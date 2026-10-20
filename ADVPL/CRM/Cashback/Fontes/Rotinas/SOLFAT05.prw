#include "TOTVS.CH"
#include "topconn.ch"
#include "SOLFAT04.ch"

#define ARRAY_CASH      1
#define ARRAY_PRODUTO   2
#define ARRAY_VALOR     3
#define ARRAY_FILPV     4
#define ARRAY_PV        5
#define ARRAY_ITEMPV    6

/*/{Protheus.doc} SOLFAT05
    Movimentações de cashback
    
    @author Gabriel Pereira Santos
    @since 26/04/2023
    @version P12
/*/ 
User Function SOLFAT05(cParFilPV, cParNumPV, nParOperacao)
    Local lRet              := .T.
    Local aArea 	        := Lj7GetArea({"SA1", "SC5", "SC6"})

    Default cParFilPV       := ""
    Default cParNumPV       := ""
    Default nParOperacao    := 0
    
    Private cFilPV          := cParFilPV
    Private cNumPV          := cParNumPV
    Private nOperacao       := nParOperacao
    Private cMsg            := ""

    If podeExecutar()
        Processa( {|| lRet := processaCashback() }, "Processando", "Realizando movimentações de cashback...", .F.)
    EndIf

    Lj7RestArea(aArea)

Return lRet

/*
    Rotina de pré-validação
*/
Static Function podeExecutar()
    Local lRet      := .F.
    Local lAtivo    := GetNewPar("ES_ATVCASH", .T.) 

    Begin Sequence

        If ( !lAtivo )
            cMsg := "Rotina de cashback não esta ativa (ES_ATVCASH)"
            Break
        EndIf

        If (!FwAliasInDic(ALIAS_FORM0) .Or. !FwAliasInDic(ALIAS_GRID0) .Or. !FwAliasInDic(ALIAS_GRID1))
            cMsg := "Necessário criar as tabelas que envolve o processo de cashback ("+ALIAS_FORM0+"/"+ALIAS_GRID0+"/"+ALIAS_GRID1+")"
            Break
        EndIf
        
        If (SA1->(FieldPos("A1_ZCASH")) <= 0)
            cMsg := "Necessário criar o campo A1_ZCASH (Cashback) e preenche-lo"
            Break
        EndIf

        If ( nOperacao < OPERACAO_INCLUSAO .OR. nOperacao > OPERACAO_COPIA )
            cMsg := "Operacao informada não permitida (" + cValToChar(nOperacao) + ")"
            Break
        EndIf

        If (nOperacao <> OPERACAO_EXCLUSAO)
            SC5->(DBSetOrder(1))
            If !SC5->(MsSeek(AvKey(cFilPV, "C5_FILIAL")+AvKey(cNumPV, "C5_NUM")))
                cMsg := "Pedido informado não foi encontrado (" + cFilPV + "/" + cNumPV + ")"
                Break
            EndIf
            
            SC6->(DBSetOrder(1))
            If !SC6->(MsSeek(AvKey(cFilPV, "C6_FILIAL")+AvKey(cNumPV, "C6_NUM")))
                cMsg := "Pedido informado não tem itens (" + cFilPV + "/" + cNumPV + ")"
                Break
            EndIf
            
            SA1->(DBSetOrder(1))
            If !SA1->(MsSeek(xFilial("SA1")+AvKey(SC5->C5_CLIENTE, "A1_COD")+AvKey(SC5->C5_LOJACLI, "A1_LOJA")))
                cMsg := "Cliente do PV não existe (" + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + ")"
                Break
            EndIf

            If ( SA1->A1_ZCASH <> "S" )
                cMsg := "Cliente " + SA1->A1_COD + "/" + SA1->A1_LOJA + " não esta com o controle de cashback ativo."
                Break
            EndIf
        EndIf

        lRet := .T.
    EndSequence

Return lRet

