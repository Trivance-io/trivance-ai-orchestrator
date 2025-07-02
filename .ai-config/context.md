# 🤖 Configuración de Claude Code para Trivance Platform

## 🌐 Idioma y Comunicación
- **Idioma principal**: Español para todas las interacciones
- **Documentación**: Comentarios y documentación en español
- **Mensajes de error**: En español cuando sea posible
- **Commits**: Mensajes de commit en español

## 📁 Arquitectura del Workspace

### Descripción General
Trivance es una plataforma completa de gestión de organizaciones, eventos y donaciones que consiste en 4 repositorios principales:

```
Trivance-platform/               # Workspace multi-repo principal
├── .claude/                     # Configuraciones de Claude Code
│   └── settings.json           # Configuración multi-repo automática
├── level_up_backoffice/        # Panel administrativo web (React/Vite)
├── ms_level_up_management/     # API backend principal (NestJS + GraphQL)
├── ms_trivance_auth/           # Servicio de autenticación (NestJS)
├── trivance-mobile/            # Aplicación móvil (React Native + Expo)
├── scripts/                    # Scripts de automatización
├── TrivancePlatform.code-workspace  # Configuración VS Code multi-repo
└── CLAUDE.md                   # Configuración principal de Claude
```

## 🏗️ Repositorios y Tecnologías

### 1. level_up_backoffice (Frontend Administrativo)
**Propósito**: Panel de administración web para gestionar la plataforma
**Tecnologías principales**:
- React 18+ con TypeScript 5.3+
- Vite como bundler
- Redux Toolkit + RTK Query para estado
- Apollo Client para GraphQL
- Tailwind CSS + Material-UI para estilos
- Vitest para testing

**Estructura clave**:
```
src/
├── components/     # Componentes reutilizables
├── pages/         # Páginas de la aplicación
├── api/           # Servicios de API (GraphQL/REST)
├── store/         # Redux store y slices
├── utils/         # Utilidades y helpers
└── translations/  # Archivos de internacionalización
```

**URLs importantes**:
- Desarrollo: `http://localhost:5173`
- Staging: `https://staging-admin.trivance.com`
- Producción: `https://admin.trivance.com`

### 2. ms_level_up_management (Backend Principal)
**Propósito**: Microservicio central que maneja toda la lógica de negocio
**Tecnologías principales**:
- NestJS 10.x con TypeScript 5.x
- GraphQL Code-First con Apollo Server
- MongoDB + Prisma ORM
- AWS S3 para almacenamiento
- Sentry para monitoring
- Firebase Admin para notificaciones

**Módulos principales**:
- `users/` - Gestión de usuarios
- `organizations/` - Gestión de organizaciones
- `events/` - Sistema de eventos
- `donations/` - Sistema de donaciones
- `payments/` - Procesamiento de pagos
- `categories/` - Sistema de categorización

**APIs**:
- GraphQL: `http://localhost:3000/graphql`
- REST: `http://localhost:3000/api`
- Health: `http://localhost:3000/health`

### 3. ms_trivance_auth (Servicio de Autenticación)
**Propósito**: Microservicio dedicado a autenticación y autorización
**Tecnologías principales**:
- NestJS con TypeScript
- MongoDB con Mongoose
- JWT + bcrypt para autenticación
- Swagger para documentación

**APIs**:
- Base: `http://localhost:3001`
- Swagger: `http://localhost:3001/api-docs`
- Health: `http://localhost:3001/health`

### 4. trivance-mobile (Aplicación Móvil)
**Propósito**: App móvil nativa para usuarios finales
**Tecnologías principales**:
- React Native 0.79.4 + Expo 53.0.7
- TypeScript 5.8.3
- Redux Toolkit + Redux Persist
- React Navigation v6
- Firebase Crashlytics

**Environments**:
- Local: `EXPO_ENV=local npm start`
- QA: `EXPO_ENV=qa npm start` (recomendado)
- Prod: `EXPO_ENV=production npm start`

## 🔧 Comandos de Desarrollo

### Comandos por Repositorio

#### level_up_backoffice
```bash
npm run dev        # Servidor de desarrollo
npm run build      # Build para producción
npm run lint       # Linting con ESLint
npm run test       # Tests con Vitest
npm run preview    # Preview del build
```

#### ms_level_up_management
```bash
npm run start:dev     # Desarrollo con hot-reload
npm run start:prod    # Producción
npm run build         # Build de producción
npm run lint          # Linting y formato
npm run test          # Tests unitarios
npm run test:e2e      # Tests end-to-end
npm run test:cov      # Cobertura de tests
```

#### ms_trivance_auth
```bash
npm run start:dev     # Desarrollo con hot-reload
npm run start:prod    # Producción
npm run build         # Build de producción
npm run lint          # Linting y formato
npm run test          # Tests unitarios
npm run test:e2e      # Tests end-to-end
```

#### trivance-mobile
```bash
npm start              # Metro bundler
npm run start:qa       # Inicio con environment QA
npm run ios           # Simulador iOS
npm run android       # Emulador Android
npm run build:qa      # Build para QA
npm run build:prod    # Build para producción
npm run lint          # Linting
npm run type-check    # Check de tipos TypeScript
```

### Comandos de Setup Inicial
```bash
# Para cada proyecto, ejecutar en orden:
npm install
cp .env.example .env  # Configurar variables de entorno
npm run build
npm run lint
```

### Workflow de Desarrollo Diario
```bash
# 1. Iniciar servicios backend
cd ms_trivance_auth && npm run start:dev &
cd ms_level_up_management && npm run start:dev &

# 2. Iniciar frontend
cd level_up_backoffice && npm run dev

# 3. Iniciar mobile (opcional)
cd trivance-mobile && EXPO_ENV=qa npm start
```

