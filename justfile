# =====================================================
# Justfile Settings
# =====================================================
# Load environment variables from .env file into justfile context
# This allows justfile recipes to reference variables using ${VAR_NAME} syntax
set dotenv-load := true

# Export all loaded environment variables to child processes
# This makes variables available to all commands executed within recipes
# (e.g., docker compose, shell scripts, and other external tools)
set export := true


# =====================================================
# Environment Setup
# =====================================================
# Create local environment configuration file from template
# Copy .env.example to .env for initial project setup
# After copying, edit .env file to set your specific configuration values
copy-env:
    cp .env.example .env


# =====================================================  
# Alembic Database Migration Management  
# =====================================================  
# Create a new Alembic migration revision with auto-generated changes  
# Detects model changes and generates a new migration script in the migrations directory  
# Accepts an optional migration message as the first argument (defaults to "Auto migration")  
# Example usage:  
# just alembic-revision  
# just alembic-revision "Hello, World!"  
alembic-revision message="Auto migration":  
    alembic -c ./app/migrations/alembic.ini revision --autogenerate -m "{{ message }}"

# Apply all pending migrations to bring the database schema up to the latest version  
alembic-upgrade:  
    alembic -c ./app/migrations/alembic.ini upgrade head

# Revert the most recent migration to roll back the latest schema change  
alembic-downgrade:  
    alembic -c ./app/migrations/alembic.ini downgrade -1


# =====================================================  
# MySQL Persistent Storage Management  
# =====================================================  
# Initialize MySQL data directory structure  
# Creates the local directory specified by MYSQL_DATA_PATH environment variable  
# This directory will store MySQL data files, including tables, logs, and configuration  
init-mysql-storage:
    sudo mkdir -p ${MYSQL_DATA_PATH}  

# Remove MySQL persistent storage directory and all contents  
delete-mysql-storage:
    sudo rm -rf ${MYSQL_DATA_PATH}


# =====================================================
# MySQL Docker Compose Management
# =====================================================

# Start MySQL server based on specified composition number
# Usage: just mysql-up <number>
#   number=1: Basic server with user authentication (docker-compose.1-init.yml)
#   number=2: Server with interactive shell access (docker-compose.2-shell.yml)
#   number=3: Persistent production-like setup (docker-compose.3-persistent.yml)

mysql-up number:
    #!/usr/bin/env bash
    if [ "{{ number }}" = "1" ]; then
        # Docker Compose 1: MySQL Server Initialization
        # Start MySQL server with user-based authentication in detached mode
        #
        # -d flag (detached mode):
        #   Runs containers in the background and releases the terminal immediately.
        #   Without -d, docker compose would stream logs to stdout and block the shell
        #   until interrupted. Detached mode is preferred for long-running services like MySQL.
        docker compose -f docker-composes/docker-compose.1-init.yml --env-file .env up -d
    elif [ "{{ number }}" = "2" ]; then
        # Docker Compose 2: MySQL with Interactive Shell Access
        # Start MySQL server and client containers in detached mode with shell access enabled
        # Uses the same .env configuration for consistency across environments
        # Client container runs an idle process to allow `exec`-based interactive access
        docker compose -f docker-composes/docker-compose.2-shell.yml --env-file .env up -d
    elif [ "{{ number }}" = "3" ]; then
        # Docker Compose 3: Persistent MySQL Production-like Setup
        # Start MySQL server with full data persistence, user accounts, and long-term data retention
        # Designed to simulate a production-ready configuration while remaining manageable in development
        docker compose -f docker-composes/docker-compose.3-persistent.yml --env-file .env up -d
    else
        echo "Error: Invalid composition number. Use 1, 2, or 3."
        exit 1
    fi

# Stop and remove MySQL containers based on specified composition number
# Usage: just mysql-down <number>
#   number=1: Stop basic server instance
#   number=2: Stop server with shell access
#   number=3: Stop persistent instance (data in MYSQL_DATA_PATH is preserved)

mysql-down number:
    #!/usr/bin/env bash
    if [ "{{ number }}" = "1" ]; then
        # Stop and remove MySQL containers, networks, and anonymous volumes
        docker compose -f docker-composes/docker-compose.1-init.yml --env-file .env down
    elif [ "{{ number }}" = "2" ]; then
        # Stop and remove MySQL containers and networks defined in compose file
        docker compose -f docker-composes/docker-compose.2-shell.yml --env-file .env down
    elif [ "{{ number }}" = "3" ]; then
        # Stop and remove containers and networks from the persistent MySQL setup
        # Persistent data in MYSQL_DATA_PATH is preserved for future restarts or backups
        docker compose -f docker-composes/docker-compose.3-persistent.yml --env-file .env down
    else
        echo "Error: Invalid composition number. Use 1, 2, or 3."
        exit 1
    fi


# =====================================================
# MySQL Interactive Shell Access
# =====================================================
# !!! For development convenience only — using .env file password variables directly in CLI commands !!!
# This approach exposes secrets in process lists and command history; never use in production

# Launch MySQL CLI based on composition number and user type
# Usage: just mysql-shell <number> [admin]
#   number=2: Shell access via docker-compose.2-shell.yml
#   number=3: Shell access via docker-compose.3-persistent.yml
#   admin: Optional flag to connect as root user instead of application user

mysql-shell number user="app":
    #!/usr/bin/env bash
    if [ "{{ number }}" = "2" ]; then
        if [ "{{ user }}" = "admin" ]; then
            # Launch MySQL CLI as admin user (root) with full privileges
            docker compose \
                -f docker-composes/docker-compose.2-shell.yml \
                --env-file .env \
                exec mysql-client \
                mysql -p"$MYSQL_ROOT_PASSWORD"
        else
            # Launch MySQL CLI as application user
            docker compose \
                -f docker-composes/docker-compose.2-shell.yml \
                --env-file .env \
                exec mysql-client \
                mysql -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$MYSQL_DB_NAME"
        fi
    elif [ "{{ number }}" = "3" ]; then
        if [ "{{ user }}" = "admin" ]; then
            # Launch MySQL CLI as admin user (root) with full privileges
            docker compose \
                -f docker-composes/docker-compose.3-persistent.yml \
                --env-file .env \
                exec mysql-client \
                mysql -p"$MYSQL_ROOT_PASSWORD"
        else
            # Launch MySQL CLI as application user
            docker compose \
                -f docker-composes/docker-compose.3-persistent.yml \
                --env-file .env \
                exec mysql-client \
                mysql -u "$MYSQL_USERNAME" -p"$MYSQL_PASSWORD" "$MYSQL_DB_NAME"
        fi
    else
        echo "Error: Invalid composition number. Use 2 or 3."
        exit 1
    fi