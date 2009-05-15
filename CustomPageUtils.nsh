;c-style prevention of duplicate imports.
!IFNDEF CUSTOM_PAGE_UTILS_IMPORT
!DEFINE CUSTOM_PAGE_UTILS_IMPORT "yup"
!INCLUDE "nsDialogs.nsh"

;------------------------------------------------------------------------------
; This contains utility macros/functions for simplifying the creation of custom
; installer pages.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a control (such as a text box).
; This must be called before beginning the EasyCustomPage.
; This variable will be checked and a trailing '\' will be chopped off if
; present (this allows your config file to have values like "@PATH_TOKEN@\test.txt"
; without worrying that the guy installing will append "\" to the token and you'll get
; "c:\blah\\test.txt".
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
!MACRO CreateEasyCustomDirPathVar VAR_NAME
  !INSERTMACRO CreateEasyCustomTextVar "${VAR_NAME}" "!INSERTMACRO EnsureEndsWithout $${VAR_NAME} '\'"
!MACROEND

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a control (such as a text box).
; This must be called before beginning the EasyCustomPage.
; This variable will be checked and a trailing '/' will be chopped off if
; present (this allows your config file to have values like "@URL_TOKEN@/test.html"
; without worrying that the guy installing will append "/" to the token and you'll get
; "http://blah.com//test.html".
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
!MACRO CreateEasyCustomURLVar VAR_NAME
  !INSERTMACRO CreateEasyCustomTextVar "${VAR_NAME}" "!INSERTMACRO EnsureEndsWithout $${VAR_NAME} '/'"
!MACROEND

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a control (such as a text box).
; This must be called before beginning the EasyCustomPage.
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
; VERIFICATION_CALL - A macro that will be inserted inline.  May be blank, but if
;                     non-blank, should be a block of valid NSIS code.  For
;                     example, it could be "!INSERTMACRO EnsureEndsWith $MY_VAR '\'"
!MACRO CreateEasyCustomTextVar VAR_NAME VERIFICATION_CALL
  !INSERTMACRO CreateEasyCustomVar "${VAR_NAME}" \
        "System::Call user32::GetWindowText(i$${VAR_NAME}_CONTROL,t.r0,i${NSIS_MAX_STRLEN})" \
        "${VERIFICATION_CALL}"
!MACROEND

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a check box control.
; This must be called before beginning the EasyCustomPage.
; According to the developer (from the NSIS forums):
; "If [the value] is 0, it's unchecked.  If it's 1, it's checked.
;  Anything else is an intermediate state."
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
!MACRO CreateEasyCustomCheckBoxVar VAR_NAME
  !INSERTMACRO CreateEasyCustomVar "${VAR_NAME}" \
        "SendMessage $${VAR_NAME}_CONTROL ${BM_GETCHECK} 0 0 $0" \
        ""
!MACROEND

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a list box control.
; This must be called before beginning the EasyCustomPage.
; The value will be the index of the currently selected list item, or -1 if
; no value is selected.
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
!MACRO CreateEasyCustomListBoxVar VAR_NAME
  !INSERTMACRO CreateEasyCustomVar "${VAR_NAME}" \
        "SendMessage $${VAR_NAME}_CONTROL ${LB_GETCURSEL} 0 0 $0" \
        ""
!MACROEND

;------------------------------------------------------------------------------
; Starts a custom page.  After calling this, you add controls (by calling
; macros like EasyCustomTextBox) and when complete, call EasyCustomPageEnd.
;
; CUSTOM_NAME - A custom name that must be unique, and should be simple with no
;               spaces or punctuation.  It is used to define functions and things.
; CUSTOM_HEADER - The text in the title bar of the custom page.
; CUSTOM_MESSAGE - The more detailed text in the top section of the page.
!MACRO EasyCustomPageBegin CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE
  !INSERTMACRO EasyCustomPageWithPrePostBegin "${CUSTOM_NAME}" "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}" "" ""
!MACROEND

;------------------------------------------------------------------------------
; Like EasyCustomPageBegin, but calls the ON_ENTER_FUNC before displaying the page.
;
; CUSTOM_NAME - A custom name that must be unique, and should be simple with no
;               spaces or punctuation.  It is used to define functions and things.
; CUSTOM_HEADER - The text in the title bar of the custom page.
; CUSTOM_MESSAGE - The more detailed text in the top section of the page.
; ON_ENTER_FUNC - The function to call when entering the page.  May be "".
; ON_LEAVE_FUNC - The function to call when leaving the page.  May be "".
!MACRO EasyCustomPageWithPreBegin CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE ON_ENTER_FUNC
  !INSERTMACRO EasyCustomPageWithPrePostBegin "${CUSTOM_NAME}" "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}" "${ON_ENTER_FUNC}" ""
!MACROEND

;------------------------------------------------------------------------------
; Like EasyCustomPageBegin, but calls the ON_LEAVE_FUNC when leaving the page.
;
; CUSTOM_NAME - A custom name that must be unique, and should be simple with no
;               spaces or punctuation.  It is used to define functions and things.
; CUSTOM_HEADER - The text in the title bar of the custom page.
; CUSTOM_MESSAGE - The more detailed text in the top section of the page.
; ON_LEAVE_FUNC - The function to call when leaving the page.  May be "".
!MACRO EasyCustomPageWithPostBegin CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE ON_LEAVE_FUNC
  !INSERTMACRO EasyCustomPageWithPrePostBegin "${CUSTOM_NAME}" "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}" "" "${ON_LEAVE_FUNC}"
!MACROEND

;------------------------------------------------------------------------------
; Like EasyCustomPageBegin, but calls the ON_ENTER_FUNC before displaying the page,
; and calls ON_LEAVE_FUNC when leaving the page.
;
; CUSTOM_NAME - A custom name that must be unique, and should be simple with no
;               spaces or punctuation.  It is used to define functions and things.
; CUSTOM_HEADER - The text in the title bar of the custom page.
; CUSTOM_MESSAGE - The more detailed text in the top section of the page.
; ON_ENTER_FUNC - The function to call when entering the page.  May be "".
; ON_LEAVE_FUNC - The function to call when leaving the page.  May be "".
!MACRO EasyCustomPageWithPrePostBegin CUSTOM_NAME CUSTOM_HEADER CUSTOM_MESSAGE ON_ENTER_FUNC ON_LEAVE_FUNC
  Page custom ${CUSTOM_NAME}_CustomPage ${ON_LEAVE_FUNC}
  Function ${CUSTOM_NAME}_CustomPage
    ; Call the ON_ENTER function if there is one.
    !IF "${ON_ENTER_FUNC}" != ""
      Call ${ON_ENTER_FUNC}
    !ENDIF

    ; Save the variables we'll be changing.
    push $0
    push ${AV_EASY_X}
    push ${AV_EASY_Y}

    !INSERTMACRO MUI_HEADER_TEXT "${CUSTOM_HEADER}" "${CUSTOM_MESSAGE}"

    ; Start the fields slightly below the top, so there's room to line things up.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} 0 + 5

    nsDialogs::Create /NOUNLOAD 1018
    pop $0 ; pop the handle to the dialog, which we don't use for anything.
!MACROEND

;------------------------------------------------------------------------------
; This macro inserts a custom page using "$CUSTOM_NAME".ini.
; Insert this macro in the list of pages in the order you'd like it to appear.
;
; The initial value for this control can be set by setting the value of
; the VAR_NAME variable any time before the page is displayed (such as in
; .onInit or .onVerifyInstDir).
;
; VAR_NAME   - The NAME of the variable that will have the value from this control
;              stored in it.  In other words, if you want to use a variable called
;              $MY_VAR, you should pass the STRING "MY_VAR".  This variable must
;              have been declared by calling CreateEasyCustomVar.
; LABEL_TEXT - The label to display to the left of the text box.
!MACRO EasyCustomTextBox VAR_NAME LABEL_TEXT
    Push $0
    ; Create the label.
    !INSERTMACRO EasyCustomLineLabel "${LABEL_TEXT}"

    ; To make it line up correctly, the text box has to be slightly higher than the label.
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} - 2

    ; Note on the below code:  We're being all fancy and confusing by using
    ; "$${VAR_NAME} to refer to the variable.  Since ${VAR_NAME} is a macro
    ; containing a string ("MY_VAR" for example), adding an extra $ in front
    ; means that after the macro substitution, we have a variable reference.
    ; $${VAR_NAME} becomes $MY_VAR

    ; Create the text box.
    ${NSD_CreateText} ${AV_EASY_X}u ${AV_EASY_Y}u 220u 12u $${VAR_NAME}

    ; Pop the handle to the text box into the control variable.
    Pop $${VAR_NAME}_CONTROL

    ; Connect the OnChange function to the control
    GetFunctionAddress $0 OnChange_${VAR_NAME}
    nsDialogs::OnChange /NOUNLOAD $${VAR_NAME}_CONTROL $0
    
    ; reset X/Y for the next line.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 15
    Pop $0
!MACROEND

;------------------------------------------------------------------------------
; This macro adds a file path request text box to an easy custom page.
;
; In the future this will have fancy features like autocompletion and a browse button.
;
; The initial value for this control can be set by setting the value of
; the VAR_NAME variable any time before the page is displayed (such as in
; .onInit or .onVerifyInstDir).
;
; VAR_NAME   - The NAME of the variable that will have the value from this control
;              stored in it.  In other words, if you want to use a variable called
;              $MY_VAR, you should pass the STRING "MY_VAR".  This variable must
;              have been declared by calling CreateEasyCustomVar.
; LABEL_TEXT - The label to display to the left of the text box.
!MACRO EasyCustomFilePath VAR_NAME LABEL_TEXT
    Push $0
    ; Create the label.
    !INSERTMACRO EasyCustomLineLabel "${LABEL_TEXT}"

    ; To make it line up correctly, the text box has to be slightly higher than the label.
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} - 2

    ; Note on the below code:  We're being all fancy and confusing by using
    ; "$${VAR_NAME} to refer to the variable.  Since ${VAR_NAME} is a macro
    ; containing a string ("MY_VAR" for example), adding an extra $ in front
    ; means that after the macro substitution, we have a variable reference.
    ; $${VAR_NAME} becomes $MY_VAR

    ; Create the "File Request" text box.
    ${NSD_CreateFileRequest} ${AV_EASY_X}u ${AV_EASY_Y}u 220u 12u $${VAR_NAME}

    ; Pop the handle to the text box into the control variable.
    Pop $${VAR_NAME}_CONTROL

    ; Connect the OnChange function to the control
    GetFunctionAddress $0 OnChange_${VAR_NAME}
    nsDialogs::OnChange /NOUNLOAD $${VAR_NAME}_CONTROL $0

    ; Autocomplete while they're typing!
    System::Call shlwapi::SHAutoComplete(i$${VAR_NAME}_CONTROL,i${SHACF_FILESYSTEM})

    ; reset X/Y for the next line.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 15
    Pop $0
