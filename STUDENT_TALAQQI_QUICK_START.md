# Quick Start Guide - Student Talaqqi Session

## 5-Minute Setup

### Step 1: Copy Files
```bash
# Classes (compile to WEB-INF/classes/)
cp src/model/QuranVerse.java → src/model/
cp src/dao/QuranDAO.java → src/dao/
cp src/controller/StudentTalaqqiSessionServlet.java → src/controller/

# Views
cp WEB-INF/views/studentTalaqqiSession.jsp → WEB-INF/views/
```

### Step 2: Update web.xml
Already done! Check:
- `<servlet-name>StudentTalaqqiSessionServlet</servlet-name>` exists
- `<url-pattern>/student/talaqqi-session</url-pattern>` mapped

### Step 3: Compile & Deploy
```bash
cd c:\xampp\tomcat\webapps\TalaqqiHub
javac -cp ".:WEB-INF/lib/*:WEB-INF/classes" -d WEB-INF/classes src/model/QuranVerse.java
javac -cp ".:WEB-INF/lib/*:WEB-INF/classes" -d WEB-INF/classes src/dao/QuranDAO.java
javac -cp ".:WEB-INF/lib/*:WEB-INF/classes" -d WEB-INF/classes src/controller/StudentTalaqqiSessionServlet.java
```

### Step 4: Restart Tomcat
```bash
$CATALINA_HOME/bin/catalina.sh stop
$CATALINA_HOME/bin/catalina.sh start
```

### Step 5: Test
1. Login as student (if not already)
2. Navigate to Talaqqi Sessions
3. Click "Join Live Session"
4. Jitsi Meet should load

---

## File Manifest

```
TalaqqiHub/
├── src/
│   ├── model/
│   │   ├── QuranVerse.java          ✅ NEW
│   │   └── TalaqqiSession.java      (extended)
│   ├── dao/
│   │   ├── QuranDAO.java            ✅ NEW
│   │   └── TalaqqiSessionDAO.java   (extended with 2 methods)
│   └── controller/
│       ├── StudentTalaqqiSessionServlet.java  ✅ NEW
│       └── TeacherTalaqqiSessionServlet.java  (reference)
│
├── WEB-INF/
│   └── views/
│       ├── studentTalaqqiSession.jsp          ✅ NEW
│       └── teacherTalaqqiSession.jsp          (reference)
│
├── web.xml                          ✅ UPDATED (servlet + mapping)
└── STUDENT_TALAQQI_SESSION_IMPLEMENTATION.md  ✅ NEW
```

---

## URL Reference

| Route | Method | Purpose |
|-------|--------|---------|
| `/student/talaqqi-session` | GET | Load session view |
| `/student/talaqqi-session?sessionId=X` | GET | Load specific session |
| `/student/talaqqi-session?action=joinSession` | POST | Join video call |
| `/student/talaqqi-session?action=leaveSession` | POST | Leave video call |

---

## Key Endpoints

### Al-Quran Cloud API Examples
```
https://api.alquran.cloud/v1/ayah/1:1/editions/quran-uthmani,en.sahih
https://api.alquran.cloud/v1/surah/2
https://api.alquran.cloud/v1/surah
```

### Jitsi Meet
```
https://meet.jit.si/external_api.js
Room: TalaqqiHub-[timestamp]
```

---

## Configuration

### Timeouts (QuranDAO.java)
```java
private static final int CONNECT_TIMEOUT_MS = 10_000;   // 10 seconds
private static final int READ_TIMEOUT_MS = 15_000;      // 15 seconds
```

### Verse Pre-loading (StudentTalaqqiSessionServlet.java)
```java
verses = loadVerseSequence(surahNumber, ayahNumber, 5);  // Load 5 verses
```

### Session Status
```
Possible values: "pending", "active", "ended"
Stored in HTTP session, not database
```

---

## Common Tasks

### Add New Surah to Display
```java
// In StudentTalaqqiSessionServlet.doGet()
QuranVerse verse = quranDAO.getAyah(2, 255);  // Ayat al-Kursi
request.setAttribute("currentVerse", verse);
```

### Fetch All Verses in a Surah
```java
QuranDAO dao = new QuranDAO();
List<QuranVerse> verses = dao.getSurahVerses(1);  // All of Al-Fatiha
```

