package util;

/**
 * Normalizes user-entered text that may contain Unicode dashes or UTF-8 mojibake.
 */
public final class TextEncodingUtil {

    private TextEncodingUtil() {
    }

    /**
     * Replace en/em dashes and common mojibake (e.g. {@code 6Ã¢ÂÂ20}) with ASCII hyphen.
     */
    public static String normalizeAsciiDash(String value) {
        if (value == null || value.isEmpty()) {
            return "";
        }

        String normalized = value
            .replace('\u2013', '-')
            .replace('\u2014', '-')
            .replace('\u2212', '-')
            .replace('\u00ad', '-')
            .replace("\u00e2\u0080\u0093", "-")
            .replace("\u00e2\u0080\u0094", "-")
            .replace("\u00c3\u00a2\u00c2\u00c2", "-")
            .replace("\u00c3\u00a2\u00c2\u0080\u0093", "-");

        normalized = normalized.replaceAll(
            "(?<=\\d)\\s*(?:-|"
                + "\u2013|\u2014|\u2212|"
                + "\u00e2\u0080[\u0093\u0094]|"
                + "\u00c3\u00a2[\u00c2\u0080\u0093\u00a2]{1,6})\\s*(?=\\d)",
            "-");

        return normalized.replaceAll("-{2,}", "-").trim();
    }
}
