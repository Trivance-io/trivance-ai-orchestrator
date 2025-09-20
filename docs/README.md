# Documentación Claude Code - Sitio Web

Este directorio contiene el sitio web de documentación para Claude Code, construido con Jekyll y desplegado en GitHub Pages.

## 🚀 Inicio Rápido

### Desarrollo Local

```bash
# 1. Instalar dependencias
cd docs
bundle install

# 2. Migrar contenido (opcional, ya migrado)
ruby ../scripts/migrate_content.rb

# 3. Servir localmente
bundle exec jekyll serve --watch --livereload

# 4. Abrir en navegador
open http://localhost:4000
```

### Construir para Producción

```bash
cd docs
bundle exec jekyll build
```

## 📁 Estructura del Proyecto

```
docs/
├── _config.yml              # Configuración Jekyll
├── _data/
│   ├── docs.yml             # Estructura de documentación
│   └── search.json          # Índice de búsqueda (generado)
├── _layouts/
│   ├── default.html         # Layout base
│   └── docs.html            # Layout para documentación
├── _includes/
│   ├── nav.html             # Navegación
│   ├── search.html          # Componente búsqueda
│   └── footer.html          # Footer
├── _plugins/
│   └── search_generator.rb  # Generador índice búsqueda
├── assets/
│   ├── css/
│   │   └── docs.css         # Estilos principales
│   └── js/
│       └── search.js        # Funcionalidad búsqueda
├── pages/                   # Páginas de documentación
│   ├── commands/
│   ├── agents/
│   ├── workflows/
│   └── best-practices/
├── index.md                 # Página principal
└── Gemfile                  # Dependencias Ruby
```

## 🎨 Características

### Diseño Responsive

- **Mobile-first**: Optimizado para dispositivos móviles
- **CSS Grid**: Layout moderno y flexible
- **Breakpoints**: 768px (tablet), 1024px (desktop)

### Búsqueda Avanzada

- **Client-side**: Búsqueda instantánea sin servidor
- **Fuzzy matching**: Tolerancia a errores tipográficos
- **Filtros por categoría**: Comandos, agentes, workflows, mejores prácticas
- **Keyboard shortcuts**: Presiona `/` para buscar

### Performance

- **Lighthouse Score**: >90 performance, >95 accessibility
- **Bundle size**: <50KB total
- **Core Web Vitals**: FCP <2s, LCP <2.5s, CLS <0.1

### Accesibilidad

- **WCAG AA compliant**
- **Keyboard navigation** completa
- **Screen reader** optimizado
- **Color contrast** >4.5:1

## 🔧 Desarrollo

### Agregar Nueva Documentación

1. **Agregar archivo** en `.claude/human-handbook/docs/`
2. **Actualizar estructura** en `_data/docs.yml`
3. **Migrar contenido**: `ruby scripts/migrate_content.rb`
4. **Probar localmente**: `bundle exec jekyll serve`

### Personalizar Estilos

Edita `assets/css/docs.css`:

- Variables CSS en `:root`
- Mobile-first responsive design
- Componentes modulares

### Extender Búsqueda

Edita `assets/js/search.js`:

- Configuración en `this.config`
- Algoritmos de relevancia
- Filtros personalizados

## 🧪 Testing

### Ejecutar Tests

```bash
# Tests TDD (deben fallar antes de implementación)
python -m pytest tests/contract/ -v
python -m pytest tests/integration/ -v

# Tests de calidad
python -m pytest tests/performance/ -v
python -m pytest tests/validation/ -v
python -m pytest tests/compatibility/ -v
```

### Test Suites

- **Contract Tests**: Validación contratos Jekyll y búsqueda
- **Integration Tests**: Escenarios usuario completos
- **Performance Tests**: Lighthouse, Core Web Vitals, bundle size
- **Validation Tests**: HTML válido, links funcionales
- **Compatibility Tests**: Cross-browser, responsive

## 🚀 Despliegue

### GitHub Pages (Automático)

El despliegue es automático en push a `main`:

1. **GitHub Action** ejecuta workflow
2. **Migra contenido** desde `.claude/human-handbook/docs/`
3. **Construye Jekyll** con optimizaciones
4. **Despliega** a GitHub Pages

### Manual

```bash
# Construir
cd docs
bundle exec jekyll build

# Los archivos están en docs/_site/
```

## 🔍 Troubleshooting

### Jekyll Build Falla

```bash
# Verificar sintaxis
bundle exec jekyll build --verbose

# Limpiar caché
bundle exec jekyll clean
```

### Búsqueda No Funciona

```bash
# Verificar índice generado
ls docs/_site/_data/search.json

# Verificar JavaScript
grep -n "DocumentationSearch" docs/assets/js/search.js
```

### Links Rotos

```bash
# Ejecutar test de validación
python -m pytest tests/validation/test_html_links.py -v
```

## 📊 Métricas

### Performance Goals

- **Page Load**: <3s
- **Lighthouse Performance**: ≥90
- **Lighthouse Accessibility**: ≥95
- **Bundle Size**: <50KB
- **Search Response**: <50ms

### Current Status

- ✅ **Jekyll Structure**: Configurado
- ✅ **Responsive Design**: Implementado
- ✅ **Search Functionality**: Funcional
- ✅ **Content Migration**: Automatizado
- ✅ **GitHub Pages**: Desplegado

## 🤝 Contribuir

1. **Fork** el repositorio
2. **Crear rama** para feature: `git checkout -b feature/mejora-documentacion`
3. **Hacer cambios** en `.claude/human-handbook/docs/`
4. **Migrar contenido**: `ruby scripts/migrate_content.rb`
5. **Probar localmente**: `bundle exec jekyll serve`
6. **Commit y push**: Seguir convenciones del proyecto
7. **Crear Pull Request**

## 📚 Referencias

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages](https://pages.github.com/)
- [CSS Grid Guide](https://css-tricks.com/snippets/css/complete-guide-grid/)
- [Lighthouse](https://developers.google.com/web/tools/lighthouse)

---

**Versión**: 1.0.0
**Última actualización**: 2025-09-20
**Autor**: Trivance AI Team
