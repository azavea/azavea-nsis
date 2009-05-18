;c-style prevention of duplicate imports.
!IFNDEF SIMPLE_INSTALLERS_IMPORT
!DEFINE SIMPLE_INSTALLERS_IMPORT "yup"

; This contains macros that give you an entire basic installer.

;------------------------------------------------------------------------------
; The first half of what you need to install an executable and its associated stuff.
; Uses all the default pages, locations, etc.
;
; USAGE: Call this, then list all the config files you need, then call
;        EndInstallExe.  Example:
;
;   BeginInstallExe "Test Thing To Install" "TestThing" "Avencia;Avencia_Test"
;     File ..\config\templates\TestThing.config
;     File ..\config\templates\TestThing_App.config
;   EndInstallExe "..\csharp\TestThing\bin\Release" "TestThing_App.config" "TestThing.exe.config"
;
; NICE_NAME - The pretty name to display to the user.
; SHORT_NAME - The name with no spaces to use for things like the install dir.
; DEFAULT_MERGE_OPTIONS - The semicolon-separated list of merge file names
;                         for the user to choose between, I.E. "Avencia;DOT;DOT_Test"
!MACRO BeginInstallExe NICE_NAME SHORT_NAME DEFAULT_MERGE_OPTIONS
  Name "${NICE_NAME}"
  OutFile "${SHORT_NAME}Setup.exe"
  InstallDir "C:\projects\${SHORT_NAME}"

  !DEFINE APP_NAME "${SHORT_NAME}"
  !DEFINE APP_MAJOR_VERSION "0"
  !DEFINE APP_MINOR_VERSION "1"

  !INCLUDE "AvenciaUtils.nsh"
  !INCLUDE "ConfigUtils.nsh"
  !INCLUDE "StandardQuestions.nsh"
  !INCLUDE "MUI.nsh"

  !INSERTMACRO MUI_PAGE_WELCOME
  ; Ask the user to choose an install directory.
  !INSERTMACRO MUI_PAGE_DIRECTORY
  ; Page to show while installing the files.
  !INSERTMACRO MUI_PAGE_INSTFILES
  ; Ask where we're installing.
  !INSERTMACRO DefaultMergeSelectionPage "${DEFAULT_MERGE_OPTIONS}" ""

  ; On uninstall, show the progress.
  !INSERTMACRO MUI_UNPAGE_CONFIRM
  !INSERTMACRO MUI_UNPAGE_INSTFILES

  ; Tell MUI the language.
  !INSERTMACRO MUI_LANGUAGE "English"

  ; Declare the standard variables (APPLICATION_DIR, CONFIG_DIR, LOG_DIR, TEMPLATES_DIR)
  !INSERTMACRO AvStandardSubdirVariables

  Function .onInit
    Call StartupChecks
  FunctionEnd

  Function .onVerifyInstDir
    !INSERTMACRO AvStandardQuestionsOnVerify
  FunctionEnd

  Section "Install Basics"
    !INSERTMACRO SaveStandardUninstallInfo "avencia16.ico" "externals\Avencia_Common"
  SectionEnd

  !INSERTMACRO StandardLogFileSection $LOG_DIR

  Section "Configuration Files"
    !INSERTMACRO IncludeMerginator "$CONFIG_DIR\Merginator"

    SetOutPath $TEMPLATES_DIR
!MACROEND

;------------------------------------------------------------------------------
; Finished up the exe installer.
; See the description of BeginInstallExe for example usage.
;
; SOURCE_DIR - The path to the dlls/exes/etc where we're getting them from.
; APP_CONFIG_IS - The current name of the app config file in the templates dir (Blah_app.config)
; APP_CONFIG_SHOULD_BE - What it should be named (Blah.exe.config)
!MACRO EndInstallExe SOURCE_DIR APP_CONFIG_IS APP_CONFIG_SHOULD_BE
    ;merge files
    !DEFINE MERGE_DIR "$CONFIG_DIR\merge"
    ; Create the dir.
    SetOutPath "${MERGE_DIR}"
    ; Substitute values in the config file.
    !INSERTMACRO OpenMergeFile "${MERGE_DIR}\installer.mer" $0

    DetailPrint "Using log directory: $LOG_DIR"
    !INSERTMACRO WriteToken $0 "logdir" "$LOG_DIR"
    !INSERTMACRO WriteToken $0 "log_dir" "$LOG_DIR"

    DetailPrint "Using config directory: $CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "configdir" "$CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "config_dir" "$CONFIG_DIR"

    DetailPrint "Using bin directory: $APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exedir" "$APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exe_dir" "$APPLICATION_DIR"

    !INSERTMACRO CloseMergeFile $0

    StrCpy $1 ""
    !INSERTMACRO AppendMergeFile $1 "${MERGE_DIR}\installer.mer"

    ; Run the Merginator
    !INSERTMACRO Merginate "$CONFIG_DIR\installed.mer" "$1" "$TEMPLATES_DIR" "$CONFIG_DIR"

    ; Let everyone read config files, since the windows service user will need to read them.
    !INSERTMACRO SetPermissions "$CONFIG_DIR" "Everyone" "R"
  SectionEnd

  Section "Application"
    SetOutPath $APPLICATION_DIR
    File ${SOURCE_DIR}\*.exe
    File ${SOURCE_DIR}\*.dll

    ; Move over the app config.
    DetailPrint "Renaming $CONFIG_DIR\${APP_CONFIG_IS} to $APPLICATION_DIR\${APP_CONFIG_SHOULD_BE}"
    Rename "$CONFIG_DIR\${APP_CONFIG_IS}" "$APPLICATION_DIR\${APP_CONFIG_SHOULD_BE}"
  SectionEnd

  !INSERTMACRO AvStandardUninstaller
!MACROEND

!ENDIF ;SIMPLE_INSTALLERS_IMPORT

