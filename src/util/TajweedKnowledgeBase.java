package util;

/**
 * Offline Tajweed knowledge used when OpenAI quota/billing is unavailable.
 */
public class TajweedKnowledgeBase {

    private static final String FALLBACK_NOTE =
            "\n\n_Note: This answer was provided from TalaqqiHub's offline learning guide because " +
            "the live AI service is temporarily unavailable. Please verify with your teacher._";

    public static String findAnswer(String question) {
        if (question == null) return null;
        String q = question.toLowerCase();

        if (containsAny(q, "madd", "مد")) {
            return "There are several types of Madd (lengthening) in Tajweed:\n\n"
                    + "1. **Madd al-Tabi'i (Natural Madd)** — 2 counts. Occurs when hamzah is followed by alif, waw with dammah, or ya with kasrah.\n"
                    + "2. **Madd al-Munfasil (Separate Madd)** — 4 or 5 counts. Hamzah at the end of a word followed by madd letter at the start of the next word.\n"
                    + "3. **Madd al-Muttasil (Connected Madd)** — 4 or 5 counts. Hamzah and madd letter in the same word.\n"
                    + "4. **Madd al-Lazim (Obligatory Madd)** — 6 counts. Madd letter followed by a sukoon (permanent or temporary).\n"
                    + "5. **Madd al-'Arid (Incidental Madd)** — 2, 4, or 6 counts when stopping on a word ending with madd letter.\n"
                    + "6. **Madd al-Leen** — 2, 4, or 6 counts when stopping on a word with waw or ya saakinah preceded by fathah.\n\n"
                    + "Start by mastering Madd al-Tabi'i (2 counts) before moving to the longer types."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "noon sakinah", "noon saakinah", "نون ساكنة", "noon sakina")) {
            return "Noon Sakinah and Tanween have four rules:\n\n"
                    + "1. **Izhar (Clear)** — Pronounce noon clearly before throat letters (ء ه ع ح غ خ).\n"
                    + "2. **Idgham (Merging)** — Merge noon into the next letter. With ghunnah: ي ر م ل و ن (6 letters). Without ghunnah: ل ر (2 letters).\n"
                    + "3. **Iqlab (Conversion)** — Convert noon to meem sound before ب, with ghunnah.\n"
                    + "4. **Ikhfa (Hiding)** — Partially hide the noon sound with ghunnah before the remaining 15 letters.\n\n"
                    + "Example — Izhar: مِنْ عِلْمٍ (min 'ilm). Example — Iqlab: مِنْ بَعْدِ (mim ba'di)."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "ض", "dad", "dād", "pronounce the letter")) {
            return "The letter **ض (Dad)** is pronounced from the **side of the tongue** touching the upper molars, "
                    + "with the tongue slightly cupped. It is a heavy (tafkhim) letter.\n\n"
                    + "Tips:\n"
                    + "- Place the tongue's edge against the upper back teeth/molars\n"
                    + "- Apply slight pressure — it is not the same as د (dal)\n"
                    + "- Practice words like ضَرَبَ، مَضْبُوط، أَضْوَاء\n"
                    + "- Listen to expert Qaris and compare your sound to theirs\n\n"
                    + "The precise makhraj is best corrected by a qualified teacher in person."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "hukum tajweed", "hukum tajwid", "list tajweed", "list hukum",
                "list all hukum", "all hukum", "jenis tajweed", "kaedah tajweed", "rules of tajweed")) {
            return "Main Hukum (rules) of Tajweed:\n\n"
                    + "1. **Makharij al-Huruf** — Articulation points of letters\n"
                    + "2. **Sifaat al-Huruf** — Letter qualities (heavy, light, qalqalah)\n"
                    + "3. **Noon Sakinah & Tanween** — Izhar, Idgham, Iqlab, Ikhfa\n"
                    + "4. **Meem Sakinah** — Ikhfa Shafawi, Idgham Shafawi, Izhar Shafawi\n"
                    + "5. **Madd** — Lengthening rules (2, 4, 5, or 6 counts)\n"
                    + "6. **Qalqalah** — Echo on ق ط ب ج د when saakinah\n"
                    + "7. **Tafkhim & Tarqiq** — Heavy vs light pronunciation\n"
                    + "8. **Waqf & Ibtida** — Stopping and starting correctly\n"
                    + "9. **Hamzah al-Wasl** — Connecting hamzah when continuing recitation\n"
                    + "10. **Ra Rules** — When ر is heavy or light\n\n"
                    + "These are the core hukum every student learns step by step with a teacher."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "type of tajweed", "types of tajweed", "tajweed type", "tajweed rules",
                "categories of tajweed", "main tajweed")) {
            return "The main categories (types) of Tajweed rules are:\n\n"
                    + "1. **Makharij al-Huruf** — Correct articulation points of each Arabic letter\n"
                    + "2. **Sifaat al-Huruf** — Letter characteristics (heavy/light, qalqalah, etc.)\n"
                    + "3. **Noon Sakinah & Tanween** — Izhar, Idgham, Iqlab, Ikhfa\n"
                    + "4. **Meem Sakinah** — Ikhfa Shafawi, Idgham Shafawi, Izhar Shafawi\n"
                    + "5. **Madd** — Rules of lengthening (Tabi'i, Munfasil, Muttasil, Lazim, etc.)\n"
                    + "6. **Qalqalah** — Echoing sound on ق ط ب ج د when saakinah\n"
                    + "7. **Tafkhim & Tarqiq** — Heavy and light pronunciation\n"
                    + "8. **Waqf & Ibtida** — Rules of stopping and starting recitation\n"
                    + "9. **Hamzah al-Wasl** — Connecting hamzah rules\n"
                    + "10. **Ra Rules** — Pronunciation of the letter ر (tafkhim/tarqiq)\n\n"
                    + "Students typically learn Makharij first, then Noon Sakinah, Madd, and Qalqalah."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "tajweed", "تجويد", "improve")) {
            return "To improve Tajweed:\n\n"
                    + "1. Learn the makhraj (articulation points) of each Arabic letter\n"
                    + "2. Study the rules systematically: Noon Sakinah, Meem Sakinah, Madd, Qalqalah, and heavy/light letters\n"
                    + "3. Practice daily with a teacher who can correct your recitation\n"
                    + "4. Listen to skilled Qaris and repeat after them\n"
                    + "5. Record yourself and compare with correct recitation\n\n"
                    + "Consistency and teacher feedback are the most important factors."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "sukoon", "sukun", "سكون")) {
            return "**Sukoon** (ـْ) indicates the absence of a vowel on a letter — the letter is pronounced without extension.\n\n"
                    + "In Tajweed, sukoon affects rules like Noon Sakinah, Qalqalah (on ق ط ب ج د when saakinah), and stopping (waqf).\n\n"
                    + "Example: in the word كِتَابْ, the ب carries sukoon when you stop on it."
                    + FALLBACK_NOTE;
        }

        if (containsAny(q, "memoriz", "hafiz", "hifz", "حفظ")) {
            return "Tips for Quran memorization (Hifz):\n\n"
                    + "1. Set a fixed daily portion — even 3–5 ayahs consistently\n"
                    + "2. Review old portions before learning new ones (rule of thumb: 70% review, 30% new)\n"
                    + "3. Recite with correct Tajweed from the start\n"
                    + "4. Use the same mushaf and reciter for consistency\n"
                    + "5. Pray with what you have memorized to strengthen retention"
                    + FALLBACK_NOTE;
        }

        return null;
    }

    private static boolean containsAny(String text, String... keywords) {
        for (String kw : keywords) {
            if (text.contains(kw)) return true;
        }
        return false;
    }
}
