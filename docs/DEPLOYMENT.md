# 🚀 Guía de Deployment - Trivance Platform

## 📋 Resumen Ejecutivo

Trivance Platform utiliza un **sistema híbrido de configuración**:

- **✅ Desarrollo Local**: 100% automático, sin configuración manual
- **⚠️ QA Environment**: Configuración manual requerida por seguridad  
- **🔒 Producción**: Configuración manual crítica con aprobación de seguridad

---

## 🔄 Flujo de Environments

```mermaid
graph LR
    A[Development<br/>🤖 Auto] --> B[QA<br/>⚙️ Manual] --> C[Production<br/>🔒 Manual]
    
    A --> |"git push origin develop"| B
    B --> |"Aprobación + git push origin main"| C
```

---

## 🖥️ Development Environment (Automático)

### ✅ Qué está Pre-configurado

El script de setup configura automáticamente:

- **URLs**: localhost con puertos estándar
- **Base de datos**: Credenciales locales predefinidas
- **JWT Secrets**: Secrets de desarrollo seguros
- **CORS**: Configurado para desarrollo local
- **Logging**: Debug mode habilitado
- **GraphQL**: Playground e introspection habilitados

### 🎯 Setup de Desarrollo

```bash
# 1. Clonar y configurar (100% automático)
mkdir -p Trivance-platform
cd Trivance-platform
git clone https://github.com/GLab-Projects/trivance-dev-config.git
./trivance-dev-config/setup.sh

# 2. Iniciar servicios (todo configurado)
./scripts/start-all-services.sh

# 3. Verificar que todo funciona
./scripts/check-health.sh
```

**🎉 ¡Ya está! El desarrollo local funciona inmediatamente.**

---

## ⚙️ QA Environment (Manual)

### 📋 Pre-requisitos para QA

Antes de configurar QA, asegúrate de tener:

- [ ] Infraestructura QA desplegada (servidores, bases de datos)
- [ ] Certificados SSL configurados
- [ ] Variables de entorno QA definidas por el equipo de infraestructura
- [ ] Acceso a servicios externos (AWS, Sentry, etc.) para QA

### 🔧 Configuración Manual de QA

#### 1. Variables de Entorno por Repositorio

Para cada repositorio (`ms_level_up_management`, `ms_trivance_auth`, `level_up_backoffice`):

```bash
# Editar archivo .env en cada repositorio
cd ms_level_up_management
cp .env .env.backup  # Backup de configuración dev

# Configurar para QA
cat > .env << EOF
# QA Environment Configuration
NODE_ENV=qa
PORT=3000

# URLs QA reales (proporcionadas por infraestructura)
API_BASE_URL=https://api-qa.trivance.com
AUTH_API_URL=https://auth-qa.trivance.com
FRONTEND_URL=https://staging-admin.trivance.com
GRAPHQL_URL=https://api-qa.trivance.com/graphql

# Base de datos QA (credenciales proporcionadas por DBA)
DATABASE_URL=postgresql://QA_USER:QA_SECURE_PASSWORD@qa-db.trivance.com:5432/trivance_qa

# JWT para QA (generar nuevo secret)
JWT_SECRET=$(openssl rand -base64 64)
JWT_EXPIRATION_TIME=1h

# AWS QA (credenciales proporcionadas por DevOps)
AWS_ACCESS_KEY_ID=AKIA...QA_KEY
AWS_SECRET_ACCESS_KEY=...QA_SECRET_KEY
AWS_REGION=us-east-1
AWS_S3_BUCKET=trivance-qa-uploads

# Monitoreo QA
SENTRY_DSN=https://...@sentry.io/project-qa
LOG_LEVEL=info

# Configuración QA
CORS_ORIGIN=https://staging-admin.trivance.com
GRAPHQL_PLAYGROUND=true
GRAPHQL_DEBUG=false
GRAPHQL_INTROSPECTION=true

# Rate limiting para QA
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=100
EOF
```

#### 2. Configuración por Tecnología

**Backend Management (ms_level_up_management)**:
```bash
# Configuración específica PostgreSQL + GraphQL
DATABASE_URL=postgresql://qa_mgmt_user:SECURE_PASS@qa-postgres.trivance.com:5432/trivance_management_qa
```

