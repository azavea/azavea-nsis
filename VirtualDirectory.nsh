;c-style prevention of duplicate imports.
!IFNDEF VIRTUAL_DIR_IMPORT
!DEFINE VIRTUAL_DIR_IMPORT "yup"

;--------------------------------
; CreateVDir Function
Var CVDIR_VIRTUAL_NAME
Var CVDIR_REAL_PATH
Var CVDIR_PRODUCT_NAME
Var CVDIR_DEFAULT_DOC
Function CreateVDir
 
;Open a VBScript File in the temp dir for writing
DetailPrint "Creating $TEMP\createVDir.vbs";
FileOpen $0 "$TEMP\createVDir.vbs" w
 
;Write the script:
;Create a virtual dir named $CVDIR_VIRTUAL_NAME pointing to $CVDIR_REAL_PATH with proper attributes
FileWrite $0 "On Error Resume Next$\n"
FileWrite $0 "Set Root = GetObject($\"IIS://LocalHost/W3SVC/1/ROOT$\")$\n"
FileWrite $0 "Set Dir = Root.Create($\"IIsWebVirtualDir$\", $\"$CVDIR_VIRTUAL_NAME$\")$\n"
FileWrite $0 "If (Err.Number <> 0) Then$\n"
FileWrite $0 "  If (Err.Number <> -2147024713) Then$\n"
FileWrite $0 "    message = $\"Error $\" & Err.Number$\n"
FileWrite $0 "    message = message & $\" trying to create IIS virtual directory.$\" & chr(13)$\n"
FileWrite $0 "    message = message & $\"Please check your IIS settings (inetmgr).$\"$\n"
FileWrite $0 "    MsgBox message, vbCritical, $\"$CVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 "    WScript.Quit (Err.Number)$\n"
FileWrite $0 "  End If$\n"
FileWrite $0 "  ' Error -2147024713 means that the virtual directory already exists.$\n"
FileWrite $0 "  ' We will check if the parameters are the same: if so, then OK.$\n"
FileWrite $0 "  ' If not, then fail and display a message box.$\n"
FileWrite $0 "  Set Dir = GetObject($\"IIS://LocalHost/W3SVC/1/ROOT/$CVDIR_VIRTUAL_NAME$\")$\n"
FileWrite $0 "  If (Dir.Path <> $\"$CVDIR_REAL_PATH$\") Then$\n"
FileWrite $0 "    message = $\"Virtual Directory $CVDIR_VIRTUAL_NAME already exists pointing at a different folder ($\" + Dir.Path + $\").$\" + chr(13)$\n"
FileWrite $0 "    message = message + $\"Please delete the virtual directory using the IIS console (inetmgr), and install again.$\"$\n"
FileWrite $0 "    MsgBox message, vbCritical, $\"$CVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 "    Wscript.Quit (Err.Number)$\n"
FileWrite $0 "  End If$\n"
FileWrite $0 "  If (Dir.AspAllowSessionState <> True  Or  Dir.AccessScript <> True) Then$\n"
FileWrite $0 "    message = $\"Virtual Directory $CVDIR_VIRTUAL_NAME already exists and has incompatible parameters.$\" + chr(13)$\n"
FileWrite $0 "    message = message + $\"Please delete the virtual directory using the IIS console (inetmgr), and install again.$\"$\n"
FileWrite $0 "    MsgBox message, vbCritical, $\"$CVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 "    Wscript.Quit (Err.Number)$\n"
FileWrite $0 "  End If$\n"
FileWrite $0 "  Wscript.Quit (0)$\n"
FileWrite $0 "End If$\n"
FileWrite $0 "Dir.Path = $\"$CVDIR_REAL_PATH$\"$\n"
FileWrite $0 "Dir.AccessRead = True$\n"
FileWrite $0 "Dir.AccessWrite = False$\n"
FileWrite $0 "Dir.AccessScript = True$\n"
FileWrite $0 "Dir.AppFriendlyName = $\"$CVDIR_VIRTUAL_NAME$\"$\n"
FileWrite $0 "Dir.EnableDirBrowsing = False$\n"
FileWrite $0 "Dir.ContentIndexed = False$\n"
FileWrite $0 "Dir.DontLog = True$\n"
FileWrite $0 "Dir.EnableDefaultDoc = True$\n"
FileWrite $0 "Dir.DefaultDoc = $\"$CVDIR_DEFAULT_DOC$\"$\n"
FileWrite $0 "Dir.AspBufferingOn = True$\n"
FileWrite $0 "Dir.AspAllowSessionState = True$\n"
FileWrite $0 "Dir.AspSessionTimeout = 30$\n"
FileWrite $0 "Dir.AspScriptTimeout = 900$\n"
FileWrite $0 "Dir.SetInfo$\n"
FileWrite $0 "Set IISObject = GetObject($\"IIS://LocalHost/W3SVC/1/ROOT/$CVDIR_VIRTUAL_NAME$\")$\n"
FileWrite $0 "IISObject.AppCreate2(2) 'Create a process-pooled web application$\n"
FileWrite $0 "If (Err.Number <> 0) Then$\n"
FileWrite $0 " message = $\"Error $\" & Err.Number$\n"
FileWrite $0 " message = message & $\" trying to create the virtual directory at 'IIS://LocalHost/W3SVC/1/ROOT/$CVDIR_VIRTUAL_NAME'$\" & chr(13)$\n"
FileWrite $0 " message = message & $\"Please check your IIS settings (inetmgr).$\"$\n"
FileWrite $0 " MsgBox message, vbCritical, $\"$CVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 " WScript.Quit (Err.Number)$\n"
FileWrite $0 "End If$\n"
 
