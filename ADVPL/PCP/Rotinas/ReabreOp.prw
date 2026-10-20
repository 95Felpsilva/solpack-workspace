#Include "protheus.ch"

////////////////////////////////////////////////////////////////////////////////////////
// Ponto de entrada: MT650ACTIONS
// Adiciona o botão "Reabrir OP" no menu Outras Ações do MATA650
////////////////////////////////////////////////////////////////////////////////////////
User Function MT650ACTIONS()
    Local aMenu  := {}
    Local aSuper := SuperGetAction()

    // carrega o menu original, caso exista
    If ValType(aSuper) == "A"
        aMenu := aSuper
    EndIf

    // adiciona a opção "Reabrir OP"
    AAdd(aMenu, {"Reabrir OP", "U_REABREOP", 0})

Return aMenu


////////////////////////////////////////////////////////////////////////////////////////
// Função: U_REABREOP
// Finalidade: Reabrir OP limpando o campo C2_DATRF
////////////////////////////////////////////////////////////////////////////////////////
User Function REABREOP()
    Local cFil    := xFilial("SC2")     // usa xFilial padrão do Protheus
    Local cNumOP  := M->C2_NUM
    Local cItemOP := M->C2_ITEM

    // Validar se existe seleção
    If Empty(cNumOP)
        MsgStop("Nenhuma OP selecionada.", "Reabrir OP")
        Return
    EndIf

    // Abrir tabela
    DbSelectArea("SC2")
    DbSetOrder(1)       // índice deve ser FILIAL+NUM+ITEM (verifique no SIGACFG)

    If !DbSeek(cFil + cNumOP + cItemOP)
        MsgStop("OP não encontrada na tabela SC2.", "Reabrir OP")
        Return
    EndIf

    /////////////////////////////////////////
    // "REABERTURA" – limpa C2_DATRF
    /////////////////////////////////////////
    RecLock("SC2", .T.)
        SC2->C2_DATRF := ""   // limpa campo que indica fechamento
    MsUnlock()

    MsgInfo("OP " + cNumOP + " reaberta com sucesso!", "Reabrir OP")

    /////////////////////////////////////////
    // Atualiza a tela (super refresh)
    /////////////////////////////////////////
    If ExistBlock("MENU_REFRESH")
        MENU_REFRESH()        // função nativa em várias telas padrão
    EndIf

Return
