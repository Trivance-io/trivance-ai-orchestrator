# Environment Management Guide

## Overview

The Trivance platform uses a centralized environment management system that allows easy switching between different environments (local, qa, production) while maintaining consistency across all services.

## Environment Structure

Each environment consists of separate `.env` files for each service:
- `[env].ms_trivance_auth.env`
- `[env].ms_level_up_management.env`
- `[env].level_up_backoffice.env`
- `[env].trivance-mobile.env`

## Available Commands

### Check Current Environment
```bash
./change-env.sh status
```

Shows the currently active environment and lists all available environments.

### Switch Environment
```bash
./change-env.sh switch local
./change-env.sh switch qa
./change-env.sh switch production
```

Switches all services to the specified environment by copying the appropriate `.env` files.

### Validate Environment
```bash
./change-env.sh validate
```

Validates that all required environment variables are present for each service.

### Sync with Configuration
```bash
./change-env.sh sync
```

Synchronizes environment files with the master configuration in `config/environments.json`.

## Environment Files Location

All environment files are stored in:
```
workspace/
└── envs/
    ├── local.ms_trivance_auth.env
    ├── local.ms_level_up_management.env
    ├── local.level_up_backoffice.env
    ├── local.trivance-mobile.env
    ├── qa.ms_trivance_auth.env
    ├── qa.ms_level_up_management.env
    └── ... (other environments)
```

## Configuration File

The master configuration is stored in `config/environments.json`:

```json
{
  "environments": {
    "ms_trivance_auth": {
      "PORT": "3001",
      "DB_MONGO": "mongodb://localhost:27017/trivance_auth_development",
      // ... other variables
    },
    "ms_level_up_management": {
      "PORT": "3000",
      "DATABASE_URL": "postgresql://...",
      // ... other variables
    }
    // ... other services
  }
}
```

## Adding New Environment Variables

1. Update `config/environments.json` with the new variable
2. Run sync to update environment files:
   ```bash
   ./change-env.sh sync
   ```
3. Restart the affected service:
   ```bash
   pm2 restart [service-name]
   ```

## Creating a New Environment

1. Add the new environment configuration to `config/environments.json`
2. Run setup to create the environment files:
   ```bash
   ./change-env.sh setup
   ```
3. Switch to the new environment:
   ```bash
   ./change-env.sh switch [new-env]
   ```

## Security Considerations

### Local Development
- Uses generated development secrets
- Safe defaults for local testing
- No production credentials

### QA Environment
- Requires manual configuration
- Use dedicated QA credentials
- Never use production data

### Production Environment
- Highly restricted access
- Separate credential management
- Regular secret rotation
- Never commit production values

## Best Practices

1. **Never commit `.env` files** - They are gitignored for security
2. **Use descriptive variable names** - Follow the existing naming convention
3. **Document new variables** - Add comments in `environments.json`
4. **Validate after changes** - Always run validation after modifications
5. **Keep environments isolated** - Don't mix credentials between environments

## Common Issues

### Environment not switching
- Ensure all services are stopped before switching
- Check file permissions in the envs directory
- Verify the environment exists

### Missing variables after sync
- Check `config/environments.json` for syntax errors
- Ensure all required services are defined
- Run validation to identify missing variables

### Service using wrong environment
- Restart the service after switching: `pm2 restart [service-name]`
- Verify `.env` file exists in service directory
- Check PM2 logs for environment loading errors

## Environment Variables Reference

### Authentication Service (ms_trivance_auth)
- `PORT` - Service port (default: 3001)
- `DB_MONGO` - MongoDB connection string
- `JWTSECRET` - JWT signing secret
- `PASSWORDSECRET` - Password encryption secret
- Additional OAuth and Twilio variables

### Management API (ms_level_up_management)
- `PORT` - Service port (default: 3000)
- `DATABASE_URL` - PostgreSQL connection string
- `JWTSECRET` - JWT signing secret
- GraphQL configuration
- Payment gateway credentials
- AWS S3 configuration

### Frontend (level_up_backoffice)
- `VITE_API_URL` - Management API URL
- `VITE_AUTH_API_URL` - Auth API URL
- `VITE_GRAPHQL_URL` - GraphQL endpoint
- `VITE_ENVIRONMENT` - Current environment name

### Mobile (trivance-mobile)
- `EXPO_PUBLIC_API_URL` - Management API URL
- `EXPO_PUBLIC_AUTH_API_URL` - Auth API URL
- `EXPO_PUBLIC_GRAPHQL_URL` - GraphQL endpoint
- `EXPO_PUBLIC_ENVIRONMENT` - Current environment name