!MACROEND
; No idea what this means, but apparently it's needed for autocomplete to work.
!DEFINE SHACF_FILESYSTEM 1

;------------------------------------------------------------------------------
; This macro adds a list box to an easy custom page.
;
; The initial value for this control can be set by setting the value of
; the VAR_NAME variable any time before the page is displayed (such as in
; .onInit or .onVerifyInstDir).
;
; VAR_NAME   - The NAME of the variable that will have the value from this control
;              stored in it.  In other words, if you want to use a variable called
;              $MY_VAR, you should pass the STRING "MY_VAR".  This variable must
;              have been declared by calling CreateEasyCustomListBoxVar.
; LABEL_TEXT - The label to display above the list box.
; HEIGHT     - How tall to make the box (8 per line + 3 for overhead)
!MACRO EasyCustomListBox VAR_NAME LABEL_TEXT HEIGHT
    Push $0
    ; Create the label.
    ${NSD_CreateLabel} ${AV_EASY_X}u ${AV_EASY_Y}u 300u 10u "${LABEL_TEXT}"
    pop $0 ; don't use the label for anything, just take it off the stack.

    ; We're putting the next control below it.
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 12

    ; Note on the below code:  We're being all fancy and confusing by using
    ; "$${VAR_NAME} to refer to the variable.  Since ${VAR_NAME} is a macro
    ; containing a string ("MY_VAR" for example), adding an extra $ in front
    ; means that after the macro substitution, we have a variable reference.
    ; $${VAR_NAME} becomes $MY_VAR

    ; Create the list box.  The current ${NSD_CreateListBox} macro doesn't
    ; allow OnChange notification, so we have to manually add it with LBS_NOTIFY.
    ; This supposedly will be fixed in a future release.
    nsDialogs::CreateItem /NOUNLOAD ${__NSD_ListBox_CLASS} ${__NSD_ListBox_STYLE}|${LBS_NOTIFY} ${__NSD_ListBox_EXSTYLE} ${AV_EASY_X}u ${AV_EASY_Y}u 300u ${HEIGHT}u ""

    ; Pop the handle to the text box into the control variable.
    Pop $${VAR_NAME}_CONTROL

    ; Connect the OnChange function to the control
    GetFunctionAddress $0 OnChange_${VAR_NAME}
    nsDialogs::OnChange /NOUNLOAD $${VAR_NAME}_CONTROL $0

    ; reset X/Y for the next line.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + ${HEIGHT}
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 3 ; small gap before next control.
    Pop $0