**Backend Auth (ms_trivance_auth)**:
```bash
# Configuración específica MongoDB + Auth
DATABASE_URL=mongodb://qa_auth_user:SECURE_PASS@qa-mongo.trivance.com:27017/trivance_auth_qa
```

**Frontend (level_up_backoffice)**:
```bash
# Variables específicas Vite/React
VITE_API_URL=https://api-qa.trivance.com
VITE_AUTH_API_URL=https://auth-qa.trivance.com
VITE_GRAPHQL_URL=https://api-qa.trivance.com/graphql
```

#### 3. Deployment a QA

```bash
# 1. Build para QA
npm run build:qa

# 2. Deploy (según estrategia de la empresa)
# Opción A: Docker
docker build -t trivance-app:qa .
docker push registry.trivance.com/trivance-app:qa

# Opción B: PM2
pm2 start ecosystem.qa.config.js

# Opción C: Kubernetes
kubectl apply -f k8s/qa/
```

#### 4. Validación QA

```bash
# Verificar deployment
curl -f https://api-qa.trivance.com/health
curl -f https://auth-qa.trivance.com/health
curl -f https://staging-admin.trivance.com

# Ejecutar tests de QA
npm run test:qa
npm run test:e2e:qa
```

---

## 🔒 Production Environment (Crítico)

### 🚨 Proceso de Aprobación

**OBLIGATORIO**: Todo deployment a producción requiere:

1. **✅ Code Review** aprobado por 2+ senior developers
2. **✅ QA Testing** completo con sign-off del QA team
3. **✅ Security Review** por el security officer
4. **✅ Performance Testing** con métricas aprobadas
5. **✅ Backup Strategy** validada
6. **✅ Rollback Plan** documentado y probado

### 🔐 Configuración de Producción

#### 1. Secrets Management

**NUNCA** hardcodear secrets en archivos. Usar:

```bash
# Opción A: HashiCorp Vault
vault kv get -field=jwt_secret secret/trivance/prod/auth

# Opción B: AWS Secrets Manager  
aws secretsmanager get-secret-value --secret-id trivance/prod/jwt-secret

# Opción C: Kubernetes Secrets
kubectl get secret trivance-secrets -o jsonpath='{.data.jwt-secret}' | base64 -d
```

#### 2. Variables de Entorno Producción

```bash
# Production Environment Configuration
NODE_ENV=production
PORT=3000

# URLs Producción (validadas por seguridad)
API_BASE_URL=https://api.trivance.com
AUTH_API_URL=https://auth.trivance.com  
FRONTEND_URL=https://admin.trivance.com
GRAPHQL_URL=https://api.trivance.com/graphql

# Base de datos Producción (alta disponibilidad)
DATABASE_URL=postgresql://prod_user:${PROD_DB_SECRET}@prod-db-cluster.trivance.com:5432/trivance_production

# JWT Producción (rotación mensual obligatoria)
JWT_SECRET=${PROD_JWT_SECRET}
JWT_EXPIRATION_TIME=15m  # Más corto en producción

# AWS Producción (IAM roles recomendado)
AWS_ACCESS_KEY_ID=${PROD_AWS_KEY}
AWS_SECRET_ACCESS_KEY=${PROD_AWS_SECRET}
AWS_REGION=us-east-1
AWS_S3_BUCKET=trivance-production-uploads

# Monitoreo Producción (crítico)
SENTRY_DSN=${PROD_SENTRY_DSN}
LOG_LEVEL=warn
DATADOG_API_KEY=${PROD_DATADOG_KEY}

# Configuración Producción (restrictiva)
CORS_ORIGIN=https://admin.trivance.com
GRAPHQL_PLAYGROUND=false  # NUNCA en producción
GRAPHQL_DEBUG=false
GRAPHQL_INTROSPECTION=false  # Seguridad

# Rate limiting Producción (más restrictivo)
RATE_LIMIT_TTL=60
RATE_LIMIT_LIMIT=50

# SSL y Seguridad
FORCE_HTTPS=true
HELMET_CONFIG=strict
CSP_CONFIG=strict
```

