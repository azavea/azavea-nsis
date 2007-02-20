;c-style prevention of duplicate imports.
!IFNDEF AVENCIA_UTILS_IMPORT
!DEFINE AVENCIA_UTILS_IMPORT "yup"

; This contains a bunch of utility functions for doing basic things that are common to many installers.
; These require a few defines:
; !DEFINE APP_NAME "NameForYourApp_WithoutSpaces" ; used for folders, registry keys, etc.
; !DEFINE CONFIG_DIR "WhereAreTheConfigFiles" ; tells Web.config and App.configs to look here
; !DEFINE TEPLATES_DIR "WhereisTokenSwap.exe"
; The name defined on the "Name application name" line is used for display names.

; Some standard defines used in multiple places.
!DEFINE UNINST_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
!DEFINE UNINSTALLER_FILE "$INSTDIR\Uninstall${APP_NAME}.exe"

; Tell to use the Avencia icons.  You can override this by setting them before importing this file.
!IFNDEF MUI_ICON
  !DEFINE MUI_ICON "Avencia Installer.ico"
!ENDIF
!IFNDEF MUI_UNICON
  !DEFINE MUI_UNICON "Avencia Uninstaller.ico"
!ENDIF

;------------------------------------------------------------------------------
; This function checks for the following:
; 1) That there isn't another copy of this installer running.
; 2) That there is not an old version of the application.
; 2.1) If there is, it gives the user the option of uninstalling.
Function StartupChecks
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${APP_NAME}_Setup_Mutex") i .r1 ?e'
  Pop $R0
 
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort

  ; Check for the old version.
  ReadRegStr $R0 HKLM ${UNINST_REG_KEY} "UninstallString"
  StrCmp $R0 "" continue_install
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
      "$(^Name) is already installed. $\n$\nClick `OK` to remove the \
      previous version or `Cancel` to cancel this upgrade." \
      IDOK uninst
      Abort
  
    ;Run the uninstaller
    uninst:
      ClearErrors
      ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
 
      IfErrors uninstall_failed continue_install
      uninstall_failed:
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          "Uninstall of old version failed.  $\n$\nClick 'OK' to try to install the \
          new version anyway, or 'Cancel' to quit." \
        IDOK continue_install
        Abort
  continue_install:
FunctionEnd

;------------------------------------------------------------------------------
;icon is a filename, like "avencia16.ico"
;path is a path NOT ending in a "\".
!MACRO SaveUninstallInfo ADDREMOVE_ICON ICON_PATH
  ; Show us in add/remove programs
  ; required
  WriteRegStr HKLM ${UNINST_REG_KEY} "DisplayName" "$(^Name)"
  ; required
  WriteRegStr HKLM ${UNINST_REG_KEY} "UninstallString" "${UNINSTALLER_FILE}"
  ; Icon and other misc info.
  WriteRegStr HKLM ${UNINST_REG_KEY} "DisplayIcon" "$INSTDIR\${ADDREMOVE_ICON}"
  WriteRegStr HKLM ${UNINST_REG_KEY} "Publisher" "Avencia Incorporated"
  WriteRegStr HKLM ${UNINST_REG_KEY} "NoModify" "1"
  WriteRegStr HKLM ${UNINST_REG_KEY} "NoRepair" "1"

  ; Create an uninstaller.
  WriteUninstaller "${UNINSTALLER_FILE}"
  SetOutPath $INSTDIR
  File ${ICON_PATH}\${ADDREMOVE_ICON}
!MACROEND

;------------------------------------------------------------------------------
; Removes the icon, registry keys, and uninstaller file itself.
!MACRO RemoveUninstallInfo
  ; Remove us from the add/remove programs list.
  DeleteRegKey HKLM ${UNINST_REG_KEY}
  ; Delete the uninstaller file.
  Delete "${UNINSTALLER_FILE}"
!MACROEND

;------------------------------------------------------------------------------
; The log directory is almost always the same thing.
!DEFINE STANDARD_LOG_DIR "$INSTDIR\log"
!MACRO StandardLogFileSection
  ; We don't have an uninstall section for log files because they are always left behind.
  Section "Log Files"
    SetOutPath ${STANDARD_LOG_DIR}
    ; Let everyone write log files, since the IIS user will need to write them.
    nsExec::ExecToLog '"cacls.exe" "${STANDARD_LOG_DIR}" /T /E /G Everyone:W'
  SectionEnd
!MACROEND

;------------------------------------------------------------------------------
; Opens a new merge file and writes the header information.
!MACRO OpenMergeFile FILE_NAME OUT_FILE_HANDLE
  FileOpen ${OUT_FILE_HANDLE} ${FILE_NAME} w
  FileWrite ${OUT_FILE_HANDLE} '<?xml version="1.0" encoding="utf-8" ?>$\r$\n'
  FileWrite ${OUT_FILE_HANDLE} '<MERGE>$\r$\n'
