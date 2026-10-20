#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.CH'

static QTD_MODEL_POS := 0

/*/{Protheus.doc} CRMA980
PE MVC cadastro de Clientees
@author Tiago Faria
@since 13/11/2019
@version undefined

@type function
/*/
user function CRMA980()
	Local aParam 	:= Paramixb
	Local aButton	:= {}
	Local oObj
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local lIsGrid	:= .f.
	Local lRet		:= .t.
	Local oModel	:= nil
	
	If aParam <> NIL
		oObj 		:= aParam[1]
		cIdPonto 	:= aParam[2]
		cIdModel 	:= aParam[3]

		oModel := oObj:getModel()
		lIsGrid := ( Len( aParam ) > 3 )
	endif
	
	if cIdPonto == "BUTTONBAR" .and. FwIsInCallStack("U_RELFILCADASTROS") .and. oModel:getOperation() == MODEL_OPERATION_VIEW
		if isInCallStack('CRMA290')
        	U_SOLFAT02()
    	endif
		aAdd(aButton,{'Cons. Pedido de Venda', 'SALVAR', { || CRMA310(,"SA1") }, 'Cons. Pedido de Venda' })
		aAdd(aButton,{'Nova Anotacao', 'SALVAR', { || CRMA090(,"AOB") }, 'Nova anotacao' })
		return aButton
	endif

Return lRet
