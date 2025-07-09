# Deployment Guide

## Overview

This guide covers deployment procedures for all Trivance platform environments.

## Environments

### Local Development (Default)
- Automatically configured during setup
- Uses dynamically generated secrets
- All services run on localhost

### QA Environment
- Requires manual configuration
- Update `config/environments.json` with QA values
- Switch using: `./change-env.sh switch qa`

### Production Environment
- Highly restricted, manual configuration only
- Never commit production credentials
- Use secure secret management (Vault, AWS Secrets Manager, etc.)

## Local Development Setup

### Initial Setup
```bash
# Clone and setup
git clone https://github.com/GLab-Projects/trivance-dev-config
cd trivance-dev-config
./setup.sh

# Start all services
./start-all.sh
```

### Service Management with PM2

#### Start All Services
```bash
./start-all.sh
```

#### Check Status
```bash
pm2 status
./status.sh  # Enhanced status with health checks
```

#### View Logs
```bash
pm2 logs              # All services
pm2 logs auth-service # Specific service
pm2 logs --lines 100  # Last 100 lines
```

#### Restart Services
```bash
pm2 restart all
pm2 restart management-api
```

#### Stop Services
```bash
pm2 stop all
pm2 kill  # Stop PM2 daemon
```

## Database Setup

### PostgreSQL (Management Service)
```bash
# macOS
brew services start postgresql
createdb trivance_development
createuser trivance_dev -P  # Password: trivance_dev_pass

# Linux
sudo systemctl start postgresql
sudo -u postgres createdb trivance_development
sudo -u postgres createuser trivance_dev -P
```

### MongoDB (Auth Service)
```bash
# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

## Environment Configuration

### Switching Environments
```bash
# View current environment
./change-env.sh status

# Switch to QA
./change-env.sh switch qa

# Validate configuration
./change-env.sh validate
```

### Adding New Environment Variables
1. Update `config/environments.json`
2. Sync environment files:
   ```bash
   ./change-env.sh sync
   ```
3. Restart affected services:
   ```bash
   pm2 restart [service-name]
   ```

## Security Best Practices

### Development
- Secrets are auto-generated in `.trivance-secrets`
- Never commit `.trivance-secrets` or `.env` files
- Use unique secrets per developer

### QA/Staging
- Use dedicated QA credentials
- Rotate secrets regularly
- Limit access to QA environment

### Production
- Use professional secret management
- Enable audit logging
- Implement least privilege access
- Regular security audits

## Monitoring

### Health Checks
```bash
# Quick health check
./status.sh

# Detailed PM2 monitoring
pm2 monit
```

### Performance Monitoring
```bash
# View resource usage
pm2 describe [service-name]

# Real-time monitoring
pm2 monit
```

## Troubleshooting Deployment

### Service Won't Start
1. Check logs: `pm2 logs [service-name]`
2. Verify environment variables: `./change-env.sh validate`
3. Check port availability: `lsof -i:[port]`

### Database Connection Failed
1. Verify database is running
2. Check connection strings in `.env`
3. Ensure database exists and user has permissions

### Memory Issues
Edit PM2 configuration in `start-all.sh`:
```javascript
max_memory_restart: '2G'  // Increase from 1G
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      - name: Install PM2
        run: npm install -g pm2
      - name: Deploy
        run: |
          ./setup.sh
          pm2 start ecosystem.config.js
          pm2 save
```

## Production Deployment Checklist

- [ ] All tests passing
- [ ] Security audit completed
- [ ] Production secrets configured
- [ ] Database migrations ready
- [ ] Monitoring configured
- [ ] Backup strategy in place
- [ ] Rollback plan documented
- [ ] Load testing completed
- [ ] SSL certificates valid
- [ ] CORS properly configured