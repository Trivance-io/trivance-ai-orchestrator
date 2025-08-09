# Trivance Dev Config

Configura automáticamente el entorno completo de desarrollo de Trivance en minutos.

## Qué hace

- Clona y configura 4 repositorios automáticamente
- Instala todas las dependencias necesarias
- Genera configuraciones seguras únicas
- Configura Docker para 2 backends y 2 bases de datos
- Prepara hot-reload instantáneo para desarrollo

## 🏗️ Arquitectura del Sistema

### 🐳 Arquitectura Híbrida Completa: Docker + PM2 + Expo

```
┌─────────────────────────────────────────────────────────────┐
│                  TRIVANCE PLATFORM COMPLETA                │
├─────────────────────────────────────────────────────────────┤
│ CLIENT LAYER                                               │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Web Admin       │ │ Mobile App      │                   │
│ │ localhost:5173  │ │ Expo QR Code    │                   │
│ │ (PM2 + Vite)    │ │ (Metro Bundler) │                   │
│ │ Hot-reload ≤1s  │ │ Hot-reload ≤1s  │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ BACKEND LAYER (Docker)                                     │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Management API  │ │ Auth Service    │                   │
│ │ localhost:3000  │ │ localhost:3001  │                   │
│ │ (NestJS+GraphQL)│ │ (NestJS+REST)   │                   │
│ │ Hot-reload ≤2s  │ │ Hot-reload ≤2s  │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ DATABASE LAYER (Docker)                                    │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ PostgreSQL      │ │ MongoDB         │                   │
│ │ localhost:5432  │ │ localhost:27017 │                   │
│ │ (Management DB) │ │ (Auth DB)       │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ OBSERVABILITY (Docker)                                     │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Log Viewer      │ │ Dozzle Monitor  │                   │
│ │ localhost:4000  │ │ localhost:9999  │                   │
│ └─────────────────┘ └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

### 🎯 Decisiones de Arquitectura Claves

| Decisión | Justificación | Beneficio |
|----------|---------------|-----------|
| **Docker para 2 Backends** | Aislamiento de Management API + Auth Service | Zero conflictos entre servicios |
| **PM2 para Web Admin** | Hot-reload instantáneo, desarrollo ágil | Productividad máxima frontend |
| **Expo para Mobile** | Metro bundler nativo, debugging integrado | Desarrollo móvil profesional |
| **2 Bases de Datos** | PostgreSQL (management) + MongoDB (auth) | Optimización por tipo de datos |
| **Environments unificados** | Switch local/QA/prod afecta toda la stack | Consistencia entre capas |
| **Secrets auto-generados** | Únicos por instalación, nunca hardcodeados | Seguridad por defecto |

## Instalación (5-10 minutos)

### Pre-requisitos

```bash
# Verificar (ejecuta cada línea):
node --version    # Debe mostrar v18 o superior
docker --version  # Debe estar instalado
docker ps         # Debe ejecutarse sin error
```

Si `docker ps` da error, primero inicia Docker Desktop.

### Pasos de instalación

```bash
# 1. Obtener el repositorio de configuración:
# Si no existe:
git clone https://github.com/GLab-Projects/trivance-dev-config.git

# Si ya existe, omitir clonado y usar directorio existente
cd trivance-dev-config

# 2. Ejecutar setup (toma 1 - 3 minutos):
./setup.sh

