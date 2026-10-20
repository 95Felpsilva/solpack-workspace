#include 'Totvs.ch'

user function tstInfFichaTecnica()
    rpcClearEnv()
    RPCSetEnv("01", "01", "admin", "8219")

    POSICIONE("CZB",1,XFILIAL("CZB")+"0000000042","CZB_NMAB")
    u_infFichaTecncia()
return
/*/{Protheus.doc} infFichaTecncia
Tela para facilitar o preenchimento de campos memo
@type function
@author Tiago Faria
@since 19/01/2021
/*/
user function infFichaTecncia()
    local oDlg		:= nil
    local oGrid		:= nil
    local oCol		:= nil
    local bOK		:= {||oDlg:end()}
    local bCancel	:= {||oDlg:end()}
    local aButtons	:= {}
    local nLine		:= 0
    local aColumns  := {}
    local nColumn   := 0
    local cMemo     := ""
    private cChar   := "|"

    aColumns := strToKarr(CZB->CZB_DSAB,cChar)

    aCoords := {0,0,600,1200}

    Define MsDialog oDlg Title "Ficha técnica - MEMO"  From aCoords[1], aCoords[2] to aCoords[3], aCoords[4] Pixel

    oGrid := IpGridObject():newIpGridObject(0,0,0,0, oDlg)

    for nColumn := 1 to len(aColumns)

        cTitle  := alltrim(aColumns[nColumn])
        cID     := "col" + cValToChar(nColumn)

        oCol := IpColumnObject():newIpColumnObject(cID	, cTitle, "C", 20,0)
        oGrid:addColumn(oCol)

    next nColumn

    oGrid:create()
    oGrid:getGrid():oBrowse:align := CONTROL_ALIGN_ALLCLIENT

    Activate MsDialog oDlg Center on init EnchoiceBar( oDlg, bOK,bCancel,,aButtons)

    for nLine := 1 to oGrid:length()
        if !oGrid:isDeletedLine(nLine)
            aColumns := oGrid:getColumns()

            for nColumn := 1 to len(aColumns)
                oCol := aColumns[nColumn]
                cMemo += alltrim(oGrid:getValue(oCol:getID(),nLine))

                if nColumn < len(aColumns)
                    cMemo += cChar
                endif
            next nColumn
            if nLine < oGrid:length()
                cMemo += CRLF
            endif
        endif
    next nLine

    freeobj(oGrid)
return cMemo
