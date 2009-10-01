;c-style prevention of duplicate imports.
!IFNDEF SECTION_MANAGEMENT_IMPORT
!DEFINE SECTION_MANAGEMENT_IMPORT "yup"

; This is thanks to the NSIS wiki:
; http://nsis.sourceforge.net/Managing_Sections_on_Runtime
;
; Define IDs for your sections like so:
;
;   Section "My Section" SECTION_ID
;     ...
;   SectionEnd
; 
; And use them like this:
;
;    ${SelectSection} ${SECTION_ID}

;!define SF_USELECTED  0
;!define SF_SELECTED   1
;!define SF_SECGRP     2
;!define SF_BOLD       8
;!define SF_RO         16
;!define SF_EXPAND     32
###############################
 
!macro SecSelect SecId
  Push $0
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SecId} $0
  SectionSetInstTypes ${SecId} 1
  Pop $0
!macroend
 
!define SelectSection '!insertmacro SecSelect'
#################################
 
!macro SecUnSelect SecId
  Push $0
  IntOp $0 ${SF_USELECTED} | ${SF_RO}
  SectionSetFlags ${SecId} $0
  SectionSetText  ${SecId} ""
  Pop $0
!macroend
 
!define UnSelectSection '!insertmacro SecUnSelect'
###################################
 
!macro SecExtract SecId
  Push $0
  IntOp $0 ${SF_USELECTED} | ${SF_RO}
  SectionSetFlags ${SecId} $0
  SectionSetInstTypes ${SecId} 2
  Pop $0
!macroend
 
!define SetSectionExtract '!insertmacro SecExtract'
###################################
 
!macro Groups GroupId
  Push $0
  SectionGetFlags ${GroupId} $0
  IntOp $0 $0 | ${SF_RO}
  IntOp $0 $0 ^ ${SF_BOLD}
  IntOp $0 $0 ^ ${SF_EXPAND}
  SectionSetFlags ${GroupId} $0
  Pop $0
!macroend
 
!define SetSectionGroup "!insertmacro Groups"
####################################
 
!macro GroupRO GroupId
  Push $0
  IntOp $0 ${SF_SECGRP} | ${SF_RO}
  SectionSetFlags ${GroupId} $0
  Pop $0
!macroend
 
!define MakeGroupReadOnly '!insertmacro GroupRO'

!ENDIF ;SECTION_MANAGEMENT_IMPORT
