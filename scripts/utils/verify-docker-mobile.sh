#!/bin/bash
# 📱 Script para verificar integración Docker + Mobile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔍 Verificando integración Docker + App Móvil"
echo "=============================================="

# 1. Verificar Docker
echo -e "\n${BLUE}1. Verificando Docker:${NC}"
if docker ps &>/dev/null 2>&1; then
    echo -e "  ${GREEN}✅ Docker está corriendo${NC}"
    
    # Verificar contenedores específicos
    if docker ps | grep -q "postgres"; then
        echo -e "  ${GREEN}✅ PostgreSQL está corriendo${NC}"
    else
        echo -e "  ${RED}❌ PostgreSQL NO está corriendo${NC}"
    fi
    
    if docker ps | grep -q "mongodb"; then
        echo -e "  ${GREEN}✅ MongoDB está corriendo${NC}"
    else
        echo -e "  ${RED}❌ MongoDB NO está corriendo${NC}"
    fi
    
    if docker ps | grep -q "ms_level_up_management"; then
        echo -e "  ${GREEN}✅ Management API está corriendo${NC}"
    else
        echo -e "  ${RED}❌ Management API NO está corriendo${NC}"
    fi
    
    if docker ps | grep -q "ms_trivance_auth"; then
        echo -e "  ${GREEN}✅ Auth Service está corriendo${NC}"
    else
        echo -e "  ${RED}❌ Auth Service NO está corriendo${NC}"
    fi
else
    echo -e "  ${RED}❌ Docker no está corriendo o no está instalado${NC}"
    exit 1
fi

# 2. Verificar APIs
echo -e "\n${BLUE}2. Verificando APIs:${NC}"
if curl -s http://localhost:3000/health &>/dev/null; then
    echo -e "  ${GREEN}✅ Management API responde en http://localhost:3000${NC}"
else
    echo -e "  ${RED}❌ Management API NO responde${NC}"
fi

if curl -s http://localhost:3001/api-docs &>/dev/null; then
    echo -e "  ${GREEN}✅ Auth Service responde en http://localhost:3001${NC}"
else
    echo -e "  ${RED}❌ Auth Service NO responde${NC}"
fi

# 3. Verificar configuración Mobile
echo -e "\n${BLUE}3. Verificando configuración Mobile:${NC}"
MOBILE_DIR="${WORKSPACE_DIR}/trivance-mobile"

if [[ -d "$MOBILE_DIR" ]]; then
    echo -e "  ${GREEN}✅ Directorio mobile existe${NC}"
    
    # Verificar archivos de configuración
    if [[ -f "$MOBILE_DIR/src/environments/env.local.ts" ]]; then
        echo -e "  ${GREEN}✅ env.local.ts existe${NC}"
        
        # Verificar URLs correctas
        if grep -q "http://localhost:3000" "$MOBILE_DIR/src/environments/env.local.ts"; then
            echo -e "  ${GREEN}✅ URL de Management API correcta${NC}"
        else
            echo -e "  ${RED}❌ URL de Management API incorrecta${NC}"
        fi
        
        if grep -q "http://localhost:3001" "$MOBILE_DIR/src/environments/env.local.ts"; then
            echo -e "  ${GREEN}✅ URL de Auth Service correcta${NC}"
        else
            echo -e "  ${RED}❌ URL de Auth Service incorrecta${NC}"
        fi
    else
        echo -e "  ${RED}❌ env.local.ts NO existe${NC}"
    fi
    
    # Verificar .env.local
    if [[ -f "$MOBILE_DIR/.env.local" ]]; then
        echo -e "  ${GREEN}✅ .env.local existe${NC}"
        
        if grep -q "ENV_LOCAL=true" "$MOBILE_DIR/.env.local"; then
            echo -e "  ${GREEN}✅ ENV_LOCAL está configurado correctamente${NC}"
        else
            echo -e "  ${YELLOW}⚠️  ENV_LOCAL no está en true${NC}"
        fi
    else
        echo -e "  ${YELLOW}⚠️  .env.local NO existe (usar npm run start:docker)${NC}"
    fi
    
    # Verificar scripts en package.json
    if grep -q "start:docker" "$MOBILE_DIR/package.json"; then
        echo -e "  ${GREEN}✅ Script start:docker está disponible${NC}"
    else
        echo -e "  ${RED}❌ Script start:docker NO está disponible${NC}"
    fi
else
    echo -e "  ${RED}❌ Directorio mobile NO existe${NC}"
fi

# 4. Instrucciones finales
echo -e "\n${BLUE}4. Próximos pasos:${NC}"
echo "  1. cd $MOBILE_DIR"
echo "  2. npm install (si no lo has hecho)"
echo "  3. npm run start:docker"
echo "  4. Escanea el QR con Expo Go"
echo ""
echo -e "${YELLOW}💡 Consejos:${NC}"
echo "  - El banner debe mostrar: 🎛️ LOCAL DOCKER | 📡 localhost:3000"
echo "  - Si usas Android Emulator, cambia localhost por 10.0.2.2"
echo "  - Para iOS físico, usa la IP de tu máquina en la red"

echo -e "\n${GREEN}✅ Verificación completa${NC}"