#### 3. Deployment Producción

```bash
# 1. Pre-deployment checklist
□ Backup de base de datos completado
□ Maintenance window comunicado
□ Rollback plan activado
□ Monitoring dashboards listos
□ Equipo on-call notificado

# 2. Blue-Green Deployment (recomendado)
# Deploy a entorno "green"
kubectl apply -f k8s/prod/green/

# Validación en green
npm run test:prod:smoke
npm run test:prod:health

# Switch traffic green → blue
kubectl patch service trivance-api -p '{"spec":{"selector":{"version":"green"}}}'

# 3. Post-deployment validation
npm run test:prod:full
./scripts/validate-production.sh

# 4. Monitoring
# Verificar métricas por 2 horas mínimo
# Alerts configurados
# Performance baselines validados
```

#### 4. Secrets Rotation (Producción)

```bash
# Rotación mensual obligatoria
# 1. Generar nuevos secrets
NEW_JWT_SECRET=$(openssl rand -base64 128)

# 2. Actualizar en secrets manager
aws secretsmanager update-secret --secret-id trivance/prod/jwt-secret --secret-string "$NEW_JWT_SECRET"

# 3. Rolling restart de servicios
kubectl rollout restart deployment/trivance-auth
kubectl rollout restart deployment/trivance-api

# 4. Validar funcionamiento
kubectl rollout status deployment/trivance-auth
```

---

## 🔧 Troubleshooting por Environment

### Development Issues

```bash
# Problema: Puerto en uso
sudo lsof -i :3000
kill -9 <PID>

# Problema: Base de datos no conecta
brew services restart postgresql
brew services restart mongodb-community

# Problema: Node modules corruptos
rm -rf node_modules package-lock.json
npm install
```

### QA Issues

```bash
# Problema: DNS no resuelve
nslookup api-qa.trivance.com
# Contactar: DevOps team

# Problema: Certificado SSL inválido
openssl s_client -connect api-qa.trivance.com:443
# Contactar: Security team

# Problema: Base de datos QA no accesible
# Verificar VPN, firewall rules
# Contactar: DBA team
```

### Production Issues

```bash
# 🚨 CRITICAL: Seguir runbook de incidentes
# 1. Alertar en Slack #production-incidents
# 2. Iniciar bridge call
# 3. Ejecutar rollback si es necesario
# 4. Documentar en post-mortem

# Rollback de emergencia
kubectl rollout undo deployment/trivance-api
kubectl rollout undo deployment/trivance-auth
```

---

## 📊 Checklist de Deployment

### ✅ Development → QA

- [ ] Features completadas y probadas localmente
- [ ] Tests unitarios pasando
- [ ] Code review aprobado
- [ ] Branch develop actualizado
- [ ] Variables QA configuradas manualmente
- [ ] Deploy a QA ejecutado
- [ ] Tests de integración en QA pasando
- [ ] QA team sign-off

### ✅ QA → Production

- [ ] Todas las features QA aprobadas
- [ ] Tests E2E completos
- [ ] Performance tests aprobados
- [ ] Security scan completado
- [ ] Backup de producción realizado
- [ ] Maintenance window programado
- [ ] Variables producción configuradas
- [ ] Secrets rotados
- [ ] Deploy plan aprobado
- [ ] Rollback plan probado
- [ ] Equipo on-call alertado
- [ ] Post-deployment monitoring configurado

---

## 🆘 Contacts & Escalation

### Por Environment

- **Development**: Slack #dev-support
- **QA**: Slack #qa-team + DevOps on-call
- **Production**: Slack #production-incidents + PagerDuty

### Por Componente  

- **Backend API**: Backend team lead
- **Auth Service**: Security + Backend team
- **Frontend**: Frontend team lead  
- **Infrastructure**: DevOps team
- **Database**: DBA team
- **Security**: Security officer

---

**⚠️ IMPORTANTE**: Esta guía asume que la infraestructura (servidores, bases de datos, DNS) ya está configurada por el equipo de DevOps/Infrastructure. Para setup de infraestructura, consultar documentación específica de infrastructure-as-code.