#Include "Protheus.ch"   

User Function MSRFAT01() 	
Local cOpt
Local lAuto := .F.
Local cNum  := ""

//If MsgYesNo("Deseja Enviar Relatório via E-Mail?","Envia E-Mail")
//	cOpt := "mail"
//else
	cOpt := "grafico"
//Endif

If FunName() == "MATA410"
	lAuto := .T.
	cNum  := SC5->C5_NUM
Endif

If cOpt == "mail"
	U_MSRFATHT(lAuto,cNum)
Else
	U_MSRFATGF(lAuto,cNum)
EndIf     

Return