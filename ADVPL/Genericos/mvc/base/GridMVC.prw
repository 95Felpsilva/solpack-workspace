#include 'totvs.ch'
/*/{Protheus.doc} GridMVC
Tela responsável por exibir o MVC apenas com Grid
@type function
@version 12.1.27
@author Tiago Faria
@since 25/07/2021
@param cIDPrograma, character, ID do programa
@param oOwner, object, Container da tela
@param cTitulo, character, Titulo do MVC
@param nOperation, numeric, Operação que será executada o MVC 3=INCLUSAO;4=ALTERACAO;5=EXCLUSAO
/*/
user function GridMVC(cIDPrograma,cTitulo,nOperation,aEnableButtons,nPercReducao,bCloseOnOK,bOk,bCancel)
	private oDefMVC    := GridMVCDef():getDef(cIDPrograma)
	default cTitulo    := ""
	default nOperation := 4
return FWExecView( cTitulo , cIDPrograma, nOperation, /*oDlg*/,/*bCloseOnOK*/, bOk , nPercReducao, aEnableButtons, bCancel , /*cOperatId*/, /*cToolBar*/, /*oModel*/ ) == 0

static Function ModelDef()
return oDefMVC:modelDef()

static function viewDef()
return oDefMVC:viewDef()
