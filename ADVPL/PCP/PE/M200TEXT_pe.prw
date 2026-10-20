#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M200TEXT
PE localizado na função "A200Prompt" da rotina de estruturas
responsável por montar as informacoes que serao apresentadas para cada item na árvore da estrutura.
@author Joni Santos
@since 30/12/2019
@version 1.0
@return cReturn, string, retorna a nova descrição do produto

@type function
/*/
user function M200TEXT()
	Local aArea    := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local cTextOri := ParamIXB[1] // Texto original, já com o TRT e a QTDE adicionados por padrão do sistema
	Local cPai     := ParamIXB[2] // Código do item pai
	Local cTRT     := ParamIXB[3] // Sequencia TRT do item na estrutura
	Local cComp    := ParamIXB[4] // Código do componente que está sendo inserido na árvore
	Local nQuant   := ParamIXB[5] // Quantidade do item na estrutura
	Local cReturn  := ""     	 // retorno do PE

	SB1->(dbSetOrder(1))    
	If SB1->(dbSeek(xFilial("SB1") + cComp, .F.)) // Posiciona no produto para obter sua descrição
		cReturn := Pad(AllTrim(cTextOri) + " " + alltrim(SB1->B1_UM) + " | Tipo: " + alltrim(SB1->B1_TIPO),500) 
	Else
		cReturn := pad(cTextOri,500)   // Retorno do PE
	EndIf
	
	// Restaura as áreas originais
	RestArea(aAreaSB1)
	RestArea(aArea)
Return cReturn // novo texto a ser apresentado na árvore da estrutura