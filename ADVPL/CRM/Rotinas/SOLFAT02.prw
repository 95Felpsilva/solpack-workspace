#include 'protheus.ch'
#include 'TopConn.ch'

/*/{Protheus.doc} User Function SOLFAT02
    TELA DE ALERTA DO CRM
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
User Function SOLFAT02()
//    local cEmpres:= '01'
//	local cFilia := '01'

    private DDTAPED     := 1
    private DPED        := 2
    private DCLI        := 3  
    private DLOJA       := 4 
    private DNOME       := 5
    private DITEM       := 6
    private DPRODUTO    := 7
    private DDESC       := 8 
    private DQTD        := 9

//	RpcSetEnv('01','01' ,'','','FAT','U_SOLFAT02',{},.F.,.T.,.T.,.T.)
/*	
    if !select('AO3')
        dbSelectArea('AO3')
        AO3->(dbSetOrder(1))
    endif

    if AO3->AO3_CODUSR <> RetCodUsr()
        if !AO3->(dbseek(xFilial('AO3')+PADR(RetCodUsr(),tamSX3('AO3_CODUSR')[1],'')))
            //msgAlert('Para acessar este programa precisa ser usuário CRM',"Usuário CRM")
            return
        endif
    endif

    if empty(AO3->AO3_ZZEQUI)
        return
    endif    
*/
    if !select('ZZ1')
        dbSelectArea('ZZ1')
        ZZ1->(dbSetOrder(1))
    endif
    if !select('ZZ2')
        dbSelectArea('ZZ2')
        ZZ2->(dbSetOrder(1))
    endif
    mostraMsg()

Return 

 

Static Function mostraMsg()
//    local aItems        := {'S=Selecione','L=Laranja','V=Verde','A=Azul'}
    private bOK		    := {|| iif(gravaDados(),oDlgIC:End(),)}
    private bCancel     := {|| aTab := {} ,oDlgIC:End()}
    private aEstrut       := {}
    private cEquipe     := ''
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
    private aTab        := {}

    cEquipe := RetCodUsr()
    cEquipeAnt := cEquipe

    buscaDadosEquipe(cEquipe)
    if empty(aTab)
        return
    endif

//    Local oOK       := LoadBitmap(GetResources(),'br_verde')
//    Local oNO       := LoadBitmap(GetResources(),'br_vermelho')

    // ADICIONANDO OS BOTÕES NA ENCHOICE
//    aAdd(aButtons,{"Incluir Pedidos",{|| incPed(oView) }, 'Incluir Pedidos',  'Incluir Pedidos' })
//    aAdd(aButtons,{"Limpar Equipe",{|| limpa() }, 'Limpar Equipe',  'Limpar Equipe' })
 

    SetPrvt("oDlgIC","oPanel1","ooBrwIC")

    oDlgIC       := MSDialog():New( 083,233,520,750,"Pedidos a Faturar",,,.F.,,,,,,.T.,,,.T. )
    oDlgIC:bInit := {||EnchoiceBar(oDlgIC,bOK,bCancel,.F.,aButtons)}

