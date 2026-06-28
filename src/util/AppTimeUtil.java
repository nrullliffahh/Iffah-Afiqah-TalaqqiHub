package util;

import java.sql.Time;
import java.time.LocalTime;
import java.time.ZoneId;

/** Application timezone for attendance join/leave timestamps (Malaysia). */
public final class AppTimeUtil {

    public static final ZoneId APP_ZONE = ZoneId.of("Asia/Kuala_Lumpur");

    private AppTimeUtil() {}

    /** Current local time as {@link Time} for attendance columns. */
    public static Time currentSqlTime() {
        return Time.valueOf(LocalTime.now(APP_ZONE));
    }
}
