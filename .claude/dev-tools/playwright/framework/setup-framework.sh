#!/usr/bin/env bash
set -e

# Verificar que estamos en un workspace con .claude
if [[ ! -d ".claude" ]]; then
    echo "Error: Debe ejecutarse desde la raíz del workspace (donde está .claude/)"
    exit 1
fi

echo "🚀 Setup Playwright Framework + Estructura Estándar"

# 1. Instalar Playwright con confirmación
echo "📦 Verificando instalación Playwright..."
if ! npx playwright --version >/dev/null 2>&1; then
    echo "   Playwright no encontrado."
    read -p "   ¿Instalar Playwright? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Instalando..."
        npm init playwright@latest
    else
        echo "   Saltando instalación. Puedes instalar manualmente con: npm init playwright@latest"
    fi
else
    echo "   ✅ Playwright ya está instalado"
fi

# 2. Crear estructura de directorios (solo los esenciales al inicio)
echo "📁 Creando estructura de testing..."
mkdir -p tests/e2e/specs/core
mkdir -p tests/api/specs

# Crear estructura adicional solo si no existe (lazy creation)
for dir in unit integration visual performance; do
    [[ ! -d "tests/$dir" ]] && mkdir -p "tests/$dir"
done

# Subdirectorios E2E
for subdir in auth admin; do
    [[ ! -d "tests/e2e/specs/$subdir" ]] && mkdir -p "tests/e2e/specs/$subdir"
done

mkdir -p tests/e2e/{page-objects,fixtures,utils}
mkdir -p tests/api/{fixtures,utils}
mkdir -p tests/visual/baselines
mkdir -p tests/performance/{load,stress}

echo "   ✅ Estructura de directorios creada"

# 3. Actualizar .gitignore de forma segura
echo "📝 Configurando archivos..."
if [[ -f ".gitignore" ]]; then
    cp .gitignore .gitignore.backup
    
    # Solo agregar si no existen estas entradas
    if ! grep -q "test-results" .gitignore; then
        echo "" >> .gitignore
        echo "# Playwright artifacts" >> .gitignore
        echo "test-results/" >> .gitignore
        echo "playwright-report/" >> .gitignore
        echo "playwright/.auth/" >> .gitignore
        echo ".playwright-mcp/" >> .gitignore
        echo "   ✅ .gitignore actualizado"
    fi
else
    cat > .gitignore << 'EOF'
node_modules/
.env

# Playwright artifacts
test-results/
playwright-report/
playwright/.auth/
.playwright-mcp/
EOF
    echo "   ✅ .gitignore creado"
fi

# 4. Variables de entorno
if [[ ! -f ".env.test" ]]; then
    cat > .env.test << 'EOF'
# Test Environment Variables
API_BASE_URL=http://localhost:3000
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=testpass123
HEADLESS=true
TIMEOUT=30000
EOF
    echo "   ✅ .env.test creado"
fi

# 5. Archivos de ejemplo esenciales
if [[ ! -f "tests/e2e/specs/core/example.spec.ts" ]]; then
    cat > tests/e2e/specs/core/example.spec.ts << 'EOF'
import { test, expect } from '@playwright/test';

test.describe('Ejemplo básico', () => {
  test('página principal carga correctamente', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/.*/); // Ajustar según tu app
  });
});
EOF
    echo "   ✅ Test E2E ejemplo creado"
fi

if [[ ! -f "tests/api/specs/health.spec.ts" ]]; then
    cat > tests/api/specs/health.spec.ts << 'EOF'
import { test, expect } from '@playwright/test';

test.describe('API Health Check', () => {
  test('endpoint /health responde correctamente', async ({ request }) => {
    const response = await request.get('/api/health');
    expect(response.status()).toBe(200);
  });
});
EOF
    echo "   ✅ Test API ejemplo creado"
fi

# 6. Scripts package.json de forma segura
if [[ -f "package.json" ]] && ! grep -q "test:e2e" package.json; then
    echo "📜 Agregando scripts de testing..."
    cp package.json package.json.backup
    
    # Método seguro usando jq si está disponible
    if command -v jq >/dev/null 2>&1; then
        jq '.scripts += {
          "test:unit": "echo \"Configure unit testing framework (Jest/Vitest)\"",
          "test:api": "playwright test tests/api",
          "test:e2e": "playwright test tests/e2e", 
          "test:e2e:headed": "playwright test tests/e2e --headed",
          "test:visual": "playwright test tests/visual",
          "test:all": "npm run test:unit && npm run test:api && npm run test:e2e",
          "test:report": "playwright show-report"
        }' package.json > package.json.tmp && mv package.json.tmp package.json
        echo "   ✅ Scripts agregados con jq"
    else
        # Fallback más seguro sin jq
        echo "   ⚠️  jq no disponible. Agregando scripts manualmente..."
        cat >> package.json.backup << 'EOF'

Scripts sugeridos para agregar a package.json:
"test:unit": "echo \"Configure unit testing framework (Jest/Vitest)\"",
"test:api": "playwright test tests/api",
"test:e2e": "playwright test tests/e2e",
"test:e2e:headed": "playwright test tests/e2e --headed", 
"test:visual": "playwright test tests/visual",
"test:all": "npm run test:unit && npm run test:api && npm run test:e2e",
"test:report": "playwright show-report"
EOF
        echo "   📝 Scripts guardados en package.json.backup para agregar manualmente"
    fi
fi

# 7. README de testing
if [[ ! -f "tests/README.md" ]]; then
    if [[ -f ".claude/dev-tools/playwright/framework/TESTING-README-TEMPLATE.md" ]]; then
        cp .claude/dev-tools/playwright/framework/TESTING-README-TEMPLATE.md tests/README.md
        echo "   ✅ README de testing creado"
    else
        echo "   ⚠️  Template README no encontrado, saltando..."
    fi
fi

# 8. Resumen final
echo ""
echo "🎉 Setup completado!"
echo "📋 Estructura:"
echo "   tests/{e2e,api,unit,integration,visual,performance}/"
echo ""
echo "🚀 Comandos (si se agregaron scripts):"
echo "   npm run test:e2e"
echo "   npm run test:api" 
echo "   npm run test:all"
echo ""
echo "📖 Personaliza tests en tests/e2e/specs/ según tu aplicación"