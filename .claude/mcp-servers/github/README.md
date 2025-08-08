# GitHub MCP Server

Conecta Claude Code con GitHub para gestionar repos, issues, y PRs directamente.

## Instalación

```bash
cd trivance-dev-config
./.claude/mcp-servers/github/setup.sh
```

**⚠️ DESPUÉS DE LA INSTALACIÓN: Configurar Token de GitHub**

El script te pedirá un GitHub Personal Access Token. Para generarlo:

1. Ve a: **Settings > Developer settings > Personal access tokens > Tokens (classic)**
   - Directo: https://github.com/settings/tokens
2. Click **'Generate new token (classic)'**
3. En **Note**: `Claude MCP - [tu-nombre]`
4. **Expiration**: `90 days` (recomendado)
5. Selecciona estos **scopes**:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `read:org` (Read org and team membership)  
   - ✅ `read:user` (Read user profile data)
6. Click **'Generate token'**
7. **⚠️ COPIA EL TOKEN INMEDIATAMENTE** (solo se muestra una vez)
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

## Ejemplos de uso

```
• "Revisa el PR #123 y sugiere mejoras"
• "Crea una branch feature/nueva-funcionalidad"
• "Busca issues relacionados con autenticación"
• "Analiza el código de la función login()"
```

## Configuración Manual

**Template de configuración:** Ver `.claude/mcp-servers/.mcp.example.json` para estructura completa de MCP servers (GitHub + otros futuros).

**Si el script falla o no configura el token automáticamente:**

```bash
# Configurar token manualmente
claude mcp update github -e GITHUB_PERSONAL_ACCESS_TOKEN="tu_token_aquí"

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
**Docker no responde** → Iniciar Docker Desktop