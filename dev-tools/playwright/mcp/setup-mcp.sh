#!/usr/bin/env bash
set -e

# Verificar que estamos en un workspace con .claude
if [[ ! -d ".claude" ]]; then
    echo "Error: Debe ejecutarse desde la raíz del workspace (donde está .claude/)"
    exit 1
fi

# Configurar Playwright MCP para Claude Code
echo "Configurando Playwright MCP..."

if [[ ! -f ".mcp.json" ]]; then
    echo "Copiando configuración MCP..."
    cp .claude/dev-tools/playwright/mcp/.mcp.example.json ./.mcp.json
    echo "Archivo .mcp.json creado"
else
    echo "Archivo .mcp.json ya existe"
fi

echo "Setup MCP completado. Reinicia Claude Code para aplicar los cambios."
echo "Uso: Pide a Claude que interactúe con navegadores usando comandos naturales."