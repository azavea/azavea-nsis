;c-style prevention of duplicate imports.
!IFNDEF CUSTOM_PAGE_UTILS_IMPORT
!DEFINE CUSTOM_PAGE_UTILS_IMPORT "yup"

; This contains a bunch of utility functions for doing basic things that are common to many installers.
; These are basic things like saving install/uninstall information, copying standard files
; or common paths, etc.

;------------------------------------------------------------------------------
; This macro initializes a custom page.  Must be called in .onInit for each
; custom page in your installer.
; CUSTOM_NAME - The name of the ini file (I.E. "MyCustomPage" if the ini is
;               "MyCustomPage.ini".
!MACRO AvCustomInit CUSTOM_NAME
  ; This extracts the ini so we can use the dialog.
  !INSERTMACRO MUI_INSTALLOPTIONS_EXTRACT "${CUSTOM_NAME}.ini"
!MACROEND
;------------------------------------------------------------------------------
; Same as AvCustomInit, except this allows you to specify that the ini file is in a
; different location than your .nsi file.
!MACRO AvCustomInitWithPath CUSTOM_NAME PATH_TO_FILE
  !INSERTMACRO MUI_INSTALLOPTIONS_EXTRACT_AS "${PATH_TO_FILE}${CUSTOM_NAME}.ini" "${CUSTOM_NAME}.ini"
!MACROEND

;------------------------------------------------------------------------------
; This macro reads the value of a text field and puts it into the specified
; OUT_VAR.
; CUSTOM_NAME - The name of the ini file (I.E. "MyCustomPage" if the ini is
;               "MyCustomPage.ini".
; FIELD - The name of the field in the custom page.
!MACRO AvCustomReadText OUT_VAR CUSTOM_NAME FIELD
  !INSERTMACRO MUI_INSTALLOPTIONS_READ ${OUT_VAR} "${CUSTOM_NAME}.ini" "${FIELD}" "State"
!MACROEND

;------------------------------------------------------------------------------
; This macro inserts a custom page using "$CUSTOM_NAME".ini.
; Insert this macro in the list of pages in the order you'd like it to appear.
; CUSTOM_NAME - The name of the ini file (I.E. "MyCustomPage" if the ini is
;               "MyCustomPage.ini".
; CUSTOM_HEADER - The text at the top of the custom page.
; CUSTOM_MESSAGE - The more detailed text for the page.
; ONLEAVE_FUNC - The function to call when leaving the page.  May be "".
!MACRO AvCustomPage CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE ONLEAVE_FUNC
  Page custom ${CUSTOM_NAME}_FUNC ${ONLEAVE_FUNC}
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

  Function ${CUSTOM_NAME}_FUNC
    !INSERTMACRO MUI_HEADER_TEXT "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}"
    !INSERTMACRO MUI_INSTALLOPTIONS_DISPLAY "${CUSTOM_NAME}.ini"
  FunctionEnd
!MACROEND

!ENDIF ;CUSTOM_PAGE_UTILS_IMPORT
