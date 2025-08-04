# Guía Práctica de Agentes Claude Code

## 🧠 Agentes Centrales (Siempre Activos)

### `orchestrator-router` - El Cerebro Estratégico
**Propósito**: Coordina automáticamente qué agentes usar para cada tarea compleja.
**Cuándo se activa**: Automáticamente para tareas que requieren múltiples especialistas.
**No necesitas invocarlo directamente** - él decide qué agentes usar y en qué orden.

### `claude-code-expert` - Especialista en Claude Code
**Propósito**: Experto exclusivo en funcionalidades, configuración y troubleshooting de Claude Code.
**Cuándo usarlo**: Preguntas sobre MCP tools, configuración, hooks, debugging de Claude Code.
**Ejemplo**: "¿Cómo configuro un MCP tool?" → Se activa automáticamente.

---

## 💻 Agentes de Desarrollo

### `software-architect` - Diseño y Arquitectura
**Especialización**: Patrones arquitectónicos, diseño de sistemas, decisiones técnicas estratégicas.
**Cuándo usarlo**: Planificación de features complejas, reestructuración de arquitectura, evaluación de tecnologías.
**Ejemplo**: Migrar de monolito a microservicios, diseñar nueva arquitectura de datos.

### `backend-engineer` - APIs y Servidor
**Especialización**: NestJS, GraphQL, PostgreSQL, MongoDB, APIs REST.
**Cuándo usarlo**: Desarrollo de endpoints, optimización de queries, integración con bases de datos.
**Ejemplo**: "Crear API para gestión de usuarios con autenticación JWT".

### `frontend-engineer` - Interfaces de Usuario
**Especialización**: React, TypeScript, Vite, Tailwind CSS, Redux Toolkit.
**Cuándo usarlo**: Componentes React, estado management, optimización de performance frontend.
**Ejemplo**: "Implementar dashboard interactivo con gráficos en tiempo real".

### `mobile-engineer` - Aplicaciones Móviles
**Especialización**: React Native, Expo, optimizaciones móviles, features nativas.
**Cuándo usarlo**: Desarrollo de apps móviles, integración con funcionalidades del dispositivo.
**Ejemplo**: "Implementar cámara con filtros personalizados en React Native".

### `database-architect` - Arquitectura de Datos
**Especialización**: Diseño de esquemas, optimización de queries, migración de datos.
**Cuándo usarlo**: Problemas de performance en BD, diseño de nuevas estructuras de datos.
**Ejemplo**: "Optimizar consultas que tardan >2 segundos en PostgreSQL".

---

## 🔍 Agentes de Calidad

### `qa-engineer` - Testing y Calidad
**Especialización**: Estrategias de testing, cobertura, tests automatizados, pipelines de calidad.
**Cuándo usarlo**: Implementar testing suite, mejorar cobertura, debugging de tests que fallan.
**Ejemplo**: "Crear tests E2E para el flujo completo de checkout".

### `debugger-specialist` - Resolución de Bugs
**Especialización**: Diagnóstico sistemático, análisis de logs, resolución de bugs complejos.
**Cuándo usarlo**: Bugs intermitentes, errores en producción, issues difíciles de reproducir.
**Ejemplo**: "Error 500 aleatorio que solo ocurre los martes por la tarde".

### `code-reviewer` - Revisión de Código
**Especialización**: Best practices, patrones de código, mantenibilidad, refactoring.
**Cuándo usarlo**: Después de implementar features grandes, antes de merge a main.
**Ejemplo**: "Revisar PR con 500+ líneas de cambios en sistema de pagos".

### `security-auditor` - Auditoría de Seguridad
**Especialización**: Vulnerabilidades, OWASP Top 10, seguridad en APIs, autenticación.
**Cuándo usarlo**: Antes de releases, después de cambios en auth, auditorías periódicas.
**Ejemplo**: "Auditar endpoint de pagos antes de integrar con Stripe".

