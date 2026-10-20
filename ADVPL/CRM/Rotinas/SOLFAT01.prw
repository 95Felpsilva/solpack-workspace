#include 'protheus.ch'
#include 'TopConn.ch'

/*/{Protheus.doc} User Function SOLFAT01
    Tela para envio de mensagem ao CRM
    @type  Function
    @author Ramão Oliveira
    @since 15/03/2022
    @version 01
    @param , , 
    @return , ,  
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function SOLFAT01(oView,pEquipe)

    private DDTAPED     := 1
    private DPED        := 2
    private DCLI        := 3  
    private DLOJA       := 4 
    private DNOME       := 5
    private DITEM       := 6
    private DPRODUTO    := 7
    private DDESC       := 8 
    private DQTD        := 9
    private DRECNO      := 10


  
    if !select('ZZ1')
        dbSelectArea('ZZ1')
        ZZ1->(dbSetOrder(1))
    endif
    if !select('ZZ2')
        dbSelectArea('ZZ2')
        ZZ2->(dbSetOrder(1))
    endif
    mostraMsg(oView,pEquipe)

Return 

 

Static Function mostraMsg(oView, pEquipe)
    local aItems        := {'S=Selecione','L=Laranja','V=Verde','A=Azul'}
    local aVendedores   := {}
    local lVendedores   := .T.
    local iVendedores   := 0
    private bOK		    := {|| iif(gravaDados(),oDlgIC:End(),)}
    private bCancel     := {|| aTab := {} ,oDlgIC:End()}
    private aEstrut       := {}
    private cEquipe     := {}
    private aHeader     := {'Data a Fat','Pedido','Cliente','Loja','Nome', 'Item','Produto','Descrição','Quantidade'}
//    private aCampos     := {'ZZ2_DTAFAT','ZZ2_NUM','ZZ2_ITEM','ZZ2_PRODUT','ZZ2_QTDVEN'}
    private aColunas    := {30,30,30,5,60,30,80,40,40}
    private cObservacao := ''
    private cPergunta   := ''
    private cEquipeAnt  := 'S'
    private oDlgIC      := nil
    private oTMultiget1 := nil
    private oTMultiget2 := nil
    private ooBrwIC     := nil
    private aButtons    := {}
    private aTab        := {{sTod('        '),' ',' ',' ',' ',' ',' ',' ',0,}}
    private lResposta   := .F.
    
    aVendedores := buscaVendedoresCRM()
    if lVendedores .and. !empty(aVendedores)
        aItems := {}
        aadd(aItems,'S=Selecione')
        for iVendedores := 1 to len(aVendedores)
            aadd(aItems,aVendedores[iVendedores][1] + '=' + aVendedores[iVendedores][2])
        next iVendedores
    endif
    

    if !empty(pEquipe)
        lResposta := .T.
        cEquipe := pEquipe
        cEquipeAnt := 'S'
        buscaDadosEquipe(cEquipe,.T.)
    endif


//    Local oOK       := LoadBitmap(GetResources(),'br_verde')
//    Local oNO       := LoadBitmap(GetResources(),'br_vermelho')

    // ADICIONANDO OS BOTÕES NA ENCHOICE
    if !empty(oView)
        aAdd(aButtons,{"Incluir Pedidos",{|| incPed(oView) }, 'Incluir Pedidos',  'Incluir Pedidos' })
    endif
    aAdd(aButtons,{"Limpar",{|| limpa() }, 'Limpar',  'Limpar' })
 

    SetPrvt("oDlgIC","oPanel1","ooBrwIC")

    oDlgIC       := MSDialog():New( 083,233,560,750,"Pedidos a Faturar",,,.F.,,,,,,.T.,,,.T. )
    oDlgIC:bInit := {||EnchoiceBar(oDlgIC,bOK,bCancel,.F.,aButtons)}

    oSay1       := TSay():New( 41,022,{||"Destino:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oCombo      := TComboBox():New(40,40,{|u|iif(PCount()>0,cEquipe:=u,cEquipe)}, aItems,100,20,oDlgIC,,{||iif(buscaDadosEquipe(cEquipe,.F.),.T.,.F.)},,,,.T.,,,,/*{|| iif(lResposta,.F.,.T.)} */,,,,,'cEquipe')
