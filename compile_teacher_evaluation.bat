@echo off
REM ======================================
REM Teacher Evaluation Module - Compile Script
REM ======================================
REM This script compiles all Java files for the Teacher Evaluation Module

setlocal enabledelayedexpansion

REM Get current directory
set CURRENT_DIR=%CD%

REM Define paths
set SRC_DIR=%CURRENT_DIR%\src
set BUILD_DIR=%CURRENT_DIR%\WEB-INF\classes
set LIB_DIR=%CURRENT_DIR%\WEB-INF\lib
set TOMCAT_CLASSES=%CURRENT_DIR%\WEB-INF\classes

REM Create build and classes directories if they don't exist
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%LIB_DIR%" mkdir "%LIB_DIR%"

REM Display build information
echo.
echo ======================================
echo Teacher Evaluation Module - Compilation
echo ======================================
echo.
echo Source Directory: %SRC_DIR%
echo Build Directory: %BUILD_DIR%
echo Library Directory: %LIB_DIR%
echo.

REM Set classpath
set CLASSPATH=%LIB_DIR%\*;%BUILD_DIR%

REM Compile Model class
echo [1/3] Compiling Evaluation.java...
javac -cp "%CLASSPATH%" -d "%BUILD_DIR%" "%SRC_DIR%\com\talaqqihub\model\Evaluation.java"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to compile Evaluation.java
    pause
    exit /b 1
)
echo [OK] Evaluation.java compiled successfully

REM Compile DAO class
echo.
echo [2/3] Compiling TeacherEvaluationDAO.java...
javac -cp "%CLASSPATH%" -d "%BUILD_DIR%" "%SRC_DIR%\com\talaqqihub\dao\TeacherEvaluationDAO.java"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to compile TeacherEvaluationDAO.java
    pause
    exit /b 1
)
echo [OK] TeacherEvaluationDAO.java compiled successfully

REM Compile Servlet class
echo.
echo [3/3] Compiling TeacherEvaluationServlet.java...
javac -cp "%CLASSPATH%" -d "%BUILD_DIR%" "%SRC_DIR%\com\talaqqihub\servlet\TeacherEvaluationServlet.java"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to compile TeacherEvaluationServlet.java
    pause
    exit /b 1
)
echo [OK] TeacherEvaluationServlet.java compiled successfully

echo.
echo ======================================
echo All files compiled successfully!
echo ======================================
echo.
echo Compiled files location: %BUILD_DIR%
echo.
echo Next Steps:
echo   1. Ensure evaluation table exists in database
echo   2. Verify web.xml servlet mapping
echo   3. Restart Tomcat server
echo   4. Access at: http://localhost:8080/TalaqqiHub/teacher/evaluation
echo.
echo ======================================

pause
