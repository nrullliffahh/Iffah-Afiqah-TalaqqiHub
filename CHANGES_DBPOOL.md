# TalaqqiHub — DB Pooling & DBConnection Changes

Summary
- Added a Tomcat JDBC DataSource resource (`META-INF/context.xml`) named `jdbc/TalaqqiHubDB` to enable connection pooling for the webapp.
- Hardened `src/util/DBConnection.java`:
  - Prefer JNDI DataSource lookup first.
  - Reduced JDBC connect/socket timeouts and removed long multi-step fallbacks.
  - Trim environment/system property values to avoid leading/trailing-space auth bugs.

Files changed
- `src/util/DBConnection.java` — JNDI-first, trimmed env values, faster fail path.
- `META-INF/context.xml` — Tomcat JDBC `Resource` configuration (pool settings).

Why
- Per-request raw JDBC connections with retries caused ~8s login delays when initial credentials failed or timed out. Pooling prevents per-request socket connect overhead.

Quick test checklist
- Restart Tomcat (so `META-INF/context.xml` is read):
  - `cd C:\xampp\tomcat\bin`
  - `catalina.bat stop`
  - `catalina.bat run`
- Reproduce login and confirm Network timing shows ~20–200ms (no multi-second waits).
- Tail logs during test and confirm there are no repeated "Access denied" or repeated fallback messages.

Rollback steps (fast)
1. Disable pooling resource (stop Tomcat first):
   - Rename `META-INF/context.xml` to `context.xml.disabled` or remove it.
2. Restore previous `DBConnection.java` if needed (use VCS or revert file). The current `DBConnection` still supports DriverManager; app will continue to function.
3. Restart Tomcat.

Secure recommendation
- Create a dedicated DB user (minimal privileges) for the webapp instead of using `root`.
- Example SQL (run in MySQL as admin):
  - `CREATE USER 'talaqqi_user'@'localhost' IDENTIFIED BY 'StrongPassword';`
  - `GRANT SELECT, INSERT, UPDATE, DELETE ON talaqqihub.* TO 'talaqqi_user'@'localhost';`
  - `FLUSH PRIVILEGES;`
- Update `META-INF/context.xml` (and/or machine env vars) with the new credentials.

Notes
- Machine env vars used by the app: `DB_URL`, `DB_USER`, `DB_PASSWORD`. Use `setx /M` (Admin) or update `META-INF/context.xml` for container-managed pooling.
- I trimmed env values in code to avoid issues like a leading space in `DB_USER` causing authentication failures.

If you want, I can (A) create the SQL and instructions to add the dedicated DB user now, or (B) remove the `context.xml` to stop pool-init errors and keep current DriverManager usage.
