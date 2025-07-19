# 🔍 Sistema de Observabilidad - Log Viewer

Sistema unificado de logging para desarrollo AI-first que permite debuggear la aplicación completa sin acceso al navegador.

## 🎯 Introducción

El Log Viewer es un componente esencial del stack de desarrollo que proporciona:
- **Logging centralizado**: Todos los logs en un solo lugar
- **Búsqueda avanzada**: Por servicio, nivel, trace ID, session ID
- **Interfaz web**: Accesible en http://localhost:4000
- **Integración completa**: Parte del modo estándar docker-dev

## 🐳 Integración con Docker Development Mode

El Log Viewer está completamente integrado con el modo estándar de desarrollo:
- Se inicia automáticamente con `./start.sh start`
- Contenedor: `trivance_log_viewer_dev` (puerto 4000)
- Hot-reload de logs en tiempo real
- Parte integral del stack de observabilidad

## 🏗️ Arquitectura

```
Frontend (React) → Backend (NestJS) → Archivo JSON → Log Viewer
     ↓                    ↓                              ↑
  Interceptors      Interceptors                   Búsqueda/Filtros
```

### Componentes del Sistema

#### 1. Frontend Logger (`level_up_backoffice/src/utils/logger.ts`)
- Captura automática de console.*, errores, y requests
- Correlación con Session ID y Trace ID
- Buffer con deduplicación para prevenir spam
- Truncado automático de payloads grandes

#### 2. Backend Logger (`ms_level_up_management/src/logging/`)
- `UnifiedLoggerService`: Servicio central de logging con Winston
- `LoggingInterceptor`: Intercepta todas las requests HTTP
- `LoggingController`: Recibe logs del frontend
- Sanitización automática de campos sensibles

#### 3. Auth Service Logger (`ms_trivance_auth/src/common/interceptors/`)
- `LoggingInterceptor`: Envía logs al Management API
- Usa network alias para conectividad: `trivance_management`

#### 4. Log Viewer Service
- Interfaz web en puerto 4000
- API REST para consultas
- Auto-refresh cada 10 segundos
- Filtros y búsqueda avanzada

## 🚀 Uso

### Acceso Web
```bash
# Abrir interfaz web
open http://localhost:4000

# O usando el script dedicado
./trivance-dev-config/scripts/utils/start-log-viewer.sh open
```

### API REST

#### Endpoints Disponibles
- `GET /api/logs/search` - Búsqueda con filtros
- `GET /api/logs/latest` - Últimos logs
- `GET /health` - Health check

#### Parámetros de Búsqueda
- `service`: frontend, backend, auth
- `level`: error, warn, info, debug
- `traceId`: ID único de request
- `sessionId`: ID de sesión del usuario
- `text`: Búsqueda de texto completo
- `from`/`to`: Rango de fechas
- `limit`: Número máximo de resultados

### Ejemplos de Consultas

```bash
# Ver errores recientes
curl "http://localhost:4000/api/logs/search?level=error&limit=20" | jq

# Seguir una sesión específica
curl "http://localhost:4000/api/logs/search?sessionId=abc-123" | jq

# Buscar por trace ID
curl "http://localhost:4000/api/logs/search?traceId=xyz-789" | jq

# Buscar texto
curl "http://localhost:4000/api/logs/search?text=unauthorized" | jq

# Filtrar por servicio
curl "http://localhost:4000/api/logs/search?service=auth&level=error" | jq
```

## ⚙️ Configuración

### Frontend
El logger se inicializa automáticamente en `main.tsx`:
```typescript
const logger = FrontendLogger.getInstance({
  endpoint: '/api/logs/batch',
  bufferSize: 20,
  flushInterval: 5000
});
```

### Backend
Configurado globalmente en `LoggingModule` con interceptor automático.

