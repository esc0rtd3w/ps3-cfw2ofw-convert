@echo off

:: Based on original PS3_OFW_TOOLS_470 convert.bat file
:: Source http://www.pspx.ru/forum/showthread.php?t=106399


:reset
:: Change terminal size
::mode con lines=27

cls

set scriptVersion=0.4

title PS3 CFW to OFW Game and App Converter v%scriptVersion%                      esc0rtd3w 2017

color 0e

set waitTime=3
set wait=ping -n %waitTime% 127.0.0.1

set failType=0

set askUpdate=1
set doUpdate=1
set prefixURL=https://
set updateXML=0
set updateLink=0
set updatePackageAvailable=1
set multipleUpdates=0
set packageID=0

set isBlankXML=0

set updatesAvailable=0
set updatesTitleID=0
set updatesName=0
set updatesVersion=0
set updatesSize=0
set updatesURL=0

set licenseStatus=1

set filetypes=99
set discID=BXXX00000
set gameID=NPXX00000

set detectedGame=0

set paramDumpTitle=0
set paramDumpTitleID=0
set paramDumpVersion=0
set paramDumpVersionTargetApp=0
set paramDumpVersionApp=0

set convertedTitleID=0
set convertedTitleIDTemp=0
set titleIDLetterCode=XXXX
set titleIDLetterCodeTemp=XXXX
set titleIDNumberCode=00000
set titleIDNumberCodeTemp=00000


:: Set ROOT Path
::set root=%~dp0
set root=%cd%

:: Set BIN path
if exist "%root%\bin\make_npdata.exe" set binPath=%root%\bin
if exist "%root%\tool\make_npdata.exe" set binPath=%root%\tool


:: Set Tool Variables
set cocolor="%binPath%\cocolor.exe"
set dklic_validator="%binPath%\dklic_validator.exe"
set freedata="%binPath%\freedata.exe"
set HashConsole="%binPath%\HashConsole.exe"
set klic_bruteforcer="%binPath%\klic_bruteforcer.exe"
set make_c00_edat="%binPath%\make_c00_edat.exe"
set make_npdata="%binPath%\make_npdata.exe"
set make_npdata_old="%binPath%\make_npdata_old.exe"
set npdpc="%binPath%\npdpc.exe"
set pgdecrypt="%binPath%\pgdecrypt.exe"
set ps3xport="%binPath%\ps3xport.exe"
set pspkg="%binPath%\pspkg.exe"
set rap2rifkey="%binPath%\rap2rifkey.exe"
set sfk="%binPath%\sfk.exe"
set sfo_extractor="%binPath%\sfo_extractor.exe"
set sfoprint="%binPath%\sfoprint.exe"
set wget="%binPath%\wget.exe"
set xml="%binPath%\xml.exe"

set unlockC00="%binPath%\unlock_c00.pkg"

set kdw_license_gen="%binPath%\kdw-licdat\kdw_license_gen.exe"
:: -------------------------------------------------------------
:: DONE SETTING MAIN VARIABLES
:: -------------------------------------------------------------

:: Pre-Clean Temp Files
if exist "temp\TEMP_*.txt" del /f /q "temp\PARAM_*.txt"
if exist "temp\TEMP_*.txt" del /f /q "temp\TEMP_*.txt"

:: Loading Text
echo Preparing PS3 CFW to OFW Game and App Converter....

:: Wait a second
set waitTime=2
%wait%>nul


:: Set Default PS3_GAME Directory
set PS3_GAME=%root%\PS3_GAME
set PS3_GAME_CHOICE=1

:: Skip Custom PS3_GAME Choice Until Fixed (20170608)
goto start

cls
echo Enter Location For PS3_GAME Directory and press ENTER:
echo.
echo.
echo.
echo 1) Default
echo.
echo 2) Custom
echo.
echo.
echo.
echo.
echo Just press ENTER to use defaults....
echo.
echo.

set /p PS3_GAME_CHOICE=

if %PS3_GAME_CHOICE% gtr 2 goto reset

if %PS3_GAME_CHOICE%==1 set PS3_GAME=%root%\PS3_GAME
if %PS3_GAME_CHOICE%==2 goto customDir

goto start


:customDir

