#Include "Protheus.ch"
#include "rwmake.ch"
#Include "Topconn.ch"

/*###############################################################
#																#
#	FUNCAO TSTTOLSP - RODRIGO T J PAIVA							#
#	RTJPAIVA@GMAIL.COM - 15/09/2015								#
#																#
###############################################################*/

User Function TsTTolSP()
Local xx
Local cText    := Space(15)
Local bAcao    := {|lFim| LeE_peso(@lFim) }
Local cTitulo  := 'Aguardando leitura da balança...'
Local cMsg     := 'Peso ... '
Local lOpen	 := .F.
Public lAborta := .T.
Private cPeso  := Space(30)
Private nPeso  := 0
Private nHdll  := 0

If(&(ReadVar()) > 0)
	Return(&(ReadVar()))
EndIf

lOpen := MSOpenPort(@nHdll,"COM1:9600,n,8,1")

If !lOpen
	Return (0)
EndIf

xx := MsRead(nHdll,@cText)
If !xx
	Alert("Nao foi possivel pegar informações da porta")
	MsClosePort(nHdll)
	Return(0)
Else
	Processa( bAcao, cTitulo,cMsg, lAborta )
EndIf
MsClosePort(nHdll)

If nPeso < 1
	Alert("Verifique se o peso da balança está correto, caso esteja incorreto estabilize o peso e realize nova pesagem!")
EndIf

Return(nPeso)

/*###############################################################
#																#
#	FUNCAO LEE_PESO												#
#																#	
###############################################################*/

Static Function LeE_peso(lFim)
Local lEnd    		:= .F.
Local nCont	  		:= 0
Local nVezes  		:= 0
Local cTesteX 		:= ""
Local cRemoteip     :=  Getclientip()
Private cText 		:= Space(15)          

ProcRegua(1000)
While !lEnd
	If((lFim) .OR. (nVezes > 1000))
		Return(.F.)
	EndIf
	
	MsRead(nHdll,@cText)
	nVezes ++
	cTesteX += cText
	
	//cText := "3sh001046000030"
	If At("3qh", cTesteX) > 0 .AND. Len(ALLTRIM(Substr(cTesteX, At("3qh", cTesteX)+3, 6))) == 6
		cTemp := Substr(cTesteX, At("3qh", cTesteX)+3, 10)
		nTemp := Val(cTemp) / 100000
		cTemp := Alltrim(Transform(nTemp,"@E 999,999,999.99 Kg"))
		
		If(nTemp > 0)
			cPeso := cTemp
			nPeso := nTemp
			lEnd  := .T.
			cTesteX := ""
		EndIf
			IncProc("Peso Liquido na Balança: " + cTemp)

	EndIf
	
	If !lAborta
		Return(.F.)
	EndIf
	IncProc()
EndDo

Return(lEnd)

/*###############################################################
#																#
#	FUNCAO VERUM - RODRIGO T J PAIVA							#
#	RTJPAIVA@GMAIL.COM - 15/09/2015								#
#																#
###############################################################*/

User Function VerUm()
Local _cQuery := ""
Local lRet := .F.
	
	_cQuery := "SELECT * FROM SB1010 SB1 "
	_cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
	_cQuery += " AND SB1.B1_COD = '"+M->H6_PRODUTO+"' "
	
	_cQuery := ChangeQuery(_cQuery)
	
//---------------------------------------------------------------------------------------------------------------
//CASO O ARQUIVO EXISTA E ESTEJA ABERTO
If(Select("QRY") <> 0)
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"QRY",.T.,.T.)
aStru := dbStruct()
//---------------------------------------------------------------------------------------------------------------
dbSelectArea("QRY")
While !QRY->(EOF())
	If QRY->B1_UM == 'KG'
	lRet := .T.
	Else
	lRet := .F.
	EndIf
	
	QRY->(dbSkip())
EndDo

Return(lRet)

/*###############################################################
#																#
#	FUNCAO VBALA - RODRIGO T J PAIVA							#
#	RTJPAIVA@GMAIL.COM - 15/09/2015								#
#																#
###############################################################*/

User Function VBala
	Local lRet	:= .T.
	Local lVal	:= GetMv('ZZ_XUSABAL')

	If lVal
		If M->H6_QTDPRO2 > 0
			MsgBox("O uso da balança é obrigatório, informe peso '0' para poder prosseguir!!!","Programa: VBala","STOP")
			lRet := .F.
		EndIf
	EndIf  

Return(lRet)