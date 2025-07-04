# 🚀 Trivance Dev Config

**Configuración automatizada de desarrollo para la plataforma Trivance**

Sistema de configuración automática diseñado para IA y desarrolladores que permite configurar todo el entorno de desarrollo de Trivance en segundos, sin intervención manual.

## 🎯 **Objetivo Principal**

Configurar automáticamente el entorno completo de desarrollo de Trivance con:
- **4 repositorios** (2 backends NestJS, 1 frontend React, 1 mobile React Native)
- **Variables de entorno** generadas automáticamente
- **Dependencias** instaladas con protección de timeout
- **Verificación de compilación** obligatoria para todos los repos
- **Herramientas de desarrollo** configuradas (VS Code, Claude)

## ⚡ **Inicio Rápido - Un Solo Comando**

```bash
# Clona este repo y ejecuta el setup automático
git clone [REPO_URL] trivance-dev-config
cd trivance-dev-config
./setup.sh
```

**🎉 ¡Listo! En 5-10 minutos tendrás todo configurado automáticamente.**

## ✨ **Características Principales**

### 🤖 **AI-First Design**
- Configuración **100% automatizada** sin intervención manual
- Compatible con **Claude Code**, **Cursor**, **GitHub Copilot**
- Variables de entorno **auto-generadas** para desarrollo
- Detección automática de errores y **auto-corrección**

### 🛡️ **Desarrollo Robusto**
- **Protección de timeout** para instalaciones largas
- **Verificación de compilación obligatoria** para todos los repos
- Manejo inteligente de errores con **logs detallados**
- **Rollback automático** en caso de fallos

### 🔧 **Zero Configuration**
- **Firebase** opcional para desarrollo
- **Base de datos** en modo desarrollo por defecto
- **CORS** preconfigurado para desarrollo local
- **Hot reload** habilitado en todos los servicios

### 📊 **Monitoreo y Observabilidad**
- Health checks automáticos para todos los servicios
- Logs centralizados en `./logs/`
- Progress indicators en tiempo real
- Compilación tracking por repositorio

## 📁 **Estructura del Proyecto**

```
trivance-dev-config/
├── README.md                 # 📖 Este archivo
├── setup.sh                  # 🎯 Script principal de configuración
├── config/
│   ├── repositories.json     # 📦 Configuración de repos a clonar
│   └── environments.json     # 🔐 Variables de entorno por ambiente
├── scripts/
│   ├── core/
│   │   └── orchestrator.sh   # 🎼 Orquestador principal
│   ├── utils/
│   │   ├── common.sh         # 🛠️ Utilidades compartidas
│   │   └── progress.sh       # 📊 Indicadores de progreso
│   └── verify-compilation.sh # ✅ Verificación obligatoria de compilación
├── templates/
│   ├── CLAUDE.md.template    # 🤖 Configuración para Claude
│   ├── TrivancePlatform.code-workspace.template # 💻 VS Code workspace
│   └── dynamic/
│       └── README.workspace.template # 📝 README dinámico del workspace
├── docs/
│   ├── ONBOARDING.md         # 👥 Guía de onboarding
│   ├── WORKFLOWS.md          # 🔄 Flujos de trabajo
│   ├── TROUBLESHOOTING.md    # 🔧 Solución de problemas
│   └── DEPLOYMENT.md         # 🚀 Guía de despliegue
└── tests/
    └── README.md             # 🧪 Documentación de testing
```

## 🔄 **Proceso Automatizado (7 Pasos)**

El sistema ejecuta automáticamente estos pasos:

### **Paso 1: Validación de Configuración** ✅
- Verifica archivos de configuración JSON
- Valida herramientas requeridas (Node.js, Git, npm)
- Checks de permisos y conectividad

### **Paso 2: Clonado de Repositorios** 📥
- Clona 4 repositorios desde `config/repositories.json`
- Checkout automático a rama `experiments`
- Verificación de integridad de cada repo

### **Paso 3: Configuración de Entornos** 🔐
- Genera variables de entorno automáticamente
- Configura `.env` para cada repositorio
- Manejo inteligente de secretos y credenciales

### **Paso 4: Instalación de Dependencias** 📦
- Instala `npm` dependencies con **timeout protection (10 min)**
- Progress indicators en tiempo real
- Logs detallados para debugging

### **Paso 5: Configuración de Herramientas** 🛠️
- VS Code workspace multi-repositorio
- Claude Code configuration file
- Development utilities setup

