#include 'totvs.ch'
/*
* Fuction: TITICMST
* Ajuste Data e Numero Titulo ICMS/ST
* 
*/
User Function TITICMST
	//Local cOrigem  := PARAMIXB[1]
	//Local cTipoImp := PARAMIXB[2]
	Local lDifal   := PARAMIXB[3]

	// Ajusta numero do titulo e data para ICMS ST
	If lDifal // DIFAL
		SE2->E2_NUM     := SF2->F2_DOC
        //SE2->E2_PREFIXO := SF2->F2_SERIE
		SE2->E2_VENCTO  := DataValida(SF2->F2_EMISSAO + 0,.T.)
		SE2->E2_VENCREA := DataValida(SF2->F2_EMISSAO + 0,.T.)
		SE2->E2_NATUREZ := getNewPar("ZZ_NATDIF",'51205')
	EndIf
Return {SE2->E2_NUM,SE2->E2_VENCTO}