## 🗄️ Base de Datos y Modelos

### MongoDB Collections Principales
- **users**: Usuarios del sistema con roles y permisos
- **organizations**: Organizaciones multi-tenant
- **events**: Eventos con sistema de ticketing
- **donations**: Transacciones de donaciones
- **publications**: Contenido modular (banners, posts, videos)
- **payments**: Procesamiento de pagos
- **categories**: Sistema de categorización
- **notifications**: Sistema de notificaciones

### Servicios Externos Integrados
- **AWS S3**: Almacenamiento de archivos multimedia
- **Firebase**: Crashlytics y notificaciones push
- **Brevo (SendinBlue)**: Email marketing
- **ePayco/Wompi**: Pasarelas de pago
- **Sentry**: Monitoring y error tracking
- **Google Maps**: Geolocalización

## 🔐 Autenticación y Seguridad

### Flujo de Autenticación
1. Login a través de `ms_trivance_auth`
2. JWT token generado y compartido entre servicios
3. Validación en `ms_level_up_management`
4. Autorización basada en roles y permisos

### Roles del Sistema
- **super_admin**: Acceso completo al sistema
- **admin**: Administrador de organización
- **moderator**: Moderador de contenido
- **user**: Usuario final

## 🌍 Environments y URLs

### Development (Local)
- Auth: `http://localhost:3001`
- Management: `http://localhost:3000`
- Backoffice: `http://localhost:5173`
- GraphQL Playground: `http://localhost:3000/graphql`

### QA/Staging
- Auth: `https://authqa.trivance.com`
- Management: `https://apiqa.trivance.com`
- Backoffice: `https://staging-admin.trivance.com`

### Production
- Auth: `https://auth.trivance.com`
- Management: `https://api.trivance.com`
- Backoffice: `https://admin.trivance.com`

## 📊 Monitoring y Observabilidad

### Error Tracking
- **Sentry**: Configurado en services backend
- **Firebase Crashlytics**: Configurado en mobile app
- **Console logs**: Estructurados con niveles apropiados

### Health Checks
- Endpoints `/health` disponibles en todos los servicios
- Monitoreo de conexiones de base de datos
- Verificación de servicios externos

## 🧪 Testing

### Estrategias por Repositorio
- **Frontend**: Vitest + React Testing Library
- **Backend**: Jest + Supertest para e2e
- **Mobile**: Jest + React Native Testing Library

### Comandos de Testing
```bash
# Tests unitarios
npm test

# Tests con cobertura
npm run test:cov

# Tests e2e
npm run test:e2e

# Tests en modo watch
npm run test:watch
```

## 🚀 Deployment

### Ambientes de Deploy
1. **Development**: Automático en push a `develop`
2. **QA/Staging**: Automático en push a `staging`
3. **Production**: Manual con aprobación en `main`

### Proceso de Release
1. Feature branch → `develop`
2. `develop` → `staging` (testing)
3. `staging` → `main` (producción)

## 📝 Convenciones de Código

### Estructura de Commits
- `feat:` nuevas funcionalidades
- `fix:` corrección de bugs
- `docs:` documentación
- `style:` formato de código
- `refactor:` refactorización
- `test:` tests
- `chore:` tareas de mantenimiento

### Nomenclatura
- **Archivos**: camelCase para archivos TS/JS, kebab-case para componentes
- **Componentes**: PascalCase
- **Variables**: camelCase
- **Constantes**: UPPER_SNAKE_CASE
- **Funciones**: camelCase con verbos descriptivos

### Estructura de Carpetas
- Seguir la arquitectura modular en cada proyecto
- Separar lógica de presentación
- Usar index.ts para exports limpios
- Mantener consistencia entre proyectos

## 🔍 Debugging y Troubleshooting

### Herramientas de Debug
- **React DevTools**: Para frontend debugging
- **Apollo DevTools**: Para debugging GraphQL
- **Expo DevTools**: Para mobile debugging
- **MongoDB Compass**: Para debug de base de datos

### Logs y Monitoreo
- Usar `console.log` estructurado con niveles
- Configurar Sentry para producción
- Implementar health checks en todos los servicios

## 📚 Recursos Adicionales

### Documentación Detallada
Cada proyecto tiene documentación específica en su directorio `docs/`:
- `ARCHITECTURE.md` - Arquitectura del proyecto
- `DEVELOPMENT.md` - Guía de desarrollo
- `DEPLOYMENT.md` - Guía de deployment
- `API.md` - Documentación de API (cuando aplique)

### Links Útiles
- [Documentación NestJS](https://docs.nestjs.com/)
- [Documentación React](https://react.dev/)
- [Documentación Expo](https://docs.expo.dev/)
- [Documentación GraphQL](https://graphql.org/learn/)

## ⚠️ Notas Importantes

### Cosas a Recordar
1. **Siempre ejecutar linting** antes de hacer commits
2. **Verificar types** en proyectos TypeScript
3. **Correr tests** antes de hacer push
4. **Actualizar documentación** con cambios significativos
5. **Usar QA environment** para testing de mobile
6. **Verificar health checks** después de deploys

### Performance
- Usar lazy loading en componentes React
- Implementar paginación en listas largas
- Optimizar queries GraphQL
- Usar CDN para assets estáticos
- Implementar caching apropiado

### Seguridad
- Nunca commitear credenciales o secrets
- Validar inputs en frontend y backend
- Usar HTTPS en todos los environments
- Implementar rate limiting
- Mantener dependencias actualizadas

---

**Última actualización**: 2 de julio de 2025
**Versión**: 1.0.0
**Mantenido por**: Equipo de desarrollo Trivance