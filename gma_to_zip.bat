@echo off
set extractor=gmad.exe
set compressor=7z.exe

set addonfile=
set zipfile=
set execfile=

for %%a in (%0) do set execfile=%%~nxa
for %%a in (%1) do set addonfile=%%~dpnxa
for %%a in (%2) do set zipfile=%%~dpnxa

set addonfile="%addonfile%"
set zipfile="%zipfile%"

IF %addonfile%=="" (
	echo You need to specify an addon file.
	echo Useage: "%execfile% <addonfile> [<zipfile>]"
	echo.

	pause
	@echo on
	@exit /B 1
)

IF not exist %addonfile% (
	echo The file %addonfile% does not exist.
	echo Useage: "%execfile% <addonfile> [<zipfile>]"
	echo.

	pause
	@echo on
	@exit /B 2
)

for %%a in (%addonfile%) do set rawaddonfile=%%~dpna
for %%a in (%addonfile%) do set rawaddonfilename=%%~na

IF %zipfile%=="" (
    set zipfile="%rawaddonfile%.zip"
)

set tmpfolder=%tmp%/gmatozip
set addontmp="%tmpfolder%/%rawaddonfilename%"

IF exist "%tmpfolder%" (
	rmdir /s /q "%tmpfolder%" > nul
)

IF exist %zipfile% (
	del /f /q %zipfile% > nul
)

echo Extracting Addon...
echo.

echo %extractor% extract -file %addonfile% -out %addontmp%
%extractor% extract -file %addonfile% -out %addontmp%
if errorlevel 1 (
	echo.
	echo.
	echo The file %addonfile% could not be extracted.
	echo Useage: "%execfile% <addonfile> [<zipfile>]"
	echo.

	rmdir /s /q "%tmpfolder%" > nul
	pause
	@echo on
	@exit /B 3
)

echo.
echo.
echo.
echo.


echo Zipping addon...
echo.

echo %compressor% a -tzip -mm=BZip2 -mtc=off -mx=9 -mpass=5 -md=900000b -y %zipfile% %addontmp%
%compressor% a -tzip -mm=BZip2 -mtc=off -mx=9 -mpass=5 -md=900000b -y %zipfile% %addontmp%
if errorlevel 1 (
	echo.
	echo.
	echo The file %zipfile% could not be created.
	echo Useage: "%execfile% <addonfile> [<zipfile>]"
	echo.

	rmdir /s /q "%tmpfolder%" > nul
	pause
	@echo on
	@exit /B 4
)

rmdir /s /q "%tmpfolder%" > nul

echo.
echo.
echo.
echo.

@echo on
@exit /B 0