!MACROEND

;------------------------------------------------------------------------------
; Writes the token/value pair to the merge file.
!MACRO WriteToken MERGE_FILE_HANDLE TOKEN VALUE
  FileWrite ${MERGE_FILE_HANDLE} '<TOKEN name="@${TOKEN}@" value="${VALUE}"/>$\r$\n'
!MACROEND

;------------------------------------------------------------------------------
; Finishes and closes the merge file.
!MACRO CloseMergeFile FILE_HANDLE
  FileWrite ${FILE_HANDLE} '</MERGE>$\r$\n'
  FileClose ${FILE_HANDLE}
!MACROEND

; Used by the TokenSwap macro.
!IFNDEF TOKENSWAP_LOCATION
  !DEFINE TOKENSWAP_LOCATION "${TEMPLATES_DIR}\TokenSwap.exe"
!ENDIF
;------------------------------------------------------------------------------
; Executes tokenswap.
; Assumes TokenSwap.exe is in TEMPLATES_DIR.  This can be overridden by defining
; TOKENSWAP_LOCATION before importing this file.
!MACRO TokenSwap TEMPLATE_FILE MERGE_FILE DESTINATION_DIR
  nsExec::ExecToLog '"${TOKENSWAP_LOCATION}" -mFile "${MERGE_FILE}" -tFiles "${TEMPLATE_FILE}" -dDir "${DESTINATION_DIR}" -nopause'
!MACROEND

;------------------------------------------------------------------------------
; If you need nothing swapped except the log and config dir (which is a common case)
; you can use this macro.
; Relies on CONFIG_DIR and TEMPLATES_DIR (needs TokenSwap).
; Makes a .mer file, calls TokenSwap.
!MACRO SwapStandardInstallTokens STD_SWAP_FROM_FILE STD_SWAP_TO_DIR
  !INSERTMACRO OpenMergeFile "${STD_SWAP_TO_DIR}\install.mer" $0
  !INSERTMACRO WriteToken $0 "logdir" ${STANDARD_LOG_DIR}
  !INSERTMACRO WriteToken $0 "configdir" ${CONFIG_DIR}
  !INSERTMACRO CloseMergeFile $0
  !INSERTMACRO TokenSwap ${STD_SWAP_FROM_FILE} "${STD_SWAP_TO_DIR}\install.mer" ${STD_SWAP_TO_DIR}
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders (web applications or web services).
!MACRO WebFolder SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC
  ; Includes this for doing the virtual directory creation/deletion.
  !INCLUDE "VirtualDirectory.nsh"
  Section "Web_${DISPLAY_NAME}"
    SetOutPath ${DEST_REAL}\templates
    File ${SOURCE}\Web.config
    SetOutPath ${DEST_REAL}
    File ${SOURCE}\*.as?x
    File /nonfatal ${SOURCE}\*.htm
    File /nonfatal ${SOURCE}\*.xml
    SetOutPath ${DEST_REAL}\xsd
    File /nonfatal ${SOURCE}\xsd\* ; may not be any xsd if this isn't a web service.
    SetOutPath ${DEST_REAL}\controls
    File /nonfatal ${SOURCE}\controls\*.as?x ; may not be any custom controls
    SetOutPath ${DEST_REAL}\images
    File /nonfatal ${SOURCE}\images\*
    SetOutPath ${DEST_REAL}\styles
    File /nonfatal ${SOURCE}\styles\*
    SetOutPath ${DEST_REAL}\bin
    File ${SOURCE}\bin\*.dll

    !INSERTMACRO SwapStandardInstallTokens "${DEST_REAL}\templates\Web.config" "${DEST_REAL}"
    StrCpy $CVDIR_VIRTUAL_NAME "${DEST_VIRT}"
    StrCpy $CVDIR_REAL_PATH "${DEST_REAL}"
    StrCpy $CVDIR_PRODUCT_NAME "${DISPLAY_NAME}"
    StrCpy $CVDIR_DEFAULT_DOC "${DEFAULT_DOC}"
    Call CreateVDir
  SectionEnd

  Section "un.Web_${DISPLAY_NAME}"
    StrCpy $DVDIR_VIRTUAL_NAME "${DEST_VIRT}"
    StrCpy $DVDIR_PRODUCT_NAME "${DISPLAY_NAME}"
    Call un.DeleteVDir
    RmDir /r "${DEST_REAL}"
  SectionEnd
!MACROEND
!ENDIF ;AVENCIA_UTILS_IMPORT
