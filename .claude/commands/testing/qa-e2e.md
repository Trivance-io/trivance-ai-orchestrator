---
allowed-tools: mcp__playwright__*, Task, Bash(mkdir *), Bash(date *), Read, Write, Glob, Grep
description: Coordinador de testing E2E que delega a playwright-qa-specialist con integración MCP completa
---

# End-to-End Quality Assurance Engine

Sistema integral de testing E2E que coordina con playwright-qa-specialist para validación comprehensiva de aplicaciones web usando Playwright MCP browser automation.

Arguments: `$ARGUMENTS` - Test targets, URLs, flows, o configuraciones específicas (--browsers, --mobile, --critical, --api)

## Phase 1: Project Discovery & Test Analysis

**Environment Detection:**
- Usar **Glob** para detectar estructura de aplicación: `**/*.{js,ts,jsx,tsx,vue,svelte}`
- Usar **Read** para analizar `package.json`, `playwright.config.js`, configuraciones existentes
- Usar **Grep** para identificar critical user flows, API endpoints, rutas importantes
- Detectar stack tecnológico y patrones de testing existentes

**Scope Planning:**
- **Sin argumentos**: Test suite completo basado en discovery de aplicación
- **Con URL específica**: Testing dirigido a flujos específicos de esa URL
- **Con --critical flag**: Enfocar solo en critical paths y core business flows
- **Con --api flag**: Incluir testing de API endpoints durante flujos E2E

## Phase 2: Strategic QA Orchestration

**MANDATORY Delegation Pattern (NO implementación independiente):**

Ejecutar delegación completa al especialista:
```
Execute `/agent:playwright-qa-specialist` with comprehensive context:
- Project structure discovered in Phase 1
- Technology stack and existing test patterns
- Target URLs, flows, and test scope from arguments
- Browser matrix configuration (default: chrome,firefox,safari)
- Mobile testing requirements (if --mobile flag present)
- Performance benchmarking requirements
- Integration testing scope (API endpoints discovered)
```

**Context Handoff Include:**
- Application architecture patterns
- Existing test infrastructure and configurations
- Critical user journeys identified
- Performance baselines and thresholds
- Security considerations for auth flows
- Accessibility compliance requirements

## Phase 3: MCP Integration & Test Coordination

**MCP Browser Commands Coordination:**
- Coordinar uso de `mcp__playwright__browser_navigate` para navegación inteligente
- Gestionar `mcp__playwright__browser_click`, `browser_fill_form` para interactions
- Coordinar `mcp__playwright__browser_take_screenshot` para evidencia visual
- Integrar `mcp__playwright__browser_evaluate` para validaciones JavaScript
- Gestionar `mcp__playwright__browser_wait_for` para dynamic content
- Coordinar `mcp__playwright__browser_handle_dialog` para user interactions

**Cross-Browser Execution:**
- Validar execution matrix: Chrome, Firefox, Safari (según argumentos)
- Coordinar mobile viewport testing si `--mobile` especificado
- Gestionar parallel execution y resource management
- Coordinar screenshot comparison para visual regression testing

## Phase 4: Quality Reporting & Issue Management

**Report Generation:**
- **Crear directorios**: `mkdir -p .claude/qa-reports .claude/logs/$(date +%Y-%m-%d)`
- **Generar timestamp**: `date '+%Y-%m-%dT%H:%M:%S'`
- **Consolidar resultados** del playwright-qa-specialist
- **Escribir reporte ejecutivo**: `.claude/qa-reports/e2e-report-$(timestamp).md`

**Integration with Quality Gates:**
- Validar playwright-qa-specialist outputs contra project standards
- Coordinar con `config-security-expert` para security test scenarios
- Integrar con `performance-optimizer` para Core Web Vitals validation
- Coordinar con framework-specific agents para component-level fixes

**Issue Detection & Routing:**
- **CRITICAL issues** → Immediate escalation con screenshots y reproduction steps
- **PERFORMANCE issues** → Route to performance-optimizer para analysis
- **SECURITY vulnerabilities** → Route to security-reviewer para assessment
- **UI/UX issues** → Route to frontend-developer para component fixes

**Executive Summary Template:**
```markdown
🧪 **E2E Testing Report Completado**

## Results Summary
**Coverage:** X test cases ejecuted - **Pass Rate:** Y% - **Browsers:** Chrome/Firefox/Safari
**Performance:** Avg page load Zms - **Accessibility:** AA compliant - **Security:** No vulnerabilities

## Critical Issues: <count>
### 🚨 BLOCKING (<count> items)
- [ ] [Issue description] - [Browser] - [Impact] - [Assigned to: specialist]

### ⚠️ HIGH PRIORITY (<count> items)  
- [ ] [Issue description] - [Performance impact] - [Resolution approach]

### 💡 IMPROVEMENTS (<count> items)
- [ ] [Enhancement opportunity] - [Expected benefit] - [Implementation effort]

## Cross-Browser Matrix
| Feature | Chrome | Firefox | Safari | Mobile |
|---------|--------|---------|--------|--------|
| Login Flow | ✅ | ✅ | ❌ | ✅ |
| Checkout | ✅ | ⚠️ | ✅ | ❌ |

## Performance Benchmarks
- **Page Load**: <2s target achieved: X/Y pages
- **Core Web Vitals**: LCP, FID, CLS metrics
- **API Response Times**: <500ms achieved: X/Y endpoints

**Detailed Report:** <qa_report_file>
**Screenshots & Evidence:** .claude/qa-reports/evidence/

**Next Actions:**
1. Resolve blocking issues (est: X hours)
2. Performance optimization focus areas  
3. Cross-browser compatibility fixes
```

**Integration with other commands:**
- **Post-implementation**: `/qa-e2e` después de `/implement` para validation
- **Pre-deployment**: `/qa-e2e --critical` antes de production releases
- **Performance focus**: `/qa-e2e --performance` para Core Web Vitals optimization
- **Security testing**: `/qa-e2e --security-flows` para auth and sensitive operations
- **Mobile validation**: `/qa-e2e --mobile` para responsive design verification

## Success Criteria

- **Complete Delegation**: Nunca implementa testing independientemente, siempre delega a playwright-qa-specialist
- **MCP Integration**: Coordina efectivamente browser automation commands via MCP
- **Quality Reporting**: Genera executive summaries actionables con issue routing
- **Cross-Browser Coverage**: Valida functionality across target browser matrix
- **Performance Benchmarking**: Incluye Core Web Vitals y performance analysis
- **Issue Escalation**: Routes diferentes tipos de issues a specialists apropiados

**Execution Guarantee:**
1. **Project discovery** - Map application structure y test requirements
2. **Strategic delegation** - Handoff completo a playwright-qa-specialist con context
3. **MCP coordination** - Gestión de browser automation via MCP commands  
4. **Quality consolidation** - Executive reporting con issue routing y action items