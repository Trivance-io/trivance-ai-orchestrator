# GitHub MCP Server

Conecta Claude Code con GitHub para gestionar repos, issues, y PRs directamente.

## Instalación

```bash
./.claude/mcp-servers/github/setup.sh
```

**Configurar Token de GitHub**

El script te pedirá un GitHub Personal Access Token. Para generarlo:

1. Ve a: **Settings > Developer settings > Personal access tokens > Tokens (classic)**
   - Directo: https://github.com/settings/tokens
2. Click **'Generate new token (classic)'**
3. En **Note**: `Claude MCP - [tu-nombre]`
4. **Expiration**: `90 days` (recomendado)
5. Selecciona estos scopes:
   - `repo`
   - `read:org`
   - `read:user`
   - `actions:read`
6. Click **'Generate token'**
7. Copia el token (solo se muestra una vez)
8. Pégalo cuando el script lo solicite

**Nota**: Usar token **Classic** (no Fine-grained) para compatibilidad completa con MCP.

## Verificación

Después de configurar:

```bash
claude mcp list    # Debe mostrar "github"
```

En Claude Code:
```
/mcp               # Debe mostrar conexión activa
```

## Configuración

Toolsets habilitados: `context`, `issues`, `pull_requests`

## Ejemplos de uso

```
• "Revisa el PR #123 y sugiere mejoras"
• "Crea una branch feature/nueva-funcionalidad"
• "Busca issues relacionados con autenticación"
• "Analiza el código de la función login()"
```

## Configuración Manual

Si el script falla:

```bash
# Configurar token y toolsets manualmente
claude mcp update github -e GITHUB_PERSONAL_ACCESS_TOKEN="tu_token_aquí"
claude mcp update github -e GITHUB_TOOLSETS="context,issues,pull_requests"

# Verificar que esté configurado
claude mcp list
```

**Verificar variables de entorno:**
```bash
# El token debe aparecer en la configuración MCP
cat .mcp.json  # Debe mostrar GITHUB_PERSONAL_ACCESS_TOKEN en env
```

## Troubleshooting

**"No MCP servers configured"** → Usar `/mcp` en Claude Code  
**"Permission denied"** → Verificar permisos del token  
**"Authentication failed"** → Reconfigurar token: `claude mcp update github -e GITHUB_PERSONAL_ACCESS_TOKEN="tu_nuevo_token"`  
**"The github_ci MCP server requires 'actions: read' permission"** → Token sin permisos `actions:read` - regenerar token con todos los scopes requeridos  
**"Missing toolset functionality"** → Verificar GITHUB_TOOLSETS: `cat .mcp.json | grep TOOLSETS`  
**Docker no responde** → Iniciar Docker Desktop