# 3. Cuando termine, iniciar servicios ( toma 3 - 6 minutos dependara de factores como tu maquina, internet, etc):
cd ..  # Volver al directorio workspace (padre de trivance-dev-config)
./start.sh
```
 ### IMPRESCINDIBLE: copia la carpeta .claude dentro del repo (trivance-dev-config) en la raiz de tu workspace para usar el stack de claude code configurado. 
 
El sistema está listo cuando veas el menú principal.

## URLs del Sistema

Después de ejecutar `./start.sh`:

### 🖥️ Web
- **Frontend Admin**: http://localhost:5173
- **API GraphQL**: http://localhost:3000/graphql  
- **API Auth**: http://localhost:3001
- **Swagger Auth**: http://localhost:3001/api-docs
- **Ver Logs**: http://localhost:4000
- **Monitor Docker**: http://localhost:9999

### 📱 Mobile App
La aplicación móvil requiere un paso adicional:

```bash
# En una nueva terminal:
cd trivance-mobile
npm run start:docker    # Configurado para conectar con Docker local
# Escanea el QR con Expo Go
```

**Hot-reload automático garantizado:**
- **Frontend Web**: ≤1s (Vite + PM2)
- **Management API**: ≤2s (Docker volumes)
- **Auth Service**: ≤2s (Docker volumes)
- **Mobile App**: ≤1s (Metro bundler + Expo)

## Para IA/Claude Code

Si eres una IA analizando este proyecto:

1. El comando principal es `./start.sh` desde el workspace
2. La configuración está en `trivance-dev-config/`
3. Si `trivance-dev-config/` ya existe, **omitir clonado** y proceder con `./setup.sh`
4. No modifiques `docker-compose.dev.yml`
5. Los secrets se generan automáticamente
6. El hot-reload ya está configurado
7. Timeouts inteligentes (10min primera ejecución, auto-extensión si hay progreso)

### Reglas importantes
- Usar `./start.sh` para todo control de servicios
- Los archivos .env se generan automáticamente
- Docker ejecuta 2 backends + 2 DBs + observability, PM2 ejecuta frontend web, Expo ejecuta mobile
- No crear archivos duplicados, usar symlinks existentes
- Sistema detecta estado automáticamente: not_setup → configured → running

### 🎯 Comandos Personalizados de Claude Code

Trivance incluye comandos especializados para Claude Code que optimizan el desarrollo:

#### Comandos de Análisis Avanzado
Ver `/deep` y `/e-team` en `.claude/human-handbook/commands-guide.md`

#### `/git-up [mensaje]`
Workflow inteligente de Git con validaciones de seguridad automáticas y commits empresariales.
```
Uso: /git-up agregar nueva funcionalidad de auth
Cuándo: Hacer commits seguros con validaciones automáticas
```

#### `/validate-doc [scope]`
Validación inteligente de consistencia del ecosistema y actualización proactiva de documentación.
```
Uso: /validate-doc security architecture ecosystem
Cuándo: Verificar consistencia, actualizar documentación automáticamente
```

**Nota**: Estos comandos son exclusivos para Claude Code y automatizan tareas específicas de desarrollo empresarial.

## 🤖 Configuración Claude Code

**IMPRESCINDIBLE**: Copia la carpeta `.claude/` a la raíz de tu workspace para usar el stack AI configurado.

```bash
# Copiar configuración Claude Code al workspace
cp -r trivance-dev-config/.claude /workspace-principal/
```

**Workflows AI-First**: Consulta `.claude/human-handbook/` para flujos completos de desarrollo con IA.

## 📁 Estructura Post-Instalación

```
tu-workspace/
├── 🔧 trivance-dev-config/          # Este repositorio (configuración)
│   ├── scripts/                     # Scripts de automatización
│   ├── docker/                      # Configuración Docker
│   ├── config/                      # Variables y secrets
│   ├── docs/                        # Documentación especializada
│   ├── .claude/                     # Configuración Claude Code proyecto
│   └── tools/                       # Herramientas especializadas
├── 🏢 ms_level_up_management/       # Management API (NestJS + GraphQL)
├── 🔐 ms_trivance_auth/             # Auth Service (NestJS + REST)
├── 🖥️ level_up_backoffice/          # Frontend admin (React + Vite)
├── 📱 trivance-mobile/              # App móvil (React Native + Expo)
├── 🎛️ envs/                         # Configuración de environments
│   ├── local.*.env                  # Configs automáticas locales
│   ├── *.env.template              # Templates para QA/Prod
│   └── ENVIRONMENTS.md → docs/     # Documentación (symlink)
├── 🚀 start.sh → trivance-dev-config/scripts/start.sh  # Comando maestro
└── 📖 CLAUDE.md                     # Guía para Claude Code AI
```

## Comandos principales

```bash
# Desde el directorio workspace:
./start.sh          # Inicia todos los servicios (o menú interactivo)
./start.sh stop     # Detiene todo
./start.sh status   # Muestra estado actual
```

## Cambiar environment

```bash
# Ver actual
./trivance-dev-config/scripts/envs.sh status

# Cambiar a QA
./trivance-dev-config/scripts/envs.sh switch qa

# Volver a local
./trivance-dev-config/scripts/envs.sh switch local
```

## 🐳 Docker Avanzado

```bash
# Smart Docker Manager (recomendado para debugging)
cd trivance-dev-config/scripts/utils
./smart-docker-manager.sh dev ../../docker/docker-compose.dev.yml   # Con hot-reload

