#INCLUDE "Protheus.ch"

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北 Funcao    ?CtbDesp Autor  ?Ana Flavia      Data ? 12/11/15     北
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北 Descricao ?Define a Conta Contabil a ser utilizada no momento  北
北        ?da Contabiliza玢o das Despesas de acordo com o C.Custo 北
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北 Uso       ?Especifico (Solpack) adaptei o programa CtbGpe     北
北do analista Carlos eduardo para CTBDesp                        北
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/

User Function CtbDesp(nOpcao)						&& CtbDesp - Nome da Funcao (Alterar de acordo com o cliente) - nOpcao poder?ser 1 - Debito; 2 - Credito

Local cRet := ""									&& cRet ira retornar a Conta Contabil vinculada ao produto, de acordo com a classificacao do Centro de Custo

CTT->(dbSetOrder(1))								&& Utiliza o 1o indice da tabela CTT (CTT_FILIAL + CTT_CUSTO)
If CTT->(dbSeek(xFilial("CTT") + SD1->D1_CC))
	If nOpcao == 1									&& nOpcao = 1 - Debito
		If CTT->CTT_ZZTPCC == "1"					&& CTT_ZZTPCC - Campo personalizado na CTT (Centro de Custo) para classificacao contabil. Exemplo 1 - Administracao
			cRet:= SB1->B1_ZZCTAD                   && SB1->B1_ZZCTAD - Campo personalizado na SB1 (Produto) para informacao da Conta Contabil. Exemplo ...DBA - Debito Administra玢o
		ElseIf CTT->CTT_ZZTPCC == "2"				&& CTT_ZZTPCC - Campo personalizado na CTT (Centro de Custo) para classificacao contabil. Exemplo 2 - Comercial
			cRet:= SB1->B1_ZZCTAA					&& SB1->B1_ZZCTAA - Campo personalizado na SB1 (Produto) para informacao da Conta Contabil. Exemplo ...DBC - Debito Comercial
		ElseIf CTT->CTT_ZZTPCC == "3"				&& CTT_ZZTPCC - Campo personalizado na CTT (Centro de Custo) para classificacao contabil. Exemplo 3 - Producao
			cRet:= SB1->B1_ZZCTAC					&& SB1->B1_ZZCTAC - Campo personalizado na SB1 (Produtos) para informacao da Conta Contabil. Exemplo ...DBP - Debito Producao
		EndIf
	ElseIf nOpcao == 2								&& nOpcao = 2 - Credito
		If CTT->CTT_ZZTPCC == "1"                   && Idem item anterior
			cRet:= SB1->B1_ZZCTAD					&& Idem item anterior - Credito
		ElseIf CTT->CTT_ZZTPCC == "2"               && Idem item anterior
			cRet:= SB1->B1_ZZCTAA					&& Idem item anterior - Credito
		ElseIf CTT->CTT_ZZTPCC == "3"               && Idem item anterior
			cRet:= SB1->B1_ZZCTAC			        && Idem item anterior - Credito	
		EndIf
	EndIf
EndIf
     
Return cRet

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北																				北
北 Caso haja a necessidade de utiliza玢o de mais de 3 classifica珲es de Centro  北
北 de Custo, um novo grupo de ElseIF dever?ser acrescentado ?rotina.  		北
北 Da mesma forma, se menos de 3 op珲es forem utilizadas, um grupo de ElseIF    北
北 dever?ser retirado da rotina. Obs: Essa fun玢o somente dever?ser utilizada	北
北 caso a Conta Contabil varie em fun玢o do Centro de Custo, caso contrario,   	北
北 n鉶 existe a necessidade de utiliza玢o dessa fun玢o.							北
北																				北		
北屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