### `performance-optimizer` - Optimización de Performance
**Especialización**: Bottlenecks, profiling, optimización de queries, caching, CDN.
**Cuándo usarlo**: App lenta, high load, optimización antes de lanzamiento.
**Ejemplo**: "Dashboard tarda 5 segundos en cargar, necesita optimización".

---

## 🚀 Agentes de Infraestructura

### `devops-engineer` - Infraestructura y Deploy
**Especialización**: Docker, CI/CD, monitoring, deployment pipelines, escalabilidad.
**Cuándo usarlo**: Setup de infraestructura, problemas de deployment, monitoring.
**Ejemplo**: "Configurar pipeline de CI/CD con deployment automático a staging".

### `mcp-expert` - Integraciones MCP
**Especialización**: Model Context Protocol, integraciones con herramientas externas.
**Cuándo usarlo**: Conectar Claude Code con APIs externas, crear tools personalizados.
**Ejemplo**: "Integrar Claude Code con Slack para notificaciones de deployment".

---

## 🎨 Agentes de Experiencia

### `ux-researcher` - Investigación de Usuarios
**Especialización**: Research de usuarios, testing de usabilidad, análisis de comportamiento, validación de hipótesis.
**Cuándo usarlo**: Entender necesidades del usuario, validar diseños, optimizar experiencia.
**Ejemplo**: "Investigar por qué los usuarios abandonan el checkout en el paso 3".

### `ux-ui-designer` - Diseño de Interfaces
**Especialización**: Diseño de UI/UX, sistemas de diseño, usabilidad, accesibilidad.
**Cuándo usarlo**: Diseñar nuevas interfaces, mejorar usabilidad existente.
**Ejemplo**: "Rediseñar flow de onboarding para mejorar conversión".

### `ai-ml-engineer` - Inteligencia Artificial
**Especialización**: Integración de LLMs, prompt engineering, features de IA.
**Cuándo usarlo**: Agregar capabilities de IA, integrar GPT/Claude en tu app.
**Ejemplo**: "Implementar chatbot inteligente para soporte al cliente".

---

## 🎯 Flujos Típicos de Agentes

### Nueva Feature Completa
```
orchestrator-router → software-architect → [frontend/backend-engineer] → qa-engineer → security-auditor
```

### Bug Crítico en Producción
```
orchestrator-router → debugger-specialist → [relevant-engineer] → qa-engineer
```

### Optimización de Performance
```
orchestrator-router → performance-optimizer → [database/frontend/backend-engineer] → qa-engineer
```

### Launch de Producto
```
orchestrator-router → ux-researcher → ux-ui-designer → security-auditor → performance-optimizer → devops-engineer
```

---

## 🚨 Cuándo NO Usar Agentes Específicos

**❌ No uses directamente si:**
- La tarea es simple (1-2 pasos) → Usa comandos básicos
- No estás seguro cuál usar → Deja que orchestrator-router decida
- Es una pregunta rápida → Pregunta directamente

**✅ Deja que orchestrator-router coordine cuando:**
- Tarea involucra múltiples áreas (UI + API + DB)
- No estás seguro de la complejidad
- Es un proyecto nuevo o grande
- Necesitas expertise de varios dominios

---

## 💡 Tips de Uso de Agentes

### Básicos
- **orchestrator-router se activa automáticamente** para tareas complejas
- **Especialistas trabajan en paralelo** cuando es posible
- **Cada agente mantiene contexto** de lo que hicieron otros

### Avanzados
- **Combina agentes**: security-auditor + performance-optimizer para releases
- **Secuencias lógicas**: architect → engineer → qa → security
- **Trust the process**: Los agentes saben cuándo pasar el testigo

### Enterprise
- **Siempre incluye security-auditor** en features críticas
- **devops-engineer para todo lo relacionado** con infraestructura
- **qa-engineer como checkpoint final** antes de production

*Esta guía cubre los 18 agentes especializados organizados por dominio y frecuencia de uso.*