# Trivance Dev Config - Documentación de Arquitectura

## Resumen

Este repositorio proporciona configuración automatizada del entorno de desarrollo para la plataforma Trivance, que consta de 4 servicios interconectados:

- **ms_trivance_auth** - Servicio de autenticación (NestJS)
- **ms_level_up_management** - API de gestión con GraphQL (NestJS)
- **level_up_backoffice** - Frontend administrativo (React/Vite)
- **trivance-mobile** - Aplicación móvil (React Native/Expo)

## Estructura de Directorios

```
trivance-dev-config/
├── config/              # Archivos de configuración
│   ├── environments.json    # Variables de entorno para todos los servicios
│   └── repositories.json    # URLs y ramas de repositorios
├── docs/                # Documentación adicional
├── scripts/             # Scripts de automatización
│   ├── core/           # Scripts principales de orquestación
│   │   └── orchestrator.sh  # Script principal de configuración
│   ├── utils/          # Scripts utilitarios
│   │   ├── clean-workspace.sh      # Limpieza del workspace
│   │   ├── common.sh               # Funciones compartidas
│   │   ├── generate-secrets.sh     # Generación dinámica de secretos
│   │   ├── parallel-install.sh     # Instalación paralela con npm
│   │   ├── post-setup-fixes.sh     # Correcciones post-instalación
│   │   ├── verify-compilation.sh   # Verificación de compilación
│   │   ├── verify-docker-mobile.sh # Verificación Docker + Mobile
│   │   └── verify-parity.sh        # Verificación de paridad
│   └── envs.sh         # Gestión de entornos
├── templates/          # Plantillas de configuración
├── setup.sh           # Punto de entrada principal
├── start-all.sh       # Orquestación de servicios con PM2
└── status.sh          # Monitoreo del estado de servicios
```

## Características Principales

### 1. Configuración Automatizada
- Clona los 4 repositorios
- Configura variables de entorno
- Instala dependencias en paralelo
- Verifica la compilación
- Configura herramientas de desarrollo

### 2. Gestión de Procesos
- Integración con PM2 para gestión automática de servicios
- Reinicio automático en caso de fallo
- Registro centralizado de logs
- Monitoreo de recursos

### 3. Gestión de Entornos
- Generación dinámica de secretos para seguridad
- Cambio entre entornos (local/qa/producción)
- Configuración basada en plantillas

### 4. Experiencia del Desarrollador
- Configuración con un solo comando
- Verificaciones de salud y monitoreo
- Manejo profesional de errores
- Compatibilidad multiplataforma

## Uso

### Configuración Inicial
```bash
./setup.sh
```

### Iniciar Servicios

#### Opción 1: Stack Completo con Docker (Recomendado)
```bash
./start.sh start    # Starts Docker containers + PM2 services
```

#### Opción 2: Control Individual
```bash
# Backend y bases de datos (Docker)
docker-compose up -d

# Solo frontend (PM2)
pm2 start ecosystem.config.js --only level_up_backoffice
```

### Verificar Estado
```bash
./start.sh status   # Muestra estado de Docker y PM2
```

### App Móvil con Docker
```bash
# En el repo móvil después de que Docker esté corriendo
cd trivance-mobile
npm run start:docker   # O usa .env.local con ENV_LOCAL=true
```

### Gestionar Entornos
```bash
./change-env.sh status        # Mostrar entorno actual
./change-env.sh switch qa     # Cambiar a entorno QA
```

## Decisiones Técnicas

### Arquitectura Híbrida Docker (Enfoque Pragmático)
**Decisión**: Docker para backend/bases de datos en desarrollo, cloud-nativo para QA/Producción

**Justificación**:
- El desarrollo se beneficia de la contenedorización (consistencia, aislamiento, configuración fácil)
- QA/Producción ya estables en infraestructura cloud
- El costo de migración excede los beneficios para servicios establecidos
- El equipo ya domina la configuración actual de producción

