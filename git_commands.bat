@echo off
echo ==========================================
echo  Tomato Streaming - Comandos Git Uteis
echo ==========================================
echo.

:menu
echo Escolha uma opcao:
echo.
echo [1] Inicializar repositorio e fazer primeiro commit
echo [2] Commit das correcoes e push
echo [3] Criar tag e release (v1.0.0)
echo [4] Atualizar versao e criar nova release
echo [5] Ver status do repositorio
echo [6] Ver log de commits
echo [7] Sair
echo.
set /p choice="Digite o numero: "

if "%choice%"=="1" goto init
if "%choice%"=="2" goto commit_fix
if "%choice%"=="3" goto first_release
if "%choice%"=="4" goto new_release
if "%choice%"=="5" goto status
if "%choice%"=="6" goto log
if "%choice%"=="7" goto end
goto menu

:init
echo.
echo [Inicializando repositorio...]
git init
git add .
git commit -m "🎉 Initial commit - Tomato Streaming v1.0.0"
echo.
echo Agora configure o remote:
echo git remote add origin https://github.com/SEU_USUARIO/tomato_streaming.git
echo git branch -M main
echo git push -u origin main
echo.
pause
goto menu

:commit_fix
echo.
echo [Commitando correcoes...]
git add .
git commit -m "fix: ajustar versão minima do Dart SDK para 3.5.0"
git push origin main
echo.
echo Correcoes enviadas!
echo.
pause
goto menu

:first_release
echo.
echo [Criando primeira release v1.0.0...]
git tag -a v1.0.0 -m "🎉 Release v1.0.0 - Primeira versão oficial

Funcionalidades:
- Sistema de anúncios com redundância (AdMob + Unity Ads)
- Criptografia AES-256 e ofuscação ProGuard
- Notificações de novos episódios
- Player com controles avançados (±10 segundos)
- Suporte a Português e Inglês
- Banners discretos
- GitHub Actions CI/CD configurado"

git push origin v1.0.0
echo.
echo Release v1.0.0 criada! 
echo Verifique o progresso em: https://github.com/SEU_USUARIO/tomato_streaming/actions
echo.
pause
goto menu

:new_release
echo.
set /p version="Digite a nova versao (ex: 1.1.0): "
echo.
echo [Criando release v%version%...]
git add .
git commit -m "chore: bump version to %version%"
git push origin main
git tag -a v%version% -m "Release v%version%"
git push origin v%version%
echo.
echo Release v%version% criada! Verifique em GitHub Actions.
echo.
pause
goto menu

:status
echo.
git status
echo.
pause
goto menu

:log
echo.
git log --oneline --graph --all -10
echo.
pause
goto menu

:end
echo.
echo Ate logo!
exit
