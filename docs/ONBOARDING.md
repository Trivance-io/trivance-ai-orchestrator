# 🚀 Guía de Onboarding - Trivance Platform

## 👋 Bienvenido al Equipo

Esta guía te llevará de cero a tener un entorno de desarrollo completamente funcional en **menos de 10 minutos**.

## 📋 Requisitos Previos

### Herramientas Requeridas
```bash
# Node.js 18+
node --version   # Debe ser v18 o superior
npm --version    # Debe estar instalado
git --version    # Debe estar instalado

# Docker Desktop (OBLIGATORIO)
docker --version  # Debe estar instalado
docker ps         # Docker debe estar corriendo

# Verificar acceso SSH a GitHub
ssh -T git@github.com
```

### ⚠️ Docker es OBLIGATORIO
- **Docker Desktop**: Descarga desde [docker.com](https://www.docker.com/products/docker-desktop/)
- **Por qué**: Los backends y bases de datos corren en contenedores Docker
- **Nota**: No necesitas instalar PostgreSQL o MongoDB por separado

## 🚀 Setup Automático (3 Pasos)

### Paso 1: Clonar y Configurar
```bash
# Crear workspace
mkdir -p ~/Desarrollo/Trivance-Platform
cd ~/Desarrollo/Trivance-Platform

# Clonar configuración
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config
```

### Paso 2: Ejecutar Setup Completo
```bash
# TODO automático en un comando
./setup.sh
```

**Este comando hace AUTOMÁTICAMENTE**:
- ✅ Clona los 4 repositorios
- ✅ Genera secrets únicos y seguros
- ✅ Instala todas las dependencias
- ✅ Configura variables de entorno
- ✅ Verifica que todo compile
- ✅ Configura arquitectura híbrida Docker + PM2

### Paso 3: Iniciar Servicios
```bash
cd ..  # Volver al workspace
./start.sh
```

## 🎉 ¡Listo!

### URLs Disponibles
- **Frontend Admin**: http://localhost:5173
- **API Principal**: http://localhost:3000
- **GraphQL**: http://localhost:3000/graphql
- **Auth Service**: http://localhost:3001

### 📱 App Móvil
```bash
# En nueva terminal
cd trivance-mobile
npm run start:docker   # Conecta automáticamente a servicios Docker

# ✅ Configuración automática: 
# - .env se genera automáticamente
# - env.local.ts se genera automáticamente en src/environments/
# - No necesitas crear archivos manualmente

# Alternativa manual (si necesitas configuración específica):
cp .env.example .env.local
# Editar .env.local: ENV_LOCAL=true
npm start
```

### Comandos Diarios
```bash
./start.sh          # Menú interactivo
./start.sh start    # Iniciar servicios
./start.sh status   # Ver estado
./start.sh stop     # Detener servicios
```

## 🔧 Desarrollo Diario

### Flujo Típico
```bash
# 1. Iniciar día
./start.sh start

# 2. Verificar que todo funciona
./start.sh status

# 3. Desarrollar (los servicios se recargan automáticamente)

# 4. Antes de commit (OBLIGATORIO)
./trivance-dev-config/scripts/utils/verify-compilation.sh

# 5. Finalizar día
./start.sh stop
```

### Comandos Útiles
```bash
# Gestión de servicios
./start.sh status   # Estado de servicios
pm2 logs backoffice # Logs del frontend
docker logs -f trivance_management  # Logs del backend
./start.sh restart  # Reiniciar todos los servicios

# Environment management
./trivance-dev-config/scripts/envs.sh status   # Ver environment actual
./trivance-dev-config/scripts/envs.sh switch qa  # Cambiar a QA
```

## 🤖 Claude Code Setup

**IMPORTANTE**: Claude Code se configura automáticamente **AL FINAL** del setup exitoso.

1. **Después del setup completo**, ejecuta:
   ```bash
   /init
   ```

2. Esto generará automáticamente el `CLAUDE.md` optimizado con todo el contexto del workspace.

## 🆘 Solución de Problemas

### Error: Puerto en uso
```bash
pm2 stop all
./start.sh start
```

### Error: Dependencias
```bash
cd [repositorio-con-error]
rm -rf node_modules package-lock.json
npm install
```

### Error: Base de datos
```bash
# macOS
brew services start postgresql
brew services start mongodb-community

# Linux
sudo systemctl start postgresql
sudo systemctl start mongod
```

### Verificación Completa
```bash
./trivance-dev-config/scripts/utils/validate-setup.sh
```

## ✅ Checklist de Verificación

Después del setup, confirma:

- [ ] `pm2 status` muestra todos los servicios como `online`
- [ ] Puedes acceder a http://localhost:5173 (Frontend Admin)
- [ ] Puedes acceder a http://localhost:3000/graphql (GraphQL Playground)
- [ ] Puedes acceder a http://localhost:9999 (Dozzle - Monitor de logs)
- [ ] No hay errores en `pm2 logs`
- [ ] Existe `.trivance-secrets` en el workspace
- [ ] Existe carpeta `envs/` con archivos `.env`

## 📊 Herramientas de Monitoreo

### Monitor de Logs Docker (Dozzle)
- **URL**: http://localhost:9999
- **Propósito**: Monitoreo en tiempo real de logs de contenedores Docker
- **Comando**: `./trivance-dev-config/scripts/docker/dozzle.sh start`
- **Funcionalidad**: 
  - Logs en tiempo real de todos los servicios Docker
  - Filtrado automático de contenedores Trivance
  - Búsqueda y navegación por logs
  - Interfaz web moderna y responsiva

## 🎯 Próximos Pasos

1. **Revisar primera tarea** asignada
2. **Ejecutar /init** para configurar Claude Code
3. **Hacer primer commit** (aunque sea pequeño)
4. **Unirse al equipo** en Slack #dev-general

## 📚 Recursos

- **Troubleshooting**: `docs/TROUBLESHOOTING.md`
- **Workflows**: `docs/WORKFLOWS.md`
- **Environments**: `envs/ENVIRONMENTS.md`
- **Soporte**: Slack #dev-support

---

**¡Bienvenido oficialmente al equipo! 🚀**

Si completaste todos los checkpoints, estás listo para contribuir al proyecto.