**Compromisos Aceptados**:
- Diferencias menores entre entornos (documentadas y entendidas)
- Métodos de despliegue diferentes (Docker vs servicios cloud)
- Estas diferencias no impactan la calidad del producto

### PM2 para Desarrollo Frontend
- Hot reload para retroalimentación inmediata (crítico para productividad)
- Docker agregaría latencia innecesaria para frontend
- El frontend no tiene dependencias complejas que requieran contenedorización
- PM2 proporciona capacidades de reinicio automático

### Instalación Paralela
- Reduce el tiempo de configuración de ~15 minutos a ~3 minutos
- Protección contra timeout previene instalaciones colgadas
- Indicación de progreso para mejor experiencia de usuario

### Generación Dinámica de Secretos
- Secretos únicos por instalación
- Previene filtración de credenciales
- Valores por defecto seguros para desarrollo

### Compatibilidad de Shell
- Scripts compatibles con POSIX cuando es posible
- Shebang bash explícito para características avanzadas
- Compatibilidad cruzada macOS/Linux

## Filosofía de Arquitectura: Valor sobre Purismo

### Principios Guía
1. **YAGNI** (No lo vas a necesitar) - Evitar optimización prematura
2. **Tecnología Aburrida** - Usar lo que el equipo conoce bien
3. **Migración Gradual** - Cambios incrementales sobre reescrituras grandes
4. **Decisiones Basadas en Datos** - Basadas en métricas reales, no suposiciones
5. **Velocidad del Equipo > Pureza Técnica** - La productividad es lo más importante

### Estrategia de Paridad de Entornos

#### Lo que Sincronizamos
- Versiones de Node.js en todos los entornos
- Versiones de motores de base de datos (PostgreSQL 14, MongoDB 6)
- Valores críticos de configuración (límites de tasa, timeouts)
- Políticas de seguridad y flujos de autenticación

#### Diferencias Aceptadas
| Componente | Local | QA/Prod | Impacto | Mitigación |
|------------|-------|---------|---------|------------|
| Base de datos | Docker PostgreSQL | AWS RDS | Ninguno | Misma versión |
| Caché | Sin Redis | ElastiCache | Rendimiento | Feature flags |
| Almacenamiento | Sistema de archivos | S3 | Subidas | LocalStack opcional |
| Monitoreo | Logs de consola | CloudWatch | Depuración | Logs estructurados |

### Configuración de App Móvil
La app móvil usa un sistema unificado de entornos que:
- Soporta desarrollo local Docker vía `env.local.ts`
- Mantiene compatibilidad con configuraciones existentes de QA/Producción
- Permite cambio fluido entre entornos
- Muestra indicadores visuales del entorno activo

## Consideraciones de Seguridad

1. **Sin credenciales de producción hardcodeadas**
2. **Secretos generados para desarrollo**
3. **Aislamiento de entornos**
4. **Patrones gitignore para archivos sensibles**
5. **Secretos Docker para datos sensibles**
6. **Configuración móvil unificada previene fugas de credenciales**

## Mantenimiento

### Agregar Nuevos Servicios
1. Actualizar `config/repositories.json`
2. Agregar plantilla de entorno en `config/environments.json`
3. Actualizar configuración PM2 en `start-all.sh`

### Actualizar Dependencias
Ejecutar setup nuevamente para obtener últimos cambios:
```bash
./setup.sh
```

## Solución de Problemas

### El Servicio No Inicia
- Verificar logs: `pm2 logs [nombre-servicio]`
- Verificar que los puertos estén disponibles: `./status.sh`
- Reiniciar servicio: `pm2 restart [nombre-servicio]`

### Timeout de Instalación
- Limpiar caché npm: `npm cache clean --force`
- Eliminar node_modules y reintentar
- Verificar conectividad de red

### Problemas de Entorno
- Verificar que existan archivos `.env` en cada servicio
- Revisar plantillas de entorno en `envs/`
- Regenerar secretos si es necesario