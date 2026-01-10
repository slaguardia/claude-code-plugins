# Database Migration Plugin

Database migration tools for Flyway, including running migrations, fixing common errors, and managing SQL files.

## Features

### Commands

- **migrate** - Run Flyway database migrations and resolve any errors

## Installation

Add to your Claude Code plugins:

```bash
claude plugins add database-migration
```

## Usage

### Run Migrations
```
/migrate
```

Runs Flyway migrations and handles common errors:
- SQL syntax errors
- Delimiter issues
- Checksum mismatches
- Function conflicts
- Missing search_path

## Common Errors

### Checksum Mismatch (Versioned)
Never modify versioned migrations (V*.sql) after they've been applied. Create a new migration instead.

### Checksum Mismatch (Repeatable)
Expected when R__*.sql files are modified. Flyway will re-run them.

### Function Already Exists
Use `DROP FUNCTION IF EXISTS` before `CREATE OR REPLACE` when changing return types.

### Missing search_path
All functions must have `SET search_path TO ''` for security.

## File Locations

- Versioned migrations: `flyway/sql/V*.sql`
- Repeatable migrations: `flyway/sql/repeatables/R__*.sql`
- Configuration: `flyway/flyway.conf`

## Best Practices

1. Use versioned migrations for schema changes
2. Use repeatable migrations for functions, views, triggers
3. Never modify versioned migrations after deployment
4. Always include `SET search_path TO ''` in functions
5. Use qualified table names (`public.table_name`)
