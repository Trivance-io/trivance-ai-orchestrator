# GitHub Actions Workflow Test

Este archivo es una prueba para validar que los workflows de GitHub Actions están funcionando correctamente.

## Workflows que deben ejecutarse:

### 1. Claude Code Review (`claude-code-review.yml`)
- **Trigger**: Pull Request opened/synchronize
- **Modelo**: claude-opus-4-1-20250805
- **Herramientas**: MCP GitHub tools para review automatizado
- **Permisos**: contents:read, pull-requests:write, issues:read, id-token:write

### 2. Security Review (`security.yml`) 
- **Trigger**: Pull Request
- **Modelo**: claude-opus-4-1-20250805  
- **Permisos**: contents:read, pull-requests:write, id-token:write

## Test Code Sample

```javascript
// Este código JavaScript simple debería disparar el clean_code hook
function testFunction(param1, param2) {
    return param1 + param2;
}

const result = testFunction(1, 2);
console.log(result);
```

## Validaciones esperadas:

- ✅ Workflows se ejecutan sin errores de argumentos inválidos
- ✅ Permisos OIDC funcionan correctamente  
- ✅ MCP GitHub integration responde
- ✅ Claude realiza review automático
- ✅ Security scanner completa sin fallos

**Status**: TESTING - Este archivo será eliminado después de la validación.