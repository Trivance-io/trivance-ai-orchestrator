# 🐳 Docker Configuration - Trivance Platform

## 🚨 IMPORTANTE: SEGURIDAD DE CREDENCIALES

### ⚠️ NUNCA COMMITEAR ARCHIVOS DE CONFIGURACIÓN CON CREDENCIALES REALES

Este directorio contiene configuraciones Docker que **REQUIEREN MANEJO SEGURO**:

- ✅ **Commitear**: `docker-compose.yaml`, `Dockerfile.*`, `.env.example`
- ❌ **NO COMMITEAR**: `.env.docker-local`, `.env.production`, `.env.staging`

### 🔐 Configuración Segura

1. **Para desarrollo local - Management Service**:
   ```bash
   cp .env.management.example .env.docker-local
   # Editar .env.docker-local con valores de desarrollo
   ```

2. **Para desarrollo local - Auth Service**:
   ```bash
   cp .env.auth.example .env.docker-auth-local
   # Editar .env.docker-auth-local con valores de desarrollo
   ```

3. **Para producción**:
   ```bash
   # Management Service
   cp .env.management.example .env.production
   # Auth Service  
   cp .env.auth.example .env.auth.production
   # Configurar valores reales de producción
   # USAR SECRETOS SEGUROS (Azure Key Vault, AWS Secrets Manager, etc.)
   ```

### 🛡️ Principios de Seguridad

1. **Separación de entornos**: Cada entorno tiene su propio archivo `.env`
2. **Secretos únicos**: Nunca reutilizar credenciales entre entornos
3. **Rotación regular**: Cambiar secretos periódicamente
4. **Principio de menor privilegio**: Solo permisos necesarios
5. **Monitoreo**: Logs de acceso y uso de credenciales

### 🚀 Comandos Docker

```bash
# Desarrollo local
docker-compose --env-file .env.docker-local up -d

# Producción (usar secretos seguros)
docker-compose --env-file .env.production up -d

# Construcción
docker-compose build --no-cache

# Logs
docker-compose logs -f ms_level_up_management
```

### 🔍 Verificación de Seguridad

Antes de cada commit, verificar:
```bash
# Verificar que no hay credenciales reales
git status
git diff --cached

# Verificar archivos .env no están staged
git ls-files --cached | grep -E '\.env\.(docker-local|production|staging)'
```

## 📋 Arquitectura Docker

- **ms_level_up_management**: Backend Principal (NestJS + GraphQL + PostgreSQL)
- **ms_trivance_auth**: Servicio de Autenticación (NestJS + MongoDB)
- **postgres**: Base de datos PostgreSQL (para management)
- **mongodb**: Base de datos MongoDB (para auth)
- **Red**: `trivance_network` para comunicación inter-servicios

## 🌐 Servicios Disponibles

- **Management API**: http://localhost:3000
- **GraphQL Playground**: http://localhost:3000/graphql
- **Auth Service**: http://localhost:3001
- **PostgreSQL**: localhost:5432
- **MongoDB**: localhost:27017

## 🔧 Troubleshooting

### Problema: Application exits immediately
**Solución**: Verificar que `NODE_ENV=production` en `.env.docker-local`

### Problema: GraphQL permission denied
**Solución**: Verificar permisos en Dockerfile (ya resuelto)

### Problema: Firebase initialization failed
**Solución**: Usar credenciales de desarrollo en `.env.docker-local`

---

⚠️ **RECORDATORIO**: Este archivo de documentación debe mantenerse actualizado con cualquier cambio en la configuración Docker.