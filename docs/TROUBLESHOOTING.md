# 🔧 Guía de Troubleshooting - Trivance Platform

## 🎯 Problemas Comunes y Soluciones

### ⚙️ NUEVO: Verificación de Compilación

#### Fallos de Compilación

**Problema**: verify-compilation.sh falla
```bash
❌ COMPILATION VERIFICATION FAILED
❌ 2/4 repositories failed compilation
```
**Solución**:
```bash
# 1. Verificar logs de compilación
ls -la logs/compilation/

# 2. Ver detalles del error de cada repo
cat logs/compilation/ms_level_up_management_build.log
cat logs/compilation/level_up_backoffice_build.log

# 3. Solución común: regenerar variables de entorno
cd ms_level_up_management
rm .env
cd ../ms_trivance_auth  
rm .env
cd ..

# 4. Re-ejecutar configuración
./trivance-dev-config/scripts/core/orchestrator.sh

# 5. Intentar compilación nuevamente
./scripts/verify-compilation.sh
```

#### ⚠️ CRÍTICO: Error de Timeout en macOS

**Problema**: timeout command not found en macOS
```bash
timeout: command not found
parallel-install.sh: line 30: timeout: command not found
```
**Solución**: ✅ **YA RESUELTO AUTOMÁTICAMENTE** - Sistema implementa timeout universal:
```bash
# Detección automática de timeout en parallel-install.sh
if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_duration" "${cmd[@]}"
elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$timeout_duration" "${cmd[@]}"
else
    # Implementación nativa bash para macOS
    "${cmd[@]}" &
    local cmd_pid=$!
    ( sleep "$timeout_duration" && kill -TERM $cmd_pid 2>/dev/null ) &
    local timeout_pid=$!
    wait $cmd_pid
    kill $timeout_pid 2>/dev/null
fi
```
**Nota**: Este fix es **cross-platform** y funciona en Windows, Mac y Linux automáticamente.

**Problema**: React Native TypeScript errores
```bash
TypeScript has warnings/errors (common in development)
```
**Solución**: ✅ **NORMAL** - React Native con Expo tolera errores de TypeScript en desarrollo. El proyecto sigue siendo funcional para builds EAS.

**Problema**: Firebase credenciales faltantes
```bash
Service account object must contain a string "project_id" property
```
**Solución**: ✅ **YA RESUELTO** - Firebase ahora es opcional en desarrollo. El servicio inicia con configuración por defecto.

**Problema**: Error de Sentry Sourcemaps
```bash
error: Auth token is required for this request. Please run `sentry-cli login`
```
**Solución**: ✅ **AUTO-CORREGIDO** - El sistema aplica automáticamente un fix en el **Paso 6/7** que:
- Agrega script `build:dev` sin Sentry para desarrollo
- El verificador de compilación usa `build:dev` automáticamente  
- Mantiene `build` original para producción

**📋 Fixes Automáticos:** Todos aplicados en Paso 6/7:
1. **Sentry Build Fix** para ms_level_up_management
2. **Verificación de Variables** de entorno
3. **Detección de Conflictos** de puerto
4. **Configuración TypeScript** para React Native

### 🚀 Problemas de Setup Inicial

#### Node.js y NPM

**Problema**: Node.js versión incorrecta
```bash
Error: Node.js version 16.x.x is not supported
```
**Solución**:
```bash
# Instalar Node.js 18+
nvm install 18
nvm use 18
nvm alias default 18

# Verificar versión
node --version  # Debe mostrar v18.x.x
```

**Problema**: NPM permisos
```bash
Error: EACCES: permission denied
```
**Solución**:
```bash
# Cambiar propietario del directorio npm
sudo chown -R $(whoami) ~/.npm

# O usar nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

#### Git y SSH

**Problema**: SSH key no configurada
```bash
git@github.com: Permission denied (publickey)
```
**Solución**:
```bash
# Generar nueva SSH key
ssh-keygen -t ed25519 -C "tu-email@trivance.com"

# Agregar a SSH agent
ssh-add ~/.ssh/id_ed25519

# Copiar key pública
cat ~/.ssh/id_ed25519.pub
# Agregar en GitHub: Settings > SSH and GPG keys

# Probar conexión
ssh -T git@github.com
```

**Problema**: Git configuración faltante
```bash
Please tell me who you are
```
**Solución**:
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@trivance.com"
```

### 📦 Problemas de Dependencias

#### Variables de Entorno Auto-Generadas

