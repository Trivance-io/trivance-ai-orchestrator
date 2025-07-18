# Sistema de Observabilidad Trivance

Sistema unificado de logging para desarrollo AI-first que permite debuggear la aplicación completa sin acceso al navegador.

## Arquitectura

```
Frontend (React) → Backend (NestJS) → Archivo JSON → Log Viewer
     ↓                    ↓                              ↑
  Interceptors      Interceptors                   Búsqueda/Filtros
```

## Componentes

### 1. Frontend Logger (`level_up_backoffice/src/utils/logger.ts`)
- Captura automática de console.*, errores, y requests
- Correlación con Session ID y Trace ID
- Buffer con deduplicación para prevenir spam
- Truncado automático de payloads grandes

### 2. Backend Logger (`ms_level_up_management/src/logging/`)
- `UnifiedLoggerService`: Servicio central de logging con Winston
- `LoggingInterceptor`: Intercepta todas las requests HTTP
- `LoggingController`: Recibe logs del frontend
- Sanitización automática de campos sensibles

### 3. Log Viewer (`http://localhost:4000`)
- Interfaz web para explorar logs
- Filtros por servicio, nivel, trace ID, session ID
- Búsqueda de texto completo
- Auto-refresh cada 10 segundos

## Uso

### Ver logs en tiempo real
```bash
# Abrir viewer
open http://localhost:4000

# O usar API directamente
curl "http://localhost:4000/api/logs/search?limit=50" | jq
```

### Filtros disponibles
- `service`: frontend, backend, auth
- `level`: error, warn, info, debug
- `traceId`: ID único de request
- `sessionId`: ID de sesión del usuario
- `text`: Búsqueda de texto
- `from`/`to`: Rango de fechas

### Ejemplos útiles
```bash
# Ver errores recientes
curl "http://localhost:4000/api/logs/search?level=error&limit=20" | jq

# Seguir una sesión específica
curl "http://localhost:4000/api/logs/search?sessionId=abc-123" | jq

# Buscar por trace ID
curl "http://localhost:4000/api/logs/search?traceId=xyz-789" | jq

# Buscar texto
curl "http://localhost:4000/api/logs/search?text=unauthorized" | jq
```

## Configuración

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
  image: node:20-alpine
  ports:
    - "4000:4000"
  volumes:
    - ../../logs:/logs:ro
```

## Buenas Prácticas

1. **No loguear información sensible** - El sistema sanitiza automáticamente campos como password, token, etc.
2. **Usar trace IDs** - Permite correlacionar frontend y backend
3. **Logs estructurados** - Usar objetos JSON para mejor búsqueda
4. **Niveles apropiados** - error para errores, warn para advertencias, info para flujo normal

## Mantenimiento

### Limpiar logs
```bash
docker exec trivance_management sh -c "echo '' > /logs/trivance-unified.json"
```

### Ver tamaño de logs
```bash
docker exec trivance_management ls -lh /logs/
```

### Rotar logs
Los logs rotan automáticamente cada 100MB, manteniendo máximo 5 archivos.

## Troubleshooting

### No aparecen logs del backend
- Verificar que el servicio esté corriendo: `docker ps | grep management`
- Verificar logs de Docker: `docker logs trivance_management`

### Frontend no envía logs
- Verificar consola del navegador por errores
- Verificar que el endpoint `/api/logs/batch` responde

### Log viewer no funciona
- Verificar que el puerto 4000 esté libre
- Verificar logs: `docker logs trivance_log_viewer`