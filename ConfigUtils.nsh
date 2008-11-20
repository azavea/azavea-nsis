;c-style prevention of duplicate imports.
!IFNDEF CONFIG_UTILS_IMPORT
!DEFINE CONFIG_UTILS_IMPORT "yup"
!INCLUDE "CustomPageUtils.nsh"

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

;--------------------------------------------------------------------------------------
; Prompts the user for which set of default values (which default merge file) will be used.
; Defines a variable, $${CUSTOM_NAME}_SELECTION, which will be one of the names added with the
; AddMergeFileOption macro.  The selection will be "" if "No Defaults" is selected.
;
; CUSTOM_NAME - A custom name that must be unique, and should be simple with no
;               spaces or punctuation.  It is used to define functions and things.
; CUSTOM_HEADER - The text in the title bar of the custom page.
; CUSTOM_MESSAGE - The more detailed text in the top section of the page.
; LIST_BOX_PROMPT - The text to display next to the list box.
; ON_CHOOSE_FUNC - The function to call after the user selects the default value name, may be ""
!MACRO MergeFileSelectionPageBegin CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE LIST_BOX_PROMPT ON_CHOOSE_FUNC
  ; Create the variables first.
  Var ${CUSTOM_NAME}_SELECTION
  Var ${CUSTOM_NAME}_OPTION_LIST
  !INSERTMACRO CreateEasyCustomListBoxVar "${CUSTOM_NAME}_LISTBOX"

  Function ${CUSTOM_NAME}_default_onChooseMergeFile
    ; The _LISTBOX variable has the index of the selected value, so we need to parse
    ; through our _OPTION_LIST string and find the name at that index (the options are
    ; semicolon delimited, and the string always ends with a semicolon).
    Push $0    ; Has the current index within the string.
    Push $1    ; Has how many options we have yet to go.
    Push $2    ; The current character we're looking at while looking for semicolons.
    Push $3    ; The total length of the option list.
    Push $5    ; The index of the beginning of the selected text.
    Push $6    ; The length of the selected text.

    StrLen $3 "$${CUSTOM_NAME}_OPTION_LIST"
    IntOp $0 0 + 0
    IntOp $1 0 + $${CUSTOM_NAME}_LISTBOX
    ${CUSTOM_NAME}_find_name_beginning: ; this is a label
      ; If we don't need to move any more words, we're done.
      IntCmp $1 0 ${CUSTOM_NAME}_found_name_beginning ${CUSTOM_NAME}_found_name_beginning
      ; If we hit the end of the string, we're done.
      IntCmp $0 $3 ${CUSTOM_NAME}_found_name_beginning 0 ${CUSTOM_NAME}_found_name_beginning
        StrCpy $2 "$${CUSTOM_NAME}_OPTION_LIST" 1 $0
        StrCmp $2 ";" 0 +2
          IntOp $1 $1 - 1     ; We found a semicolon, so we're on the next word
          IntOp $0 $0 + 1     ; Either way we want to move to the next index.
        Goto ${CUSTOM_NAME}_find_name_beginning ; Loop again.
    ${CUSTOM_NAME}_found_name_beginning: ; this is a label
    IntOp $5 $0 + 0    ; Save the beginning index in $5.

    IntOp $6 0 + 0    ; Start out assuming length is zero.
    ${CUSTOM_NAME}_find_name_ending: ; this is a label
      ; If we hit the end of the string, we're done.
      IntCmp $0 $3 ${CUSTOM_NAME}_found_name_ending 0 ${CUSTOM_NAME}_found_name_ending
      ; Check for a semicolon.
      StrCpy $2 "$${CUSTOM_NAME}_OPTION_LIST" 1 $0
      ; If it's a semicolon, we're done.
      StrCmp $2 ";" ${CUSTOM_NAME}_found_name_ending 0
        IntOp $6 $6 + 1     ; Not a semicolon, increase the length by one.
        IntOp $0 $0 + 1     ; Also we want to move to the next index.
      Goto ${CUSTOM_NAME}_find_name_ending ; Loop again.
    ${CUSTOM_NAME}_found_name_ending: ; this is a label

    IntCmp $0 $3 ${CUSTOM_NAME}_setting_blank_str ${CUSTOM_NAME}_setting_real_str ${CUSTOM_NAME}_setting_blank_str
    ${CUSTOM_NAME}_setting_blank_str: ; this is a label
      ; If the "start" index is after the end of the string, use ""
      StrCpy $${CUSTOM_NAME}_SELECTION ""
      Goto ${CUSTOM_NAME}_done_setting_str ; Loop again.
    ${CUSTOM_NAME}_setting_real_str: ; this is a label
      ; Otherwise, copy a chunk of the string.
      StrCpy $${CUSTOM_NAME}_SELECTION "$${CUSTOM_NAME}_OPTION_LIST" $6 $5
      Goto ${CUSTOM_NAME}_done_setting_str ; Loop again.
    ${CUSTOM_NAME}_done_setting_str: ; this is a label

    ; Now call the user function if there is one.
    !If "${ON_CHOOSE_FUNC}" != ""
      Call ${ON_CHOOSE_FUNC}
    !Endif
    DetailPrint "Selection: $${CUSTOM_NAME}_SELECTION";

    Pop $6
    Pop $5
    Pop $3
    Pop $2
    Pop $1
    Pop $0
  FunctionEnd
  !INSERTMACRO EasyCustomPageWithPostBegin "${CUSTOM_NAME}" "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}" ${CUSTOM_NAME}_default_onChooseMergeFile
    !INSERTMACRO EasyCustomListBox "${CUSTOM_NAME}_LISTBOX" "${LIST_BOX_PROMPT}" 27