**Problema**: Variables de entorno faltantes o incorrectas
```bash
Error: JWT_SECRET is not defined
```
**Solución**: ✅ **YA NO OCURRE** - El sistema ahora auto-genera todas las variables:
```bash
# Si por alguna razón necesitas regenerar:
cd ms_level_up_management
rm .env
cd ../ms_trivance_auth
rm .env
cd ..

# Re-ejecutar setup para regenerar
./trivance-dev-config/setup.sh
```

#### Node Modules

**Problema**: Dependencias no instalan
```bash
npm ERR! peer dep missing
```
**Solución**:
```bash
# Limpiar cache
npm cache clean --force

# Eliminar node_modules y reinstalar
rm -rf node_modules package-lock.json
npm install

# Si persiste, usar --legacy-peer-deps
npm install --legacy-peer-deps
```

**Problema**: Conflictos de versiones
```bash
Error: Cannot resolve dependency tree
```
**Solución**:
```bash
# Para desarrollo, forzar resolución
npm install --force

# Para producción, actualizar dependencias
npm audit fix
npm update
```

#### Python/Native Dependencies

**Problema**: Error compilando dependencias nativas
```bash
gyp ERR! stack Error: not found: make
```
**Solución**:
```bash
# macOS
xcode-select --install

# Ubuntu/Debian
sudo apt-get install build-essential

# Windows (usar en WSL o GitBash)
# Instalar Visual Studio Build Tools
```

### 🔌 Problemas de Servicios

#### Puertos en Uso

**Problema**: Puerto ya está en uso
```bash
Error: listen EADDRINUSE :::3000
```
**Solución**:
```bash
# Ver qué proceso usa el puerto
lsof -i :3000

# Matar proceso específico
lsof -ti:3000 | xargs kill -9

# O usar script de limpieza
./scripts/stop-all-services.sh
```

#### MongoDB Conexión

**Problema**: No puede conectar a MongoDB
```bash
MongoNetworkError: failed to connect to server
```
**Solución**:
```bash
# Verificar si MongoDB está corriendo
brew services list | grep mongo  # macOS
sudo systemctl status mongod     # Linux

# Iniciar MongoDB
brew services start mongodb-community  # macOS
sudo systemctl start mongod            # Linux

# Verificar configuración en .env
DATABASE_URL=mongodb://localhost:27017/trivance
```

#### JWT/Auth Issues

**Problema**: JWT token inválido
```bash
JsonWebTokenError: invalid token
```
**Solución**:
```bash
# Verificar JWT_SECRET en .env de ambos servicios auth y management
# Deben ser idénticos

# ms_trivance_auth/.env
JWT_SECRET=tu-secret-super-seguro-aqui

# ms_level_up_management/.env  
JWT_SECRET=tu-secret-super-seguro-aqui

# Reiniciar servicios
./scripts/stop-all-services.sh
./scripts/start-all-services.sh
```

### 🎨 Problemas de Frontend

#### Build Errors

**Problema**: TypeScript errores
```bash
TS2345: Argument of type 'string' is not assignable to parameter of type 'number'
```
**Solución**:
```bash
# Verificar y corregir tipos
# Limpiar cache de TypeScript
rm -rf .tsbuildinfo
rm -rf dist/

# Verificar configuración
npx tsc --noEmit

# Reinstalar @types si es necesario
npm install @types/react @types/node --save-dev
```

**Problema**: Vite build falla
```bash
Error: Build failed with errors
```
**Solución**:
```bash
# Limpiar cache de Vite
rm -rf node_modules/.vite
rm -rf dist/

# Verificar imports
# Buscar imports circulares
npm run build -- --debug

# Verificar que todas las dependencias estén instaladas
npm install
```

#### Runtime Errors

**Problema**: Module not found
```bash
Module not found: Can't resolve './Component'
```
**Solución**:
```bash
# Verificar path del import
# Verificar que el archivo existe
# Verificar case sensitivity (Component vs component)

# Para imports absolutos, verificar vite.config.ts
alias: {
  '@': path.resolve(__dirname, './src'),
}
```

### 📱 Problemas de Mobile

#### Expo Issues

**Problema**: Expo no inicia
```bash
Error: Expo CLI not found
```
**Solución**:
```bash
# Instalar Expo CLI
npm install -g @expo/cli

# O usar npx
npx expo start

# Verificar setup
npx expo doctor
```

**Problema**: Metro bundler error
```bash
Error: Metro bundler has encountered an internal error
```
**Solución**:
```bash
# Limpiar cache de Metro
npx expo start --clear

# O usar npm script
npm run clean

# Limpiar cache completo
rm -rf node_modules/.cache
rm -rf .expo
npm install
```

#### iOS/Android Issues

**Problema**: iOS build falla
```bash
xcodebuild: error: Unable to find a destination
```
**Solución**:
```bash
# Verificar Xcode instalado y actualizado
xcode-select --install

# Verificar simuladores disponibles
xcrun simctl list devices

# Limpiar derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Verificar certificados
npx expo run:ios --device
```

