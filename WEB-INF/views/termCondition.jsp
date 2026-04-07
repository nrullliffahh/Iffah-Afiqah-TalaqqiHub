<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Terms & Conditions - TalaqqiHub</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-gray-100">

    <!-- Overlay and centered modal -->
    <div class="fixed inset-0 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="w-full max-w-3xl mx-auto">

        <div class="bg-white rounded-xl shadow-xl overflow-hidden">

          <!-- Header -->
          <div class="relative bg-gradient-to-r from-indigo-600 to-purple-700 p-6">
            <div class="flex items-start justify-between gap-4">
              <div>
                <h1 class="text-white text-2xl font-semibold">Terms &amp; Conditions</h1>
                <p class="text-indigo-100 mt-1">Please read these terms carefully before using TalaqqiHub</p>
              </div>
              <div class="flex items-start">
                <button type="button" aria-label="Close" onclick="closeModal()" class="text-white hover:bg-white/10 p-2 rounded-md">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
          </div>

          <!-- Content -->
          <div class="p-6 max-h-[60vh] overflow-y-auto">

            <!-- Terms list -->
            <div class="space-y-6">

              <!-- Reusable term item structure: number badge, icon, title, huraian -->

              <!-- 1 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">1</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Acceptance of Terms</h3>
                    <p class="text-sm text-gray-700 mt-1">By registering and using TalaqqiHub, students agree to comply with all platform rules and guidelines to maintain a safe and effective environment for Quran learning. Continued use constitutes acceptance of these terms.</p>
                  </div>
                </div>
              </div>

              <!-- 2 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">2</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Eligibility and Account Responsibility</h3>
                    <div class="text-sm text-gray-700 mt-1">
                      <p>Students must meet any eligibility criteria specified by TalaqqiHub and provide accurate personal information when registering. Accounts are individual — do not share login credentials, and keep them secure. You are responsible for all activity under your account.</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 3 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">3</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Class Participation and Attendance</h3>
                    <div class="text-sm text-gray-700 mt-1">
                      <p>Students are expected to be punctual and attend scheduled classes regularly. Attendance may be recorded automatically; repeated absences or lateness can negatively affect learning progress and may prompt teacher or admin follow-up.</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 4 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">4</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Class Booking and Cancellation</h3>
                    <div class="text-sm text-gray-700 mt-1">
                      <ul class="list-disc ml-5">
                        <li>Students book sessions through the platform and must follow stated booking rules.</li>
                        <li>Cancellations should include valid reasons; frequent or last-minute cancellations may be monitored and addressed by admins.</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 5 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">5</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Learning Conduct and Ethics</h3>
                    <p class="text-sm text-gray-700 mt-1">Students must behave respectfully toward teachers and peers. Offensive language, harassment, or misuse of the platform is prohibited — TalaqqiHub is strictly for Quran learning purposes and respectful conduct is required.</p>
                  </div>
                </div>
              </div>

              <!-- 6 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">6</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Evaluation, Feedback, and Progress Records</h3>
                    <p class="text-sm text-gray-700 mt-1">Teachers will evaluate recitation, provide constructive feedback, and record progress. Students can review reports to track improvement and apply feedback for continued learning.</p>
                  </div>
                </div>
              </div>

              <!-- 7 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">7</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">AI Assistance Usage</h3>
                    <div class="text-sm text-gray-700 mt-1">
                      <p>AI chat assistance is available to support learning and answer questions, but it does not replace teachers. Do not use AI features for unrelated or inappropriate purposes.</p>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 8 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">8</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Data Privacy and Security</h3>
                    <p class="text-sm text-gray-700 mt-1">Student data is stored securely and used only for learning delivery and system management. TalaqqiHub will not share personal data without consent except where required by law or safety concerns.</p>
                  </div>
                </div>
              </div>

              <!-- 9 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">9</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">System Availability</h3>
                    <p class="text-sm text-gray-700 mt-1">TalaqqiHub strives for continuous access but may experience downtime due to maintenance or technical issues. Reliable internet access is required to use the platform.</p>
                  </div>
                </div>
              </div>

              <!-- 10 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">10</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Violation and Account Termination</h3>
                    <p class="text-sm text-gray-700 mt-1">Violations of these terms may result in suspension or termination of access. Serious or repeated misconduct can lead to permanent account restriction and administrative action.</p>
                  </div>
                </div>
              </div>

              <!-- 11 -->
              <div class="flex gap-4">
                <div class="flex-shrink-0">
                  <div class="flex items-center justify-center w-10 h-10 rounded-full bg-indigo-50 text-indigo-700 font-semibold">11</div>
                </div>
                <div class="flex-1">
                  <div>
                    <h3 class="text-lg font-medium">Updates to Terms</h3>
                    <p class="text-sm text-gray-700 mt-1">TalaqqiHub may update these terms when necessary. Continued use of the platform after changes indicates acceptance of the updated terms; we recommend reviewing terms periodically.</p>
                  </div>
                </div>
              </div>

            </div>

            <!-- Important notice -->
            <div class="mt-6">
              <div class="bg-green-50 border-l-4 border-green-400 p-4 rounded-md">
                <p class="text-green-800 text-sm">Important: By clicking "Understand and Agree" you confirm that you have read, understood, and accepted all Terms &amp; Conditions of TalaqqiHub.</p>
              </div>
            </div>

            <!-- Actions -->
            <div class="mt-6 flex items-center justify-end gap-3">
              <button onclick="cancelAction()" class="px-4 py-2 rounded-lg bg-gray-200 text-gray-800 hover:bg-gray-300">Cancel</button>
              <button id="agreeBtn" onclick="agreeAction()" class="px-4 py-2 rounded-lg bg-purple-600 text-white hover:bg-purple-700">Understand and Agree</button>
            </div>

          </div>

        </div>
      </div>
    </div>

    <script>
      function closeModal(){
        if (document.referrer) location.href = document.referrer;
        else window.close();
      }
      function cancelAction(){
        closeModal();
      }
      function agreeAction(){
        // No server-side action here. Redirect to home or previous page.
        // Integrate with application flow as needed.
        if (document.referrer) location.href = document.referrer;
        else location.href = '/';
      }
    </script>

  </body>
</html>
