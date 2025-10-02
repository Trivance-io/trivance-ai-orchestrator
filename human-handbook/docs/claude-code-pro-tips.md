# Claude Code Pro-Tips

_Guía técnica para fluir naturalmente con Claude Code_

## ⚡ Quick Reference

| Acción                        | Comando/Atajo         |
| ----------------------------- | --------------------- |
| Razonamiento básico           | `thinking`            |
| Razonamiento profundo         | `think hard`          |
| Razonamiento más profundo     | `think harder`        |
| Razonamiento máximo           | `ultrathink`          |
| Toggle razonamiento           | `Tab`                 |
| Referencia archivo/directorio | `@path`               |
| Revertir cambios              | `ESC ESC` o `/rewind` |
| Cambiar modo de permisos      | `Shift+Tab`           |

## 🧠 Control de Razonamiento Extendido

Claude Code incluye un sistema de razonamiento extendido con niveles progresivos de profundidad.

### Niveles de Razonamiento

| Nivel            | Descripción                                         |
| ---------------- | --------------------------------------------------- |
| **thinking**     | Razonamiento básico para problemas estándar         |
| **think hard**   | Razonamiento profundo para problemas complejos      |
| **think harder** | Razonamiento más profundo para análisis complejos   |
| **ultrathink**   | Razonamiento máximo para decisiones arquitectónicas |

### Activación

**Explícita**: Incluye el trigger correspondiente en tu prompt

```bash
# Razonamiento básico
thinking necesito validar esta lógica

# Razonamiento profundo
think hard ayúdame a diseñar esta arquitectura

# Razonamiento más profundo
think harder optimiza esta query

# Razonamiento máximo
ultrathink analiza esta optimización de performance
```

**Por toggle**: Presiona `Tab` para activar/desactivar razonamiento extendido durante la sesión

### Cuándo Usar Cada Nivel

| Nivel            | Caso de Uso                                                |
| ---------------- | ---------------------------------------------------------- |
| **thinking**     | Debugging, refactoring simple, code review                 |
| **think hard**   | Diseño de features, optimización de queries                |
| **think harder** | Refactoring complejo, análisis de dependencias             |
| **ultrathink**   | Arquitectura de sistemas, análisis de codebase desconocida |

## 📁 Referencias Rápidas con @

Usa `@` para referenciar archivos o directorios sin esperar a que Claude los lea.

### Sintaxis

**Archivo único:**

```text
@src/utils/auth.js revisa esta implementación
```

**Directorio completo:**

```text
@src/components analiza todos los componentes
```

**Múltiples referencias:**

```text
compara @src/old-auth.js con @src/new-auth.js
```

### Ventajas

- **Inmediato** - No esperas a que Claude lea el archivo
- **Preciso** - Referencias exactas sin ambigüedad
- **Eficiente** - Funciona con scope de git

## ⏮️ Navegación Temporal y Checkpointing

Claude Code guarda automáticamente checkpoints antes de cada edición.

### Revertir Cambios

**Método 1:** `ESC ESC` (presiona ESC dos veces)
**Método 2:** `/rewind`

Ambos métodos abren el menú de rewind con tres opciones:

**Conversation only**

- Retrocede a un mensaje anterior
- Mantiene cambios de código

**Code only**

- Revierte cambios en archivos
- Mantiene historial de conversación

**Both code and conversation**

- Restaura ambos a un punto anterior
- Reset completo a checkpoint

### Casos de Uso

**Explorar implementación alternativa**

```bash
[implementación A]
# ESC ESC → Code only (revertir)
[implementación B]
```

**Recuperar después de error**

```bash
[cambios incorrectos]
# ESC ESC → Both (reset completo)
```

**Iterar en features**

```bash
[versión 1]
# ESC ESC → Conversation only (mantener código, nueva dirección)
```

### Limitaciones

- No trackea cambios en bash commands
- Solo archivos editados en la sesión actual
- No reemplaza version control (git)

---

## 🔄 Gestión de Conversaciones

### La Regla del Ciclo Negativo