cls
echo Drag or type your PS3_GAME Folder Into This Window and Press ENTER:
echo.
echo.

set /p PS3_GAME=

goto start



:start

:: Dump PARAM.SFO Info
%sfoprint% %PS3_GAME%\PARAM.SFO TITLE>"%root%\temp\PARAM_SFO_TITLE.txt"
%sfoprint% %PS3_GAME%\PARAM.SFO TITLE_ID>"%root%\temp\PARAM_SFO_TITLE_ID.txt"
%sfoprint% %PS3_GAME%\PARAM.SFO VERSION>"%root%\temp\PARAM_SFO_VERSION.txt"
%sfoprint% %PS3_GAME%\PARAM.SFO APP_VER>"%root%\temp\PARAM_SFO_APP_VER.txt"


:: Loading Text
cls
echo Loading PS3 CFW to OFW Game and App Converter....
echo.
echo.

:: Wait a second
set waitTime=2
%wait%>nul

:: Check for game existance
if not exist "%PS3_GAME%" set failType=1&&goto fail
if not exist "%root%\PS3_GAME\PARAM.SFO" set failType=2&&goto fail
::if not exist "%root%\PS3_GAME\LICDIR\LIC.DAT" set failType=3&&goto fail

:: Clear Screen After Dumping Info
cls


:: Title
for /f "delims=: tokens=2" %%a in ('type temp\PARAM_SFO_TITLE.txt') do (
	echo %%a>"%root%\temp\TEMP_PARAM_SFO_TITLE.txt"
)
set /p paramDumpTitle=<"%root%\temp\TEMP_PARAM_SFO_TITLE.txt"

:: Title ID
for /f "delims=: tokens=2" %%a in ('type temp\PARAM_SFO_TITLE_ID.txt') do (
	echo %%a>"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"
)
set /p paramDumpTitleID=<"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"

:: Version
for /f "delims=: tokens=2" %%a in ('type temp\PARAM_SFO_VERSION.txt') do (
	echo %%a>"%root%\temp\TEMP_PARAM_SFO_VERSION.txt"
)
set /p paramDumpVersionApp=<"%root%\temp\TEMP_PARAM_SFO_VERSION.txt"

:: App Version
for /f "delims=: tokens=2" %%a in ('type temp\PARAM_SFO_APP_VER.txt') do (
	echo %%a>"%root%\temp\TEMP_PARAM_SFO_APP_VER.txt"
)
set /p paramDumpVersion=<"%root%\temp\TEMP_PARAM_SFO_APP_VER.txt"


setlocal enabledelayedexpansion

set paramDumpTitle=!paramDumpTitle:~1,64!
set paramDumpTitleID=!paramDumpTitleID:~1,64!
set paramDumpVersion=!paramDumpVersion:~1,64!
set paramDumpVersionApp=!paramDumpVersionApp:~1,64!

echo !paramDumpTitle!>"%root%\temp\TEMP_PARAM_SFO_TITLE.txt"
echo !paramDumpTitleID!>"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"
echo !paramDumpVersion!>"%root%\temp\TEMP_PARAM_SFO_VERSION.txt"
echo !paramDumpVersionApp!>"%root%\temp\TEMP_PARAM_SFO_APP_VER.txt"


:: Get first 4 characters of TITLE_ID
set /p titleIDLetterCodeTemp=<"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"
set titleIDLetterCodeTemp=!titleIDLetterCodeTemp:~0,-5!
echo !titleIDLetterCodeTemp!>"%root%\temp\TEMP_CONVERT_TITLE_LETTERCODE.txt"

:: Get last 5 digits of TITLE_ID
set /p titleIDNumberCodeTemp=<"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"
set titleIDNumberCodeTemp=!titleIDNumberCodeTemp:~4,9!
echo !titleIDNumberCodeTemp!>"%root%\temp\TEMP_CONVERT_TITLE_NUMBERCODE.txt"

endlocal


set /p paramDumpTitle=<"%root%\temp\TEMP_PARAM_SFO_TITLE.txt"
set /p paramDumpTitleID=<"%root%\temp\TEMP_PARAM_SFO_TITLE_ID.txt"
set /p paramDumpVersion=<"%root%\temp\TEMP_PARAM_SFO_VERSION.txt"
set /p paramDumpVersionApp=<"%root%\temp\TEMP_PARAM_SFO_APP_VER.txt"


