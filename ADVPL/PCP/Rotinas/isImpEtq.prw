#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.ch'
/*/{Protheus.doc} isImpEtq
Valida se deve ou não imprimir a etiqueta.
@author Tiago Faria
@since 07/06/2019
@version 1.0
@return logical, se true é a operação de impressão das etiquetas se false não é
@param cOP, characters, descricao
@param cProduto, characters, descricao
@param cOperac, characters, descricao
@type function
/*/
user function isImpEtq(cOP,cProduto,cOperac)
	local cQuery 		:= ""
	local cAlias 		:= ""
	local aArea	 		:= Lj7GetArea({"SC2","SG2"})
	local lRet	 		:= .t.
	default cOP 		:= SH6->H6_OP
	default cProduto 	:= SH6->H6_PRODUTO
	default cOperac 	:= SH6->H6_OPERAC

	cQuery += "SELECT" + CRLF
	cQuery += "	MAX(G2_CODIGO) AS G2_CODIGO" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += "	" + retSqlTab("SC2") + CRLF
	cQuery += "INNER JOIN" + CRLF
	cQuery += "	" + retSqlTab("SG2") + CRLF
	cQuery += "ON 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SG2") + CRLF
	cQuery += "	AND G2_PRODUTO = C2_PRODUTO" + CRLF
	cQuery += "	AND G2_CODIGO = C2_ROTEIRO" + CRLF
	cQuery += "	AND C2_EMISSAO BETWEEN G2_DTINI AND CASE WHEN G2_DTFIM = '        ' THEN 'ZZZZZZZZ' ELSE G2_DTFIM END" + CRLF
	cQuery += "	AND G2_ZZIMPET = 'S'" + CRLF
	//cQuery += "	AND G2_OPERAC = '" + SH6->H6_OPERAC + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SG2") + CRLF
	cQuery += "WHERE 1=1" + CRLF
	cQuery += "	AND " + retSqlFil("SC2") + CRLF
	cQuery += "	AND C2_NUM+C2_ITEM+C2_SEQUEN = '" + cOP + "'" + CRLF
	cQuery += "	AND " + retSqlDel("SC2") + CRLF

	TcQuery cQuery new Alias (cAlias := getNextAlias())

	if (cAlias)->(Eof()) .or. empty((cAlias)->(G2_CODIGO))
		lRet := u_getLastOperac(cProduto) == cOperac
	else
		lRet := (cAlias)->(G2_CODIGO) == cOperac
	endif 

	(cAlias)->(dbCloseArea())

	Lj7RestArea(aArea)
return lRet
