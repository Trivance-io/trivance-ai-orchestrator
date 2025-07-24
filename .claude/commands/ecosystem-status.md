# Ecosystem Status Check

Realiza una verificación completa del estado del ecosistema Trivance Platform:

## 1. Estado de Servicios
Ejecuta `./start.sh status` para verificar todos los servicios y proporciona un resumen de:
- ✅ Servicios corriendo correctamente
- ❌ Servicios con problemas
- ⚠️ Servicios no iniciados

## 2. Verificación Docker
Verifica el estado de los contenedores Docker:
- PostgreSQL (puerto 5432)
- MongoDB (puerto 27017) 
- Management API (puerto 3000)
- Auth Service (puerto 3001)
- Log Viewer (puerto 4000)
- Dozzle (puerto 9999)

## 3. Verificación de Environment
Confirma la configuración actual del environment:
- Environment activo (`./trivance-dev-config/scripts/envs.sh status`)
- Archivos .env generados correctamente
- Variables críticas configuradas

## 4. Verificación de Puertos
Verifica que todos los puertos requeridos estén disponibles:
```bash
lsof -i :3000 :3001 :5173 :5432 :27017 :4000 :9999
```

## 5. Revisión de Logs
Escanea rápidamente los logs recientes en busca de errores críticos:
- Logs de Docker containers
- Logs de PM2 (frontend)
- Errores en el Log Viewer unificado

## 6. Health Checks
Verifica los endpoints de health de todos los servicios:
- Management API: `http://localhost:3000/health`
- Auth Service: `http://localhost:3001/health`
- Frontend: `http://localhost:5173`
- GraphQL Playground: `http://localhost:3000/graphql`

Proporciona un **reporte completo** del estado del ecosistema con recomendaciones de acción si encuentras problemas.