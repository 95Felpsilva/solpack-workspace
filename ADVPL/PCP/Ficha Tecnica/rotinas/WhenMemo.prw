#include 'totvs.ch'

user function WhenMemo()
    local lRet := .t.

    if readVar() == "M->CZG_VLMEMO" .and. !FwIsInCallStack("SETVALUE")
        FwFldPut("CZG_VLMEMO",u_infFichaTecncia())
        lRet := .f.
    endif
return lRet