:: Get conversion TITLE_ID
for /f "tokens=*" %%a in ('type temp\TEMP_PARAM_SFO_TITLE_ID.txt') do (
	echo %%a>"%root%\temp\TEMP_CONVERT_TITLE_ID.txt"
)

set /p titleIDLetterCodeTemp=<"%root%\temp\TEMP_CONVERT_TITLE_LETTERCODE.txt"
set /p titleIDNumberCodeTemp=<"%root%\temp\TEMP_CONVERT_TITLE_NUMBERCODE.txt"

:: Set new converted TITLE_ID
if %titleIDLetterCodeTemp%==BLJS set titleIDLetterCode=NPJB
if %titleIDLetterCodeTemp%==BLJM set titleIDLetterCode=NPJB
if %titleIDLetterCodeTemp%==BCJS set titleIDLetterCode=NPJA
if %titleIDLetterCodeTemp%==BLUS set titleIDLetterCode=NPUB
if %titleIDLetterCodeTemp%==BCUS set titleIDLetterCode=NPUA
if %titleIDLetterCodeTemp%==BLES set titleIDLetterCode=NPEB
if %titleIDLetterCodeTemp%==BCES set titleIDLetterCode=NPEA
if %titleIDLetterCodeTemp%==BLAS set titleIDLetterCode=NPHB
if %titleIDLetterCodeTemp%==BCAS set titleIDLetterCode=NPHA
if %titleIDLetterCodeTemp%==BLKS set titleIDLetterCode=NPKB
if %titleIDLetterCodeTemp%==BCKS set titleIDLetterCode=NPKA

set titleIDNumberCode=%titleIDNumberCodeTemp%
set convertedTitleID=%titleIDLetterCode%%titleIDNumberCode%


:checkUpd
:: Set update URL Once PARAM.SFO has been parsed
set serverUpdateXML=%prefixURL%a0.ww.np.dl.playstation.net/tpl/np/%paramDumpTitleID%/%paramDumpTitleID%-ver.xml

set userAgent=--user-agent="Mozilla/5.0 (PLAYSTATION 3; 4.81)"
::set header=--header="Accept: text/html"

set disableCertCheck=--no-check-certificate



cls
echo Checking For Updates....
echo.
echo.

:: Download Update XML
%wget% %disableCertCheck% %userAgent% -O "%root%\temp\%paramDumpTitleID%.xml" %serverUpdateXML%


:: Check for blank XML
for %%a in ("temp\%paramDumpTitleID%.xml") do (
  if %%~za equ 0 (
	set isBlankXML=1
  ) else (
	set isBlankXML=0
  )
)


:: If XML is blank, skip parsing XML file
if %isBlankXML%==1 goto skipUpd


:: XML Functions

:: Sample Structure
::titlepatch
::titlepatch/@status
::titlepatch/@titleid
::titlepatch/tag
::titlepatch/tag/@name
::titlepatch/tag/@popup
::titlepatch/tag/@signoff
::titlepatch/tag/package
::titlepatch/tag/package/@version
::titlepatch/tag/package/@size
::titlepatch/tag/package/@sha1sum
::titlepatch/tag/package/@url
::titlepatch/tag/package/@ps3_system_ver
::titlepatch/tag/package
::titlepatch/tag/package/paramsfo
::titlepatch/tag/package/paramsfo/TITLE

:: XML Functions
set xmlShowStructureShort=%xml% el "temp\%paramDumpTitleID%.xml"
set xmlShowStructureLong=%xml% el -a "temp\%paramDumpTitleID%.xml"
set xmlShowStructureDebug=%xml% el -v "temp\%paramDumpTitleID%.xml"
set xmlCountElements=%xml% sel -t -v "count(/titlepatch/tag/package)" "temp\%paramDumpTitleID%.xml"

:: Debug Display XML Structure
::%xmlShowStructureShort%
%xmlShowStructureLong%
::%xmlShowStructureDebug%

