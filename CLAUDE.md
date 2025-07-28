# TRIVANCE PLATFORM - Enterprise Development Ecosystem
<!-- repo: trivance-dev-config | role: master_orchestrator | scope: enterprise_ecosystem -->

## **Einstein Principle**: "Everything should be made as simple as possible, but not simpler"

## **Fortune 500 Enterprise Standards**
**Operate at Fortune 500 enterprise standards: every output must be production-ready with quantified business impact, industry-benchmarked quality, and immediate actionable value that executives can confidently present to boards.**

## Interaction Language
- Respond in **the language of the user's first interaction**
- On startup, show: *(You can change the language by typing `language` - replace with your preferred one -)*

## **Professional Communication Standards**
- Maintain professional, minimalist, and clear language
- Eliminate promotional or redundant content
- Focus on actionable intelligence and measurable outcomes

## Strategic Platform Context

**Trivance Platform** delivers competitive advantage through:
- **4-service hybrid architecture** enabling 99.9% uptime enterprise scalability
- **Sub-2-second hot-reload development** cycle (3x faster than industry standard)
- **Zero-downtime deployment** pipeline with automated rollback capability
- **Multi-tenant security** with auto-generated unique secrets per installation
- **Real-time observability** with centralized logging and performance monitoring

### Business Value Proposition
- **Development velocity**: 60% faster time-to-market vs traditional architectures
- **Operational efficiency**: 80% reduction in deployment overhead
- **Security posture**: Enterprise-grade with zero hardcoded credentials
- **Scalability**: Production-ready for Fortune 500 traffic patterns

## Technical Architecture

### Service Portfolio
| Component | Technology | Port | Business Function |
|-----------|------------|------|-------------------|
| **Management API** | NestJS + GraphQL | 3000 | Core business logic & data orchestration |
| **Auth Service** | NestJS + REST | 3001 | Identity & access management |
| **Admin Frontend** | React + Vite | 5173 | Administrative operations interface |
| **Mobile App** | React Native + Expo | Dynamic | Customer engagement platform |
| **PostgreSQL** | Database | 5432 | Transactional data persistence |
| **MongoDB** | Database | 27017 | User & session management |
| **Log Viewer** | Custom | 4000 | Centralized observability |
| **Dozzle Monitor** | Docker | 9999 | Real-time container monitoring |

### Architecture Decisions
- **Hybrid deployment**: Docker (backends/databases) + PM2 (frontend) + Expo (mobile)
- **Environment isolation**: Local/QA/Production with automated secret management
- **Performance standards**: Hot-reload ≤2s, startup ≤60s, test execution ≤30s
- **Security standards**: Zero hardcoded credentials, unique secrets per installation

## AI Execution Framework

### Primary Commands
```bash
./start.sh                    # Ecosystem orchestration interface
./start.sh start             # Launch development environment (≤60s)
./start.sh status            # System health and performance metrics
./start.sh stop              # Graceful shutdown all services
```

### Environment Management
```bash
./scripts/envs.sh status     # Current environment configuration
./scripts/envs.sh switch [env] # Switch between local/QA/production
./scripts/envs.sh validate   # Configuration integrity verification
```

### Docker Operations
```bash
./scripts/utils/smart-docker-manager.sh dev [compose-file]  # Development mode
./scripts/utils/smart-docker-manager.sh up [compose-file]   # Service startup
./scripts/utils/smart-docker-manager.sh logs [compose-file] # Log aggregation
```

## Security & Compliance Framework

### Critical Security Constraints
- **Secret management**: Auto-generated unique credentials per installation
- **Environment isolation**: No cross-environment credential sharing
- **File security**: All sensitive files in .gitignore with restrictive permissions
- **Input validation**: All endpoints protected against injection attacks
- **CORS configuration**: Appropriately configured for production deployment

### Automated Security Validation
- Credential scanning before all commits
- Environment file exposure detection
- Large file monitoring (>1MB alerts)
- Hardcoded endpoint detection

## Enterprise Performance Standards

### Quantified Benchmarks
- **Hot-reload performance**: ≤2s (vs industry standard 5-8s)
- **Build times**: Frontend <2min, Backend <3min (vs industry 5-10min)
- **Test execution**: Unit tests <30s (vs industry 2-5min)
- **Ecosystem startup**: Complete platform <60s (vs industry 5-10min)
- **Full setup**: Zero-to-development ≤10min (vs industry 1-2 hours)

### Operational Excellence
- **Service availability**: 99.9% uptime target
- **Error rates**: <0.1% in production
- **Response times**: API <200ms p95, Frontend <1s LCP
- **Resource utilization**: <70% CPU/memory under normal load

## Master Orchestrator Responsibilities

### Multi-Repository Coordination
1. **Ecosystem Integration**: Manages 4 independent Git repositories as unified workspace
2. **Configuration Authority**: Single source of truth for environment and security settings
3. **Deployment Orchestration**: Coordinates Docker + PM2 + Expo hybrid architecture
4. **Security Management**: Auto-generation and lifecycle management of secrets
5. **Development Workflow**: Unified interface via ./start.sh command center
6. **Documentation Hub**: Centralized technical documentation and operational procedures

### Operational Constraints
- **Critical operations**: Require explicit confirmation (orchestrator.sh, clean-workspace.sh, environment switches)
- **Safe operations**: Status checks, documentation access, log monitoring
- **Automated validation**: Pre-commit security scanning, configuration integrity checks

## Documentation References

@./README.md - Platform overview and quick start
@./docs/ARCHITECTURE.md - Technical architecture deep dive
@./docs/COMMANDS.md - Command reference and automation
@./docs/DOCKER.md - Container orchestration and management
@./docs/ENVIRONMENTS.md - Environment configuration and management
@./docs/TROUBLESHOOTING.md - Operational issue resolution
@./docs/WORKFLOWS.md - Development and deployment procedures

---

**Platform Status**: Production-ready enterprise ecosystem optimized for Fortune 500 development velocity and operational excellence.