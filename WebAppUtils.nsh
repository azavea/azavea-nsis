;c-style prevention of duplicate imports.
!IFNDEF WEBAPP_UTILS_IMPORT
!DEFINE WEBAPP_UTILS_IMPORT "yup"

; This contains utility functions related to installing web applications.

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

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "" "" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "" "yes"
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
  !INSERTMACRO WebApplicationWithSecID "${SOURCE}" "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" ""
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

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "" "" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "" "yes"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for the "old-style" "Web Application" type of project.
; Same as WebApplicationWithSecID but uses .NET 4
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
!MACRO WebApplicationWithSecID4 SOURCE DEST_REAL DEST_VIRT DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SEC_ID_DEF
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

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "" "" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "4" "yes"
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
  !INSERTMACRO WebServiceWithSecID "${SOURCE}" "${DEST_REAL}" "${DEST_VIRT}" "" "" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "yes"
!MACROEND

;------------------------------------------------------------------------------
; Like WebService but does not create a virtual directory.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.WebServices
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO WebServiceWithoutVirtDir SOURCE DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
	!INSERTMACRO WebServiceWithSecID "${SOURCE}" "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" ""
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
!MACRO WebServiceWithSecID SOURCE DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SEC_ID_DEF CREATE_VIRT_DIR
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

  !INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "" "${CREATE_VIRT_DIR}"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for RESTService projects.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
; 
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.WebServices
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; WEBSITE_NAME - The name of the IIS website to install to
; APP_POOL_NAME- The name of the IIS application pool to install to
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO RESTService SOURCE DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
	Section "REST_${DISPLAY_NAME}"
		SetOutPath ${DEST_REAL}
		File ${SOURCE}\Global.asax
		SetOutPath ${DEST_REAL}\Views
		File ${SOURCE}\Views\Web.config ; Internal Web.config for ASP.NET MVC Views. There is also a 'normal' Web.config file.
		File /r ${SOURCE}\Views\*.cshtml
		SetOutPath ${DEST_REAL}\Content
		File /r ${SOURCE}\Content\*.html
		SetOutPath ${DEST_REAL}\bin
		File ${SOURCE}\bin\*.dll
	
	!INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "yes" "4" "yes"
!MACROEND

;------------------------------------------------------------------------------
; Call this macro to create web folders for Mvc3WebApp projects.
; Note that while this attempts to be all-inclusive, there may be some specialized files (like themes)
; or additional install steps that you will have to take care of in your specific installer.
;
; SOURCE       - The source directory to get files from.  I.E. ..\csharp\My.Project.WebServices
; DEST_REAL    - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT    - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; WEBSITE_NAME - The name of the IIS website to install to
; APP_POOL_NAME- The name of the IIS application pool to install to
; DISPLAY_NAME - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC  - The default document, such as "default.asmx".
; WEB_CONFIG   - The location/name (at install time) of the fully token-swapped Web.config file.
;                I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                to the correct location/name: $DEST_REAL\Web.config
!MACRO Mvc3WebApplication SOURCE DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG
	Section "REST_${DISPLAY_NAME}"
		SetOutPath ${DEST_REAL}
		File ${SOURCE}\Global.asax
		SetOutPath ${DEST_REAL}\Views
		File ${SOURCE}\Views\Web.config ; Internal Web.config for ASP.NET MVC Views. There is also a 'normal' Web.config file.
		File /r ${SOURCE}\Views\*.cshtml
		SetOutPath ${DEST_REAL}\Content
		;File /r ${SOURCE}\Content\*.html
		File /r ${SOURCE}\Content\*
		SetOutPath ${DEST_REAL}\bin
		File ${SOURCE}\bin\*.dll
		SetOutPath ${DEST_REAL}\Scripts
		File /r ${SOURCE}\Scripts\*

	!INSERTMACRO RestOfWebProj "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}" "${WEB_CONFIG}" "" "4" "yes"
!MACROEND

