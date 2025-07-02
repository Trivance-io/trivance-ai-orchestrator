# 🧠 Contexto de Memoria para Claude Code - Trivance Platform

## 🎯 Información de Contexto Crítica

### Estado Actual del Proyecto
- **Fecha de última actualización**: 2 de julio de 2025
- **Fase del proyecto**: Desarrollo activo
- **Arquitectura**: Microservicios con frontend React y app móvil
- **Equipo**: Desarrollo full-stack con foco en TypeScript

### Decisiones Arquitecturales Importantes
1. **Separación de servicios**: Auth separado del management por seguridad
2. **GraphQL**: Elegido para API principal por flexibilidad
3. **MongoDB**: Base de datos NoSQL para escalabilidad
4. **Multi-tenant**: Organizaciones aisladas por seguridad
5. **Expo**: Elegido para mobile por facilidad de deployment

## 📋 Patrones de Desarrollo Recurrentes

### Estructura de Componentes React (Frontend)
```typescript
// Patrón estándar para componentes
interface ComponentProps {
  // Props tipadas
}

export const ComponentName: React.FC<ComponentProps> = ({ prop1, prop2 }) => {
  // Hooks locales
  // Lógica del componente
  // Return JSX
}

// Lógica separada en archivos .logic.ts
```

### Estructura de Módulos NestJS (Backend)
```typescript
// Patrón estándar para módulos
@Module({
  imports: [TypeOrmModule.forFeature([Entity])],
  controllers: [EntityController],
  providers: [EntityService],
  exports: [EntityService]
})
export class EntityModule {}
```

### Estructura de Pantallas Mobile
```typescript
// Patrón para pantallas React Native
interface ScreenProps {
  navigation: NavigationProp<any>
  route: RouteProp<any>
}

export const ScreenName: React.FC<ScreenProps> = ({ navigation, route }) => {
  // Hooks de Redux
  // Lógica de pantalla
  // Return JSX
}
```

## 🔄 Workflows Comunes

### Flujo de Nueva Feature
1. **Análisis**: Definir requisitos y alcance
2. **Backend**: Crear/modificar endpoints en management API
3. **Frontend**: Implementar UI en backoffice
4. **Mobile**: Implementar pantallas en app (si aplica)
5. **Testing**: Unit tests + E2E tests
6. **Documentation**: Actualizar docs relevantes

### Flujo de Bug Fix
1. **Reproducción**: Verificar en environment apropiado
2. **Identificación**: Usar logs de Sentry/console
3. **Fix**: Implementar solución en capa correspondiente
4. **Testing**: Verificar fix no rompe funcionalidad existente
5. **Deploy**: QA primero, luego producción

### Flujo de Refactoring
1. **Análisis**: Identificar código a refactorizar
2. **Tests**: Asegurar cobertura de tests existente
3. **Refactor**: Implementar cambios manteniendo API
4. **Verification**: Todos los tests pasan
5. **Documentation**: Actualizar si hay cambios de API

## 🗂️ Ubicaciones de Archivos Importantes

### Configuraciones
- **Environment configs**: `src/config/` en cada proyecto
- **TypeScript configs**: `tsconfig.json` en cada proyecto
- **ESLint configs**: `eslint.config.js` o `.eslintrc.js`
- **Package configs**: `package.json` en cada proyecto

### Documentación
- **Arquitectura**: `docs/ARCHITECTURE.md` en cada proyecto
- **APIs**: `docs/API.md` en proyectos backend
- **Development**: `docs/DEVELOPMENT.md` en cada proyecto
- **Deployment**: `docs/DEPLOYMENT.md` en cada proyecto

### Código Principal
- **Frontend components**: `src/components/` (level_up_backoffice)
- **Frontend pages**: `src/pages/` (level_up_backoffice)
- **Backend modules**: `src/modules/` (ms_* proyectos)
- **Mobile screens**: `src/pages/` (trivance-mobile)
- **Mobile components**: `src/components/` (trivance-mobile)

## 🔐 Información de Seguridad

