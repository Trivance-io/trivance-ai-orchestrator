# 🚀 Complete Onboarding Guide - Trivance Platform

## 👋 Welcome to the Development Team

This guide will take you step by step from zero to having a fully functional development environment for Trivance Platform.

**📚 For QA/Production deployment**: See [DEPLOYMENT.md](DEPLOYMENT.md)

## 📋 Prerequisites

### Required Tools

#### 1. Sistema Operativo
- **macOS** 10.15+ (recomendado)
- **Linux** Ubuntu 20.04+ o similar
- **Windows** 10+ con WSL2

#### 2. Herramientas de Desarrollo
```bash
# Node.js (versión 18+)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Git
# macOS: brew install git
# Ubuntu: sudo apt-get install git
# Windows: https://git-scm.com/download/win

# Editor de Código (elige uno)
# VS Code: https://code.visualstudio.com/
# Cursor: https://cursor.sh/
```

#### 3. Accesos Requeridos
- [ ] **GitHub**: Acceso a la organización Trivance
- [ ] **SSH Key**: Configurada en GitHub
- [ ] **Slack**: Acceso al workspace del equipo
- [ ] **AWS** (opcional): Para desarrollo avanzado
- [ ] **MongoDB** (local o acceso remoto)

### Verificación de Prerequisitos

```bash
# Verificar versiones
node --version    # Debe ser 18+
npm --version     # Debe estar instalado
git --version     # Debe estar instalado

# Verificar acceso SSH a GitHub
ssh -T git@github.com
```

## 🚀 Setup Automático (100% Listo en Minutos)

### 🏁 Proceso de 6 Pasos - TODO AUTOMATIZADO

#### Paso 1: Crear Workspace y Clonar Configuración

```bash
# Crear directorio de trabajo
mkdir -p ~/Desarrollo/Trivance-Platform
cd ~/Desarrollo/Trivance-Platform

# Clonar repositorio de configuraciones
git clone https://github.com/GLab-Projects/trivance-dev-config.git
```

#### Paso 2: OBLIGATORIO - Validación Pre-Setup

```bash
# Validar configuración (interactivo - verifica organización, ramas, accesos)
./trivance-dev-config/scripts/core/pre-setup-validation.sh
```

#### Paso 3: Ejecutar Setup Completo (Automatizado)

```bash
# Setup completamente automatizado
./trivance-dev-config/setup.sh
```

#### Paso 4: Iniciar Servicios

```bash
# Todo pre-configurado, listo para ejecutar
./start-all.sh
```

#### Paso 5: Validar Instalación

```bash
# Verificación de salud completa
./status.sh
```

#### Paso 6: NUEVO - Verificación de Compilación (Obligatorio)

```bash
# MANDATORY: Verificar que todos los repositorios compilen
./scripts/utils/verify-compilation.sh
```

### 🎉 ¡Listo! El setup automáticamente:

- ✅ **Clona todos los repositorios** (4 repos)
- ✅ **Instala todas las dependencias** automáticamente
- ✅ **Genera variables de entorno** con secretos seguros
- ✅ **Configura workspace** VS Code/Cursor
- ✅ **Copia configuraciones AI** robustas
- ✅ **Configura Firebase** en modo desarrollo opcional
- ✅ **Verifica que TODO compila** exitosamente
- ✅ **Scripts de automatización** listos

### ⚡ ZERO CONFIGURACIÓN MANUAL REQUERIDA

🎯 **Variables de entorno auto-generadas:**
- Secretos JWT seguros (Base64)
- URLs de desarrollo pre-configuradas
- Bases de datos locales configuradas
- CORS y APIs pre-configurados
- Firebase en modo desarrollo

## 🎯 Flujo de Desarrollo Post-Setup

### Uso Diario (Después del setup)

```bash
# Iniciar desarrollo (30 segundos)
cd ~/Desarrollo/Trivance-Platform
./start-all.sh

# URLs de desarrollo disponibles:
# • Frontend: http://localhost:5173
# • Backend API: http://localhost:3000
# • Auth Service: http://localhost:3001
# • GraphQL: http://localhost:3000/graphql

# Verificar estado de servicios
./status.sh

# Verificar compilación (si se hicieron cambios)
./scripts/utils/verify-compilation.sh

# Finalizar día de desarrollo
pm2 stop all
```

### Comandos de Desarrollo Frecuentes

```bash
# Verificar estado completo del workspace
./status.sh

# Re-verificar que todo compila (obligatorio antes de commits)
./scripts/utils/verify-compilation.sh

# Reiniciar servicios si hay problemas
pm2 stop all
./start-all.sh

# Abrir workspace en VS Code
code TrivancePlatform.code-workspace
```

