#include 'totvs.ch'

#Define OPC_INCLUIR 3
#Define OPC_ALTERAR 4
#Define OPC_COPIAR 6

/*/{Protheus.doc} M410STTS
PE após a gravação do pedido de vendas
@type function
@version 12.1.33
@author Tiago Faria
@since 03/11/2021
/*/
user function M410STTS()
    local nOper := PARAMIXB[1]

    if nOper == OPC_INCLUIR .or. nOper == OPC_ALTERAR .or. nOper == OPC_COPIAR
        FWMsgRun( ,{||BolAntecip():gerar() },"M410STTS", "Aguarde gerando o boleto..."  )    
    endif
return