### **Paso 6: Fixes Automáticos** 🔧 **NUEVO**
- **Sentry Fix**: Agrega `build:dev` sin Sentry para desarrollo
- **Variables de Entorno**: Verifica configuración Firebase
- **Conflictos de Puerto**: Detecta puertos ocupados
- **TypeScript RN**: Configuración optimizada

### **Paso 7: Verificación de Compilación** ✅ **OBLIGATORIO**
- Compila **todos** los repositorios con fixes aplicados
- NestJS: `npm run build:dev` (desarrollo) o `npm run build` (producción)
- React: `npm run build`
- React Native: TypeScript verification
- **FALLA TODO** si algún repo no compila

## 🎮 **Comandos Principales**

```bash
# Configuración completa desde cero
./setup.sh

# Solo verificar compilación
./scripts/verify-compilation.sh

# Limpiar workspace y empezar de nuevo
./scripts/utils/clean-workspace.sh

# Health check de servicios
./scripts/utils/health-check.sh
```

## 🚦 **Después de la Configuración**

Una vez completado el setup, tendrás:

```bash
# 🗂️ Workspace organizado
├── ms_trivance_auth/          # 🔐 Auth Service (Puerto 3001)
├── ms_level_up_management/    # 📊 Management API (Puerto 3000)  
├── level_up_backoffice/       # 💻 Frontend React (Puerto 5173)
├── trivance-mobile/           # 📱 Mobile React Native
├── TrivancePlatform.code-workspace # 💼 VS Code Workspace
├── CLAUDE.md                  # 🤖 Claude Configuration
└── logs/                      # 📋 Logs centralizados

# 🎯 Comandos para iniciar servicios
cd ms_trivance_auth && npm run start:dev         # Auth Service
cd ms_level_up_management && npm run start:dev   # Management API  
cd level_up_backoffice && npm run dev           # Frontend
cd trivance-mobile && npm start                 # Mobile
```

## 🔍 **Monitoreo y Health Checks**

```bash
# Verificar estado de servicios
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3000/health  # Management API

# Ver logs en tiempo real
tail -f logs/setup.log
tail -f logs/compilation/*.log
```

## 🌟 **Características para IA**

### Claude Code Integration
- Archivo `CLAUDE.md` con contexto completo del proyecto
- Variables de entorno y estructura explicada
- Comandos más utilizados documentados

### Cursor Integration  
- Workspace configurado con settings optimizados
- Rules file para mejor code completion
- Multi-repo navigation configurada

### Auto-Fix Capabilities
- Detección automática de problemas comunes
- Sugerencias de solución en logs
- Recovery procedures documentadas

## 🚨 **Solución de Problemas Comunes**

### ❌ Error de Timeout en Instalación
```bash
# Las dependencias tardan más de 10 minutos
# 💡 Solución: Ya incluye timeout protection automático
```

### ❌ Firebase Configuration Error  
```bash
# Service account object must contain 'project_id'
# 💡 Solución: Firebase es opcional en desarrollo
```

### ❌ Compilación Falla
```bash
# TypeScript errors o missing dependencies
# 💡 Solución: Ver logs en ./logs/compilation/
```

### ❌ Puerto Ocupado
```bash
# Error: listen EADDRINUSE: address already in use :::3000
# 💡 Solución: killall node && ./setup.sh
```

## 📚 **Documentación Avanzada**

- 📖 **[Onboarding](docs/ONBOARDING.md)** - Guía paso a paso para nuevos desarrolladores
- 🔄 **[Workflows](docs/WORKFLOWS.md)** - Flujos de desarrollo y buenas prácticas  
- 🔧 **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Solución de problemas detallada
- 🚀 **[Deployment](docs/DEPLOYMENT.md)** - Guías de despliegue para QA/Prod

## 🤝 **Contribución**

Este repositorio es el **núcleo de la configuración automatizada**. Para contribuir:

1. Fork el repositorio
2. Haz cambios en rama feature
3. Asegúrate que `./setup.sh` funciona completamente
4. Ejecuta `./scripts/verify-compilation.sh` 
5. Submit PR con descripción detallada

## 📄 **Licencia**

Propiedad de Gracia Lab - Uso interno y colaboradores autorizados únicamente.

---

**⚡ ¡Configuración automática en segundos, desarrollo productivo en minutos!**

*Diseñado para IA • Optimizado para desarrolladores • Probado en producción*