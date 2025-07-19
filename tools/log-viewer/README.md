# Log Viewer Service

Servicio de observabilidad para el sistema unificado de logs de Trivance.

## 📚 Documentación Completa

Ver la documentación detallada en: [`/docs/LOG-VIEWER.md`](../../docs/LOG-VIEWER.md)

## 🚀 Quick Start

```bash
# El servicio se inicia automáticamente con:
./start.sh start

# Acceder a la interfaz web:
open http://localhost:4000
```

## 📁 Estructura

```
log-viewer/
├── server.js         # Servidor Express con API REST
├── public/           # Frontend web
│   ├── index.html   # Interfaz de usuario
│   └── app.js       # Lógica del cliente
├── Dockerfile       # Configuración Docker
└── package.json     # Dependencias Node.js
```

## 🐳 Docker

- **Container**: `trivance_log_viewer_dev`
- **Puerto**: 4000
- **Imagen base**: node:22-alpine
- **Volumen**: `/logs` (read-only)

Para más información, consultar la [documentación completa](../../docs/LOG-VIEWER.md).