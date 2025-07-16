# 🎛️ Sistema de Environments - Guía Completa

## 🤔 ¿Qué es esto?

El sistema de environments de Trivance te permite cambiar entre diferentes configuraciones (local, QA, producción) con **UN SOLO COMANDO**. Es como tener diferentes "modos" para tu aplicación:

- **🏠 Local**: Tu computadora, para desarrollo
- **🧪 QA**: Servidor de pruebas
- **🚀 Producción**: Servidor real con usuarios

## 🎯 ¿Cómo funciona?

### La magia en 3 pasos:

1. **Configuración centralizada**: Todo está en `trivance-dev-config/config/environments.json`
2. **Generación automática**: El sistema crea archivos `.env` para cada servicio (incluidos Docker)
3. **Un comando para cambiar**: Cambias TODOS los servicios de golpe (Docker + PM2)

### 🐳 Arquitectura Híbrida Docker + PM2:
- **Backends y DBs**: En contenedores Docker (PostgreSQL, MongoDB, APIs NestJS)
- **Frontend**: Con PM2 para hot-reload instantáneo
- **Integración automática**: Los environments manejan ambos sistemas

### Ejemplo visual:
```
Tu comando: ./trivance-dev-config/scripts/envs.sh switch qa

Lo que pasa:
├── ms_trivance_auth/.env           → Cambia a config de QA
├── ms_level_up_management/.env      → Cambia a config de QA  
├── level_up_backoffice/.env         → Cambia a config de QA
├── trivance-mobile/.env             → Cambia a config de QA
├── trivance-mobile/src/environments/env.local.ts → ✨ NUEVO: Generado automáticamente
├── docker/.env.docker-local         → Cambia a config de QA para Docker
└── docker/.env.docker-auth-local    → Cambia a config de QA para Docker

¡TODO sincronizado! 🎉 (Docker + PM2 + TypeScript)
```

## 📋 Guía Rápida - Lo que necesitas saber

### 1️⃣ Ver en qué environment estás
```bash
./trivance-dev-config/scripts/envs.sh status
```

Te dirá algo como:
```
✅ Environment actual: local
📁 Archivos de configuración en: /tu-proyecto/envs
```

### 2️⃣ Cambiar de environment

**Para desarrollo local** (tu computadora):
```bash
./trivance-dev-config/scripts/envs.sh switch local
```

**Para servidor de pruebas** (QA):
```bash
./trivance-dev-config/scripts/envs.sh switch qa
```

**Para producción** (¡CUIDADO! 🚨):
```bash
./trivance-dev-config/scripts/envs.sh switch production
# Te pedirá confirmación porque es PRODUCCIÓN REAL
```

### 3️⃣ Después de cambiar

Reinicia los servicios:
```bash
./start.sh              # Recomendado (symlink del workspace)
# O alternativamente:
./trivance-dev-config/start-all.sh
```

## ⚙️ Sistema de Variables de Entorno - IMPORTANTE

### 🎯 Triple Sistema de Variables en Docker

**¿Por qué NODE_ENV=production en desarrollo local?**

Trivance usa un sistema de **triple variables** para máxima claridad y estabilidad:

```bash
NODE_ENV=production    # Configuración técnica Docker (siempre production)
RUN_MODE=local        # Modo de ejecución (local/qa/production)  
APP_ENV=development   # Lógica de aplicación (development/qa/production)
```

### 📋 Propósito de Cada Variable

| Variable | Propósito | Valores | Uso |
|----------|-----------|---------|-----|
| `NODE_ENV` | Estabilidad de contenedores Docker | `production` | ReadEnvService, optimizaciones Node.js |
| `RUN_MODE` | Scripts NPM y comandos | `local`, `qa`, `production` | `npm run start:${RUN_MODE}` |
| `APP_ENV` | Lógica de aplicación | `development`, `qa`, `production` | Logging, debugging, features |

### 🔧 Razón Técnica

