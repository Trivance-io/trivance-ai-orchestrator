# Trivance Development Configuration

Central configuration repository for Trivance Platform development environment.

## Prerequisites

**Required before setup:**
- Node.js 18+ and npm 8+
- Git with SSH key configured for GitHub
- SSH access to GLab-Projects repositories

**Optional for local services:**
- PostgreSQL (for ms_level_up_management)
- MongoDB (for ms_trivance_auth)

**Verify prerequisites:**
```bash
node --version    # Should be 18+
npm --version     # Should be 8+
ssh -T git@github.com    # Should show successful authentication
```

## AI-Readable Setup Instructions

**For Claude Code or other AI assistants:**

Execute these commands sequentially:

```bash
# Step 1: Clone configuration repository
git clone https://github.com/GLab-Projects/trivance-dev-config.git

# Step 2: Navigate to repository  
cd trivance-dev-config

# Step 3: Execute automated setup
./setup.sh

# Step 4: Configure environment variables (REQUIRED)
cd ../ms_level_up_management
cp .env.example .env
# Edit .env with actual values

cd ../ms_trivance_auth
cp .env.example .env  
# Edit .env with actual values

# Step 5: Start development services
cd ../
./scripts/start-all-services.sh

# Step 6: Validate installation
./scripts/check-health.sh
```

**The setup script automatically:**
- Clones all required repositories (ms_level_up_management, ms_trivance_auth, level_up_backoffice, trivance-mobile)
- Installs dependencies for all projects
- Creates .env.example files
- Sets up AI configurations (Claude Code, universal AI)
- Generates CLAUDE.md with complete AI context
- Generates workspace documentation
- Copies development scripts

## Manual Setup Instructions

### Quick Setup (3 commands)

```bash
git clone https://github.com/GLab-Projects/trivance-dev-config.git
cd trivance-dev-config
./setup.sh
```

**IMPORTANT**: After setup, configure environment variables before starting services.

### Step-by-Step Setup

1. **Clone configuration repository**
   ```bash
   git clone https://github.com/GLab-Projects/trivance-dev-config.git
   cd trivance-dev-config
   ```

2. **Run automated setup**
   ```bash
   ./setup.sh
   ```

3. **Configure environment variables (REQUIRED)**
   ```bash
   # Backend Management API
   cd ../ms_level_up_management
   cp .env.example .env
   nano .env    # Edit with actual database URLs, JWT secrets, AWS keys
   
   # Authentication Service
   cd ../ms_trivance_auth  
   cp .env.example .env
   nano .env    # Edit with actual MongoDB URL, JWT secrets
   
   # Frontend (optional - has defaults)
   cd ../level_up_backoffice
   cp .env.example .env.local    # If .env.example exists
   ```

4. **Start development services**
   ```bash
   cd ../    # Return to workspace root
   ./scripts/start-all-services.sh
   ```

5. **Validate installation**
   ```bash
   ./scripts/check-health.sh
   ```

## Environment Configuration Details

### Required Environment Variables

**ms_level_up_management (.env):**
```bash
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/trivance_management
JWT_SECRET=your-secure-jwt-secret-here
# Optional: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SENTRY_DSN
```

**ms_trivance_auth (.env):**
```bash
NODE_ENV=development  
PORT=3001
DATABASE_URL=mongodb://localhost:27017/trivance_auth
JWT_SECRET=your-secure-jwt-secret-here
BCRYPT_ROUNDS=12
```

**Frontend environment variables are auto-configured for local development.**

## Setup Time Estimates

### With This Automation
- **Prerequisites check**: 2 minutes
- **Repository cloning**: 3-5 minutes  
- **Dependencies installation**: 8-12 minutes
- **Environment configuration**: 5 minutes
- **First startup**: 2 minutes
- **Total time**: **20-26 minutes** for complete working environment

### Traditional Manual Setup
- **Repository cloning**: 10-15 minutes (manual, one by one)
- **Dependencies installation**: 15-20 minutes (manual, troubleshooting)
- **Configuration setup**: 30-45 minutes (research, trial and error)
- **Environment troubleshooting**: 30-60 minutes (common issues)
- **Documentation reading**: 45-60 minutes
- **Total time**: **2-3 hours** minimum, often more

### Time Savings
- **85% faster** setup process
- **Zero configuration research** required
- **Automated error prevention** eliminates common pitfalls
- **Ready-to-code** environment in under 30 minutes

## Post-Setup Workflow

After successful setup, your typical development workflow:

