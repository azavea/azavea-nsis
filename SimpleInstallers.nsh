;c-style prevention of duplicate imports.
!IFNDEF SIMPLE_INSTALLERS_IMPORT
!DEFINE SIMPLE_INSTALLERS_IMPORT "yup"

; This contains macros that give you an entire basic installer.

;------------------------------------------------------------------------------
; The first half of what you need to install an executable and its associated stuff.
; Uses all the default pages, locations, etc.  Requires "${APP_NAME}" to be defined
; as a name for the app with no spaces.
;
; USAGE: Call the series of SimpleInstall macros as follows:
;
;   !INCLUDE "SimplerInstallers.nsh"
;
;   ${BeginSimpleInstall} "Test Thing To Install" "TestThing" "Avencia;Avencia_Test"
;     <some other pages>
;   ${SimpleInstall_PagesToInit}
;     File ..\config\templates\TestThing.config
;     File ..\config\templates\TestThing_App.config
;   ${SimpleInstall_InitToConfig}
;     StrCpy $SOME_VAR "something"
;   ${SimpleInstall_ConfigToTokens}
;     ${WriteToken}
;   ${SimpleInstall_TokensToSections} ""
;   ${NormalApplication} "..\csharp\TestThing\bin\Release" "TestThing_App.config" "TestThing.exe.config"
;   Section "Some Other Section"
;     ...
;   SectionEnd
;
;   ${AvStandardUninstaller}
;
; NICE_NAME - The pretty name to display to the user.
; DEFAULT_MERGE_OPTIONS - The semicolon-separated list of merge file names
;                         for the user to choose between, I.E. "Avencia;DOT;DOT_Test"
!MACRO SimpleInstall_ToPages NICE_NAME DEFAULT_MERGE_OPTIONS
  !INSERTMACRO SimpleInstall_ToPages_WithDetails "${NICE_NAME}" "${DEFAULT_MERGE_OPTIONS}" 0 1 "" "C:\projects\${APP_NAME}"
!MACROEND

;------------------------------------------------------------------------------
; This version takes additional details if you feel like specifying them.
; MAJOR_VER - Major version, I.E. the "2" in "2.0"
; MINOR_VER - Minor version, I.E. the "0" in "2.0"
; ON_MERGE_SELECTION - The function to call after the user chooses a merge file.
;                      May be "".
; DEFAULT_INST_DIR - What dir to default to install to.
!MACRO SimpleInstall_ToPages_WithDetails NICE_NAME DEFAULT_MERGE_OPTIONS MAJOR_VER MINOR_VER ON_MERGE_SELECTION DEFAULT_INST_DIR
  Name "${NICE_NAME}"
  OutFile "${APP_NAME}Setup.exe"
  InstallDir "${DEFAULT_INST_DIR}"

  !DEFINE APP_MAJOR_VERSION "${MAJOR_VER}"
  !DEFINE APP_MINOR_VERSION "${MINOR_VER}"

  !INCLUDE "AvenciaUtils.nsh"
  !INCLUDE "ConfigUtils.nsh"
  !INCLUDE "StandardQuestions.nsh"
  !INCLUDE "MUI.nsh"

  !INSERTMACRO MUI_PAGE_WELCOME
  ; Ask the user to choose an install directory.
  !INSERTMACRO MUI_PAGE_DIRECTORY
  ; Ask where we're installing.
  !INSERTMACRO DefaultMergeSelectionPage "${DEFAULT_MERGE_OPTIONS}" "${ON_MERGE_SELECTION}"
!MACROEND

;------------------------------------------------------------------------------
; The next macro in the "SimpleInstall" series.
; See the description of BeginSimpleInstall for example usage.
!MACRO SimpleInstall_PagesToInit
  ; Page to show while installing the files.
  !INSERTMACRO MUI_PAGE_INSTFILES

  ; On uninstall, show the progress.
  !INSERTMACRO MUI_UNPAGE_CONFIRM
  !INSERTMACRO MUI_UNPAGE_INSTFILES

  ; Tell MUI the language.
  !INSERTMACRO MUI_LANGUAGE "English"

  ; Declare the standard variables (APPLICATION_DIR, CONFIG_DIR, LOG_DIR, TEMPLATES_DIR)
  !INSERTMACRO AvStandardSubdirVariables

  Function .onInit
    Call StartupChecks
    !INSERTMACRO AvStandardQuestionsOnInit
!MACROEND

