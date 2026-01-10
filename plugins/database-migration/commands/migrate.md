# Migrate Command

Run Flyway database migrations and resolve any errors.

## Steps

1. Run the migration script:
   ```bash
   cd flyway && ./migrate.sh
   ```

2. If the migration succeeds, report which migrations were applied.

3. If the migration fails, analyze the error and fix it.

## Common Errors and Fixes

### SQL Syntax Errors
- Read the failing SQL file mentioned in the error
- Fix the syntax issue (missing semicolons, typos, invalid SQL)
- Re-run the migration

### Delimiter Errors (`$$` instead of `$function$`)
- Run `npm run fix-flyway-delimiters` to auto-fix
- Or manually replace `$$` with `$function$` in the failing file

### Checksum Mismatch (Versioned Migrations)
- **Never modify versioned migrations (V*.sql) that have been applied**
- If local changes were made accidentally, revert them
- If the schema needs to change, create a new versioned migration

### Checksum Mismatch (Repeatable Migrations)
- This is expected when R__*.sql files are intentionally modified
- Flyway will re-run the migration with the new checksum
- If it fails, fix the SQL and re-run

### Function Already Exists with Different Return Type
- Use `DROP FUNCTION IF EXISTS function_name(args);` before CREATE OR REPLACE
- Or create a new versioned migration to drop the old function first

### Missing search_path
- All functions must have `SET search_path TO ''`
- Add it after the SECURITY INVOKER/DEFINER line

### Unqualified Table Names
- Use `public.table_name` instead of just `table_name`
- Check all table references in the failing function

## Migration File Locations

- Versioned: `flyway/sql/V*.sql`
- Repeatable: `flyway/sql/repeatables/R__*.sql`
- Config: `flyway/flyway.conf`

## Best Practices

### Versioned Migrations (V*.sql)
- Use for schema changes (CREATE TABLE, ALTER TABLE)
- Never modify after deployment
- Use sequential version numbers

### Repeatable Migrations (R__*.sql)
- Use for functions, views, triggers
- Can be modified - Flyway re-runs when checksum changes
- Always include proper error handling

### Function Template

```sql
CREATE OR REPLACE FUNCTION public.my_function(
  p_param1 UUID,
  p_param2 TEXT
)
RETURNS SETOF public.my_type
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path TO ''
AS $function$
BEGIN
  -- Function body
  RETURN QUERY
  SELECT * FROM public.my_table WHERE id = p_param1;
END;
$function$;
```

## Reference

- Flyway config: `flyway/flyway.conf`
- SQL files: `flyway/sql/` and `flyway/sql/repeatables/`
- Documentation: `flyway/CLAUDE.md` and `docs/FLYWAY_MIGRATIONS.md`
