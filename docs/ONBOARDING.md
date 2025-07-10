# 🚀 Guía de Onboarding - Trivance Platform

## 👋 Bienvenido al Equipo

Esta guía te llevará de cero a tener un entorno de desarrollo completamente funcional en **menos de 10 minutos**.

## 📋 Requisitos Previos

### Herramientas Requeridas
```bash
# Node.js 18+
node --version   # Debe ser v18 o superior
npm --version    # Debe estar instalado
git --version    # Debe estar instalado

# Verificar acceso SSH a GitHub
ssh -T git@github.com
```

### Base de Datos (Opcional)
- **PostgreSQL**: Para el backend principal
- **MongoDB**: Para el servicio de autenticación

## 🚀 Setup Automático (3 Pasos)

### Paso 1: Clonar y Configurar
```bash
# Crear workspace
mkdir -p ~/Desarrollo/Trivance-Platform
cd ~/Desarrollo/Trivance-Platform

# Clonar configuración
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config
```

### Paso 2: Ejecutar Setup Completo
```bash
# TODO automático en un comando
./setup.sh
```

**Este comando hace AUTOMÁTICAMENTE**:
- ✅ Clona los 4 repositorios
- ✅ Genera secrets únicos y seguros
- ✅ Instala todas las dependencias
- ✅ Configura variables de entorno
- ✅ Verifica que todo compile
- ✅ Configura servicios PM2

### Paso 3: Iniciar Servicios
```bash
cd ..  # Volver al workspace
./start.sh
```

## 🎉 ¡Listo!

### URLs Disponibles
- **Frontend**: http://localhost:5173
- **API Principal**: http://localhost:3000
- **GraphQL**: http://localhost:3000/graphql
- **Auth Service**: http://localhost:3001

### Comandos Diarios
```bash
./start.sh          # Menú interactivo
./start.sh start    # Iniciar servicios
./start.sh status   # Ver estado
./start.sh stop     # Detener servicios
```

## 🔧 Desarrollo Diario

### Flujo Típico
```bash
# 1. Iniciar día
./start.sh start

# 2. Verificar que todo funciona
./start.sh status

# 3. Desarrollar (los servicios se recargan automáticamente)

# 4. Antes de commit (OBLIGATORIO)
./trivance-dev-config/scripts/utils/verify-compilation.sh

# 5. Finalizar día
pm2 stop all
```

### Comandos Útiles
```bash
# PM2 management
pm2 status          # Estado de servicios
pm2 logs            # Ver logs en tiempo real
pm2 restart all     # Reiniciar servicios

# Environment management
./trivance-dev-config/scripts/envs.sh status   # Ver environment actual
./trivance-dev-config/scripts/envs.sh switch qa  # Cambiar a QA
```

## 🤖 Claude Code Setup

**IMPORTANTE**: Claude Code se configura automáticamente **AL FINAL** del setup exitoso.

1. **Después del setup completo**, ejecuta:
   ```bash
   /init
   ```

2. Esto generará automáticamente el `CLAUDE.md` optimizado con todo el contexto del workspace.

## 🆘 Solución de Problemas

### Error: Puerto en uso
```bash
pm2 stop all
./start.sh start
```

### Error: Dependencias
```bash
cd [repositorio-con-error]
rm -rf node_modules package-lock.json
npm install
```

### Error: Base de datos
```bash
# macOS
brew services start postgresql
brew services start mongodb-community

# Linux
sudo systemctl start postgresql
sudo systemctl start mongod
```

### Verificación Completa
```bash
./trivance-dev-config/scripts/utils/validate-setup.sh
```

## ✅ Checklist de Verificación

Después del setup, confirma:

- [ ] `pm2 status` muestra todos los servicios como `online`
- [ ] Puedes acceder a http://localhost:5173
- [ ] Puedes acceder a http://localhost:3000/graphql
- [ ] No hay errores en `pm2 logs`
- [ ] Existe `.trivance-secrets` en el workspace
- [ ] Existe carpeta `envs/` con archivos `.env`

## 🎯 Próximos Pasos

1. **Revisar primera tarea** asignada
2. **Ejecutar /init** para configurar Claude Code
3. **Hacer primer commit** (aunque sea pequeño)
4. **Unirse al equipo** en Slack #dev-general

## 📚 Recursos

- **Troubleshooting**: `docs/TROUBLESHOOTING.md`
- **Workflows**: `docs/WORKFLOWS.md`
- **Environments**: `envs/ENVIRONMENTS.md`
- **Soporte**: Slack #dev-support

---

**¡Bienvenido oficialmente al equipo! 🚀**

Si completaste todos los checkpoints, estás listo para contribuir al proyecto.