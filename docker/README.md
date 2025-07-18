# 🐳 Docker Configuration - Trivance Platform

## 🎯 Estrategia Docker

### Principios
1. **Docker SOLO donde aporta valor**: Backends y bases de datos
2. **Desarrollo nativo donde es óptimo**: Frontend (hot reload) y Mobile (Expo)
3. **Integración transparente**: Todo funciona con `./start.sh`
4. **Sin complejidad extra**: Detección automática Docker vs PM2

### Arquitectura
```
┌─────────────────────────────────────────────────────┐
│              TRIVANCE-DEV-CONFIG                     │
│                 (Orquestador)                        │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐           ┌────────▼────────┐
│  DOCKER        │           │  PM2/LOCAL       │
├────────────────┤           ├─────────────────┤
│ • PostgreSQL   │           │ • Backoffice    │
│ • MongoDB      │           │ • Mobile App    │
│ • Management   │           │   (con Expo)    │
│ • Auth Service │           │                 │
└────────────────┘           └─────────────────┘
```

## ⚙️ Sistema de Variables de Entorno

### 🎯 Triple Sistema de Variables

**¿Por qué NODE_ENV=production en desarrollo local?**

Para compatibilidad con el `ReadEnvService`, Docker usa un sistema de triple variables:

```bash
NODE_ENV=production    # Técnico: Estabilidad Docker (siempre production)
RUN_MODE=local        # Operacional: Scripts NPM (local/qa/production)
APP_ENV=development   # Funcional: Lógica de aplicación (development/qa/production)
```

### 📋 Archivos de Configuración

| Archivo | NODE_ENV | APP_ENV | RUN_MODE | Propósito |
|---------|----------|---------|----------|-----------|
| `.env` | `production` | `development` | `local` | Variables globales Docker |
| `.env.docker-local` | - | `development` | `local` | Management API |
| `.env.docker-auth-local` | `development` | - | - | Auth Service |

**Nota**: El `NODE_ENV` en `environment:` del docker-compose siempre sobrescribe otros valores.

### 💡 Para Desarrolladores

Si tu código en Docker necesita detectar el entorno:

```typescript
// ❌ NO funcionará en Docker
if (process.env.NODE_ENV === 'development') {
  enableDebugMode();
}

// ✅ SÍ funcionará correctamente
if (process.env.APP_ENV === 'development') {
  enableDebugMode();
}
```

## 🚨 IMPORTANTE: SEGURIDAD DE CREDENCIALES

### ⚠️ NUNCA COMMITEAR ARCHIVOS DE CONFIGURACIÓN CON CREDENCIALES REALES

Este directorio contiene configuraciones Docker que **REQUIEREN MANEJO SEGURO**:

- ✅ **Commitear**: `docker-compose.yaml`, `Dockerfile.*`, `.env.example`
- ❌ **NO COMMITEAR**: `.env.docker-local`, `.env.production`, `.env.staging`

### 🔐 Configuración Segura

1. **Para desarrollo local - Management Service**:
   ```bash
   cp ../templates/env/.env.management.example .env.docker-local
   # Editar .env.docker-local con valores de desarrollo
   ```

2. **Para desarrollo local - Auth Service**:
   ```bash
   cp ../templates/env/.env.auth.example .env.docker-auth-local
   # Editar .env.docker-auth-local con valores de desarrollo
   ```

3. **Para producción**:
   ```bash
   # Management Service
   cp ../templates/env/.env.management.example .env.production
   # Auth Service  
   cp ../templates/env/.env.auth.example .env.auth.production
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

## 🚀 Integración con el Flujo Principal

### Uso Automático
El script `start.sh` detecta automáticamente si Docker está disponible:
- **CON Docker**: Usa Docker para backends y PM2 para frontend
- **SIN Docker**: Usa PM2 para todos los servicios

### Flujo de Trabajo
```bash
# Primera vez
./setup.sh  # Configura TODO automáticamente

# Desarrollo diario
./start.sh  # Detecta y usa Docker si está disponible

# Para Mobile
cd trivance-mobile && EXPO_ENV=local npm start
```

## 🔧 Troubleshooting

### Problema: Application exits immediately
**Solución**: Verificar que `NODE_ENV=production` en `.env.docker-local`

### Problema: GraphQL permission denied
**Solución**: Verificar permisos en Dockerfile (ya resuelto)

### Problema: Firebase initialization failed
**Solución**: Usar credenciales de desarrollo en `.env.docker-local`

### Problema: Puerto ya en uso
```bash
# Ver qué usa el puerto
lsof -i:3000
# Detener servicios Docker
docker-compose down
```

---

⚠️ **RECORDATORIO**: Este archivo de documentación debe mantenerse actualizado con cualquier cambio en la configuración Docker.