# GitHub MCP Server

Conecta Claude Code con GitHub para gestionar repos, issues, y PRs directamente desde el entorno de desarrollo.

## Instalación Automática

```bash
./.claude/mcp-servers/github/setup.sh
```

El script automatizado:
1. ✅ Valida prerequisitos (Docker, curl)
2. 🔐 Solicita y valida tu GitHub Personal Access Token
3. 📋 Crea archivo `.mcp.json` en la raíz del proyecto
4. 🔧 Configura automáticamente el MCP server

## Configuración del Token

**Generar GitHub Personal Access Token:**

1. Ve a: **Settings > Developer settings > Personal access tokens > Tokens (classic)**
   - Directo: https://github.com/settings/tokens
2. Click **'Generate new token (classic)'**
3. En **Note**: `Claude MCP - [tu-nombre]`
4. **Expiration**: `90 days` (recomendado)
5. **Selecciona estos scopes:**
   - ✅ `repo` - Acceso completo a repositorios
   - ✅ `read:org` - Leer información de organizaciones
   - ✅ `read:user` - Leer perfil de usuario
   - ✅ `actions:read` - Leer resultados de GitHub Actions
6. Click **'Generate token'**
7. **Copia el token** (solo se muestra una vez)

⚠️ **Usar token Classic, NO Fine-grained** para compatibilidad completa con MCP.

## Verificación Post-Instalación

**1. Verificar archivo de configuración:**
```bash
ls -la .mcp.json    # Debe existir en raíz del proyecto
```

**2. Reiniciar Claude Code:**
- Cierra completamente Claude Code
- Abre nuevamente desde la raíz del proyecto

**3. Verificar conexión activa:**
En Claude Code:
```
¿Tienes acceso a GitHub?
```

## Funcionalidades Disponibles

Con MCP GitHub activo, puedes:

- 📖 **Revisar PRs**: "Analiza el PR #123 y sugiere mejoras"
- 🐛 **Gestionar Issues**: "Busca issues relacionados con autenticación"  
- 🔍 **Análisis de código**: "Examina el archivo src/auth.js"
- 📊 **Revisar CI/CD**: "¿Qué tests fallaron en el último workflow?"

## Integración con GitHub Actions

Los workflows configurados en `.github/workflows/` ya incluyen permisos específicos MCP:

- `claude-code-review.yml` - Review automático de PRs
- `claude.yml` - Respuesta a mentions @claude
- `security.yml` - Análisis de seguridad

## Troubleshooting

**"Token inválido"** → Verificar que incluye todos los scopes requeridos  
**"Docker no responde"** → Iniciar Docker Desktop  
**"Archivo no encontrado"** → Ejecutar script desde raíz del proyecto  
**"Claude no ve GitHub"** → Reiniciar Claude Code completamente  

## Configuración Manual (Solo si Script Falla)

Si el script automatizado falla:

```bash
# 1. Copiar configuración
cp .claude/mcp-servers/.mcp.example.json ./.mcp.json

# 2. Editar manualmente el token
# Reemplazar: github_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# Con tu token real en .mcp.json

# 3. Reiniciar Claude Code
```

**Validar configuración manual:**
```bash
grep GITHUB_PERSONAL_ACCESS_TOKEN .mcp.json
# Debe mostrar tu token (no la plantilla XXX)