!MACROEND

;--------------------------------------------------------------------------------------
; Adds a merge file option to the list.
;
; CUSTOM_NAME     - The same name you passed to MergeFileSelectionPageBegin
; FILENAME_OPTION - The option name.  Should be the filename without extension (I.E.
;                   "Blah" will mean "Blah.mer".  If it ends in "_Test", first
;                   "Blah.mer" will be used then "Blah.mer", the assumption being that
;                   test values are mostly the same as the regular ones except with a
;                   few overrides.
!MACRO AddMergeFileOption CUSTOM_NAME FILENAME_OPTION
  StrCpy $${CUSTOM_NAME}_OPTION_LIST "$${CUSTOM_NAME}_OPTION_LIST${FILENAME_OPTION};"
  !INSERTMACRO EasyCustomListBoxEntry "${CUSTOM_NAME}_LISTBOX" "${FILENAME_OPTION}"
  DetailPrint "Adding option ${FILENAME_OPTION} to ${CUSTOM_NAME}"
!MACROEND

;--------------------------------------------------------------------------------------
; Finishes the MergeFileSelectionPage.
;
; CUSTOM_NAME     - The same name you passed to MergeFileSelectionPageBegin
; ALLOW_NO_DEFAULTS - if "true", adds an option for "No Defaults".  If the user chooses
;                     this option, $${CUSTOM_NAME}_SELECTION will be "".
!MACRO MergeFileSelectionPageEnd CUSTOM_NAME ALLOW_NO_DEFAULTS
  !If "${ALLOW_NO_DEFAULTS}" == "true"
    DetailPrint "Adding No Defaults option."
    ; Add a blank option.
    StrCpy $${CUSTOM_NAME}_OPTION_LIST "$${CUSTOM_NAME}_OPTION_LIST;"
    !INSERTMACRO EasyCustomListBoxEntry "${CUSTOM_NAME}_LISTBOX" "No Defaults"
  !Endif
  !INSERTMACRO EasyCustomPageEnd
!MACROEND

;--------------------------------------------------------------------------------------
; Initializes to the given merge file.
;
; CUSTOM_NAME    - The same name you passed to MergeFileSelectionPageBegin
; SELECTED_INDEX - The index (0-based) of the default merge file selection.
!MACRO InitMergeFileValue CUSTOM_NAME SELECTED_INDEX
  DetailPrint "Initializing merge file dialog ${CUSTOM_NAME} to ${SELECTED_INDEX}"
  IntOp $${CUSTOM_NAME}_LISTBOX 0 + ${SELECTED_INDEX}
  Call ${CUSTOM_NAME}_default_onChooseMergeFile
  DetailPrint "Done Initializing merge file dialog ${CUSTOM_NAME} to ${SELECTED_INDEX}"
!MACROEND

;--------------------------------------------------------------------------------------
; Appends 0, 1, or 2 merge file names to the MERGE_FILE_LIST variable.
; If no defaults were selected, no names are appended.
; If a <something>_Test name was selected, both <something>.mer and <something>_Test.mer
; are appended.
; Otherwise, just <something>.mer is appended.
;
; CUSTOM_NAME     - The same name you passed to MergeFileSelectionPageBegin
; MERGE_FILE_LIST - The variable containing the list of merge files (constructed
;                   using AppendMergeFile).
!MACRO AppendSelectedMergeFileNames CUSTOM_NAME MERGE_FILE_LIST
  DetailPrint "Appending merge files for ${CUSTOM_NAME}"
  ; Append our merge files.
  !If $${CUSTOM_NAME}_SELECTION != ""
    ; See if it is a test merge file and we should first append the real one.
    Push $R8          ; length of the selection.
    Push $R9          ; Working var for pieces of the selection.

    StrLen $R8 $${CUSTOM_NAME}_SELECTION
    ; Skip the "_Test" check if the length is less than or equal to 5.
    IntCmp $R8 5 ${CUSTOM_NAME}_append_selected_file ${CUSTOM_NAME}_append_selected_file
      ; We're only here if the length was greater than 5.
      StrCpy $R9 $${CUSTOM_NAME}_SELECTION "" -5   ; Get the last 5 chars into $R9
      StrCmp $R9 "_Test" 0 ${CUSTOM_NAME}_append_selected_file
        ; We're only here if the last 5 chars were "_Test".
        IntOp $R8 $R8 - 5
        StrCpy $R9 $${CUSTOM_NAME}_SELECTION $R8    ; Copy all but the last 5 chars into $R9.
        ; Now append that name.
        DetailPrint "Appending merge file ${MERGE_DIR}\$R9.mer"
        !INSERTMACRO AppendMergeFile ${MERGE_FILE_LIST} "${MERGE_DIR}\$R9.mer"

    ${CUSTOM_NAME}_append_selected_file:    ; This is a label
    DetailPrint "Appending merge file ${MERGE_DIR}\$${CUSTOM_NAME}_SELECTION.mer"
    !INSERTMACRO AppendMergeFile ${MERGE_FILE_LIST} "${MERGE_DIR}\$${CUSTOM_NAME}_SELECTION.mer"
    Pop $R9
    Pop $R8
  !EndIf
!MACROEND

!ENDIF ;CONFIG_UTILS_IMPORT