**Problema**: Cuando una interacción da resultados no deseados, corregir repetidamente al LLM crea un **ciclo negativo de retroalimentación**.

**Por qué sucede**:

- El contexto completo (incluyendo errores) se usa como entrada
- Cada corrección añade más "ruido" al contexto
- El LLM persevera en el error al intentar "complacer" las correcciones previas

### La Regla de las 3 Correcciones

```text
Intento 1: Resultado incorrecto → Corregir
Intento 2: Aún incorrecto → Corregir con más contexto
Intento 3: Sigue incorrecto → STOP
```

**En el intento 3, no sigas corrigiendo. En su lugar:**

1. **Usa /rewind** si el error fue reciente
2. **Inicia nueva conversación** con contexto claro desde cero
3. **Reformula el problema** - quizás la instrucción original fue ambigua

### Anti-Pattern: "Maldecir" al LLM

**❌ No hagas esto:**

```text
"No, eso está mal"
"Te dije que no hicieras eso"
"Otra vez lo mismo, arréglalo"
"¿Por qué no entiendes?"
```

**✅ Haz esto:**

```text
ESC ESC → Both code and conversation
[Nueva conversación]
"Necesito implementar X. Contexto: Y. Restricciones: Z."
```

### Cuándo Empezar de Nuevo

**Indicadores de que necesitas nueva conversación**:

- 3+ correcciones sin progreso
- El LLM repite el mismo error
- Las respuestas se vuelven "confusas" o inconsistentes
- Cambio significativo de dirección en el problema

**Template para nueva conversación:**

```text
ultrathink necesito [objetivo claro]

Contexto:
- [información relevante]
- [restricciones conocidas]

Intentos previos fallaron porque:
- [razón específica]

Enfoque esperado:
- [dirección clara]
```

## ⚙️ Control de Permisos

### Modos de Permisos

Claude Code tiene 4 modos de permisos:

| Modo                  | Comportamiento                            |
| --------------------- | ----------------------------------------- |
| **default**           | Pide confirmación para acciones sensibles |
| **acceptEdits**       | Auto-acepta ediciones de archivos         |
| **bypassPermissions** | Bypass total (útil en CI/CD)              |
| **plan**              | Solo planifica, no ejecuta                |

### Cambiar Modo Durante Sesión

**Shift+Tab**: Cicla entre modos de permisos

### Configuración Persistente

En `.claude/settings.json`:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": ["Bash(npm run lint)", "Bash(npm test)"],
    "deny": ["Read(.env)", "WebFetch"]
  }
}
```

### Casos de Uso por Contexto

| Contexto         | Modo Recomendado    | Razón                           |
| ---------------- | ------------------- | ------------------------------- |
| Desarrollo Local | `acceptEdits`       | Flujo rápido sin interrupciones |
| CI/CD            | `bypassPermissions` | Automatización sin prompts      |
| Exploración      | `plan`              | Ver acciones sin ejecutar       |
| Producción       | `default`           | Control y confirmación manual   |

### ⚠️ Precaución con bypassPermissions

`bypassPermissions` elimina **todas** las confirmaciones:

- Útil para automatización
- Peligroso en uso interactivo
- Solo úsalo si confías completamente en el contexto

## 🔍 Análisis de Code Review

### Ver Hallazgos del Bot de Revisión

Después de que Claude Bot revisa tu PR en GitHub, obtén los hallazgos directamente:

```bash
# Para el PR asociado al branch actual
gh pr view --json comments --jq '.comments[] | select(.author.login=="claude") | .body'

# Para un PR específico
gh pr view 210 --json comments --jq '.comments[] | select(.author.login=="claude") | .body'
```

### Workflow de Análisis Objetivo

**1. Fetch findings** (comando arriba)

**2. Análisis conversacional**

```text
Analiza estos hallazgos objetivamente considerando:
- ¿Es técnicamente válido?
- ¿El contexto justifica el cambio?
- ¿El ROI de la corrección es positivo?

