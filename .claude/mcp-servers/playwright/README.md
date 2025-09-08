# Playwright MCP Server - Configuración Segura para QA Automatizado

**Integración de testing automatizado visual y funcional en Claude Code con máxima seguridad**

## 🎯 Características Principales

- **Testing Visual Automatizado**: Screenshots, snapshots y validación visual
- **QA Funcional**: Navegación, clicks, formularios y flujos de usuario
- **Seguridad Endurecida**: Sandbox, timeouts agresivos y whitelist de dominios
- **Integración Claude Code**: Permisos granulares y comandos nativos
- **Aislamiento de Recursos**: Browsers en `/tmp` con cleanup automático

## 🚀 Setup Rápido

```bash
# 1. Ejecutar setup interactivo (recomendado)
./.claude/mcp-servers/playwright/setup.sh

# 2. Reiniciar Claude Code para aplicar
# 3. Verificar conexión MCP en status
```

## ⚙️ Setup Manual (Alternativo)

```bash
# 1. Instalar Playwright MCP globalmente
npm install -g @playwright/mcp

# 2. Instalar browsers
npx playwright install chromium

# 3. Configurar MCP
cp .claude/mcp-servers/playwright/.mcp.example.json ./.mcp.json

# 4. Reiniciar Claude Code
```

## 🔐 Configuración de Seguridad

### Medidas de Seguridad Implementadas

**Aislamiento de Procesos:**
- `--isolated`: Procesos browser completamente aislados
- `--no-sandbox=false`: Sandbox habilitado para máximo aislamiento
- `PLAYWRIGHT_BROWSERS_PATH=/tmp`: Datos temporales con auto-cleanup

**Restricciones de Red:**
- `--allowed-origins`: Solo dominios whitelisted permitidos
- `--block-service-workers`: Service workers deshabilitados
- `--block-third-party-cookies`: Cookies de terceros bloqueadas
- `--blocked-resources`: Recursos no críticos bloqueados

**Límites de Recursos:**
- `--max-memory=512`: Límite 512MB RAM por proceso
- `--max-cpu=50`: Máximo 50% CPU utilizable
- `--timeout-*`: Timeouts agresivos para prevenir procesos colgados