!MACROEND

;------------------------------------------------------------------------------
; This macro adds a list box entry to a list box.
; The default selected row in the list box may be set ahead of time by setting
; the list box variable, however it can't actually be selected until you've
; added at least that many rows to the box.
;
; VAR_NAME   - The NAME of the variable for the list box you're adding this entry
;              to.  In other words, if you want to use a variable called
;              $MY_VAR, you should pass the STRING "MY_VAR".  This variable must
;              have been declared by calling CreateEasyCustomListBoxVar.
; LABEL_TEXT - The label to display above the list box.
; HEIGHT     - How tall to make the box (8 per line + 3 for overhead)
!MACRO EasyCustomListBoxEntry VAR_NAME ENTRY
    Push $0
    SendMessage $${VAR_NAME}_CONTROL ${LB_ADDSTRING} 0 "STR:${ENTRY}"
    ; Try to assign the initial value.  This can't be done until the value is
    ; actually added to the box, so we try each time we add a value.
    ${IF} $${VAR_NAME} >= 0
      SendMessage $${VAR_NAME}_CONTROL ${LB_SETCURSEL} $${VAR_NAME} 0 $0
    ${ENDIF}
    Pop $0
!MACROEND

;------------------------------------------------------------------------------
; This macro adds a check box to an easy custom page.
;
; The initial value for this control can be set by setting the value of
; the VAR_NAME variable any time before the page is displayed (such as in
; .onInit or .onVerifyInstDir).  1 = checked, 0 = unchecked.
;
; VAR_NAME   - The NAME of the variable that will have the value from this control
;              stored in it.  In other words, if you want to use a variable called
;              $MY_VAR, you should pass the STRING "MY_VAR".  This variable must
;              have been declared by calling CreateEasyCustomCheckBoxVar.
; LABEL_TEXT - The label to display to the right of the check box.
!MACRO EasyCustomCheckBox VAR_NAME LABEL_TEXT
    Push $0
    ; Indent the checkbox slightly from the left.
    IntOp ${AV_EASY_X} ${AV_EASY_X} + 5

    ; Create the check box
    ${NSD_CreateCheckBox} ${AV_EASY_X}u ${AV_EASY_Y}u 220u 12u "${LABEL_TEXT}"

    ; Note on the below code:  We're being all fancy and confusing by using
    ; "$${VAR_NAME} to refer to the variable.  Since ${VAR_NAME} is a macro
    ; containing a string ("MY_VAR" for example), adding an extra $ in front
    ; means that after the macro substitution, we have a variable reference.
    ; $${VAR_NAME} becomes $MY_VAR

    ; Pop the handle to the text box into the control variable.
    Pop $${VAR_NAME}_CONTROL

    ; Set the control based on the current value of the variable.
    ${IF} $${VAR_NAME} = 1
      SendMessage $${VAR_NAME}_CONTROL ${BM_SETCHECK} 1 0 $0
    ${ENDIF}

    ; Connect the OnClick function to the control
    GetFunctionAddress $0 OnChange_${VAR_NAME}
    nsDialogs::OnClick /NOUNLOAD $${VAR_NAME}_CONTROL $0

    ; reset X/Y for the next line.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 15
    Pop $0