### Change Video Quality
```javascript
// In studentTalaqqiSession.jsp
configOverwrite: {
    startAudioOnly: true,
    resolution: 720,
    enableLayerSuspension: true
}
```

### Customize Colors
```css
/* In studentTalaqqiSession.jsp <style> tag */
.sidebar-gradient { 
    background: linear-gradient(180deg, #YOUR_COLOR_1 0%, #YOUR_COLOR_2 100%); 
}
.btn-green-gradient {
    background: linear-gradient(90deg, #YOUR_COLOR_A 0%, #YOUR_COLOR_B 100%);
}
```

---

## Testing Commands

### Test QuranDAO
```bash
cd src/dao
java -cp ".:../../WEB-INF/lib/*" QuranDAO
# Output: Surah: Al-Fatiha, Ayah: 1, Arabic: ..., English: ...
```

### Test Database Connection
```sql
-- Check session data
SELECT * FROM talaqqisession 
WHERE bookingId IN (
    SELECT bookingId FROM classbooking 
    WHERE studentId = 'STU-001'
);
```

### Test API with curl
```bash
curl "https://api.alquran.cloud/v1/ayah/1:1/editions/quran-uthmani,en.sahih"
```

---

## Debugging

### Enable Debug Logging
```java
// Add to StudentTalaqqiSessionServlet.java
System.out.println("[DEBUG] String variable = " + value);
System.err.println("[ERROR] Exception occurred: " + e.getMessage());
```

### Check Tomcat Logs
```bash
tail -f $CATALINA_HOME/logs/catalina.out
tail -f $CATALINA_HOME/logs/localhost.[date].log
```

### Browser Console
- Press F12 → Console tab
- Check for JavaScript errors
- Monitor network requests (Network tab)
- Check Jitsi API initialization

---

## Performance Tips

1. **Cache Verses**: Store fetched verses in HashMap<String, QuranVerse>
2. **Connection Pool**: Use DBConnection pooling for database
3. **CDN**: Served from CDN (Tailwind, Font Awesome, Jitsi)
4. **Lazy Load Jitsi**: Only initialize when button clicked (already done!)
5. **Prefetch DNS**: Add to JSP <head>:
   ```html
   <link rel="dns-prefetch" href="https://api.alquran.cloud">
   <link rel="dns-prefetch" href="https://meet.jit.si">
   ```

---

## Security Notes

✅ **Implemented**:
- Student session authentication
- Ownership scope guards (can't view others' sessions)
- SQL injection protection (prepared statements)
- JSON injection protection (escapeJson method)
- CSRF protection via HTTP POST

⚠️ **Recommended**:
- Add Content Security Policy (CSP) headers
- Use HTTPS only in production
- Rate limit API calls
- Implement failed login attempts lockout
- Regular security audits

---

## Troubleshooting Checklist

```
[ ] Can access /student/talaqqi-session?
[ ] Database has classbooking records with status="Upcoming"?
[ ] Student is properly authenticated (studentId in session)?
[ ] Quran API is reachable (check network tab)?
[ ] org.json library in classpath?
[ ] Tomcat restarted after compilation?
[ ] SSL certificate valid (if using HTTPS)?
[ ] Student's class booking is for a future date?
[ ] Teacher is assigned to the class?
```

---

## Next Steps

1. **Setup Completion**
   - Verify compilation without errors
   - Test database connectivity
   - Confirm Tomcat restart

2. **Feature Enhancements** (Optional)
   - Add recording capability
   - Implement chat feature
   - Add attendance auto-tracking
   - Create session history view
   - Add student ratings/feedback

3. **Performance Optimization**
   - Implement verse caching layer
   - Add database indexing for queries
   - Set up CDN for static assets
   - Configure Gzip compression

4. **Production Deployment**
   - Enable SSL/TLS
   - Set up monitoring (error tracking, APM)
   - Configure backup strategy
   - Create disaster recovery plan

---

## Support Resources

- **Jitsi Meet Docs**: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-iframe/
- **Al-Quran Cloud API**: https://api.alquran.cloud/
- **Tailwind CSS**: https://tailwindcss.com/docs
- **Oracle Servlet Docs**: https://docs.oracle.com/javaee/7/api/javax/servlet/package-summary.html

---

**Version**: 1.0  
**Last Updated**: March 28, 2026  
**Status**: Ready for Production
