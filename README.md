# 🚀 Trivance Dev Config - La Configuración Definitiva

> **Configuración automática, completa y segura del entorno de desarrollo para la plataforma Trivance.**
> 
> **⚡ IMPORTANTE**: Este es el **ÚNICO** repositorio que necesitas para configurar TODA la plataforma de desarrollo.

## 🎯 ¿Qué es esto y por qué existe?

Trivance Dev Config es la **fuente de verdad única** para la configuración del entorno de desarrollo. Resuelve el problema de configuración manual compleja automatizando **todo** el proceso.

### ❌ Sin este repositorio:
- 4 repositorios para clonar manualmente
- Configuración de 12+ archivos .env diferentes
- Instalación manual de dependencias (15+ minutos)
- Configuración Docker compleja
- Secrets inseguros o hardcodeados
- Incompatibilidades entre servicios

### ✅ Con este repositorio:
- **1 comando**: `./setup.sh` y listo
- **Arquitectura híbrida optimizada**: Docker (backends) + PM2 (frontend)
- **Hot-reload ≤2s garantizado**: Estándar de desarrollo
- **Secrets únicos y seguros**: Generados automáticamente
- **Zero breaking changes**: Actualizaciones sin romper nada

## 🏗️ Arquitectura del Sistema

### 🐳 Arquitectura Híbrida Docker + PM2

```
┌─────────────────────────────────────────────────────────────┐
│                    TRIVANCE PLATFORM                       │
├─────────────────────────────────────────────────────────────┤
│ FRONTEND LAYER (PM2)                                       │
│ ┌─────────────────┐                                        │
│ │ Backoffice      │ ←→ Hot-reload ≤2s (Vite + PM2)        │
│ │ localhost:5173  │                                        │
│ └─────────────────┘                                        │
├─────────────────────────────────────────────────────────────┤
│ BACKEND LAYER (Docker)                                     │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Management API  │ │ Auth Service    │                   │
│ │ localhost:3000  │ │ localhost:3001  │                   │
│ │ (GraphQL)       │ │ (REST)          │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ DATABASE LAYER (Docker)                                    │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ PostgreSQL      │ │ MongoDB         │                   │
│ │ localhost:5432  │ │ localhost:27017 │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ OBSERVABILITY (Docker)                                     │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Log Viewer      │ │ Dozzle          │                   │
│ │ localhost:4000  │ │ localhost:9999  │                   │
│ └─────────────────┘ └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

### 🎯 Decisiones Arquitecturales Clave

| Decisión | Justificación | Beneficio |
|----------|---------------|-----------|
| **Docker para Backends** | Aislamiento, consistencia, reproducibilidad | Zero "works on my machine" |
| **PM2 para Frontend** | Hot-reload instantáneo, desarrollo ágil | Productividad máxima |
| **Secrets auto-generados** | Seguridad por defecto, únicos por instalación | Zero vulnerabilidades por configuración |
| **Environments automáticos** | Switch entre local/QA/prod sin errores | Zero configuración manual |
| **Single Source of Truth** | Un solo lugar para toda la configuración | Zero inconsistencias |

## 🚀 Instalación Express (3 comandos)

### Pre-requisitos OBLIGATORIOS

```bash
# Verificar requisitos (copia y pega)
node --version    # ✅ Debe ser v18+ 
npm --version     # ✅ Debe existir
git --version     # ✅ Debe existir  
docker --version  # ✅ OBLIGATORIO
docker ps         # ✅ Debe funcionar sin errores
```

⚠️ **CRÍTICO**: Si `docker ps` falla, PARA AQUÍ. [Instala Docker Desktop](https://www.docker.com/products/docker-desktop/) y asegúrate de que esté corriendo.

### Instalación Automática

```bash
# 1. Clonar configuración
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config

# 2. Setup completo automático (5-10 minutos)
./setup.sh

