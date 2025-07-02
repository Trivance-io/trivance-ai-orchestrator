# 🔧 Comandos Personalizados de Claude Code para Trivance

## 🚀 Comandos de Inicio Rápido

### Iniciar Todos los Servicios
```bash
# Backend services
cd ms_trivance_auth && npm run start:dev &
cd ms_level_up_management && npm run start:dev &

# Frontend
cd level_up_backoffice && npm run dev &

# Mobile (opcional)
cd trivance-mobile && EXPO_ENV=qa npm start
```

### Setup Completo desde Cero
```bash
# Para cada repo ejecutar:
npm install
cp .env.example .env
npm run build
npm run lint
```

## 🧪 Comandos de Testing

### Test Completo de Todo el Workspace
```bash
# Backend tests
cd ms_trivance_auth && npm run test
cd ms_level_up_management && npm run test

# Frontend tests  
cd level_up_backoffice && npm run test

# Mobile tests
cd trivance-mobile && npm test
```

### Test con Cobertura
```bash
# Solo en backends NestJS
cd ms_level_up_management && npm run test:cov
cd ms_trivance_auth && npm run test:cov
```

## 🔍 Comandos de Linting y Formato

### Lint de Todo el Workspace
```bash
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  echo "Linting $dir..."
  cd $dir && npm run lint
  cd ..
done
```

### Fix de Linting Automático
```bash
# Para repos que soportan --fix
cd ms_level_up_management && npm run lint
cd ms_trivance_auth && npm run lint
cd level_up_backoffice && npm run lint
cd trivance-mobile && npm run lint:fix
```

## 📦 Comandos de Build

### Build de Producción de Todo
```bash
# Backend builds
cd ms_trivance_auth && npm run build
cd ms_level_up_management && npm run build

# Frontend build
cd level_up_backoffice && npm run build

# Mobile builds (seleccionar environment)
cd trivance-mobile && npm run build:qa
# cd trivance-mobile && npm run build:prod
```

## 🗄️ Comandos de Base de Datos

### MongoDB (ms_level_up_management)
```bash
# Ver logs de conexión
cd ms_level_up_management && npm run start:dev | grep -i mongo

# Ejecutar migraciones de Prisma
cd ms_level_up_management && npx prisma migrate dev

# Ver schema de Prisma
cd ms_level_up_management && npx prisma studio
```

## 🔐 Comandos de Debugging

### Ver Logs en Tiempo Real
```bash
# Auth service logs
cd ms_trivance_auth && npm run start:dev | grep -E "(ERROR|WARN|INFO)"

# Management service logs  
cd ms_level_up_management && npm run start:dev | grep -E "(ERROR|WARN|INFO)"
```

### Debug de GraphQL
```bash
# Abrir GraphQL Playground
open http://localhost:3000/graphql

# Verificar schema GraphQL
cd ms_level_up_management && npm run build && cat src/schema.gql
```

## 📱 Comandos Específicos de Mobile

### Desarrollo Mobile
```bash
cd trivance-mobile

# Para desarrollo local (backend local)
EXPO_ENV=local npm start

# Para testing con QA (recomendado)
EXPO_ENV=qa npm start

# Para verificación final
EXPO_ENV=production npm start

# Limpiar cache de Metro
npm run clean

# Prebuild para desarrollo nativo
npm run prebuild
```

### Build y Deploy Mobile
```bash
cd trivance-mobile

# Build para QA/TestFlight
npm run build:qa

# Build para producción
npm run build:prod

# Submit a stores (QA)
npm run submit:qa

# Submit a stores (producción)
npm run submit:prod
```

## 🌍 Verificación de Environments

### Check de Servicios Locales
```bash
# Verificar que todos los servicios estén corriendo
curl http://localhost:3001/health  # Auth service
curl http://localhost:3000/health  # Management service
curl http://localhost:5173         # Frontend

# Ver GraphQL Playground
open http://localhost:3000/graphql

# Ver Swagger de Auth
open http://localhost:3001/api-docs
```

### Check de Servicios QA
```bash
# Verificar servicios QA
curl https://authqa.trivance.com/health
curl https://apiqa.trivance.com/health
open https://staging-admin.trivance.com
```

## 🚨 Comandos de Emergencia

### Limpieza Completa
```bash
# Limpiar todos los node_modules
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  echo "Cleaning $dir..."
  cd $dir && rm -rf node_modules package-lock.json
  cd ..
done

# Reinstalar todo
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  echo "Installing $dir..."
  cd $dir && npm install
  cd ..
done
```

### Reset de Desarrollo
```bash
# Matar todos los procesos Node
pkill -f node

# Limpiar puertos (macOS)
lsof -ti:3000,3001,5173 | xargs kill -9

# Reiniciar servicios
npm run start:dev
```

## 📊 Comandos de Monitoreo

### Ver Uso de Puertos
```bash
# Ver qué está corriendo en puertos de desarrollo
lsof -i :3000  # Management API
lsof -i :3001  # Auth API  
lsof -i :5173  # Frontend dev server
lsof -i :19000 # Expo dev server
lsof -i :19001 # Expo metro bundler
```

### Monitoreo de Memoria y CPU
```bash
# Ver procesos Node activos
ps aux | grep node

# Top de procesos por memoria
top -o %MEM | head -20
```

## 🔄 Comandos de Git Workflow

### Branch de Feature
```bash
# Crear nueva feature
git checkout -b feat/nueva-funcionalidad

# Cambios en múltiples repos
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  cd $dir
  git add .
  git commit -m "feat: descripción de la funcionalidad"
  cd ..
done
```

### Sync de Todos los Repos
```bash
# Pull de todos los repos
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  cd $dir
  git pull origin develop
  cd ..
done
```

## ⚙️ Comandos de Configuración

### Verificar Configuración de TypeScript
```bash
# Check configs de TS en todos los projects
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  echo "TypeScript config en $dir:"
  cd $dir && npx tsc --noEmit
  cd ..
done
```

### Actualizar Dependencies
```bash
# Check de outdated packages
for dir in level_up_backoffice ms_level_up_management ms_trivance_auth trivance-mobile; do
  echo "Outdated packages en $dir:"
  cd $dir && npm outdated
  cd ..
done
```

---

**Nota**: Estos comandos están optimizados para el workspace de Trivance. Ajustar rutas según sea necesario.