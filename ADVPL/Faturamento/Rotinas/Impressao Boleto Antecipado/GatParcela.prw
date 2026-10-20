#include 'totvs.ch'
/*/{Protheus.doc} GatParcela
Função chamada da validaçãço de usuário do campo C5_ZZPARC1
@type function
@version 12.1.33
@author Tiago Faria
@since 24/11/2021
@return logical, retorna sempre .t.
/*/
user function GatParcela()
	local nBaseDup := BolAntecip():getBaseDup()
	local nParc2   := 0
	local cCampo   := readVar()

	M->C5_ZZBASED := nBaseDup

	if cCampo == "M->C5_ZZPAR1"
		nParc2 := nBaseDup - M->C5_ZZPAR1

		if nParc2 > 0
			M->C5_ZZPAR2 := nParc2
		else
			M->C5_ZZPAR2 := 0
		endif

	else
		nParc2 := nBaseDup - M->C5_ZZPAR2

		if nParc2 > 0
			M->C5_ZZPAR1 := nParc2
		else
			M->C5_ZZPAR1 := 0
		endif
	endif

	u_vldVlrDtEntrega(.f./*lvalid*/)
return .t.
