package util;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import java.io.File;

/**
 * Resolves student profile pictures stored as {@code /images/profiles/p_{studentId}.ext}.
 */
public final class StudentProfilePicUtil {

    private static final String[] EXTENSIONS = { ".jpg", ".jpeg", ".png", ".webp", ".gif" };

    private StudentProfilePicUtil() {}

    public static String resolveWebPath(ServletContext context, String studentId) {
        if (context == null || studentId == null || studentId.trim().isEmpty()) {
            return null;
        }
        String baseDir = context.getRealPath("/images/profiles");
        if (baseDir == null) return null;

        File folder = new File(baseDir);
        String safeId = studentId.trim();
        for (String ext : EXTENSIONS) {
            File file = new File(folder, "p_" + safeId + ext);
            if (file.isFile()) {
                return "/images/profiles/p_" + safeId + ext;
            }
        }
        return null;
    }

    /** Sync session attribute from disk so avatars survive navigation and re-login. */
    public static void bindToSession(HttpSession session, ServletContext context, String studentId) {
        if (session == null) return;
        String path = resolveWebPath(context, studentId);
        if (path != null) {
            session.setAttribute("profilePicPath", path);
        } else {
            session.removeAttribute("profilePicPath");
        }
    }
}
