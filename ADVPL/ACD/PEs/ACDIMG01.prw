#include "protheus.ch"

/*/{Protheus.doc} Img01
Ponto de entrada referente a impressão de etiquetas de identificação do produto.

@author 		Julio Lisboa - FSW TOTVS IP Campinas
@since 			17/07/2015
@return 		nil

/*/
User Function Img01()   
/*
	
	Local aAreaAtu	:= GetArea()
	Local aAreaCB0	:= CB0->(GetArea())
	Local aAreaSH6	:= SH6->(GetArea())
	
	Local cTextoLogo	:= IIF(cFilAnt == "0101","SOLPACK","AGRONET")
	Local cCodigo
	Local nI			:= 0
	Local lImpCabec	:= .F.
	Local lImprime	:= .F.
	Local lReimpres	:= .F.
	Local nRecno		:= 0
	Local nQuantTotal	:= 0
	Local nTipo		:= 4
	
	Private nqtde 	:= 	iif( Len(ParamIxb) >= 01 , ParamIxb[01] , Nil )
	Private cCodSep 	:=  iif( Len(ParamIxb) >= 02 , ParamIxb[02] , Nil )
	Private cCodID 	:=	iif( Len(ParamIxb) >= 03 , ParamIxb[03] , Nil )
	Private nCopias	:= 	iif( Len(ParamIxb) >= 04 , ParamIxb[04] , 0   )
	Private cNFEnt  	:= 	iif( Len(ParamIxb) >= 05 , ParamIxb[05] , Nil )
	Private cSerie  	:= 	iif( Len(ParamIxb) >= 06 , ParamIxb[06] , Nil )
	Private cFornec  	:= 	iif( Len(ParamIxb) >= 07 , ParamIxb[07] , Nil )
	Private cLojafo  	:= 	iif( Len(ParamIxb) >= 08 , ParamIxb[08] , Nil )
	Private cArmazem 	:= 	iif( Len(ParamIxb) >= 09 , ParamIxb[09] , Nil )
	Private cOP      	:= 	iif( Len(ParamIxb) >= 10 , ParamIxb[10] , Nil )
	Private cNumSeq  	:= 	iif( Len(ParamIxb) >= 11 , ParamIxb[11] , Nil )
	Private cLote    	:= 	iif( Len(ParamIxb) >= 12 , ParamIxb[12] , Nil )
	Private cSLote   	:= 	iif( Len(ParamIxb) >= 13 , ParamIxb[13] , Nil )
	Private dValid   	:= 	iif( Len(ParamIxb) >= 14 , ParamIxb[14] , Nil )
	Private cCC  	   	:= 	iif( Len(ParamIxb) >= 15 , ParamIxb[15] , Nil )
	Private cLocOri  	:= 	iif( Len(ParamIxb) >= 16 , ParamIxb[16] , Nil )
	Private cOPREQ   	:= 	iif( Len(ParamIxb) >= 17 , ParamIxb[17] , Nil )
	Private cNumSerie	:= 	iif( Len(ParamIxb) >= 18 , ParamIxb[18] , Nil )
	Private cOrigem  	:= 	iif( Len(ParamIxb) >= 19 , ParamIxb[19] , Nil )
	Private cEndereco	:= 	iif( Len(ParamIxb) >= 20 , ParamIxb[20] , Nil )
	Private cPedido  	:= 	iif( Len(ParamIxb) >= 21 , ParamIxb[21] , Nil )
	Private nResto   	:= 	iif( Len(ParamIxb) >= 22 , ParamIxb[22] , 0   )
	Private cItNFE   	:= 	iif( Len(ParamIxb) >= 23 , ParamIxb[23] , Nil )
	
	cLocOri := iif( cLocOri==cArmazem,' ',cLocOri)
	nQtde   := iif( nQtde==Nil,SB1->B1_QE,nQtde)
	cCodSep := iif( cCodSep==Nil,'',cCodSep)
	
	If nResto > 0
		nCopias++
	EndIf
	
	For nI := 1 to nCopias
		//tratativa para ajustar a quantidade
		If nI == nCopias .and. nResto > 0
			nQtde := nResto
		EndIf
		
		If cCodID <> Nil
			//Retorna a etiqueta selecionada
			CBRetEti(cCodID)
			cCodigo := cCodID
			nRecno 	:= CB0->CB0_ZZREC
			lReimpres := .T.
		Else
			//Se usa CB0, gera etiqueta
			If Usacb0("01")
				cCodigo := CBGrvEti("01",{SB1->B1_COD,nQtde,cCodSep,cNFEnt,cSerie,cFornec,cLojafo,cPedido,cEndereco,cArmazem,cOp,cNumSeq,Nil,Nil,Nil,cLote,cSLote,dValid,cCC,cLocOri,Nil,cOPReq,cNumserie,cOrigem,cItNFE})
			Else
				cCodigo := SB1->B1_CODBAR
			EndIf
		EndIf
		
		cCodigo := AllTrim(cCodigo)

		//Se for apontamento, imprime as etiquetas
		If FunName() == "MATA681" .and. !lReimpres
			RecLock("CB0",.F.)
			CB0->CB0_ZZREC := SH6->(Recno())
			CB0->(MsUnlock())
			nTipo := 1
		EndIf

		//Se foi a primeira impressão, abre a tela de parâmetros
		If nI == 1
			If trataParametros(@lImpCabec,@cTextoLogo)
				lImprime := .T.
			EndIf
		EndIf
			
		If lImprime
			
			U_valImpEt(cCodigo,1,lImpCabec,nTipo,cTextoLogo)
		EndIf
		
		//Realiza a reimpressão da etiqueta
		If lReimpres .and. nRecno <> 0
			//Posiciona na SH6
			SH6->(DbSetOrder(1))
			SH6->(DbGoTo(nRecno))
			
			//Define se será impresso o cabeçalho na reimpressão via coletor
			lImpCabec := GetNewPar("ZZ_RIMPCAB",.T.)
			
			U_valImpEt(cCodigo,1,lImpCabec,1)
		EndIf
	Next
	
	RestArea(aAreaSH6)
	RestArea(aAreaCB0)
	RestArea(aAreaAtu)
*/
Return

