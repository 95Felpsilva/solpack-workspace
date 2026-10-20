#include 'totvs.ch'
/*/{Protheus.doc} MT680GD3
    É executada no final da função A680GeraD3(), e permite a validação do seu retorno.
    @type  Function
    @author user
    @since 08/09/2020
    @version version
    @return nil
    /*/
user function MT680GD3()
    local lOK := PARAMIXB[4]

    if lOK
        lOK := apontCCIndireto()
    endif
return lOK

static function apontCCIndireto()
    local aArea         := Lj7GetArea({"SD3","CTT","SB1"})
    local cCusto        := SD3->D3_CC
    local cCCIndireto   := getNewPar("ZZ_PREFIND","8") + substr(cCusto,2)
    local aDados        := {}
    local cMOD          := "MOD" + cCCIndireto
    local lExistCTT     := posicione("CTT",1,xFilial("CTT")+cCCIndireto,"!Eof()")
    local lExistSB1     := posicione("SB1",1,xFilial("SB1")+alltrim(cMOD),"!Eof()")
    local lRet          := .t.

    if  lExistCTT .and. lExistSB1 .and. SD3->D3_TIPO == "MO"
        aDados := copyD3()
        //insere a cópia do sd3
        insertD3(aDados)
        //atualiza os campos centro de custo e produto para o centro de custo indireto
        recLock("SD3",.f.)
        SD3->D3_CC      := cCCIndireto
        SD3->D3_COD     := cMOD
        SD3->D3_GRUPO   := SB1->B1_GRUPO
        SD3->D3_LOCAL   := SB1->B1_LOCPAD
        SD3->D3_TIPO    := SB1->B1_TIPO
        SD3->D3_CONTA   := SB1->B1_CONTA
        SD3->(msUnlock())
        a240Atu()//atualiza o campo D3_NUMSEQ
    endif

    Lj7RestArea(aArea)
return lRet

static function copyD3(cAlias)
    local nField    := 0
    local nQtdField := 0
    local aDados    := {}
    local xContent  := nil
    local cField    := ""
    default cAlias  := "SD3"

    nQtdField := (cAlias)->(fCount())

    for nField := 1 to nQtdField
        cField 		:= (cAlias)->(fieldName(nField))
        xContent	:= (cAlias)->&(cField)
        aAdd(aDados,{cField,xContent})
    next nField

return aDados

static function insertD3(aDados,cAlias)
    local cField    := ""
    local xContent  := nil
    local nField    := 0
    default cAlias := "SD3"

    recLock(cAlias,.t.)

    for nField := 1 to len(aDados)
        cField 		:= aDados[nField,1]
        xContent	:= aDados[nField,2]

        (cAlias)->&(cField) := xContent
    next nField

    (cAlias)->(msUnlock())
return
