# Trivance Dev Config - Architecture Documentation

## Overview

This repository provides automated development environment configuration for the Trivance platform, consisting of 4 interconnected services:

- **ms_trivance_auth** - Authentication service (NestJS)
- **ms_level_up_management** - Management API with GraphQL (NestJS)
- **level_up_backoffice** - Admin frontend (React/Vite)
- **trivance-mobile** - Mobile application (React Native/Expo)

## Directory Structure

```
trivance-dev-config/
├── config/              # Configuration files
│   ├── environments.json    # Environment variables for all services
│   └── repositories.json    # Repository URLs and branches
├── docs/                # Additional documentation
├── scripts/             # Automation scripts
│   ├── core/           # Main orchestration scripts
│   │   └── orchestrator.sh  # Main setup script
│   ├── utils/          # Utility scripts
│   │   ├── clean-workspace.sh      # Workspace cleanup
│   │   ├── common.sh               # Shared functions
│   │   ├── generate-secrets.sh     # Dynamic secret generation
│   │   ├── parallel-install.sh     # Parallel npm install
│   │   ├── post-setup-fixes.sh     # Post-installation fixes
│   │   └── verify-compilation.sh   # Build verification
│   └── envs.sh         # Environment management
├── templates/          # Configuration templates
├── setup.sh           # Main entry point
├── start-all.sh       # PM2-based service orchestration
└── status.sh          # Service status monitoring
```

## Key Features

### 1. Automated Setup
- Clones all 4 repositories
- Configures environment variables
- Installs dependencies in parallel
- Verifies compilation
- Sets up development tools

### 2. Process Management
- PM2 integration for automatic service management
- Automatic restart on failure
- Centralized logging
- Resource monitoring

### 3. Environment Management
- Dynamic secret generation for security
- Environment switching (local/qa/production)
- Template-based configuration

### 4. Developer Experience
- Single command setup
- Health checks and monitoring
- Professional error handling
- Cross-platform compatibility

## Usage

### Initial Setup
```bash
./setup.sh
```

### Start Services
```bash
./start.sh  # or ./start-all.sh
```

### Check Status
```bash
./status.sh
```

### Manage Environments
```bash
./change-env.sh status        # Show current environment
./change-env.sh switch qa     # Switch to QA environment
```

## Technical Decisions

### PM2 for Process Management
- Provides automatic restart capabilities
- Centralizes logs outside of project repositories
- Offers monitoring and resource management
- Industry standard for Node.js process management

### Parallel Installation
- Reduces setup time from ~15 minutes to ~3 minutes
- Timeout protection prevents hanging installations
- Progress indication for better UX

### Dynamic Secret Generation
- Unique secrets per installation
- Prevents credential leakage
- Development-safe defaults

### Shell Compatibility
- POSIX-compliant scripts where possible
- Explicit bash shebang for advanced features
- macOS/Linux cross-compatibility

## Security Considerations

1. **No hardcoded production credentials**
2. **Generated secrets for development**
3. **Environment isolation**
4. **Gitignore patterns for sensitive files**

## Maintenance

### Adding New Services
1. Update `config/repositories.json`
2. Add environment template in `config/environments.json`
3. Update PM2 configuration in `start-all.sh`

### Updating Dependencies
Run setup again to pull latest changes:
```bash
./setup.sh
```

## Troubleshooting

### Service Won't Start
- Check logs: `pm2 logs [service-name]`
- Verify ports are available: `./status.sh`
- Restart service: `pm2 restart [service-name]`

### Installation Timeout
- Clear npm cache: `npm cache clean --force`
- Remove node_modules and retry
- Check network connectivity

### Environment Issues
- Verify `.env` files exist in each service
- Check environment templates in `envs/`
- Regenerate secrets if needed