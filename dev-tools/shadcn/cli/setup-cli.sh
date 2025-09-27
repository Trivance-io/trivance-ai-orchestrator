#!/usr/bin/env bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones helper
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en la raíz del proyecto
if [[ ! -f "package.json" ]]; then
    log_error "Debe ejecutarse desde la raíz del proyecto (donde está package.json)"
    exit 1
fi

log_info "Configurando Shadcn/ui para desarrollo profesional..."

# 1. Verificar Node.js version
NODE_VERSION=$(node --version | cut -d 'v' -f 2)
REQUIRED_VERSION="18.0.0"

if ! command -v node &> /dev/null; then
    log_error "Node.js no está instalado"
    exit 1
fi

log_info "Node.js version: $NODE_VERSION"

# 2. Detectar framework
FRAMEWORK="unknown"
if grep -q '"next"' package.json; then
    FRAMEWORK="nextjs"
    log_info "Framework detectado: Next.js"
elif grep -q '"vite"' package.json; then
    FRAMEWORK="vite"
    log_info "Framework detectado: Vite"
elif grep -q '"react"' package.json; then
    FRAMEWORK="react"
    log_info "Framework detectado: React"
else
    log_warning "Framework no detectado automáticamente"
fi

# 3. Verificar TypeScript
if [[ -f "tsconfig.json" ]]; then
    log_success "TypeScript configurado"
else
    log_warning "TypeScript no detectado - se recomienda para Shadcn/ui"
fi

# 4. Verificar Tailwind CSS
if grep -q '"tailwindcss"' package.json; then
    log_success "Tailwind CSS detectado"
else
    log_warning "Tailwind CSS no detectado - es requerido para Shadcn/ui"
    read -p "¿Instalar Tailwind CSS? (y/N): " install_tailwind
    if [[ $install_tailwind =~ ^[Yy]$ ]]; then
        log_info "Instalando Tailwind CSS..."
        npm install -D tailwindcss postcss autoprefixer
        npx tailwindcss init -p
        log_success "Tailwind CSS instalado"
    fi
fi

# 5. Verificar/Instalar Shadcn CLI
if ! command -v shadcn &> /dev/null; then
    log_info "Shadcn CLI no encontrado - instalando globalmente..."
    npm install -g shadcn@latest
    log_success "Shadcn CLI instalado"
else
    log_success "Shadcn CLI ya está instalado"
fi

# 6. Verificar configuración de Shadcn
if [[ -f "components.json" ]]; then
    log_success "Shadcn ya está configurado (components.json existe)"
else
    log_info "Inicializando Shadcn/ui..."

    # Determinar configuración basada en framework
    case $FRAMEWORK in
        "nextjs")
            npx shadcn@latest init --yes --style new-york --color neutral --ts
            ;;
        "vite")
            npx shadcn@latest init --yes --style new-york --color neutral --ts --src-dir src
            ;;
        *)
            npx shadcn@latest init
            ;;
    esac

    log_success "Shadcn/ui inicializado"
fi

# 7. Crear directorios necesarios
log_info "Creando estructura de directorios..."
mkdir -p components/ui
mkdir -p lib
mkdir -p hooks

# 8. Instalar componentes core
log_info "¿Instalar componentes básicos? (button, input, card, etc.)"
read -p "Instalar componentes core? (Y/n): " install_core
if [[ $install_core =~ ^[Yy]$ ]] || [[ -z $install_core ]]; then
    log_info "Instalando componentes core..."

    # Componentes esenciales
    npx shadcn@latest add button input label
    npx shadcn@latest add card separator
    npx shadcn@latest add alert toast

    log_success "Componentes core instalados"
fi

# 9. Configurar CSS variables si no existe
GLOBALS_CSS=""
if [[ $FRAMEWORK == "nextjs" ]]; then
    GLOBALS_CSS="app/globals.css"
elif [[ -f "src/index.css" ]]; then
    GLOBALS_CSS="src/index.css"
