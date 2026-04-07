# Quran Setting Real-Time Display - Test Guide

## Issue Fixed
Student's page now displays updated Quran verses in real-time when a teacher changes the Quran reference during a live session, without requiring a manual page refresh.

## Implementation Details

### Backend Change (StudentTalaqqiSessionServlet.java)
- **New POST action**: `getCurrentQuran`
- **Response format**: JSON with `surah`, `ayah`, `ayahEnd` fields
- **Authentication**: Verified against student's enrolled sessions
- **Fallback**: Returns upcoming session if no specific `sessionId` provided

### Frontend Change (studentTalaqqiSession.jsp)
- **Polling interval**: 3 seconds (configurable via `POLL_INTERVAL_MS`)
- **API endpoint**: Calls `/student/sessions` with `action=getCurrentQuran`
- **Auto-update mechanism**: 
  - Detects surah/ayah changes from polling response
  - Fetches new verses from Al-Quran Cloud API
  - Re-renders DOM with new verses
  - Restores interaction handlers (translation toggles)

---

## Test Procedure

### Scenario 1: Basic Polling Update
1. **Setup**:
   - Open student portal, navigate to "Talaqqi Sessions"
   - Student sees session with Surah 2, Ayah 1

2. **Teacher Action**:
   - Teacher opens session from their portal
   - Teacher changes Quran reference to Surah 5, Ayah 10
   - Teacher clicks "Save" or "Update"

3. **Expected Student Behavior**:
   - Within 3 seconds: Student's verse display updates automatically
   - New verses (Surah 5, Ayah 10-14) display
   - Console shows: `[Quran Update] Surah 5:10 (was 2:1)`
   - Translation toggle still works on new verses

### Scenario 2: Range Update (Ayah Range)
1. Teacher sets Surah 1, Ayah 1-7 (all of Surah Al-Fatiha)
2. Student automatically receives and displays all 7 verses
3. Verses render with proper ayah numbers

### Scenario 3: Multiple Updates
1. Teacher changes reference multiple times
2. Each change propagates to student within 3 seconds
3. Verses update correctly each time

### Scenario 4: No Active Session
1. Student has no session booked
2. Polling silently fails (no error message)
3. Student continues viewing default/previous verses

---

## Debug Information

### Browser Console Output
When updates occur, you'll see:
```
[Quran Update] Surah 2:5 (was 2:1)
[Verses Updated] Displaying 5 verse(s)
```

### Network Activity
In DevTools Network tab, you'll see periodic POST requests to:
```
POST /student/sessions
Form Data: action=getCurrentQuran
```

### Troubleshooting

#### Verses Don't Update
1. Check browser console for errors
2. Verify teacher actually saved the Quran change
3. Ensure student's session ID is correct
4. Check database for `classschedule.classSurah`, `classAyah` updates

#### API Errors
- May see "Translation not available" if Al-Quran Cloud API has issues
- Arabic text may fail to load if API is down
- Polling continues to retry every 3 seconds

#### Performance
- Polling adds minimal overhead (1 POST every 3 seconds)
- DOM updates only occur when surah/ayah actually change
- Use browser's Performance tab to monitor

---

## Configuration

To adjust polling interval, in `studentTalaqqiSession.jsp`:
```javascript
const POLL_INTERVAL_MS = 3000; // Change this value (milliseconds)
```

Recommended values:
- `1000` = Best responsiveness, slight network overhead
- `3000` = Balanced (default)
- `5000` = Lower overhead, slight delay in updates

---

## Files Modified
- `src/controller/StudentTalaqqiSessionServlet.java` - Added `getCurrentQuran` action
- `WEB-INF/views/studentTalaqqiSession.jsp` - Added polling mechanism

## Backward Compatibility
✓ No breaking changes
✓ Existing functionality preserved
✓ Silent failures (non-disruptive errors)
✓ Works with existing authentication/authorization
