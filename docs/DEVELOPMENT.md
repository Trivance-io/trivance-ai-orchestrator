# 🔧 Guía de Desarrollo Avanzado

Herramientas y comandos para desarrollo profesional con Trivance.

## 🧪 Testing

### Backend (NestJS + Jest)
```bash
cd ms_level_up_management
npm test                    # Unit tests
npm run test:watch          # Watch mode
npm run test:cov            # Con cobertura
npm run test:e2e           # End-to-end
```

### Frontend (React + Vitest)  
```bash
cd level_up_backoffice
npm test                    # Unit tests
```

### Mobile (React Native)
```bash
cd trivance-mobile
npm run type-check          # TypeScript validation
npm run lint                # ESLint validation
```

## 🎨 Linting y Formateo

Cada repositorio incluye configuración estándar:

```bash
npm run lint               # ESLint
npm run lint:fix          # ESLint con auto-fix
npm run format            # Prettier
npm run type-check        # TypeScript check
```

## 🗄️ Base de Datos (Prisma)

### Comandos Management API
```bash
cd ms_level_up_management
npx prisma migrate dev      # Nueva migración
npx prisma generate         # Regenerar cliente
npx prisma studio          # GUI de base de datos
npx prisma db push         # Sincronizar schema
```

## 🐳 Docker Avanzado

### Smart Docker Manager
```bash
cd trivance-dev-config/scripts/utils
./smart-docker-manager.sh dev ../../docker/docker-compose.dev.yml   # Con hot-reload
./smart-docker-manager.sh logs ../../docker/docker-compose.dev.yml  # Ver logs
./smart-docker-manager.sh restart ../../docker/docker-compose.dev.yml [servicio]
```

### Docker Directo
```bash
cd trivance-dev-config/docker
docker compose -f docker-compose.dev.yml logs -f        # Ver logs
docker compose -f docker-compose.dev.yml down           # Detener contenedores
```

## 🔧 Resolución de Problemas

### Docker no funciona
1. Abre Docker Desktop
2. Espera que diga "Running"
3. Intenta de nuevo

### Puerto ocupado
```bash
# Ver qué lo usa
lsof -i:5173

# Detener servicios node
killall node

# Reiniciar
./start.sh stop && ./start.sh start
```

### Reset completo
```bash
cd trivance-dev-config
./scripts/utils/clean-workspace.sh
./setup.sh
```

## 📊 Observabilidad Avanzada

Ver documentación detallada en [`OBSERVABILITY.md`](OBSERVABILITY.md).

## 🚀 Hot-Reload Garantizado

- **Frontend Web**: ≤1s (Vite + PM2)
- **Management API**: ≤2s (Docker volumes)
- **Auth Service**: ≤2s (Docker volumes)
- **Mobile App**: ≤1s (Metro bundler + Expo)

## 📚 Más Información

- Arquitectura detallada: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Sistema de environments: [`ENVIRONMENTS.md`](ENVIRONMENTS.md)
- Problemas específicos: [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)