**Problema**: Android build falla
```bash
ANDROID_HOME is not set
```
**Solución**:
```bash
# Configurar Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
export ANDROID_HOME=$HOME/Android/Sdk          # Linux

# Agregar a PATH
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Agregar a ~/.bashrc o ~/.zshrc
```

### 🔍 Problemas de Development Tools

#### VS Code/Cursor

**Problema**: Extensions no funcionan
```bash
Extension host terminated unexpectedly
```
**Solución**:
```bash
# Deshabilitar todas las extensiones
# Rehabilitar una por una para identificar la problemática

# Limpiar cache de VS Code
# macOS: ~/Library/Application Support/Code/User/workspaceStorage
# Linux: ~/.config/Code/User/workspaceStorage

# Reinstalar VS Code/Cursor
```

**Problema**: TypeScript IntelliSense lento
```bash
TypeScript server is not responding
```
**Solución**:
```bash
# En VS Code: Cmd+Shift+P > "TypeScript: Restart TS Server"

# Verificar versión de TypeScript
npm list typescript

# Configurar memoria para TS
// En .vscode/settings.json
{
  "typescript.preferences.maxTsServerMemory": 4096
}
```

#### Claude Code Issues

**Problema**: Claude no lee configuración
```bash
Claude doesn't seem to understand project context
```
**Solución**:
```bash
# Verificar estructura de archivos
ls -la .claude/
# Debe contener: settings.json, context.md, commands.md, prompts.md

# Verificar que settings.json es JSON válido
python3 -m json.tool .claude/settings.json

# Sincronizar configuraciones
./scripts/sync-configs.sh
```

### 🌐 Problemas de Red y APIs

#### API Connection Issues

**Problema**: Cannot connect to backend
```bash
Network Error: Connection refused
```
**Solución**:
```bash
# Verificar que backend está corriendo
curl http://localhost:3000/graphql  # GraphQL endpoint funcional
curl http://localhost:3001/health

# IMPORTANTE: La raíz / retorna 404 - ES NORMAL
# {"message":"Cannot GET /","error":"Not Found","statusCode":404}
# Esto NO es un error, es diseño estándar de APIs REST/GraphQL

# Verificar configuración de URLs en frontend
# level_up_backoffice/.env
VITE_API_URL=http://localhost:3000
VITE_AUTH_URL=http://localhost:3001

# Verificar CORS en backend
# Debe permitir origen del frontend
```

#### ✅ Endpoints Funcionales Confirmados

**Backend Management API (Puerto 3000)**:
```bash
# GraphQL Playground - FUNCIONAL
http://localhost:3000/graphql

# Endpoints API REST disponibles:
/api/auth          # Autenticación
/api/users         # Gestión de usuarios  
/api/organizations # Organizaciones
/api/donations     # Donaciones
/api/initiatives   # Iniciativas
# Y 25+ endpoints más

# Verificar tipos GraphQL disponibles
curl -s -H "Content-Type: application/json" \
  -X POST \
  -d '{"query":"{ __schema { types { name } } }"}' \
  http://localhost:3000/graphql
```

**Backend Auth Service (Puerto 3001)**:
```bash
# Auth endpoints disponibles
/api/auth/login
/api/auth/register
/api/auth/refresh
/api/auth/profile
```

#### GraphQL Issues

**Problema**: GraphQL schema not found
```bash
GraphQL Error: Schema not found
```
**Solución**:
```bash
# Regenerar schema en backend
cd ms_level_up_management
npm run build

# Verificar que schema.gql se genera
ls src/schema.gql

# Limpiar cache de Apollo
# En frontend, limpiar apollo cache
```

### 🔒 Problemas de Seguridad y Permisos

#### File Permissions

**Problema**: Scripts no ejecutan
```bash
Permission denied: ./scripts/setup-workspace.sh
```
**Solución**:
```bash
# Dar permisos de ejecución
chmod +x scripts/*.sh

# Verificar permisos
ls -la scripts/

# Si persiste, ejecutar directamente con bash
bash scripts/setup-workspace.sh
```

#### Environment Variables

**Problema**: Variables de entorno no se cargan
```bash
process.env.JWT_SECRET is undefined
```
**Solución**:
```bash
# Verificar que existe archivo .env
ls -la .env

# Verificar formato del archivo .env (sin espacios alrededor del =)
JWT_SECRET=mi-secret-aqui

# Para Vite (frontend), usar prefijo VITE_
VITE_API_URL=http://localhost:3000

# Reiniciar servidor después de cambios en .env
```

