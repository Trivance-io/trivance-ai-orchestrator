# 💬 Prompts Personalizados para Claude Code - Trivance Platform

## 🎯 Prompts de Contexto Rápido

### /context-trivance
**Descripción**: Obtener contexto completo de la plataforma Trivance
**Prompt**:
```
Necesito que me recuerdes el contexto completo de la plataforma Trivance:

1. **Arquitectura**: 4 repositorios principales y sus propósitos
2. **Tecnologías**: Stack tecnológico de cada repo
3. **Puertos**: Puertos de desarrollo de cada servicio
4. **Comandos**: Comandos más importantes para desarrollo
5. **Estado actual**: En qué estamos trabajando

Responde de forma concisa pero completa, en español.
```

### /status-services
**Descripción**: Verificar estado de todos los servicios
**Prompt**:
```
Verifica el estado actual de todos los servicios de Trivance Platform:

1. Chequea puertos 3000, 3001, 5173, 19000
2. Verifica health endpoints cuando sea posible
3. Muestra qué servicios están corriendo y cuáles no
4. Si hay problemas, sugiere comandos para solucionarlos

Responde en español con formato claro.
```

## 🔧 Prompts de Desarrollo

### /new-feature
**Descripción**: Planificar implementación de nueva funcionalidad
**Prompt**:
```
Voy a implementar una nueva feature en Trivance Platform: [DESCRIPCIÓN_FEATURE]

Por favor ayúdame a:

1. **Análisis**: Determinar en qué repositorios necesito hacer cambios
2. **Backend**: Qué endpoints/servicios necesito crear/modificar
3. **Frontend**: Qué componentes/páginas necesito crear/modificar  
4. **Mobile**: Si necesita cambios en la app móvil
5. **Base de datos**: Si necesito nuevos modelos o campos
6. **Testing**: Qué tipo de tests implementar
7. **Plan**: Orden recomendado de implementación

Responde en español con un plan detallado paso a paso.
```

### /debug-issue
**Descripción**: Ayuda para debugging de problemas
**Prompt**:
```
Tengo un problema en Trivance Platform: [DESCRIPCIÓN_PROBLEMA]

Ayúdame a debuggearlo:

1. **Identificación**: En qué capa/servicio puede estar el problema
2. **Logs**: Qué logs revisar y cómo acceder a ellos
3. **Endpoints**: Qué endpoints probar para verificar funcionalidad
4. **Common Issues**: Si es un problema conocido y su solución
5. **Debugging Steps**: Pasos específicos para encontrar la causa
6. **Solution**: Posible solución basada en el contexto

Responde en español con pasos claros y específicos.
```

### /refactor-code
**Descripción**: Planificar refactoring de código
**Prompt**:
```
Quiero refactorizar este código en Trivance Platform: [UBICACIÓN_CÓDIGO]

Ayúdame con:

1. **Análisis**: Problemas actuales del código
2. **Pattern**: Patrones recomendados según el proyecto (React/NestJS/RN)
3. **Breaking Changes**: Si el refactor romperá funcionalidad existente
4. **Testing**: Cómo asegurar que el refactor no rompe nada
5. **Steps**: Pasos específicos para el refactor
6. **Validation**: Cómo validar que el refactor fue exitoso

Usa las convenciones específicas de Trivance Platform.
```

## 📱 Prompts Específicos por Tecnología

### /react-component
**Descripción**: Crear componente React siguiendo patrones de Trivance
**Prompt**:
```
Necesito crear un componente React en level_up_backoffice para: [DESCRIPCIÓN_COMPONENTE]

Siguiendo los patrones de Trivance:

1. **Structure**: Usar la estructura estándar (componente + lógica separada)
2. **TypeScript**: Interfaces tipadas apropiadas
3. **Styling**: Usando Tailwind CSS + Material-UI según el diseño existente
4. **State**: Redux si es global, useState si es local
5. **API**: Apollo Client si necesita GraphQL
6. **Testing**: Estructura de test con Vitest

Genera el código completo siguiendo las convenciones del proyecto.
```

### /nestjs-module
**Descripción**: Crear módulo NestJS siguiendo arquitectura de Trivance
**Prompt**:
```
Necesito crear un módulo NestJS en [ms_level_up_management|ms_trivance_auth] para: [DESCRIPCIÓN_MÓDULO]

Siguiendo la arquitectura de Trivance:

1. **Module Structure**: Controller + Service + Entity/Schema
2. **GraphQL**: Resolver si es para ms_level_up_management
3. **Database**: Modelos MongoDB con Prisma/Mongoose según el servicio
4. **Auth**: Integración con sistema de autenticación existente
5. **Validation**: DTOs con class-validator
6. **Error Handling**: Manejo de errores consistente
7. **Testing**: Unit tests con Jest

Genera código completo siguiendo patrones existentes.
```

