;c-style prevention of duplicate imports.
!IFNDEF WEBAPP_UTILS_IMPORT
!DEFINE WEBAPP_UTILS_IMPORT "yup"

; This contains a utility functions related to installing web applications.

; Includes this for string calls like IndexOf
!INCLUDE "AvenciaUtils.nsh"
; Includes this for doing the virtual directory creation/deletion.
!INCLUDE "VirtualDirectory.nsh"
; Uses tokenswap to configure the Web.config file.
!INCLUDE "ConfigUtils.nsh"

;------------------------------------------------------------------------------
; Call this macro to create .NET 1.1 web folders (web applications or web services).
!MACRO WebFolder SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC TOKENSWAP_LOC
  !INSERTMACRO WebFolderCustomContents ${SOURCE} ${DEST_REAL}  ${DEST_VIRT} ${DISPLAY_NAME} \
      ${DEFAULT_DOC} ${TOKENSWAP_LOC} "xsd\*;controls\*.as?x;images\*;styles\*;bin\*.dll"
!MACROEND

;------------------------------------------------------------------------------
; This version handles the virtual directory, includes all as?x, htm, and xml files
; in the source directory, swaps standard tokens in Web.config, and includes any files
; listed in FILE_PATHS.
; FILE_PATHS - A semi-colon-separated list of files/paths that will be recursively added.
;              This works as follows:
;                images\*;controls\*.as?x
;              means include everything under images (images\one.bmp, images\subdir,
;              images\subdir\two.bmp, etc) and all files "*.as?x" under controls
;              (controls\one.aspx, controls\subdir\two.ascx, etc).
;              If no files exist in one of the paths, a warning is generated.
!MACRO WebFolderCustomContents SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC TOKENSWAP_LOC FILE_PATHS
  Section "Web_${DISPLAY_NAME}"
    SetOutPath ${DEST_REAL}\templates
    File ${SOURCE}\Web.config
    SetOutPath ${DEST_REAL}
    File /nonfatal ${SOURCE}\*.as?x
    File /nonfatal ${SOURCE}\*.htm
    File /nonfatal ${SOURCE}\*.xml

    ; This section loops over the list of FILE_PATHS.
    Push $R0 ; working string
    Push $R1 ; index of ";"
    Push $R2 ; a single value
    
    StrCpy R0 ${SUB_DIRS}
    !INSERTMACRO IndexOf $R1 $R0 ";"
    StrCmp $R1 -1 +7      ; Skip the contents of the loop if index was -1.
      StrCpy $R2 $R0 $R1    ; copy the value into R2
      SetOutPath ${DEST_REAL}\$R2            ; Set the output path.
      File /r /nonfatal ${SOURCE}\$R2\*      ; Recursively get everything in that directory.
      IntOp $R1 1 + $R1     ; Add one so we skip the semicolon
      StrCpy $R0 $R0 "" $R1 ; chop the first value and semicolon off the front of the string.
    goto -7               ; loop back to the IndexOf call.
    Pop $R2
    Pop $R1
    Pop $R0

    !INSERTMACRO SwapStandardInstallTokens "${DEST_REAL}\templates\Web.config" "${DEST_REAL}" "${TOKENSWAP_LOC}"
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

!ENDIF ;WEBAPP_UTILS_IMPORT
