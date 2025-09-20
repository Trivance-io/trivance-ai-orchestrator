---
layout: default
title: "Documentación Claude Code"
description: "Guía completa de comandos, agentes y mejores prácticas para desarrollo AI-first con Claude Code. Aprende a maximizar tu productividad con herramientas de inteligencia artificial."
---

# Documentación Claude Code

**Domina el desarrollo AI-first con la guía completa de Claude Code**

Bienvenido a la documentación oficial de Claude Code, tu compañero definitivo para desarrollo profesional asistido por inteligencia artificial. Aprende a usar comandos de alto valor, agentes especialistas y workflows AI-first para transformar tu productividad.

---

## 🚀 Comienza Aquí

<div class="getting-started-grid">

  <div class="start-card">
    <h3>
      <a href="/quickstart/">⚡ Inicio Rápido</a>
    </h3>
    <p>Configura Claude Code en 5 minutos y ejecuta tu primer comando de alto valor.</p>
  </div>

  <div class="start-card">
    <h3>
      <a href="/commands/">⌨️ Comandos Esenciales</a>
    </h3>
    <p>Comandos organizados por impacto. Comienza con <code>/implement</code> y <code>/understand</code>.</p>
  </div>

  <div class="start-card">
    <h3>
      <a href="/workflows/">🔄 Workflows AI-First</a>
    </h3>
    <p>Metodología completa para desarrollo dirigido por IA con máxima eficiencia.</p>
  </div>

</div>

---

## 📚 Explora la Documentación

{%- if site.data.docs.sections -%}

  <div class="sections-grid">
    {%- for section in site.data.docs.sections -%}
      <div class="section-card" style="border-left: 4px solid {{ section.color_theme }};">
        <div class="section-header">
          <span class="section-icon">{{ section.icon }}</span>
          <h3>
            <a href="{{ section.url | relative_url }}">{{ section.title }}</a>
          </h3>
        </div>

        <p class="section-description">{{ section.description }}</p>

        {%- if section.pages -%}
          <ul class="section-pages">
            {%- for page in section.pages limit:3 -%}
              <li>
                <a href="{{ section.url | append: page.id | append: '/' | relative_url }}">
                  {{ page.title }}
                </a>
              </li>
            {%- endfor -%}
            {%- if section.pages.size > 3 -%}
              <li class="see-more">
                <a href="{{ section.url | relative_url }}">Ver todos →</a>
              </li>
            {%- endif -%}
          </ul>
        {%- endif -%}
      </div>
    {%- endfor -%}

  </div>
{%- endif -%}

---

## ⚡ Comandos de Alto Valor

Comandos que transforman tu productividad diaria:

<div class="commands-highlight">

### `/understand`

**Análiza todo el codebase** y explica arquitectura, patrones y funcionamiento completo.

```bash
/understand
```

_ROI: 30 min ahorran 3+ horas de refactoring por inconsistencias._

### `/implement`

**Motor de implementación automática** que planifica e implementa features completas.

```bash
/implement "nueva feature de dashboard con notificaciones"
```

_ROI: Reduce 4+ horas desarrollo manual a 20-30 minutos._

### `/review`

**Quality assurance multi-especialista** con análisis profundo de seguridad y performance.

```bash
/review
```

_ROI: Detecta 90%+ issues antes de producción._

</div>

[Ver todos los comandos →](/commands/)

---

## 🎯 ¿Por Qué Claude Code?

<div class="benefits-grid">

  <div class="benefit-item">
    <h4>🚀 Productividad 10x</h4>
    <p>Comandos de alto valor reducen tareas de horas a minutos. Desarrollo asistido por IA que realmente funciona.</p>
  </div>

  <div class="benefit-item">
    <h4>🤖 33+ Agentes Especialistas</h4>
    <p>Expertos en React, Rails, Django, mobile y más. Cada desafío tiene su especialista perfecto.</p>
  </div>

  <div class="benefit-item">
    <h4>🔄 Workflows AI-First</h4>
    <p>Metodología probada que maximiza el valor de la IA mientras mantienes control total del proceso.</p>
  </div>

  <div class="benefit-item">
    <h4>⭐ Calidad Enterprise</h4>
    <p>Tests automáticos, revisiones de seguridad y best practices integradas en cada workflow.</p>
  </div>

</div>

---

## 📖 Recursos Adicionales

<div class="resources-section">

### 🔗 Enlaces Útiles

- [**Repositorio en GitHub**]({{ site.data.docs.external_links.github.url }}) - Código fuente y issues
- [**Guía de Contribución**]({{ site.data.docs.external_links.github.url }}/blob/main/CONTRIBUTING.md) - Cómo contribuir
- [**Discusiones**]({{ site.data.docs.external_links.github.url }}/discussions) - Comunidad y preguntas

