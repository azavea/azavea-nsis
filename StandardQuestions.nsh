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
  !DEFINE DEFAULT_APP_DIR "$INSTDIR\app"
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
; Just declares the four standard subdir variables:
; APPLICATION_DIR, CONFIG_DIR, LOG_DIR, and TEMPLATES_DIR.
; 
; Note: Use this macro INSTEAD OF AvStandardQuestionsPage if you
;       want to use the other standard macros but don't want to
;       bother to ask the user where the subdirectories go.
!MACRO AvStandardSubdirVariables
  Var APPLICATION_DIR
  Var CONFIG_DIR
  Var LOG_DIR
  Var TEMPLATES_DIR
!MACROEND

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
; Call this macro from .onInit if you are using the standard questions.
!MACRO AvStandardQuestionsOnInit
  !INSERTMACRO InitVar "APPLICATION_DIR" "${DEFAULT_APP_DIR}"
  !INSERTMACRO InitVar "CONFIG_DIR" "${DEFAULT_CONF_DIR}"
  !INSERTMACRO InitVar "LOG_DIR" "${DEFAULT_LOG_DIR}"
  !INSERTMACRO InitVar "TEMPLATES_DIR" "${DEFAULT_TEMPLATES_DIR}"
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
; Prompts the user for the website name
!MACRO WebsiteNamePage
  !INSERTMACRO CreateEasyCustomTextVar "WEBSITE_NAME" ""
  !INSERTMACRO EasyCustomPageBegin "WebsiteName" "Website Name" "Please enter the name of the IIS website"
    !INSERTMACRO EasyCustomTextBox "WEBSITE_NAME" "Website name:"
  !INSERTMACRO EasyCustomPageEnd
!MACROEND

; Prompts the user for the website name, suggestion made based on customer
; installation choice
!MACRO WebsiteNamePageSuggest
  !INSERTMACRO CreateEasyCustomTextVar "WEBSITE_NAME" ""
  !INSERTMACRO EasyCustomPageWithPreBegin "WebsiteName" "Website Name" "Please enter the name of the IIS website" defaultWebSiteName
    !INSERTMACRO EasyCustomTextBox "WEBSITE_NAME" "Website name:"
  !INSERTMACRO EasyCustomPageEnd

  Function defaultWebSiteName
    ${If} $InstallLocation_SELECTION == "Azavea_Internal"
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal"
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal_Test"
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public"
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public_Test"
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${Else}
      StrCpy $WEBSITE_NAME "Default Web Site"
    ${EndIf}
  FunctionEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Prompts the user for the application pool name
!MACRO AppPoolNamePage
  !INSERTMACRO CreateEasyCustomTextVar "APP_POOL_NAME" ""
  !INSERTMACRO EasyCustomPageBegin "AppPoolName" "Application Pool Name" "Please enter the name of the IIS application pool"
    !INSERTMACRO EasyCustomTextBox "APP_POOL_NAME" "Applicaton pool name:"
  !INSERTMACRO EasyCustomPageEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Prompts the user for the application pool name, suggests name based on customer
!MACRO AppPoolNamePageSuggest
  !INSERTMACRO CreateEasyCustomTextVar "APP_POOL_NAME" ""
  !INSERTMACRO EasyCustomPageWithPreBegin "AppPoolName" "Application Pool Name" "Please enter the name of the IIS application pool" defaultAppPool
    !INSERTMACRO EasyCustomTextBox "APP_POOL_NAME" "Applicaton pool name:"
  !INSERTMACRO EasyCustomPageEnd

  Function defaultAppPool
    ${If} $InstallLocation_SELECTION == "Azavea_Internal"
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal"
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal_Test"
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public"
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public_Test"
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${Else}
      StrCpy $APP_POOL_NAME "SW AppPool .NET v4.0"
    ${EndIf}
  FunctionEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Guesses the local host name based on the registry value.
; This should be called from the installer's .onInit function.
; A value passed on the command line will override the registry value.
!MACRO InitLocalhostName
  Push $0
  ReadRegStr $0 HKLM "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" "ComputerName"
  !INSERTMACRO InitVar "LOCALHOST_NAME" $0
  Pop $0
!MACROEND


;--------------------------------------------------------------------------------------
; Standard page to ask for the name of the virtual directory.
; Declares a variable "APP_URL" that will contain the virtual
; directory name chosen by the user.
; If you set that variable in .onInit, that value will be used
; as the default when this page is shown.
!MACRO AvStandardVirtualDirectoryPage
  !INSERTMACRO CreateEasyCustomURLVar "APP_URL"
  !INSERTMACRO EasyCustomPageBegin "WebAppURL" "Virtual Directory" "Please choose the virtual directory (http://localhost/virtual_directory) for this application."
    !INSERTMACRO EasyCustomTextBox "APP_URL" "Web Application:"
  !INSERTMACRO EasyCustomPageEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Standard page to ask for the name of the virtual directory, based on customer
; selection.
; Declares a variable "APP_URL" that will contain the virtual
; directory name chosen by the user.
; If you set that variable in .onInit, that value will be used
; as the default when this page is shown.
!MACRO AvStandardVirtualDirectoryPageSuggest OPTION_A OPTION_B
  !INSERTMACRO CreateEasyCustomURLVar "APP_URL"
  !INSERTMACRO EasyCustomPageWithPreBegin "WebAppURL" "Virtual Directory" "Please choose the virtual directory (http://localhost/virtual_directory) for this application." defaultAppUrl
    !INSERTMACRO EasyCustomTextBox "APP_URL" "Web Application:"
  !INSERTMACRO EasyCustomPageEnd

  Function defaultAppUrl
    ${If} $InstallLocation_SELECTION == "Azavea_Internal"
      StrCpy $APP_URL "${OPTION_A}"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal"
      StrCpy $APP_URL "${OPTION_A}"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Internal_Test"
      StrCpy $APP_URL "${OPTION_A}"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public"
      StrCpy $APP_URL "${OPTION_B}"
    ${ElseIf} $InstallLocation_SELECTION == "PWD_Public_Test"
      StrCpy $APP_URL "${OPTION_B}"
    ${EndIf}
  FunctionEnd
!MACROEND

!ENDIF ;STANDARD_QUESTIONS_IMPORT