:: Update Package XML Values
set xmlTitleID=%xml% sel -t -m "/titlepatch" -v @titleid "temp\%paramDumpTitleID%.xml"
set xmlName=%xml% sel -t -m "/titlepatch/tag/package/paramsfo" -v TITLE "temp\%paramDumpTitleID%.xml"
set xmlVersion=%xml% sel -t -m "/titlepatch/tag/package" -v @version "temp\%paramDumpTitleID%.xml"
set xmlSize=%xml% sel -t -m "/titlepatch/tag/package" -v @size "temp\%paramDumpTitleID%.xml"
set xmlURL=%xml% sel -t -m "/titlepatch/tag/package" -v @url "temp\%paramDumpTitleID%.xml"

:: Dump Values To Temp Files
%xmlCountElements%>"%root%\temp\TEMP_xml_number_of_elements.txt"
%xmlTitleID%>"%root%\temp\TEMP_xml_title_id.txt"
%xmlName%>"%root%\temp\TEMP_xml_name.txt"
%xmlVersion%>"%root%\temp\TEMP_xml_version.txt"
%xmlSize%>"%root%\temp\TEMP_xml_size.txt"
%xmlURL%>"%root%\temp\TEMP_xml_url.txt"

:: Set number of available updates from parsed XML values
set /p updatesAvailable=<"%root%\temp\TEMP_xml_number_of_elements.txt"

:: Check for multiple updates
if %updatesAvailable% gtr 1 set multipleUpdates=1

:: Set new variables from parsed XML values
set /p updatesTitleID=<"%root%\temp\TEMP_xml_title_id.txt"
set /p updatesName=<"%root%\temp\TEMP_xml_name.txt"
set /p updatesVersion=<"%root%\temp\TEMP_xml_version.txt"
set /p updatesSize=<"%root%\temp\TEMP_xml_size.txt"
set /p updatesURL=<"%root%\temp\TEMP_xml_url.txt"

:: Debug Output Testing
::echo.
::echo.
::echo Name: %updatesName%
::echo Title ID: %updatesTitleID%
::echo.
::echo Multiple Update Flag: %multipleUpdates%
::echo.
::echo Number of Updates Available: %updatesAvailable%
::echo Update Version: %updatesVersion%
::echo Update Size: %updatesSize%
::echo Update URL: %updatesURL%
::pause


::set updatesMax=%updatesAvailable%
::set updatesCurrent=%updatesMax%
::set /a charsTotal=5*%updatesMax%
::set /a charsForLast=%charsTotal%-5

::set updatesVersionFirst=%updatesVersion:~0,5%
::set updatesVersionLast=%updatesVersion:~25,5%
	
::echo charsTotal: %charsTotal%
::echo updatesVersionFirst: %updatesVersionFirst%
::echo updatesVersionLast: %updatesVersionLast%
::pause



:: Skipping XML update parsing
:skipUpd


:: Dump Update XML Info
for /f "delims=: tokens=2" %%a in ('type temp\%paramDumpTitleID%.xml') do (
	echo %%a>"%root%\temp\TEMP_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=1" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_1_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=2" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_2_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=3" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_3_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=4" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_4_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=5" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_5_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=6" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_6_%paramDumpTitleID%.txt"
)

for /f "delims=/ tokens=7" %%a in ('type temp\TEMP_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_7_%paramDumpTitleID%.txt"
)

for /f "delims=. tokens=1" %%a in ('type temp\TEMP_URL_7_%paramDumpTitleID%.txt') do (
	echo %%a>"%root%\temp\TEMP_URL_7_%paramDumpTitleID%.txt"
)


set /p urlTemp1=<"%root%\temp\TEMP_URL_1_%paramDumpTitleID%.txt"
set /p urlTemp2=<"%root%\temp\TEMP_URL_2_%paramDumpTitleID%.txt"
set /p urlTemp3=<"%root%\temp\TEMP_URL_3_%paramDumpTitleID%.txt"
set /p urlTemp4=<"%root%\temp\TEMP_URL_4_%paramDumpTitleID%.txt"
set /p urlTemp5=<"%root%\temp\TEMP_URL_5_%paramDumpTitleID%.txt"
set /p urlTemp6=<"%root%\temp\TEMP_URL_6_%paramDumpTitleID%.txt"
set /p urlTemp7=<"%root%\temp\TEMP_URL_7_%paramDumpTitleID%.txt"