## 🔧 Setup Manual (Si el automático falla)

### Paso 1: Clonar Repositorios Manualmente

```bash
# En el directorio Trivance
git clone git@github.com:trivance/ms_level_up_management.git
git clone git@github.com:trivance/ms_trivance_auth.git  
git clone git@github.com:trivance/level_up_backoffice.git
git clone git@github.com:trivance/trivance-mobile.git
```

### Paso 2: Instalar Dependencias

```bash
# Para cada repositorio
cd ms_level_up_management && npm install && cd ..
cd ms_trivance_auth && npm install && cd ..
cd level_up_backoffice && npm install && cd ..
cd trivance-mobile && npm install && cd ..
```

### Paso 3: Configurar Workspace

```bash
# Copiar configuraciones desde dev-config
cp trivance-dev-config/.claude ./ -r
cp trivance-dev-config/.ai-config ./ -r
cp trivance-dev-config/scripts ./ -r
cp trivance-dev-config/templates/TrivancePlatform.code-workspace.template ./TrivancePlatform.code-workspace

# Dar permisos a scripts
chmod +x scripts/*.sh
```

## 📱 Configuración por Herramienta AI

### Para Claude Code
```bash
# Ya configurado automáticamente en .claude/
# Verificar archivos:
ls -la .claude/
# settings.json, context.md, commands.md, prompts.md
```

### Para Cursor
```bash
# Copiar configuración específica
cp trivance-dev-config/templates/.cursorrules.template ./.cursorrules
cp trivance-dev-config/templates/.cursor-settings.template ./.cursor-settings.json
```

### Para VS Code
```bash
# Configurar workspace (ya hecho automáticamente)
code TrivancePlatform.code-workspace

# Configurar settings locales (opcional)
mkdir -p .vscode
cp trivance-dev-config/templates/.vscode-settings.template .vscode/settings.json
```

### Para GitHub Copilot
```bash
# Crear instrucciones para Copilot
mkdir -p .github
cp trivance-dev-config/.ai-config/context.md .github/copilot-instructions.md
```

## 🔐 Configuración de Seguridad

### Git Configuration
```bash
# Configurar Git con tus datos
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@example.com"

# Configurar SSH key (si no está configurada)
ssh-keygen -t ed25519 -C "tu-email@example.com"
cat ~/.ssh/id_ed25519.pub
# Agregar la key a GitHub: Settings > SSH and GPG keys
```

### Variables de Entorno Críticas

#### ms_level_up_management (.env)
```bash
NODE_ENV=development
PORT=3000
DATABASE_URL=mongodb://localhost:27017/trivance_management
JWT_SECRET=tu-jwt-secret-super-seguro
AWS_ACCESS_KEY_ID=tu-aws-key
AWS_SECRET_ACCESS_KEY=tu-aws-secret
SENTRY_DSN=tu-sentry-dsn
```

#### ms_trivance_auth (.env)
```bash
NODE_ENV=development
PORT=3001
DATABASE_URL=mongodb://localhost:27017/trivance_auth
JWT_SECRET=tu-jwt-secret-super-seguro
BCRYPT_ROUNDS=12
```

## 🚀 Primer Inicio

### Paso 1: Iniciar Servicios Backend

```bash
# Opción A: Iniciar todos los servicios automáticamente
./start-all.sh

# Opción B: Iniciar manualmente (para debugging)
cd ms_trivance_auth && npm run start:dev &
cd ms_level_up_management && npm run start:dev &
cd level_up_backoffice && npm run dev &
```

### Paso 2: Verificar Servicios

```bash
# Verificar que todos los servicios respondan
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3000/health  # Management API
curl http://localhost:5173         # Frontend

# Abrir interfaces web
open http://localhost:5173          # Frontend
open http://localhost:3000/graphql  # GraphQL Playground
open http://localhost:3001/api-docs # Swagger Auth
```

### Paso 3: Ejecutar Tests

```bash
# Tests unitarios en cada repo
cd ms_level_up_management && npm test
cd ms_trivance_auth && npm test
cd level_up_backoffice && npm test
cd trivance-mobile && npm test
```

## 🎯 Configuración Específica por Rol

### Frontend Developer
```bash
# Configuración adicional para frontend
cd level_up_backoffice

# Instalar extensiones recomendadas VS Code
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension esbenp.prettier-vscode

# Verificar scripts disponibles
npm run --help
```

