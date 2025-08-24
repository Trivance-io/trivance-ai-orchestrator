---
allowed-tools: Read(*), Bash(git *), Bash(gh *), LS(*)
description: Configura workspace leyendo CLAUDE.md, verificando estado git y mostrando opciones de desarrollo
---

# Session Start

Configura workspace automáticamente según especificaciones del proyecto.

## Ejecución

Cuando ejecutes este comando, sigue estos pasos:

### 1. Bienvenida e inicialización
Mostrar exactamente este texto:
```
*Configurando workspace...*

```

### 2. Leer configuración del proyecto
- Ejecutar: `Read` en `/CLAUDE.md` para obtener configuraciones específicas

### 3. Establecer contexto actual
- Ejecutar: `pwd` para detectar si estamos en worktree (contiene "worktree-")
- Ejecutar: `git status --porcelain` para ver cambios pendientes
- Ejecutar: `git branch --show-current` para rama actual
- Ejecutar: `git log --oneline -3` para commits recientes
- Mostrar resumen: "📍 Branch: [rama] | Estado: [limpio/[X] cambios pendientes] | Último commit: [mensaje del commit más reciente]"

### 4. Mostrar situación del trabajo actual
- Ejecutar: `gh issue list --assignee @me --state open --limit 6` si gh está disponible
- Si comando falla, mostrar: "ℹ️ GitHub CLI no disponible"
- Si exitoso y hay issues:
  - Mostrar header: "🎯 **Tu situación actual:**"
  - Agregar: "Tienes [número] issues activos:"
  - Para issues 1-5: mostrar cada uno como "• #[número] [título]"
  - Si hay 6 o más: agregar línea "• Ver todos en: github.com/[owner]/[repo]/issues/assigned"
  - Agregar línea vacía después
- Si exitoso y no hay issues: 
  - Mostrar: "🎯 **Tu situación actual:**"
  - Agregar: "✓ No tienes issues asignados - workspace limpio para nuevas tareas"
  - Agregar línea vacía después

### 5. Protocolo de trabajo
**SI NO estamos en worktree (pwd no contiene "worktree-")**, mostrar:

```
⚙️ **Protocolo de trabajo:**
Para desarrollo/issues con código, usamos worktrees para mantener branches limpias:

1. Crear worktree: /worktree:create <purpose> <parent-branch>
2. Cambiar directorio: cd ../worktree-<purpose>
3. Nueva sesión Claude: claude /workflow:session-start

Comandos típicos:
/worktree:create feature-auth develop     # Feature desde develop
/worktree:create fix-payment-bug main     # Hotfix desde main  
/worktree:cleanup worktree-feature-auth   # Limpiar al terminar
```

**SI YA estamos en worktree (pwd contiene "worktree-")**, mostrar:

```
⚙️ **Protocolo de trabajo:**
✓ Ya estás en worktree - listo para desarrollo
```

### 6. Decisión asistida
**SI NO estamos en worktree**, mostrar:

```
🤔 **¿Cuál es tu objetivo para esta sesión?**

- **Desarrollo/bugs/refactor** → ¡Crea worktree primero! ⬆️
- **Solo Análisis/Docs** → Continúa aquí
```

**SI YA estamos en worktree**, mostrar:

```
🤔 **¿Cuál es tu objetivo para esta sesión?**

- **Desarrollo/bugs/refactor** → Continúa aquí ✓
- **Cambiar tarea** → Crea nuevo worktree
```

**IMPORTANTE**:
- Ejecutar pasos 1-6 secuencialmente sin confirmación del usuario
- Si algún paso falla, continuar con warning pero no terminar
- Mantener output conciso y actionable
- Las restricciones del paso 5 NO se muestran al usuario, están solo como recordatorio interno