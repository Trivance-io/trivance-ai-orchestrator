# Troubleshooting Guide

## Common Issues and Solutions

### Setup Issues

#### npm install hangs or times out
**Problem**: Installation gets stuck during setup

**Solutions**:
1. Clear npm cache:
   ```bash
   npm cache clean --force
   ```
2. Use different npm registry:
   ```bash
   npm config set registry https://registry.npmjs.org/
   ```
3. Remove node_modules and package-lock.json:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

#### Git clone fails
**Problem**: Cannot clone repositories during setup

**Solutions**:
1. Check GitHub access:
   ```bash
   ssh -T git@github.com
   ```
2. Use HTTPS instead of SSH:
   ```bash
   git config --global url."https://".insteadOf git://
   ```
3. Check network/firewall settings

### Service Startup Issues

#### Service won't start with PM2
**Problem**: Service shows as "errored" in pm2 status

**Solutions**:
1. Check logs:
   ```bash
   pm2 logs [service-name]
   ```
2. Check if port is already in use:
   ```bash
   lsof -i :[port]
   # Kill the process if needed
   kill -9 [PID]
   ```
3. Restart the service:
   ```bash
   pm2 delete [service-name]
   pm2 start ecosystem.config.js --only [service-name]
   ```

#### All services crash immediately
**Problem**: Services start but crash within seconds

**Solutions**:
1. Check environment variables:
   ```bash
   ./change-env.sh validate
   ```
2. Ensure databases are running:
   ```bash
   # PostgreSQL
   brew services start postgresql  # macOS
   sudo systemctl start postgresql # Linux
   
   # MongoDB
   brew services start mongodb-community  # macOS
   sudo systemctl start mongod # Linux
   ```
3. Check Node.js version:
   ```bash
   node --version  # Should be 18+
   ```

### Database Connection Issues

#### PostgreSQL connection refused
**Problem**: Management API cannot connect to PostgreSQL

**Solutions**:
1. Verify PostgreSQL is running:
   ```bash
   pg_isready
   ```
2. Check connection string in `.env`:
   ```
   DATABASE_URL=postgresql://trivance_dev:trivance_dev_pass@localhost:5432/trivance_development
   ```
3. Create database and user:
   ```bash
   psql postgres
   CREATE DATABASE trivance_development;
   CREATE USER trivance_dev WITH PASSWORD 'trivance_dev_pass';
   GRANT ALL PRIVILEGES ON DATABASE trivance_development TO trivance_dev;
   ```

#### MongoDB connection failed
**Problem**: Auth service cannot connect to MongoDB

**Solutions**:
1. Verify MongoDB is running:
   ```bash
   mongosh --eval "db.adminCommand('ping')"
   ```
2. Check connection string:
   ```
   DB_MONGO=mongodb://localhost:27017/trivance_auth_development
   ```
3. Ensure MongoDB is accepting connections:
   ```bash
   mongosh
   use trivance_auth_development
   db.createCollection("test")
   ```

### PM2 Specific Issues

#### PM2 command not found
**Problem**: PM2 is not available after installation

**Solutions**:
1. Install PM2 globally:
   ```bash
   npm install -g pm2
   ```
2. Check npm global path:
   ```bash
   npm config get prefix
   # Add to PATH if needed
   export PATH=$PATH:$(npm config get prefix)/bin
   ```

#### PM2 logs are empty
**Problem**: No logs showing in PM2

**Solutions**:
1. Check log file permissions:
   ```bash
   ls -la logs/pm2/
   ```
2. Flush PM2 logs:
   ```bash
   pm2 flush
   pm2 restart all
   ```
3. Check ecosystem.config.js for correct log paths

### Frontend Issues

#### Vite dev server not accessible
**Problem**: Cannot access http://localhost:5173

**Solutions**:
1. Check if Vite is using a different port:
   ```bash
   pm2 logs backoffice | grep "Local:"
   ```
2. Clear Vite cache:
   ```bash
   cd level_up_backoffice
   rm -rf node_modules/.vite
   pm2 restart backoffice
   ```
3. Check for port conflicts:
   ```bash
   lsof -i :5173
   ```

#### GraphQL Playground not loading
**Problem**: http://localhost:3000/graphql shows error

**Solutions**:
1. Verify Management API is running:
   ```bash
   pm2 status management-api
   ```
2. Check GraphQL is enabled in development:
   ```bash
   # In .env file
   NODE_ENV=development
   ```
3. Check browser console for CORS errors

### Mobile Development Issues

#### Metro bundler not starting
**Problem**: React Native Metro bundler fails

**Solutions**:
1. Clear Metro cache:
   ```bash
   cd trivance-mobile
   npx react-native start --reset-cache
   ```
2. Clear watchman:
   ```bash
   watchman watch-del-all
   ```
3. Reinstall pods (iOS):
   ```bash
   cd ios && pod install
   ```

### Environment Issues

#### Wrong environment after switching
**Problem**: Services still using old environment values

**Solutions**:
1. Restart all services:
   ```bash
   pm2 restart all
   ```
2. Verify .env files were copied:
   ```bash
   ls -la ms_*/. env level_*/.env trivance-*/.env
   ```
3. Force reload:
   ```bash
   pm2 delete all
   ./start-all.sh
   ```

### Performance Issues

#### Services running slowly
**Problem**: APIs responding slowly or timing out

**Solutions**:
1. Check system resources:
   ```bash
   pm2 monit
   ```
2. Increase memory limits in ecosystem.config.js:
   ```javascript
   max_memory_restart: '2G'  // Increase from 1G
   ```
3. Check for memory leaks:
   ```bash
   pm2 describe [service-name]
   ```

### Quick Fixes Script

For common issues, run the post-setup fixes:
```bash
cd trivance-dev-config
./scripts/utils/post-setup-fixes.sh
```

This script automatically:
- Fixes Sentry configuration issues
- Generates Firebase credentials
- Validates environment variables
- Checks port availability

### Getting More Help

1. **Check detailed logs**:
   ```bash
   pm2 logs --lines 100
   ```

2. **Enable debug mode**:
   ```bash
   DEBUG=* pm2 restart [service-name]
   ```

3. **System information**:
   ```bash
   pm2 report
   ```

4. **Clean restart**:
   ```bash
   pm2 kill
   pm2 start ecosystem.config.js
   ```

### Emergency Reset

If all else fails, perform a clean reset:
```bash
# Stop everything
pm2 kill

# Clean workspace (WARNING: This removes all repos!)
cd trivance-dev-config
./scripts/utils/clean-workspace.sh

# Start fresh
./setup.sh
./start-all.sh
```