/*/{Protheus.doc}	trataParametros
Trata os parâmetros para impressão da etiqueta

@author				Julio Lisboa - FSW TOTVS IP Campinas
@since					14/07/2015
@return				lRet
/*/
Static Function trataParametros(lImpCabec,cTextoLogo)
	
	Local lRet			:= .F.
	Local aParambox	:= {}
	
	Local cMVPAR01	:= MV_PAR01
	Local cMVPAR02	:= MV_PAR02
	Local cMVPAR03	:= MV_PAR03
	
	Aadd(aParambox,{2,"Imprime dados da Solpack"	,"1",{"SIM","NAO"},50,,.T.})// MV_PAR01
	Aadd(aParambox,{1,"Local de Impressao"	,Space(TamSX3("CB5_CODIGO")[1]),"","",	"CB5","",60,.F.})// MV_PAR02
	Aadd(aParambox,{2,"Logo"	,"1",{cTextoLogo,IIF(cTextoLogo == "SOLPACK","AGRONET","SOLPACK")},60,,.F.})// MV_PAR03
	
	//Verifica se o usuário vai ou não imprimir
	If ParamBox(aParambox,"IMPRESSÃO ETIQUETA ACD",,,,,,,,"ETQACD",.T.,.T.)
		If MV_PAR01 == "SIM"
			lImpCabec		:= .T.
		EndIf
		
		//Seta o local de impressão
		If !Empty(MV_PAR02)
			If !CB5SetImp(MV_PAR02)
				MsgStop("Problemas no local de impressão!")
				return
			EndIf
		EndIf
		
		If !Empty(MV_PAR03)
			cTextoLogo := AllTrim(MV_PAR03)
		EndIf
		
		MV_PAR01 := cMVPAR01
		MV_PAR02 := cMVPAR02
		MV_PAR03 := cMVPAR03
		
		lRet := .T.
	EndIf
	
Return (lRet)
