# Branch Loan API - DevOps Assignment

A production-ready containerized microloans REST API built with Flask, PostgreSQL, Docker, and automated CI/CD.

## Quick Start
```bash
# 1. Start development environment
make dev

# 2. Access the API
curl -k https://branchloans.com/health
curl -k https://branchloans.com/api/loans
```

Open browser: `https://branchloans.com/health` (Click "Advanced" → "Proceed")

## Assignment Completion

All four parts of the Branch DevOps assignment have been completed:

✅ **Part 1**: Containerization with HTTPS  
✅ **Part 2**: Multi-environment setup (dev/staging/prod)  
✅ **Part 3**: CI/CD pipeline with GitHub Actions  
✅ **Part 4**: Comprehensive documentation

##  Architecture
```
┌─────────────────────────────────────────────────────┐
│         branchloans.com:443 (HTTPS)                 │
│         Browser accepts self-signed cert            │
└──────────────────┬──────────────────────────────────┘
                   │ TLS/SSL
                   ▼
        ┌──────────────────────┐
        │   Nginx Container    │
        │   - SSL Termination  │
        │   - Reverse Proxy    │
        │   - Port 443         │
        └──────────┬───────────┘
                   │ HTTP
                   ▼
        ┌──────────────────────┐
        │   Flask API          │
        │   - Gunicorn         │
        │   - Port 8000        │
        │   - Health checks    │
        │   - Non-root user    │
        └──────────┬───────────┘
                   │ PostgreSQL Protocol
                   ▼
        ┌──────────────────────┐
        │   PostgreSQL 16      │
        │   - Port 5432        │
        │   - Persistent data  │
        │   - Health checks    │
        └──────────────────────┘

         All containers on bridge network
```

## Features

- **Fully Containerized**: Docker + Docker Compose
- **HTTPS**: Nginx with self-signed SSL certificates
- **Multi-Environment**: Dev, Staging, Production configs
- **Security**: Non-root containers, Trivy vulnerability scanning
- **CI/CD**: Automated GitHub Actions pipeline
- **Health Checks**: Container-level health monitoring
- **Resource Management**: CPU/memory limits per environment
- **Data Persistence**: Database survives container restarts
- **Comprehensive Docs**: Complete setup and troubleshooting guide

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Make
- Git

## Installation & Setup

### 1. Clone Repository
```bash
git clone https://github.com/rakshitmalik1/dummy-branch-app
cd dummy-branch-app
```

### 2. Generate SSL Certificates
```bash
mkdir -p certs
openssl req -x509 -newkey rsa:4096 \
  -keyout certs/key.pem -out certs/cert.pem \
  -days 365 -nodes \
  -subj "/C=IN/ST=UP/L=Ghaziabad/O=Branch/CN=branchloans.com"
```

### 3. Configure Local Domain
```bash
# Linux/Mac
echo "127.0.0.1 branchloans.com" | sudo tee -a /etc/hosts

# Windows (Run PowerShell as Administrator)
Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 branchloans.com"
```

### 4. Start Application
```bash
# Start development environment
make dev

# Wait 15 seconds for services to be healthy
# Then access: https://branchloans.com/health
```

## Running the Application

### Using Make Commands
```bash
# Development environment
make dev

# Staging environment
make staging

# Production environment
make prod

# Stop environment
make stop-dev      # or stop-staging, stop-prod

# Clean everything (containers + volumes)
make clean

# View logs
make logs
```

### Using Docker Compose Directly
```bash
# Development
docker-compose --env-file .env.dev up --build -d

# Staging
docker-compose --env-file .env.staging up --build -d

# Production
docker-compose --env-file .env.prod up --build -d

# Stop
docker-compose --env-file .env.dev down
```

### Verify Deployment
```bash
# Check container status
docker ps

# Test health endpoint
curl -k https://branchloans.com/health

# Test API endpoints
curl -k https://branchloans.com/api/loans
curl -k https://branchloans.com/api/stats

# Check resource usage
docker stats --no-stream
```