//    oSay1       := TSay():New( 40,022,{||"Seguem os itens dos pedidos prontos para faturamento"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oSay2       := TSay():New( 60,022,{||"Mensagem Fat.:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oTMultiget1 := tMultiget():new( 70, 22, {| U | if( pCount() > 0, cObservacao := u, cObservacao ) }, oDlgIC, 100, 50, , , , , , .T.,,,,,,.F.,,,,,.T. )
    
    oSay3       := TSay():New( 60,142,{||"Mensagem CRM:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oTMultiget2 := tMultiget():new( 70, 142, {| U | if( pCount() > 0, cPergunta := u, cPergunta ) }, oDlgIC, 100, 50, , , , , , .T. )

    ooBrwIC       := TCBrowse():New( 130 , 10, 240 , 80 ,,aHeader,aColunas,oDlgIC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
    oTButton1 := TButton():New( 210, 010, "Excluir",oDlgIC,{||excluiLinha(ooBrwIC:nAt)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton1 := TButton():New( 210, 100, "Limpa Data",oDlgIC,{||limpaData(ooBrwIC:nAt)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    

    ooBrwIC:SetArray(aTab)
    ooBrwIC:AddColumn(TCColumn():New("Data a Fat",{||aTab[ooBrwIC:nAt,1] },,,,"LEFT",30,.F.,.T.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Pedido",{||aTab[ooBrwIC:nAt,2] },,,,"LEFT",30,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Cliente",{||aTab[ooBrwIC:nAt,3] },,,,"LEFT",30,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Loja",{||aTab[ooBrwIC:nAt,4] },,,,"LEFT",10,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Nome",{||aTab[ooBrwIC:nAt,5] },,,,"LEFT",50,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Item",{||aTab[ooBrwIC:nAt,6] },,,,"LEFT",10,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Produto",{||aTab[ooBrwIC:nAt,7] },,,,"LEFT",40,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New("Descrição",{||aTab[ooBrwIC:nAt,8] },,,,"LEFT",50,.F.,.F.,,,,.F.,))
    ooBrwIC:AddColumn(TCColumn():New('Quantidade',{||aTab[ooBrwIC:nAt,9] },"@E 999,999,999.999",,,"RIGHT",50,.F.,.F.,, ,,.F.,))
//    ooBrwIC:BlDblClick := { || iif(!empty(aTab),vld(ooBrwIC:COLPOS),)}
    oDlgIC:Activate(,,,.T.)

Return aTab


/*/{Protheus.doc} excluiLinha
    (long_description)
    @type  Static Function
    @author Ramão Oliveira
    @since 01/04/2022
    @version 01
    @param iLinha, , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function excluiLinha(iLinha)
    if !empty(aTab)
        if !empty(aTab[iLinha][DRECNO])
            ZZ2->(dbSetOrder(1))
            ZZ2->(dbGoTo(aTab[iLinha][DRECNO]))
            if ZZ2->(recno()) == aTab[iLinha][DRECNO]
                if ZZ2->(recLock('ZZ2',.F.))
                    ZZ2->(dbDelete())
                    ZZ2->(msUnlock())
                endif
            endif
        endif
        ADel( aTab, iLinha )
        ASize( aTab, len(aTab) - 1 )
    endif

    ooBrwIC:SetArray(aTab)
    ooBrwIC:refresh()
    oDlgIC:refresh()
Return 

/*/{Protheus.doc} limpaData
    (long_description)
    @type  Static Function
    @author Ramão
    @since 08/04/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function limpaData(iLinha)
    if !empty(aTab)
        if !empty(aTab[iLinha][DRECNO])
            ZZ2->(dbSetOrder(1))
            ZZ2->(dbGoTo(aTab[iLinha][DRECNO]))
            if ZZ2->(recno()) == aTab[iLinha][DRECNO]
                if ZZ2->(recLock('ZZ2',.F.))
                    ZZ2->ZZ2_DTAFAT = sTod('        ')
                    ZZ2->(msUnlock())
                endif
            endif
        endif
        aTab[iLinha][DDTAPED] := sTod('        ')
    endif

    ooBrwIC:refresh()
    oDlgIC:refresh()
Return 

/*/{Protheus.doc} vld
    (long_description)
    @type  Static Function
    @author Ramão Oliveira
    @since 18/03/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function vld(iCelula)
    if alltrim(cValtoChar(iCelula)) $ '1'
        lEditCell( aTab, ooBrwIC, , ooBrwIC:COLPOS)
    endif
Return 





/*/{Protheus.doc}  buscaDadosEquipe
    Busca Dados da Equipe
    @type  Static Function
    @author Ramão Oliveira
    @since 18/03/2022
    @version 1
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function  buscaDadosEquipe(cEquipe,lInicio)
    Local cQuery      := ""
    Local cAlias      := getNextAlias()    
    local lSalva      := .T.
    if !empty(cEquipeAnt) .and. cEquipeAnt <> 'S' .and. !lInicio
        lSalva := MsgYesNo('Deseja gravar os dados ?', 'Salvar os dados')
        if lSalva
            if !gravaDados()
                return .f.
            endif
        endif
    endif
    aTab := {}
    cEquipeAnt := cEquipe
    cObservacao := ' '
    cPergunta   := ' '
//    oDlgIC:refresh()
    // BUSCANDO CABEÇALHO (ZZ1)

    if !ZZ1->(dbSeek(xFilial('ZZ1')+cEquipe))
        cObservacao := ' '
        cPergunta   := ' '
        if !lInicio
            oTMultiget1:refresh()
            oTMultiget2:refresh()
            ooBrwIC:SetArray(aTab)
            ooBrwIC:refresh()
            oDlgIC:refresh()
        endif
        return .T.
    endif
    cObservacao := ZZ1->ZZ1_OBSERV
    cPergunta   := ZZ1->ZZ1_PERGUN
    if !lInicio
        oTMultiget1:refresh()
        oTMultiget2:refresh()
        oDlgIC:refresh()
    endif
    // BUSCANDO OS PEDIDOS JÁ VINCULADOS
    cQuery += "SELECT "                             + CRLF
    cQuery += "ZZ2_DTAFAT  AS DTAFAT,"              + CRLF
    cQuery += "ZZ2_NUM     AS PED,"                 + CRLF
    cQuery += "A1_COD      AS CLI,"                 + CRLF
    cQuery += "A1_LOJA     AS LOJA,"                + CRLF
    cQuery += "A1_NOME     AS NOME,"                + CRLF
    cQuery += "ZZ2_ITEM    AS ITEM,"                + CRLF
    cQuery += "ZZ2_PRODUT  AS PRODUTO,"             + CRLF
    cQuery += "B1_DESC     AS DESCRI,"              + CRLF
    cQuery += "ZZ2_QTDVEN  AS QTD,"                 + CRLF
    cQuery += "C6_NOTA     AS NOTA,"                + CRLF
    cQuery += "ZZ2.R_E_C_N_O_ AS RECNO"             + CRLF    
    cQuery += "FROM " + retSqlTab("ZZ2")            + CRLF // ZZ2
    cQuery += "INNER JOIN " + retSqlTab("SC5")      + CRLF // SC5
    cQuery += " ON" + retSqlfil("SC5")              + CRLF
    cQuery += "AND C5_NUM = ZZ2_NUM"                + CRLF
    cQuery += "AND" + retSqldel("SC5")              + CRLF
    cQuery += "INNER JOIN " + retSqlTab("SA1")      + CRLF // SA1
    cQuery += " ON" + retSqlfil("SA1")              + CRLF
    cQuery += "AND A1_COD = C5_CLIENTE"             + CRLF
    cQuery += "AND A1_LOJA = C5_LOJACLI"            + CRLF
    cQuery += "AND" + retSqldel("SA1")              + CRLF
    cQuery += "INNER JOIN " + retSqlTab("SC6")      + CRLF // SC6
    cQuery += " ON" + retSqlfil("SC6")              + CRLF
    cQuery += "AND C6_NUM = ZZ2_NUM"                + CRLF
    cQuery += "AND C6_ITEM = ZZ2_ITEM"              + CRLF
    cQuery += "AND C6_PRODUTO = ZZ2_PRODUT"         + CRLF
    cQuery += "AND" + retSqldel("SC6")              + CRLF
    cQuery += "INNER JOIN " + retSqlTab("SB1")      + CRLF // SB1
    cQuery += " ON" + retSqlfil("SB1")              + CRLF
    cQuery += "AND B1_COD = ZZ2_PRODUT"             + CRLF
    cQuery += "AND" + retSqldel("SB1")              + CRLF
    cQuery += "WHERE " + retSqlfil("ZZ2")           + CRLF // ZZ2
    cQuery += "AND " + retSqldel("ZZ2")             + CRLF
    cQuery += "AND ZZ2_EQUIPE = '" + cEquipe + "'"  + CRLF

    tcQuery cQuery new alias &cAlias // QUERY

    aTab := {}
    if (cAlias)->(!eof())
        while (cAlias)->(!eof())
            if !empty((cALias)->NOTA)
                ZZ2->(dbGoTo((cALias)->RECNO))
                if ZZ2->(recno()) == (cALias)->RECNO
                    ZZ2->(recLock('ZZ2',.F.))
                    ZZ2->(dbDelete())
                    ZZ2->(msUnlock())
                endif
            else
                aadd(aTab,{ sToD((cAlias)->DTAFAT),; 
                            (cALias)->PED       ,;
                            (cAlias)->CLI       ,;
                            (cAlias)->LOJA      ,;
                            (cAlias)->NOME      ,;
                            (cAlias)->ITEM      ,;
                            (cAlias)->PRODUTO   ,;
                            (cAlias)->DESCRI    ,;
                            (cAlias)->QTD       ,;
                            (cAlias)->RECNO     })
            endif
            (cAlias)->(dbSkip())
        enddo
    endif
    if !lInicio
        ooBrwIC:SetArray(aTab)
        ooBrwIC:refresh()
    endif
Return .t.



/*/{Protheus.doc} gravaDados
    (long_description)
    @type  Static Function
    @author Ramão Oliveira
    @since 18/03/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function gravaDados()
    local iTab := 0
    local cPed := ''
    local cItem := ''
    local cProd := ''
    local nQtd  := 0
    local ddta  := nil
    local cErro := ''
    local lRet := .T.
    if cEquipeAnt == 'S'
        return lRet
    endif
    // GRAVANDO ZZ1
    begin transaction 
        ZZ1->(dbSetOrder(1))
        if !ZZ1->(dbSeek(xFilial('ZZ1')+cEquipeAnt))
            if ZZ1->(recLock('ZZ1',.T.))
                ZZ1->ZZ1_FILIAL     := xFilial('ZZ1')
                ZZ1->ZZ1_EQUIPE     := cEquipeAnt
                ZZ1->ZZ1_OBSERV     := cObservacao
                ZZ1->ZZ1_PERGUN     := cPergunta
                ZZ1->ZZ1_RESPON     := 'C'
                ZZ1->(msUnlock('ZZ1'))
            else
                cErro := 'Erro ao Gravar ZZ1, tente novamente'
                lRet := .F.
                disarmTransaction()
                break
            endif
        else
            if ZZ1->(recLock('ZZ1',.F.))
                if cObservacao <> ZZ1->ZZ1_OBSERV .or. len(cObservacao) <> len(ZZ1->ZZ1_OBSERV)
                    ZZ1->ZZ1_RESPON     := 'C'
                endif
                ZZ1->ZZ1_OBSERV     := cObservacao
                ZZ1->ZZ1_PERGUN     := cPergunta
                
                ZZ1->(msUnlock('ZZ1'))
            else
                cErro := 'Erro ao Gravar ZZ1, tente novamente'
                lRet := .F.
                disarmTransaction()
                break
            endif

        endif

        for iTab := 1 to len(aTab)
            cPed    := padr(aTab[iTab][DPED]    , tamSX3('ZZ2_NUM')[1],'')
            cItem   := padr(aTab[iTab][DITEM]   , tamSX3('ZZ2_ITEM')[1],'')
            cProd   := padr(aTab[iTab][DPRODUTO], tamSX3('ZZ2_PRODUTO')[1],'')
            nQtd    := aTab[iTab][DQTD]
            ddta    := aTab[iTab][DDTAPED]
            ZZ2->(dbSetOrder(1))
            if !ZZ2->(dbseek(xFilial('ZZ2')+cEquipeAnt+cPed+cItem+cProd))
                if ZZ2->(recLock('ZZ2',.T.))
                    ZZ2->ZZ2_FILIAL := xFilial('ZZ2')
                    ZZ2->ZZ2_EQUIPE := cEquipeAnt
                    ZZ2->ZZ2_NUM    := cPed
                    ZZ2->ZZ2_ITEM   := cItem
                    ZZ2->ZZ2_PRODUT := cProd
                    ZZ2->ZZ2_QTDVEN := nQtd 
                    ZZ2->ZZ2_DTAFAT := ddta
                    ZZ2->(msUnlock())
                else
                    cErro := 'Erro ao Gravar ZZ2, tente novamente'
                    disarmTransaction()
                    break
                endif
            else
                if ZZ2->(recLock('ZZ2',.F.))
                    ZZ2->ZZ2_QTDVEN := nQtd
                    ZZ2->ZZ2_DTAFAT := ddta
                    ZZ2->(msUnlock())
                else
                    cErro := 'Erro ao Gravar ZZ2, tente novamente'
                    disarmTransaction()
                    break
                endif
            endif

        next iTab
    end transaction
    if !empty(cErro)
        msgAlert(cErro)
    endif

Return lRet





/*/{Protheus.doc} incPed
    Inclui os pedidos marcados na tela SeqLibPed
    @type  Static Function
    @author Ramão Oliveira
    @since 22/03/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function incPed(oView)
    local oModel    := oView:getModel()
	local oGrid     := oModel:getModel(cIDGrid)
	local nQtdLine  := oGrid:Length()
    local nLine     := 0
    local cCliente  := ''
    local cLoja     := ''
    local cNome     := ''
    local cProd     := ''
    local cDesc     := ''
//    local iTab      := 0
//    local cPed      := ''
//    local cItem     := ''
    
    if empty(cEquipe) .or. cEquipe == 'S'
        msgAlert('Selecione o Destinatario')
        return .F.
    endif
//	local lMark	   := .f.
//	local aProd	   := {}
//	local nProd    := 0
    
    for nLine := 1 to nQtdLine
        cNome := ''
        cDesc := ''
        
		oGrid:goLine(nLine)
        if oGrid:isDeleted() .or. !oGrid:getValue("CRM")
			loop
		endif
        SC9->(dbGoTo(oGrid:getValue("C9RECNO")))
        if SC9->(RECNO()) == oGrid:getValue("C9RECNO")
            cCliente := padr(SC9->C9_CLIENTE,tamSX3('A1_COD')[1],'')
            cLoja    := padr(SC9->C9_LOJA,tamSX3('A1_LOJA')[1],'')
            cProd    := padr(SC9->C9_PRODUTO,tamSX3('B1_COD')[1],'')
            if aScan(aTab,{|x| alltrim(x[DPED])+alltrim(x[DITEM]) == alltrim(SC9->C9_PEDIDO) +alltrim(SC9->C9_ITEM) })
                loop
            endif
            if !select('SA1')
                dbSelectArea('SA1')
            endif
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial('SA1')+cCliente+cLoja))
            if SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA == xFilial('SA1')+cCliente+cLoja
            cNome := SA1->A1_NOME
            endif
            if !select('SB1')
                dbSelectArea('SB1')
            endif
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial('SB1')+cProd))
            if SB1->B1_FILIAL + SB1->B1_COD == xFilial('SB1')+cProd
                cDesc := SB1->B1_DESC
            endif
        //{'Data a Fat','Pedido','Cliente','Loja','Nome', 'Item','Produto','Descrição','Quantidade'}
            aadd(aTab,{sTod('        ') ,;
                SC9->C9_PEDIDO          ,;
                SC9->C9_CLIENTE         ,;
                SC9->C9_LOJA            ,;
                cNome                   ,;
                SC9->C9_ITEM            ,;
                SC9->C9_PRODUTO         ,;
                cDesc                   ,;
                SC9->C9_QTDLIB          ,;
                nil})
        //SA1->A1_NOME SB1->B1_DESC
        endif

    next nLine
//    ooBrwIC:SetArray(aTab)
//    ooBrwIC:bLine := {||aEstrut }
    ooBrwIC:SetArray(aTab)
    ooBrwIC:refresh()
//    ooBrwIC:DrawSelect()
//    oDlgIC:refresh() 
Return 



/*/{Protheus.doc} limpa
    (long_description)
    @type  Static Function
    @author Ramão Oliveira
    @since 25/03/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
*/
Static Function limpa()
    local lApaga := .F.
    local iTab := 0
    local cPed := ''
    local cItem := ''
    local cProd := ''
//    local nQtd  := 0
//    local ddta  := nil
    local cErro := ''
    local lRet := .T.
    if cEquipeAnt == 'S'
        msgAlert('Não é possível limpar dados sem antes selecionar um Destinatário!','Limpar')
        return 
    endif

    lApaga := MsgYesNo('Deseja Limpar os dados?' + CRLF + 'Atenção! Ao limpar, não será possível restaurar os pedidos vinculados.', 'Limpar')
    if !lApaga
        return
    endif

    // Apagando ZZ1
    begin transaction 
        ZZ1->(dbSetOrder(1))
        if ZZ1->(dbSeek(xFilial('ZZ1')+cEquipe))
            if ZZ1->(recLock('ZZ1',.F.))
                ZZ1->(dbDelete())
                ZZ1->(msUnlock('ZZ1'))
            else
                cErro := 'Erro ao Apagar ZZ1, tente novamente'
                lRet := .F.
                disarmTransaction()
                break
            endif
        endif

        for iTab := 1 to len(aTab)
            cPed    := padr(aTab[iTab][DPED]    , tamSX3('ZZ2_NUM')[1],'')
            cItem   := padr(aTab[iTab][DITEM]   , tamSX3('ZZ2_ITEM')[1],'')
            cProd   := padr(aTab[iTab][DPRODUTO], tamSX3('ZZ2_PRODUTO')[1],'')
            ZZ2->(dbSetOrder(1))
            if ZZ2->(dbseek(xFilial('ZZ2')+cEquipe+cPed+cItem+cProd))
                if ZZ2->(recLock('ZZ2',.F.))
                    ZZ2->(dbDelete())
                    ZZ2->(msUnlock())
                else
                cErro := 'Erro ao Apagar ZZ2, tente novamente'
                disarmTransaction()
                break
                endif
            endif

        next iTab
        
    end transaction
    
    if !empty(cErro)
        msgAlert(cErro)
        return 
    endif
    // limpando variáveis
    cObservacao := ' '
    cPergunta   := ' '
    aTab := {}
    oTMultiget1:refresh()
    oTMultiget2:refresh()
    ooBrwIC:SetArray(aTab)
    ooBrwIC:refresh()
    oDlgIC:refresh()
Return 


Static Function buscaVendedoresCRM()
    aVendedores := {}
    Local cQuery      := ""
    Local cAlias      := getNextAlias()    

    cQuery += "SELECT "                             + CRLF
    cQuery += "AO3_CODUSR  AS COD,"                 + CRLF
    cQuery += "USR_CODIGO  AS ABREV,"               + CRLF
    cQuery += "USR_NOME    AS NOME"                 + CRLF
    cQuery += "FROM " + retSqlTab("AO3")            + CRLF 
    cQuery += "INNER JOIN SYS_USR USR"              + CRLF 
    cQuery += "ON USR_ID = AO3_CODUSR"              + CRLF 
    cQuery += "AND USR.D_E_L_E_T_ = ' '"            + CRLF
    cQuery += "AND USR_MSBLQL = '2'"                + CRLF
    cQuery += "WHERE " + retSqlfil("AO3")           + CRLF 
    cQuery += "AND " + retSqldel("AO3")             + CRLF
    cQuery += "AND AO3_ZZEQUI <> ''"                + CRLF

    tcQuery cQuery new alias &cAlias 

    if (cAlias)->(!EOF())
        while (cAlias)->(!EOF())
            aadd(aVendedores,{(cAlias)->COD,(cAlias)->ABREV,(cAlias)->NOME})
            (cAlias)->(dbSkip())
        enddo
    endif
    (cAlias)->(dbCloseArea())
Return aVendedores
