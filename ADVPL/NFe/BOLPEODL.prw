#Include 'Protheus.ch'

/*/{Protheus.doc} BOLPEODL
Ponto de entrada que permite incluir componentes visuais na tela de impressão do boleto.

@type function
@author TOTVS IP
@since 	11/09/2023
@param PARAMIXB, Array, Array de 3 posições, sendo elas: 1 = Objeto Dialog; 2 = Array com os Titulos ; 3 = Array com o bloco de código de Impressão e E-mail 
@return nil
/*/
User Function BOLPEODL()
	Local oDlg		:= PARAMIXB[1]
	Local aTitulos	:= PARAMIXB[2]
    local aActions  := PARAMIXB[3]
	local bImprime  := aActions[1]
	local bEmail    := aActions[2]
	
    oDlg:nHeight := 490
	@ 200,245 BUTTON "Imprimir/E-mail" SIZE 50,12 ACTION {|| oDlg:End(), Eval(bImprime) , Eval(bEmail)} PIXEL OF oDlg
Return
