---
description: "Organizar commits con mejores prácticas y subir a GitHub"
argument-hint: "Descripción del cambio (ej: 'add user authentication')"
allowed-tools: ["Bash", "Read", "TodoWrite"]
---

# Flujo Git Optimizado

## 1. Estado Actual
**Examina todos los repositorios del workspace**, o del repositorio actual segun sea al caso, verifica los cambios que existen en git, se transparente con el usuario al decirle cuales cambios estas revisando.

## 2. Auditoría de Seguridad OBLIGATORIA

**Ejecutar ANTES de cualquier commit:**
```bash
# Detectar secrets/credenciales
grep -r -i -E "(password|token|secret|key|api_key)" . --exclude-dir=.git
grep -r -E "DATABASE_URL=|JWT_SECRET=|MONGODB_URI=" . --exclude-dir=.git

# Detectar rutas hardcodeadas
grep -r "/Users/" . --exclude-dir=.git
grep -r "C:\\Users" . --exclude-dir=.git

# Verificar archivos sensibles
git ls-files | grep -E "\.(env|secret|key)$"

# Detectar archivos grandes (>5MB)
find . -type f -size +5M | grep -v .git
```
**SI CUALQUIER VALIDACIÓN FALLA: DETENER**

## 3. Análisis de Cambios
Tipos de commit (Conventional Commits):
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bugs
- `docs:` Cambios en documentación
- `style:` Formateo, espacios
- `refactor:` Refactoring de código
- `test:` Agregar o corregir tests
- `chore:` Tareas de mantenimiento

## 4. Validaciones Técnicas

**Ejecutar si disponible:**
```bash
npm run lint 2>/dev/null || echo "Lint no disponible"
npm run typecheck 2>/dev/null || echo "TypeCheck no disponible"

# Validar JSON
[ -f package.json ] && node -e "JSON.parse(require('fs').readFileSync('package.json'))"
[ -f tsconfig.json ] && node -e "JSON.parse(require('fs').readFileSync('tsconfig.json'))"
```

## 5. Tu Tarea
Basado en "$ARGUMENTS":

1. **Crear commits organizados**
2. **Formato:**
   ```
   feat(auth): add user login validation
   
   - Add email format validation
   - Add password strength requirements
   ```

## 6. Flujo de Ejecución
1. **Auditoría automática** (pasos 2-4)
2. **Stage archivos** apropiados
3. **Crear commits** con conventional commits
4. **Mostrar resumen** completo:
   - ✅ Auditoría seguridad: PASADA
   - ✅ Validaciones técnicas: PASADAS
   - 📋 Archivos: [lista]
   - 🚀 Destino: [rama]
5. **Pedir confirmación**: "¿CONFIRMAS push a GitHub? (yes/no)"
6. **Solo con "yes"**: ejecutar `git push`