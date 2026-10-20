#include "rwmake.ch"

user Function numSeq()
      
    Local _cRet := ""
    
    _cRet := alltrim(getmv("MV_NUMSEQB"))
    
    if !empty(_cRet)
        PUTMV("MV_NUMSEQB",strzero((val(_cRet)+1),5))
    endif
Return(_cRet)
