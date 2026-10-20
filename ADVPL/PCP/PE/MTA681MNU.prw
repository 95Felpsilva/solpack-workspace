#include "totvs.ch"
/*/{protheus.doc}MTA681MNU
Ponto de entrada na rotina de apontamento de produção.
@author Sergio Braz
@since 28/03/18
/*/
User Function MTA681MNU 
	AADD(aRotina,{"Reimprime Etq"	,"U_ImpEtq(.t.)"	,0,6})
	AADD(aRotina,{"Envia Revisão"	,"U_updRevisao(.t.)",0,4})
	AADD(aRotina,{"Retira Revisão"	,"U_updRevisao(.f.)",0,4})
	AADD(aRotina,{"Rel. Acompanhamento Producao"	,"u_RELACOMPPROD()",0,6})
	AADD(aRotina,{"Tela AP CodBar"	,"u_APCODBAR()",0,6})
Return