;------------------------------------------------------------------------------
; This is an internal macro used by the WebXXX macros for the common code.
; Those various macros copy the specific files, this takes care of the Web.Config,
; the virtual directories, and the uninstall section.
; 
; DEST_REAL       - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT       - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; DISPLAY_NAME    - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC     - The default document, such as "default.asmx".
; WEB_CONFIG      - The location/name (at install time) of the fully token-swapped Web.config file.
;                   I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                   to the correct location/name: $DEST_REAL\Web.config
; SUPPLEMENTARY   - Is this being installed into the same directory as something else
!MACRO RestOfWebProj DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SUPPLEMENTARY DOTNETVER CREATE_VIRT_DIR
    ; Move the web.config file from wherever it was installed and tokenswapped to the web app folder
    ${If} "${WEB_CONFIG}" != ""		
	
		; NSIS won't overwrite a file when the replacement file doesn't have a later date
		; so delete the existing Web.config file if this is a supplementary app.
		${If} "${SUPPLEMENTARY}" != ""
			Delete "${DEST_REAL}\Web.config"
		${EndIf}
		Rename "${WEB_CONFIG}" "${DEST_REAL}\Web.config"
    ${EndIf}

	; If this is the supplementary project (i.e. SOAP services installed into same directory as REST)
	; then we need to create the virtual directory.
	${If} "${CREATE_VIRT_DIR}" != ""
		${If} "${DOTNETVER}" == "4"
			!INSERTMACRO CreateVirtualDir4 "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}"
		${Else}
			!INSERTMACRO CreateVirtualDir "${DEST_REAL}" "${DEST_VIRT}" "${DISPLAY_NAME}" "${DEFAULT_DOC}"
		${EndIf}
	${Else}
		
	${EndIf}
    !INSERTMACRO SaveUninstallValue "WebAppURL_${DISPLAY_NAME}" "${DEST_VIRT}"
    !INSERTMACRO SaveUninstallValue "WebAppURL_${DISPLAY_NAME}_WebsiteName" "${WEBSITE_NAME}"
  SectionEnd
  
  Section "un.Web_${DISPLAY_NAME}"
    ${If} "${CREATE_VIRT_DIR}" != ""
            Push $1
            Push $2
            !INSERTMACRO GetUninstallValue "WebAppURL_${DISPLAY_NAME}" $1
            !INSERTMACRO GetUninstallValue "WebAppURL_${DISPLAY_NAME}_WebsiteName" $2
            ${If} "$1" != ""
        		!INSERTMACRO DeleteVirtualDir "$1" "${DISPLAY_NAME}" "$2"
            ${EndIf}
            Pop $2
            Pop $1

            ; Remove the real directory
            RmDir /r "${DEST_REAL}"
    ${EndIf}
  SectionEnd
