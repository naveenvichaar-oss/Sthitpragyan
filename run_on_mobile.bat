@echo off
title स्थितप्रज्ञ (Sthitaprajna) Mobile Web Server
echo =======================================================
echo   📱 स्थितप्रज्ञ (Sthitaprajna) मोबाइल सर्वर प्रारंभ हो रहा है...
echo =======================================================
echo.
echo आपका लोकल IP: 192.168.0.105
echo.
echo फ़ोन के Chrome ब्राउज़र में यह लिंक खोलें:
echo 👉 http://192.168.0.105:8080
echo.
echo (ध्यान दें: फ़ोन और लैपटॉप दोनों एक ही Wi-Fi से जुड़े होने चाहिए)
echo =======================================================
echo.

cd /d "%~dp0"
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
pause

