#Include 'Protheus.ch'
/*/{Protheus.doc} FA440VLD
P.E. utilizado para validar se deve ou não gerar comissão na baixa do titulo
Adicionado pois a SAFRA modificou o método de pagamento, de Emissão para Baixa e 
com isso o calculo estava pagando novamente as comissões de 2020
@author Joni Santos
@since 04/12/2020
@version 1.0
@return lRet, logico, se .t. gera comissão se .f. não gera comissão
/*/
User Function FA440VLD()

	Local lRet := SE1->E1_EMISSAO >= STOD('20220301')

Return lRet