elif [[ -f "src/App.css" ]]; then
    GLOBALS_CSS="src/App.css"
fi

if [[ -n $GLOBALS_CSS ]] && [[ -f $GLOBALS_CSS ]]; then
    if ! grep -q "@layer base" $GLOBALS_CSS; then
        log_info "Configurando CSS variables en $GLOBALS_CSS..."
        echo "" >> $GLOBALS_CSS
        echo "/* Shadcn/ui CSS Variables */" >> $GLOBALS_CSS
        echo "@layer base {" >> $GLOBALS_CSS
        echo "  :root {" >> $GLOBALS_CSS
        echo "    --background: 0 0% 100%;" >> $GLOBALS_CSS
        echo "    --foreground: 0 0% 3.9%;" >> $GLOBALS_CSS
        echo "    --muted: 0 0% 96.1%;" >> $GLOBALS_CSS
        echo "    --muted-foreground: 0 0% 45.1%;" >> $GLOBALS_CSS
        echo "    --border: 0 0% 89.8%;" >> $GLOBALS_CSS
        echo "    --input: 0 0% 89.8%;" >> $GLOBALS_CSS
        echo "    --ring: 0 0% 3.9%;" >> $GLOBALS_CSS
        echo "    --radius: 0.5rem;" >> $GLOBALS_CSS
        echo "  }" >> $GLOBALS_CSS
        echo "}" >> $GLOBALS_CSS
        log_success "CSS variables configuradas"
    fi
fi

# 10. Crear ejemplo de uso
log_info "¿Crear ejemplo de componente? (Y/n)"
read -p "Crear ejemplo? (Y/n): " create_example
if [[ $create_example =~ ^[Yy]$ ]] || [[ -z $create_example ]]; then
    EXAMPLE_FILE="components/example-card.tsx"
    cat > $EXAMPLE_FILE << 'EOF'
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

export function ExampleCard() {
  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Shadcn/ui Setup</CardTitle>
        <CardDescription>Componentes listos para usar</CardDescription>
      </CardHeader>
      <CardContent>
        <form>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="name">Nombre</Label>
              <Input id="name" placeholder="Tu nombre" />
            </div>
          </div>
        </form>
        <div className="flex justify-between pt-4">
          <Button variant="outline">Cancelar</Button>
          <Button>Continuar</Button>
        </div>
      </CardContent>
    </Card>
  )
}
EOF
    log_success "Ejemplo creado en $EXAMPLE_FILE"
fi

# 11. Verificar instalación
log_info "Verificando instalación..."

# Verificar que shadcn funciona
if npx shadcn@latest --version &> /dev/null; then
    log_success "Shadcn CLI funcional"
else
    log_error "Problema con Shadcn CLI"
fi

# Verificar components.json
if [[ -f "components.json" ]]; then
    log_success "Configuración completada"
else
    log_error "components.json no encontrado"
fi

# 12. Resumen y próximos pasos
echo ""
log_success "🎉 Shadcn/ui configurado exitosamente!"
echo ""
echo "📋 Resumen de configuración:"
echo "  - Framework: $FRAMEWORK"
echo "  - TypeScript: $([ -f tsconfig.json ] && echo "✅" || echo "❌")"
echo "  - Tailwind CSS: $(grep -q tailwindcss package.json && echo "✅" || echo "❌")"
echo "  - Shadcn CLI: ✅"
echo "  - components.json: $([ -f components.json ] && echo "✅" || echo "❌")"

echo ""
echo "🎯 Próximos pasos:"
echo "  1. Importa y usa componentes en tu aplicación"
echo "  2. Personaliza el tema en components.json"
echo "  3. Agrega más componentes: npx shadcn@latest add [component]"
echo ""
echo "📚 Documentación:"
echo "  - Guía completa: dev-tools/shadcn/README.md"
echo "  - Componentes: https://ui.shadcn.com"
echo "  - Roadmap: dev-tools/shadcn/TODO.md"

echo ""
log_success "Setup CLI completado. ¡Shadcn/ui está listo para usar!"