/*
    Rotinas resposável por realizar movimentações de cashback
*/
Static Function processaCashback()
    Local aDadosEnt         := {}
    Local aUtilizado        := {}
    Local cIDCash           := ""
    Local cCodProduto       := ""
	Local cAliasForm 		:= ALIAS_FORM0
	Local cPrefForm			:= PREFIXO_ALIAS_FORM0
    Local cCodCliente       := SC5->C5_CLIENTE
    Local cCodLoja          := SC5->C5_LOJACLI
    Local cItemPV           := ""
    Local nSaldoCash        := 0
    Local nNewCash          := 0
    Local nRecord           := 0
    Local nTotalUtilizado   := 0
    Local nTotalGerado      := 0
    Local nConvTotal        := 0
    Local lValidPorcent     := .F.
    Local lRet              := .T.

    Begin Transaction
        Begin Sequence

            If (nOperacao == OPERACAO_EXCLUSAO)
                faturamento.MonitorCashback.u_deleteMoviment(,,cFilPV, cNumPV,, cCodCliente, cCodLoja)
                Break
            EndIf        

            (cAliasForm)->(DBSetOrder(3))
            If ( !(cAliasForm)->(MsSeek(xFilial(cAliasForm)+AvKey(cCodCliente, cPrefForm+"_CLIENT")+AvKey(cCodLoja, cPrefForm+"_LOJA"))))
                If ( !faturamento.MonitorCashback.u_createCliente(cCodCliente, cCodLoja) )
                    FwAlertError("Não foi possível gerar cashback vinculado ao cliente. Por favor, altere o PV para uma nova tentativa.",NOME_EMPRESA)
                    Break
                EndIf
            EndIf

            If ( (cAliasForm)->&(cPrefForm+"_VALOR") <= 0 .And. nOperacao == OPERACAO_INCLUSAO)
                cMsg := "Cliente " + cCodCliente + "/" + cCodLoja + " não tem saldo de cashback"
                Break
            EndIf

            cIDCash := (cAliasForm)->&(cPrefForm+"_ID")
            lValidPorcent := faturamento.MonitorCashback.u_validPorcentPV(cNumPV, cCodCliente, cCodLoja)

            If ( nOperacao == OPERACAO_ALTERACAO )
                aUtilizado := faturamento.MonitorCashback.u_getValorByPV(MOVIMENTO_SAIDA, cIDCash, cFilPV, cNumPV)
                faturamento.MonitorCashback.u_deleteMoviment(cIDCash,,cFilPV,cNumPV)
            EndIf

            While ( SC6->(!Eof()) .And. SC6->C6_FILIAL == cFilPV .And. SC6->C6_NUM == cNumPV )
                cCodProduto := SC6->C6_PRODUTO
                nNewCash := SC6->C6_VALOR
                cItemPV := SC6->C6_ITEM            

                If ( lValidPorcent )
                    If ( nOperacao == OPERACAO_ALTERACAO )
                        nRecord := AScan(aUtilizado,{|x| Alltrim(x[1]) == Alltrim(cItemPV) })   

                        If (nRecord > 0)
                            If (aUtilizado[nRecord,3] > 0 .And. SC6->C6_VALDESC >= aUtilizado[nRecord,3])
                                RecLock("SC6", .F.)
                                    SC6->C6_VALDESC -= aUtilizado[nRecord,3] 
                                SC6->(MsUnlock())
                            EndIf
                        EndIf
                    EndIf
                    
                    nSaldoCash := faturamento.MonitorCashback.u_getSaldoProdutoCash(cIDCash, cCodProduto, cNumPV)
                    
                    If ( nSaldoCash > ( SC6->C6_VALOR - SC6->C6_VALDESC ) )
                        nSaldoCash := ( SC6->C6_VALOR - SC6->C6_VALDESC )
                    EndIf

                    If ( nSaldoCash > 0 )
                        If ( faturamento.MonitorCashback.u_createMoviment(MOVIMENTO_SAIDA, cIDCash, cCodProduto, nSaldoCash, cFilPV, cNumPV, cItemPV) )
                            RecLock("SC6", .F.)
                                SC6->C6_VALDESC := nSaldoCash
                            SC6->(MsUnlock())
                        Else
                            lRet := .F.
                        EndIf
                    EndIf

                    nTotalUtilizado += nSaldoCash
                    nTotalGerado += nNewCash

                    nConvTotal := faturamento.MonitorCashback.u_convertValuePorcent(cIDCash, cCodProduto, cCodCliente, cCodLoja, nTotalGerado)
                    
                    cMsg := "Pedido utilizou R$ " + cValToChar(nTotalUtilizado) + " de crédito de cashback e gerou R$ " + cValToChar(nConvTotal) + " de crédito em carteira."
                Else
                    cMsg := "Pedido não utilizou saldo de cashback por não entrar na regra de porcentagem mínima, em relação ao pedido anterior."
                EndIf
                
                aAdd(aDadosEnt, {cIDCash, cCodProduto, nNewCash, cFilPV, cNumPV, cItemPV})

                SC6->(DBSkip())
            EndDo

            If (Len(aDadosEnt) > 0)
                lRet := geraMovimentoEntrada(aDadosEnt)
            EndIf

            Aviso(NOME_EMPRESA, cMsg, { "Fechar" }, 1)
        End Sequence

        If ( !lRet )
            DisarmTransaction()
        EndIf

    End Transaction

Return lRet

/*
    Rotina responsável por enviar comando de 
    criação do movimentos de cashback
*/
Static Function geraMovimentoEntrada(aDadosEnt)
    Local nTotal    := Len(aDadosEnt)
    Local nRecord   := 0
    Local lRet      := .F.
    
    For nRecord := 1 To nTotal
        lRet := faturamento.MonitorCashback.u_createMoviment(MOVIMENTO_ENTRADA,;
                                                            aDadosEnt[nRecord, ARRAY_CASH],;
                                                            aDadosEnt[nRecord, ARRAY_PRODUTO],;
                                                            aDadosEnt[nRecord, ARRAY_VALOR],;
                                                            aDadosEnt[nRecord, ARRAY_FILPV],;
                                                            aDadosEnt[nRecord, ARRAY_PV],;
                                                            aDadosEnt[nRecord, ARRAY_ITEMPV])

        If (!lRet)
            Exit
        EndIf
    Next nRecord

Return lRet