!MACROEND

;------------------------------------------------------------------------------
; Displays a full-width label.
;
; LABEL_TEXT - The text for the label
; HEIGHT     - How tall to make the label (8 per line + 2 for overhead)
!MACRO EasyCustomLabel LABEL_TEXT HEIGHT
    Push $0
    ; Create the label.
    ${NSD_CreateLabel} ${AV_EASY_X}u ${AV_EASY_Y}u 300u ${HEIGHT}u "${LABEL_TEXT}"
    pop $0 ; don't use the label for anything, just take it off the stack.

    ; reset X/Y for the next line.
    IntOp ${AV_EASY_X} 0 + 0
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + ${HEIGHT}
    IntOp ${AV_EASY_Y} ${AV_EASY_Y} + 3 ; small gap before next control.
    Pop $0
!MACROEND


;------------------------------------------------------------------------------
; This macro completes an easy custom page.  It should be called after you've
; added all the controls to the page.
!MACRO EasyCustomPageEnd
    ; Restore original values.
    pop ${AV_EASY_Y}
    pop ${AV_EASY_X}
    pop $0

    ; Display the page.
    nsDialogs::Show
  FunctionEnd
!MACROEND

;------------------------------------------------------------------------------
; This is a "private" macro -- intended just for use by the other macros in this file.
; It creates a label with a width of 80 and moves AV_EASY_X over 80 so the next
; control will be next to the label.
;
; LABEL_TEXT - The text for the label
!MACRO EasyCustomLineLabel LABEL_TEXT
    Push $0
    ; Create the label.
    ${NSD_CreateLabel} ${AV_EASY_X}u ${AV_EASY_Y}u 80u 10u "${LABEL_TEXT}"
    pop $0 ; don't use the label for anything, just take it off the stack.

    ; We're putting the next control over to the right.
    IntOp ${AV_EASY_X} ${AV_EASY_X} + 80
    Pop $0
