# 🐳 Docker Integration - Trivance Platform

## 📋 Tabla de Contenidos

- [Introducción](#introducción)
- [Arquitectura Docker](#arquitectura-docker)
- [Configuración Automática](#configuración-automática)
- [Comandos Principales](#comandos-principales)
- [Gestión de Environments](#gestión-de-environments)
- [Troubleshooting](#troubleshooting)
- [Mejores Prácticas](#mejores-prácticas)

## 🎯 Introducción

Trivance Platform utiliza una **arquitectura híbrida** que combina Docker y PM2:

- **Docker (OBLIGATORIO)**: Para backends y bases de datos
- **PM2**: Para el frontend con hot-reload nativo

### ¿Por qué arquitectura híbrida?

1. **Backends en Docker**: Entorno consistente, aislamiento completo
2. **Frontend en PM2**: Hot-reload instantáneo para desarrollo ágil
3. **Integración automática**: Todo se configura solo con `envs.sh`

## 🏗️ Arquitectura Docker

### Servicios Dockerizados

```yaml
# docker-compose.yaml
services:
  # Bases de datos
  postgres:         # Puerto 5432 - Base de datos principal
  mongodb:          # Puerto 27017 - Base de datos de autenticación
  
  # Backends
  ms_level_up_management:  # Puerto 3000 - API principal + GraphQL
  ms_trivance_auth:        # Puerto 3001 - Servicio de autenticación
```

### Frontend (PM2)

```javascript
// ecosystem.config.js
apps: [{
  name: 'backoffice',
  script: 'npm run dev',  // Puerto 5173 - Hot reload nativo
}]
```

## ⚙️ Sistema de Variables de Entorno

### 🎯 Triple Sistema de Variables

**Trivance usa un sistema único de triple variables** para compatibilidad Docker y claridad semántica:

```bash
NODE_ENV=production    # Técnico: Estabilidad Docker
RUN_MODE=local        # Operacional: Scripts NPM  
APP_ENV=development   # Funcional: Lógica de aplicación
```

### 📋 Configuración por Environment

| Environment | NODE_ENV | RUN_MODE | APP_ENV | Docker Command |
|-------------|----------|----------|---------|----------------|
| **Local** | `production` | `local` | `development` | `npm run start:local` |
| **QA** | `production` | `qa` | `qa` | `npm run start:qa` |
| **Production** | `production` | `production` | `production` | `npm run start:production` |

### 🔧 ¿Por qué NODE_ENV=production en desarrollo?

**Razón técnica**: El `ReadEnvService` en los backends:
- En `development`: busca archivo `.env` (❌ no existe en contenedores)
- En `production`: usa `process.env` directamente (✅ correcto para Docker)

**Solución**: Docker siempre usa `NODE_ENV=production`, pero `APP_ENV` controla la lógica de aplicación.

### 💡 Guía para Desarrolladores

```typescript
// ❌ INCORRECTO en código que corre en Docker
if (process.env.NODE_ENV === 'development') {
  console.log('Debug info'); // Nunca se ejecutará
}

// ✅ CORRECTO usar APP_ENV para lógica de aplicación
if (process.env.APP_ENV === 'development') {
  console.log('Debug info'); // Se ejecutará en desarrollo local
}

// ✅ CORRECTO usar RUN_MODE para comandos específicos
const command = `start:${process.env.RUN_MODE}`; // start:local
```

## 🚀 Flujo de Inicio

### Requisitos

Docker es **OBLIGATORIO**. El sistema verificará:

```bash
# Al ejecutar ./start.sh
✅ Docker OK
# o
❌ Docker NO disponible - No puedes continuar
```

### Proceso de Inicio

1. **Verifica Docker**: Si no está corriendo, no permite continuar
2. **Genera .env Docker**: `envs.sh` crea automáticamente los archivos adaptados
3. **Inicia backends**: PostgreSQL, MongoDB, APIs en contenedores
4. **Inicia frontend**: PM2 para hot-reload óptimo
5. **Health checks**: Verifica que todos los servicios respondan

## ⚙️ Configuración Automática

### Variables de Entorno

El comando `envs.sh switch` genera automáticamente los archivos Docker:

```bash
# Archivos originales en /envs/
local.management.env → .env.docker-local
local.auth.env → .env.docker-auth-local

# Adaptaciones automáticas:
localhost:5432 → postgres:5432
localhost:27017 → mongodb:27017
```

### Archivos de Configuración

```
trivance-dev-config/docker/
├── docker-compose.yaml          # Orquestación de servicios
├── Dockerfile.ms_level_up_management
├── Dockerfile.ms_trivance_auth
├── .env.docker-local           # Generado por envs.sh
├── .env.docker-auth-local      # Generado por envs.sh
└── Makefile                    # Comandos Docker simplificados
```

## 📝 Comandos Principales

### Usando ./start.sh (Recomendado)

```bash
# Menú interactivo principal
./start.sh

# Comandos directos
./start.sh start    # Inicia servicios (detecta Docker automáticamente)
./start.sh stop     # Detiene todos los servicios
./start.sh status   # Muestra estado de servicios
```

### Gestión Docker (desde el menú)

Opción 6 en el menú principal cuando Docker está disponible:

1. **Ver logs de contenedores**
   - Management API
   - Auth Service
   - PostgreSQL
   - MongoDB
   - Todos

2. **Reconstruir imágenes**
   - Útil después de cambios en dependencias

3. **Resetear bases de datos**
   - ⚠️ DESTRUCTIVO - Elimina todos los datos

4. **Acceder a shell de contenedor**
   - Debugging directo en contenedores

5. **Ver uso de recursos**
   - Monitoreo en tiempo real con `docker stats`

### Usando Makefile (Avanzado)

```bash
cd trivance-dev-config/docker

# Comandos básicos
make up          # Iniciar servicios
make down        # Detener servicios
make logs        # Ver logs
make status      # Estado de contenedores

# Comandos específicos
make logs-management  # Logs de Management API
make logs-auth       # Logs de Auth Service
make shell-management # Shell en Management API
make shell-auth      # Shell en Auth Service

# Mantenimiento
make rebuild     # Reconstruir imágenes
make clean       # Limpiar todo (volumes incluidos)
make db-reset    # Resetear bases de datos
```

## 🔄 Gestión de Environments

### Cambio de Environment

El sistema mantiene sincronizados los environments entre Docker y PM2:

```bash
# Desde el menú principal
3) 🔄 Cambiar environment

# Los archivos .env de Docker se regeneran automáticamente
```

### Archivos de Environment Docker

```bash
# Local (desarrollo)
.env.docker-local       # Management API
.env.docker-auth-local  # Auth Service

# QA (próximamente)
.env.docker-qa
.env.docker-auth-qa
```

## 🔧 Troubleshooting

### Docker no inicia

```bash
# Verificar Docker daemon
docker ps

# Si falla, iniciar Docker Desktop o:
sudo systemctl start docker  # Linux
```

### Servicios no responden

```bash
# Ver logs específicos
docker logs trivance_management --tail 50
docker logs trivance_auth --tail 50

# Verificar health checks
./start.sh status
```

### Problemas de conexión

```bash
# Verificar red Docker
docker network ls
docker network inspect trivance-dev-config_trivance_network

# Recrear red si es necesario
cd trivance-dev-config/docker
docker compose down
docker compose up -d
```

### Errores de compilación

```bash
# Limpiar y reconstruir
cd trivance-dev-config/docker
make clean
make rebuild
```

### Puerto en uso

```bash
# Verificar puertos
lsof -i :3000  # Management API
lsof -i :3001  # Auth Service
lsof -i :5432  # PostgreSQL
lsof -i :27017 # MongoDB

# Detener proceso conflictivo o cambiar puertos en docker-compose.yaml
```

## 🎯 Mejores Prácticas

### Desarrollo Local

1. **Usa el modo híbrido**: Mejor experiencia de desarrollo
2. **No modifiques .env de Docker manualmente**: Se regeneran automáticamente
3. **Commits**: Nunca incluyas archivos .env en git

### Debugging

1. **Logs en tiempo real**: `make logs` o desde el menú Docker
2. **Shell interactivo**: Útil para debugging directo
3. **Health checks**: Siempre verifica antes de desarrollar

### Performance

1. **Recursos Docker**: Asigna suficiente memoria en Docker Desktop
2. **Limpieza regular**: `docker system prune` para liberar espacio
3. **Volumes**: Persisten datos entre reinicios

### Migración PM2 → Docker

El sistema maneja esto automáticamente:

1. Detecta servicios PM2 corriendo
2. Los detiene si es necesario
3. Inicia versiones Docker
4. Mantiene frontend en PM2 para hot-reload

## 🚨 Comandos de Emergencia

```bash
# Detener TODO inmediatamente
docker compose down && pm2 stop all

# Limpiar TODO y empezar de cero
cd trivance-dev-config/docker
docker compose down -v --rmi all
cd ../..
pm2 delete all
./start.sh setup

# Ver qué está usando recursos
docker ps -a
pm2 list
```

## 📊 Monitoreo

### Estado de Servicios

```bash
# Vista completa del sistema
./start.sh
# Opción 5: Ver salud del sistema

# Endpoints verificados:
# ✅ Auth Service (3001)
# ✅ Management API (3000)
# ✅ GraphQL Playground
# ✅ Frontend (5173)
```

### Logs Centralizados

```bash
# Ver todos los logs Docker
cd trivance-dev-config/docker
docker compose logs -f --tail=100

# Logs PM2
pm2 logs
```

## 🔐 Seguridad

1. **Secrets**: Generados automáticamente, nunca hardcodeados
2. **Networks**: Red aislada `trivance_network` para comunicación interna
3. **Volumes**: Datos persistentes solo en volumes Docker
4. **Puertos**: Solo expuestos los necesarios para desarrollo

---

## 📚 Referencias

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [PM2 Documentation](https://pm2.keymetrics.io/)
- [Trivance Platform README](../../README.md)
- [Environment Management](./ENVIRONMENTS.md)

---

**Última actualización**: Configuración automática desde trivance-dev-config
**Modo recomendado**: Híbrido (Docker + PM2)
**Soporte**: Slack #dev-support