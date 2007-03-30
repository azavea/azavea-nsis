;c-style prevention of duplicate imports.
!IFNDEF STANDARD_QUESTIONS_IMPORT
!DEFINE STANDARD_QUESTIONS_IMPORT "yup"

; This contains some helpers to prompt the user for the locations of the application,
; config, and log files.  The location of the templates dir is not prompted since it
; is typically a subdirectory of the config file directory.

; Uses the custom page stuff.
!INCLUDE "CustomPageUtils.nsh"

;------------------------------------------------------------------------------
; These variables are fairly typical.  Where does the application (.exe, .dll, etc) go,
; where do the avencia config files go, where do the template config files go (to be
; merged using TokenSwap), and where do log files go.  These are variables so they can
; be set to new values any time $INSTDIR changes.
Var APPLICATION_DIR
Var CONFIG_DIR
Var TEMPLATES_DIR
Var LOG_DIR

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
; Call this macro from .onVerifyInstDir if you are using the standard questions.
!MACRO StandardQuestionsOnVerify
  !INSERTMACRO MUI_INSTALLOPTIONS_WRITE "StandardQuestions.ini" "Field 2" "State" "${DEFAULT_APP_DIR}"
  !INSERTMACRO MUI_INSTALLOPTIONS_WRITE "StandardQuestions.ini" "Field 4" "State" "${DEFAULT_CONF_DIR}"
  !INSERTMACRO MUI_INSTALLOPTIONS_WRITE "StandardQuestions.ini" "Field 6" "State" "${DEFAULT_LOG_DIR}"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro from your first install section to load the standard variables.
!MACRO StandardQuestionsReadAnswers
  !INSERTMACRO AvCustomReadText $APPLICATION_DIR "StandardQuestions" "Field 2"
  !INSERTMACRO AvCustomReadText $CONFIG_DIR "StandardQuestions" "Field 4"
  StrCpy $TEMPLATES_DIR "${DEFAULT_TEMPLATES_DIR}"
  !INSERTMACRO AvCustomReadText $LOG_DIR "StandardQuestions" "Field 6"
!MACROEND

!ENDIF ;STANDARD_QUESTIONS_IMPORT
