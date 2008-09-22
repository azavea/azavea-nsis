;c-style prevention of duplicate imports.
!IFNDEF AVENCIA_UTILS_IMPORT
!DEFINE AVENCIA_UTILS_IMPORT "yup"

; This contains a bunch of utility functions for doing basic things that are common to many installers.
; These are basic things like saving install/uninstall information, copying standard files
; or common paths, etc.
; These require a few defines:
; !DEFINE APP_NAME "NameForYourApp_WithoutSpaces" ; used for folders, registry keys, etc.
; The name defined on the 'Name "application name"' line is used for display names.

; Some standard defines used in multiple places.
!DEFINE UNINST_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

;------------------------------------------------------------------------------
; Saves information needed at uninstall time to the appropriate registry key.
; KEY - A simple string key, certain ones (such as "DisplayName") have special
;       meaning to the Add/Remove Programs dialog.
; VALUE - The value you'd like saved.
!MACRO SaveUninstallValue KEY VALUE
  WriteRegStr HKLM ${UNINST_REG_KEY} "${KEY}" "${VALUE}"
!MACROEND

;------------------------------------------------------------------------------
; Saves information needed at uninstall time to the appropriate registry key.
; KEY - A simple string key to look up.
; DEST_VAR - the variable to insert the value into.  Unset values will be "".
!MACRO GetUninstallValue KEY DEST_VAR
  ReadRegStr ${DEST_VAR} HKLM ${UNINST_REG_KEY} "${KEY}"
!MACROEND

;------------------------------------------------------------------------------
;icon is a filename, like "avencia16.ico"
;path is a path NOT ending in a "\".
!MACRO SaveStandardUninstallInfo ADDREMOVE_ICON ICON_PATH
  ; Show us in add/remove programs
  ; the first two values are required
  !INSERTMACRO SaveUninstallValue "DisplayName" "$(^Name)"
  !DEFINE UNINSTALLER_FILE "$INSTDIR\Uninstall${APP_NAME}.exe"
  !INSERTMACRO SaveUninstallValue "UninstallString" "${UNINSTALLER_FILE}"
  ; Icon and other misc info.
  !INSERTMACRO SaveUninstallValue "DisplayIcon" "$INSTDIR\${ADDREMOVE_ICON}"
  !INSERTMACRO SaveUninstallValue "Publisher" "Avencia Incorporated"
  !INSERTMACRO SaveUninstallValue "NoModify" "1"
  !INSERTMACRO SaveUninstallValue "NoRepair" "1"
  !INSERTMACRO SaveUninstallValue "InstallLocation" "$INSTDIR"

  !IFDEF APP_MAJOR_VERSION
    !INSERTMACRO SaveUninstallValue "VersionMajor" "${APP_MAJOR_VERSION}"
  !ENDIF
  !IFDEF APP_MINOR_VERSION
    !INSERTMACRO SaveUninstallValue "VersionMinor" "${APP_MAJOR_VERSION}"
  !ENDIF

  ; Create an uninstaller.
  SetOutPath $INSTDIR
  File ${ICON_PATH}\${ADDREMOVE_ICON}
  WriteUninstaller "${UNINSTALLER_FILE}"
!MACROEND

;------------------------------------------------------------------------------
; Removes the icon, registry keys, and uninstaller file itself.
!MACRO RemoveUninstallInfo
  Push $R0

  !INSERTMACRO GetUninstallValue "UninstallString" $R0
  ; Remove us from the add/remove programs list.
  DeleteRegKey HKLM ${UNINST_REG_KEY}
  StrCmp $R0 "" done
    ; Delete the uninstaller file if we know where it was.
    DetailPrint "Deleting uninstaller file $R0"
    ; If this uninstaller is being run programatically, a delete on its exe will
    ; not succeed.  So set /REBOOTOK so that even if we can't delete it now, it'll
    ; get deleted when we reboot.
    Delete /REBOOTOK "$R0"
  done:

  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; This function checks for the following:
; 1) That there isn't another copy of this installer running.
; 2) That there is not an old version of the application.
; 2.1) If there is, it gives the user the option of uninstalling.
Function StartupChecks
  Push $R0
  Push $R1

  ; This pushes something onto the stack, so pop it out in $R0
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${APP_NAME}_Setup_Mutex") i .r1 ?e'
  Pop $R0
 
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "The installer is already running."
    Abort

  ; Check for the old version.
  !INSERTMACRO GetUninstallValue "UninstallString" $R0
  StrCmp $R0 "" continue_install
    !INSERTMACRO GetUninstallValue "InstallLocation" $R1
    StrCmp $R1 "" cant_uninstall can_uninstall
    cant_uninstall:
      MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
        "$(^Name) is already installed. $\n$\nThe installed version \
        is too old to be automatically uninstalled.  You can uninstall \
        the old version using the Add/Remove Programs dialog.$\n$\n \
        Do you wish to install anyway (not recommended)?" \
        IDYES continue_install
        Abort
    can_uninstall:
      MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION|MB_DEFBUTTON1 \
        "$(^Name) is already installed. $\n$\nDo you want to uninstall \
        the other copy before installing this one (highly recommended)?" \
        IDYES uninst IDNO continue_install
        Abort
  
    ;Run the uninstaller
    uninst:
      ClearErrors
      ; ExecWait doesn't actually wait, so instead we use nsExec.
      ; R0 contains the uninstaller file, R1 contains the old installed path.
      nsExec::ExecToLog '$R0 _?=$R1'
 
      IfErrors uninstall_failed continue_install
      uninstall_failed:
        MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2 \
          "Uninstall of old version failed.  $\n$\nTry to install the new \
          version anyway?" \
        IDYES continue_install
        Abort
  continue_install:

  Pop $R1
  Pop $R0
FunctionEnd

;------------------------------------------------------------------------------
; The log directory is almost always the same thing.
!MACRO StandardLogFileSection LOG_DIR
  ; We don't have an uninstall section for log files because they are always left behind.
  Section "Log Files"
    SetOutPath ${LOG_DIR}
    ; Let everyone write log files, since the IIS user will need to write them.
    !INSERTMACRO SetPermissions "${LOG_DIR}" "Everyone" "R"
    !INSERTMACRO SetPermissions "${LOG_DIR}" "Everyone" "W"
    !INSERTMACRO SetPermissions "${LOG_DIR}" "Everyone" "C"
  SectionEnd
!MACROEND

;------------------------------------------------------------------------------
; This macro ensures that the value in VALUE ends with the string END_WITH.
; If VALUE is "Test" and END_WITH is "\" then this will change VALUE to "Test\".
; On the other hand, if VALUE was "Test2\", it would be unchanged.
!MACRO EnsureEndsWith VALUE END_WITH
  Push $R0
  Push $R1
  Push $R2

  StrLen $R0 ${END_WITH} ; how long is the ending string
  IntOp $R1 0 - $R0   ; how far to offset back from the end of the string
  StrCpy $R2 ${VALUE} $R0 $R1 ;take N chars starting N from the end of VALUE put in R2
  StrCmp $R2 ${END_WITH} +2 ;if the last N chars = END_WITH, good.
    StrCpy ${VALUE} "${VALUE}${END_WITH}" ; otherwise, append END_WITH

  Pop $R2
  Pop $R1
  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; This macro ensures that the value in VALUE does not end with the string END_WITH.
; If VALUE is "Test\" and END_WITH is "\" then this will change VALUE to "Test".
; On the other hand, if VALUE was "Test2", it would be unchanged.
!MACRO EnsureEndsWithout VALUE END_WITH
  Push $R0
  Push $R1
  Push $R2

  StrLen $R0 ${END_WITH} ; how long is the ending string
  IntOp $R1 0 - $R0   ; how far to offset back from the end of the string
  StrCpy $R2 ${VALUE} $R0 $R1 ;take N chars starting N from the end of VALUE put in R2
  StrCmp $R2 ${END_WITH} 0 +2 ;if the last N chars != END_WITH, good.
    StrCpy ${VALUE} "${VALUE}" "$R1"; otherwise, chop off END_WITH length chars

  Pop $R2
  Pop $R1
  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; This macro ensures that the file/directory "PATH" allows "USER" to have