if %isBlankXML%==1 set updateLink=%prefixURL%%urlTemp1%/%urlTemp2%/%urlTemp3%/%urlTemp4%/%urlTemp5%/%urlTemp6%/%urlTemp7%.pkg
if %isBlankXML%==0 set updateLink=%updatesURL%


:: Set Update Package Status
::if not defined urlTemp7 set updatePackageAvailable=0
if %isBlankXML%==1 set updatePackageAvailable=0



:: Fix Title After WGET Operation
title PS3 CFW to OFW Game and App Converter v%scriptVersion%                      esc0rtd3w 2017


:: Main Menu

:getID

:: Set gameID to suggested conversion name by default
set gameID=%convertedTitleID%

cls
echo -------------------------------------------------------------------------------
%cocolor% 0b
echo Detected Game: [%paramDumpTitle%] [%paramDumpTitleID%] [%paramDumpVersion%] [%paramDumpVersionApp%]
echo.
if %updatePackageAvailable%==1 %cocolor% 0a
if %updatePackageAvailable%==1 echo Update Package: [%urlTemp7%]
if %updatePackageAvailable%==0 %cocolor% 0c
if %updatePackageAvailable%==0 echo Update Package: [UPDATE NOT AVAILABLE]
%cocolor% 0e
echo -------------------------------------------------------------------------------
echo.
echo Disc                         HDD
echo.
echo BLJS12345/BLJM12345          NPJB12345
echo BCJS12345                    NPJA12345
echo BLUS12345                    NPUB12345
echo BCUS12345                    NPUA12345
echo BLES12345                    NPEB12345
echo BCES12345                    NPEA12345
echo BLAS12345                    NPHB12345
echo BCAS12345                    NPHA12345
echo BLKS12345                    NPKB12345
echo BCKS12345                    NPKA12345
echo.
echo Enter Game ID and press ENTER or just press ENTER to use defaults:
echo.
echo Suggested Conversion Name: [%convertedTitleID%]
echo.

set /p gameID=


:: Create the structure of directories and subdirectories of our game
mkdir "%gameID%"
mkdir "%gameID%\LICDIR"

if %askUpdate%==1 goto getPKG

goto notConvert


:getPKG
:: Download Updates
cls

echo -------------------------------------------------------------------------------
%cocolor% 0b
echo Detected Game: [%paramDumpTitle%] [%paramDumpTitleID%] [%paramDumpVersion%] [%paramDumpVersionApp%]
echo.
if %updatePackageAvailable%==1 %cocolor% 0a
if %updatePackageAvailable%==1 echo Update Package: [%urlTemp7%]
if %updatePackageAvailable%==0 %cocolor% 0c
if %updatePackageAvailable%==0 echo Update Package: [UPDATE NOT AVAILABLE]
%cocolor% 0e
echo -------------------------------------------------------------------------------
echo.
echo.
echo Would you like to download all available updates?
echo.
echo.
echo Default is YES
echo.
echo.
echo.
echo 1) Yes
echo.
echo 2) No
echo.
echo.
echo.
echo Make a selection and press ENTER....
echo.
echo.

set /p doUpdate=

if not exist "%root%\temp\update" mkdir "%root%\temp\update"
if %doUpdate%==1 %wget% %disableCertCheck% %userAgent% -O "%root%\temp\update\%urlTemp7%.pkg" %updateLink%

goto notConvert



:notConvert
set filetypes=1

cls
echo -------------------------------------------------------------------------------
%cocolor% 0b
echo Detected Game: [%paramDumpTitle%] [%paramDumpTitleID%] [%paramDumpVersion%] [%paramDumpVersionApp%]
echo.
if %updatePackageAvailable%==1 %cocolor% 0a
if %updatePackageAvailable%==1 echo Update Package: [%urlTemp7%]
if %updatePackageAvailable%==0 %cocolor% 0c
if %updatePackageAvailable%==0 echo Update Package: [UPDATE NOT AVAILABLE]
%cocolor% 0e
echo -------------------------------------------------------------------------------
echo.
echo.
echo Choose Filetypes NOT To Convert and press ENTER:
echo.
echo Default is 1
echo.
echo.
echo.
echo 0) NOTHING (Convert All Files)
echo.
echo 1) SDAT
echo.
echo 2) SDAT/EDAT
echo.
echo 3) SDAT/EDAT/SPRX
echo.
echo 4) SDAT/EDAT/SPRX/SELF
echo.
echo.

