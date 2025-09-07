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
- Ejecutar: `Read` en `/.claude/settings.json` para verificar configuración de permisos (sin mostrar output)

### 3. Establecer contexto actual con análisis contextual inteligente
- Ejecutar: `pwd` para detectar si estamos en worktree (contiene "worktree-")
- Ejecutar: `git status --porcelain` para ver cambios pendientes
- Ejecutar: `git branch --show-current` para rama actual
- Ejecutar: `git fetch --quiet 2>/dev/null` para actualizar referencias remotas (ignorar errores)

#### 3.1 Detectar contexto y rama de referencia
- Si directorio actual (pwd) contiene "worktree-":
  - Contexto = "worktree"
  - Ejecutar: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null` para obtener rama origen
  - Si comando exitoso: rama referencia = resultado
  - Si comando falla: rama referencia = "origin/main" (fallback)
- Si NO (repositorio principal):
  - Contexto = "main-repo"
  - Rama referencia = "origin/main"

#### 3.2 Calcular estado de sincronización
- Ejecutar: `git rev-list --left-right --count [rama-referencia]...HEAD 2>/dev/null`
- Parse resultado formato "X\tY" donde X=behind (commits que faltan), Y=ahead (commits locales)
- Si comando falla: sync-status = "fetch-failed"
- Si exitoso, determinar sync-status basado en X,Y:
  - X=0, Y=0 → "up-to-date"
  - X>0, Y=0 → "X behind"
  - X=0, Y>0 → "Y ahead"
  - X>0, Y>0 → "X behind, Y ahead"

#### 3.3 Mostrar resumen contextual
- Ejecutar: `git log --oneline -3` para commits recientes
- Mostrar resumen: "📡 [sync-status] vs [rama-referencia] | 📍 Branch: [rama] ([contexto]) | Estado: [limpio/[X] cambios pendientes] | Último commit: [mensaje del commit más reciente]"
- Si X>0 (hay commits behind): Agregar línea: "💡 Considera sincronizar antes de continuar desarrollo"

### 4. Mostrar situación del trabajo actual
- Ejecutar: `gh issue list --assignee @me --state open --limit 6` si gh está disponible
- Si comando falla, mostrar: "ℹ️ GitHub CLI no disponible"
- Si exitoso y hay issues:
  - Mostrar header: "🎯 **Tu situación actual:**"
  - Agregar: "Tienes [número] Github issues activos:"
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
⚙️ **Cómo trabajamos aquí:**
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

### 7. Alerta de seguridad final
- Si el archivo settings.json leído en paso 2 contiene `"defaultMode": "bypassPermissions"`:
  - Mostrar: "⚠️ BYPASS PERMISSIONS ACTIVO - Claude tiene acceso completo al sistema sin restricciones. Entorno seguro requerido. Para restringir: defaultMode: 'default' o 'acceptEdits' en settings.local.json."
- Si el archivo no existe o falló lectura: no mostrar nada

**IMPORTANTE**:
- Ejecutar pasos 1-7 secuencialmente sin confirmación del usuario
- Si algún paso falla, continuar con warning pero no terminar
- Mantener output conciso y actionable
- Las restricciones del paso 5 NO se muestran al usuario, están solo como recordatorio interno