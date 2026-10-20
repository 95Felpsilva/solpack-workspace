#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MA650BUT
Adiciona itens no menu principal do fonte MATA650
@author Tiago Faria
@since 17/07/2019
@version undefined

@type function
/*/
user function myMatr820()
	local aMvPar := saveMvPar()
   
    MATR820()

    restoreMvPar(aMvPar)
return 

static function saveMvPar()
	Local aMvPar	:= {}
	Local nMV		:= 0

	For nMv := 1 To 60
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv
Return aMvPar

static function restoreMVPar(aMvPar)
	Local nMv	 	:= 0

	For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
Return