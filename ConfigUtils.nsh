;c-style prevention of duplicate imports.
!IFNDEF CONFIG_UTILS_IMPORT
!DEFINE CONFIG_UTILS_IMPORT "yup"

; This contains utility functions for swapping tokens in text files.  This uses the TokenSwap
; utility, and has methods for creating merge files and executing tokenswap.

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

;--------------------------------------------------------------------------------------
; Includes the merginator exe/dll files
;
; WHERE - The folder to put the merginator files in, will be saved as ${MERGINATOR_DIR}
!MACRO IncludeMerginator WHERE
  !DEFINE MERGINATOR_DIR "${WHERE}"
  SetOutPath ${MERGINATOR_DIR}
  File externals\Avencia.Tools.Merginator\*.exe
  File externals\Avencia.Tools.Merginator\*.dll
!MACROEND

;------------------------------------------------------------------------------
; Constructs a list of input merge files for passing to Merginate's INPUT_MERS
; parameter.
; FILE_LIST   - A variable holding the current list of merge files, variable's value
;               should be "" if this is the first one.
; MERGE_FILE  - The merge file (including path if necessary) to add to the list.
;               Merge files are used in order, so values in a later one will override
;               values in earlier ones.  This may be "", in which case this is a
;               no-op (the idea being if there was conditional logic for setting the
;               $SOME_MERGE_FILE var, you don't have to check if it's been set before
;               calling this).
!MACRO AppendMergeFile FILE_LIST MERGE_FILE
  ${If} ${MERGE_FILE} != ""
    StrCpy ${FILE_LIST} '${FILE_LIST} -mi "${MERGE_FILE}"'
  ${ENDIF}
!MACROEND

;--------------------------------------------------------------------------------------
; Runs the merginator with the list of merge files
;
; OUTPUT_MER      - The output merge file, which will be written with any user values.
; INPUT_MERS      - A list of input merge files, created using the AppendMergeFile macro.
;                   May be "" if there are none.
; TEMPL_DIR       - The directory containing template files.
; DEST_DIR        - The output directory for tokenized template files.
!MACRO Merginate OUTPUT_MER INPUT_MERS TEMPL_DIR DEST_DIR
  Push $0
  ; Run the Merginator
  StrCpy $0 '"${MERGINATOR_DIR}\Avencia.Tools.Merginator.UI.exe" ${INPUT_MERS} -mo "${OUTPUT_MER}" -t "${TEMPL_DIR}" -d "${DEST_DIR}" -c'
  DetailPrint "Executing the Merginator: $0"
  nsExec::ExecToLog '$0'
  Pop $0
!MACROEND

;------------------------------------------------------------------------------
; Executes tokenswap.  Tokenswap's exe must be TOKENSWAP_LOCATION
!MACRO TokenSwap TEMPLATE_FILE MERGE_FILE DESTINATION_DIR TOKENSWAP_LOCATION
  DetailPrint "Swapping tokens in ${TEMPLATE_FILE}"
  nsExec::ExecToLog '"${TOKENSWAP_LOCATION}" -mFile "${MERGE_FILE}" -tFiles "${TEMPLATE_FILE}" -dDir "${DESTINATION_DIR}" -nopause'
!MACROEND

;------------------------------------------------------------------------------
; Executes tokenswap against an entire directory.  Tokenswap's exe must be TOKENSWAP_LOCATION
!MACRO TokenSwapDir TEMPLATE_DIR MERGE_FILE DESTINATION_DIR TOKENSWAP_LOCATION
  DetailPrint "Swapping tokens in files in ${TEMPLATE_DIR}"
  nsExec::ExecToLog '"${TOKENSWAP_LOCATION}" -mFile "${MERGE_FILE}" -tDir "${TEMPLATE_DIR}" -dDir "${DESTINATION_DIR}" -nopause'
!MACROEND

;------------------------------------------------------------------------------
; If you need nothing swapped except the log and config dir (which is a common case)
; you can use this macro.
; Makes a .mer file, calls TokenSwap.
; Uses the standard variables LOG_DIR and CONFIG_DIR
!MACRO SwapStandardInstallTokens STD_SWAP_FROM_FILE STD_SWAP_TO_DIR TOKENSWAP_LOCATION
  Push $0

  !INSERTMACRO OpenMergeFile "${STD_SWAP_TO_DIR}\install.mer" $0
  !INSERTMACRO WriteToken $0 "logdir" $LOG_DIR
  !INSERTMACRO WriteToken $0 "configdir" $CONFIG_DIR
  !INSERTMACRO CloseMergeFile $0
  !INSERTMACRO TokenSwap "${STD_SWAP_FROM_FILE}" "${STD_SWAP_TO_DIR}\install.mer" "${STD_SWAP_TO_DIR}" "${TOKENSWAP_LOCATION}"

  Pop $0
!MACROEND


;------------------------------------------------------------------------------
; Checks for the merge file, if found executes the merge command, if not warns
; the user that they had better configure the files themselves.
; MERGE_FILE - The .mer file to use if present.
; MERGE_CMD - The command to execute to merge the config files.
!MACRO MergeConfigs MERGE_FILE MERGE_CMD
  Push $R0
  Push $R1

  ; After a fresh install, there are no config files.  Check and see if there is a merge file.
  FindFirst $R0 $R1 "${MERGE_FILE}"
  ; If there is a merge file, merge it.
  StrCmp $R1 "" warn merge
  warn:
    MessageBox MB_OK|MB_ICONEXCLAMATION \
      "No merge file found, cannot automatically populate config files. $\n$\n\
      Please remember to populate the config files after the installation completes."
    goto done
  merge:
    DetailPrint 'Executing command: ${MERGE_CMD}"'
    nsExec::ExecToLog '${MERGE_CMD}'
  done:

  Pop $R1
  Pop $R0
!MACROEND

!ENDIF ;CONFIG_UTILS_IMPORT
