/*---------------------------------------------------------------------*
 |  Projeto  : Protheus - SIGAEST                                      |
 |  Fonte    : MATA650OP.PRW                                           |
 |  Objetivo : Adicionar botão "Reabrir OP" no Outras Ações do MATA650 |
 |  Autor    : ChatGPT / Ajustado por Solon                            |
 *---------------------------------------------------------------------*/

#Include "protheus.ch"
#Include "totvs.ch"

/*---------------------------------------------------------------------*
 |  Ponto de entrada chamado pelo MATA650 para carregar ações extras   |
 |  Retorna um array com os botões personalizados                      |
 *---------------------------------------------------------------------*/
User Function MATA650()
    Local aButtons := {}

    /*--------------------------------------------------------------*
     | Adiciona botão Reabrir OP na sessão Outras Ações             |
     | Formato: { "Título", "Função Chamado" }                      |
     *--------------------------------------------------------------*/
    aAdd(aButtons, { "Reabrir OP", "U_REABROP" })

Return aButtons

/*---------------------------------------------------------------------*
 |  Função acionada ao clicar no botão "Reabrir OP"                    |
 |  Ação: limpar campo C2_DATRF e reabrir OP                           |
 *---------------------------------------------------------------------*/
User Function REABROP()

    Local cOrdem   := C2_NUM
    Local cProduto := C2_PRODUTO
    Local cFilial  := FWFilial()

    If Empty(cOrdem)
        MsgStop("Nenhuma OP selecionada!")
        Return
    EndIf

    /* Confirmação do usuário */
    If !MsgYesNo("Deseja realmente REABRIR a OP " + cOrdem + ;
                 " do produto " + cProduto + "?")
        Return
    EndIf

    /* Posiciona tabela SC2 */
    DbSelectArea("SC2")
    SC2->(DbSetOrder(1))  // Índice padrão por Filial + C2_NUM

    If !SC2->(DbSeek(cFilial + cOrdem))
        MsgStop("OP " + cOrdem + " não localizada!")
        Return
    EndIf

    /* Bloqueio e alteração */
    RecLock("SC2", .F.)
       SC2->C2_DATRF := ""   // Limpa data de referência
    MsUnlock()

    MsgInfo("OP " + cOrdem + " reaberta com sucesso!")

    /* Atualiza tela */
    FWRefreshScreen()

Return

/*---------------------------------------------------------------------*
 |  Função dummy exigida por Older AppServers                          |
 |  Evita erro ao compilar projetos com User Function raiz             |
 *---------------------------------------------------------------------*/
User Function M650OPRA()
Return
