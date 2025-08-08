#!/usr/bin/env bash
set -e

# Cleanup en caso de error
cleanup() {
    [[ $? -ne 0 ]] && claude mcp remove github 2>/dev/null || true
}
trap cleanup EXIT

# Verificar prerequisitos
command -v claude >/dev/null || { echo "❌ Claude Code no instalado: https://claude.ai/code"; exit 1; }
command -v docker >/dev/null || { echo "❌ Docker no instalado: https://docker.com/get-started"; exit 1; }
docker info >/dev/null 2>&1 || { echo "❌ Docker no ejecutándose. Iniciar Docker Desktop"; exit 1; }
command -v curl >/dev/null || { echo "❌ curl requerido para validación"; exit 1; }

# Configurar token PRIMERO
echo "🔑 Generar token: https://github.com/settings/tokens"
echo "Permisos: repo, read:org, read:user"
read -p "Token: " GITHUB_TOKEN

# Validar token
[[ -z "$GITHUB_TOKEN" ]] && { echo "❌ Token vacío"; exit 1; }

echo "🔍 Validando token..."
HTTP_STATUS=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user -o /dev/null)
if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "❌ Token inválido o sin permisos (HTTP $HTTP_STATUS)"
    exit 1
fi

# Configurar MCP con token (sin TOOLSETS - permisos controlados por PAT)
claude mcp remove github 2>/dev/null || true
claude mcp add -s project github --env GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN \
  ghcr.io/github/github-mcp-server

# Verificar instalación
claude mcp list | grep -q "github" && {
    echo ""
    echo "✅ GitHub MCP Server configurado exitosamente"
    echo ""
    echo "🔄 IMPORTANTE: Debes reiniciar Claude Code para aplicar los cambios"
    echo "   • Cierra completamente Claude Code (Cmd+Q en Mac)"
    echo "   • Vuelve a abrir Claude Code"
    echo "   • Luego usa: /mcp para acceder a GitHub"
    echo ""
    echo "⚠️  Sin reiniciar, el servidor MCP no funcionará correctamente"
} || {
    echo "❌ Error en verificación"
    exit 1
}