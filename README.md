# Trivance Dev Config

Professional automated development environment configuration for the Trivance platform.

## Overview

This repository provides enterprise-grade automated setup for the complete Trivance development environment:

- **ms_trivance_auth** - Authentication service (NestJS, Port 3001)
- **ms_level_up_management** - Management API with GraphQL (NestJS, Port 3000)
- **level_up_backoffice** - Admin frontend (React/Vite, Port 5173)
- **trivance-mobile** - Mobile application (React Native/Expo, Port 8081)

## Key Features

- ✅ **Zero Manual Configuration** - Fully automated setup
- ✅ **Secure by Default** - Dynamic secret generation, no hardcoded credentials
- ✅ **Production-Ready** - PM2 process management with auto-restart
- ✅ **AI-First Design** - Optimized for AI-assisted development workflows
- ✅ **Cross-Platform** - Compatible with macOS and Linux
- ✅ **Validated Setup** - Automated tests ensure everything works

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/GLab-Projects/trivance-dev-config
cd trivance-dev-config

# 2. Run automated setup (takes ~5-10 minutes)
./setup.sh

# 3. Start all services
./start-all.sh
```

That's it! All services are now running with PM2 process management.

## Prerequisites

The setup script automatically validates these requirements:

- **Node.js 18+** (required)
- **npm 8+** (required)
- **Git 2+** (required)
- **PostgreSQL** (recommended - Management API will fail without it)
- **MongoDB** (recommended - Auth Service will fail without it)

Missing prerequisites will be clearly reported during setup.

## Available Commands

### Core Commands
- `./setup.sh` - Complete automated setup with validation
- `./start-all.sh` - Start all services with PM2
- `./status.sh` - Check service health and status

### Environment Management
- `./change-env.sh status` - Show current environment
- `./change-env.sh switch [env]` - Switch environment (local/qa/production)
- `./change-env.sh validate` - Validate environment configuration
- `./change-env.sh sync` - Sync with environments.json

### PM2 Process Management
- `pm2 status` - View service status
- `pm2 logs` - View real-time logs
- `pm2 restart all` - Restart all services
- `pm2 stop all` - Stop all services
- `pm2 monit` - Interactive monitoring dashboard

## Service URLs

Once running, services are available at:

- **Auth API**: http://localhost:3001
- **Management API**: http://localhost:3000
- **GraphQL Playground**: http://localhost:3000/graphql
- **Admin Frontend**: http://localhost:5173
- **Mobile Metro**: http://localhost:8081 (optional)

## Security

### Automatic Secret Generation
- Unique development secrets generated per installation
- Stored in `.trivance-secrets` (gitignored)
- No hardcoded credentials in the repository

### Environment Isolation
- Separate configurations for local/qa/production
- Production credentials must be manually configured
- All sensitive files properly gitignored

## What Gets Configured

### During Setup
1. **Repository Cloning** - All 4 repositories with correct branches
2. **Secret Generation** - Unique JWT secrets, API keys, encryption keys
3. **Environment Files** - `.env` files for each service with secure values
4. **Dependencies** - Parallel installation with 3-minute timeout protection
5. **Compilation Check** - Ensures all services build successfully
6. **Validation Tests** - 9 automated tests verify setup completeness

### Process Management
- PM2 configuration with automatic restart on failure
- Centralized logging in `logs/pm2/`
- Memory limits and resource monitoring
- Zero-downtime reload capability

## Project Structure

```
workspace/
├── trivance-dev-config/    # This configuration repository
├── ms_trivance_auth/       # Auth service
├── ms_level_up_management/ # Management API  
├── level_up_backoffice/    # Admin frontend
├── trivance-mobile/        # Mobile app
├── logs/                   # Centralized PM2 logs
├── envs/                   # Environment configurations
└── .trivance-secrets       # Generated secrets (gitignored)
```

## Troubleshooting

### Quick Fixes
```bash
# Run automated validation
./scripts/utils/validate-setup.sh

# Check detailed logs
pm2 logs --lines 100

# Restart specific service
pm2 restart [service-name]
```

### Common Issues

**PostgreSQL/MongoDB not found**
- Services will fail to start without databases
- Install with: `brew install postgresql mongodb-community` (macOS)

**Port already in use**
- The setup handles this automatically
- Manual fix: `lsof -i:[port]` then `kill -9 [PID]`

**Service won't start**
- Check logs: `pm2 logs [service-name]`
- Validate environment: `./change-env.sh validate`

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for detailed solutions.

## For AI-Assisted Development

This repository is optimized for AI-first workflows:

1. **Clear Command Structure** - All commands are simple and unambiguous
2. **Predictable File Locations** - Consistent structure across all services
3. **Comprehensive Validation** - AI can verify setup success
4. **No Manual Steps** - Everything is automated
5. **Professional Error Handling** - Clear error messages for debugging

### AI Usage Example
```bash
# AI can simply run these 3 commands:
git clone https://github.com/GLab-Projects/trivance-dev-config
cd trivance-dev-config
./setup.sh && ./start-all.sh
```

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md) - Technical architecture details
- [Environment Management](docs/ENVIRONMENTS.md) - Managing multiple environments
- [Deployment Guide](docs/DEPLOYMENT.md) - Deployment procedures
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and solutions

## Requirements

### Minimum Versions
- Node.js 18.0.0+
- npm 8.0.0+
- Git 2.0.0+

### Database Requirements
- PostgreSQL (for Management API)
- MongoDB (for Auth Service)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Run validation tests: `./scripts/utils/validate-setup.sh`
4. Commit your changes
5. Push to the branch
6. Create a Pull Request

## License

This project is proprietary and confidential.

---

**Note**: This is a development configuration tool. For production deployment, see the [Deployment Guide](docs/DEPLOYMENT.md).