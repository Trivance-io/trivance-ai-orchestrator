#!/usr/bin/env bash
set -e

# Validaciones de prerequisitos
command -v docker >/dev/null || { echo "❌ Docker no instalado: https://docker.com/get-started"; exit 1; }
docker info >/dev/null 2>&1 || { echo "❌ Docker no ejecutándose. Iniciar Docker Desktop"; exit 1; }
command -v curl >/dev/null || { echo "❌ curl requerido para validación"; exit 1; }

# Verificar que estamos en la raíz del proyecto
if [[ ! -f ".claude/settings.json" ]]; then
    echo "❌ Ejecutar desde la raíz del proyecto (donde está .claude/)"
    exit 1
fi

echo "ℹ️  Configuración GitHub MCP Server"
echo
echo "🔗 Generar token: https://github.com/settings/tokens"
echo
echo "🔐 Permisos requeridos (Classic Token):"
echo "   ✓ repo (acceso completo a repositorios)"
echo "   ✓ read:org (leer organización)"
echo "   ✓ read:user (leer perfil usuario)"
echo "   ✓ actions:read (leer GitHub Actions)"
echo
read -s -p "🔑 Ingresa tu GitHub Personal Access Token: " GITHUB_TOKEN
echo

[[ -z "$GITHUB_TOKEN" ]] && { echo "❌ Token vacío"; exit 1; }

echo
echo "🔎 Validando token..."
HTTP_STATUS=$(curl -s -w "%{http_code}" --max-time 10 -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user -o /dev/null 2>/dev/null)
if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "❌ Token inválido o sin permisos (HTTP $HTTP_STATUS)"
    echo "ℹ️  Verificar que el token tenga todos los permisos requeridos"
    exit 1
fi
echo "✓ Token válido"

# Crear configuración MCP
echo
echo "🔧 Configurando MCP..."
cp .claude/mcp-servers/.mcp.example.json ./.mcp.json

# Reemplazar token en configuración (compatible con macOS y Linux)
if command -v gsed >/dev/null; then
    gsed -i "s/github_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/$GITHUB_TOKEN/g" ./.mcp.json
elif sed --version 2>/dev/null | grep -q GNU; then
    sed -i "s/github_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/$GITHUB_TOKEN/g" ./.mcp.json
else
    sed -i '' "s/github_pat_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/$GITHUB_TOKEN/g" ./.mcp.json
fi

echo "✓ Archivo .mcp.json creado"
echo "✓ Token configurado correctamente"

echo
echo "🚀 Configuración completa"
echo "⚠️  IMPORTANTE: Reinicia Claude Code para aplicar los cambios"
echo "ℹ️  Verificar con: ls -la .mcp.json (debe existir en raíz del proyecto)"