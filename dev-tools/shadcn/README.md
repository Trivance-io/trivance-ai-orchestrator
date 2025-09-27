# Shadcn/ui para Claude Code

Desarrollo acelerado de interfaces con componentes UI profesionales desde Claude Code.

## 🎯 Dos Enfoques de Desarrollo

### **MCP (Interactivo)**

**Ideal para:** Exploración de componentes, prototipado rápido, instalación asistida

**Qué hace:** Claude Code busca, instala y configura componentes Shadcn/ui directamente con comandos naturales.

### **CLI (Sistemático)**

**Ideal para:** Desarrollo estructurado, configuración de proyectos, gestión de design systems

**Qué hace:** Uso tradicional del CLI de Shadcn/ui con configuración optimizada para proyectos empresariales.

## ⚡ Configuración MCP (Interactivo)

**Configuración automática:** MCP ya instalado y configurado para búsqueda e instalación de componentes

**Estado actual:** ✅ Configurado en `.mcp.json`

### 🎯 Uso MCP - Comandos Naturales

**Búsqueda e instalación:**

```
Claude, busca componentes de formulario en Shadcn
Claude, instala el componente button y form de Shadcn
Claude, muéstrame ejemplos de uso del componente dialog
```

**Configuración de proyecto:**

```
Claude, configura Shadcn en mi proyecto Next.js
Claude, ayúdame a elegir los componentes necesarios para un dashboard
```

**Exploración y customización:**

```
Claude, explora las variantes disponibles del componente card
Claude, customiza el theme de Shadcn para mi marca
```

## 🧪 Configuración CLI (Sistemático)

**Paso 1:** Ejecutar setup (configuración completa del proyecto)

```bash
bash dev-tools/shadcn/cli/setup-cli.sh
```

**Paso 2:** Configurar design system según necesidades del proyecto

### 🎯 Uso CLI - Comandos Directos

```bash
# Inicializar proyecto
npx shadcn@latest init

# Instalar componentes específicos
npx shadcn@latest add button
npx shadcn@latest add form dialog

# Gestión avanzada
npx shadcn@latest add --all
npx shadcn@latest update
```

**Ejemplo de configuración:**

```typescript
// components.json
{
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  }
}
```

## 📋 Lo que se Crea Automáticamente

```
proyecto/
├── .mcp.json                    ← Configuración MCP (ya existe)
├── components.json              ← Configuración Shadcn CLI
├── components/
│   └── ui/                      ← Componentes instalados
├── lib/
│   └── utils.ts                 ← Utilidades Shadcn
├── tailwind.config.ts           ← Configuración Tailwind
└── app/globals.css              ← Estilos base
```

**Configuración Tailwind automática:**

```javascript
// tailwind.config.ts
import type { Config } from "tailwindcss"

const config = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  prefix: "",
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        // ... más variables CSS
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config

export default config
```

## 🔄 Workflow Profesional

### **1. Exploración con MCP**

```
Claude, explora los componentes disponibles para un sistema de gestión de usuarios
```

### **2. Configuración del Proyecto**

```bash
# Usando setup automático
bash dev-tools/shadcn/cli/setup-cli.sh
```

### **3. Instalación Masiva**

```
Claude, instala todos los componentes necesarios para formularios complejos
```

### **4. Customización del Design System**

```
Claude, configura el tema para seguir los principios de diseño del proyecto
```

## 🎨 Design System Integration

### **Principios de Diseño S-Tier**

- **Consistencia:** Design tokens unificados
- **Accesibilidad:** WCAG 2.2 AA como mínimo
- **Performance:** CSS optimizado y tree-shaking
- **Mantenibilidad:** Componentes modulares y reutilizables

### **Configuración del Tema**

```css
/* app/globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 0 0% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 0 0% 3.9%;
    --primary: 0 0% 9%;
    --primary-foreground: 0 0% 98%;
    /* ... más variables */
  }

  .dark {
    --background: 0 0% 3.9%;
    --foreground: 0 0% 98%;
    /* ... variables dark mode */
  }
}
```

## 🔧 Solución de Problemas

**"Claude no encuentra componentes"**

- Verifica que el MCP esté configurado en `.mcp.json`
- Reinicia Claude Code para recargar configuración MCP

**"Componentes no se muestran correctamente"**

- Verifica que Tailwind CSS esté configurado
- Asegúrate de que `globals.css` esté importado
- Revisa que las variables CSS estén definidas

**"Error en instalación CLI"**

- Ejecuta `npx shadcn@latest init` manualmente
- Verifica que el proyecto use Next.js, Vite o un framework compatible
- Revisa que TypeScript esté configurado

**"Conflictos de dependencias"**

- El script de setup maneja dependencias automáticamente
- Revisa `package.json` para conflictos de versiones
- Ejecuta `npm audit fix` si hay vulnerabilidades

## 🚀 Componentes Más Utilizados

### **Formularios**

```bash
npx shadcn@latest add form input button label
```

### **Navegación**

```bash
npx shadcn@latest add navigation-menu breadcrumb tabs
```

### **Data Display**

```bash
npx shadcn@latest add table card badge
```

### **Feedback**

```bash
npx shadcn@latest add alert-dialog toast alert
```

### **Layout**

```bash
npx shadcn@latest add separator accordion collapsible
```

## 📚 Referencias

- [Shadcn/ui Official](https://ui.shadcn.com)
- [Shadcn MCP](https://github.com/RafalWilinski/shadcn-mcp)
- [Claude Code + MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Design Principles](../../docs/design-principles.md)
