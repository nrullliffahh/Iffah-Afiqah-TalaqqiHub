package model;

/**
 * QuranVerse Model
 *
 * Represents a single ayah (verse) from the Quran with Arabic text,
 * transliteration, and English translation.
 *
 * Data is fetched from the Al-Quran Cloud API:
 * https://api.alquran.cloud/v1
 *
 * MVC Role: Model – pure data container representing Quran verse information.
 */
public class QuranVerse {

    private int surahNumber;           // Surah number (1-114)
    private String surahName;          // Arabic name (e.g., "الفاتحة")
    private String surahNameEnglish;   // English name (e.g., "Al-Fatiha")
    private int ayahNumber;            // Ayah number within the surah
    private int totalAyahs;            // Total number of ayahs in the surah
    private String arabicText;         // Quranic text in Uthmani script
    private String transliteration;    // Romanized pronunciation (optional)
    private String translation;        // English meaning (Sahih International)

    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Default constructor – initializes with Surah 1 Ayah 1
     */
    public QuranVerse() {
        this.surahNumber = 1;
        this.surahName = "الفاتحة";
        this.surahNameEnglish = "Al-Fatiha";
        this.ayahNumber = 1;
        this.totalAyahs = 7;
        this.arabicText = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ";
        this.transliteration = "Bismi llāhi r-raḥmāni r-raḥīm";
        this.translation = "In the name of Allah, the Entirely Merciful, the Especially Merciful.";
    }

    /**
     * Constructor with surah and ayah
     */
    public QuranVerse(int surahNumber, int ayahNumber) {
        this();
        this.surahNumber = surahNumber;
        this.ayahNumber = ayahNumber;
    }

    /**
     * Full constructor – used when populating from API response
     */
    public QuranVerse(int surahNumber, String surahName, String surahNameEnglish,
                      int ayahNumber, int totalAyahs, String arabicText,
                      String transliteration, String translation) {
        this.surahNumber = surahNumber;
        this.surahName = surahName;
        this.surahNameEnglish = surahNameEnglish;
        this.ayahNumber = ayahNumber;
        this.totalAyahs = totalAyahs;
        this.arabicText = arabicText;
        this.transliteration = transliteration;
        this.translation = translation;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Getters
    // ─────────────────────────────────────────────────────────────────────────

    public int getSurahNumber() {
        return surahNumber;
    }

    public String getSurahName() {
        return surahName;
    }

    public String getSurahNameEnglish() {
        return surahNameEnglish;
    }

    public int getAyahNumber() {
        return ayahNumber;
    }

    public int getTotalAyahs() {
        return totalAyahs;
    }

    public String getArabicText() {
        return arabicText;
    }

    public String getTransliteration() {
        return transliteration;
    }

    public String getTranslation() {
        return translation;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Setters
    // ─────────────────────────────────────────────────────────────────────────

    public void setSurahNumber(int surahNumber) {
        this.surahNumber = surahNumber;
    }

    public void setSurahName(String surahName) {
        this.surahName = surahName;
    }

    public void setSurahNameEnglish(String surahNameEnglish) {
        this.surahNameEnglish = surahNameEnglish;
    }

    public void setAyahNumber(int ayahNumber) {
        this.ayahNumber = ayahNumber;
    }

    public void setTotalAyahs(int totalAyahs) {
        this.totalAyahs = totalAyahs;
    }

    public void setArabicText(String arabicText) {
        this.arabicText = arabicText;
    }

    public void setTransliteration(String transliteration) {
        this.transliteration = transliteration;
    }

    public void setTranslation(String translation) {
        this.translation = translation;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Utility Methods
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Returns formatted verse identifier: "Surah 2: 255"
     */
    public String getFormattedReference() {
        return String.format("Surah %d: %d", surahNumber, ayahNumber);
    }

    /**
     * Returns full display: "Al-Fatiha (1:1)"
     */
    public String getFullDisplay() {
        return String.format("%s (%d:%d)", surahNameEnglish, surahNumber, ayahNumber);
    }

    @Override
    public String toString() {
        return String.format("QuranVerse{surah=%d:%d, english=%s, arabic=%s}",
                surahNumber, ayahNumber, surahNameEnglish, arabicText);
    }
}