# 3. Iniciar todos los servicios
cd .. && ./start.sh
```

**¡Listo!** 🎉 Todo está funcionando.

## 🌐 URLs del Sistema

Una vez iniciado, tienes acceso a:

| Servicio | URL | Estado | Descripción |
|----------|-----|--------|-------------|
| **🖥️ Frontend Admin** | http://localhost:5173 | PM2 | Panel de administración React |
| **🔧 Management API** | http://localhost:3000 | Docker | Backend principal NestJS + GraphQL |
| **🔐 Auth Service** | http://localhost:3001 | Docker | Autenticación y autorización |
| **🎮 GraphQL Playground** | http://localhost:3000/graphql | Docker | Explorador de APIs GraphQL |
| **🔍 Log Viewer** | http://localhost:4000 | Docker | Sistema de observabilidad unificado |
| **📊 Dozzle** | http://localhost:9999 | Docker | Monitor de logs en tiempo real |
| **📱 Mobile (Expo)** | *Dinámico* | Expo | App móvil React Native |

### 🔥 Hot-Reload Garantizado ≤2s

- **Frontend**: Cambios visibles instantáneamente (Vite + PM2)
- **Backend**: Recarga automática en contenedores
- **Mobile**: Metro bundler con recarga rápida
- **Environments**: Switch automático entre local/QA/prod

## 📁 Estructura Post-Instalación

```
tu-workspace/
├── 🔧 trivance-dev-config/          # ← ESTE REPO (configuración)
│   ├── scripts/                     # Scripts de automatización
│   ├── docker/                      # Configuración Docker
│   ├── config/                      # Variables y secrets
│   └── docs/                        # Documentación especializada
├── 🏢 ms_level_up_management/       # Backend principal (NestJS + GraphQL)
├── 🔐 ms_trivance_auth/             # Servicio de autenticación (NestJS)
├── 🖥️ level_up_backoffice/          # Frontend admin (React + Vite)
├── 📱 trivance-mobile/              # App móvil (React Native + Expo)
├── 🎛️ envs/                         # Configuración de environments
│   ├── local.*.env                  # Configs automáticas locales
│   ├── *.env.template              # Templates para QA/Prod
│   └── ENVIRONMENTS.md → docs/     # Documentación (symlink)
├── 🚀 start.sh → trivance-dev-config/scripts/start.sh  # Comando maestro
└── 📖 CLAUDE.md                     # Guía para Claude Code AI
```

## ⚡ Comandos Esenciales

### 🎮 Gestión del Sistema

```bash
# Control maestro del sistema
./start.sh                    # Menú interactivo completo
./start.sh start              # 🚀 Iniciar modo desarrollo (Docker + PM2)
./start.sh stop               # 🛑 Detener todos los servicios  
./start.sh status             # 📊 Ver estado completo del sistema

# Configuración
./start.sh setup              # 🔧 Reconfigurar desde cero
```

### 🎛️ Gestión de Environments

```bash
# Ver environment actual
./trivance-dev-config/scripts/envs.sh status

# Cambiar environment (local ↔ QA ↔ prod)
./trivance-dev-config/scripts/envs.sh switch local
./trivance-dev-config/scripts/envs.sh switch qa
./trivance-dev-config/scripts/envs.sh switch production

# Validar configuración
./trivance-dev-config/scripts/envs.sh validate
```

### 🐳 Docker Management

```bash
# Via Smart Docker Manager (recomendado)
cd trivance-dev-config/scripts/utils
./smart-docker-manager.sh dev docker-compose.dev.yml      # Modo desarrollo con hot-reload
./smart-docker-manager.sh up docker-compose.dev.yml       # Iniciar servicios
./smart-docker-manager.sh down docker-compose.dev.yml     # Detener servicios
./smart-docker-manager.sh logs docker-compose.dev.yml     # Ver logs

# Docker tradicional
cd trivance-dev-config/docker
docker compose up -d          # Iniciar
docker compose down           # Detener
docker compose logs -f        # Logs en tiempo real
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

## 🔧 Desarrollo Avanzado

### 🧪 Testing

```bash
# Backend (NestJS con Jest)
cd ms_level_up_management
npm test                    # Unit tests
npm run test:watch          # Watch mode
npm run test:cov            # Con cobertura
npm run test:e2e           # End-to-end

# Frontend (React con Vitest)  
cd level_up_backoffice
npm test                    # Unit tests

# Mobile (React Native)
cd trivance-mobile
npm test                    # Unit tests
npm run type-check          # TypeScript validation
```

### 🎨 Linting y Formateo

```bash
# Cada repositorio tiene sus comandos
npm run lint               # ESLint
npm run lint:fix          # ESLint con auto-fix
npm run format            # Prettier
npm run type-check        # TypeScript check
```

### 🗄️ Base de Datos (Prisma)

```bash
cd ms_level_up_management
npx prisma migrate dev      # Nueva migración
npx prisma generate         # Regenerar cliente
npx prisma studio          # GUI de base de datos
npx prisma db push         # Sincronizar schema
```

## 📊 Observabilidad

### 🔍 Log Viewer Unificado (Puerto 4000)

Sistema de observabilidad moderno:
```bash
# Acceder al Log Viewer
open http://localhost:4000

# API programática
curl "http://localhost:4000/api/logs/search?level=error&limit=20"
curl "http://localhost:4000/api/logs/search?service=backend"
curl "http://localhost:4000/api/logs/search?text=unauthorized"

# Filtros disponibles:
# - service: frontend, backend, auth
# - level: error, warn, info, debug  
# - traceId: seguimiento de requests
# - sessionId: seguimiento de sesiones
# - text: búsqueda de texto completo
```