set /p filetypes=

if %filetypes% gtr 4 goto notConvert


:: Check for a LIC.DAT file
if not exist "%PS3_GAME%\LICDIR\LIC.DAT" set licenseStatus=0

:: Copy TROPHY and GAME files
xcopy "%PS3_GAME%\TROPDIR" "%gameID%\TROPDIR" /s /i
xcopy "%PS3_GAME%\*.*" "%gameID%\*.*"

if %filetypes%==1 xcopy "%PS3_GAME%\USRDIR\*.sdat" "%gameID%\USRDIR\*.sdat" /e

if %filetypes%==2 xcopy "%PS3_GAME%\USRDIR\*.sdat" "%gameID%\USRDIR\*.sdat" /e
if %filetypes%==2 xcopy "%PS3_GAME%\USRDIR\*.edat" "%gameID%\USRDIR\*.edat" /e

if %filetypes%==3 xcopy "%PS3_GAME%\USRDIR\*.sdat" "%gameID%\USRDIR\*.sdat" /e
if %filetypes%==3 xcopy "%PS3_GAME%\USRDIR\*.edat" "%gameID%\USRDIR\*.edat" /e
if %filetypes%==3 xcopy "%PS3_GAME%\USRDIR\*.sprx" "%gameID%\USRDIR\*.sprx" /e

if %filetypes%==4 xcopy "%PS3_GAME%\USRDIR\*.sdat" "%gameID%\USRDIR\*.sdat" /e
if %filetypes%==4 xcopy "%PS3_GAME%\USRDIR\*.edat" "%gameID%\USRDIR\*.edat" /e
if %filetypes%==4 xcopy "%PS3_GAME%\USRDIR\*.sprx" "%gameID%\USRDIR\*.sprx" /e
if %filetypes%==4 xcopy "%PS3_GAME%\USRDIR\*.self" "%gameID%\USRDIR\*.self" /e


:: Create a list of files and directories of the USRDIR folder. It is necessary for make_npdata
dir /b /s /a:-d "%PS3_GAME%\USRDIR\">list.txt

if %filetypes%==0 type list.txt | findstr /i /v "EBOOT.BIN" > temp.txt
if %filetypes%==1 type list.txt | findstr /i /v ".sdat EBOOT.BIN" > temp.txt
if %filetypes%==2 type list.txt | findstr /i /v ".sdat .edat EBOOT.BIN" > temp.txt
if %filetypes%==3 type list.txt | findstr /i /v ".sdat .edat .sprx EBOOT.BIN" > temp.txt
if %filetypes%==4 type list.txt | findstr /i /v ".sdat .edat .sprx .self EBOOT.BIN" > temp.txt

del list.txt
rename temp.txt list.txt


:: Convert game files
setlocal enabledelayedexpansion

set infile=list.txt
set find=%PS3_GAME%\
set replace=


for /F "tokens=*" %%n in (!infile!) do (
set LINE=%%n
set TMPR=!LINE:%find%=%replace%!
echo !TMPR!>>TMP.TXT
)
move TMP.TXT %infile%

@echo on
for /f "tokens=*" %%B in (!infile!) do make_npdata -e "%PS3_GAME%\%%~B" "%gameID%\%%~B" 0 1 3 0 16
@echo off

endlocal


:: Create EDAT
@echo off

goto makeLIC


:makeLIC
if %licenseStatus%==0 (
copy /y "%PS3_GAME%\PARAM.SFO" "%binPath%\kdw-licdat\GAMES\CREATE_NEW_LICENSE\PS3_GAME\PARAM.SFO"

color 0c

echo.
echo.
echo No License Found!
echo.
echo.
echo When the KDW app opens, press C then 1 and ENTER to create a new LIC.DAT
echo.
echo.

start "" %kdw_license_gen%

echo.
echo.
echo.
echo Press ENTER when license has been created....
echo.
echo.
echo.
echo.
pause>nul

copy /y "%binPath%\kdw-licdat\GAMES\CREATE_NEW_LICENSE\PS3_GAME\LICDIR\LIC.DAT" "%PS3_GAME%\LICDIR\LIC.DAT"

set licenseStatus=1

)


