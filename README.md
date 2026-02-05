# **MySQL Core**

*An educational project showcasing how to use MySQL with Python, covering both synchronous and asynchronous approaches.*

## **Project Structure**

```bash
mysql-core/
├── app/                   # Main application code
├── docker-composes/       # Docker Compose configurations for MySQL servers
├── .env.example           # Example environment variables file
├── justfile               # Project-specific commands using Just
├── pixi.lock              # Locked dependency versions for reproducible environments
├── pixi.toml              # Pixi project configuration: environments, dependencies, and platforms
└── playground-testing/    # Jupyter notebooks for playground testing
```

Each directory includes its own `README.md` with detailed information about its contents and usage, and every file contains comprehensive inline comments to explain the code.

## **Dependencies Overview**

- [pydantic-settings](https://github.com/pydantic/pydantic-settings) — 
a Pydantic-powered library for managing application configuration and environment variables with strong typing, validation, and seamless `.env` support.

- [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy) — 
the Python SQL toolkit and Object-Relational Mapper (ORM) used as the foundation for database modeling, querying, and transaction management in both synchronous and asynchronous contexts.

- [Alembic](https://github.com/sqlalchemy/alembic) — 
a lightweight database migration tool for SQLAlchemy, enabling structured, version-controlled evolution of the MySQL schema over time.

- [mysql-connector-python](https://github.com/mysql/mysql-connector-python) — 
the official Python client for MySQL, enabling synchronous database connections and operations.

- [aiomysql](https://github.com/aio-libs/aiomysql) — 
the Python client for MySQL, enabling asynchronous database connections and operations.

- [just](https://github.com/casey/just) — 
a lightweight, cross-platform command runner that replaces complex shell scripts with clean, readable, and reusable project-specific recipes. [^1]

[^1]: Despite using `pixi`, there are issues with `pixi tasks` regarding environment variable handling from `.env` files and caching mechanism that is unclear and causes numerous errors. In contrast, `just` provides predictable, transparent execution without the complications encountered with `pixi tasks` system. I truly hope `pixi tasks` have been improved by the time you’re reading this! <33

### **Testing & Development Dependencies**

- [ipykernel](https://github.com/ipython/ipykernel) — 
the IPython kernel for Jupyter, enabling interactive notebook development and seamless integration with the project’s virtual environments.

## **Quick Start**

### **I. Prerequisites**

- [Docker and Docker Compose](https://docs.docker.com/engine/install/) container tools.
- [Pixi](https://pixi.sh/latest/) package manager.

> **Platform note**: All development and testing were performed on `linux-64`.  
> If you're using a different platform, you’ll need to:
> 1. Update the `platforms` list in the `pixi.toml` accordingly.
> 2. Ensure that platform-specific scripts are compatible with your operating system or replace them with equivalents.

### **II. Database Setup**

1. **Clone the repository**

    ```bash
    git clone git@github.com:Sierra-Arn/mysql-core.git
    cd mysql-core
    ```

2. **Install dependencies**
    
    ```bash
    pixi install --all
    ```

3. **Activate pixi environment**
    
    ```bash
    pixi shell
    ```

4. **Setup environment configuration**
   ```bash
   just copy-env
   ```

5. **Start MySQL database**
   ```bash
   just mysql-up-2
   ```

6. **Create a database migration & Apply it**
    ```bash
    just alembic-revision
    just alembic-upgrade
    ```

### **III. Testing**

Once a database is ready, you can run and test the MySQL implementation with interactive Jupyter notebooks in `playground-testing/`. Additionally, you can open a MySQL shell to manually verify that everything is working correctly:

```bash
just mysql-shell-2
```

### **IV. Cleanup**

```bash
just mysql-down-2
```

## **License**

This project is licensed under the [BSD-3-Clause License](LICENSE).