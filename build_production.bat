@echo off
echo ==========================================
echo  Tomato Streaming - Build de Producao
echo ==========================================
echo.

echo [1/5] Limpando build anterior...
call flutter clean
echo.

echo [2/5] Instalando dependencias...
call flutter pub get
echo.

echo [3/5] Gerando localizacoes...
call flutter gen-l10n
echo.

echo [4/5] Compilando APK Release com ofuscacao...
call flutter build apk --release --obfuscate --split-debug-info=build/debug-info
echo.

echo [5/5] Build concluido!
echo.
echo APK gerado em: build\app\outputs\flutter-apk\app-release.apk
echo.
echo Tamanho do APK:
dir build\app\outputs\flutter-apk\app-release.apk
echo.

echo ==========================================
echo  Build Finalizado com Sucesso!
echo ==========================================
echo.
echo Proximos passos:
echo 1. Instalar: flutter install --release
echo 2. Ou copiar APK de: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