### 📱 Soporte

- **Issues**: [Reportar problemas]({{ site.data.docs.external_links.github.url }}/issues)
- **Email**: [{{ site.email | default: "support@trivance.ai" }}](mailto:{{ site.email | default: "support@trivance.ai" }})
- **Documentación**: Siempre actualizada y sincronizada

</div>

---

## 🏃‍♂️ Empezar Ahora

**¿Listo para transformar tu desarrollo?**

1. **[Lee la guía de inicio rápido](/quickstart/)** - Configuración en 5 minutos
2. **[Prueba tu primer comando](/commands/)** - Comienza con `/understand`
3. **[Explora los agentes](/agents/)** - Encuentra tu especialista perfecto
4. **[Implementa AI-first workflows](/workflows/)** - Metodología completa

<div class="cta-section">
  <a href="/quickstart/" class="cta-button">
    🚀 Comenzar Ahora
  </a>
  <a href="/commands/" class="cta-button secondary">
    📋 Ver Comandos
  </a>
</div>

---

<small>
**Última actualización**: {{ site.data.docs.site_info.last_updated | date: "%d de %B, %Y" }}
**Versión**: {{ site.data.docs.site_info.version }}
**Construido con**: Jekyll + GitHub Pages
</small>

<style>
/* Landing Page Specific Styles */
.getting-started-grid,
.sections-grid,
.benefits-grid {
  display: grid;
  gap: 1.5rem;
  margin: 2rem 0;
}

.getting-started-grid {
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

.sections-grid {
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
}

.benefits-grid {
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}

.start-card,
.section-card,
.benefit-item {
  background: var(--bg-secondary, #f9fafb);
  border: 1px solid var(--border-color, #e5e7eb);
  border-radius: 0.5rem;
  padding: 1.5rem;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.start-card:hover,
.section-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.section-icon {
  font-size: 1.5rem;
}

.section-pages {
  list-style: none;
  padding: 0;
  margin: 1rem 0 0 0;
}

.section-pages li {
  margin-bottom: 0.5rem;
}

.section-pages a {
  color: var(--primary-color, #3b82f6);
  text-decoration: none;
  font-size: 0.9rem;
}

.section-pages a:hover {
  text-decoration: underline;
}

.see-more a {
  font-weight: 600;
  color: var(--primary-dark, #2563eb);
}

.commands-highlight {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2rem;
  border-radius: 0.75rem;
  margin: 2rem 0;
}

.commands-highlight h3 {
  color: white;
  margin-top: 1.5rem;
}

.commands-highlight h3:first-child {
  margin-top: 0;
}

.commands-highlight code {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-weight: 600;
}

.commands-highlight pre {
  background: rgba(0, 0, 0, 0.3);
  border: none;
  margin: 0.5rem 0;
}

.benefit-item h4 {
  margin-bottom: 0.5rem;
  color: var(--primary-color, #3b82f6);
}

.resources-section {
  background: var(--bg-tertiary, #f3f4f6);
  padding: 2rem;
  border-radius: 0.5rem;
  margin: 2rem 0;
}

.resources-section h3 {
  margin-top: 0;
  color: var(--primary-color, #3b82f6);
}

.cta-section {
  text-align: center;
  margin: 3rem 0;
}

.cta-button {
  display: inline-block;
  padding: 1rem 2rem;
  margin: 0.5rem;
  background: var(--primary-color, #3b82f6);
  color: white;
  text-decoration: none;
  border-radius: 0.5rem;
  font-weight: 600;
  font-size: 1.1rem;
  transition: all 0.2s ease;
}

.cta-button:hover {
  background: var(--primary-dark, #2563eb);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  color: white;
  text-decoration: none;
}

.cta-button.secondary {
  background: transparent;
  color: var(--primary-color, #3b82f6);
  border: 2px solid var(--primary-color, #3b82f6);
}

.cta-button.secondary:hover {
  background: var(--primary-color, #3b82f6);
  color: white;
}

/* Responsive Design */
@media (max-width: 768px) {
  .getting-started-grid,
  .sections-grid,
  .benefits-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .commands-highlight {
    padding: 1.5rem;
  }

  .resources-section {
    padding: 1.5rem;
  }

  .cta-button {
    display: block;
    margin: 0.5rem 0;
  }
}

/* Dark mode adjustments */
@media (prefers-color-scheme: dark) {
  .start-card,
  .section-card,
  .benefit-item {
    background: var(--bg-secondary, #1f2937);
    border-color: var(--border-color, #374151);
  }

  .resources-section {
    background: var(--bg-secondary, #1f2937);
  }
}
</style>