### Docker
El viewer corre en contenedor separado con acceso read-only a logs:
```yaml
log-viewer:
  build:
    context: ../../trivance-dev-config/tools/log-viewer
  container_name: trivance_log_viewer_dev
  ports:
    - "4000:4000"
  volumes:
    - ../../logs:/logs:ro
```

## 📝 Gestión con Scripts

### Script Dedicado
```bash
# Ubicación
./trivance-dev-config/scripts/utils/start-log-viewer.sh

# Comandos disponibles
./start-log-viewer.sh start    # Iniciar servicio
./start-log-viewer.sh stop     # Detener servicio
./start-log-viewer.sh restart  # Reiniciar servicio
./start-log-viewer.sh status   # Ver estado
./start-log-viewer.sh logs     # Ver logs del contenedor
./start-log-viewer.sh open     # Abrir en navegador
```

### Integración con Start.sh
El Log Viewer se inicia automáticamente al usar:
```bash
./start.sh start  # Incluye Log Viewer en el stack
```

## 🛠️ Mantenimiento

### Limpiar Logs
```bash
docker exec trivance_mgmt_dev sh -c "echo '' > /logs/trivance-unified.json"
```

### Ver Tamaño de Logs
```bash
docker exec trivance_mgmt_dev ls -lh /logs/
```

### Rotación de Logs
Los logs rotan automáticamente:
- Tamaño máximo: 100MB por archivo
- Archivos mantenidos: 5
- Rotación: Automática por Winston

## 🎯 Buenas Prácticas

1. **No loguear información sensible** 
   - El sistema sanitiza automáticamente: password, token, key, secret
   - Revisar antes de loguear datos sensibles

2. **Usar trace IDs** 
   - Permite correlacionar requests entre frontend y backend
   - Se propaga automáticamente en headers

3. **Logs estructurados** 
   - Usar objetos JSON para mejor búsqueda
   - Incluir contexto relevante

4. **Niveles apropiados**
   - `error`: Errores que requieren atención
   - `warn`: Advertencias importantes
   - `info`: Flujo normal de la aplicación
   - `debug`: Información detallada para debugging

## 🔧 Troubleshooting

### No aparecen logs del backend
```bash
# Verificar que el servicio esté corriendo
docker ps | grep trivance_mgmt_dev

# Ver logs de Docker
docker logs trivance_mgmt_dev

# Verificar que el archivo de logs existe
docker exec trivance_mgmt_dev ls -la /logs/
```

### Frontend no envía logs
```bash
# Verificar en consola del navegador
# Buscar errores relacionados con el logger

# Verificar endpoint
curl -X POST http://localhost:3000/api/logs/batch \
  -H "Content-Type: application/json" \
  -d '{"logs":[]}'
```

### Log viewer no funciona
```bash
# Verificar puerto libre
lsof -i :4000

# Ver logs del contenedor
docker logs trivance_log_viewer_dev

# Verificar health
curl http://localhost:4000/health
```

### Error de conectividad Auth → Management
Si ves errores como "fetch failed" en Auth Service:
```bash
# Verificar network alias
docker exec trivance_auth_dev ping trivance_management

# Debe responder correctamente gracias al alias configurado
```

## 🔗 Archivos Relacionados

- **Implementación**: `tools/log-viewer/`
- **Frontend Logger**: `level_up_backoffice/src/utils/logger.ts`
- **Backend Service**: `ms_level_up_management/src/logging/`
- **Auth Interceptor**: `ms_trivance_auth/src/common/interceptors/logging.interceptor.ts`
- **Docker Config**: `docker/docker-compose.dev.yml`

## 📊 Métricas y Performance

- **Latencia de logs**: <100ms desde generación hasta visualización
- **Capacidad**: ~10,000 logs/minuto sin impacto
- **Retención**: 5 archivos de 100MB cada uno
- **Memoria**: ~50MB para el servicio viewer

---

**Comando estándar**: `./start.sh start` incluye Log Viewer automáticamente
**URL**: http://localhost:4000
**Container**: `trivance_log_viewer_dev`