;------------------------------------------------------------------------------
; The next macro in the "SimpleInstall" series.
; See the description of BeginSimpleInstall for example usage.
!MACRO SimpleInstall_InitToConfig
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
; The next macro in the "SimpleInstall" series.
; See the description of BeginSimpleInstall for example usage.
!MACRO SimpleInstall_ConfigToTokens
    ;merge files
    !DEFINE MERGE_DIR "$CONFIG_DIR\merge"
    ; Create the dir.
    SetOutPath "${MERGE_DIR}"
    ; Include the defaults.
    File "defaults\*.mer"

    ; Substitute values in the config file.
    !INSERTMACRO OpenMergeFile "${MERGE_DIR}\install.mer" $0

    !INSERTMACRO AvLog "Using log directory: $LOG_DIR"
    !INSERTMACRO WriteToken $0 "logdir" "$LOG_DIR"
    !INSERTMACRO WriteToken $0 "log_dir" "$LOG_DIR"

    !INSERTMACRO AvLog "Using config directory: $CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "configdir" "$CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "config_dir" "$CONFIG_DIR"

    !INSERTMACRO AvLog "Using bin directory: $APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exedir" "$APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exe_dir" "$APPLICATION_DIR"
!MACROEND

;------------------------------------------------------------------------------
; If you need to pick up additional merge files from somewhere else,
; use this macro followed by SimpleInstall_MergesToTokens INSTEAD OF
; SimpleInstall_ConfigToTokens.
!MACRO SimpleInstall_ConfigToMerges
    ;merge files
    !DEFINE MERGE_DIR "$CONFIG_DIR\merge"
    ; Create the dir.
    SetOutPath "${MERGE_DIR}"
    ; Include the defaults.
    File "defaults\*.mer"
!MACROEND

;------------------------------------------------------------------------------
; If you need to pick up additional merge files from somewhere else,
; use SimpleInstall_ConfigToMerges followed by this macro INSTEAD OF
; SimpleInstall_ConfigToTokens.
!MACRO SimpleInstall_MergesToTokens
    ; Substitute values in the config file.
    !INSERTMACRO OpenMergeFile "${MERGE_DIR}\install.mer" $0

    !INSERTMACRO AvLog "Build number: ${BUILD_NUMBER}"
    !INSERTMACRO WriteToken $0 "BuildNumber" "${BUILD_NUMBER}"

    !INSERTMACRO AvLog "Using log directory: $LOG_DIR"
    !INSERTMACRO WriteToken $0 "logdir" "$LOG_DIR"
    !INSERTMACRO WriteToken $0 "log_dir" "$LOG_DIR"

    !INSERTMACRO AvLog "Using config directory: $CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "configdir" "$CONFIG_DIR"
    !INSERTMACRO WriteToken $0 "config_dir" "$CONFIG_DIR"

    !INSERTMACRO AvLog "Using bin directory: $APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exedir" "$APPLICATION_DIR"
    !INSERTMACRO WriteToken $0 "exe_dir" "$APPLICATION_DIR"
!MACROEND

;------------------------------------------------------------------------------
; The next macro in the "SimpleInstall" series.
; See the description of BeginSimpleInstall for example usage.
;
; FIRST_MERGE_FILE - A merge file to use before all others.  May be "" if none.
; LAST_MERGE_FILE - A merge file to use after all others (except the installer file).  May be "" if none.
;                   The merge file written by the installer always trumps all other merge files.
!MACRO SimpleInstall_TokensToSections FIRST_MERGE_FILE LAST_MERGE_FILE
    !INSERTMACRO CloseMergeFile $0

    StrCpy $1 ""
    !INSERTMACRO AppendMergeFile $1 "${FIRST_MERGE_FILE}"
    !INSERTMACRO AppendDefaultSelectedMergeFileName $1
    !INSERTMACRO AppendMergeFile $1 "${LAST_MERGE_FILE}"
    !INSERTMACRO AppendMergeFile $1 "${MERGE_DIR}\install.mer"

    ; Run the Merginator
    !INSERTMACRO Merginate "$CONFIG_DIR\installed.mer" "$1" "$TEMPLATES_DIR" "$CONFIG_DIR"

    ; Let everyone read config files, since the windows service user will need to read them.
    !INSERTMACRO SetPermissions "$CONFIG_DIR" "Everyone" "R"
  SectionEnd
!MACROEND

;------------------------------------------------------------------------------
; Finished up the exe installer.
; See the description of BeginInstallExe for example usage.
;
; SOURCE_DIR - The path to the dlls/exes/etc where we're getting them from.
; APP_CONFIG_IS - The current name of the app config file in the templates dir (Blah_app.config)
; APP_CONFIG_SHOULD_BE - What it should be named (Blah.exe.config)
!MACRO NormalApplication SOURCE_DIR APP_CONFIG_IS APP_CONFIG_SHOULD_BE
  Section "Application"
    SetOutPath $APPLICATION_DIR
    File ${SOURCE_DIR}\*.exe
    File ${SOURCE_DIR}\*.dll

    ; Move over the app config.
    !INSERTMACRO AvLog "Renaming $CONFIG_DIR\${APP_CONFIG_IS} to $APPLICATION_DIR\${APP_CONFIG_SHOULD_BE}"
    Rename "$CONFIG_DIR\${APP_CONFIG_IS}" "$APPLICATION_DIR\${APP_CONFIG_SHOULD_BE}"
  SectionEnd
!MACROEND

!ENDIF ;SIMPLE_INSTALLERS_IMPORT