### 📊 Dozzle (Puerto 9999)

Monitor visual de logs Docker:
```bash
# Ver logs en tiempo real
open http://localhost:9999

# Características:
# - Logs de todos los contenedores
# - Filtrado en tiempo real
# - Interfaz web moderna
# - Sin instalación adicional
```

## 🚨 Troubleshooting

### ❌ Problemas Comunes

**Error: "Docker no está corriendo"**
```bash
# Solución:
1. Abrir Docker Desktop
2. Esperar a que diga "Running"
3. Ejecutar: docker ps
4. Si funciona, reintentar setup
```

**Error: "Puerto ocupado"**
```bash
# Verificar qué está usando el puerto
lsof -i:3000
lsof -i:3001  
lsof -i:5173

# Liberar puertos Node.js
killall node

# Reiniciar servicios
./start.sh stop && ./start.sh start
```

**Error: "Falló la compilación"**
```bash
# Verificar logs
ls logs/compilation/
cat logs/compilation/[servicio]_build.log

# Limpiar y reinstalar
./trivance-dev-config/scripts/utils/clean-workspace.sh
./trivance-dev-config/setup.sh
```

### 🔄 Comandos de Recuperación

```bash
# Reset completo (cuando todo falla)
./trivance-dev-config/scripts/utils/clean-workspace.sh
./trivance-dev-config/setup.sh

# Reinstalar dependencias
cd [repositorio] && rm -rf node_modules && npm install

# Regenerar secrets
rm trivance-dev-config/config/.trivance-secrets
./trivance-dev-config/scripts/utils/generate-secrets.sh
```

## 📚 Documentación Especializada

Para temas específicos, consulta:

| Tema | Archivo | Descripción |
|------|---------|-------------|
| **🏗️ Arquitectura** | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Decisiones técnicas y patrones |
| **🐳 Docker** | [docs/DOCKER.md](docs/DOCKER.md) | Configuración Docker avanzada |
| **🎛️ Environments** | [docs/ENVIRONMENTS.md](docs/ENVIRONMENTS.md) | Sistema de environments completo |
| **🔄 Workflows** | [docs/WORKFLOWS.md](docs/WORKFLOWS.md) | Flujos de desarrollo típicos |
| **🚨 Troubleshooting** | [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Solución de problemas avanzados |
| **📋 Comandos** | [docs/COMMANDS.md](docs/COMMANDS.md) | Referencia completa de comandos |

## 🤖 Para Claude Code AI

Si eres Claude Code, lee **obligatoriamente**:
1. **[CLAUDE.md del workspace](../CLAUDE.md)** - Comandos operacionales
2. **Este README.md** - Arquitectura y principios  
3. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Decisiones técnicas críticas

### 🛡️ Reglas Críticas para IA

1. **NUNCA recrear soluciones existentes** - Siempre consultar documentación primero
2. **NUNCA modificar docker-compose.dev.yml** - Es la configuración maestra
3. **NUNCA crear archivos duplicados** - Usar symlinks cuando sea necesario
4. **SIEMPRE usar ./start.sh** - Es el comando maestro unificado
5. **SIEMPRE verificar antes de cambiar** - Leer logs y estado antes de actuar

### ⚠️ Anti-Patterns que Prevenir

- ❌ Crear `start-all.sh` o `status.sh` en raíz (eliminados por arquitectura limpia)
- ❌ Duplicar `ENVIRONMENTS.md` (existe symlink a docs/)
- ❌ Hardcodear secrets (usar auto-generación)
- ❌ Modificar archivos de configuración sin entender dependencias
- ❌ Ignorar el sistema de environments (local/QA/prod)

## 🎯 Filosofía del Proyecto

### 🏛️ Principios Arquitecturales

1. **Configuration as Code** - Todo configurado desde este repositorio
2. **Security by Default** - Secrets únicos, configuración segura automática
3. **Developer Happiness** - Hot-reload ≤2s, setup automático, zero fricción
4. **Zero Breaking Changes** - Actualizaciones sin romper flujos existentes
5. **Single Source of Truth** - Un lugar para toda la configuración

### 🎨 Decisiones de Diseño

- **Español en docs**: Equipo hispano-hablante, mayor claridad
- **Emojis para navegación**: Identificación visual rápida
- **Comandos copiables**: Todos los ejemplos son ejecutables
- **Progressive disclosure**: Información básica primero, detalles después
- **Fail-fast philosophy**: Errores claros, soluciones específicas

---

## 🚀 ¿Listo para empezar?

```bash
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config && ./setup.sh
cd .. && ./start.sh
```

**¡3 comandos y tienes todo el entorno de Trivance funcionando!** 🎉

---

*📝 Última actualización: Julio 2025 | 🏗️ Versión: Docker Híbrido v2.0*