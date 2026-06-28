# TalaqqiHub

Java Servlet/JSP web application packaged as a Maven WAR and served by **Apache Tomcat 9**, backed by **MySQL/MariaDB**. See `README.md` for the deployment (Kerocket/Docker) overview and `pom.xml` for dependencies.

## Cursor Cloud specific instructions

The VM startup update script (`mvn -B -DskipTests dependency:go-offline`) only pre-fetches Java dependencies. The system tooling below is provisioned into the VM snapshot during environment setup, not by the update script.

### Services / toolchain
- **MariaDB** (local stand-in for MySQL) — provides the `talaqqihub_db` database the app reads/writes.
- **Apache Tomcat 9** installed at `/opt/tomcat9` — runs the built WAR.
- **Maven** + **JDK** (17/21) — builds the WAR (`pom.xml` targets `--release 17`; JDK 21 builds it fine).

### Database (non-obvious)
- The app's local-dev connection (see `tryLocalDevFallback` / `local-default` in `src/util/DBConnection.java` and `src/util/JdbcCredentialLoader.java`) hardcodes `jdbc:mysql://127.0.0.1:3306/talaqqihub_db` with user `root` / password `admin`. No env vars are needed for local dev.
- MariaDB has **no systemd** in this environment; start it manually: `sudo mysqld_safe &` (data in `/var/lib/mysql`).
- Because the app connects over **TCP** (not the unix socket), `root` is configured for password auth: `root@127.0.0.1` / `admin`. Connect with `mysql -h127.0.0.1 -uroot -padmin`.
- Schema is loaded from `db/talaqqihub_backup.sql` (no `CREATE DATABASE`/`USE` inside, so create `talaqqihub_db` first), then the numbered `db/0*.sql` migrations are applied in order (they are idempotent / safe to re-run).

### Build & run
- Build: `mvn -B -DskipTests package` → `target/TalaqqiHub.war` (the MySQL driver is bundled into `WEB-INF/lib`).
- Deploy as Tomcat root context: copy the WAR to `/opt/tomcat9/webapps/ROOT.war`.
- Run: `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 CATALINA_PID=/opt/tomcat9/tomcat.pid /opt/tomcat9/bin/catalina.sh run` (use `start`/`stop` for background). App serves at `http://localhost:8080/`.
- There is **no hot reload** — after rebuilding, replace `webapps/ROOT.war` (delete the exploded `webapps/ROOT` dir) and restart Tomcat.
- Health check: `GET /api/db-health` returns JSON `{"ok":true,...,"studentCount":N}` when the DB is wired up correctly.

### Test login (from seed data; passwords are plaintext)
- Student: `hannah@gmail.com` / `hannah123` → lands on `/student/dashboard`.

### Known code issue (not an environment problem)
- On branch `cursor/fix-session-completion-50f6`, `src/dao/TalaqqiSessionDAO.java` (~line 1695) calls `isActiveBookingId(...)` (which `throws SQLException`) inside `backfillSessionBookingIdResolved(...)` without handling it, so `mvn package` fails with "unreported exception java.sql.SQLException". `main` (commit `dd4a9e4`) does not have this code and builds cleanly. Fixing it requires a code change in the DAO; it is unrelated to environment setup.

### Lint / tests
- There is no configured linter or automated test suite (no JUnit/`src/test` test harness wired into `pom.xml`; the `src/test` and `src/debug` dirs are excluded from compilation). The effective check is a successful `mvn -B -DskipTests package`.