; "PERMISSION.
; PATH: The file or directory, a trailing slash is optional for directories.
; USER: The user, must be known to the machine (this won't make up new users).
; PERMISSION: "R" for read, "W" for write, "F" for full control (see cacls.exe).
!MACRO SetPermissions PATH USER PERMISSION
  Push $R0
  Push $R1

  StrCpy $R1 "${PATH}"

  ; Check if the PATH has a slash, if so we'll need to chop it off.
  StrCpy $R0 $R1 1 -1 ;take 1 chars starting 1 from the end of VALUE, put in R2
  StrCmp $R0 "\" 0 +2 ;if the last char = \, need to truncate.
    StrCpy $R1 $R1 -1 ; truncate

  DetailPrint 'Setting permissions: "cacls.exe" "$R1" /T /E /G "${USER}":${PERMISSION}'
  nsExec::ExecToLog '"cacls.exe" "$R1" /T /E /G "${USER}":${PERMISSION}'
  Pop $R1
  Pop $R0
!MACROEND

;------------------------------------------------------------------------------
; This macro gets the command line value of parameter PARAM_NAME and puts it
; into DEST_VAR.  If the command is quoted ("/E Jeff Rules") we use the closing
; quote to terminate the value, so in that example the value would be "Jeff Rules".
; If unquoted (/E Jeff Rules) we use the first space, so the value would be "Jeff".
; By the way, this macro doesn't handle escaped quotes.
; PARAM_NAME: The entire parameter string to look for, I.E. "/E " or "/USER=" or
;             "-- " or whatever.  Everything that should precede the actual value.
; DEST_VAR: The destination variable.  Must be a variable.  The value will be ""
;           if the parameter was not found in the param string.
!MACRO GetCommandOption PARAM_NAME DEST_VAR
  Push $0
  Push $1
  Push "${PARAM_NAME}"
  Call GetSingleParameter
  Pop ${DEST_VAR}
  DetailPrint "Value of command line param ${PARAM_NAME}: '${DEST_VAR}'"
  Pop $1
  Pop $0
!MACROEND

;------------------------------------------------------------------------------
; Sets a variable to a default value.  Also checks the command line and will
; use the command line value over the default if a command line value is
; provided.  Command line values are expected to be in the form /VAR_NAME=<value>.
;
; VAR_NAME - The NAME of the variable that will be defaulted.  In other
;            words, if you are using a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
; DEFAULT_VALUE - The default value.  This will be used if the variable has
;                 no value on the command line.
!MACRO InitVar VAR_NAME DEFAULT_VALUE
  ; Check for a command line param.
  !INSERTMACRO GetCommandOption "/${VAR_NAME}=" $${VAR_NAME}
  ; No command line param, set it to the default value.
  StrCmp $${VAR_NAME} "" "" +2
    StrCpy $${VAR_NAME} "${DEFAULT_VALUE}"
!MACROEND


;
; The following functions have been copied wholesale from the appendix in the
; NSIS manual, under the section "Useful Scripts"
;


;------------------------------------------------------------------------------
; This function is intended to be called by the GetCommandOption macro.
; Pops the param name, pushes the value.
Function GetSingleParameter
  Pop $0
  Push $R0
  Push $R1
  Push $R2
  Push $R3
 
  ; This loads the entire parameter string from the command line
  ; into $R0.
  Call GetParameters
  Pop $R0

  ; R1 contains the value-terminator, either a closing " or a space.
  StrCpy $R1 '"'
  ; search for quoted $0
  Push $R0
  Push '"$0'
  Call StrStr
  Pop $R2
  ; If we found it, $R2 will now contain:
  ; '"$0=<the rest of the param string, including any remaining params>'
  ; Otherwise it will be empty string.

  ; This will remove the " off the front...  Except what if it's an empty
  ; string?  You'd think it would break, but this is how the example did it.
  StrCpy $R2 $R2 "" 1
  ; Compare $R2 with "", if equal, do nothing (meaning go to the next line),
  ; if not equal, meaning we found something, jump to foundParamString.
  StrCmp $R2 "" "" foundParamString
    ; Didn't find anything, try searching without a ".
    StrCpy $R1 ' ' ; change the value-terminator.
    ; search entire param list ($R0) for non quoted $0
    Push $R0
    Push '$0'
    Call StrStr
    Pop $R2
	; Check if we found anything.  If $R2 is "", we didn't find anything, so
	; just return empty string.
    StrCmp $R2 "" done
foundParamString:
    ; If we're here, we found the parameter.
    ; copy the value after $0.
	StrLen $R3 $0
    StrCpy $R2 $R2 "" $R3
  ; By now $R2 will now have the value we want, plus the entire remainder
  ; of the parameter string.  So we need to chop off everything past the
  ; terminating charater.
  Push $R2
  Push $R1
  Call StrStr
  Pop $R1
  ; Now $R1 has the terminating character plus everything else.  If $R1 is
  ; empty, there wasn't anything else, so we're done.
  StrCmp $R1 "" done
  ; Get the length of $R1 so we can chop that much off the end of $R2.
  StrLen $R1 $R1
  StrCpy $R2 $R2 -$R1
done:
  ; Save the output into $1.
  StrCpy $1 $R2
  ; Restore all the working variables.
  Pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  ; put the return value onto the stack.
  Push $1
FunctionEnd

; GetParameters
 ; input, none
 ; output, top of stack (replaces, with e.g. whatever)
 ; modifies no other variables.
 
 Function GetParameters
 
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   
   StrCpy $R2 1
   StrLen $R3 $CMDLINE
   
   ;Check for quote or space
   StrCpy $R0 $CMDLINE $R2
   StrCmp $R0 '"' 0 +3
     StrCpy $R1 '"'
     Goto loop
   StrCpy $R1 " "
   
   loop:
     IntOp $R2 $R2 + 1
     StrCpy $R0 $CMDLINE 1 $R2
     StrCmp $R0 $R1 get
     StrCmp $R2 $R3 get
     Goto loop
   
   get:
     IntOp $R2 $R2 + 1
     StrCpy $R0 $CMDLINE 1 $R2
     StrCmp $R0 " " get
     StrCpy $R0 $CMDLINE "" $R2
   
   Pop $R3
   Pop $R2
   Pop $R1
   Exch $R0
 
 FunctionEnd

 ; StrStr
 ; input, top of stack = string to search for
 ;        top of stack-1 = string to search in
 ; output, top of stack (replaces with the portion of the string remaining)
 ; modifies no other variables.
 ;
 ; Usage:
 ;   Push "this is a long ass string"
 ;   Push "ass"
 ;   Call StrStr
 ;   Pop $R0
 ;  ($R0 at this point is "ass string")

 Function StrStr
   Exch $R1 ; st=haystack,old$R1, $R1=needle
   Exch    ; st=old$R1,haystack
   Exch $R2 ; st=old$R1,old$R2, $R2=haystack
   Push $R3
   Push $R4
   Push $R5
   StrLen $R3 $R1
   StrCpy $R4 0
   ; $R1=needle
   ; $R2=haystack
   ; $R3=len(needle)
   ; $R4=cnt
   ; $R5=tmp
   loop:
     StrCpy $R5 $R2 $R3 $R4
     StrCmp $R5 $R1 done
     StrCmp $R5 "" done
     IntOp $R4 $R4 + 1
     Goto loop
 done:
   StrCpy $R1 $R2 "" $R4
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Exch $R1
 FunctionEnd 

!ENDIF ;AVENCIA_UTILS_IMPORT
