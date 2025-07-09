# 🎛️ Environment Configuration Guide

This repository is part of the **Trivance Platform** multi-repo workspace and uses a centralized environment management system.

## 📋 Environment Strategy

### Automated Configuration
- **Local Development**: Fully automated, zero manual configuration
- **QA/Staging**: Requires manual configuration of sensitive values
- **Production**: Requires security approval and manual setup

### Environment Files
- `.env` files are **auto-generated** from `trivance-dev-config`
- **DO NOT** manually edit `.env` files - they will be overwritten
- **DO NOT** commit `.env` files to version control

## 🚀 Quick Start

### 1. Initial Setup (One Time)
```bash
# From workspace root
./trivance-dev-config/setup.sh
```

### 2. Switch Environments
```bash
# From workspace root
./trivance-dev-config/scripts/envs.sh switch local    # Development
./trivance-dev-config/scripts/envs.sh switch qa       # QA/Staging
./trivance-dev-config/scripts/envs.sh switch production # Production
```

### 3. View Current Environment
```bash
./trivance-dev-config/scripts/envs.sh status
```

## 🔐 Security

### Development (Local)
- Secrets are auto-generated uniquely per installation
- Safe for local development
- Never use these values in production

### QA/Production
- Manual configuration required
- Store secrets in secure vault
- Follow company security policies

## 📖 Documentation

For complete environment documentation:
- `envs/ENVIRONMENTS.md` - Complete environment guide
- `trivance-dev-config/docs/` - Platform documentation

## ⚠️ Important Notes

1. **Never commit secrets** - All `.env` files are gitignored
2. **Use the central system** - Don't create custom env management
3. **Follow the workflow** - Use provided scripts for env switching

---

*This repository is managed by trivance-dev-config automated setup*