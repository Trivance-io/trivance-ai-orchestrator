# Safe Ecosystem Restart

Realiza un reinicio seguro y controlado del ecosistema Trivance Platform:

## ⚠️ IMPORTANTE
Este comando debe ejecutarse paso a paso **CON CONFIRMACIÓN DEL USUARIO** en cada etapa.

## Paso 1: Pre-checks
Verificar que es seguro proceder:
- No hay procesos críticos corriendo
- No hay desarrolladores trabajando activamente
- Backup reciente disponible si es necesario
- **¿Confirmas que es seguro proceder? (Pedir confirmación)**

## Paso 2: Detener Servicios Gradualmente
```bash
# Detener frontend primero (menos crítico)
pm2 stop backoffice

# Detener servicios Docker
./start.sh stop
```
**¿Los servicios se detuvieron correctamente? (Verificar y pedir confirmación)**

## Paso 3: Verificar Limpieza
```bash
# Verificar que no hay procesos colgados
ps aux | grep -E "(node|docker|postgres|mongo)"

# Verificar que los puertos están libres
lsof -i :3000 :3001 :5173 :5432 :27017 :4000 :9999
```
**¿Todos los puertos están libres? (Pedir confirmación antes de continuar)**

## Paso 4: Limpiar Recursos (Si es necesario)
Si hay procesos colgados o puertos ocupados:
```bash
# Solo si es necesario y CON CONFIRMACIÓN
pm2 kill
docker system prune -f
```
**¿Necesitas limpieza adicional? (Solo si hay problemas)**

## Paso 5: Reiniciar Servicios
```bash
# Iniciar con el comando estándar
./start.sh start
```
**¿Los servicios iniciaron correctamente? (Esperar y verificar)**

## Paso 6: Validación Post-Restart
Verificar que todo funciona:
- Todos los servicios en estado "online"
- Endpoints de health responden
- Frontend accesible
- APIs funcionales
- Base de datos conectada

## Paso 7: Confirmación Final
Proporcionar resumen del reinicio:
- ✅ Servicios reiniciados exitosamente
- ⏱️ Tiempo total del proceso
- 📊 Estado final de todos los componentes
- 🔗 URLs de verificación para el usuario

**NUNCA ejecutar este comando automáticamente - siempre requiere supervisión e interacción del usuario.**