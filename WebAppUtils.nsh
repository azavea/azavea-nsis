;c-style prevention of duplicate imports.
!IFNDEF WEBAPP_UTILS_IMPORT
!DEFINE WEBAPP_UTILS_IMPORT "yup"

; This contains a utility functions related to installing web applications.

; Includes this for doing the virtual directory creation/deletion.
!INCLUDE "VirtualDirectory.nsh"
; Uses tokenswap to configure the Web.config file.
!INCLUDE "ConfigUtils.nsh"

;------------------------------------------------------------------------------
; Call this macro to create web folders for the .NET 2.0 "Web Site" type of project.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.Web
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.aspx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO WebSite SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
  Section "WebSite_${DISPLAY_NAME}"

    SetOutPath ${DEST_REAL}
    ; Copy all files except .pdb debug files and web.config (because the web.config in the
    ; development directory will be the one with development values, we want to use the one
    ; passed in as WEB_CONFIG).
    File /r /x _svn /x *web.config /x *.pdb ${SOURCE}\*

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for the "old-style" "Web Application" type of project.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.Web
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.aspx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO WebApplication SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
  !INSERTMACRO WebServiceWithSecID "${SOURCE}" "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" ""
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for the "old-style" "Web Application" type of project.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.Web
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.aspx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
; SEC_ID_DEF   - The name of the macro to define containing the section ID.
!MACRO WebApplicationWithSecID SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SEC_ID_DEF
  Section "Web_${DISPLAY_NAME}" ${SEC_ID_DEF}
    SetOutPath ${DEST_REAL}
    File /r ${SOURCE}\*.as?x
    File /nonfatal /r ${SOURCE}\*.htm
    File /nonfatal /r ${SOURCE}\*.html
    File /nonfatal /r ${SOURCE}\*.xml
    File /nonfatal /r ${SOURCE}\*.sitemap
    File /nonfatal /r ${SOURCE}\*.master
    SetOutPath ${DEST_REAL}\images
    File /nonfatal ${SOURCE}\images\*
    SetOutPath ${DEST_REAL}\styles
    File /nonfatal ${SOURCE}\styles\*
    SetOutPath ${DEST_REAL}\js
    File /nonfatal ${SOURCE}\js\*
    SetOutPath ${DEST_REAL}\bin
    File ${SOURCE}\bin\*.dll

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for WebService projects.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.WebServices
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO WebService SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
  !INSERTMACRO WebServiceWithSecID "${SOURCE}" "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" ""
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for WebService projects.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.WebServices
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
; SEC_ID_DEF   - The name of the macro to define containing the section ID.
!MACRO WebServiceWithSecID SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SEC_ID_DEF
  Section "Web_${DISPLAY_NAME}" ${SEC_ID_DEF}
    SetOutPath ${DEST_REAL}
    File /r ${SOURCE}\*.as?x
    File /nonfatal /r ${SOURCE}\*.htm
    File /nonfatal /r ${SOURCE}\*.html
    File /nonfatal /r ${SOURCE}\*.xml
    SetOutPath ${DEST_REAL}\images
    File /nonfatal ${SOURCE}\images\*
    SetOutPath ${DEST_REAL}\styles
    File /nonfatal ${SOURCE}\styles\*
    SetOutPath ${DEST_REAL}\xsd
    File /nonfatal ${SOURCE}\xsd\* ; may not be any xsd if this isn't a web service.
    SetOutPath ${DEST_REAL}\bin
    File ${SOURCE}\bin\*.dll

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}"
!MACROEND

;------------------------------------------------------------------------------
; This is an internal macro used by the WebXXX macros for the common code.
; Those various macros copy the specific files, this takes care of the Web.Config,
; the virtual directories, and the uninstall section.
; 
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO RestOfWebProj DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
    ; Move the web.config file from wherever it was installed and tokenswapped to the web app folder
    Rename ${WEB_CONFIG} ${DEST_REAL}\Web.config

    !INSERTMACRO CreateVirtualDir "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}"
    !INSERTMACRO SaveUninstallValue "WebAppURL_${DISPLAY_NAME}" "${DEST_VIRT}"
  SectionEnd

  Section "un.Web_${DISPLAY_NAME}"
    Push $1
    !INSERTMACRO GetUninstallValue "WebAppURL_${DISPLAY_NAME}" $1
    !INSERTMACRO DeleteVirtualDir "$1" "${DISPLAY_NAME}"
    Pop $1

    ; Remove the real directory
    RmDir /r "${DEST_REAL}"
  SectionEnd
!MACROEND
!ENDIF ;WEBAPP_UTILS_IMPORT