¿Qué hallazgos debo corregir?
```

**3. Aplicar correcciones** (proceso natural con Edit/Write)

**4. Commit cambios**

```bash
/git-github:commit "fix(review): resolve PR findings"
```

### Evaluación Crítica de Hallazgos

No todos los hallazgos requieren acción. Evalúa cada uno:

**Preguntas clave:**

- ¿El hallazgo malinterpreta el contexto?
- ¿Sugiere corrección que viola principios del proyecto?
- ¿La complejidad de la corrección > valor agregado?

**Ejemplo:** Un hallazgo sobre "violación de complexity budget" en documentación estática es técnicamente inválido - el presupuesto aplica a código ejecutable, no a líneas de markdown.

### Template de Análisis

```text
ultrathink analiza estos hallazgos del code review

[pegar findings]

Para cada hallazgo, evalúa:
1. Validez técnica
2. Contexto del cambio
3. ROI de corrección

Recomienda qué corregir y qué rechazar con justificación.
```

## 🚀 Workflow Optimization

### Validación de Contexto

Antes de comandos críticos, valida tu contexto:

```bash
git branch    # ¿Estoy en el branch correcto?
pwd           # ¿Estoy en el directorio correcto?
git status    # ¿Tengo cambios pendientes?
```

### Checkpointing Proactivo

Antes de cambios grandes:

```bash
# Checkpoint manual
git add .
git commit -m "checkpoint: antes de refactor X"

# Luego usar Claude Code
[realizar cambios]

# Si falla
git reset --hard HEAD
```

### Uso de Agentes Especializados

Ver `@human-handbook/docs/agents-guide.md` para los 44 agentes disponibles.

Los agentes se invocan usando el **Task tool** con el parámetro `subagent_type`:

```text
# Ejemplo: Delegación a agente especializado
ultrathink delega la revisión de seguridad al agente security-reviewer

# El sistema invocará:
# Task(subagent_type: "security-reviewer", prompt: "análisis detallado")
```

**Agentes comunes:**

- `security-reviewer` - Auditoría de seguridad
- `performance-engineer` - Optimización de performance
- `code-quality-reviewer` - Review de calidad de código

### Uso de Comandos del Ecosistema

Ver `@human-handbook/docs/commands-guide.md` para los 26 comandos disponibles.

**Pattern de desarrollo:**

```bash
# Setup
/utils:session-start
/git-github:worktree:create "feature-X" develop
cd ../worktree-feature-X

# Desarrollo
/SDD-cycle:specify "implementar X"
/SDD-cycle:clarify
/SDD-cycle:plan
/SDD-cycle:tasks
/SDD-cycle:analyze
/SDD-cycle:implement

# Entrega
/git-github:commit "all changes"
/git-github:pr develop
```

## 💡 Tips Finales

### Combinaciones Poderosas

**ultrathink + @directorio**

```text
ultrathink analiza la arquitectura de @src/core
```

**ESC ESC + nueva conversación**

```text
[resultado no deseado]
ESC ESC → Both
[nueva conversación con contexto limpio]
```

**Tab + thinking explícito**

```text
Tab (activar razonamiento)
"ultrathink diseña este sistema"
```

### Flujo Natural

1. **Inicia con contexto** - Usa `@` para archivos relevantes
2. **Ajusta razonamiento** - `Tab` o triggers explícitos según complejidad
3. **Checkpoint antes de cambios** - Protección contra errores
4. **3 intentos máximo** - Después → nueva conversación
5. **Revierte sin miedo** - `ESC ESC` es tu amigo

## 📚 Referencias

### Documentación del Ecosistema

- [**ai-first-workflow.md**](ai-first-workflow.md) - Ecosistema completo PRD → SDD → GitHub
- [**commands-guide.md**](commands-guide.md) - 26 comandos documentados
- [**agents-guide.md**](agents-guide.md) - 44 agentes especializados

### Documentación Oficial

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code/overview)
- [Extended Thinking](https://docs.claude.com/en/docs/build-with-claude/extended-thinking)
- [Checkpointing](https://docs.claude.com/en/docs/claude-code/checkpointing)
- [Settings Reference](https://docs.claude.com/en/docs/claude-code/settings)

---

_Última actualización: 2025-10-02 | Claude Code Pro-Tips_
