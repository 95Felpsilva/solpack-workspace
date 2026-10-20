#Include "Protheus.ch"


/*/{Protheus.doc} User Function M450FLB
    (long_description)
    @type  Function
    @author Ramão Oliveira
    @since 01/02/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function M450FLB()
    local cData         := dTos(dDataBase)
    local lAplicaFiltro := MsgYesNo('Deseja aplicar o filtro de data de entrega por prazo do produto?','Deseja aplicar filtro de Data Entrega?')
    local cFiltro      := "@ (C9_BLCRED='01' OR C9_BLCRED='04' Or C9_BLCRED = '09' Or C9_BLCRED='80' Or C9_BLCRED='90' or C9_BLCRED='91' or C9_BLCRED='92') And 1=1 "
    
    if lAplicaFiltro
//@ C9_DATENT >= convert(DATE,'" + cData + "',112)  AND     
        cFiltro +=  " AND C9_DATENT <= DATEADD(DAY,COALESCE(( SELECT TOP 1 B1_ZZPE FROM SB1010 SB1 WHERE B1_COD = C9_PRODUTO AND SB1.D_E_L_E_T_ = ' '),30),convert(DATE,'" + cData + "',112))"
    ELSE
        return PARAMIXB[1]
    endif
Return cFiltro