!MACROEND

;------------------------------------------------------------------------------
; Creates a variable that will be mapped to a control (such as a text box).
; Another "private" macro, intended for use by the other CreateEasyCustomXXXVar
; macros.
;
; VAR_NAME - The NAME of the variable that will be created and used.  In other
;            words, if you want to create a variable called $MY_VAR, you should
;            pass the STRING "MY_VAR".
; GET_VALUE_CALL - A macro that will be inserted inline, should put the value
;                  from the control into $0.
; VERIFICATION_CALL - A macro that will be inserted inline.  May be blank, but if
;                     non-blank, should be a block of valid NSIS code.  For
;                     example, it could be "!INSERTMACRO EnsureEndsWith $MY_VAR '\'"
!MACRO CreateEasyCustomVar VAR_NAME GET_VALUE_CALL VERIFICATION_CALL
  ; Define the variable
  Var ${VAR_NAME}
  ; Define a variable that will hold the control ID / handle / whatever.
  Var ${VAR_NAME}_CONTROL
  ; Define an OnChange function that will be called by the control to set
  ; the variable whenever the user changes the value in the control.
  Function OnChange_${VAR_NAME}
    Push $0 ; save old val

    ; Note on the below code:  We're being all fancy and confusing by using
    ; "$${VAR_NAME} to refer to the variable.  Since ${VAR_NAME} is a macro
    ; containing a string ("MY_VAR" for example), adding an extra $ in front
    ; means that after the macro substitution, we have a variable reference.
    ; $${VAR_NAME} becomes $MY_VAR

    ; This puts the value into $0.
    ${GET_VALUE_CALL}
    StrCpy $${VAR_NAME} $0
    Pop $0 ; restore old val
    ${VERIFICATION_CALL}
  FunctionEnd
!MACROEND

; Define these to make the code more readable.  Should not be referenced
; outside this file.
!DEFINE AV_EASY_X $R5
!DEFINE AV_EASY_Y $R6

!ENDIF ;CUSTOM_PAGE_UTILS_IMPORT
