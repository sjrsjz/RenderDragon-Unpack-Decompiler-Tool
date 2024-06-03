@echo off
setlocal enabledelayedexpansion
echo ********************************************
echo ** RenderDragon unpack and decompile tool **
echo ********************************************
echo.
rem set path for tools
set "dxc_path=%~dp0dxc.exe"
set "dxilspirv=%~dp0dxil-spirv.exe"
set "materialbintool=%~dp0MaterialBinTool-0.8.2-native-image.exe"

echo Please choose an option:
echo 1. Unpack and decompile dxbc shaders
echo 2. Provide directory and decompile dxbc shaders
set /p "user_choice=Input option number: "

if "%user_choice%"=="1" (
    rem bin file path
    set /p "bin_file_path=Input file(*.material.bin) path: "
    "!materialbintool!" -u !bin_file_path!
    if !errorlevel! neq 0 (
        echo [MaterialBinTool]Failed: "!bin_file_path!"
        exit /b 1
    ) else (
        echo [MaterialBinTool]Success: "!bin_file_path!"
    )
    set "folder_path=!bin_file_path:~1,-14!"
    echo folder_path: "!folder_path!"

) else if "%user_choice%"=="2" (
    rem folder path
    set /p "folder_path=Input DXBC folder: "
    set "folder_path=!folder_path:"=!"
    echo %folder_path%
)

rem decompile dxbc shaders
echo Start to decompile DXBC shaders...
echo %folder_path%
for /r "%folder_path%" %%f in (*.dxbc) do (
    rem get file name without extension
    set "filename=%%~dpnf"
    rem decompile dxbc to dxil
    "%dxc_path%" /dumpbin /nologo "%%f" > "!filename!.dxil"
    if !errorlevel! neq 0 (
        echo [DXC]Failed: "%%f"
        rem delete failed output file
        del "!filename!.dxil"
    ) else (
        echo [DXC]Success: "%%f"
    )

    "%dxilspirv%" --glsl "%%f" > "!filename!.glsl"
    if !errorlevel! neq 0 (
        echo [DXIL SPIRV]Failed: "%%f"
        rem delete failed output file
        del "!filename!.glsl"
    ) else (
        echo [DXIL SPIRV]Success: "%%f"
    )
)

endlocal