### Backend Developer
```bash
# Configuración adicional para backend
cd ms_level_up_management

# Instalar herramientas de MongoDB
brew install mongodb/brew/mongodb-community  # macOS
# sudo apt-get install mongodb  # Ubuntu

# Verificar conexión a base de datos
npm run start:dev
# Revisar logs para confirmar conexión exitosa
```

### Mobile Developer
```bash
# Configuración adicional para mobile
cd trivance-mobile

# Instalar Expo CLI globalmente
npm install -g @expo/cli

# Para iOS (solo macOS)
# Instalar Xcode desde App Store
# sudo xcode-select --install

# Para Android
# Instalar Android Studio
# Configurar ANDROID_HOME

# Verificar setup
npx expo doctor
```

### DevOps/Full-Stack
```bash
# Configuración completa
# Todos los pasos anteriores +

# Docker (opcional para containerización)
# AWS CLI (para deployment)
brew install awscli  # macOS
# aws configure

# Herramientas de monitoring
# Instalar extensiones de debugging
```

## 📚 Recursos de Aprendizaje

### Documentación del Proyecto
- **Arquitectura**: `docs/ARCHITECTURE.md` en cada repo
- **API Docs**: `docs/API.md` en repos backend
- **Deployment**: `docs/DEPLOYMENT.md` en cada repo

### Guías Técnicas
- **Workflows**: `trivance-dev-config/docs/WORKFLOWS.md`
- **Troubleshooting**: `trivance-dev-config/docs/TROUBLESHOOTING.md`
- **Patrones**: `.ai-config/patterns.md`

### Enlaces Útiles
- **Slack**: #dev-general, #dev-support, #dev-announcements
- **Jira**: [url-jira] (para tareas)
- **Confluence**: [url-confluence] (documentación interna)
- **Staging**: https://staging-admin.trivance.com

## ✅ Checklist de Onboarding Completo

### Configuración Técnica
- [ ] Node.js 18+ instalado
- [ ] Git configurado con SSH
- [ ] Repositorios clonados
- [ ] Dependencias instaladas
- [ ] Variables de entorno configuradas
- [ ] Servicios iniciando correctamente
- [ ] Tests pasando
- [ ] Editor configurado con extensiones

### Configuración AI
- [ ] Claude Code funcionando
- [ ] Herramienta AI preferida configurada
- [ ] Prompts personalizados disponibles
- [ ] Contexto del proyecto cargado

### Accesos y Cuentas
- [ ] GitHub con permisos apropiados
- [ ] Slack configurado
- [ ] AWS acceso (si aplica)
- [ ] MongoDB acceso
- [ ] VPN configurada (si aplica)

### Conocimiento del Proyecto
- [ ] Arquitectura entendida
- [ ] Workflows de desarrollo claros
- [ ] Proceso de deployment conocido
- [ ] Contactos del equipo identificados

## 🆘 Troubleshooting Común

### Problemas de Instalación
```bash
# Node modules no instalan
rm -rf node_modules package-lock.json
npm install

# Problemas de permisos
sudo chown -R $(whoami) ~/.npm

# Puerto en uso
lsof -ti:3000 | xargs kill -9
```

### Problemas de Servicios
```bash
# MongoDB no conecta
# Verificar que MongoDB esté corriendo
brew services start mongodb/brew/mongodb-community  # macOS

# Servicios no inician
./status.sh
# Revisar logs en logs/
```

### Problemas de Git
```bash
# SSH no funciona
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com

# Permisos de repositorio
# Contactar admin para acceso
```

## 🎉 ¡Onboarding Completado!

Si llegaste hasta aquí y todos los checks están ✅, ¡felicitaciones!

### Próximos Pasos
1. **Revisar primera tarea** asignada en Jira
2. **Unirse a daily standups** (9:00 AM)
3. **Conocer al equipo** en #dev-general
4. **Hacer primer commit** (aunque sea pequeño)

### Recursos de Ayuda
- **Buddy asignado**: [nombre-buddy]
- **Tech Lead**: [nombre-tech-lead]
- **Slack**: #dev-support para preguntas
- **Documentación**: Siempre actualizada en trivance-dev-config

### Feedback
Tu experiencia de onboarding es importante. Comparte feedback en:
- **Slack**: #dev-feedback
- **Email**: dev-team@trivance.com

---

**¡Bienvenido oficialmente al equipo de desarrollo de Trivance Platform!** 🚀

Estamos emocionados de trabajar contigo y esperamos tus contribuciones al proyecto.