### Patrones de Autenticación
- **JWT tokens**: Generados en ms_trivance_auth
- **Token validation**: En headers Authorization: Bearer
- **Roles**: super_admin, admin, moderator, user
- **Multi-tenant**: Organización ID en context

### Variables de Entorno Críticas
```bash
# Backend
DATABASE_URL=mongodb://...
JWT_SECRET=...
AWS_ACCESS_KEY_ID=...
SENTRY_DSN=...

# Frontend
VITE_API_URL=...
VITE_GRAPHQL_URL=...

# Mobile
EXPO_PUBLIC_API_URL=...
EXPO_PUBLIC_ENVIRONMENT=...
```

## 🚨 Errores Comunes y Soluciones

### Error: "Cannot connect to database"
**Causa**: MongoDB no está corriendo o URL incorrecta
**Solución**: Verificar connection string y servicio MongoDB

### Error: "GraphQL schema not found"
**Causa**: Schema no generado o build incompleto
**Solución**: `npm run build` en ms_level_up_management

### Error: "Metro bundler failed"
**Causa**: Cache corrupto o dependencias faltantes
**Solución**: `npm run clean` y `npm install` en trivance-mobile

### Error: "ESLint configuration not found"
**Causa**: Config de ESLint no compatible con versión
**Solución**: Verificar `eslint.config.js` y versión de ESLint

### Error: "Cannot resolve module"
**Causa**: Import path incorrecto o dependency faltante
**Solución**: Verificar import paths y `npm install`

## 🎨 Estándares de UI/UX

### Colores de Brand (Trivance)
- **Primario**: Definido en cada proyecto
- **Secundario**: Definido en cada proyecto
- **Success**: Verde estándar
- **Error**: Rojo estándar
- **Warning**: Amarillo estándar

### Componentes Reutilizables
- **Buttons**: Definidos en components/Button
- **Modals**: Definidos en components/Modal
- **Forms**: Usando react-hook-form
- **Tables**: Componentes de tabla customizados
- **Charts**: ApexCharts en frontend, Chart.js como alternativa

## 🔧 Herramientas de Desarrollo

### IDEs Recomendados
- **VS Code**: Con extensiones de TypeScript, React, React Native
- **WebStorm**: Como alternativa para desarrollo full-stack

### Extensiones Útiles
- TypeScript Hero
- Auto Rename Tag
- Bracket Pair Colorizer
- GitLens
- Thunder Client (para API testing)

### Debugging Tools
- **React DevTools**: Para debugging de componentes
- **Apollo DevTools**: Para debugging de GraphQL
- **Redux DevTools**: Para debugging de estado
- **Flipper**: Para debugging de React Native

## 📈 Métricas y Performance

### Métricas Clave
- **Bundle size**: Monitoreado en builds
- **API response time**: Monitoreado con Sentry
- **Mobile app size**: Monitoreado en builds
- **Database query performance**: Monitoreado con logs

### Optimizaciones Importantes
- **Code splitting**: En frontend React
- **Lazy loading**: Para componentes pesados
- **Image optimization**: Para assets móviles
- **Query optimization**: Para GraphQL/MongoDB
- **Caching**: Redis para sessions y data frecuente

## 🔄 Integraciones Externas

### APIs de Terceros
- **AWS S3**: Para almacenamiento de archivos
- **Firebase**: Para notificaciones push y crashlytics
- **Brevo**: Para email marketing
- **ePayco/Wompi**: Para procesamiento de pagos
- **Google Maps**: Para geolocalización

### Webhooks
- **Payment webhooks**: Para confirmación de pagos
- **Email webhooks**: Para tracking de emails
- **Push notification callbacks**: Para confirmación de entrega

## 🎯 Objetivos y Roadmap

### Objetivos Inmediatos
- Completar funcionalidades de donaciones
- Optimizar performance de mobile app
- Implementar analytics avanzados
- Mejorar sistema de notificaciones

### Objetivos a Mediano Plazo
- Implementar ML para recomendaciones
- Expandir integraciones de pago
- Desarrollar API pública
- Implementar sistema de reviews

---

**Nota**: Este contexto se actualiza regularmente. Verificar fecha de última actualización.