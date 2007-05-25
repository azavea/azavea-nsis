;c-style prevention of duplicate imports.
!IFNDEF WEBAPP_UTILS_IMPORT
!DEFINE WEBAPP_UTILS_IMPORT "yup"

; This contains a utility functions related to installing web applications.

; Includes this for doing the virtual directory creation/deletion.
!INCLUDE "VirtualDirectory.nsh"
; Uses tokenswap to configure the Web.config file.
!INCLUDE "ConfigUtils.nsh"

;------------------------------------------------------------------------------
; Call this macro to create web folders (web applications or web services).
!MACRO WebFolder SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC TOKENSWAP_LOC
  Section "Web_${DISPLAY_NAME}"
    SetOutPath ${DEST_REAL}\templates
    File ${SOURCE}\Web.config
    SetOutPath ${DEST_REAL}
    File /r ${SOURCE}\*.as?x
    File /nonfatal ${SOURCE}\*.htm
    File /nonfatal ${SOURCE}\*.xml
    SetOutPath ${DEST_REAL}\xsd
    File /nonfatal ${SOURCE}\xsd\* ; may not be any xsd if this isn't a web service.
    SetOutPath ${DEST_REAL}\images
    File /nonfatal ${SOURCE}\images\*
    SetOutPath ${DEST_REAL}\styles
    File /nonfatal ${SOURCE}\styles\*
    SetOutPath ${DEST_REAL}\bin
    File ${SOURCE}\bin\*.dll

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
