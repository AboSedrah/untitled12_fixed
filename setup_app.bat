@echo off
REM Use SET for variables in batch files
set PKG=com.example.untitled12

REM 1) Clean, build, and run
echo [1] Cleaning, getting dependencies, and running the app...
flutter clean && flutter pub get && flutter run

REM 2) Grant notification permission (Android 13+)
echo [2] Granting POST_NOTIFICATIONS permission...
adb shell pm grant %PKG% android.permission.POST_NOTIFICATIONS

REM 3) Allow exact alarm scheduling (Android 12+)
echo [3] Opening settings to allow SCHEDULE_EXACT_ALARM (manual step required)...
REM This opens the settings page for you to enable it manually.
adb shell am start -a android.settings.REQUEST_SCHEDULE_EXACT_ALARM -d package:%PKG%

REM Alternative for step 3 (uncomment to use, may not work on all devices)
REM echo [3b] Attempting to grant SCHEDULE_EXACT_ALARM directly...
REM adb shell appops set %PKG% SCHEDULE_EXACT_ALARM allow

REM 4) Whitelist from battery optimization
echo [4] Adding app to device idle whitelist...
adb shell cmd deviceidle whitelist +%PKG%

REM 5) Open app notification settings for verification
echo [5] Opening app notification settings for you to verify...
adb shell am start -a android.settings.APP_NOTIFICATION_SETTINGS --es android.provider.extra.APP_PACKAGE %PKG%

echo.
echo Script finished.
