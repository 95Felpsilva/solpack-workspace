#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Font.ch"
#Include "Colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSE125F ºAutor  ³Donizete            º Data ³  07/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ A função deste programa é retirar o flag de contabilização º±±
±±º          ³ de registros do SE1/SE2/SE5.                               º±±
±±º          ³ DAMATA - 21/05/2014                                        º±±
±±º          ³ Acrescentado a retirada de Flag do SEF                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamada através de menu.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetSE125F()

Private oFont1, oDlg1, oGrp1, oBtn1, oBtn2, oBtn3, oBtn4, oGrp3, oBtn6, oBtn17, oGrp4, oBtn7
Private oBtn9, oBtn10, oBtn11, oBtn12, oGrp5, oBtn13, oBtn14, oBtn15, oBtn16

Public _cTab  := ""
Public _cDesc := ""

oFont1	:= TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
oDlg1   := MSDialog():New( 143,250,568,1274,"R E T I R A      F L A G",,,.F.,,,,,,.T.,,,.T. )

oGrp4   := TGroup():New( 008,008,100,240,"C A D A S T R O      G E R A I S:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn7   := TButton():New( 020,016,"Naturezas"				,oGrp4,{|x| FINA010()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn8   := TButton():New( 046,016,"Fornecedores"			,oGrp4,{|x| MATA020()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn9   := TButton():New( 072,016,"Clientes"				,oGrp4,{|x| MATA030()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn10  := TButton():New( 044,128,"Lançamento Padrão"		,oGrp4,{|x| CTBA080()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn11  := TButton():New( 018,128,"Lançamentos Contábeis"	,oGrp4,{|x| CTBA102()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn12  := TButton():New( 072,128,"Consulta Genérica"		,oGrp4,{|x| EDAPP()},105,020,,oFont1,,.T.,,"",,,,.F. )

oGrp5   := TGroup():New( 008,264,100,496,"C O N T A B I L I Z A Ç Õ E S      O F F:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn13  := TButton():New( 024,272,"Financeiro"				,oGrp5,{|x| FINA370()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn14  := TButton():New( 024,384,"Compras"					,oGrp5,{|x| CTBANFE()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn15  := TButton():New( 060,272,"Faturamento"				,oGrp5,{|x| CTBANFS()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn16  := TButton():New( 060,384,"Recursos Humanos"		,oGrp5,{|x| Alert("Não disponível")},105,020,,oFont1,,.T.,,"",,,,.F. )

oGrp1   := TGroup():New( 120,008,192,240,"F I N A N C E I R O:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn1   := TButton():New( 132,014,"SE1 - Contas a Receber"	,oGrp1,{|x| _cTab:="SE1",_cDesc:="Contas a Receber",RunTab()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn2   := TButton():New( 160,014,"SE2 - Contas a Pagar"	,oGrp1,{|x| _cTab:="SE2",_cDesc:="Contas a Pagar",RunTab()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn3   := TButton():New( 132,126,"SE5 - Movimento Bancário",oGrp1,{|x| _cTab:="SE5",_cDesc:="Movimento Bancário",RunTab()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn4   := TButton():New( 160,126,"SEF - Cheques"			,oGrp1,{|x| RETSEF()},105,020,,oFont1,,.T.,,"",,,,.F. )

oGrp3   := TGroup():New( 120,264,192,496,"E N T R A D A S     E     S A Í D A S:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oBtn6   := TButton():New( 148,271,"SF1 - Doc. de Entrada"	,oGrp3,{|x| _cTab:="SF1",_cDesc:="Documento de Entrada",menuNFs()},105,020,,oFont1,,.T.,,"",,,,.F. )
oBtn17  := TButton():New( 148,384,"SF2 - Doc. de Saída"		,oGrp3,{|x| _cTab:="SF2",_cDesc:="Documento de Saída",menuNFs()},105,020,,oFont1,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return Nil

//**********************************************************************************************************************************************************
Static Function RUNTAB()
//**********************************************************************************************************************************************************
Private aRotina 	:= {}
Private cCadastro	:= ""
Private _nOpc		:= 0
Private _aRetFlag 	:= {|| ZZRET() }
Private _aSetFlag 	:= {|| ZZSET() }
Private _aVerFlag 	:= {|| ZZVER() }


cCadastro := _cTab + " - " + _cDesc

aRotina	:=   {	{"Pesquisar"	,"AXPESQUI" 			,0,1},;
				{"Visualizar"   ,"AXVISUAL"           	,0,2},;
				{"Limpa Flag"   ,"EVAL(_aRetFlag)"    	,0,3},;
				{"Preenche Flag","EVAL(_aSetFlag)"    	,0,4},;
				{"Ver Flag"     ,"EVAL(_aVerFlag)"    	,0,5},;
				{"Lanc.Contab." ,"CTBA102()"          	,0,6},;
				{"Ctb.OffLine"  ,"FINA370()"          	,0,7}}

mBrowse(06,01,22,75, _cTab,,,,,,)

Return Nil


//**********************************************************************************************************************************************************
Static Function ZZRET()
//**********************************************************************************************************************************************************
Local _cMacro := ""

If SE5->E5_LA=="S"
	Alert("O registro ainda não foi contabilizado.")
Else
	_cMacro := _cTab+"->"+SubStr(_cTab,2,2)+"_LA"
	If Reclock(_cTab,.f.)
		&(_cMacro) := " "
		msunlock()
	EndIf
EndIf

Return


//**********************************************************************************************************************************************************
Static Function ZZSET()
//**********************************************************************************************************************************************************
Local _cMacro := ""

If SE5->E5_LA=="S"
	Alert("O registro já foi contabilizado.")
Else
	_cMacro := _cTab+"->"+SubStr(_cTab,2,2)+"_LA"
	If Reclock(_cTab,.f.)
		&(_cMacro) := "S"
		msunlock()
	EndIf
EndIf

Return


//**********************************************************************************************************************************************************
Static Function ZZVER()
//**********************************************************************************************************************************************************
Local _cCpoLA := _cTab+"->"+Right(_cTab,2)+"_LA"

MsgInfo("Flag do Registro: "+Iif(Empty(&(_cCpoLA)),"Em branco",&(_cCpoLA)),"RETFLAG3")

Return

// ==================================================================================================================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETSEF    ºAutor  ³Donizete            º Data ³  07/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ A função deste programa é retirar o flag de cheques e possiº±±
±±º          ³bilitar recontabilizá-los.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamada através de menu.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RETSEF()

// Variáveis do programa
Public nConfirm 	:= 0
Public lInvert  	:= .F.
Public aTitBrw  	:= {}
Public aTitBrw  	:= {}
Public cArqTMP		:= ""

Public cMarca   	:= GetMark()//Space(02)
Public nReg			:= 0

Public _cBco	    := Space(3)
Public _cAgencia   	:= Space(5)
Public _cConta  	:= Space(10)
Public _cChequeDe  	:= Space(15)
Public _cChequeAte 	:= Space(15)

// Monta inteface principal.
DEFINE MSDIALOG oTela TITLE "Retira Flag do SEF"  PIXEL FROM 05,05 TO 205,310 ///???
@ 002 , 002 To 70 , 150 Label " Dados " Color 8388608 OF oTela Pixel

@ 010 , 005 SAY "Banco: " 	SIZE 080 , 010 OF oTela Pixel
@ 010 , 065 MSGET _cBco Picture "@!" F3 "SA6" SIZE 070 , 008 OF oTela Pixel

@ 020 , 005 SAY "Agência: " 	SIZE 080 , 010 OF oTela Pixel
@ 020 , 065 MSGET _cAgencia Picture "@!" SIZE 070 , 008 OF oTela Pixel

@ 030 , 005 SAY "Conta: " 	SIZE 080 , 010 OF oTela Pixel
@ 030 , 065 MSGET _cConta Picture "@!" SIZE 070 , 008 OF oTela Pixel

@ 040 , 005 SAY "Número do Cheque de: " 	SIZE 080 , 010 OF oTela Pixel
@ 040 , 065 MSGET _cChequeDe Picture "@!" SIZE 070 , 008 OF oTela Pixel

@ 050 , 005 SAY "Número do Cheque Até: " 	SIZE 080 , 010 OF oTela Pixel
@ 050 , 065 MSGET _cChequeAte Picture "@!" SIZE 070 , 008 OF oTela Pixel

// 1 = OK, 2 = Cancelar e 11 = Editar
DEFINE SBUTTON FROM 080,090 TYPE 1 ACTION ( nConfirm:= 1, ProcProc() ) ENABLE OF oTela
DEFINE SBUTTON FROM 080,123 TYPE 2 ACTION ( nConfirm:= 0 , oTela:End() ) ENABLE OF oTela

ACTIVATE MSDIALOG oTela CENTERED

Return // Fim

// ==================================================================================================================================

Static Function ProcProc()

// Chama o processameto.
If nConfirm == 1

	nConfirm := 0

	MontaTMP()

	If nReg >0

		// Monta inteface principal.
		DEFINE MSDIALOG oTela1 TITLE "Retira Flag do SEF"  PIXEL FROM 05,05 TO 450,800 //450
		@ 002 , 002 To 200 , 395 Label " Dados " Color 8388608 OF oTela1 Pixel

		oMark1 := MsSelect():New("ZTMP","OK",,aTitBrw,lInvert,cMarca,{07,04,195,390})
		oMark1:oBrowse:lCanAllMark := .T.
		oMark1:oBrowse:lHasMark	   := .T.
		oMark1:bMark          	   := {| | (MBIT1(cMarca,lInvert) , oMark1:oBrowse:Refresh()) }
		oMark1:oBrowse:bAllMark	   := {| | (MVALL(cMarca,lInvert) , oMark1:oBrowse:Refresh()) }

		// 1 = OK, 2 = Cancelar e 11 = Editar
		DEFINE SBUTTON FROM 205,285 TYPE 1 ACTION ( nConfirm:= 1 , oTela1:End() ) ENABLE OF oTela1
		@ 205,320 BUTTON "Cont.Off"	SIZE 42,13 FONT oTela1:oFont ACTION FINA370() OF oTela1 PIXEL
		DEFINE SBUTTON FROM 205,365 TYPE 2 ACTION ( nConfirm:= 0 , oTela1:End() ) ENABLE OF oTela1

		ACTIVATE MSDIALOG oTela1 CENTERED

		// Chama o processameto.
		If nConfirm == 1
			Processa({|| LIMPARFLAG() })
		Endif

	Else
		Alert("Não foi encontrado dados com os parâmetros informados.")
	EndIf

	// Fecha e apaga arquivo temporário.
	dbSelectArea("TSE5")
	dbCloseArea()

	dbSelectArea("ZTMP")
	ZTMP->(dbCloseArea())
	FErase(cArqTMP+GetDBExtension())
	FErase(cArqTMP+OrdBagExt())

EndIf

Return

// ==================================================================================================================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MONTATMP  ºAutor  ³Microsiga           º Data ³  07/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para criar o arquivo temporário para o markbrowser. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTMP()

// Variáveis do programa.
Local aCampos 	:= {}
Local aAux  	:= {}

// Define a estrutura do arquivo.
aCampos:=	{	{ "OK"				,"C"	,02	,0},;
{ "E5_DATA"		    ,"D"	,08	,0},;
{ "E5_VALOR"	    ,"N"	,14	,2},;
{ "E5_BANCO"	    ,"C"	,03	,0},;
{ "E5_AGENCIA"	    ,"C"	,05	,0},;
{ "E5_CONTA"	    ,"C"	,10	,0},;
{ "E5_NUMCHEQ"	    ,"C"	,15	,0},;
{ "E5_HISTOR"	    ,"C"	,40	,0},;
{ "E5_LA"		    ,"C"	,01	,0},;
{ "E5_DTDISPO"	    ,"D"	,08	,0},;
{ "E5_TIPODOC"	    ,"C"	,02	,0},;
{ "NUMREC"       	,"N"	,14	,0} } //??

// Cria o arquivo temporário.
cArqTMP	:= 	CriaTrab(aCampos,.t.)
dbUseArea(.t.,,cArqTMP,"ZTMP",.f.)
IndRegua("ZTMP",cArqTMP,"E5_NUMCHEQ",,,"Selecionando Registros...")

cQuery := " SELECT E5_DATA, E5_VALOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, E5_HISTOR, E5_LA, E5_DTDISPO, E5_TIPODOC, R_E_C_N_O_ NUMREC"
cQuery += " FROM "+RetSqlName("SE5")
cQuery += " WHERE"
cQuery += " 	E5_FILIAL='"+xFilial("SE5")+"' AND"
cQuery += " 	E5_BANCO='"+_cBco+"' AND"
cQuery += " 	E5_AGENCIA='"+_cAgencia+"' AND"
cQuery += " 	E5_CONTA='"+_cConta+"' AND"
cQuery += " 	(E5_NUMCHEQ>='"+_cChequeDe+"' AND E5_NUMCHEQ<='"+_cChequeAte+"') AND"
cQuery += " 	D_E_L_E_T_=' '"
TcQuery cQuery Alias TSE5 New

TcSetField("TSE5", "E5_DATA"   , "D", 08, 0)
TcSetField("TSE5", "E5_DTDISPO", "D", 08, 0)

TSE5->(dbGoTop())
While !(TSE5->(EOF()))
	nReg++
	TSE5->(dbSkip())
Enddo
ProcRegua(nReg)

DbSelectArea("TSE5")
dbGoTop()

If nReg > 0

	While !Eof()
		dbSelectArea("ZTMP")
		If Reclock("ZTMP",.T.)

			ZTMP->OK			:= cMarca
			ZTMP->E5_DATA 		:= TSE5->E5_DATA
			ZTMP->E5_VALOR		:= TSE5->E5_VALOR
			ZTMP->E5_BANCO		:= TSE5->E5_BANCO
			ZTMP->E5_AGENCIA	:= TSE5->E5_AGENCIA
			ZTMP->E5_CONTA		:= TSE5->E5_CONTA
			ZTMP->E5_NUMCHEQ	:= TSE5->E5_NUMCHEQ
			ZTMP->E5_HISTOR		:= TSE5->E5_HISTOR
			ZTMP->E5_LA			:= TSE5->E5_LA
			ZTMP->E5_DTDISPO	:= TSE5->E5_DTDISPO
			ZTMP->E5_TIPODOC 	:= TSE5->E5_TIPODOC
			ZTMP->NUMREC		:= TSE5->NUMREC
			msunlock()
		EndIf

		dbSelectArea("TSE5")
		dbSkip()
	EndDo
EndIf

dbSelectArea("ZTMP")
dbGotop()

//Define as colunas do markbrowser.
aAdd( aTitBrw ,{ "OK"      	 	, ""	, ""      			})
Aadd( aTitBrw ,{ "E5_DATA"   	, ""	, "Data"   			})
Aadd( aTitBrw ,{ "E5_VALOR"  	, ""	, "Valor"   		})
Aadd( aTitBrw ,{ "E5_BANCO"  	, ""	, "Banco"			})
Aadd( aTitBrw ,{ "E5_AGENCIA"	, ""	, "Agencia"   		})
Aadd( aTitBrw ,{ "E5_CONTA"  	, ""	, "Conta"			})
Aadd( aTitBrw ,{ "E5_NUMCHEQ"	, ""	, "Número Cheque"  	})
Aadd( aTitBrw ,{ "E5_HISTOR" 	, ""	, "Histórico"		})
Aadd( aTitBrw ,{ "E5_LA"  	 	, ""	, "Flag"         	})
Aadd( aTitBrw ,{ "E5_DTDISPO"	, ""	, "Dt.Reconc."		})
Aadd( aTitBrw ,{ "E5_TIPODOC"	, ""	, "Tipo Doc."		})
Aadd( aTitBrw ,{ "NUMREC"    	, ""	, "Recno"   		})

Return()

// ==================================================================================================================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MBIT1  	ºAutor  ³Microsiga           º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Marcar/Desmarcar registros indiv. no MarkBrowseº±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MBIT1(cMarca,lInverte)

// Variáveis do programa.
Local _lRet := .t.

If IsMark("OK",cMarca,lInverte)
	RecLock("ZTMP",.F.)
	If !lInverte
		ZTMP->OK := cMarca
	Else
		ZTMP->OK := "  "
	Endif
	MsUnlock("ZTMP")
Else
	RecLock("ZTMP",.F.)
	If !lInverte
		ZTMP->OK := "  "
	Else
		ZTMP->OK := cMarca
	Endif
	MsUnlock("ZTMP")
Endif

Return(_lRet)

// ==================================================================================================================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MVALL		ºAutor  ³Microsiga           º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Marcar/Desmarcar Todos no MarkBrowse	     	  º±±
±±º          ³ 															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MVALL(cMarca,lInverte)

// Variáveis do programa.
Local nRec 		:= ZTMP->(Recno())
Local _lRet 	:= .t.
Local _lAviso 	:= .t.

dbSelectArea("ZTMP")
ZTMP->(dbGoTop())
While !(ZTMP->(EOF()))
	RecLock("ZTMP",.F.)
	If Empty(ZTMP->OK)
		ZTMP->OK := cMarca
	Else
		ZTMP->OK := "  "
	Endif
	MsUnLock("ZTMP")
	ZTMP->(dbSkip())
Enddo

ZTMP->(dbGoTo(nRec))

Return(_lRet)

// ==================================================================================================================================

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EXPORTA   ºAutor  ³Donizete            º Data ³  07/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta função exporta os arquivos do banco para DBF.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LIMPARFLAG()

// Variáveis do programa.

// Define régua de processamento.
dbSelectArea( "ZTMP")
ProcRegua( ZTMP->( RECCOUNT() ) )
ZTMP->(dbGoTop())

// Processo.
While !(ZTMP->(EOF()))

	IncProc("Exportando "+ZTMP->E5_NUMCHEQ)

	// Processa apenas tabelas marcadas e verifica opções do usuário.
	If Alltrim(ZTMP->OK) != Alltrim(cMarca) .Or. ZTMP->E5_TIPODOC<>"CH"
		ZTMP->(dbSkip())
		Loop
	Endif

	cQuery := " UPDATE "+RetSqlName("SE5")
	cQuery += " SET E5_LA=' '"
	cQuery += " WHERE"
	cQuery += " 	E5_FILIAL='"+xFilial("SE5")+"' AND"
	cQuery += " 	E5_BANCO='"+ZTMP->E5_BANCO+"' AND"
	cQuery += " 	E5_AGENCIA='"+ZTMP->E5_AGENCIA+"' AND"
	cQuery += " 	E5_CONTA='"+ZTMP->E5_CONTA+"' AND"
	cQuery += " 	E5_NUMCHEQ='"+ZTMP->E5_NUMCHEQ+"' AND"
	cQuery += " 	D_E_L_E_T_=' '"

	If TcSQLExec(cQuery) < 0
		Alert("Error : "+ TcSQLError())
	Endif

	cQuery := " UPDATE "+RetSqlName("SEF")
	cQuery += " SET EF_LA=' '"
	cQuery += " WHERE"
	cQuery += " 	EF_FILIAL='"+xFilial("SEF")+"' AND"
	cQuery += " 	EF_BANCO='"+ZTMP->E5_BANCO+"' AND"
	cQuery += " 	EF_AGENCIA='"+ZTMP->E5_AGENCIA+"' AND"
	cQuery += " 	EF_CONTA='"+ZTMP->E5_CONTA+"' AND"
	cQuery += " 	EF_NUM='"+ZTMP->E5_NUMCHEQ+"' AND"
	cQuery += " 	D_E_L_E_T_=' '"

	If TcSQLExec(cQuery) < 0
		Alert("Error : "+ TcSQLError())
	Endif

	dbSelectArea("ZTMP")
	dbSkip()
EndDo

// Encerramento.
MsgInfo("Flag retirado.")

Return


Static Function menuNFs()
	
	Local cRotContabiliza 	:= IIF(_cTab=='SF1','CTBANFE()','CTBANFS()')
	Private	_bClearCtb 		:= {|| clearCtb() }
	Private	_bSeeCtb 		:= {|| seeCtb() }
	Private aRotina 		:= {}
	Private cCadastro		:= _cTab + " - " + _cDesc
	Private _nOpc			:= 0
		 
	aRotina	:=   {	{"Pesquisar"	,"AXPESQUI" 			,0,1},;
					{"Visualizar"   ,"AXVISUAL"           	,0,2},;
					{"Limpa Flag"   ,"EVAL(_bClearCtb)"    	,0,3},;					
					{"Ver Flag"     ,"EVAL(_bSeeCtb)"    	,0,5},;
					{"Lanc.Contab." ,"CTBA102()"          	,0,6},;
					{"Ctb.OffLine"  ,cRotContabiliza       	,0,7}}
	
					//{"Preenche Flag","EVAL(_aSetFlag)"    	,0,4},;
	
	mBrowse(06,01,22,75, _cTab,,,,,,)

return

Static Function clearCtb()
	
	Local _cMacro := _cTab+"->"+SubStr(_cTab,2,2)+"_DTLANC"
	
	if Reclock(_cTab,.f.)
		&(_cMacro) := CTOD("//")
		msunlock()
	endif
	
return

Static Function seeCtb()

	Local _cCpoLA := _cTab+"->"+SubStr(_cTab,2,2)+"_DTLANC"

	MsgInfo("Data de Contabilização do Registro: "+Iif(Empty(&(_cCpoLA)),"Em branco", + DTOC(&(_cCpoLA))),"RETFLAG3")

Return
