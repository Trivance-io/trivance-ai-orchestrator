# 🚀 Trivance Dev Config

Configuración **automática, completa y segura** del entorno de desarrollo para la plataforma Trivance.

## 🎯 ¿Qué es esto?

Este repositorio configura **AUTOMÁTICAMENTE** todo tu entorno de desarrollo con un solo comando:

- ✅ **4 repositorios** clonados y configurados
- ✅ **Variables de entorno** generadas de forma segura
- ✅ **Dependencias** instaladas en paralelo
- ✅ **Servicios** ejecutándose con PM2
- ✅ **Todo listo** en menos de 10 minutos

## 📋 Requisitos Previos

Antes de empezar, necesitas tener instalado:

- **Node.js 18+** → [Descargar](https://nodejs.org/)
- **Git** → [Descargar](https://git-scm.com/)
- **PostgreSQL** → Para el backend principal
- **MongoDB** → Para el servicio de autenticación

### Verificar requisitos:
```bash
node --version   # Debe ser v18 o superior
npm --version    # Debe estar instalado
git --version    # Debe estar instalado
psql --version   # PostgreSQL (opcional pero recomendado)
mongod --version # MongoDB (opcional pero recomendado)
```

## 🚀 Instalación Completa (3 pasos)

### Paso 1: Clonar este repositorio
```bash
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config
```

### Paso 2: Ejecutar setup automático
```bash
./setup.sh
```

Este comando hace TODO por ti:
- Clona los 4 repositorios del proyecto
- Genera secrets únicos y seguros
- Crea todos los archivos .env
- Instala todas las dependencias
- Verifica que todo compile correctamente

### Paso 3: Iniciar servicios
```bash
cd ..  # Volver al workspace
./start.sh
```

¡Listo! 🎉 Todos los servicios están corriendo.

## 🖥️ URLs de los Servicios

Una vez iniciados, accede a:

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Frontend Admin | http://localhost:5173 | Panel de administración |
| API Principal | http://localhost:3000 | Backend con GraphQL |
| API Auth | http://localhost:3001 | Servicio de autenticación |
| GraphQL Playground | http://localhost:3000/graphql | Explorador GraphQL |
| Mobile Metro | http://localhost:8081 | Servidor Expo (si aplica) |

## 📁 Estructura del Proyecto

Después del setup, tu workspace se verá así:

```
tu-workspace/
├── start.sh                      # 🎮 Comando principal (menú interactivo)
├── trivance-dev-config/          # 📦 Este repositorio (configuración)
├── ms_level_up_management/       # 🚀 API Backend principal
├── ms_trivance_auth/             # 🔐 Servicio de autenticación  
├── level_up_backoffice/          # 🌐 Frontend administrativo
├── trivance-mobile/              # 📱 App móvil
├── envs/                         # 🔧 Configuraciones de ambiente
│   ├── ENVIRONMENTS.md           # 📖 Guía de environments
│   ├── .current_environment      # 📍 Environment actual
│   └── *.env                     # 🔒 Archivos de configuración
├── logs/                         # 📊 Logs de PM2
└── .trivance-secrets             # 🔑 Secrets generados (NO SUBIR A GIT)
```

## 🎮 Comando Principal: start.sh

Un solo comando para todo:

```bash
./start.sh
```

Te mostrará un menú interactivo:
```
1) 🚀 Iniciar servicios
2) 📊 Ver estado de servicios  
3) 🔄 Cambiar environment
4) 🛑 Detener servicios
5) 🔍 Verificar salud del sistema
6) 📚 Ver documentación
7) 🗑️  Limpiar y reconfigurar
0) 🚪 Salir
```

También puedes usar comandos directos:
```bash
./start.sh start    # Iniciar servicios
./start.sh stop     # Detener servicios
./start.sh status   # Ver estado
./start.sh setup    # Reconfigurar todo
```

## 🔄 Gestión de Environments

### Cambiar entre ambientes:
```bash
# Ver environment actual
./trivance-dev-config/scripts/envs.sh status

# Cambiar a desarrollo local (por defecto)
./trivance-dev-config/scripts/envs.sh switch local

# Cambiar a QA
./trivance-dev-config/scripts/envs.sh switch qa

# Cambiar a producción (requiere confirmación)
./trivance-dev-config/scripts/envs.sh switch production
```

### ⚠️ Importante sobre QA/Producción:
- Los archivos de QA y producción NO vienen incluidos por seguridad
- Debes crearlos manualmente copiando los archivos locales
- Nunca subas credenciales reales a Git

## 🛠️ Comandos PM2 Útiles

```bash
pm2 status          # Ver estado de todos los servicios
pm2 logs            # Ver logs en tiempo real
pm2 logs [servicio] # Ver logs de un servicio específico
pm2 restart all     # Reiniciar todos los servicios
pm2 stop all        # Detener todos los servicios
pm2 monit           # Monitor interactivo
```

## 🔐 Seguridad

### Secrets Automáticos
- Cada instalación genera secrets ÚNICOS
- Se guardan en `.trivance-secrets` (ignorado por Git)
- NO hay credenciales hardcodeadas

### Archivos Sensibles
Estos archivos NUNCA deben subirse a Git:
- `.trivance-secrets`
- `.env` (todos)
- `envs/*.env`
- `.current_environment`

## 🆘 Solución de Problemas

### Problema: "Puerto ya está en uso"
```bash
# Ver qué usa el puerto
lsof -i:3000

# Matar el proceso
kill -9 [PID]
```

### Problema: "PostgreSQL/MongoDB connection failed"
```bash
# macOS
brew install postgresql
brew install mongodb-community
brew services start postgresql
brew services start mongodb-community

# Linux
sudo apt install postgresql mongodb
sudo systemctl start postgresql
sudo systemctl start mongodb
```

### Problema: "Service crashed"
```bash
# Ver logs del servicio
pm2 logs [nombre-servicio]

# Reiniciar servicio
pm2 restart [nombre-servicio]

# Validar configuración
./trivance-dev-config/scripts/envs.sh validate
```

### Verificación completa:
```bash
./trivance-dev-config/scripts/utils/validate-setup.sh
```

## 🤖 Para Desarrollo con IA

Este repositorio está optimizado para Claude Code y otras IAs:

### Setup completo en 3 comandos:
```bash
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config && ./setup.sh
cd .. && ./start.sh
```

### Características IA-friendly:
- ✅ Sin pasos manuales
- ✅ Errores claros y descriptivos
- ✅ Estructura predecible
- ✅ Validación automática
- ✅ Documentación en español

## 📚 Documentación Adicional

| Documento | Descripción |
|-----------|-------------|
| [ENVIRONMENTS.md](envs/ENVIRONMENTS.md) | Guía completa de environments |
| [COMMANDS.md](trivance-dev-config/docs/COMMANDS.md) | Todos los comandos disponibles |
| [TROUBLESHOOTING.md](trivance-dev-config/docs/TROUBLESHOOTING.md) | Solución de problemas detallada |
| [ONBOARDING.md](trivance-dev-config/docs/ONBOARDING.md) | Guía para nuevos desarrolladores |

## ✅ Checklist Post-Instalación

Después del setup, verifica:

- [ ] Todos los servicios están `online` en `pm2 status`
- [ ] Puedes acceder a http://localhost:5173 (Frontend)
- [ ] Puedes acceder a http://localhost:3000/graphql (GraphQL)
- [ ] No hay errores en `pm2 logs`
- [ ] El archivo `.trivance-secrets` fue creado
- [ ] La carpeta `envs/` contiene archivos `.env`

## 🚨 Errores Comunes y Soluciones

### "Cannot find module"
```bash
# Reinstalar dependencias
cd [repositorio-con-error]
rm -rf node_modules package-lock.json
npm install
```

### "EADDRINUSE: address already in use"
```bash
# El setup maneja esto automáticamente
# Si persiste, ejecuta:
pm2 kill
./start.sh
```

### "Database connection error"
```bash
# Verificar que las bases de datos estén corriendo
# PostgreSQL: puerto 5432
# MongoDB: puerto 27017
```

## 🎯 Resumen

1. **Clona** → `git clone https://github.com/GLab-Projects/trivance-dev-config.git`
2. **Setup** → `cd trivance-dev-config && ./setup.sh`
3. **Inicia** → `cd .. && ./start.sh`

¡Eso es todo! En menos de 10 minutos tendrás todo funcionando.

---

**¿Problemas?** Revisa [TROUBLESHOOTING.md](trivance-dev-config/docs/TROUBLESHOOTING.md) o contacta al equipo en Slack #dev-support