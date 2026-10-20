#include 'totvs.ch'
/*/{Protheus.doc} F150QTDT
PE para verificacao do conteudo da variavel nQtdTotTit
@type function
@version 12.1.33
@author Tiago Faria
@since 17/11/2021
/*/
user function F150QTDT()
	//local nQtdTotTit := PARAMIXB[1]
	//local nGrava := PARAMIXB[2]

	If ExistBlock("BolAntecip")
        oBol := BolAntecip():new()
        //Atualiza o status de todos os pedidos
        oBol:atualizaStatus(/*cNumPV*/)
	endif
return
