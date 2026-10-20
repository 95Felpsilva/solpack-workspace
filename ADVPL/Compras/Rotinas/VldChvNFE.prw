#include 'totvs.ch'

user function VldChvNFE()
    local lRet      := .t.
    local cChvNF    := M->F1_CHVNFE
    local cUF       := substr(cChvNF,1,2)
    local cAAMM     := subStr(cChvNF,3,4)
    local cCNPJ     := subStr(cChvNF,7,14)
    local cModelo   := subStr(cChvNF,21,2)
    
return lRet
