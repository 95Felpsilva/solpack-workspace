#include 'totvs.ch'
 /*/{Protheus.doc} FA050INC
A finalidade do ponto de entrada FA050INC é permitir validações de usuário
na inclusão do Contas a Pagar (FINA050), localizado no TudoOK da rotina.
@type function
@author Ana Flavia
@since 30/04/2021
@return logical, .T. valida a inclusão e continua o processo, caso contrário .F. e interrompe o processo.
/*/
User Function FA050INC()
	Local lRet := .t.

	//Validações de usuario
	IF funname() $ "FINA050/FINA750" .and. empty(M->E2_CCUSTO) .and. !M->E2_TIPO $ "PR /PA "
		//Mensagem de Help para esclarecer o motivo de interromper a inclusão
		Help(,,'Help',,"Campo Centro de Custo não foi preenchido.",1,0 )
		lRet := .f.
	Endif
Return lRet
