#!/usr/bin/env bash
set -e

cleanup() {
    [[ $? -ne 0 ]] && claude mcp remove github 2>/dev/null || true
}
trap cleanup EXIT
command -v claude >/dev/null || { echo "Claude Code no instalado: https://claude.ai/code"; exit 1; }
command -v docker >/dev/null || { echo "Docker no instalado: https://docker.com/get-started"; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker no ejecutándose. Iniciar Docker Desktop"; exit 1; }
command -v curl >/dev/null || { echo "curl requerido para validación"; exit 1; }

echo "Generar token: https://github.com/settings/tokens"
echo "Permisos: repo, read:org, read:user"
read -s -p "Token: " GITHUB_TOKEN
echo

[[ -z "$GITHUB_TOKEN" ]] && { echo "Token vacío"; exit 1; }

echo "Validando token..."
HTTP_STATUS=$(curl -s -w "%{http_code}" --max-time 10 -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user -o /dev/null 2>/dev/null)
if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "Token inválido o sin permisos (HTTP $HTTP_STATUS)"
    exit 1
fi

claude mcp remove github 2>/dev/null || true
claude mcp add -s project github --env GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN" \
  --env GITHUB_TOOLSETS="context,issues,pull_requests" \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN -e GITHUB_TOOLSETS \
  ghcr.io/github/github-mcp-server
claude mcp list | grep -q "github" && {
    echo "GitHub MCP Server configurado"
    echo "Reiniciar Claude Code para aplicar los cambios"
} || {
    echo "Error en verificación"
    exit 1
}