**Restricciones de Ejecución:**
- JavaScript eval() bloqueado en permisos
- Navegación a archivos locales (file://) denegada
- URLs data: y ftp: bloqueadas

### Dominios Permitidos por Defecto

```json
"--allowed-origins=localhost:3000;localhost:8080;staging.company.com"
```

**Personalizar dominios:**
1. Ejecutar `./setup.sh` y agregar dominios interactivamente
2. O editar manualmente `.mcp.json` después del setup

## 🎛️ Permisos Claude Code

### Permisos Automáticos (`allow`)
```json
"mcp__playwright__browser_navigate(url:localhost/*)",
"mcp__playwright__browser_navigate(url:staging.company.com/*)",
"mcp__playwright__browser_snapshot",
"mcp__playwright__browser_click",
"mcp__playwright__browser_type",
"mcp__playwright__browser_wait_for",
"mcp__playwright__browser_close",
"mcp__playwright__browser_get_content"
```

### Permisos con Confirmación (`ask`)
```json
"mcp__playwright__browser_evaluate:*",
"mcp__playwright__browser_file_upload:*", 
"mcp__playwright__browser_take_screenshot:*",
"mcp__playwright__browser_navigate(url:*)"
```

### Permisos Denegados (`deny`)
```json
"mcp__playwright__browser_evaluate(*eval*)",
"mcp__playwright__browser_evaluate(*Function*)",
"mcp__playwright__browser_navigate(url:file://*)",
"mcp__playwright__browser_navigate(url:data:*)"
```

## 📋 Uso con Comandos Claude Code

### QA Automatizado
```bash
# Testing visual completo
/test

# Review con validación visual  
/review

# Testing específico de features
/implement "login flow" --with-qa
```

### Comandos Manuales
```
"Navigate to localhost:3000 and take a screenshot"
"Click on the login button and verify the form appears"
"Test the signup flow from start to finish"
"Check mobile responsive design on iPhone viewport"
```

## 📁 Estructura de Archivos

```
.claude/mcp-servers/playwright/
├── .mcp.example.json    # Template configuración completa  
├── setup.sh             # Script setup interactivo
└── README.md            # Documentación (este archivo)

# Archivos generados en raíz del proyecto:
.mcp.json                # Configuración MCP activa
```

## 🔧 Configuración Avanzada

### Variables de Entorno Disponibles

```json
{
  "PLAYWRIGHT_BROWSERS_PATH": "/tmp/playwright-browsers",
  "NODE_ENV": "test",
  "PLAYWRIGHT_BROWSER_EXECUTABLE": "",
  "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD": "false",
  "PLAYWRIGHT_CHROMIUM_USE_HEADLESS_NEW": "true",
  "PLAYWRIGHT_DISABLE_USER_AGENT": "false",
  "TMPDIR": "/tmp"
}
```

### Argumentos de Línea de Comandos

```json
[
  "@playwright/mcp@latest",
  "--headless",                    // Modo sin interfaz gráfica
  "--isolated",                    // Aislamiento completo de procesos  
  "--no-sandbox=false",           // Sandbox habilitado
  "--block-service-workers",      // Bloquear service workers
  "--block-third-party-cookies",  // Bloquear cookies de terceros
  "--timeout-action=3000",        // Timeout acciones: 3 segundos
  "--timeout-navigation=30000",   // Timeout navegación: 30 segundos  
  "--timeout-test=60000",         // Timeout tests: 60 segundos
  "--blocked-resources=font,image,media,websocket", // Recursos bloqueados
  "--image-responses=omit",       // Omitir respuestas de imágenes
  "--save-session=false",         // No guardar sesiones
  "--max-memory=512",             // Límite RAM: 512MB
  "--max-cpu=50"                  // Límite CPU: 50%
]
```

## 🛠️ Troubleshooting

### Error: MCP Server no conecta
```bash
# Verificar instalación
npm list -g @playwright/mcp

# Reinstalar si es necesario  
npm install -g @playwright/mcp

# Verificar configuración
cat ./.mcp.json | jq .mcpServers.playwright
```

### Error: Browsers no disponibles
```bash
# Reinstalar browsers en ubicación correcta
export PLAYWRIGHT_BROWSERS_PATH="/tmp/playwright-browsers"
npx playwright install chromium

# Verificar ubicación
ls -la /tmp/playwright-browsers/
```

### Error: Permisos denegados
```bash
# Verificar permisos en .claude/settings.json
grep -A 10 "mcp__playwright__" .claude/settings.json

# Aplicar permisos recomendados del README
```

### Error: Timeouts frecuentes
```bash
# Incrementar timeouts en .mcp.json si es necesario
# Pero mantener valores seguros (< 60s navegación)
```

## 🔍 Validación de Seguridad

### Checklist de Seguridad Post-Setup

- [ ] Browsers ejecutan en `/tmp` con datos temporales
- [ ] Solo dominios whitelisted accesibles
- [ ] Timeouts configurados (< 60s navegación, < 5s acciones)  
- [ ] Sandbox habilitado (`--no-sandbox=false`)
- [ ] Límites de recursos aplicados (RAM, CPU)
- [ ] JavaScript eval bloqueado en permisos
- [ ] Navegación a archivos locales bloqueada
- [ ] Service workers y cookies terceros bloqueados

### Test de Validación

```bash
# Ejecutar test básico de conectividad
timeout 10 npx @playwright/mcp --help

# Verificar restricciones de dominios
# (debe fallar con dominios no whitelisted)
```

## 📖 Referencias

- **Playwright MCP**: https://github.com/ModelContextProtocol/playwright-mcp
- **Claude Code MCP**: https://docs.anthropic.com/en/docs/claude-code/mcp  
- **Model Context Protocol**: https://modelcontextprotocol.io/introduction

## 🆘 Soporte

**Para problemas de configuración:**
1. Ejecutar `.claude/mcp-servers/playwright/setup.sh` nuevamente
2. Verificar logs de Claude Code en caso de errores MCP
3. Revisar permisos en `.claude/settings.json`

**Para problemas de seguridad:**
1. Verificar que sandbox esté habilitado
2. Confirmar que solo dominios whitelisted sean accesibles
3. Validar límites de recursos y timeouts
