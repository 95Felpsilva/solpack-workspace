#Include "PROTHEUS.Ch"

/*/{Protheus.doc} A250FSD4
    O Ponto de entrada e executado na tela de atualizacao do MATA250. 
    Utilizado para filtrar as requisições empenhadas na atualização do mesmo. 
    Um retorno logico (.T.) confirma a requisicao do empenho e um retorno falso não empenha o produto. 
    Se o retorno nao for logico o sistema ira assumir .T.(verdadeiro).
    Eventos
    @type  User Function
    @author joni.santos / Ram�o Oliveira
    @since 25/03/2022
    @see Compilado pois estava requisitando duas vezes quando o apontamento ocorria via MATA103 (Retorno Beneficiamento)
    /*/

User Function A250FSD4()

    Local lRet := .T.
    local cGrupo := ''
    local cGrupoBobina := superGetMv('ZZ_GBOBINA',.F.,'4010')
    local lOPvalida    := POSICIONE('SC2',1,xFilial("SC2")+SD4->D4_OP,'SC2->C2_EMISSAO>=stod("20220704")')

    if lOPvalida
        if type('SD4->D4_COD') <> 'U'
            cGrupo := Posicione('SB1',1,xFilial('SB1')+SD4->D4_COD,'B1_GRUPO')
        endif

        if cGrupo == cGrupoBobina .and. SD4->D4_COD <> SD4->D4_PRODUTO
            lRet := .F.

        endif
    endif


Return lRet 
