# 🎛️ Sistema de Environments - Guía Completa

## 🤔 ¿Qué es esto?

El sistema de environments de Trivance te permite cambiar entre diferentes configuraciones (local, QA, producción) con **UN SOLO COMANDO**. Es como tener diferentes "modos" para tu aplicación:

- **🏠 Local**: Tu computadora, para desarrollo
- **🧪 QA**: Servidor de pruebas
- **🚀 Producción**: Servidor real con usuarios

## 🎯 ¿Cómo funciona?

### La magia en 3 pasos:

1. **Configuración centralizada**: Todo está en `trivance-dev-config/config/environments.json`
2. **Generación automática**: El sistema crea archivos `.env` para cada servicio
3. **Un comando para cambiar**: Cambias TODOS los servicios de golpe

### Ejemplo visual:
```
Tu comando: ./change-env.sh switch qa

Lo que pasa:
├── ms_trivance_auth/.env      → Cambia a config de QA
├── ms_level_up_management/.env → Cambia a config de QA
├── level_up_backoffice/.env    → Cambia a config de QA
└── trivance-mobile/.env        → Cambia a config de QA

¡TODO sincronizado! 🎉
```

## 📋 Guía Rápida - Lo que necesitas saber

### 1️⃣ Ver en qué environment estás
```bash
./trivance-dev-config/scripts/envs.sh status
```

Te dirá algo como:
```
✅ Environment actual: local
📁 Archivos de configuración en: /tu-proyecto/envs
```

### 2️⃣ Cambiar de environment

**Para desarrollo local** (tu computadora):
```bash
./trivance-dev-config/scripts/envs.sh switch local
```

**Para servidor de pruebas** (QA):
```bash
./trivance-dev-config/scripts/envs.sh switch qa
```

**Para producción** (¡CUIDADO! 🚨):
```bash
./trivance-dev-config/scripts/envs.sh switch production
# Te pedirá confirmación porque es PRODUCCIÓN REAL
```

### 3️⃣ Después de cambiar

Reinicia los servicios:
```bash
./start-all.sh
```

## 🔐 Seguridad - MUY IMPORTANTE

### Para Local (tu computadora)
- ✅ **TODO ES AUTOMÁTICO**: Los secrets se generan solos
- ✅ **Es seguro**: Cada instalación tiene secrets únicos
- ✅ **No necesitas hacer nada**: Just works™

### Para QA/Producción
- ⚠️ **CONFIGURACIÓN MANUAL REQUERIDA**
- 📝 Pasos:
  1. Copia el archivo local como plantilla:
     ```bash
     cp envs/local.management.env envs/qa.management.env
     ```
  2. Edita con valores REALES de QA:
     - URLs reales del servidor QA
     - Credenciales de base de datos QA
     - API keys de servicios externos
  3. **NUNCA** subas estos archivos a Git

## 🗂️ ¿Dónde están los archivos?

```
tu-proyecto/
├── envs/                          # 📁 Aquí están TODAS las configuraciones
│   ├── local.management.env       # Config local del backend
│   ├── local.auth.env            # Config local de auth
│   ├── local.backoffice.env      # Config local del frontend
│   ├── local.mobile.env          # Config local de la app
│   ├── qa.*.env                  # Configs de QA (crearlas manualmente)
│   └── production.*.env          # Configs de producción (crearlas manualmente)
└── .trivance-secrets             # 🔐 Secrets autogenerados (NO SUBIR A GIT)
```

## 🛠️ Comandos Completos

### Básicos
```bash
# Ver estado actual
./trivance-dev-config/scripts/envs.sh status

# Cambiar environment
./trivance-dev-config/scripts/envs.sh switch [local|qa|production]

# Ver ayuda
./trivance-dev-config/scripts/envs.sh help
```

### Avanzados
```bash
# Validar que todo esté bien configurado
./trivance-dev-config/scripts/envs.sh validate

# Comparar dos environments
./trivance-dev-config/scripts/envs.sh diff local qa

# Sincronizar con environments.json
./trivance-dev-config/scripts/envs.sh sync
```

## ❓ Preguntas Frecuentes

### "¿Por qué no puedo editar el .env directamente?"
Los `.env` se generan automáticamente desde `environments.json`. Si los editas manualmente, se perderán los cambios al cambiar de environment.

### "¿Cómo agrego una nueva variable?"
1. Agrégala en `trivance-dev-config/config/environments.json`
2. Ejecuta: `./trivance-dev-config/scripts/envs.sh sync`
3. ¡Listo! Ya está en todos los servicios

### "¿Qué pasa si cambio a producción por error?"
- El sistema te pide confirmación (debes escribir "yes")
- Si ya lo hiciste, simplemente cambia de vuelta: `switch local`

### "No encuentro el archivo de QA"
Es normal. Los archivos de QA y producción NO vienen incluidos por seguridad. Debes crearlos copiando los locales y editándolos.

## 🚀 Workflow Típico de Desarrollo

### Mañana - Empezar a trabajar:
```bash
cd ~/tu-proyecto
./start-all.sh          # Inicia todo en local automáticamente
```

### Necesitas probar en QA:
```bash
./trivance-dev-config/scripts/envs.sh switch qa
./start-all.sh          # Ahora apunta a servidores QA
```

### Volver a desarrollo local:
```bash
./trivance-dev-config/scripts/envs.sh switch local
./start-all.sh          # De vuelta a tu máquina
```

## 🆘 Solución de Problemas

### "Me dice que faltan archivos de QA"
```bash
# Crear los archivos QA copiando los locales
cp envs/local.management.env envs/qa.management.env
cp envs/local.auth.env envs/qa.auth.env
cp envs/local.backoffice.env envs/qa.backoffice.env
cp envs/local.mobile.env envs/qa.mobile.env

# Ahora edita cada uno con valores de QA
```

### "Los servicios no se conectan después de cambiar"
```bash
# Asegúrate de reiniciar después de cambiar environment
pm2 stop all
./start-all.sh
```

### "No sé en qué environment estoy"
```bash
./trivance-dev-config/scripts/envs.sh status
# O mira el archivo:
cat envs/.current_environment
```

## 📚 Para Aprender Más

- **Archivo maestro**: `trivance-dev-config/config/environments.json`
- **Script principal**: `trivance-dev-config/scripts/envs.sh`
- **Documentación técnica**: `trivance-dev-config/README.md`

---

💡 **Tip Final**: El 90% del tiempo usarás solo estos comandos:
- `status` - Ver dónde estás
- `switch local` - Volver a desarrollo
- `switch qa` - Ir a pruebas

¡Eso es todo! 🎉