if %licenseStatus%==1 (

color 0e

echo.
echo.
echo Creating New License....
echo.
echo.

make_npdata -e "%PS3_GAME%\LICDIR\LIC.DAT" "%gameID%\LICDIR\LIC.EDAT" 1 1 3 0 16 3 00 EP9000-%gameID%_00-0000000000000001 1
)


:dumpTXT
:: Create text file for info
echo.>"%root%\%gameID%\USRDIR\EP9000-%gameID%_00-0000000000000001.txt"


:doClean
:: Cleaning Temp Files
if exist %infile% del /q /f %infile%
if exist "list.txt" del /f /q "list.txt"

if exist "temp\PARAM_SFO_TITLE.txt" del /f /q "temp\PARAM_SFO_TITLE.txt"
if exist "temp\TEMP_PARAM_SFO_TITLE.txt" del /f /q "temp\TEMP_PARAM_SFO_TITLE.txt"
if exist "temp\PARAM_SFO_TITLE_ID.txt" del /f /q "temp\PARAM_SFO_TITLE_ID.txt"
if exist "temp\TEMP_PARAM_SFO_TITLE_ID.txt" del /f /q "temp\TEMP_PARAM_SFO_TITLE_ID.txt"
if exist "temp\PARAM_SFO_VERSION.txt" del /f /q "temp\PARAM_SFO_VERSION.txt"
if exist "temp\TEMP_PARAM_SFO_VERSION.txt" del /f /q "temp\TEMP_PARAM_SFO_VERSION.txt"
if exist "temp\PARAM_SFO_TARGET_APP_VER.txt" del /f /q "temp\PARAM_SFO_TARGET_APP_VER.txt"
if exist "temp\TEMP_PARAM_SFO_TARGET_APP_VER.txt" del /f /q "temp\TEMP_PARAM_SFO_TARGET_APP_VER.txt"
if exist "temp\PARAM_SFO_APP_VER.txt" del /f /q "temp\PARAM_SFO_APP_VER.txt"
if exist "temp\TEMP_PARAM_SFO_APP_VER.txt" del /f /q "temp\TEMP_PARAM_SFO_APP_VER.txt"
if exist "temp\TEMP_CONVERT_TITLE_LETTERCODE.txt" del /f /q "temp\TEMP_CONVERT_TITLE_LETTERCODE.txt"
if exist "temp\TEMP_CONVERT_TITLE_NUMBERCODE.txt" del /f /q "temp\TEMP_CONVERT_TITLE_NUMBERCODE.txt"
if exist "temp\TEMP_CONVERT_TITLE_ID.txt" del /f /q "temp\TEMP_CONVERT_TITLE_ID.txt"

if exist "temp\TEMP_*.txt" del /f /q "temp\PARAM_*.txt"
if exist "temp\TEMP_*.txt" del /f /q "temp\TEMP_*.txt"
if exist "temp\%paramDumpTitleID%.txt" del /f /q "temp\%paramDumpTitleID%.txt"


:: Finished
:done
color 0a
echo.
echo.
echo ===============================================================================
echo                                    END 
echo ===============================================================================

pause

goto end


:fail
color 0c
cls
if %failType%==1 echo The PS3_GAME Directory Is Missing!
if %failType%==2 echo The PS3_GAME\PARAM.SFO Is Missing!
::if %failType%==3 echo The PS3_GAME\LICDIR\LIC.DAT Is Missing!
echo.
if %failType%==1 echo Please Copy From Disc To %root%
if %failType%==2 echo Please Copy PS3_GAME Directory From Disc To %root%
::if %failType%==3 echo Please Create License and Copy To %root%\LICDIR\
::if %failType%==3 goto makeLIC
echo.
echo.
echo.
echo.
echo Once this is done, press ENTER to continue....
echo.
echo.

pause>nul

goto reset



:end


