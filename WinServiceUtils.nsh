;c-style prevention of duplicate imports.
!IFNDEF WIN_SERVICE_UTILS_IMPORT
!DEFINE WIN_SERVICE_UTILS_IMPORT "yup"

; This contains utility macros useful when installing windows services.


;------------------------------------------------------------------------------
; Creates the windows service.  Pops up a message box asking the user if they
; would like to start the service now.
;
; SVC_NAME - The unique name of the service.
; SVC_EXE - The executable the service will run.
; SVC_DISPLAY - The user-friendly display name for the service.
!MACRO CreateAndMaybeStartService SVC_NAME SVC_EXE SVC_DISPLAY
  !INSERTMACRO CreateAndMaybeStartServiceAsUser "${SVC_NAME}" "${SVC_EXE}" "${SVC_DISPLAY}" "" ""
!MACROEND

;------------------------------------------------------------------------------
; Creates the windows service to run under the specified user. 
; Pops up a message box asking the user if they
; would like to start the service now.
;
; SVC_NAME - The unique name of the service.
; SVC_EXE - The executable the service will run.
; SVC_DISPLAY - The user-friendly display name for the service.
; SVC_USER - The user to run the service as.  If blank, will default to the
;            local system user.
; SVC_PASSWORD - The password for that user.  If user is blank, this may be blank
;                as well.
!MACRO CreateAndMaybeStartServiceAsUser SVC_NAME SVC_EXE SVC_DISPLAY SVC_USER SVC_PASSWORD
  !INSERTMACRO AvLog "Creating service ${SVC_NAME}..."
  ${If} "${SVC_USER}" == ""
    !INSERTMACRO AvExec '"sc.exe" create ${SVC_NAME} start= auto binpath= "${SVC_EXE}" DisplayName= "${SVC_DISPLAY}"'
  ${Else}
    !INSERTMACRO AvExec '"sc.exe" create ${SVC_NAME} start= auto binpath= "${SVC_EXE}" DisplayName= "${SVC_DISPLAY}" obj= "${SVC_USER}" password= "${SVC_PASSWORD}"'
  ${EndIf}

  MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
      "Do you want to start the ${SVC_DISPLAY} service now?" \
      IDYES start IDNO dont_start
  start:
    !INSERTMACRO AvLog "Starting service ${SVC_NAME}..."
    !INSERTMACRO AvExec '"sc.exe" start ${SVC_NAME}'
  dont_start:
!MACROEND

;------------------------------------------------------------------------------
; Creates, merges the config files (if necessary / possible), and starts (if the config merge worked)
; the windows service.
; SVC_NAME - The unique name of the service.
; SVC_EXE - The executable the service will run.
; SVC_DISPLAY - The user-friendly display name for the service.
; MERGE_FILE - If non-blank, we'll check for this merge file and if present, execute the CFG_MERGE_CMD
;              If blank, config files are assumed to already be correct.
; CFG_MERGE_CMD - The command to run to merge the config files.
!MACRO CreateAndConfigAndStartService SVC_NAME SVC_EXE SVC_DISPLAY MERGE_FILE CFG_MERGE_CMD
  Push $R0
  Push $R1

  !INSERTMACRO AvLog "Creating service ${SVC_NAME}..."
  !INSERTMACRO AvExec '"sc.exe" create ${SVC_NAME} start= auto binpath= "${SVC_EXE}" DisplayName= "${SVC_DISPLAY}"'

  ; If we were given no merge file, skip the merge part and just start the service.
  ${If} "${MERGE_FILE}" != ""
    ; After a fresh install, there are no config files.  Check and see if there is a merge file.
    FindFirst $R0 $R1 "${MERGE_FILE}"
    ; If there is a merge file, merge it.
    ${If} $R1 == ""
      MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
        "No merge file found, cannot automatically populate config files. $\n$\n\
        Do you want to try to start the service anyway (not recommended)?" \
        IDYES start IDNO dont_start
    ${Else}
      !INSERTMACRO AvLog 'Executing command: ${CFG_MERGE_CMD}'
      !INSERTMACRO AvExec '${CFG_MERGE_CMD}'
    ${EndIF}
  ${EndIf}
  start:
    !INSERTMACRO AvLog "Starting service ${SVC_NAME}..."
    !INSERTMACRO AvExec '"sc.exe" start ${SVC_NAME}'
  dont_start:

  Pop $R1
  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; Stops and deletes the windows service.
; SVC_NAME - The unique name of the service.
!MACRO StopAndDeleteService SVC_NAME
  !INSERTMACRO AvLog "Stopping service ${SVC_NAME}..."
  !INSERTMACRO AvExec '"sc.exe" stop ${SVC_NAME}'
  !INSERTMACRO AvLog "Removing service ${SVC_NAME}..."
  !INSERTMACRO AvExec '"sc.exe" delete ${SVC_NAME}'
!MACROEND

!ENDIF ;WIN_SERVICE_UTILS_IMPORT
