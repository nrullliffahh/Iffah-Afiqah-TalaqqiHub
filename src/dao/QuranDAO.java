package dao;

import model.QuranVerse;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * QuranDAO
 *
 * Provides server-side access to the Al-Quran Cloud REST API.
 * Fetches Quran verse data and parses JSON responses into QuranVerse objects.
 *
 * API Base: https://api.alquran.cloud/v1
 *
 * Sample endpoints:
 * - /surah/{N}                    → Metadata for surah N
 * - /ayah/{N}:{M}/editions/...   → Specific ayah with translations
 * - /surah                        → List of all surahs
 *
 * Note: This DAO makes SYNCHRONOUS HTTP calls. In production, consider using
 * a cache or async client to avoid blocking threads during network I/O.
 *
 * MVC Role: DAO – data access layer bridging the model and external APIs.
 */
public class QuranDAO {

    private static final String API_BASE = "https://api.alquran.cloud/v1";
    private static final int CONNECT_TIMEOUT_MS = 10_000;
    private static final int READ_TIMEOUT_MS = 15_000;

    // ─────────────────────────────────────────────────────────────────────────
    // Public API Methods
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Fetches a single ayah (verse) with Arabic text and English translation.
     *
     * @param surahNumber   Surah number (1-114)
     * @param ayahNumber    Ayah number within the surah
     * @return QuranVerse object, or null if fetch fails
     */
    public QuranVerse getAyah(int surahNumber, int ayahNumber) {
        String url = String.format(
            "%s/ayah/%d:%d/editions/quran-uthmani,en.sahih",
            API_BASE, surahNumber, ayahNumber
        );
        return fetchAyahFromUrl(url);
    }

    /**
     * Fetches all ayahs in a surah.
     *
     * @param surahNumber   Surah number (1-114)
     * @return List of QuranVerse objects, or empty list if fetch fails
     */
    public List<QuranVerse> getSurahVerses(int surahNumber) {
        List<QuranVerse> verses = new ArrayList<>();

        // First, get surah metadata
        String metaUrl = String.format("%s/surah/%d", API_BASE, surahNumber);
        JSONObject metaResponse = fetchJsonFromUrl(metaUrl);

        if (metaResponse == null) {
            return verses;
        }

        JSONObject surahData = metaResponse.optJSONObject("data");
        if (surahData == null) {
            return verses;
        }

        int totalAyahs = surahData.optInt("numberOfAyahs", 0);
        String surahNameArabic = surahData.optString("name", "");
        String surahNameEnglish = surahData.optString("englishName", "");

        // Now fetch each ayah
        for (int ayahNum = 1; ayahNum <= totalAyahs; ayahNum++) {
            String ayahUrl = String.format(
                "%s/ayah/%d:%d/editions/quran-uthmani,en.sahih",
                API_BASE, surahNumber, ayahNum
            );
            QuranVerse verse = fetchAyahFromUrl(ayahUrl);

            if (verse != null) {
                verses.add(verse);
            }
        }

        return verses;
    }

    /**
     * Fetches a single ayah by absolute position in the Quran (ayah key).
     * Ayah key is a unique identifier combining surah and ayah (e.g., "1:1").
     *
     * @param ayahKey   Format: "surah:ayah" (e.g., "2:255")
     * @return QuranVerse object, or null if fetch fails
     */
    public QuranVerse getAyahByKey(String ayahKey) {
        String url = String.format(
            "%s/ayah/%s/editions/quran-uthmani,en.sahih",
            API_BASE, ayahKey
        );
        return fetchAyahFromUrl(url);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Private Helper Methods
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Fetches and parses a single ayah response from the API.
     * API response structure: { status: "...", data: [ { ... }, { ... } ] }
     * where data[0] = Arabic (quran-uthmani), data[1] = English (en.sahih)
     *
     * @param url   Full API URL including protocol and query
     * @return Parsed QuranVerse, or null if fetch/parse fails
     */
    private QuranVerse fetchAyahFromUrl(String url) {
        JSONObject response = fetchJsonFromUrl(url);

        if (response == null) {
            System.err.println("QuranDAO: Failed to fetch ayah from " + url);
            return null;
        }

        String status = response.optString("status", "");
        if (!"OK".equals(status)) {
            System.err.println("QuranDAO: API error - status: " + status);
            return null;
        }

        JSONArray dataArray = response.optJSONArray("data");
        if (dataArray == null || dataArray.length() < 2) {
            System.err.println("QuranDAO: Unexpected data format");
            return null;
        }

        // Extract Arabic and English editions
        JSONObject arabicEdition = dataArray.getJSONObject(0);
        JSONObject englishEdition = dataArray.getJSONObject(1);

        QuranVerse verse = new QuranVerse();

        // ─ Arabic edition (quran-uthmani) ──────────────────────────────────
        verse.setSurahNumber(arabicEdition.optInt("surah", 1));
        verse.setAyahNumber(arabicEdition.optInt("numberInSurah", 1));
        verse.setArabicText(arabicEdition.optString("text", ""));

        // ─ Surah name from Arabic edition ──────────────────────────────────
        JSONObject surahInfo = arabicEdition.optJSONObject("surah");
        if (surahInfo != null) {
            verse.setSurahName(surahInfo.optString("name", ""));
            verse.setSurahNameEnglish(surahInfo.optString("englishName", ""));
            verse.setTotalAyahs(surahInfo.optInt("numberOfAyahs", 0));
        }

        // ─ English edition (en.sahih) ──────────────────────────────────────
        verse.setTranslation(englishEdition.optString("text", ""));

        // ─ Transliteration (if available) ──────────────────────────────────
        // The Juz detail API may include transliteration; for now, we'll leave it empty
        verse.setTransliteration("");

        return verse;
    }

    /**
     * Generic JSON fetcher – makes HTTP GET request and parses JSON response.
     *
     * @param url   Full URL including protocol
     * @return Parsed JSONObject, or null if request fails or response is invalid
     */
    private JSONObject fetchJsonFromUrl(String url) {
        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(CONNECT_TIMEOUT_MS);
            connection.setReadTimeout(READ_TIMEOUT_MS);
            connection.setRequestProperty("User-Agent", "TalaqqiHub/1.0");

            int responseCode = connection.getResponseCode();

            if (responseCode == 200) {
                BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8)
                );
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();

                return new JSONObject(response.toString());
            } else {
                System.err.println("QuranDAO: HTTP " + responseCode + " from " + url);
                return null;
            }

        } catch (Exception e) {
            System.err.println("QuranDAO: Exception fetching " + url);
            e.printStackTrace();
            return null;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Test/Debug Helper
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Simple test – fetches and prints Surah 1 Ayah 1
     */
    public static void main(String[] args) {
        QuranDAO dao = new QuranDAO();
        QuranVerse verse = dao.getAyah(1, 1);

        if (verse != null) {
            System.out.println("Surah: " + verse.getSurahNameEnglish());
            System.out.println("Ayah: " + verse.getAyahNumber());
            System.out.println("Arabic: " + verse.getArabicText());
            System.out.println("English: " + verse.getTranslation());
        } else {
            System.out.println("Failed to fetch verse");
        }
    }
}
