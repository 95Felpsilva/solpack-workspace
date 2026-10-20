#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

WSRESTFUL pedidoVenda DESCRIPTION 'Rotas de Pedido de venda'
  WSMETHOD POST cadastrarPedidoVenda   DESCRIPTION "Api de inclusão de pedido de venda"    WSSYNTAX "/cadastrar"
END WSRESTFUL

WSMETHOD POST cadastrarPedidoVenda WSSERVICE pedidoVenda
  // Recebe o Retorno
  Local cBody     := ''                         // Recebe o conteudo do Rest
  Local oJson     := JsonObject():new()         // Recebe o JSON de Entrada
  Local oJsonRet  := JsonObject():new()         // Recebe o JSON de Entrada

  Local aCabec    := {}
  Local aItens    := {}
  Local aLinha    := {}
  Local aLogAuto  := {}
  Local nOper     := 3
  Local cErro     := ''
  Local lRet      := .T.
  Local nI
  Local nY

  Private lMsErroAuto := .F.
  Private lMsHelpAuto     := .F.
  Private lAutoErrNoFile  := .T.

  // Pega o conteudo JSON da transação Rest
  cBody := ::GetContent()
  ::SetContentType("application/json")

  oJson:fromJson(cBody)

  DbSelectArea('SA1')
  DbSetOrder(1)

  RpcSetEnv(oJson["empresa"], oJson["filial"])
  
  if !SA1->(MsSeek(xFilial('SA1') + oJson["codCli"]))
    SetRestFault(500,"Cliente nao cadastrado")
  else
    aAdd(aCabec,{'C5_TIPO'   ,  oJson["tipoPed"]    , NIL})
    aAdd(aCabec,{'C5_VEND1'  ,  oJson["codVend"]    , NIL})
    aAdd(aCabec,{'C5_NATUREZ',  oJson["codNatureza"]    , NIL})
    aAdd(aCabec,{'C5_CLIENTE',  oJson["codCli"] , NIL})
    aAdd(aCabec,{'C5_LOJACLI',  oJson["lojaCli"] , NIL})
    aAdd(aCabec,{'C5_TPFRETE',  oJson["tipoFrete"]  , NIL})
    aAdd(aCabec,{'C5_TRANSP' ,  oJson["codTrans"]  , NIL})

    if oJson["codRedespacho"]!=''
      aAdd(aCabec,{'C5_REDESP' ,  oJson["codRedespacho"]  , NIL})
      aAdd(aCabec,{'C5_ZZTFRET' ,  oJson["tipoFreteRed"]  , NIL})
    endif

    aAdd(aCabec,{'C5_FRETE'   ,  oJson["valFrete"]  , NIL})
    aAdd(aCabec,{'C5_FORPGT' ,  oJson["FormPag"]  , NIL})
    aAdd(aCabec,{'C5_CONDPAG',  oJson["condPag"] , NIL})
    aAdd(aCabec,{'C5_ZZPAR1', oJson["valAntecipa"]  , NIL})
    aAdd(aCabec,{'C5_PARC1' , oJson["valParc1"]  , NIL})
    aAdd(aCabec,{'C5_DATA1' , StoD(oJson["dtVenc1"])  , NIL})
    aAdd(aCabec,{'C5_PARC2' , oJson["valParc2"]  , NIL})
    aAdd(aCabec,{'C5_DATA2' , StoD(oJson["dtVenc2"])  , NIL})
    aAdd(aCabec,{'C5_PARC3' , oJson["valParc3"]  , NIL})
    aAdd(aCabec,{'C5_DATA3' , StoD(oJson["dtVenc3"])  , NIL})
    aAdd(aCabec,{'C5_PARC4' , oJson["valParc4"]  , NIL})
    aAdd(aCabec,{'C5_DATA4' , StoD(oJson["dtVenc4"])  , NIL})
    aAdd(aCabec,{'C5_PARC5' , oJson["valParc5"]  , NIL})
    aAdd(aCabec,{'C5_DATA5' , StoD(oJson["dtVenc5"])  , NIL})
    aAdd(aCabec,{'C5_PARC6' , oJson["valParc6"]  , NIL})
    aAdd(aCabec,{'C5_DATA6' , StoD(oJson["dtVenc6"])  , NIL})
    aAdd(aCabec,{'C5_ZZOBS' , oJson["obs"], NIL})
    aAdd(aCabec,{'C5_ZZIFCPL' , oJson["infoComplem"], NIL})

    aCabec := FWVetByDic(aCabec, "SC5")
    
    for nI := 1 To len(oJson["itens"])
      aLinha := {}
      aAdd(aLinha,{'C6_ITEM'   , StrZero(nI,2), NIL})
      aAdd(aLinha,{'C6_PRODUTO', oJson["itens"][nI]["codigo"] , NIL})
      aAdd(aLinha,{'C6_ZZDESCR', oJson["itens"][nI]["decrAdicional"] , NIL})
      aAdd(aLinha,{'C6_ZZVOL1 ', oJson["itens"][nI]["volume"] , NIL})
      aAdd(aLinha,{'C6_QTDVEN' , oJson["itens"][nI]["qtdVen"] , NIL})
      aAdd(aLinha,{'C6_PRCVEN' , oJson["itens"][nI]["prcVen"] , NIL})
      // aAdd(aLinha,{'C6_PRUNIT' , oJson["itens"][nI]["prcLista"] , NIL})
      aAdd(aLinha,{'C6_DESCONT', oJson["itens"][nI]["perDesc"] , NIL})
      aAdd(aLinha,{'C6_VALDESC', oJson["itens"][nI]["desconto"] , NIL})
      aAdd(aLinha,{'C6_VALOR',   oJson["itens"][nI]["total"]  , NIL})
      aAdd(aLinha,{'C6_OPER',    oJson["itens"][nI]["tpOperacao"]    , NIL})
      aAdd(aLinha,{'C6_TES',     oJson["itens"][nI]["tes"]    , NIL})
      aAdd(aLinha,{'C6_LOCAL',   oJson["itens"][nI]["armazem"]  , NIL})
      aAdd(aLinha,{'C6_ZZDTFAT', StoD(oJson["itens"][nI]["faturamento"])  , NIL})
      aAdd(aLinha,{'C6_ENTREG',  StoD(oJson["itens"][nI]["entrega"])  , NIL})

      aLinha := FWVetByDic(aLinha, "SC6")

      aAdd(aItens, aLinha)
    next

    //? Executa a rotina automática
    MSExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, nOper) 
    
    if lMsErroAuto
      aLogAuto := GetAutoGrLog()
      For nY := 1 To Len(aLogAuto)
        cErro += aLogAuto[nY] + CRLF
      Next nY
      SetRestFault(500, cErro)
      lRet := .F.
    else
        oJsonRet["Status"] := "Cadastro Efetuado com sucesso, Pedido:" + SC5->C5_NUM
        oJsonRet["pedido"] := SC5->C5_NUM
        ::SetResponse(oJsonRet)
    endif
  endif
Return lRet



