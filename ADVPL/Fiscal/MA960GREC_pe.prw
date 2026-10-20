#include 'totvs.ch'
/*/{Protheus.doc} MA960GREC
ponto de entrada que retornará os dados para os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE e F6_CODPROD.
@type function
@version 12.1.33
@author Tiago Faria
@since 10/11/2021
@return array, Retorna array com o conteudo dos campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE e F6_CODPROD.
/*/
user function MA960GREC()
	//local cReceita := PARAMIXB[1]
	local cUf        := PARAMIXB[2]
	local aRet       := array(4)
	local cTipoGNU   := ""
	local cDocOrig   := ""
	local cDetRece   := ""
	local cCodProd   := ""
	private lReclock := getMV("MV_GNRENF")

	if lReclock
		cTipoGNU := SF6->F6_TIPOGNU
		cDocOrig := SF6->F6_DOCORIG
		cDetRece := SF6->F6_DETRECE
		cCodProd := SF6->F6_CODPROD
	else
		cTipoGNU := M->F6_TIPOGNU
		cDocOrig := M->F6_DOCORIG
		cDetRece := M->F6_DETRECE
		cCodProd := M->F6_CODPROD
	endif

	if posicione("SZ6",1,xFilial("SZ6")+cUF,"!Eof()")
		cTipoGNU := SZ6->Z6_TIPOGNU
		cDocOrig := SZ6->Z6_DOCORIG
		cDetRece := SZ6->Z6_DETRECE
		cCodProd := SZ6->Z6_CODPROD

		u_GNREDePara(lReclock)
	endif

	aRet[1] := cTipoGNU//ok
	aRet[2] := cDocOrig//ok
	aRet[3] := cDetRece//ok
	aRet[4] := cCodProd//ok

	if lReclock
		recLock("SF6",.f.)
		SF6->F6_DTARREC := datavalida(SF6->F6_DTARREC+0)
		SF6->F6_DTPAGTO := SF6->F6_DTARREC
		SF6->(msUnlock())
	else
		M->F6_DTARREC := datavalida(M->F6_DTARREC+0)
		M->F6_DTPAGTO := M->F6_DTARREC
	endif
	//M->F6_DTVENC :=
return aRet