//    oSay1       := TSay():New( 41,022,{||"Equipe:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
//    oCombo      := TComboBox():New(40,40,{|u|iif(PCount()>0,cEquipe:=u,cEquipe)}, aItems,100,20,oDlgIC,,{||iif(buscaDadosEquipe(cEquipe),.T.,.F.)},,,,.T.,,,,,,,,,'cEquipe')
    oSay1       := TSay():New( 40,022,{||"Seguem os itens dos pedidos prontos para faturamento"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oSay2       := TSay():New( 60,022,{||"Mensagem Fat.:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oTMultiget1 := tMultiget():new( 70, 22, {| U | if( pCount() > 0, cObservacao := u, cObservacao ) }, oDlgIC, 100, 50, , , , , , .T.,,,,,,.F.,,,,,.T. )
    oTMultiget1:LREADONLY := .T.
    oSay3       := TSay():New( 60,142,{||"Mensagem CRM:"},,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,016)
    oTMultiget2 := tMultiget():new( 70, 142, {| U | if( pCount() > 0, cPergunta := u, cPergunta ) }, oDlgIC, 100, 50, , , , , , .T. )

    ooBrwIC       := TCBrowse():New( 130 , 10, 240 , 80 ,,aHeader,aColunas,oDlgIC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
    
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
    ooBrwIC:BlDblClick := { || vld(ooBrwIC:COLPOS)}
    oDlgIC:Activate(,,,.T.)

Return aTab


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
        lEditCell( aTab, ooBrwIC, , iCelula)
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
Static Function  buscaDadosEquipe(cEquipe)
    Local cQuery      := ""
    Local cAlias      := getNextAlias()    
    local cData       := dToS(dDataBase)
//    local lSalva      := .T.
    aTab := {}
    cEquipeAnt  := cEquipe
    cObservacao := ' '
    cPergunta   := ' '
//    oDlgIC:refresh()
    // BUSCANDO CABEÇALHO (ZZ1)

    if !ZZ1->(dbSeek(xFilial('ZZ1')+cEquipe))
        cObservacao := ' '
        cPergunta   := ' '
        /*
        oTMultiget1:refresh()
        oTMultiget2:refresh()
        ooBrwIC:SetArray(aTab)
        ooBrwIC:refresh()
        oDlgIC:refresh()
        */

        return .T.
    endif
    if !ZZ1->ZZ1_RESPON == 'C'
        RETURN
    endif
    cObservacao := ZZ1->ZZ1_OBSERV
    cPergunta   := ZZ1->ZZ1_PERGUN
//    oTMultiget1:refresh()
//    oTMultiget2:refresh()
//    oDlgIC:refresh()
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
    cQuery += "AND (ZZ2_DTAFAT = ' '"               + CRLF
    cQuery += " OR ZZ2_DTAFAT < '" + cData + "')"   + CRLF


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
                            (cAlias)->QTD       })
            endif
            (cAlias)->(dbSkip())
        enddo
    endif
    /*
    ooBrwIC:SetArray(aTab)
    ooBrwIC:refresh()
    */
Return .T.



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
    // GRAVANDO ZZ1
    begin transaction 
        ZZ1->(dbSetOrder(1))
        if ZZ1->(dbSeek(xFilial('ZZ1')+cEquipeAnt))
            if !empty(cPergunta) .and. (cPergunta <> ZZ1->ZZ1_PERGUN .or. len(cPergunta) <> len(ZZ1->ZZ1_PERGUN))
                if ZZ1->(recLock('ZZ1',.F.))
                    ZZ1->ZZ1_RESPON     := 'F'
                    ZZ1->ZZ1_PERGUN     := cPergunta
                    ZZ1->(msUnlock('ZZ1'))
                else
                    cErro := 'Erro ao Gravar ZZ1, tente novamente'
                    lRet := .F.
                    disarmTransaction()
                    break
                endif
            endif
        endif

        for iTab := 1 to len(aTab)
            cPed    := padr(aTab[iTab][DPED]    , tamSX3('ZZ2_NUM')[1],'')
            cItem   := padr(aTab[iTab][DITEM]   , tamSX3('ZZ2_ITEM')[1],'')
            cProd   := padr(aTab[iTab][DPRODUTO], tamSX3('ZZ2_PRODUTO')[1],'')
            nQtd    := aTab[iTab][DQTD]
            ddta    := aTab[iTab][DDTAPED]
            ZZ2->(dbSetOrder(1))
            if ZZ2->(dbseek(xFilial('ZZ2')+cEquipeAnt+cPed+cItem+cProd))
                if !empty(ddta)
                    if ZZ2->(recLock('ZZ2',.F.))
//                    ZZ2->ZZ2_QTDVEN := nQtd
                        ZZ2->ZZ2_DTAFAT := ddta
                        ZZ2->(msUnlock())
                    else
                        cErro := 'Erro ao Gravar ZZ2, tente novamente'
                        disarmTransaction()
                        break
                    endif
                endif
            endif

        next iTab
    end transaction
    if !empty(cErro)
        msgAlert(cErro)
    endif

Return lRet
