# TalaqqiHub

Java Servlet/JSP web application (Maven WAR) deployed on **Apache Tomcat 9**.

## Kerocket deployment

This repo is **not** a Node.js app. There is **no root `package.json`** by design.

Kerocket must use **Docker build** (`kerocket.toml` → `Dockerfile`):

- Maven compiles sources into `TalaqqiHub.war` and deploys as Tomcat `ROOT.war`
- `docker-entrypoint.sh` binds Tomcat to `0.0.0.0:$PORT` and configures the MySQL JNDI datasource from env vars

### Required environment variables

| Variable | Purpose |
|----------|---------|
| `PORT` | HTTP port (Kerocket sets this) |
| `DB_URL`, `DB_USER`, `DB_PASSWORD` | JDBC connection (preferred for Aiven) |
| `DATABASE_URL` | Alternative from attached MySQL data service |
| `GEMINI_API_KEY` | AI assistant feature |

See `.env.example` for a template.

### Database

Import `db/talaqqihub_backup.sql` into your cloud MySQL instance before testing login.

**Test student login (after import):** `hannah@gmail.com` / `hannah123`

**Check database on production (after redeploy):**

- `https://your-app-url/api/db-health` or `/health/db`
- Or immediately (older builds): `/admin/packages/dbcheck`

Should return JSON with `"ok":true` and `"studentCount"` > 0.

### Local development (XAMPP)

Deploy the exploded WAR to Tomcat `webapps/TalaqqiHub` or run `mvn package` and copy the WAR.

CSS is pre-built in `css/tailwind.min.css` — no Node.js/npm required for deployment.
