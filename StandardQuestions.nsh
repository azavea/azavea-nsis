;c-style prevention of duplicate imports.
!IFNDEF STANDARD_QUESTIONS_IMPORT
!DEFINE STANDARD_QUESTIONS_IMPORT "yup"

; This contains some helpers to prompt the user for the locations of the application,
; config, and log files.  The location of the templates dir is not prompted since it
; is typically a subdirectory of the config file directory.

; Uses the custom page stuff.
!INCLUDE "CustomPageUtils.nsh"

;------------------------------------------------------------------------------
; You can override the default locations by defining these prior to importing this
; nsh file.
!IFNDEF DEFAULT_APP_DIR
  !DEFINE DEFAULT_APP_DIR "$INSTDIR\csharp\${APP_NAME}"
!ENDIF
!IFNDEF DEFAULT_CONF_DIR
  !DEFINE DEFAULT_CONF_DIR "$INSTDIR\config"
!ENDIF
!IFNDEF DEFAULT_LOG_DIR
  !DEFINE DEFAULT_LOG_DIR "$INSTDIR\log"
!ENDIF
!IFNDEF DEFAULT_TEMPLATES_DIR
  !DEFINE DEFAULT_TEMPLATES_DIR "$CONFIG_DIR\templates"
!ENDIF

;------------------------------------------------------------------------------
; Inserts the "standard questions" page.  This page prompts for an application
; (csharp) dir, a config dir, and a log dir.  This also defines the following
; variables: APPLICATION_DIR, CONFIG_DIR, LOG_DIR, and TEMPLATES_DIR.
!MACRO AvStandardQuestionsPage
  !INSERTMACRO CreateEasyCustomDirPathVar "APPLICATION_DIR"
  !INSERTMACRO CreateEasyCustomDirPathVar "CONFIG_DIR"
  !INSERTMACRO CreateEasyCustomDirPathVar "LOG_DIR"
  Var TEMPLATES_DIR

  !INSERTMACRO EasyCustomPageBegin "StandardQuestions" "Additional File Paths" "Please choose locations for these files."
    !INSERTMACRO EasyCustomFilePath "APPLICATION_DIR" "Application file location:"
    !INSERTMACRO EasyCustomFilePath "CONFIG_DIR" "Config file location:"
    !INSERTMACRO EasyCustomFilePath "LOG_DIR" "Log file location:"
  !INSERTMACRO EasyCustomPageEnd
!MACROEND
;------------------------------------------------------------------------------
; Call this macro from .onVerifyInstDir if you are using the standard questions.
!MACRO AvStandardQuestionsOnVerify
  StrCpy $APPLICATION_DIR "${DEFAULT_APP_DIR}"
  StrCpy $CONFIG_DIR "${DEFAULT_CONF_DIR}"
  StrCpy $LOG_DIR "${DEFAULT_LOG_DIR}"
  StrCpy $TEMPLATES_DIR "${DEFAULT_TEMPLATES_DIR}"
!MACROEND

;--------------------------------------------------------------------------------------
; Prompts the user for the machine name.
;
; ON_CHOOSE_FUNC - The function to call after the user selects the machine name.  May be "".
!MACRO LocalhostNamePage ON_CHOOSE_FUNC
  !INSERTMACRO CreateEasyCustomTextVar "LOCALHOST_NAME" ""
  !INSERTMACRO EasyCustomPageWithPostBegin "LocalhostName" "Computer Name" "Please enter the name (or IP) of the local machine?" "${ON_CHOOSE_FUNC}"
    !INSERTMACRO EasyCustomTextBox "LOCALHOST_NAME" "Name or IP:"
  !INSERTMACRO EasyCustomPageEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Guesses the local host name based on the registry value.
; This should be called from the installer's .onInit function.
!MACRO InitLocalhostName
  ReadRegStr $LOCALHOST_NAME HKLM "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
!MACROEND

!ENDIF ;STANDARD_QUESTIONS_IMPORT
