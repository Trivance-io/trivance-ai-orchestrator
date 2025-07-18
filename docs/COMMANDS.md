# 🚀 COMANDOS RÁPIDOS TRIVANCE

## ⚡ Comando Principal

```bash
# Comando único - Menú interactivo
./start.sh

# O con argumentos directos:
./start.sh start      # Iniciar servicios
./start.sh stop       # Detener servicios
./start.sh status     # Ver estado
./start.sh setup      # Configurar desde cero
```

## 🐳 Smart Docker Manager

```bash
# Gestión inteligente de Docker con timeouts adaptativos
cd trivance-dev-config/scripts/utils

# Iniciar servicios (timeouts: 600s first_build, 180s startup)
./smart-docker-manager.sh up ../docker/docker-compose.yaml "postgres mongodb ms_level_up_management ms_trivance_auth dozzle log-viewer"

# Health check con reintentos inteligentes
./smart-docker-manager.sh health_check ../docker/docker-compose.yaml

# Restart optimizado (300s rebuild)
./smart-docker-manager.sh restart ../docker/docker-compose.yaml [servicio]

# Logs con filtros
./smart-docker-manager.sh logs ../docker/docker-compose.yaml [servicio]

# Detener servicios (60s quick_ops)
./smart-docker-manager.sh down ../docker/docker-compose.yaml
```

## 🔍 Sistema de Observabilidad

```bash
# Log Viewer unificado - Sistema principal de observabilidad
open http://localhost:4000

# Consultas programáticas por servicio
curl "http://localhost:4000/api/logs/search?service=frontend&level=error" | jq
curl "http://localhost:4000/api/logs/search?service=backend&level=error" | jq
curl "http://localhost:4000/api/logs/search?service=auth&level=error" | jq

# Búsquedas específicas
curl "http://localhost:4000/api/logs/search?sessionId=abc-123" | jq
curl "http://localhost:4000/api/logs/search?traceId=xyz-789" | jq
curl "http://localhost:4000/api/logs/search?text=unauthorized" | jq

# Iniciar Log Viewer independiente
./trivance-dev-config/scripts/utils/start-log-viewer.sh
```

## 📊 Dozzle - Monitor Visual Docker

```bash
# Monitor visual de logs Docker en tiempo real
open http://localhost:9999

# Gestión con script dedicado
./trivance-dev-config/scripts/utils/dozzle.sh start
./trivance-dev-config/scripts/utils/dozzle.sh status
./trivance-dev-config/scripts/utils/dozzle.sh open
```

## 📁 Comandos Originales (Rutas Completas)

```bash
# Verificación de sistema integrada en ./start.sh (opción 5)

# Gestión de Environments
./trivance-dev-config/scripts/envs.sh setup
./trivance-dev-config/scripts/envs.sh switch [local|qa|production]
./trivance-dev-config/scripts/envs.sh status

# Limpieza del workspace
./trivance-dev-config/scripts/utils/clean-workspace.sh

# Verificar compilación
./trivance-dev-config/scripts/utils/verify-compilation.sh
```

## 📊 Monitor de Logs Docker

```bash
# Gestión de Dozzle (Monitor de logs)
./trivance-dev-config/scripts/docker/dozzle.sh start     # Iniciar monitor
./trivance-dev-config/scripts/docker/dozzle.sh status    # Ver estado
./trivance-dev-config/scripts/docker/dozzle.sh open      # Abrir en navegador
./trivance-dev-config/scripts/docker/dozzle.sh logs      # Ver logs de Dozzle
./trivance-dev-config/scripts/docker/dozzle.sh stop      # Detener monitor

# Instalación manual (si no está incluido)
./trivance-dev-config/scripts/docker/install-dozzle.sh
```

## 🔧 Comandos por Servicio

### Backend Management API
```bash
cd ms_level_up_management
npm run start:dev      # Desarrollo con hot-reload
npm run build          # Compilar para producción
npm run test           # Ejecutar tests
npm run lint           # Verificar código
```

### Auth Service
```bash
cd ms_trivance_auth
npm run start:dev      # Desarrollo con hot-reload
npm run build          # Compilar para producción
npm run test           # Ejecutar tests
```

### Frontend Admin
```bash
cd level_up_backoffice
npm run dev            # Desarrollo con Vite
npm run build          # Build para producción
npm run preview        # Preview del build
npm run lint           # Verificar código
```

### Mobile App
```bash
cd trivance-mobile
npm start              # Iniciar Expo
npm run android        # Ejecutar en Android
npm run ios            # Ejecutar en iOS
npm run build          # Build con EAS
```

## 🌐 URLs de Desarrollo

- **Management API**: http://localhost:3000
- **GraphQL Playground**: http://localhost:3000/graphql
- **Auth Service**: http://localhost:3001
- **Auth Swagger**: http://localhost:3001/api-docs
- **Frontend Admin**: http://localhost:5173
- **Mobile Metro**: http://localhost:8081

## 💡 Tips

- Usa `./check-health.sh fix` para resolver problemas automáticamente
- Cambia environments con `./change-env.sh switch [env]` antes de iniciar
- Los logs se guardan en `./logs/` para debugging
- Ejecuta `./setup.sh` si necesitas reconfigurar todo desde cero
