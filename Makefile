# Pre-build security checks
SCAN_DIR = "C:/Users/slipk/OneDrive - The George Washington University/DC8/SEAS 8405/Week 7"
HOST_PATH := C:/Users/slipk/OneDrive - The George Washington University/DC8/SEAS 8405/Week 7

check:
	@echo "Running code analysis with Bandit..."
	docker run --rm -v "$(PWD):/app" python:3.9-alpine sh -c "pip install bandit && bandit -r /app"
	@echo "Running dependency check with pip-audit..."
	docker run --rm -v $(PWD):/app python:3.9-alpine sh -c "pip install pip-audit && pip-audit -r /app/requirements.txt"
	docker run --rm -v $(PWD):/app hadolint/hadolint hadolint /app/Dockerfile
	docker run --rm -v $(SCAN_DIR):/app python:3.9-alpine sh -c "pip install bandit && bandit -r /app"

# Host security check
host-security:
	@echo "Running Docker Bench for Security..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock docker/docker-bench-security
	docker run --rm --pid=host --cap-add audit_control \
		-v "$(HOST_PATH):/host:ro" aquasec/trivy config /host || true

# Build Docker image after security checks
dbuild: check
	docker build -t mywebapp .

# Run the container
run:
	docker run -p 6000:5000 mywebapp

# Scan the built image for vulnerabilities
scan:
	docker scout recommendations mywebapp:latest
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image app.py
	docker run --rm -v "$(shell pwd)":/mnt python:3.9-alpine sh -c "pip install bandit && bandit -r /mnt"

# Docker Compose commands
build:
	docker compose build

start:
	docker compose up -d
	docker build -t app.py .
	docker run -p 5000:5000 app.py

stop:
	docker compose down

logs:
	docker compose logs -f

clean:
	docker system prune -f

restart: stop start