!MACROEND
;------------------------------------------------------------------------------
; This is an internal macro used by the WebXXX macros for the common code.
; Those various macros copy the specific files, this takes care of the Web.Config,
; the virtual directories, and the uninstall section.
;
; DEST_REAL       - The destination "real" directory, I.E. $APPLICATION_DIR\Web
; DEST_VIRT       - The destination virtual directory, I.E. "MyApplication" (http://localhost/MyApplication)
; WEBSITE_NAME    - The IIS website to install to, I.E. "Default Web Site"
; APP_POOL_NAME   - The IIS application pool to use, I.E. "ASP.NET v4.0"
; DISPLAY_NAME    - The display name of the virtual directory, visible in IIS administrator(?)
; DEFAULT_DOC     - The default document, such as "default.asmx".
; WEB_CONFIG      - The location/name (at install time) of the fully token-swapped Web.config file.
;                   I.E. $CONFIG_DIR\WebAppOneWeb.config.  The file will be moved from that name/location
;                   to the correct location/name: $DEST_REAL\Web.config
; SUPPLEMENTARY   - Is this being installed into the same directory as something else
!MACRO RestOfWebProjFullDetails DEST_REAL DEST_VIRT WEBSITE_NAME APP_POOL_NAME DISPLAY_NAME DEFAULT_DOC WEB_CONFIG SUPPLEMENTARY CREATE_VIRT_DIR
    ; Move the web.config file from wherever it was installed and tokenswapped to the web app folder
    ${If} "${WEB_CONFIG}" != ""

		; NSIS won't overwrite a file when the replacement file doesn't have a later date
		; so delete the existing Web.config file if this is a supplementary app.
		${If} "${SUPPLEMENTARY}" != ""
			Delete "${DEST_REAL}\Web.config"
		${EndIf}
		Rename "${WEB_CONFIG}" "${DEST_REAL}\Web.config"
    ${EndIf}

	; If this is the supplementary project (i.e. SOAP services installed into same directory as REST)
	; then we need to create the virtual directory.
	${If} "${CREATE_VIRT_DIR}" != ""
                !INSERTMACRO CreateVirtualDir4 "${DEST_REAL}" "${DEST_VIRT}" "${WEBSITE_NAME}" "${APP_POOL_NAME}" "${DISPLAY_NAME}" "${DEFAULT_DOC}"
	${EndIf}
    !INSERTMACRO SaveUninstallValue "WebAppURL_${DISPLAY_NAME}" "${DEST_VIRT}"
  SectionEnd

  Section "un.Web_${DISPLAY_NAME}"
    Push $1
    !INSERTMACRO GetUninstallValue "WebAppURL_${DISPLAY_NAME}" $1
    ${If} "$1" != ""
		!INSERTMACRO DeleteVirtualDir "$1" "${DISPLAY_NAME}" "${WEBSITE_NAME}"
    ${EndIf}
    Pop $1

    ; Remove the real directory
    RmDir /r "${DEST_REAL}"
  SectionEnd
!MACROEND

;--------------------------------
; Enable .ashx files in the Default Web Site to receive HTTP DELETE requests
!MACRO EnableHttpDeleteForDefaultWebsite DEST_VIRT
              !INSERTMACRO EnableHttpDelete "Default Web Site" "${DEST_VIRT}"
!MACROEND

;--------------------------------
; Enable .ashx files in the specified website to receive HTTP DELETE requests
!MACRO EnableHttpDelete WEBSITE_NAME DEST_VIRT
       Section "Enable_Http_Delete"
              StrCpy $WAUTIL_WEBSITE_NAME "${WEBSITE_NAME}"
              StrCpy $WAUTIL_DEST_VIRT "${DEST_VIRT}"
              Call EnableHttpDelete
       SectionEnd
!MACROEND

;--------------------------------
; EnableHttpDelete Function
Var WAUTIL_WEBSITE_NAME
Var WAUTIL_DEST_VIRT
Function EnableHttpDelete
        Push $0
        Push $1

        GetTempFileName $1
        FileOpen $0 "$1.vbs" "w"

        FileWrite $0 "On Error Resume Next$\n"
        FileWrite $0 "Function LookupSiteNumber(siteName)$\r$\n"
        FileWrite $0 "	Set IIS = GetObject($\"IIS://localhost/w3svc$\")$\r$\n"
        
        FileWrite $0 "  If Err.Number <> 0 Then$\n"
        FileWrite $0 "        message = $\"Error $\" & Err.Number$\n"
        FileWrite $0 "        message = message & $\" accessing IIS server.$\" & chr(13)$\n"
        FileWrite $0 "        message = message & $\"Please check your IIS settings (inetmgr).$\"$\n"
        ${If} ${Silent}
          FileWrite $0 "      WScript.Echo message$\n"
        ${Else}
          FileWrite $0 "      MsgBox message, vbCritical$\n"
        ${EndIf}
        FileWrite $0 "        WScript.Quit (Err.Number)$\n"
        FileWrite $0 "   End If$\n"

        FileWrite $0 "	For Each Web in IIS$\r$\n"
        FileWrite $0 "		If (Web.Class = $\"IIsWebServer$\") Then$\r$\n"
        FileWrite $0 "			For Each Site in Web$\r$\n"
        FileWrite $0 "				If (Site.Name = $\"ROOT$\") Then$\r$\n"
        FileWrite $0 "					Set IISWebSite = GetObject($\"IIS://localhost/w3svc/$\" & Web.Name)$\r$\n"
        FileWrite $0 "					If (IISWebSite.ServerComment = siteName) Then$\r$\n"
        FileWrite $0 "						LookupSiteNumber = Web.Name$\r$\n"
        FileWrite $0 "					End If$\r$\n"
        FileWrite $0 "				End If$\r$\n"
        FileWrite $0 "			Next$\r$\n"
        FileWrite $0 "		End If$\r$\n"
        FileWrite $0 "	Next$\r$\n"
        FileWrite $0 "End Function$\r$\n"

        FileWrite $0 "Function StartsWith(str, searchStr)$\r$\n"
        FileWrite $0 "	Dim firstToken$\r$\n"
        FileWrite $0 "	firstToken = Left(str, InStr(str, $\",$\")-1)$\r$\n"
        FileWrite $0 "	If firstToken = searchStr Then$\r$\n"
        FileWrite $0 "		StartsWith = true$\r$\n"
        FileWrite $0 "	Else$\r$\n"
        FileWrite $0 "		StartsWith = false$\r$\n"
        FileWrite $0 "	End If$\r$\n"
        FileWrite $0 "End Function$\r$\n"

        FileWrite $0 "Dim siteNumber$\r$\n"
        FileWrite $0 "siteNumber = LookupSiteNumber($\"$WAUTIL_WEBSITE_NAME$\")$\r$\n"

        FileWrite $0 "Set website = GetObject($\"IIS://localhost/w3svc/$\" + siteNumber + $\"/ROOT/$WAUTIL_DEST_VIRT$\")$\r$\n"
        FileWrite $0 "Dim scriptMappings$\r$\n"
        FileWrite $0 "scriptMappings = website.ScriptMaps$\r$\n"

        FileWrite $0 "If Err.Number <> 0 Then$\n"
        FileWrite $0 "      message = $\"Error $\" & Err.Number$\n"
        FileWrite $0 "      message = message & $\" accessing application extension mappings.$\" & chr(13)$\n"
        FileWrite $0 "      message = message & $\"Please check your IIS settings (inetmgr).$\"$\n"
        ${If} ${Silent}
          FileWrite $0 "    WScript.Echo message$\n"
        ${Else}
          FileWrite $0 "    MsgBox message, vbCritical$\n"
        ${EndIf}
        FileWrite $0 "      WScript.Quit (Err.Number)$\n"
        FileWrite $0 "End If$\n"

        FileWrite $0 "For i = 0 To UBound(scriptMappings)$\r$\n"
        FileWrite $0 "	If StartsWith(scriptMappings(i), $\".ashx$\") Then$\r$\n"
        FileWrite $0 "		scriptMappings(i) = scriptMappings(i) & $\",DELETE$\"$\r$\n"
        FileWrite $0 "	End If$\r$\n"
        FileWrite $0 "Next$\r$\n"

        FileWrite $0 "website.Put $\"ScriptMaps$\", scriptMappings$\r$\n"
        FileWrite $0 "website.SetInfo$\r$\n"

        FileClose $0

        !INSERTMACRO AvExec '"$SYSDIR\cscript.exe" "$1.vbs"'

        Delete "$1.vbs"

        Pop $1
        Pop $0
FunctionEnd

!ENDIF ;WEBAPP_UTILS_IMPORT