FileClose $0
 
DetailPrint "Executing $TEMP\createVDir.vbs"
nsExec::ExecToLog /TIMEOUT=20000 '"$SYSDIR\cscript.exe" "$TEMP\createVDir.vbs"'
Pop $1
StrCmp $1 "0" CreateVDirOK
DetailPrint "Error $1 in CreateVDir.vbs"
Abort "Failed to create IIS Virtual Directory"
 
CreateVDirOK:
DetailPrint "Successfully created IIS virtual directory"
Delete "$TEMP\createVDir.vbs"
FunctionEnd
 
;--------------------------------
; DeleteVDir Function
Var DVDIR_VIRTUAL_NAME
Var DVDIR_PRODUCT_NAME
Function un.DeleteVDir
 
;Open a VBScript File in the temp dir for writing
DetailPrint "Creating $TEMP\deleteVDir.vbs";
FileOpen $0 "$TEMP\deleteVDir.vbs" w
 
;Write the script:
;Remove a virtual dir named $DVDIR_VIRTUAL_NAME
FileWrite $0 "On Error Resume Next$\n$\n"
;Delete the application object
FileWrite $0 "Set IISObject = GetObject($\"IIS://LocalHost/W3SVC/1/ROOT/$DVDIR_VIRTUAL_NAME$\")$\n$\n"
FileWrite $0 "IISObject.AppDelete 'Delete the web application$\n"
FileWrite $0 "If (Err.Number <> 0) Then$\n"
FileWrite $0 " MsgBox $\"Error trying to delete the application at [IIS://LocalHost/W3SVC/1/ROOT/$DVDIR_VIRTUAL_NAME]$\", vbCritical, $\"$DVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 " WScript.Quit (Err.Number)$\n"
FileWrite $0 "End If$\n$\n"
 
FileWrite $0 "Set IISObject = GetObject($\"IIS://LocalHost/W3SVC/1/ROOT$\")$\n$\n"
FileWrite $0 "IIsObject.Delete $\"IIsWebVirtualDir$\", $\"$DVDIR_VIRTUAL_NAME$\"$\n"
FileWrite $0 "If (Err.Number <> 0) Then$\n"
FileWrite $0 " MsgBox $\"Error trying to delete the virtual directory '$DVDIR_VIRTUAL_NAME' at 'IIS://LocalHost/W3SVC/1/ROOT'$\", vbCritical, $\"$DVDIR_PRODUCT_NAME$\"$\n"
FileWrite $0 " Wscript.Quit (Err.Number)$\n"
FileWrite $0 "End If$\n$\n"
 
FileClose $0
 
DetailPrint "Executing $TEMP\deleteVDir.vbs"
nsExec::Exec /TIMEOUT=20000 '"$SYSDIR\cscript.exe" "$TEMP\deleteVDir.vbs"'
Pop $1
StrCmp $1 "0" +2
DetailPrint "Error $1 in deleteVDir.vbs"
goto DeleteVDirEnd
DetailPrint "Virtual Directory $DVDIR_VIRTUAL_NAME successfully removed."
Delete "$TEMP\deleteVDir.vbs"
DeleteVDirEnd:
FunctionEnd

!ENDIF ;VIRTUAL_DIR_IMPORT
