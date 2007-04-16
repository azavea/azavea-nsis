;c-style prevention of duplicate imports.
!IFNDEF WIN_SERVICE_UTILS_IMPORT
!DEFINE WIN_SERVICE_UTILS_IMPORT "yup"

; This contains utility macros useful when installing windows services.


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

  DetailPrint "Creating service ${SVC_NAME}..."
  nsExec::ExecToLog '"sc.exe" create ${SVC_NAME} start= auto binpath= "${SVC_EXE}" DisplayName= "${SVC_DISPLAY}"'

  ; If we were given no merge file, skip the merge part and just start the service.
  StrCmp "${MERGE_FILE}" "" start
  ; After a fresh install, there are no config files.  Check and see if there is a merge file.
  FindFirst $R0 $R1 "${MERGE_FILE}"
  ; If there is a merge file, merge it.
  StrCmp $R1 "" ask_to_start merge
  ask_to_start:
    MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
      "No merge file found, cannot automatically populate config files. $\n$\n\
      Do you want to try to start the service anyway (not recommended)?" \
      IDYES start IDNO dont_start
  merge:
    DetailPrint 'Executing command: ${CFG_MERGE_CMD}'
    nsExec::ExecToLog '${CFG_MERGE_CMD}'
  start:
    DetailPrint "Starting service ${SVC_NAME}..."
    nsExec::ExecToLog '"sc.exe" start ${SVC_NAME}'
  dont_start:

  Pop $R1
  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; Stops and deletes the windows service.
; SVC_NAME - The unique name of the service.
!MACRO StopAndDeleteService SVC_NAME
  DetailPrint "Stopping service ${SVC_NAME}..."
  nsExec::ExecToLog '"sc.exe" stop ${SVC_NAME}'
  DetailPrint "Removing service ${SVC_NAME}..."
  nsExec::ExecToLog '"sc.exe" delete ${SVC_NAME}'
!MACROEND

!ENDIF ;WIN_SERVICE_UTILS_IMPORT
