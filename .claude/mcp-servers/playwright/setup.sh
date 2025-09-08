#!/usr/bin/env bash
set -e

# Verificar que estamos en un workspace con .claude
if [[ ! -d ".claude" ]]; then
    echo "Error: Debe ejecutarse desde la raíz del workspace (donde está .claude/)"
    exit 1
fi

# 1. Verificar e instalar Playwright si no existe
echo "Verificando Playwright..."
if ! npx playwright --version >/dev/null 2>&1; then
    echo "Playwright no encontrado. Instalando..."
    npm init playwright@latest
else
    echo "Playwright ya está instalado"
fi

# 2. Verificar y crear .mcp.json si no existe
echo "Verificando configuración MCP..."
if [[ ! -f ".mcp.json" ]]; then
    echo "Creando .mcp.json..."
    cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    }
  }
}
EOF
    echo "Archivo .mcp.json creado"
else
    echo "Archivo .mcp.json ya existe"
fi

echo "Setup completado. Reinicia Claude Code para aplicar los cambios."