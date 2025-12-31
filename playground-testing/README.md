# **Testing and Exploration**

Two Jupyter notebooks are provided for interactive experimentation with MySQL: one for synchronous workflows, another for asynchronous ones.

Additionally, you can always connect directly to the MySQL container and manually inspect the database state using standard mysql commands like:

1. **View all databases:**
    ```sql
    SHOW DATABASES;
    ```

2. **View all users:**
    ```sql
    SELECT User, Host FROM mysql.user;
    ```

3. **View all tables in current database:**
    ```sql
    SHOW TABLES;
    ```

    **Note:** This command requires a database to be selected first. If you get "ERROR 1046 (3D000): No database selected", 
    you need to select a database first:
    
    ```sql
    USE your_database_name;
    SHOW TABLES;
    ```

4. **View structure of specific table:**
    ```sql
    DESCRIBE <table_name>;
    ```

5. **View all schemas (same as databases in MySQL):**
    ```sql
    SHOW SCHEMAS;
    ```

6. **View data in table:**
    ```sql
    SELECT * FROM <table_name> LIMIT 10;
    ```

7. **Exit mysql:**
    ```sql
    exit;
    ```