#!/bin/bash
# Trivance Platform - Service Status Monitor

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones
check_port() {
    local port=$1
    local service=$2
    
    if lsof -i:$port >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} $service (port $port): ${GREEN}RUNNING${NC}"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} $service (port $port): ${RED}STOPPED${NC}"
        return 1
    fi
}

check_url() {
    local url=$1
    local service=$2
    
    if curl -s -f -o /dev/null -m 3 "$url"; then
        echo -e "${GREEN}[OK]${NC} $service: ${GREEN}RESPONDING${NC}"
        return 0
    else
        echo -e "${YELLOW}[WARN]${NC} $service: ${YELLOW}NOT RESPONDING${NC}"
        return 1
    fi
}

main() {
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${BLUE}TRIVANCE PLATFORM - SERVICE STATUS${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo
    
    # Verificar puertos
    echo -e "${BLUE}Port Status:${NC}"
    check_port 3001 "Auth Service"
    check_port 3000 "Management API"
    check_port 5173 "Frontend"
    echo
    
    # Verificar URLs
    echo -e "${BLUE}Endpoint Health:${NC}"
    check_url "http://localhost:3001" "Auth API"
    check_url "http://localhost:3000" "Management API"
    check_url "http://localhost:3000/graphql" "GraphQL"
    check_url "http://localhost:5173" "Frontend"
    echo
    
    # Verificar PM2 si está disponible
    if command -v pm2 &> /dev/null; then
        echo -e "${BLUE}PM2 Process Status:${NC}"
        pm2 list
    fi
    
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
}

main