El `ReadEnvService` requiere `NODE_ENV=production` en Docker porque:
- En `development`: busca archivo `.env` (no existe en contenedores)
- En `production`: usa `process.env` directamente (correcto para Docker)

**No es un error**, es un diseño técnico necesario para compatibilidad Docker.

### 💡 Para Desarrolladores

Cuando desarrolles funcionalidades que dependen del entorno:

```typescript
// ❌ NO uses NODE_ENV en Docker
if (process.env.NODE_ENV === 'development') {
  // Nunca se ejecutará en Docker
}

// ✅ USA APP_ENV para lógica de aplicación
if (process.env.APP_ENV === 'development') {
  // Se ejecutará correctamente en desarrollo local
}

// ✅ USA RUN_MODE para scripts específicos
const script = `start:${process.env.RUN_MODE}`;
```

## 🔐 Seguridad - MUY IMPORTANTE

### Para Local (tu computadora)
- ✅ **TODO ES AUTOMÁTICO**: Los secrets se generan solos
- ✅ **Es seguro**: Cada instalación tiene secrets únicos
- ✅ **No necesitas hacer nada**: Just works™

### Para QA/Producción
- ⚠️ **CONFIGURACIÓN MANUAL REQUERIDA**
- 📝 Pasos:
  1. Usa los templates como punto de partida:
     ```bash
     # Para QA
     cp envs/qa.management.env.template envs/qa.management.env
     cp envs/local.auth.env envs/qa.auth.env
     cp envs/local.backoffice.env envs/qa.backoffice.env
     cp envs/local.mobile.env envs/qa.mobile.env
     
     # Para Producción  
     cp envs/production.management.env.template envs/production.management.env
     # (repetir para otros servicios)
     ```
  2. Edita con valores REALES:
     - Reemplaza `$QA_HOST` con URLs reales del servidor
     - Actualiza credenciales de base de datos reales
     - Configura API keys de servicios externos reales
  3. **NUNCA** subas estos archivos a Git

## 📝 Archivos Template vs Archivos Reales

### ¿Cuál es la diferencia?

| Tipo | Propósito | Contenido | Uso |
|------|-----------|-----------|-----|
| `local.*.env` | ✅ Archivos reales | Valores auto-generados listos | Usar directamente |
| `qa.*.env.template` | 📝 Plantillas QA | Variables como `$QA_HOST` | Copiar y editar |
| `production.*.env.template` | 📝 Plantillas Prod | Variables como `$PROD_HOST` | Copiar y editar |
| `qa.*.env` | 🔧 Archivos reales QA | Valores reales de QA | Crear manualmente |
| `production.*.env` | 🔧 Archivos reales Prod | Valores reales de producción | Crear manualmente |

### Ejemplo de contenido:

**Template (qa.management.env.template)**:
```bash
DATABASE_URL=postgresql://user:pass@$QA_HOST:5432/trivance_qa
API_URL=https://$QA_HOST/api
```

**Archivo real (qa.management.env)** - después de editarlo:
```bash
DATABASE_URL=postgresql://user:pass@qa.servidor.com:5432/trivance_qa
API_URL=https://qa.servidor.com/api
```

### ⚠️ Importante:
- Los **templates** contienen variables que NO funcionarán hasta ser reemplazadas
- Los **archivos reales** deben tener valores concretos sin variables
- **NUNCA** comitees archivos `.env` reales a Git

## 🗂️ ¿Dónde están los archivos?

