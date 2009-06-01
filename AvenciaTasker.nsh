;c-style prevention of duplicate imports.
!IFNDEF AVENCIA_TASKER_IMPORT
!DEFINE AVENCIA_TASKER_IMPORT "yup"
!INCLUDE "WinServiceUtils.nsh"

;------------------------------------------------------------------------------
; This contains utility macros/functions for simplifying the installation of
; the Tasker windows service.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Adds the install and uninstall sections for the Tasker.  This will typically
; come late in your installer, since you'll want to install your config files
; and probably whatever applications the tasker will be scheduling before
; installing and starting the service itself.
;
; TASKER_DEST_DIR - The directory where the tasker application will be installed to.
; TASKER_SRC_DIR - The directory where the tasker application was compiled.
; CONFIG_DIR - The directory where the Avencia.Utilities.Tasker.exe.config file
;              is located (typically it will have been placed there by TokenSwap).
; SERVICE_NAME - The unique name of the windows service to create (No spaces).
!MACRO TaskerSections TASKER_DEST_DIR TASKER_SRC_DIR CONFIG_DIR SERVICE_NAME
  Section "Tasker Windows Service"
    ; Save the install dir.
    !INSERTMACRO SaveUninstallValue "TaskerDirectory" "${TASKER_DEST_DIR}"
    !INSERTMACRO SaveUninstallValue "TaskerService" "${SERVICE_NAME}"
    ; Copy the tasker binaries
    SetOutPath "${TASKER_DEST_DIR}"
    File ${TASKER_SRC_DIR}\*dll
    File ${TASKER_SRC_DIR}\*exe
  
    ; Move the app.config file from the config folder (where it was tokenswapped) to the tasker app folder
    Rename ${CONFIG_DIR}\Avencia.Utilities.Tasker.exe.config ${TASKER_DEST_DIR}\Avencia.Utilities.Tasker.exe.config
  
    !INSERTMACRO AvLog "Creating Avencia Tasker service for ${APP_NAME}..."
    !INSERTMACRO CreateAndMaybeStartService ${SERVICE_NAME} "${TASKER_DEST_DIR}\Avencia.Utilities.Tasker.exe" "Avencia Tasker Utility for ${APP_NAME}"
  SectionEnd

  Section "un.Tasker Windows Service"
    Push $0
    Push $1
    !INSERTMACRO GetUninstallValue "TaskerDirectory" $0
    !INSERTMACRO GetUninstallValue "TaskerService" $1
    !INSERTMACRO StopAndDeleteService "$1"
    RmDir /r "$0"
    Pop $1
    Pop $0
  SectionEnd
!MACROEND

!ENDIF ;AVENCIA_TASKER_IMPORT
