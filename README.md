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
| `DATABASE_URL` | **Preferred** — from attached MySQL data service (Aiven `avnadmin` credentials) |
| `DB_URL` | Optional JDBC URL (database name/host); credentials come from `DATABASE_URL` if both set |
| `DB_USER`, `DB_PASSWORD` | Only needed if `DATABASE_URL` is not attached |
| `GEMINI_API_KEY` | AI assistant feature |

**Note:** Kerocket injects two different things:
- `DATABASE_URL` → often internal `mysql:3306/app` (empty, no student table)
- `DB_URL` → your Aiven URL with `talaqqihub_db` (where you import SQL)

**Kerocket credential quirk:** Some deployments inject `DB_URL` into Java but **not** separate `DB_USER` / `DB_PASSWORD` lines. If logs show `DB_USER=missing` at JVM startup, use **one line** with embedded credentials:

```
DB_URL=jdbc:mysql://avnadmin:YOUR_AIVEN_PASSWORD@mysql-XXXX.i.aivencloud.com:16135/talaqqihub_db?sslMode=REQUIRED
PORT=8080
GEMINI_API_KEY=...
```

(URL-encode special characters in the password if needed.)

Alternatively keep separate lines if your Kerocket build passes them through:

```
DB_USER=avnadmin
DB_PASSWORD=<your Aiven password>
```

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