## 🌐 API Endpoints

|      Endpoint    | Method |    Description      |
|------------------|--------|---------------------|
| `/health`        |   GET  | Health check status |
| `/api/loans`     |   GET  | List all loans      |
| `/api/loans/:id` |   GET  | Get specific loan   |
| `/api/loans`     |  POST  | Create new loan     |
| `/api/stats`     |   GET  | Loan statistics     |

### Example: Create a Loan
```bash
curl -k -X POST https://branchloans.com/api/loans \
  -H 'Content-Type: application/json' \
  -d '{
    "borrower_id": "usr_test_001",
    "amount": 15000.00,
    "currency": "INR",
    "term_months": 12,
    "interest_rate_apr": 22.5
  }'
```

## ⚙️ Environment Configuration

Three environments with different resource allocations:

| Environment     | API Memory | DB Memory | Workers | Log Level |        Use Case               |
|-----------------|------------|-----------|---------|-----------|-------------------------------|
| **Development** |    256MB   |   256MB   |    2    |   DEBUG   | Local development, hot reload |
| **Staging**     |    512MB   |   512MB   |    3    |   INFO    | Pre-production testing        |
| **Production**  |    1GB     |   1GB     |    4    |  WARNING  | Production deployment         |

### Environment Variables

Each environment has its own `.env` file:

**`.env.dev`** - Development
```env
ENV=dev
FLASK_ENV=development
LOG_LEVEL=DEBUG
GUNICORN_WORKERS=2
GUNICORN_RELOAD=--reload
```

**`.env.staging`** - Staging
```env
ENV=staging
FLASK_ENV=staging
LOG_LEVEL=INFO
GUNICORN_WORKERS=3
```

**`.env.prod`** - Production
```env
ENV=prod
FLASK_ENV=production
LOG_LEVEL=WARNING
GUNICORN_WORKERS=4
```

## CI/CD Pipeline

The GitHub Actions pipeline automatically runs on every push and PR.

### Pipeline Stages
```
1. Test Stage (5 min)
   ├─ Setup Python & PostgreSQL
   ├─ Install dependencies
   ├─ Run database migrations
   └─ Execute tests

2. Build Stage (3 min)
   ├─ Build Docker image
   ├─ Tag with commit SHA
   └─ Cache layers for speed

3. Security Scan (2 min)
   ├─ Scan with Trivy
   ├─ Check vulnerabilities
   └─ Upload to GitHub Security

4. Push Stage (1 min)
   ├─ Push to ghcr.io
   ├─ Tag: latest, main, <sha>
   └─ Only on main branch
```

### Triggers

- Push to `main` → Full pipeline + image push
- Pull Request → Test, Build, Scan only (no push)

### Container Registry

Images available at: `ghcr.io/rakshitmalik1/dummy-branch-app`

Tags:
- `latest` - Latest main branch build
- `main` - Main branch
- `<commit-sha>` - Specific commit

## Troubleshooting

### Issue: Website shows 404 or Not Found

**Cause**: Containers not running or accessing wrong URL

**Solution**:
```bash
# Check containers are running
docker ps

# Should see 3 containers: nginx, api, db
# If not running:
make dev

# Access correct URLs:
# ✅ https://branchloans.com/health
# ✅ https://branchloans.com/api/loans
# ❌ https://branchloans.com/ (404 - no root route)
```

### Issue: "Not Secure" or SSL Certificate Warning

**Cause**: Self-signed certificate not trusted by browser

**Solution**: This is **expected** for local development!
1. Click "Advanced" in browser
2. Click "Proceed to branchloans.com (unsafe)"
3. This is safe - you created the certificate yourself

For production, use Let's Encrypt or a proper CA.

### Issue: Connection Refused

