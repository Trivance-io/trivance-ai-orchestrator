# TRIVANCE-DEV-CONFIG - Configuration Orchestrator
<!-- repo: trivance-dev-config | role: master_orchestrator | scope: ecosystem -->

## **Seguir SIEMPRE** este principio: **"Todo debe hacerse tan simple como sea posible, pero no más simple"** - Albert Einstein

## no agregar a la documentación, titulos, comentarios, entre otros, frases promocionales, redundantes, **Manten siempre un lenguaje profesional, minimalista y fácil de entender**

## Project Overview - Master Configuration Repository
@./README.md

## Complete Documentation Suite
@./docs/ARCHITECTURE.md
@./docs/COMMANDS.md
@./docs/DEPLOYMENT.md
@./docs/DOCKER.md
@./docs/DOZZLE.md
@./docs/ENVIRONMENTS.md
@./docs/LOG-VIEWER.md
@./docs/ONBOARDING.md
@./docs/TROUBLESHOOTING.md
@./docs/WORKFLOWS.md

## Repository Role & Scope

Este repositorio orquesta el ecosistema completo de Trivance Platform, gestionando:
- 4 repositorios de servicios (2 backends, 1 frontend, 1 mobile)
- Arquitectura híbrida: Docker + PM2 + Expo
- Gestión de environments (local/QA/production)
- Seguridad (secrets auto-generados)
- Workflows de desarrollo con hot-reload ≤2s

## Operaciones Críticas (NUNCA ejecutar sin confirmación explícita del usuario)

- `./scripts/core/orchestrator.sh` - Setup completo del ecosistema
- `./scripts/utils/clean-workspace.sh` - Limpieza completa
- `./scripts/envs.sh switch` - Cambio de environment
- Cualquier script que modifique `./config/*.json`
- Comandos que afecten el estado de múltiples repositorios

## Operaciones Seguras (Se pueden ejecutar libremente)

- `./start.sh` - Menú interactivo y status
- `./start.sh status` - Verificación de estado del sistema
- Scripts en `./scripts/utils/` (excepto clean-workspace.sh)
- Comandos de Docker para status y logs
- Lectura de documentación y configuraciones

## Workflow Estándar

1. **SIEMPRE usar `./start.sh`** como punto de entrada
2. **Verificar estado del sistema** antes de operaciones
3. **Validar documentación** antes de cambios mayores
4. **Probar en environment local** primero
5. **Seguir patrones arquitectónicos** establecidos
6. **Nunca modificar scripts core** sin supervisión

## Arquitectura del Ecosistema

```
┌─────────────────────────────────────────────────────────────┐
│                  TRIVANCE PLATFORM COMPLETA                │
├─────────────────────────────────────────────────────────────┤
│ CLIENT LAYER                                               │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Web Admin       │ │ Mobile App      │                   │
│ │ localhost:5173  │ │ Expo QR Code    │                   │
│ │ (PM2 + Vite)    │ │ (Metro Bundler) │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ BACKEND LAYER (Docker)                                     │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ Management API  │ │ Auth Service    │                   │
│ │ localhost:3000  │ │ localhost:3001  │                   │
│ │ (NestJS+GraphQL)│ │ (NestJS+REST)   │                   │
│ └─────────────────┘ └─────────────────┘                   │
├─────────────────────────────────────────────────────────────┤
│ DATABASE LAYER (Docker)                                    │
│ ┌─────────────────┐ ┌─────────────────┐                   │
│ │ PostgreSQL      │ │ MongoDB         │                   │
│ │ localhost:5432  │ │ localhost:27017 │                   │
└─────────────────────────────────────────────────────────────┘
```

## URLs de Servicios de Desarrollo

| Servicio | URL | Tecnología | Descripción |
|---------|-----|------------|-------------|
| **Frontend Admin** | http://localhost:5173 | PM2 + Vite | Panel administrativo React |
| **Management API** | http://localhost:3000 | Docker | Backend principal NestJS + GraphQL |
| **Auth Service** | http://localhost:3001 | Docker | Autenticación y autorización |
| **GraphQL Playground** | http://localhost:3000/graphql | Docker | Explorador de APIs GraphQL |
| **Log Viewer** | http://localhost:4000 | Docker | Sistema de observabilidad unificado |
| **Dozzle** | http://localhost:9999 | Docker | Monitor de logs Docker en tiempo real |
| **Mobile (Expo)** | *QR Dinámico* | Expo | App móvil React Native |

## Comandos Esenciales

### Comando Principal
```bash
./start.sh                    # Menú interactivo completo
```

### Control de Servicios
```bash
./start.sh start             # Desarrollo estándar con hot-reload
./start.sh status            # Estado completo del sistema  
./start.sh stop              # Detener todos los servicios
./start.sh setup             # Configurar desde cero
```

### Gestión de Environments
```bash
./scripts/envs.sh status                    # Ver environment actual
./scripts/envs.sh switch local             # Cambiar a local
./scripts/envs.sh switch qa                # Cambiar a QA
./scripts/envs.sh switch production        # Cambiar a producción
./scripts/envs.sh validate                 # Validar configuración
```

### Docker Inteligente
```bash
./scripts/utils/smart-docker-manager.sh dev docker/docker-compose.dev.yml
./scripts/utils/smart-docker-manager.sh up docker/docker-compose.dev.yml
./scripts/utils/smart-docker-manager.sh logs docker/docker-compose.dev.yml
```

## Responsabilidades Clave

### Como Repositorio Maestro
1. **Orquestación Multi-Repositorio** - Gestiona 4 repos Git separados como workspace unificado
2. **Gestión de Arquitectura Híbrida** - Coordina Docker + PM2 + Expo
3. **Autoridad de Configuración** - Fuente única de verdad para environments y settings
4. **Centro de Comandos** - Interfaz unificada vía `./start.sh`
5. **Gestor de Seguridad** - Auto-generación y gestión de secrets
6. **Hub de Documentación** - Docs especializadas para arquitectura multi-servicio

### Principios de Seguridad
- **Secrets únicos por instalación** (auto-generados)
- **JWT tokens con refresh mechanism**
- **Validación de inputs en todos los endpoints**
- **CORS configurado apropiadamente**
- **Archivos sensibles en .gitignore**
- **Permisos restrictivos en archivos de configuración**

## Performance Standards

- **Hot-reload**: ≤2s para backends, ≤1s para frontend
- **Build times**: <2min para frontends, <3min para backends  
- **Test execution**: <30s para unit tests
- **Docker startup**: <60s para servicios completos
- **Full ecosystem setup**: 5-10 minutos desde cero