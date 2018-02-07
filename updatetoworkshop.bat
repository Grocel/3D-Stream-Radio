@echo off
set compressor=gmad.exe
set uploader=gmpublish.exe
set zipper=gma_to_zip.bat
set addonid=246756300

rem Compress
:Compress
	cls
	echo Addon updating setup.
	echo.

	set addonpath=%CD%
	for %%a in ("%CD%") do set addonpath=%%~dpnxa
	for %%a in ("%CD%") do set addonname=%%~nxa
	set gmapath=%addonpath%/noupload/%addonname%.gma

	echo %compressor% create -folder "%addonpath%" -out "%gmapath%"
	%compressor% create -folder "%addonpath%" -out "%gmapath%"
	if errorlevel 1 (
		echo Coudln't compress the addon!
		pause
		goto Compress
	)

	IF exist %zipper% (
	echo "%CD%/%zipper%" "%gmapath%"
		call "%CD%/%zipper%" "%gmapath%"
		@echo off
	)

	IF "%addonid%"=="" (
		goto End
	)

	pause
	:Upload_Question
		cls
		set /P upload=Upload to Workshop? (Y/N):

		if /I %upload%==Y (
			goto Upload
		)

		if /I %upload%==N (
			goto End
		)
	goto Upload_Question


rem Upload
:Upload
	cls
	set /P changes= < "%addonpath%\changes.txt"
	echo %uploader% update -addon "%gmapath%" -id %addonid% -changes "%changes%"
	%uploader% update -addon "%gmapath%" -id %addonid% -changes "%changes%"

	if errorlevel 1 (
		echo Error Uploading "%gmapath%"!
		pause
		goto Upload
	)
pause

:End
@echo on
@exit /B 0

