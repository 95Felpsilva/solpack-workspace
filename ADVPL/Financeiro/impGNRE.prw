#include 'totvs.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
/*/{Protheus.doc} ImpGNRE
Impressão da guia do GNRE
@type function
@version 12.1.33
@author Tiago Faria
@since 06/01/2022
/*/
user function ImpGNRE()
    local aBKPMV := getBkpMV()

    MyFisa095Imp()

    restoreBkpMV(aBKPMV)
return


static function getBkpMV()
	local nQtdMV := 60
	local nMV	 := 0
	local cMV	 := ""
	local xContent := nil

	local aBkp	 := {}
	for nMV := 1 to nQtdMV
		cMV := "MV_PAR" + padL(cValToChar(nMV),2,"0")
		xContent := &(cMV)
		aAdd(aBkp,{cMV,xContent})
	next nMV
return aBkp

static function restoreBkpMV(aBkpMV)
	local nMV	 := 0
	local cMV	 := ""
	local xContent := nil

	for nMV := 1 to len(aBkpMV)
		cMV := aBkpMV[nMV,1]
		xContent := aBkpMV[nMV,2]

		&(cMV) := xContent
	next nMV
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa095Imp
Realiza impressão da GNRE

@author Simone dos Santos de Oliveira
@since 07/03/2016
@version 1.0

/*/
//-------------------------------------------------------------------
static function MyFisa095Imp()

local oImpGNRE
local oSetup
local cIdEnt     := FSA095IDEnt()
local aDevice    := {}
local cURL      := Padr(GetNewPar("MV_SPEDURL","http://"),250)
local cFilePrint := "GNRE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
local cSession   := GetPrinterSession()

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

nLocal       := if(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation := 1 //Retrato
cDevice      := if(empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nPrintType   := ascan(aDevice,{|x| x == cDevice })

If IsReadyGNRE( cUrl )

	lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
	oImpGNRE := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

	// ----------------------------------------------
	// Cria e exibe tela de Setup Customizavel
	// OBS: Utilizar include "FWPrintSetup.ch"
	// ----------------------------------------------
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN + PD_DISABLEORIENTATION

	if findfunction("u_PrtGNRE")
		if ( !oImpGNRE:lInJob )
			oSetup := FWPrintSetup():New(nFlags, "GNRE")
			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)
		endif

		// Pressionado botão OK na tela de Setup
		if oSetup:Activate() == PD_OK // PD_OK =1

			//Salva os Parametros no Profile
			fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
			fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

			// Configura o objeto de impressão com o que foi configurado na interface.
			oImpGNRE:setCopies( val( oSetup:cQtdCopia ) )

			u_PrtGNRE(cIdEnt, oImpGNRE, oSetup, cFilePrint)		

		else
			msginfo("Relatório cancelado pelo usuário.")
			return
		endif
	else
		msginfo("RDMAKE FISA119 não encontrado. Relatório não será impresso!")
	endif
endif

oImpGNRE:= nil
oSetup  := nil

return