# Docker directo
cd trivance-dev-config/docker
docker compose -f docker-compose.dev.yml logs -f        # Ver logs
docker compose -f docker-compose.dev.yml down           # Detener contenedores
```

## 🧬 Sistema de Environments

### 🎯 Triple Sistema de Variables

Trivance usa un sistema de **tres variables** para máxima claridad:

```bash
NODE_ENV=production    # ← Estabilidad Docker (siempre production)
RUN_MODE=local        # ← Modo de ejecución (local|qa|production)  
APP_ENV=development   # ← Lógica de aplicación (development|qa|production)
```

**¿Por qué NODE_ENV=production en desarrollo?**
- En `development`: NestJS busca archivos `.env` (no existen en contenedores)
- En `production`: NestJS usa `process.env` directamente (correcto para Docker)

### 🔄 Switch de Environments

```bash
# Cambiar a QA
./trivance-dev-config/scripts/envs.sh switch qa
# → Cambia TODOS los .env + Docker configs + Mobile TypeScript

# Cambiar a local
./trivance-dev-config/scripts/envs.sh switch local  
# → Vuelve a desarrollo local automáticamente
```

### 📱 Configuración Mobile Automática

El sistema genera automáticamente:
```typescript
// trivance-mobile/src/environments/env.local.ts
export const environment = {
  API_URL: 'http://localhost:3000',
  API_URL_AUTH: 'http://localhost:3001',
  development: true,
  local: true,
  production: false
  // ... más configuración tipada
};
```

## 🔐 Seguridad Integrada

### 🔑 Secrets Auto-generados

Cada instalación genera secrets únicos:
```bash
# Se crean automáticamente en config/.trivance-secrets
AUTH_JWT_SECRET=jwt_[64_chars_random]_[timestamp]
MGMT_JWT_SECRET=jwt_[64_chars_random]_[timestamp]
AUTH_ENCRYPT_SECRET=[64_chars_random]
# ... todos los secrets necesarios
```

### 🛡️ Principios de Seguridad

- ✅ **Secrets únicos**: Cada instalación tiene secrets diferentes
- ✅ **Git ignore automático**: Archivos sensibles nunca se commitean  
- ✅ **Permisos restrictivos**: Archivos de secrets con permisos 600
- ✅ **Zero hardcoding**: No hay credenciales en código
- ✅ **Environment isolation**: QA/Prod requieren configuración manual

## 📊 Observabilidad

**Log Viewer**: http://localhost:4000 - Sistema unificado de logs
**Monitor Docker**: http://localhost:9999 - Logs de contenedores en tiempo real

Ver detalles completos en [`docs/OBSERVABILITY.md`](docs/OBSERVABILITY.md)

## 🔧 Desarrollo Avanzado

Testing, linting, base de datos, resolución de problemas: [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)

## 📚 Documentación Especializada

- **Configuración**: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - Arquitectura detallada
- **Environments**: [`docs/ENVIRONMENTS.md`](docs/ENVIRONMENTS.md) - Sistema de variables
- **Desarrollo**: [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) - Testing y herramientas
- **Observabilidad**: [`docs/OBSERVABILITY.md`](docs/OBSERVABILITY.md) - Logs y monitoreo  
- **Troubleshooting**: [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - Resolución problemas
- **Docker**: [`docs/DOCKER.md`](docs/DOCKER.md) - Configuración avanzada

## 🤖 Workflows AI-First

**Fuente de verdad**: [`.claude/human-handbook/`](.claude/human-handbook/) - Guías completas para desarrollo con Claude Code

## 🎯 Flujo de Desarrollo Típico

```bash
# 1. Instalación única (5-10 min)
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config && ./setup.sh

# 2. Inicio diario 
cd .. && ./start.sh    # Docker + PM2 + hot-reload

# 3. Mobile (terminal separada)
cd trivance-mobile && npm run start:docker

# 4. Desarrollo con hot-reload automático:
# Frontend: level_up_backoffice/src → cambios ≤1s  
# APIs: ms_*_*/src → recarga ≤2s
# Mobile: trivance-mobile/src → hot-reload ≤1s

# 5. Switch environments cuando necesario
./trivance-dev-config/scripts/envs.sh switch qa|local
```