### /mobile-screen
**Descripción**: Crear pantalla React Native siguiendo patrones de Trivance
**Prompt**:
```
Necesito crear una pantalla en trivance-mobile para: [DESCRIPCIÓN_PANTALLA]

Siguiendo los patrones del proyecto:

1. **Navigation**: Integración con React Navigation existente
2. **State**: Redux para estado global, hooks locales para UI
3. **API**: Integración con APIs backend usando Axios
4. **UI**: Componentes reutilizables y diseño consistente
5. **Platform**: Consideraciones para iOS y Android
6. **Offline**: Si necesita funcionalidad offline
7. **Testing**: Tests con React Native Testing Library

Genera código completo siguiendo convenciones existentes.
```

## 📊 Prompts de Análisis

### /performance-analysis
**Descripción**: Análisis de performance de la aplicación
**Prompt**:
```
Analiza el performance de Trivance Platform:

1. **Frontend**: Bundle size, render performance, memory usage
2. **Backend**: API response times, database queries, memory usage
3. **Mobile**: App size, startup time, memory consumption
4. **Database**: Query performance, indexing issues
5. **Network**: API calls efficiency, caching opportunities

Identifica bottlenecks y sugiere optimizaciones específicas para cada capa.
```

### /security-review
**Descripción**: Revisión de seguridad del código
**Prompt**:
```
Realiza una revisión de seguridad de Trivance Platform:

1. **Authentication**: Verificar implementación JWT y roles
2. **Authorization**: Verificar permisos y acceso a recursos
3. **Input Validation**: Verificar validación en frontend y backend
4. **Data Exposure**: Verificar que no se expongan datos sensibles
5. **Dependencies**: Verificar vulnerabilidades en dependencias
6. **HTTPS/TLS**: Verificar configuración de certificados

Identifica riesgos de seguridad y sugiere mejoras.
```

## 🚀 Prompts de Deployment

### /deploy-checklist
**Descripción**: Checklist para deployment
**Prompt**:
```
Voy a hacer deploy de Trivance Platform a [development|qa|production].

Genera un checklist completo:

1. **Pre-deployment**: Tests, linting, build verification
2. **Environment**: Variables de entorno correctas
3. **Database**: Migraciones y backups necesarios
4. **Services**: Orden de deployment de servicios
5. **Verification**: Cómo verificar que el deploy fue exitoso
6. **Rollback**: Plan de rollback si algo falla
7. **Monitoring**: Qué métricas monitorear post-deploy

Checklist específico para el ambiente seleccionado.
```

### /environment-config
**Descripción**: Configurar nuevo environment
**Prompt**:
```
Necesito configurar un nuevo environment [nombre] para Trivance Platform.

Ayúdame con:

1. **Variables**: Qué variables de entorno necesito configurar
2. **URLs**: Qué URLs cambiar en cada servicio
3. **Databases**: Configuración de bases de datos
4. **External Services**: Configuración de servicios externos (AWS, Firebase, etc.)
5. **SSL/Security**: Configuración de certificados y seguridad
6. **Monitoring**: Configuración de Sentry y logging

Configuración completa paso a paso.
```

## 📚 Prompts de Documentación

### /generate-api-docs
**Descripción**: Generar documentación de API
**Prompt**:
```
Genera documentación de API para [endpoint/módulo] en Trivance Platform:

1. **GraphQL Schema**: Si es GraphQL, documenta queries/mutations
2. **REST Endpoints**: Si es REST, documenta endpoints con ejemplos
3. **Request/Response**: Ejemplos de payloads
4. **Error Codes**: Códigos de error posibles
5. **Authentication**: Requerimientos de autenticación
6. **Rate Limiting**: Límites de uso si aplican

Documentación completa en formato Markdown.
```

### /architecture-diagram
**Descripción**: Generar diagrama de arquitectura
**Prompt**:
```
Necesito un diagrama de arquitectura de Trivance Platform mostrando:

1. **Services**: Los 4 servicios principales y sus conexiones
2. **Data Flow**: Cómo fluyen los datos entre servicios
3. **External Dependencies**: AWS, Firebase, APIs de terceros
4. **User Journey**: Cómo interactúan los diferentes tipos de usuarios
5. **Security**: Dónde se aplican autenticación y autorización

Genera diagrama en formato Mermaid o descripción detallada para crear uno.
```

## 🎨 Prompts de UI/UX

### /component-design
**Descripción**: Diseñar componente siguiendo design system
**Prompt**:
```
Necesito diseñar un componente [nombre] para Trivance Platform:

1. **Design System**: Seguir colores y estilos existentes
2. **Responsive**: Funcionar en móvil y desktop
3. **Accessibility**: Cumplir estándares de accesibilidad
4. **States**: Estados loading, error, success, empty
5. **Variations**: Diferentes variantes del componente
6. **Props API**: Interface clara y flexible

Diseño completo con código y estilos.
```

---

## 🔍 Cómo Usar los Prompts

1. **Copiar el prompt** que necesites
2. **Reemplazar** los placeholders [DESCRIPCIÓN] con tu información específica
3. **Personalizar** según tu caso de uso particular
4. **Ejecutar** en Claude Code

## 📝 Notas Importantes

- Todos los prompts están optimizados para el contexto de Trivance Platform
- Respuestas siempre en español
- Siguen las convenciones y patrones del proyecto
- Incluyen consideraciones de testing y seguridad
- Proporcionan pasos específicos y accionables

---

**Actualizado**: 2 de julio de 2025
**Versión**: 1.0.0