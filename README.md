# 🤖 Trivance Platform - Configuraciones de Desarrollo

## 🎯 Propósito

Este directorio contiene todas las configuraciones, scripts y herramientas necesarias para mantener un entorno de desarrollo homogéneo y eficiente en el equipo de Trivance Platform.

## 🚀 Setup Rápido (Nuevos Desarrolladores)

```bash
# 1. Clonar repositorio de configuraciones
git clone git@github.com:GLab-Projects/trivance-dev-config.git
cd trivance-dev-config

# 2. Ejecutar setup automático (clona todos los repos)
./scripts/setup-workspace.sh

# 3. ¡Listo! Tu workspace está configurado
```

## 📁 Estructura del Repositorio

```
trivance-dev-config/
├── .claude/              # Configuración Claude Code
├── .ai-config/           # Configuración agnóstica para herramientas AI
├── scripts/              # Scripts de automatización
├── templates/            # Templates para editores
├── docs/                 # Documentación del equipo
├── team-config/          # Configuraciones compartidas (ESLint, etc.)
└── README.md             # Este archivo
```

## 🔧 Herramientas Soportadas

- **Claude Code** - Configuración completa en `.claude/`
- **VS Code** - Templates de workspace y settings
- **Cursor** - Configuración específica 
- **GitHub Copilot** - Instrucciones contextuales
- **Otras herramientas AI** - Configuración agnóstica en `.ai-config/`

## 📋 Comandos Principales

### Setup y Sincronización
```bash
./scripts/setup-workspace.sh      # Setup inicial completo
./scripts/sync-configs.sh          # Sincronizar cambios nuevos
./scripts/update-repos.sh          # Actualizar todos los repositorios
```

### Desarrollo
```bash
./scripts/start-all-services.sh    # Iniciar todos los servicios
./scripts/stop-all-services.sh     # Detener todos los servicios  
./scripts/test-all.sh              # Ejecutar tests en todos los repos
./scripts/lint-all.sh              # Linting de todos los repos
```

### Utilidades
```bash
./scripts/check-health.sh          # Verificar estado de servicios
./scripts/clean-workspace.sh       # Limpiar caches y builds
./scripts/backup-configs.sh        # Backup de configuraciones locales
```

## 🌍 Environments

El workspace soporta múltiples environments:

- **local** (default) - Desarrollo local
- **qa** - Testing en environment QA  
- **prod** - Verificación pre-producción

```bash
# Ejemplos
./scripts/start-all-services.sh local
./scripts/start-all-services.sh qa mobile
./scripts/start-all-services.sh prod
```

## 👥 Para Desarrolladores Existentes

Si ya tienes el workspace configurado y quieres sincronizar cambios:

```bash
cd trivance-dev-config
git pull
./scripts/sync-configs.sh
```

## 🔄 Actualizar Configuraciones

### Para Team Leads
```bash
# 1. Editar configuraciones necesarias
vim .claude/context.md
vim scripts/start-all-services.sh

# 2. Commit y push
git add .
git commit -m "feat: actualizar configuración para nueva feature"
git push

# 3. Notificar al equipo (Slack/Teams)
```

### Para Desarrolladores
```bash
# Cuando recibas notificación de update
git pull
./scripts/sync-configs.sh
```

## 📚 Documentación

- [Onboarding Completo](docs/ONBOARDING.md)
- [Workflows de Desarrollo](docs/WORKFLOWS.md) 
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Manual AI-First](docs/AI-FIRST-GUIDE.md)

## 🆘 Soporte

### Problemas Comunes
- **Script falla**: Verificar permisos `chmod +x scripts/*.sh`
- **Configuración no se aplica**: Ejecutar `./scripts/sync-configs.sh`
- **Servicios no inician**: Verificar puertos con `./scripts/check-health.sh`

### Contacto
- **Slack**: #dev-support
- **Email**: dev-team@trivance.com
- **Issues**: GitHub Issues en este repositorio

## 🔒 Seguridad

- ❌ **NUNCA** commitear credenciales o secrets
- ✅ Usar `.env.example` files como templates
- ✅ Revisar PRs de configuraciones cuidadosamente
- ✅ Mantener scripts con permisos apropiados

---

**Versión**: 1.0.0  
**Última actualización**: 2 de julio de 2025  
**Mantenido por**: Equipo Trivance DevOps