```
tu-proyecto/
├── envs/                          # 📁 Aquí están TODAS las configuraciones
│   ├── local.management.env       # ✅ Config local del backend (auto-generado)
│   ├── local.auth.env            # ✅ Config local de auth (auto-generado)
│   ├── local.backoffice.env      # ✅ Config local del frontend (auto-generado)
│   ├── local.mobile.env          # ✅ Config local de la app (auto-generado)
│   ├── qa.*.env.template         # 📝 Templates de QA (contienen variables como $QA_HOST)
│   ├── production.*.env.template # 📝 Templates de producción (contienen variables)
│   ├── qa.*.env                  # 🔧 Configs reales de QA (crearlas manualmente desde templates)
│   └── production.*.env          # 🔧 Configs reales de producción (crearlas manualmente)
├── trivance-mobile/src/environments/  # 📱 Configuración TypeScript auto-generada
│   └── env.local.ts              # ✨ NUEVO: Generado automáticamente desde .env
└── .trivance-secrets             # 🔐 Secrets autogenerados (NO SUBIR A GIT)
```

## 🛠️ Comandos Completos

### Básicos
```bash
# Ver estado actual
./trivance-dev-config/scripts/envs.sh status

# Cambiar environment
./trivance-dev-config/scripts/envs.sh switch [local|qa|production]

# Ver ayuda
./trivance-dev-config/scripts/envs.sh help
```

### Avanzados
```bash
# Validar que todo esté bien configurado
./trivance-dev-config/scripts/envs.sh validate

# Comparar dos environments
./trivance-dev-config/scripts/envs.sh diff local qa

# Sincronizar con environments.json
./trivance-dev-config/scripts/envs.sh sync
```

## ❓ Preguntas Frecuentes

### "¿Por qué no puedo editar el .env directamente?"
Los `.env` se generan automáticamente desde `environments.json`. Si los editas manualmente, se perderán los cambios al cambiar de environment.

### "¿Cómo agrego una nueva variable?"
1. Agrégala en `trivance-dev-config/config/environments.json`
2. Ejecuta: `./trivance-dev-config/scripts/envs.sh sync`
3. ¡Listo! Ya está en todos los servicios

### "¿Qué pasa si cambio a producción por error?"
- El sistema te pide confirmación (debes escribir "yes")
- Si ya lo hiciste, simplemente cambia de vuelta: `switch local`

### "No encuentro el archivo de QA"
Es normal. Los archivos de QA y producción NO vienen incluidos por seguridad. Debes crearlos copiando los locales y editándolos.

## 🚀 Workflow Típico de Desarrollo

### Mañana - Empezar a trabajar:
```bash
cd ~/tu-proyecto
./start.sh              # Inicia todo en local automáticamente (Docker + PM2)
```

### Necesitas probar en QA:
```bash
./trivance-dev-config/scripts/envs.sh switch qa
./start.sh              # Ahora apunta a servidores QA
```

### Volver a desarrollo local:
```bash
./trivance-dev-config/scripts/envs.sh switch local
./start.sh              # De vuelta a tu máquina
```

## 🆘 Solución de Problemas

### "Me dice que faltan archivos de QA"
```bash
# Crear los archivos QA copiando los locales
cp envs/local.management.env envs/qa.management.env
cp envs/local.auth.env envs/qa.auth.env
cp envs/local.backoffice.env envs/qa.backoffice.env
cp envs/local.mobile.env envs/qa.mobile.env

# Ahora edita cada uno con valores de QA
```

### "Los servicios no se conectan después de cambiar"
```bash
# Asegúrate de reiniciar después de cambiar environment
./start.sh              # El menú te permitirá detener y reiniciar servicios

# O manualmente (2 opciones):
# Opción 1: Desde workspace
docker-compose -f trivance-dev-config/docker/docker-compose.yaml restart
pm2 restart backoffice

# Opción 2: Desde carpeta docker
cd trivance-dev-config/docker && docker-compose restart && cd ../..
pm2 restart backoffice
```

### "No sé en qué environment estoy"
```bash
./trivance-dev-config/scripts/envs.sh status
# O mira el archivo:
cat envs/.current_environment
```

## 🐳 Gestión de Docker con Environments

### ¿Cómo se integra Docker?

Cuando cambias de environment, el sistema también genera archivos `.env` específicos para Docker:

