# 📊 Sistema de Observabilidad

Sistema integrado de monitoreo y logging para desarrollo completo de Trivance.

## Componentes

### 🔍 Log Viewer (Puerto 4000)
Sistema unificado de logging para desarrollo AI-first.

**Características:**
- Logging centralizado de todos los servicios
- Búsqueda avanzada por servicio, nivel, trace ID, session ID
- Interfaz web en http://localhost:4000
- Hot-reload de logs en tiempo real

**Arquitectura:**
```
Frontend (React) → Backend (NestJS) → Archivo JSON → Log Viewer
     ↓                    ↓                              ↑
  Interceptors      Interceptors                   Búsqueda/Filtros
```

### 📈 Dozzle (Puerto 9999)
Monitor web moderno para logs de contenedores Docker.

**Características:**
- Interfaz web responsiva
- Logs en tiempo real con actualización automática
- Filtrado automático de contenedores Trivance
- Sin configuración adicional requerida
- URL: http://localhost:9999

## Inicialización Automática

Ambos servicios se inician automáticamente con:
```bash
./start.sh start
```

## Comandos Específicos

### Log Viewer
```bash
# Acceder directamente
open http://localhost:4000

# Ver logs del servicio
docker logs trivance_log_viewer_dev
```

### Dozzle
```bash
# Usando script dedicado
./trivance-dev-config/scripts/dozzle.sh start
./trivance-dev-config/scripts/dozzle.sh status
./trivance-dev-config/scripts/dozzle.sh open

# Acceder directamente
open http://localhost:9999
```

## Integración con Docker Development Mode

- **Log Viewer**: Contenedor `trivance_log_viewer_dev`
- **Dozzle**: Contenedor con filtrado automático de contenedores Trivance
- **Parte integral** del stack de desarrollo estándar

## API del Log Viewer

```bash
# Búsqueda programática
curl "http://localhost:4000/api/logs/search?level=error&service=backend"

# Filtros disponibles: service, level, traceId, sessionId, text
```