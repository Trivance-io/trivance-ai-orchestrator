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
        echo "   Instalando Playwright (latest stable)..."
        if npm install --save-dev @playwright/test@latest --silent; then
            if npx playwright install --with-deps >/dev/null 2>&1; then
                echo "   ✅ Playwright instalado correctamente"
            else
                echo "   ❌ Error: Falló instalación de navegadores"
                exit 1
            fi
        else
            echo "   ❌ Error: Falló instalación de @playwright/test"
            exit 1
        fi
    else
        echo "   Saltando instalación."
        echo "   Manual: npm install --save-dev @playwright/test@latest"
    fi
else
    echo "   ✅ Playwright ya está instalado"
fi

# 2. Crear estructura de directorios (solo los esenciales al inicio)
echo "📁 Creando estructura de testing..."
mkdir -p tests/e2e/specs/core
mkdir -p tests/api/specs

for dir in unit integration visual performance; do
    [[ ! -d "tests/$dir" ]] && mkdir -p "tests/$dir"
done

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
if [[ -f ".gitignore" ]] && [[ "$(realpath .gitignore 2>/dev/null)" == "$(pwd)/.gitignore" ]]; then
    cp .gitignore .gitignore.backup
    entries_added=false
    for entry in "test-results/" "playwright-report/" "playwright/.auth/" ".playwright-mcp/"; do
        if ! grep -q "$entry" .gitignore; then
            [[ $entries_added == false ]] && echo "" >> .gitignore && echo "# Playwright artifacts" >> .gitignore
            echo "$entry" >> .gitignore
            entries_added=true
        fi
    done
    [[ $entries_added == true ]] && echo "   ✅ .gitignore actualizado"
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
    random_password=$(openssl rand -base64 16 2>/dev/null || echo "CHANGE_ME_$(date +%s)")
    cat > .env.test << EOF
# Test Environment Variables - PERSONALIZAR ANTES DE USO EN PRODUCCIÓN
API_BASE_URL=http://localhost:3000
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=$random_password
HEADLESS=true
TIMEOUT=30000
EOF
    chmod 600 .env.test
    echo "   ✅ .env.test creado con contraseña aleatoria"
    echo "   ⚠️  IMPORTANTE: Personaliza credenciales antes de usar en producción"
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
if [[ -f "package.json" ]]; then
    missing_scripts=()
    ! grep -q '"test:unit"' package.json && missing_scripts+=("test:unit")
    ! grep -q '"test:api"' package.json && missing_scripts+=("test:api")
    ! grep -q '"test:e2e"[^:]' package.json && missing_scripts+=("test:e2e")
    ! grep -q '"test:e2e:headed"' package.json && missing_scripts+=("test:e2e:headed")
    ! grep -q '"test:visual"' package.json && missing_scripts+=("test:visual")
    ! grep -q '"test:all"' package.json && missing_scripts+=("test:all")
    ! grep -q '"test:report"' package.json && missing_scripts+=("test:report")
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        echo "📜 Agregando scripts de testing faltantes..."
        cp package.json package.json.backup
        
        if command -v jq >/dev/null 2>&1; then
            temp_file=$(mktemp) && chmod 600 "$temp_file"
            if jq '.scripts += {
              "test:unit": "echo \"Configure unit testing framework (Jest/Vitest)\"",
              "test:api": "playwright test tests/api",
              "test:e2e": "playwright test tests/e2e",
              "test:e2e:headed": "playwright test tests/e2e --headed",
              "test:visual": "playwright test tests/visual",
              "test:all": "npm run test:unit && npm run test:api && npm run test:e2e",
              "test:report": "playwright show-report"
            }' package.json > "$temp_file" && jq empty "$temp_file" 2>/dev/null; then
                mv "$temp_file" package.json
                echo "   ✅ Scripts agregados con jq"
            else
                rm -f "$temp_file"
                echo "   ❌ Error: Falló actualización de package.json"
                exit 1
            fi
        else
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
fi

# 7. Resumen final
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