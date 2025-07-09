# Trivance Docker Setup

Isolated Docker environment for `ms_level_up_management` and `ms_trivance_auth` services.

## Quick Start

```bash
cd trivance-dev-config/docker
make up
```

Services will be available at:
- Management API: http://localhost:3000
- Auth Service: http://localhost:3001

## Available Commands

- `make up` - Start services
- `make down` - Stop services  
- `make logs` - View all logs
- `make rebuild` - Rebuild and restart
- `make status` - Check service status

## Override Environment Variables

1. Copy `.env.defaults` to `.env`:
   ```bash
   cp .env.defaults .env
   ```

2. Edit `.env` with your custom values (database URLs, API keys, etc.)

**Requirements**: Docker + docker-compose v2
