#!/usr/bin/env bash
set -e

# Verificar que estamos en un workspace válido
if [[ ! -f ".mcp.json" ]] && [[ ! -d ".claude" ]]; then
    echo "Error: Debe ejecutarse desde la raíz del workspace (donde está .claude/ o .mcp.json)"
    exit 1
fi

# Verificar configuración MCP de Shadcn
echo "Verificando configuración MCP de Shadcn..."

if [[ -f ".mcp.json" ]]; then
    if grep -q "shadcn" .mcp.json; then
        echo "✅ MCP de Shadcn ya está configurado"
        echo ""
        echo "Configuración detectada:"
        grep -A 10 "shadcn" .mcp.json || echo "  - shadcn server configurado"
    else
        echo "⚠️  .mcp.json existe pero no tiene configuración de Shadcn"
        echo "Por favor, agrega manualmente la configuración de Shadcn MCP"
        echo ""
        echo "Configuración sugerida para agregar:"
        echo '  "shadcn": {'
        echo '    "command": "node",'
        echo '    "args": ["path/to/shadcn-mcp/dist/index.js"]'
        echo '  }'
    fi
else
    echo "❌ No se encontró .mcp.json"
    echo "Para configurar Shadcn MCP, crea un archivo .mcp.json con:"
    echo ""
    cat << 'EOF'
{
  "mcpServers": {
    "shadcn": {
      "command": "node",
      "args": ["path/to/shadcn-mcp/dist/index.js"]
    }
  }
}
EOF
fi

echo ""
echo "📚 Documentación adicional:"
echo "  - README: dev-tools/shadcn/README.md"
echo "  - Shadcn MCP: https://github.com/RafalWilinski/shadcn-mcp"
echo "  - Claude Code MCP: https://docs.anthropic.com/en/docs/claude-code/mcp"

echo ""
echo "🎯 Comandos de ejemplo:"
echo "  Claude, busca componentes de formulario en Shadcn"
echo "  Claude, instala el componente button de Shadcn"
echo "  Claude, configura Shadcn en mi proyecto Next.js"

if grep -q "shadcn" .mcp.json 2>/dev/null; then
    echo ""
    echo "✅ Setup MCP completado. Shadcn MCP está listo para usar."
else
    echo ""
    echo "⚠️  Para completar el setup, configura Shadcn MCP en .mcp.json y reinicia Claude Code."
fi