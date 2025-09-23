# Playwright para Claude Code

Testing automatizado de aplicaciones web desde Claude Code.

## 🎯 Dos Enfoques de Testing

### **MCP (Interactivo)**

**Ideal para:** Exploración, debugging, validación manual, generación de tests

**Qué hace:** Claude Code controla navegadores directamente con comandos naturales.

### **Framework (Sistemático)**

**Ideal para:** Testing estructurado, CI/CD, cross-browser, visual regression

**Qué hace:** Tests programáticos con Playwright tradicional ejecutables independientemente.

## ⚡ Configuración MCP (Interactivo)

**Configuración simplificada:** Una sola instancia estable con cambios de viewport dinámicos

**Paso 1:** Ejecutar setup

```bash
bash .claude/dev-tools/playwright/mcp/setup-mcp.sh
```

**Paso 2:** Reiniciar Claude Code para detectar la nueva configuración

### 🎯 Uso MCP - Comandos Naturales

**Navegación y testing:**

```
Claude, ve a localhost:3000/login, llena el formulario con usuario 'admin' y contraseña '123' y haz click en enviar
Claude, navega a mi app y toma una captura de pantalla del dashboard
```

**Cambios de viewport dinámicos:**

```
Claude, redimensiona el navegador a 375x812 para vista móvil
Claude, cambia a vista tablet (768x1024) y verifica el menú
Claude, redimensiona a 1366x768 para vista laptop
Claude, vuelve a escritorio (1920x1080)
```

## 🧪 Configuración Framework (Sistemático)

**Paso 1:** Ejecutar setup (con confirmación y backups automáticos)

```bash
bash .claude/dev-tools/playwright/framework/setup-framework.sh
```

**Paso 2:** Configurar tests programáticos según necesidades del proyecto

### 🎯 Uso Framework - Tests Programáticos

```bash
npx playwright test
npx playwright test --headed --browser=all
npx playwright show-report
```

**Ejemplo de test:**

```typescript
// tests/e2e/specs/login.spec.ts
import { test, expect } from "@playwright/test";

test("usuario puede hacer login", async ({ page }) => {
  await page.goto("/login");

  await page.fill('[data-testid="username"]', "admin");
  await page.fill('[data-testid="password"]', "123456");
  await page.click('[data-testid="login-button"]');

  await expect(page.locator('[data-testid="dashboard"]')).toBeVisible();
});
```

## 📋 Lo que se Crea Automáticamente

```
proyecto/
├── .mcp.json                    ← Configuración MCP
├── .playwright-mcp/             ← Screenshots MCP (ignorar en git)
├── playwright.config.js         ← Configuración framework
├── tests/                       ← Tests programáticos
└── test-results/               ← Reportes framework (ignorar en git)
```

**Agregar a .gitignore:**

```bash
.playwright-mcp/
test-results/
playwright-report/
playwright/.auth/
```

## 🔄 Workflow Profesional

### **1. Exploración con MCP**

```
Claude, explora mi aplicación y documenta el flujo de usuario
```

### **2. Generación de Tests**

```
Claude, genera un test de Playwright para el flujo que acabas de explorar
```

### **3. Ejecución Sistemática**

```bash
npx playwright test --browser=all
```

## 🔧 Solución de Problemas

**"Claude no responde a comandos de navegador"**

- Verifica que `.mcp.json` esté en la raíz del proyecto
- Reinicia Claude Code completamente

**"No encuentro las capturas de pantalla"**

- MCP: Se guardan en `.playwright-mcp/`
- Framework: Se guardan en `test-results/`

**"Tests fallan en CI/CD"**

- Usar configuración framework para entornos automatizados
- MCP es solo para desarrollo interactivo

**"Error durante setup-framework.sh"**

- El script crea backups automáticos (.gitignore.backup, package.json.backup)
- Solicita confirmación antes de instalar Playwright
- Sin `jq`: scripts se guardan en package.json.backup para agregar manualmente

## 📚 Referencias

- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Playwright Framework](https://playwright.dev)
- [Claude Code + MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)
