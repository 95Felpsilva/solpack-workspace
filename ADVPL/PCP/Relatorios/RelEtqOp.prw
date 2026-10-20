#include 'totvs.ch'

#DEFINE	NLINHAINICIAL		0015
#DEFINE	NTAMANHOPAGI		0780
#DEFINE	NQUEBRAOBSERV		0100
#DEFINE	NQUEBRALEGEND		0060

/*/{Protheus.doc} RelEtqOp
Relatório Etiqueta de OP
@type function
@version 12.1.27
@author Tiago Faria
@since 01/10/2021
@param oReport, object, Objeto IPFwMsPrinter quando estiver imprimindo automaticamente
/*/
user function RelEtqOp(oReport,lFrenteVerso)
	Local nI			:= 0
	Local cDescri 	
	Private oPrinter 		:= nil
	Private nLinha			:= 0
	Private nMargemDir		:= 0
	Private nMargemEsq		:= 0
	Private nTamPag			:= 0
	Private aColImp			:= {}
	Private cNumOP			:= ""
	Private nRegs			:= 0
	Private nLinhaAUX		:= 0 //JONI

	Private aEmp			:= {}
	Private aRot			:= {}
	Private aCBI			:= {}
	Private aMotivo			:= {}
	Private aTransac		:= {}

	Private oFont06 		:= TFont():New("Arial", 06, 06,, .F.,,,,, .F., .F.)
	Private oFont06N 		:= TFont():New("Arial", 06, 06,, .T.,,,,, .F., .F.)
	Private oFont08 		:= TFont():New("Arial", 08, 08,, .F.,,,,, .F., .F.)
	Private oFont08N 		:= TFont():New("Arial", 08, 08,, .T.,,,,, .F., .F.)
	Private oFont09 		:= TFont():New("Arial", 09, 09,, .F.,,,,, .F., .F.)
	Private oFont09N 		:= TFont():New("Arial", 09, 09,, .T.,,,,, .F., .F.)
	Private oFont10 		:= TFont():New("Arial", 10, 10,, .F.,,,,, .F., .F.)
	Private oFont10N 		:= TFont():New("Arial", 10, 10,, .T.,,,,, .F., .F.)
	Private oFont11 		:= TFont():New("Arial", 11, 11,, .F.,,,,, .F., .F.)
	Private oFont11N 		:= TFont():New("Arial", 11, 11,, .T.,,,,, .F., .F.)
	Private oFont12 		:= TFont():New("Arial", 12, 12,, .F.,,,,, .F., .F.)
	Private oFont12N 		:= TFont():New("Arial", 12, 12,, .T.,,,,, .F., .F.)
	Private oFont14N 		:= TFont():New("Arial", 14, 14,, .T.,,,,, .F., .F.)
	Private oFont16 		:= TFont():New("Arial", 20, 20,, .F.,,,,, .F., .F.)
	Private oFont16N		:= TFont():New("Arial", 16, 16,, .T.,,,,, .F., .f.)
	Private oFont25N		:= TFont():New("Arial", 30, 30,, .T.,,,,, .F., .f.)
	private nNumEtq         := 0
	private lAuto := .f.
	default lFrenteVerso := .f.
	lAuto := valType(oReport) == "O"

	if lAuto
		oPrinter := oReport
	else
		reportDef()
	endif


	nLinha			:= NLINHAINICIAL
	nMargemDir		:= 0500//0590-0030//oPrinter:nVertSize()-0030
	nMargemEsq		:= 0015
	nTamPag			:= NTAMANHOPAGI

	oPrinter:StartPage()

	nLinha			:= NLINHAINICIAL
	nMargemDir		:= 0550//0590-0030//oPrinter:nVertSize()-0030
	nMargemEsq		:= 0015
	nTamPag			:= NTAMANHOPAGI

	nTamCol := nMargemDir/20
	For nI := 1 To 23
		aAdd(aColImp, nI * nTamCol)
	Next nI

	posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"!Eof()")
	
	posicione("SB5",1,xFilial("SB5")+SC2->C2_PRODUTO,"B5_CEME")
	
	IF !EMPTY(SB5->B5_CEME)
		cDescri := SB5->B5_CEME
	Else 
		cDescri := SB1->B1_DESC
	Endif

	if SB1->B1_GRUPO == "3010" .and. SB1->B1_ZZSUBGR == "01" //OP DE SACARIA
		nQtdEtq := SC2->C2_QUANT
	else
		nQtdEtq := ceiling(SC2->C2_QUANT / SB1->B1_QE )
	endif

	for nI := 1 to nQtdEtq

		//oPrinter:SayAlign(nLinha, aColImp[01], alltrim(SB1->B1_DESC), oFont25N, aColImp[22], 10, , 2, 0)
		oPrinter:SayAlign(nLinha, aColImp[01], alltrim(cDescri), oFont25N, aColImp[22], 10, , 2, 0)
		nLinha += 0045
		oPrinter:Box(nLinha+0005,aColImp[01],nLinha-0015,aColImp[03]+15,,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[01]+0002,"Operador",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[03]+15,nLinha-0015,aColImp[09],,,.f./*lConvert*/)

		oPrinter:Box(nLinha+0005,aColImp[09],nLinha-0015,aColImp[11],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[09]+0002,"N° OP",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[11],nLinha-0015,aColImp[14],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[11]+0002,SC2->C2_NUM,oFont16)

		oPrinter:Box(nLinha+0005,aColImp[14],nLinha-0015,aColImp[16]+10,,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[14]+0002,"Máquina",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[16]+10,nLinha-0015,aColImp[19],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[16]+0025,SC2->C2_ZZTEAR,oFont16)


		oPrinter:Box(nLinha+0005,aColImp[19],nLinha-0015,aColImp[21],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[19]+0002,"Etq. N°",oFont16)

		nLinha += 0020

		oPrinter:Box(nLinha+0005,aColImp[01],nLinha-0015,aColImp[03]+15,,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[01]+0002,"Hora",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[03]+15,nLinha-0015,aColImp[07],,,.f./*lConvert*/)


		oPrinter:Box(nLinha+0005,aColImp[07],nLinha-0015,aColImp[09],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[07]+0002,"Data",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[09],nLinha-0015,aColImp[11],,,.f./*lConvert*/)

		oPrinter:Box(nLinha+0005,aColImp[11],nLinha-0015,aColImp[12]+15,,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[11]+0002,"Rev",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[12]+15,nLinha-0015,aColImp[14],,,.f./*lConvert*/)


		oPrinter:Box(nLinha+0005,aColImp[14],nLinha-0015,aColImp[16]+10,,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[14]+0002,"Estoque",oFont16)
		oPrinter:Box(nLinha+0005,aColImp[16]+10,nLinha-0015,aColImp[19],,,.f./*lConvert*/)

		nNumEtq++
		oPrinter:Box(nLinha+0005,aColImp[19],nLinha-0015,aColImp[21],,,.f./*lConvert*/)
		oPrinter:Say(nLinha,aColImp[19]+0002,cValToChar(nNumEtq),oFont16)

		if nI % 10 == 0 .and. nI+1 <= nQtdEtq
			oPrinter:endPage()
			oPrinter:startPage()
			if lFrenteVerso
				oPrinter:endPage()
				oPrinter:startPage()
			endif
			nLinha := NLINHAINICIAL
		else
			if nI+1 < nQtdEtq
				oPrinter:Line(nLinha+0015,aColImp[1],nLinha+0015,aColImp[21],,,.f./*lConvert*/)
			endif
		endif

		nLinha += 0015
	next nI

	oPrinter:EndPage()

	if !lAuto
		oPrinter:Print()
	endif
return

static function reportDef()
	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup  	:= .T.

	oPrinter := FWMSPrinter():New("FSWIPIMPOP_"+FWTIMESTAMP(),IMP_PDF, lAdjustToLegacy,"/spool/", lDisableSetup,,,)
	oPrinter:cPathPDF :="C:\temp\"

	oPrinter:SetPortrait()
	//oPrinter:SetLandscape()
	oPrinter:SetPaperSize(9)
return
