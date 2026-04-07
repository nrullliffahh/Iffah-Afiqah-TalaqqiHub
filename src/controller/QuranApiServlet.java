package controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

/**
 * QuranApiServlet
 *
 * A server-side proxy to the Al-Quran Cloud REST API (https://api.alquran.cloud/v1).
 * All requests pass through this servlet so the browser is never blocked by CORS headers,
 * and so we can enforce teacher authentication before any API call is made.
 *
 * URL: /teacher/quran-api
 *
 * ── Supported actions (GET parameter: action) ─────────────────────────────
 *
 *  action=surahList
 *      Returns the list of all 114 surahs.
 *      → https://api.alquran.cloud/v1/surah
 *
 *  action=ayah&surah={N}&ayah={M}
 *      Returns a single ayah in two editions: Arabic (quran-uthmani) +
 *      English Sahih International translation (en.sahih).
 *      → https://api.alquran.cloud/v1/ayah/{N}:{M}/editions/quran-uthmani,en.sahih
 *
 *  action=surahInfo&surah={N}
 *      Returns metadata for surah N (total ayahs, name, etc.).
 *      → https://api.alquran.cloud/v1/surah/{N}
 *
 * All responses are forwarded verbatim (JSON) from the upstream API.
 * HTTP errors and network timeouts are returned as a JSON error object.
 */
public class QuranApiServlet extends HttpServlet {

    private static final String API_BASE     = "https://api.alquran.cloud/v1";
    private static final int    CONNECT_MS   = 10_000;
    private static final int    READ_MS      = 15_000;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Authentication guard ──────────────────────────────────────────────
        // Allow both teachers and students to access Quran data
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("teacherId") == null && session.getAttribute("studentId") == null)) {
            sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing 'action' parameter");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        switch (action.trim()) {

            // ── Full surah list ───────────────────────────────────────────────
            case "surahList":
                proxyTo(response, API_BASE + "/surah");
                break;

            // ── Single ayah with Arabic + English translation ─────────────────
            case "ayah": {
                String surah = request.getParameter("surah");
                String ayah  = request.getParameter("ayah");
                if (isBlank(surah) || isBlank(ayah)) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "'surah' and 'ayah' parameters are required");
                    return;
                }
                int surahNum, ayahNum;
                try {
                    surahNum = Integer.parseInt(surah.trim());
                    ayahNum  = Integer.parseInt(ayah.trim());
                } catch (NumberFormatException e) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "'surah' and 'ayah' must be integers");
                    return;
                }
                if (surahNum < 1 || surahNum > 114 || ayahNum < 1) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "Surah must be 1-114 and ayah must be >= 1");
                    return;
                }
                // Request both Arabic and English in one call to reduce round-trips
                String url = API_BASE + "/ayah/" + surahNum + ":" + ayahNum
                           + "/editions/quran-uthmani,en.sahih";
                proxyTo(response, url);
                break;
            }

            // ── Surah metadata (used to get totalAyahs) ───────────────────────
            case "surahInfo": {
                String surah = request.getParameter("surah");
                if (isBlank(surah)) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "'surah' parameter is required");
                    return;
                }
                int surahNum;
                try {
                    surahNum = Integer.parseInt(surah.trim());
                } catch (NumberFormatException e) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "'surah' must be an integer");
                    return;
                }
                if (surahNum < 1 || surahNum > 114) {
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                              "Surah must be between 1 and 114");
                    return;
                }
                proxyTo(response, API_BASE + "/surah/" + surahNum);
                break;
            }

            default:
                sendError(response, HttpServletResponse.SC_BAD_REQUEST,
                          "Unknown action: " + sanitize(action));
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  Private helpers
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Makes an HTTP GET request to {@code urlStr} and writes the full response
     * body to the servlet response.  The upstream HTTP status code is propagated.
     */
    private void proxyTo(HttpServletResponse response, String urlStr) throws IOException {
        HttpURLConnection upstream = null;
        try {
            upstream = (HttpURLConnection) new URL(urlStr).openConnection();
            upstream.setRequestMethod("GET");
            upstream.setConnectTimeout(CONNECT_MS);
            upstream.setReadTimeout(READ_MS);
            upstream.setRequestProperty("Accept", "application/json");

            int upstreamStatus = upstream.getResponseCode();
            response.setStatus(upstreamStatus);

            InputStream in = (upstreamStatus < 400)
                    ? upstream.getInputStream()
                    : upstream.getErrorStream();

            if (in == null) {
                response.getWriter().write("{\"code\":" + upstreamStatus + ",\"data\":null}");
                return;
            }

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
                 PrintWriter    out    = response.getWriter()) {
                char[] buf = new char[4096];
                int read;
                while ((read = reader.read(buf)) != -1) {
                    out.write(buf, 0, read);
                }
            }

        } catch (Exception e) {
            sendError(response, HttpServletResponse.SC_BAD_GATEWAY,
                      "Upstream error: " + e.getMessage());
        } finally {
            if (upstream != null) upstream.disconnect();
        }
    }

    private void sendError(HttpServletResponse response, int status, String message)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":false,\"error\":\"" + sanitize(message) + "\"}");
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    /** Removes characters that could break a JSON string value. */
    private String sanitize(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", " ").replace("\r", "");
    }
}