```bash
# Cambiar environment también configura Docker
./trivance-dev-config/scripts/envs.sh switch qa

# Esto genera automáticamente:
# ├── docker/.env.docker-local      # Para Management API
# └── docker/.env.docker-auth-local # Para Auth API
```

### Comandos específicos para Docker:

```bash
# Ver contenedores corriendo
docker ps

# Reiniciar servicios Docker después de cambiar environment (2 opciones):

# Opción 1: Desde el workspace (recomendado)
docker-compose -f trivance-dev-config/docker/docker-compose.yaml down
docker-compose -f trivance-dev-config/docker/docker-compose.yaml up -d

# Opción 2: Desde la carpeta docker (más simple)
cd trivance-dev-config/docker
docker-compose down
docker-compose up -d
cd ../..  # Volver al workspace

# Ver logs de Docker
docker logs trivance_management
docker logs trivance_auth
docker logs -f trivance_postgres  # -f para seguir los logs en tiempo real
```

### Servicios en Docker vs PM2:

| Servicio | Tecnología | Puerto | Comando | Estado Típico |
|----------|------------|---------|----------|---------------|
| PostgreSQL | Docker | 5432 | `docker logs trivance_postgres` | Siempre activo |
| MongoDB | Docker | 27017 | `docker logs trivance_mongodb` | Siempre activo |
| Auth API | Docker | 3001 | `docker logs trivance_auth` | Siempre activo |
| Management API | Docker | 3000 | `docker logs trivance_management` | Siempre activo |
| Frontend | PM2 | 5173 | `pm2 logs backoffice` | Siempre activo |
| Metro Bundler (Mobile) | Expo | 8081 | Solo cuando se inicia la app móvil | Opcional |
| Dozzle (Monitor logs) | Docker | 9999 | Acceder vía http://localhost:9999 | Siempre activo |

## 📚 Para Aprender Más

- **Archivo maestro**: `trivance-dev-config/config/environments.json`
- **Script principal**: `trivance-dev-config/scripts/envs.sh`
- **Documentación técnica**: `trivance-dev-config/README.md`
- **Docker**: `trivance-dev-config/docs/DOCKER.md`

---

## 📱 Configuración Automática de Mobile

### ✨ Nueva funcionalidad: env.local.ts

El sistema ahora genera automáticamente un archivo TypeScript tipado para la aplicación móvil:

```bash
# Al cambiar environment, se genera automáticamente:
./trivance-dev-config/scripts/envs.sh switch local

# ✅ Genera automáticamente:
# - trivance-mobile/.env (variables de entorno)
# - trivance-mobile/src/environments/env.local.ts (configuración TypeScript)
```

### Ejemplo del archivo generado:
```typescript
export const environment = {
  API_URL: 'http://localhost:3000',
  API_URL_AUTH: 'http://localhost:3001',
  TENANT_TRIVANCE: 'U2FsdGVkX1/mRzvnBo5dtb/ArZnjxiU2KdRzHb2s7kw=',
  // Local development configuration
  development: true,
  local: true,
  production: false,
  // Additional local config
  API_TIMEOUT: 30000,
  ENABLE_API_LOGS: true,
  ENABLE_REDUX_LOGS: true,
  SHOW_DEV_BANNER: true,
  ENABLE_CRASHLYTICS: false,
  ENABLE_ANALYTICS: false
};
```

### Beneficios:
- ✅ **Tipado completo**: TypeScript detecta errores en tiempo de compilación
- ✅ **Sincronización automática**: Se actualiza al cambiar environments
- ✅ **Configuración centralizada**: Una sola fuente de verdad
- ✅ **Desarrollo más rápido**: No necesitas crear archivos manualmente

---

💡 **Tip Final**: El 90% del tiempo usarás solo estos comandos:
- `status` - Ver dónde estás
- `switch local` - Volver a desarrollo
- `switch qa` - Ir a pruebas
- `./start.sh` - Iniciar todos los servicios (Docker + PM2)

¡Eso es todo! 🎉