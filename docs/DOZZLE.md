# 📊 Dozzle - Monitor de Logs Docker

Dozzle es una herramienta web ligera y moderna para visualizar logs de contenedores Docker en tiempo real.

## 🚀 Características

- ✅ **Interfaz web moderna** y responsiva
- ✅ **Logs en tiempo real** con actualización automática
- ✅ **Filtrado automático** de contenedores Trivance
- ✅ **Sin configuración** adicional requerida
- ✅ **Búsqueda y filtrado** de logs
- ✅ **Múltiples contenedores** en una sola vista

## 🌐 Acceso

Una vez iniciado Dozzle, accede a:

**URL:** http://localhost:9999

## 🎮 Comandos Disponibles

### Usando el script dedicado:
```bash
# Iniciar Dozzle
./trivance-dev-config/scripts/dozzle.sh start

# Ver estado
./trivance-dev-config/scripts/dozzle.sh status

# Abrir en navegador
./trivance-dev-config/scripts/dozzle.sh open

# Ver logs de Dozzle
./trivance-dev-config/scripts/dozzle.sh logs

# Detener Dozzle
./trivance-dev-config/scripts/dozzle.sh stop

# Reiniciar
./trivance-dev-config/scripts/dozzle.sh restart
```

### Usando el menú principal:
```bash
./start.sh
# Selecciona: 7) 📊 Monitor de Logs (Dozzle)
```

### Usando Docker Compose directamente:
```bash
cd trivance-dev-config/docker
docker-compose up -d dozzle
```

## 📦 Contenedores Monitoreados

Dozzle está configurado para mostrar automáticamente los logs de todos los contenedores con prefijo `trivance_*`:

- **trivance_management** - API principal
- **trivance_auth** - Servicio de autenticación  
- **trivance_postgres** - Base de datos PostgreSQL
- **trivance_mongodb** - Base de datos MongoDB

## ⚙️ Configuración

La configuración actual de Dozzle incluye:

```yaml
environment:
  - DOZZLE_LEVEL=info          # Nivel de logs
  - DOZZLE_TAILSIZE=300        # Líneas iniciales a mostrar
  - DOZZLE_FILTER=name=trivance_*  # Filtro automático
```

## 🔍 Funcionalidades Web

Una vez en http://localhost:9999:

### Navegación
- **Lista de contenedores** en la barra lateral
- **Selección múltiple** para ver varios logs simultáneamente
- **Búsqueda en tiempo real** con highlighting

### Controles
- **▶️ Play/Pause** para pausar el flujo de logs
- **🔍 Buscar** texto específico en los logs
- **📅 Timestamps** para cada línea de log
- **🎨 Colores** diferenciados por nivel de log

### Filtros
- **Error logs** solamente
- **Warning logs** y superiores
- **Info logs** completos
- **Debug logs** (si están habilitados)

## 🛠️ Resolución de Problemas

### Dozzle no inicia
```bash
# Verificar Docker
docker ps

# Verificar puerto libre
lsof -i:9999

# Reiniciar servicio
./trivance-dev-config/scripts/dozzle.sh restart
```

### No se ven logs
```bash
# Verificar contenedores corriendo
docker ps --filter "name=trivance_*"

# Verificar filtro en Dozzle
# En la web: Settings > Container Filter
```

### Error de permisos Docker
```bash
# En Linux, agregar usuario a grupo docker
sudo usermod -aG docker $USER
# Reiniciar sesión
```

## 🔐 Seguridad

Dozzle accede a Docker mediante socket read-only:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

- ✅ **Solo lectura** - No puede modificar contenedores
- ✅ **Sin persistencia** - No guarda logs localmente
- ✅ **Filtrado** - Solo ve contenedores Trivance
- ✅ **Local** - Solo accesible desde localhost

## 💡 Tips de Uso

### Para Desarrollo
1. **Mantén Dozzle abierto** en una pestaña durante desarrollo
2. **Usa la búsqueda** para encontrar errores específicos
3. **Pausa los logs** cuando necesites analizar algo específico
4. **Filtra por contenedor** para depurar servicios específicos

### Para Debugging
1. **Busca por nivel**: `ERROR`, `WARN`, `INFO`
2. **Busca por funcionalidad**: `GraphQL`, `Database`, `Auth`
3. **Usa timestamps** para correlacionar eventos
4. **Combina múltiples contenedores** para ver flujo completo

## 🔄 Integración con PM2

Dozzle es complementario a PM2:
- **PM2**: Gestiona el frontend (level_up_backoffice)
- **Dozzle**: Monitorea los backends Docker

Para logs completos del sistema:
```bash
# Logs PM2 (frontend)
pm2 logs

# Logs Docker (backends) 
# Ir a http://localhost:9999
```

## 📊 Alternativas

Si prefieres usar terminal:
```bash
# Logs de un contenedor específico
docker logs -f trivance_management

# Logs de todos los servicios
cd trivance-dev-config/docker
docker-compose logs -f
```

---

**💡 Tip:** Dozzle es especialmente útil durante el desarrollo para tener una vista unificada y moderna de todos los logs del sistema.