## 🚨 Scripts de Diagnóstico

### Health Check Completo
```bash
# Ejecutar diagnóstico completo
./scripts/check-health.sh

# Ver logs detallados
./scripts/check-health.sh --verbose
```

### Limpieza Completa
```bash
# Limpiar todo y empezar de cero
./scripts/clean-workspace.sh

# Reinstalar todo
./scripts/setup-workspace.sh
```

### Logs y Debugging
```bash
# Ver logs de servicios en tiempo real
tail -f logs/Management\ API.log
tail -f logs/Auth\ Service.log
tail -f logs/Frontend.log

# Ver todos los logs
./scripts/show-logs.sh

# Debug específico por servicio
cd ms_level_up_management && npm run start:dev:debug
```

## 📊 Herramientas de Diagnóstico

### System Information
```bash
# Información del sistema
./scripts/system-info.sh

# Salida ejemplo:
# Node.js: v18.17.0
# NPM: 9.6.7
# Git: 2.39.2
# OS: Darwin 22.5.0
# Memory: 16GB
# Disk: 256GB SSD
```

### Port Scanner
```bash
# Verificar puertos en uso
./scripts/check-ports.sh

# Salida ejemplo:
# Port 3000: Management API (✅ Running)
# Port 3001: Auth Service (✅ Running)  
# Port 5173: Frontend (✅ Running)
# Port 19000: Expo (❌ Not running)
```

### Dependency Check
```bash
# Verificar dependencias desactualizadas
./scripts/check-dependencies.sh

# Por repositorio
cd ms_level_up_management && npm outdated
cd ms_trivance_auth && npm outdated
cd level_up_backoffice && npm outdated
cd trivance-mobile && npm outdated
```

## 🆘 Escalación de Problemas

### Niveles de Soporte

#### Nivel 1: Auto-resolución
- Consultar esta guía de troubleshooting
- Ejecutar scripts de diagnóstico
- Buscar en documentación del proyecto

#### Nivel 2: Equipo de Desarrollo
- **Slack**: #dev-support
- **Timeframe**: Respuesta en 2-4 horas
- **Incluir**: Logs, screenshots, pasos para reproducir

#### Nivel 3: Tech Lead
- **Slack**: DM al tech lead
- **Email**: tech-lead@trivance.com
- **Timeframe**: Respuesta en 1 hora
- **Para**: Problemas críticos o bloqueantes

#### Nivel 4: Emergencia
- **Phone**: +1-XXX-XXX-XXXX
- **Para**: Sistema completamente caído
- **Timeframe**: Respuesta inmediata

### Información a Incluir en Reportes

#### Template de Bug Report
```markdown
## 🐛 Descripción del Problema
Descripción clara y concisa del problema.

## 🔄 Pasos para Reproducir
1. Paso 1
2. Paso 2
3. Paso 3

## 🎯 Comportamiento Esperado
Qué debería pasar normalmente.

## 💻 Entorno
- OS: [macOS/Linux/Windows]
- Node.js: [versión]
- Navegador: [si aplica]
- Repositorio: [cual repo]

## 📋 Logs/Screenshots
```
[Incluir logs relevantes]
```

## 📝 Información Adicional
Cualquier contexto adicional.
```

## 🔧 Configuraciones de Emergencia

### Rollback Rápido
```bash
# Si algo se rompe después de cambios
git stash
git checkout HEAD~1
./scripts/start-all-services.sh
```

### Configuración Mínima
```bash
# Variables de entorno mínimas para que funcione

# ms_level_up_management/.env
NODE_ENV=development
PORT=3000
DATABASE_URL=mongodb://localhost:27017/trivance
JWT_SECRET=development-secret-key

# ms_trivance_auth/.env  
NODE_ENV=development
PORT=3001
DATABASE_URL=mongodb://localhost:27017/trivance_auth
JWT_SECRET=development-secret-key
```

### Bypass de Problemas Comunes
```bash
# Saltear problemas de SSL en desarrollo
export NODE_TLS_REJECT_UNAUTHORIZED=0

# Aumentar memoria para Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# Timeout más largo para npm
export NPM_CONFIG_TIMEOUT=300000
```

---

## 💡 Consejos Preventivos

1. **Siempre hacer backup** antes de cambios grandes
2. **Usar ./scripts/check-health.sh** regularmente
3. **Mantener dependencias actualizadas** semanalmente
4. **Documentar problemas nuevos** en este archivo
5. **Compartir soluciones** con el equipo

---

**Última actualización**: 2 de julio de 2025  
**Mantenido por**: Equipo de DevOps Trivance

¿Encontraste un problema no documentado? ¡Agrega la solución a esta guía! 🚀