**Solution**:
```bash
# Check logs
docker-compose logs api

# Restart containers
make stop-dev && make dev
```

### Issue: API Container Unhealthy

**Solution**:
```bash
# Check API logs
docker logs branch-api-dev

# Common fix: Increase timeout or remove health check temporarily
# Health check is commented out in Dockerfile for compatibility
```

### Issue: Database Connection Errors

**Solution**:
```bash
# Check database health
docker ps | grep db

# Should show "(healthy)"
# If not:
docker logs branch-db-dev
make stop-dev && make dev
```

### Issue: Port Already in Use

**Solution**:
```bash
# Check what's using port 443
sudo lsof -i :443

# Kill the process or change port in docker-compose.yml
```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f db
docker-compose logs -f nginx

# Last 50 lines
docker-compose logs --tail=50 api
```

## Project Structure
```
dummy-branch-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions pipeline
├── alembic/                    # Database migrations
│   ├── versions/
│   └── env.py
├── app/                        # Flask application
│   ├── __init__.py
│   ├── config.py
│   ├── db.py
│   ├── models.py
│   ├── schemas.py
│   └── routes/
│       ├── health.py
│       ├── loans.py
│       └── stats.py
├── certs/                      # SSL certificates (generated)
│   ├── cert.pem
│   └── key.pem
├── scripts/
│   └── seed.py                 # Database seeding
├── .env.dev                    # Development config
├── .env.staging                # Staging config
├── .env.prod                   # Production config
├── .gitignore                  # Git ignore rules
├── docker-compose.yml          # Container orchestration
├── Dockerfile                  # Container image definition
├── Makefile                    # Convenience commands
├── nginx.conf                  # Reverse proxy config
├── requirements.txt            # Python dependencies
├── README.md                   # This file
└── DESIGN_DECISIONS.md         # Technical decisions
```

## Design Decisions

See `DESIGN_DECISIONS.md` for detailed explanations of:
- Why we chose each technology
- Trade-offs considered
- Alternative approaches
- Future improvements

### Key Decisions Summary

1. **Base Image**: `python:3.11-slim` (balance of size vs functionality)
2. **SSL Termination**: Nginx (industry standard, easier cert management)
3. **Multi-Environment**: Separate `.env` files (clear separation, no errors)
4. **CI/CD Tool**: GitHub Actions (free, integrated, easy)
5. **Security Scanner**: Trivy (fast, comprehensive, free)
6. **Container Registry**: ghcr.io (free, built-in auth)

## Future Improvements

Given more time, these enhancements would be valuable:

1. **Testing**: Comprehensive unit and integration test suite
2. **Monitoring**: Prometheus + Grafana for metrics and alerting
3. **Logging**: Centralized logging with ELK stack
4. **Secrets Management**: HashiCorp Vault or AWS Secrets Manager
5. **Rate Limiting**: API rate limiting and throttling
6. **API Documentation**: Swagger/OpenAPI specification
7. **Database Backups**: Automated backup and restore strategy
8. **Kubernetes**: K8s manifests for orchestration
9. **Performance Testing**: Load testing with k6 or Locust
10. **Blue-Green Deployment**: Zero-downtime deployment strategy

## Assignment Deliverables Checklist

- Part 1: Containerization with HTTPS
- Part 2: Multi-environment setup (dev/staging/prod)
- Part 3: CI/CD pipeline with security scanning
- Part 4: Comprehensive documentation
- GitHub repository with all code
- 10-minute video walkthrough (to be recorded)

## Author

**Rakshit Malik**
- GitHub: [@rakshitmalik1](https://github.com/rakshitmalik1)
- Assignment: Branch DevOps Intern 2025

## License

This project is part of the Branch DevOps Intern take-home assignment.

---

**Questions or Issues?** Check the [Troubleshooting](#troubleshooting) section or review `DESIGN_DECISIONS.md`.

**Time Spent**: 4-6 hours as per assignment guidelines.