```bash
# Daily startup (30 seconds)
cd Trivance-platform
./scripts/start-all-services.sh

# Development URLs will be available at:
# Frontend: http://localhost:5173
# Backend API: http://localhost:3000  
# Auth Service: http://localhost:3001
# GraphQL: http://localhost:3000/graphql

# Daily shutdown
./scripts/stop-all-services.sh
```

## Repository Structure

```
trivance-dev-config/
├── setup.sh                    # Single command setup
├── config/
│   ├── repositories.json       # Repository definitions
│   └── environments.json       # Environment configurations
├── scripts/
│   ├── core/
│   │   └── orchestrator.sh     # Main setup logic
│   └── utils/
│       ├── logging.sh          # Logging utilities
│       └── validation.sh       # Validation functions
├── templates/
│   ├── dynamic/                # Self-adapting templates
│   └── static/                 # Fixed templates
├── .claude/                    # Claude Code configuration
├── .ai-config/                 # Universal AI configuration
└── docs/                       # Documentation
```

## Workspace Components

After setup, the parent directory will contain:

- `ms_level_up_management/` - Backend API (NestJS + GraphQL + PostgreSQL)
- `ms_trivance_auth/` - Authentication service (NestJS + MongoDB)
- `level_up_backoffice/` - Admin frontend (React + Vite)
- `trivance-mobile/` - Mobile app (React Native + Expo)
- `trivance-dev-config/` - This configuration repository

## Development Commands

```bash
# Workspace management (from workspace root directory)
./scripts/start-all-services.sh    # Start all services
./scripts/stop-all-services.sh     # Stop all services  
./scripts/check-health.sh          # Validate workspace

# Environment-specific
./scripts/start-all-services.sh local    # Local development (default)
./scripts/start-all-services.sh qa       # QA environment
```

## AI Configuration

The setup automatically configures AI assistants for optimal development:

### Workspace AI Context
- **CLAUDE.md**: Auto-generated comprehensive workspace context for AI assistants
- **Location**: Workspace root (generated during setup)
- **Contains**: Project structure, commands, development workflows, troubleshooting

### Claude Code
- Settings: `.claude/settings.json`
- Context: `.claude/context.md` 
- Commands: `.claude/commands.md`
- Prompts: `.claude/prompts.md`

### Universal AI
- Settings: `.ai-config/settings.json`
- Context: `.ai-config/context.md`
- Patterns: `.ai-config/patterns.md`

## Environment URLs

### Development (Local)
- Frontend: http://localhost:5173
- Backend API: http://localhost:3000
- Auth Service: http://localhost:3001
- GraphQL Playground: http://localhost:3000/graphql

### QA Environment
- Frontend: https://staging-admin.example.com
- Backend API: https://apiqa.example.com
- Auth Service: https://authqa.example.com

## Troubleshooting

### Common Issues

**Permission denied errors:**
```bash
chmod +x scripts/**/*.sh
```

**Port conflicts:**
```bash
./scripts/stop-all-services.sh
./scripts/check-health.sh
```

**Dependencies issues:**
```bash
# Reinstall dependencies in all repositories
cd ms_level_up_management && rm -rf node_modules && npm install
cd ../ms_trivance_auth && rm -rf node_modules && npm install  
cd ../level_up_backoffice && rm -rf node_modules && npm install
cd ../trivance-mobile && rm -rf node_modules && npm install
```

**Database connection issues:**
```bash
# PostgreSQL (for ms_level_up_management)
brew services start postgresql    # macOS
sudo systemctl start postgresql   # Linux

# MongoDB (for ms_trivance_auth)  
brew services start mongodb-community    # macOS
sudo systemctl start mongod              # Linux
```

**Git access issues:**
- Verify SSH key is configured: `ssh -T git@github.com`
- Should return: "Hi username! You've successfully authenticated"
- If failed, generate SSH key: `ssh-keygen -t ed25519 -C "your-email@example.com"`

### Validation Commands

```bash
# Check workspace health (primary validation)
./scripts/check-health.sh

# Check if all services are running
curl http://localhost:3000/health    # Backend API
curl http://localhost:3001/health    # Auth Service  
curl http://localhost:5173           # Frontend
```

## Documentation

- [Complete Onboarding Guide](docs/ONBOARDING.md)
- [Development Workflows](docs/WORKFLOWS.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

## Support

- **Slack**: #dev-support for technical assistance
- **Email**: Contact your development team for general inquiries
- **Issues**: Create GitHub Issues in this repository for bugs or feature requests

## Contributing

1. Fork this repository
2. Create feature branch
3. Test changes with complete setup flow
4. Submit pull request with detailed description

---

**Version**: 1.0.0  
**Last Updated**: 2025-07-03  
**Maintained By**: Trivance DevOps Team