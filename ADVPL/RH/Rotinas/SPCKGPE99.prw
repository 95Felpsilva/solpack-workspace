#INCLUDE "topconn.ch"
#include "protheus.ch"

#include "TbiConn.ch"

#define linha chr(13)+chr(10)

/*-------------------------------------------------------------------------------.\
/| Programa : SPCKGPE99.prw              | Autor : Leonardo Bergamasco           |\
/|-------------------------------------------------------------------------------|\
/| Data     : 16/11/2022                 | Alteracao:                            |\
/|-------------------------------------------------------------------------------|\
/|    ********** INTEGRACAO  **********                ** UNICO X PROTHEUS **    |\
/|-------------------------------------------------------------------------------|\
/| Descricao: Integracao de dados - SIGAGPE                                      |\
/.------------------------------------------------------------------------------.*/
//                              ALTERACOES
//

User Function SPCKGPE99()

    //** Variaveis de Dimensao da tela **\\
    Local aAdvSize     := MsAdvSize( NIL , .F. )
    Local aInfoAdvSize := {aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0}
    Local aObjCoords   := {{100 , 000 , .T. , .T.}}
    Local aObjSize     := MsObjSize( aInfoAdvSize , aObjCoords )

    Private nTop,nLeft,nBottom,nRight,nXY, nBottomDT

    Private cQuery  := ""

    //** Variaveis de MSNewGetDados **\\
    Private oGestao, oPanel, oDGano, aDGano, oDGdet, nAntAtual
    Private xHeader  := {{},{}}
    Private aCpoEdit := {{},{}}
    Private nPosAA := ""
    Private cMatAUT := "010000,010001"

    Private oFont16 := TFont():New('Arial',,-16,,.T.) 

    Private oBran := LoadBitmap( GetResources(), "BR_BRANCO")  //Esfera Branca
    Private oVerd := LoadBitmap( GetResources(), "BR_VERDE")   //Esfera Verde
    Private oAmar := LoadBitmap( GetResources(), "BR_AMARELO") //Esfera Amarela
    Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO")//Esfera Vermelha

    //** Carrega as Dimensoes de tela
    nXY     := {aAdvSize[6],aAdvSize[5]} //Tamanho da Tela
    nTop    := aObjSize[1][1] - 35
    nLeft   := aObjSize[1][2]
    nBottom := aObjSize[1][3]
    nRight  := aObjSize[1][4]

    fHeader()
    fZUP("ANO",0)

    //** Montagem da TELA de manutenção **\\
    Define MsDialog oGestao Title "Monitoramento de integração"  From 0,0 To nXY[1], nXY[2] Of oMainWnd Pixel
      
        oPanel := tPanel():New(10,15,"",oGestao, ,.T.,,CLR_YELLOW,SetTransparentColor(8421504, 80),70,30)
        TBtnBmp2():New(15, 02,26,26,'OPERACAO' ,,,,{|| Processa( { || CursorWait() , fPonto()   , CursorArrow() } , "Importando os registros...") },oPanel,,,.F. )
        TBtnBmp2():New(15, 33,26,26,'S4WB013N' ,,,,{|| oGestao:End()},oPanel,,,.F. )
        TBtnBmp2():New(15, 64,26,26,'PROJETPMS',,,,{|| Processa( { || CursorWait() , fLerArq(""), CursorArrow() } , "Importando os registros...") },oPanel,,,.F. )
        TBtnBmp2():New(15,100,26,26,'FINAL'    ,,,,{|| oGestao:End()},oPanel,,,.F. )
        
        TSay():New(50,10,{|| "Ano Referencia" },oGestao,, oFont16 ,,,,.T.,CLR_RED,CLR_WHITE,100,10)
        oDGano := MSNewGetDados():New(60,10,nBottom-10,90, 3,,"AlwaysTrue",,aCpoEdit[1],0,1,,,,oGestao,xHeader[1],aDGano)
        oDGano:oBrowse:bLDblClick:={|| fZUP("RES",oDGano:nAt) }

        TSay():New(05,100,{|| "Detalhamento log (mensal)" },oGestao,, oFont16 ,,,,.T.,CLR_RED,CLR_WHITE,100,10)
        oDGdet := MSNewGetDados():New(15,100,nBottom-10,nRight-10, 3,,"AlwaysTrue",,aCpoEdit[2],0,1,,,,oGestao,xHeader[2])

    Activate MsDialog oGestao Centered  

Return

*Funcao********************************************************************************************************************************  
 
//Configuração dos MSNewGetDados
Static Function fHeader()

    //MSNewGetDados - oDGpsa
    aadd(xHeader[1], {"ST"             ,"st1","@BMP",01,0,.T.,"","" ,"","R","","",.F.,"V","","","",""})
    aadd(xHeader[1], {"Ano"            ,"aa1","@!"  , 4,0,"","","C",,,,})
    aCpoEdit[1] := {""}

    //MSNewGetDados - oDGop
    aadd(xHeader[2], {"Tipo"           ,"tp2","@!"           , 3,0,"","","C",,,,})
    aadd(xHeader[2], {"Ano"            ,"aa2","@!"           , 4,0,"","","C",,,,})
    aadd(xHeader[2], {"Mes"            ,"mm2","@!"           , 2,0,"","","C",,,,})
    aadd(xHeader[2], {"Processo"       ,"pr2","@!"           ,15,0,"","","C",,,,})
    aadd(xHeader[2], {"Colaboradores"  ,"cb2","@E 999,999"   , 6,0,"","","N",,,,})
    aadd(xHeader[2], {"Verba"          ,"vb2","@!"           ,15,0,"","","C",,,,})
    aadd(xHeader[2], {"Valor Total"    ,"vt2","@E 999,999.99",10,2,"","","N",,,,})
    aadd(xHeader[2], {"Qtd Regitro"    ,"qr2","@E 999,999"   , 6,0,"","","N",,,,})
    aadd(xHeader[2], {"Dt. Log"        ,"dt2","@!"           ,10,0,"","","C",,,,})
    aadd(xHeader[2], {"Hr. Log"        ,"hr2","@!"           , 5,0,"","","C",,,,})
    aadd(xHeader[2], {"Arquivo"        ,"aq2","@!"           ,50,0,"","","C",,,,})
    aadd(xHeader[2], {"Obs"            ,"obs","@!"           ,50,0,"","","C",,,,})
    aCpoEdit[2] := {""}

Return

*Funcao*****************************************************************************************************************************

Static Function fZUP(cPesq,nPesq)

    Local ka

    nAntAtual := nPesq
    If cPesq == "ANO"
        aDGano := {}
    
        cQuery := "SELECT DISTINCT LEFT(ZUP_ANOMES,4) ANO FROM ZUP010 WHERE ZUP_TPREG='RES' ORDER BY LEFT(ZUP_ANOMES,4)"

        TCQUERY cQuery NEW ALIAS "xZUP"
        While ! xZUP->(EOF())
            aadd(aDGano, {oBran,ANO,.F.})
        xZUP->(dbSkip())  
        EndDo
        xZUP->(dbCloseArea())
        If nPesq > 0
            oDGano:aCols[nPesq,1] := oVerd
            oDGano:Refresh()
        EndIf
    EndIf
    If cPesq == "RES"
        For ka:=1 to Len(oDGano:aCols)
            oDGano:aCols[ka,1] := oBran
        Next
        oDGano:aCols[nPesq,1] := oVerd
        oDGano:Refresh()

        oDGdet:aCols := {}
        cQuery := ""
        cQuery += "SELECT ZUP_TPREG, LEFT(ZUP_ANOMES,4) ANO, RIGHT(ZUP_ANOMES,2) MES, ZUP_TIPO, ZUP_QUANT, ZUP_VERBA, ZUP_VALOR, ZUP_QTREG, ZUP_DTLOG, ZUP_HRLOG, ZUP_ARQUIV "
        cQuery += "FROM ZUP010 AS ZUP "
        cQuery += "WHERE ZUP_VERBA IN ('LIQSL','ATCAD','PENS','IMPS','GRRF') AND ZUP_TPREG='RES' AND LEFT(ZUP_ANOMES,4)='"+oDGano:aCols[nPesq,2]+"' AND D_E_L_E_T_!='*' "

        TCQUERY cQuery NEW ALIAS "xZUP"
        While ! xZUP->(EOF())
            aadd(oDGdet:aCols, {ZUP_TPREG,ANO,MES,ZUP_TIPO,ZUP_QUANT,ZUP_VERBA,ZUP_VALOR,ZUP_QTREG,StoD(ZUP_DTLOG),ZUP_HRLOG,ZUP_ARQUIV,"",.F.})
        xZUP->(dbSkip())  
        EndDo
        xZUP->(dbCloseArea())
        oDGdet:Refresh()
    EndIf

Return

*Funcao*****************************************************************************************************************************

//Valida se o ANOMES ainda não tem integracao
Static Function fValInteg(cID, cDta, cMat)

    Local lVal := .F.

    cQuery := "SELECT DISTINCT ZUP_ANOMES FROM ZUP010 WHERE ZUP_ANOMES='"+cDta+"' AND ZUP_TIPO='"+cID+"' AND ZUP_MAT='"+cMat+"' AND D_E_L_E_T_!='*'"
    TCQUERY cQuery NEW ALIAS "xZUP"
    If ! xZUP->(EOF())
        lVal := (xZUP->ZUP_ANOMES == cDta)
    EndIf
    xZUP->(dbCloseArea())

Return ! lVal

*Funcao*****************************************************************************************************************************

Static function fLerArq(pg)

	Local cLinha  	:= ""
 	Local nTpArq, cArqChkL, cID := ""
    Local aDados    := {}
    Local kl, lAnoMes, dtLog, hrLog, idLin, nReg, nRub
    Local cMat, cDta, cRub, nQtd, nVlr
    Local aMes := {"JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}, nMes:=0

    If Empty(pg)
        nTpArq := Aviso("INTEGRACAO","Selecione o tipo de arquivo a ser integrado",{"Folha","Adiant.","Autom.","Ferias","Rescisao","13.Sal/1","13.Sal/2","PLR","Compl.Resc","Guias","Atual.Cad","Sair"},1,"")
        cID := IIF(nTpArq>0  .and. nTpArq<2, "FOL",cID)
        cID := IIF(nTpArq>1  .and. nTpArq<3, "ADI",cID)
        cID := IIF(nTpArq>2  .and. nTpArq<4, "AUT",cID)
        cID := IIF(nTpArq>3  .and. nTpArq<5, "FER",cID)
        cID := IIF(nTpArq>4  .and. nTpArq<6, "RES",cID)
        cID := IIF(nTpArq>5  .and. nTpArq<7, "131",cID)
        cID := IIF(nTpArq>6  .and. nTpArq<8, "132",cID)
        cID := IIF(nTpArq>7  .and. nTpArq<9, "PLR",cID)
        cID := IIF(nTpArq>8  .and. nTpArq<10,"CPR",cID)
        cID := IIF(nTpArq>9  .and. nTpArq<11,"IMP",cID)
        cID := IIF(nTpArq>10 .and. nTpArq<12,"CAD",cID)
        cID := IIF(nTpArq<1  .and. nTpArq>12, ""  ,cID)

        If cID == "CAD"
            nTpArq := Aviso("ATUALIZACAO DE CADASTRO","Selecione qual o cadastro a ser atualizado",{"Funcionario","Reajuste Colet.","Sair"},2,"")
            cID := IIF(nTpArq>0 .and. nTpArq<2, "FUN",cID)
            cID := IIF(nTpArq>1 .and. nTpArq<3, "RJT",cID)
            cID := IIF(nTpArq<1 .and. nTpArq>2, ""   ,cID)
        EndIf
        If cID == "FUN"
            nTpArq := Aviso("CADASTRO DE FUNCIONARIO","Atualizar a tabela de Colaborador (SRA) ou Dependente (SRB)",{"Colaborador","Dependente","Sair"},2,"")
            cID := IIF(nTpArq>0 .and. nTpArq<2, "SRA",cID)
            cID := IIF(nTpArq>1 .and. nTpArq<3, "SRB",cID)
            cID := IIF(nTpArq<1 .and. nTpArq>2, ""   ,cID)
        EndIf
        If cID == "IMP"
            nTpArq := Aviso("INTEGRACAO DAS GUIAS","Selecione qual o recolhimento a ser integrado",{"FGTS/IRRF/SIND","Pensao","GRRF","Sair"},3,"")
            cID := IIF(nTpArq>0 .and. nTpArq<2, "IMPS",cID)
            cID := IIF(nTpArq>1 .and. nTpArq<3, "PENS",cID)
            cID := IIF(nTpArq>2 .and. nTpArq<4, "GRRF",cID)
            cID := IIF(nTpArq<1 .and. nTpArq>3, ""   ,cID)
        EndIf

    ElseIf ! Empty(pg)
        cID := pg
        APMsgInfo("Selecione o arquivo [."+pg+"] para gerar o(s) titulo(s) do financeiro","Integracao")
    EndIf

    If Empty(cID)
        Return
    EndIf

    cArqChkL := cGetFile( cID+" (*."+cID+")|*."+cID+"|" , "Pesquisa arquivos" , 0 , , .t. , GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ) //"C:\TEMP\FOLHA.txt"

    //Efetua a leitura do arquivo
	If ! File(cArqChkL)
		MsgStop("O arquivo " + cArqChkL + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf
	 
	FT_FUSE(cArqChkL)
	FT_FGOTOP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
        If ! Empty(cLinha)
		    aadd(aDados,cLinha) //AllTrim(cLinha)
        EndIf
	FT_FSKIP()
	EndDo

    Eval({|| dtLog:=Date(), hrLog:=Left(Time(),5), idLin:="", nReg:=0, nRub:=0, nTLiq:=0, lAnoMes:=.F. })

    //Efetua a tratativa da linha lida no arquivo
    If ! cID $ "SRA|SRB|RJT|IMPS|PENS|GRRF|PGR|PGF"
        For kl:=1 to Len(aDados)
            idLin := Left(aDados[kl],1)
            If idLin == "1"
                cMat := Right(SubString(aDados[kl], 2, 8),6)
                cDta := AllTrim(Upper(SubString(aDados[kl],75,25)))
                nMes := aScan(aMes, {|x| x $ cDta})
                cDta := Replace(cDta, IIF(nMes>0, aMes[nMes],""), StrZero(nMes,2,0))
                cDta := Right(cDta,4)+Left(cDta,2)
                lAnoMes := IIF(cID=='FOL'.and.cMat$cMatAUT, .F., fValInteg(cID, cDta, cMat))
            ElseIf idLin == "2" .and. lAnoMes
                cRub := AllTrim(Str(Val(SubString(aDados[kl], 2, 6))))
                cLinha := Left(Right(aDados[kl],21),10)
                nQtd := Val(Left(cLinha,8)+"."+Right(cLinha,2))
                cLinha := Left(Right(aDados[kl],11),10)
                nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2))
                nReg := nReg + 1
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
            ElseIf idLin == "3" .and. lAnoMes
                Eval({|| cLinha := SubString(aDados[kl], 2,10), cRub := "SALBS", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| cLinha := SubString(aDados[kl],12,10), cRub := "BINSS", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| cLinha := SubString(aDados[kl],22,10), cRub := "BIRRF", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| cLinha := SubString(aDados[kl],42,10), cRub := "BFGTS", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| cLinha := SubString(aDados[kl],52,10), cRub := "VFGTS", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| cLinha := SubString(aDados[kl],82,10), cRub := "LIQSL", nQtd := 0, nVlr := Val(Left(cLinha,8)+"."+Right(cLinha,2)), nReg := nReg + 1 })
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,"")
                Eval({|| nRub := nRub + 1, nTLiq := nTLiq + nVlr, lAnoMes:=.F. })
            EndIf
        Next
        If nRub>0
            fGravaZUP("RES",cID,nReg,"",cDta,"LIQSL",nRub,nTLiq,cArqChkL,dtLog,hrLog,"")
            Processa( { || CursorWait() , fGravaSRD(cID, cDta) , CursorArrow() } , "Gravando registros (SRD)...")
            If cID $ "FOL|ADI|AUT|PLR|131|132"
                Processa( { || CursorWait() , fGeraSE2(cID, cDta) , CursorArrow() } , "Gerando financeiro (SE2)...")
            ElseIf cID == "RES"
                fLerArq("PGR")
            ElseIf cID == "FER"
                fLerArq("PGF")
            EndIf
            APMsgInfo("Processo finalizado","Integração")
        EndIf
    ElseIf cID $ "SRA|SRB|RJT"
        If cID $ "SRA|SRB"
            fSRASRB(cID, aDados)
        ElseIf cID == "RJT"
            For kl:=2 to Len(aDados)
                idLin := StrTokArr(aDados[kl], ";" )
                cMat := Right("000000"+idLin[1],6)
                cDta := DtoC(dDataBase)
                nVlr := Val(Replace(idLin[8], ",", "."))
                nMes := StrZero(Month(CtoD(cDta)),2,0)
                cDta := Right(cDta,4)+nMes
                lAnoMes := fValInteg(cID, cDta, cMat)
                If lAnoMes
                    fGravaZUP("LIN",cID,1,cMat,cDta,"ATCAD",0,nVlr,cArqChkL,dtLog,hrLog,"[Dt.Reajuste] "+cDta)
                    Eval({|| nReg := nReg + 1, nTLiq := nTLiq + nVlr, lAnoMes:=.F. })
                EndIf
            Next
            If nReg>0
                fGravaZUP("RES",cID,nReg,"",cDta,"ATCAD",nReg,0,cArqChkL,dtLog,hrLog,"REAJUSTE COLETIVO")
                Processa( { || CursorWait() , fAlteraSRA(cID, cDta) , CursorArrow() } , "Atualizando registros (SRA)...")
            EndIf
        EndIf
    ElseIf cID $ "IMPS|PENS|GRRF"
        cRub := cID
        cID  := IIF(cRub=="PENS","PNS","IMP")
        For kl:=1 to Len(aDados)
            idLin := StrTokArr(aDados[kl], ";" )
            cMat := IIF(cRub=="GRRF", Right("000000"+idLin[1],6), IIF(cRub=="PENS", Right(idLin[1],5)+idLin[5], idLin[1]))
            cRub := IIF(cRub=="IMPS",idLin[1],cRub)
            nVlr := Val(Replace(idLin[3], ",", "."))
            cDta := idLin[2]
            nMes := StrZero(Month(CtoD(cDta)),2,0)
            cDta := Right(cDta,4)+nMes
            lAnoMes := fValInteg(cID, cDta, cMat)
            If lAnoMes
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,1,nVlr,cArqChkL,dtLog,hrLog,"[Emiss] "+idLin[2]+";[Venc] "+idLin[4]+IIF(cRub=="PENS", +";[CPF] "+idLin[1],""))
                Eval({|| nReg := nReg + 1, nTLiq := nTLiq + nVlr, lAnoMes:=.F. })
            EndIf
            cRub := IIF(cRub $ "GRRF|PENS",cRub,"IMPS")
        Next
        If nReg>0
            fGravaZUP("RES",cID,nReg,"",cDta,cRub,nReg,nTLiq,cArqChkL,dtLog,hrLog,"GUIA "+cDta)
            If fValidSA2(cID, cArqChkL)
                Processa( { || CursorWait() , fGeraSE2(cID, cDta) , CursorArrow() } , "Gerando financeiro (SE2)...")
            Else 
                Return
            EndIf
        EndIf
    ElseIf cID $ "PGR|PGF"
        For kl:=1 to Len(aDados)
            idLin := StrTokArr(aDados[kl], ";" )
            cMat := Right("000000"+idLin[1],6)
            cRub := "LIQSL"
            nVlr := Val(Replace(idLin[3], ",", "."))
            cDta := idLin[2]
            nMes := StrZero(Month(CtoD(cDta)),2,0)
            cDta := Right(cDta,4)+nMes
            lAnoMes := fValInteg(cID, cDta, cMat)
            If lAnoMes
                fGravaZUP("LIN",cID,1,cMat,cDta,cRub,1,nVlr,cArqChkL,dtLog,hrLog,"[Emiss] "+idLin[2]+";[Venc] "+idLin[4])
                Eval({|| nReg := nReg + 1, nTLiq := nTLiq + nVlr, lAnoMes:=.F. })
            EndIf
        Next
        If nReg>0
            fGravaZUP("RES",cID,nReg,"",cDta,cRub,nReg,nTLiq,cArqChkL,dtLog,hrLog,"TITULO "+cDta)
            If fValidSA2(cID, cArqChkL)
                Processa( { || CursorWait() , fGeraSE2(cID, cDta) , CursorArrow() } , "Gerando financeiro (SE2)...")
                Processa( { || CursorWait() , fAlteraSRA(cID, cDta) , CursorArrow() } , "Atualizando registros (SRA)...")
            Else 
                Return
            EndIf
        EndIf
    EndIf

    If nAntAtual > 0
        fZUP("ANO",nAntAtual)
        fZUP("RES",nAntAtual)
    Else
        fZUP("ANO",1)
    EndIf

Return

*Funcao*****************************************************************************************************************************

Static function fGravaZUP(cReg,cTipo,nReg,cMat,cDta,cRub,nQtd,nVlr,cArqChkL,dtLog,hrLog,cObs)

	RecLock("ZUP",.T.)
        ZUP_FILIAL := xFilial("ZUP")
        ZUP_TPREG  := cReg
        ZUP_ANOMES := cDta
        ZUP_TIPO   := cTipo
        ZUP_QTREG  := nReg
        ZUP_STATUS := " "
        ZUP_DTLOG  := dtLog
        ZUP_HRLOG  := hrLog
        ZUP_ARQUIV := cArqChkL
        ZUP_OBS	   := cObs
        ZUP_MAT	   := cMat
        ZUP_VERBA  := cRub
        ZUP_QUANT  := nQtd
        ZUP_VALOR  := nVlr
    MsUnlock()

Return

*Funcao*****************************************************************************************************************************

Static Function fGravaSRD(cID, cDta)

    Local cUltMat:="", cUltPD:="", nUltSRD:=0

    cQuery := "SELECT ZUP_TIPO, ZUP_MAT, RV_COD, RV_TIPO, ZUP_QUANT, ZUP_VALOR, ZUP_ANOMES, RA_CC, "
    cQuery += "       COALESCE(RCH_DTPAGO,ZUP_ANOMES+'01') RCH_DTPAGO, COALESCE(RCH_PROCES,'00001') RCH_PROCES, ZUP.R_E_C_N_O_ RECZUP "
    cQuery += "FROM ZUP010 AS ZUP "
    cQuery += "INNER JOIN SRA010 AS SRA ON RA_FILIAL=ZUP_FILIAL AND RA_MAT=ZUP_MAT AND SRA.D_E_L_E_T_!='*' "
    cQuery += "INNER JOIN ZUV010 AS ZUV ON ZUV_FILIAL='' AND ZUV_ALIAS='SRV' AND ZUV_DE=ZUP_VERBA AND ZUV_TIPO='' AND ZUV.D_E_L_E_T_!='*' "
    cQuery += "INNER JOIN SRV010 AS SRV ON RV_FILIAL='' AND RV_COD=ZUV_PARA AND SRV.D_E_L_E_T_!='*' "
    cQuery += "LEFT JOIN RCH010 AS RCH ON RCH_FILIAL=LEFT(ZUP_FILIAL,2) AND RCH_PER=ZUP_ANOMES AND RCH_ROTEIR=ZUP_TIPO AND RCH.D_E_L_E_T_!='*' "
    cQuery += "WHERE ZUP_ANOMES='"+cDta+"' AND ZUP_TPREG='LIN' AND ZUP_TIPO='"+cID+"' AND ZUP_STATUS='' AND ZUP.D_E_L_E_T_!='*' "
    cQuery += "ORDER BY ZUP_MAT, RV_COD"

    TCQUERY cQuery NEW ALIAS "xZUP"
    While ! xZUP->(EOF())
        cUltPD := IIF(! cUltMat == xZUP->ZUP_MAT, "", cUltPD)
        
        If ! cUltPD == xZUP->RV_COD
        dbSelectArea("SRD")
	    RecLock("SRD",.T.)
            RD_FILIAL  := xFilial("SRD")
            RD_MAT     := xZUP->ZUP_MAT
            RD_PD      := xZUP->RV_COD
            RD_TIPO1   := xZUP->RV_TIPO
            RD_HORAS   := xZUP->ZUP_QUANT
            RD_VALOR   := xZUP->ZUP_VALOR
            RD_DATARQ  := xZUP->ZUP_ANOMES                 
            RD_DATPGT  := StoD(xZUP->RCH_DTPAGO)
            RD_CC      := xZUP->RA_CC
            RD_PROCES  := xZUP->RCH_PROCES
            RD_SEMANA  := "01"
            RD_PERIODO := xZUP->ZUP_ANOMES                
            RD_DTREF   := StoD(xZUP->ZUP_ANOMES+'01')
            RD_ROTEIR  := cID
            RD_MES     := Right(cDta,2)              //RD_STATUS='',RD_INSS='',RD_IR='',RD_FGTS=''            
        MsUnlock()
        cUltMat := xZUP->ZUP_MAT
        cUltPD  := xZUP->RV_COD
        nUltSRD := SRD->(RECNO())
        Else
            dbSelectArea("SRD")
            SRD->(dbGoTo(nUltSRD))
	        RecLock("SRD",.F.)
                RD_VALOR := RD_VALOR + xZUP->ZUP_VALOR
            MsUnlock()
        EndIf

        dbSelectArea("ZUP")
        ZUP->(dbGoTo(xZUP->RECZUP))
	    RecLock("ZUP",.F.)
            ZUP->ZUP_STATUS := "I"
        MsUnlock()

    xZUP->(dbSkip())  
    EndDo
    xZUP->(dbCloseArea())

Return

*Funcao*****************************************************************************************************************************

Static Function fGeraSE2(cID, cDta)

    Local aArray := {}
    Local lRet := .F.
    Local cNatur, cTipo, cForn, cLoja, cPref, dEmis, cNum, cParc, nValor, dVenc, cHist, cAcao, aObs 
    Local cZUVALIAS := IIF(cID $ "IMP|PNS", cID, "SRV")
    Private lMsErroAuto := .F.

    cQuery := "SELECT MAX(E2_NUM) NUM FROM SE2010 WHERE E2_PREFIXO='GPE' AND LEFT(E2_EMISSAO,4)>='2022'"
    TCQUERY cQuery NEW ALIAS "xSE2"
    While ! xSE2->(EOF())
        cNum   := xSE2->NUM
    xSE2->(dbSkip())  
    EndDo
    xSE2->(dbCloseArea())


    cQuery := "SELECT ZUP_TIPO, ZUP_MAT, ZUP_VALOR, ZUP_ANOMES, ZUV_NFIN, ZUV_FORNEC, ZUV_LOJA, ZUV_TPFIN, ZUV_TPREG, "
    cQuery += "       COALESCE(A2_COD,'') A2_COD, COALESCE(A2_LOJA,'') A2_LOJA, ZUP_OBS, COALESCE(RCH_DTPAGO,ZUP_ANOMES+'01') RCH_DTPAGO, ZUP.R_E_C_N_O_ RECZUP "
    cQuery += "FROM ZUP010 AS ZUP "
    If ! cID == "PNS"
        cQuery += "LEFT JOIN SRA010 AS SRA ON RA_FILIAL=ZUP_FILIAL AND RA_MAT=ZUP_MAT AND SRA.D_E_L_E_T_!='*' "
        cQuery += "LEFT JOIN SA2010 AS SA2 ON A2_FILIAL=LEFT(ZUP_FILIAL,2) AND A2_CGC=RA_CIC AND A2_ZZTP='F' AND SA2.D_E_L_E_T_!='*' "
    Else
        cQuery += "LEFT JOIN SA2010 AS SA2 ON A2_FILIAL=LEFT(ZUP_FILIAL,2) AND A2_CGC=Right(RTrim(ZUP_OBS),11) AND A2_ZZTP='F' AND SA2.D_E_L_E_T_!='*' "
    EndIf
    cQuery += "LEFT JOIN RCH010 AS RCH ON RCH_FILIAL=LEFT(ZUP_FILIAL,2) AND RCH_PER=ZUP_ANOMES AND RCH_ROTEIR=ZUP_TIPO AND RCH.D_E_L_E_T_!='*' "
    cQuery += "INNER JOIN ZUV010 AS ZUV ON ZUV_FILIAL='' AND ZUV_ALIAS='"+cZUVALIAS+"' AND ZUV_DE=ZUP_VERBA AND ZUV_TIPO=ZUP_TIPO AND ZUV_TPREG=ZUP_TPREG AND ZUV.D_E_L_E_T_!='*' "
    cQuery += "WHERE ZUP_ANOMES='"+cDta+"' AND ZUP_TIPO='"+cID+"' AND ZUP_STATUS IN ('','I') AND ZUP.D_E_L_E_T_!='*' "
    cQuery += "ORDER BY ZUP_MAT"

    TCQUERY cQuery NEW ALIAS "xZUP"
    While ! xZUP->(EOF())
        aObs   := IIF(Empty(ZUP_OBS), {}, StrTokArr(AllTrim(ZUP_OBS), ';'))
        cNatur := ZUV_NFIN
        cTipo  := ZUV_TPFIN
        cForn  := IIF(ZUV_FORNEC=="FORNEC",IIF(Empty(A2_COD) ,"000089",A2_COD ),ZUV_FORNEC)
        cLoja  := IIF(ZUV_FORNEC=="FORNEC",IIF(Empty(A2_LOJA),"0'"    ,A2_LOJA),ZUV_LOJA)
        cPref  := "GPE"
        dEmis  := IIF(cID $ "FOL|ADI|AUT|PLR|131|132", StoD(RCH_DTPAGO), IIF(Empty(aObs[1]),StoD(RCH_DTPAGO),CtoD(Replace(aObs[1],"[Emiss] ",""))))
        cNum   := StrZero(Val(cNum)+1,9)
        cParc  := IIF(cID == "PNS", Right(ZUP_MAT,1), "A")
        nValor := ZUP_VALOR
        dVenc  := IIF(cID $ "FOL|ADI|AUT|PLR|131|132", StoD(RCH_DTPAGO), IIF(Empty(aObs[1]),StoD(RCH_DTPAGO),CtoD(Replace(aObs[2],"[Venc] ",""))))
        cHist  := cID+" "+cDta
        cAcao  := "I"

        aArray := { { "E2_PREFIXO"  , cPref                         , NIL },;
                    { "E2_NUM"      , cNum                          , NIL },;
                    { "E2_PARCELA"  , cParc                         , NIL },;
                    { "E2_TIPO"     , cTipo                         , NIL },;
                    { "E2_NATUREZ"  , cNatur	                    , NIL },;
                    { "E2_FORNECE"  , cForn                         , NIL },;
                    { "E2_LOJA"     , cLoja	                        , NIL },;
                    { "E2_EMISSAO"  , dEmis                         , NIL },;
                    { "E2_VENCTO"   , DataValida(dVenc, .T.)        , NIL },;
                    { "E2_VENCREA"  , DataValida(dVenc, .T.)        , NIL },;
                    { "E2_VALOR"    , nValor                        , NIL },;
                    { "E2_HIST"     , Left(cHist+space(40),40)      , NIL }}

        //Inicia o controle de transação
        Begin Transaction
            If cAcao == "I" //INCLUSAO
                _nAutoOpc := 3
            ElseIf cAcao == "A" //ALTERACAO
                _nAutoOpc := 4
            ElseIf cAcao == "E" //EXCLUSAO
                _nAutoOpc := 5
            EndIf
        
            MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, _nAutoOpc)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
        
            If lMsErroAuto
                MostraErro()
                DisarmTransaction()
            Else
	            lRet := .T.
            Endif
        End Transaction

        dbSelectArea("ZUP")
        ZUP->(dbGoTo(xZUP->RECZUP))
	    RecLock("ZUP",.F.)
            ZUP->ZUP_STATUS := "F"
        MsUnlock()

    xZUP->(dbSkip())  
    EndDo
    xZUP->(dbCloseArea())


Return lRet


*Funcao*****************************************************************************************************************************

Static Function fAlteraSRA(cID, cDta)

    Local aObs

    cQuery := "SELECT ZUP_MAT, ZUP_OBS, ZUP_VALOR, ZUP.R_E_C_N_O_ RECZUP, SRA.R_E_C_N_O_ RECSRA "
    cQuery += "FROM ZUP010 AS ZUP "
    cQuery += "INNER JOIN SRA010 AS SRA ON RA_FILIAL=ZUP_FILIAL AND RA_MAT=ZUP_MAT AND SRA.D_E_L_E_T_!='*' "
    cQuery += "WHERE ZUP_ANOMES='"+cDta+"' AND ZUP_TPREG='LIN' AND ZUP_TIPO='"+cID+"' AND ZUP_STATUS IN('','F') AND ZUP.D_E_L_E_T_!='*' "
    cQuery += "ORDER BY ZUP_MAT"

    TCQUERY cQuery NEW ALIAS "xZUP"
    While ! xZUP->(EOF())
        If cID $ "PGR|PGF" 
            aObs   := IIF(Empty(ZUP_OBS), {}, StrTokArr(AllTrim(ZUP_OBS), ';'))
            dbSelectArea("SRA")
            SRA->(dbGoTo(xZUP->RECSRA))
	        RecLock("SRA",.F.)
                If cID == "PGR" 
                    SRA->RA_SITFOLH := "D"
                    SRA->RA_DEMISSA := CtoD(Replace(aObs[1],"[Emiss] ",""))
                ElseIf cID == "PGF"
                    SRA->RA_SITFOLH := "F"
                EndIf
            MsUnlock()
            dbSelectArea("ZUP")
            ZUP->(dbGoTo(xZUP->RECZUP))
	        RecLock("ZUP",.F.)
                ZUP->ZUP_STATUS := IIf(cID == "PGR", "D", "F")
            MsUnlock()
        ElseIf cID == "RJT"
            dbSelectArea("SRA")
            SRA->(dbGoTo(xZUP->RECSRA))
	        RecLock("SRA",.F.)
                SRA->RA_ANTEAUM := SRA->RA_SALARIO
                SRA->RA_SALARIO := xZUP->ZUP_VALOR
            MsUnlock()
            dbSelectArea("ZUP")
            ZUP->(dbGoTo(xZUP->RECZUP))
	        RecLock("ZUP",.F.)
                ZUP->ZUP_STATUS := "R"
            MsUnlock()
        EndIf
    xZUP->(dbSkip())  
    EndDo
    xZUP->(dbCloseArea())

Return

*Funcao*****************************************************************************************************************************

Static Function fPonto()



Return

*Funcao*****************************************************************************************************************************

//Carrega os campo do SX3 - SRA e SRB
Static Function fSRASRB(cID, aAB)

    Local kl, lAB:=.T., aCpo := {}

    If Len(aAB) > 0    
        cQuery := "SELECT X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_TITULO, X3_CBOX, X3_VISUAL FROM SX3010 WHERE X3_ARQUIVO='"+cID+"' ORDER BY X3_ORDEM"
        TCQUERY cQuery NEW ALIAS "xAB"
        While ! xAB->(EOF())
            aadd(aCpo, {AllTrim(X3_CAMPO), X3_TIPO, X3_TAMANHO, X3_DECIMAL, AllTrim(X3_TITULO), X3_CBOX, X3_VISUAL})
        xAB->(dbSkip())
        EndDo
        xAB->(dbCloseArea())

        For kl:=2 to Len(aAB)
            idLin := StrTokArr(aAB[kl], ";" )
                nP := ascan(aCpo, {|x| x[5] == AllTrim(idLin[3]) .and. (! x[7] == "V")})
                If nP > 0
                    If cID == "SRA"
                        cQuery := "SELECT "+aCpo[nP,1]+", R_E_C_N_O_ REC FROM SRA010 WHERE RA_FILIAL='"+idLin[1]+"' AND RA_MAT='"+idLin[2]+"' AND D_E_L_E_T_!='*' "
                    ElseIf cID == "SRB"
                        cQuery := "SELECT "+aCpo[nP,1]+", R_E_C_N_O_ REC FROM SRB010 WHERE RB_FILIAL='"+idLin[1]+"' AND RB_MAT='"+idLin[2]+"' AND D_E_L_E_T_!='*' "
                    EndIf
                    TCQUERY cQuery NEW ALIAS "xFUN"
                    If ! xFUN->(EOF())
                        If aCpo[nP,2] == "C"
                            If ! AllTrim(xFUN->&(aCpo[nP,1])) == AllTrim(idLin[4])
                                If cID == "SRA"
                                    cQuery := "UPDATE SRA010 SET "+aCpo[nP,1]+"='"+AllTrim(idLin[4])+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                ElseIf cID == "SRB"
                                    cQuery := "UPDATE SRB010 SET "+aCpo[nP,1]+"='"+AllTrim(idLin[4])+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                EndIf
                                TcSqlExec( cQuery )
                            EndIf
                        ElseIf aCpo[nP,2] == "D"
                            If ! AllTrim(xFUN->&(aCpo[nP,1])) == DtoS(CtoD(AllTrim(idLin[4])))
                                If cID == "SRA"
                                    cQuery := "UPDATE SRA010 SET "+aCpo[nP,1]+"='"+DtoS(CtoD(AllTrim(idLin[4])))+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                ElseIf cID == "SRB"
                                    cQuery := "UPDATE SRB010 SET "+aCpo[nP,1]+"='"+DtoS(CtoD(AllTrim(idLin[4])))+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                EndIf
                                TcSqlExec( cQuery )
                            EndIf
                        ElseIf aCpo[nP,2] == "N"
                            If ! AllTrim(Str(xFUN->&(aCpo[nP,1]))) == Replace(AllTrim(AllTrim(idLin[4])),",",".")
                                If cID == "SRA"
                                    cQuery := "UPDATE SRA010 SET "+aCpo[nP,1]+"='"+Replace(AllTrim(AllTrim(idLin[4])),",",".")+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                ElseIf cID == "SRB"
                                    cQuery := "UPDATE SRB010 SET "+aCpo[nP,1]+"='"+Replace(AllTrim(AllTrim(idLin[4])),",",".")+"' WHERE R_E_C_N_O_="+AllTrim(Str(xFUN->REC))
                                EndIf
                                TcSqlExec( cQuery )
                            EndIf
                        Else
                            ALERT("Tipo nao previsto")                         
                        EndIf
                    EndIf
                    xFUN->(dbCloseArea())
                EndIf
        Next
        APMsgInfo("PROCESSO EXECUTADO")
    Else
        lAB := .F.
    EndIf

Return lAB

*Funcao*****************************************************************************************************************************

//Verifica se esta com registro de fonecedor SA2
Static Function fValidSA2(cID, cArq)

    Local aErro := {}
    Local lSemErro := .T.

    If ! cID == "PNS"
        cQuery := "SELECT RA_MAT, RA_CIC, RA_NOME, COALESCE(A2_CGC,'') A2_CGC,  COALESCE(A2_COD,'') A2_COD, COALESCE(A2_LOJA,'') A2_LOJA, A2_ZZTP "
        cQuery += "FROM SRA010 AS SRA "
        cQuery += "LEFT JOIN SA2010 AS SA2 ON A2_FILIAL=LEFT(RA_FILIAL,2) AND A2_CGC=RA_CIC AND A2_ZZTP='F' AND SA2.D_E_L_E_T_!='*' "
        cQuery += "WHERE RA_FILIAL='"+xFilial("SRA")+"' AND RA_MAT IN (SELECT DISTINCT ZUP_MAT FROM ZUP010 WHERE ZUP_ARQUIV='"+cArq+"') AND COALESCE(A2_CGC,'')='' AND SRA.D_E_L_E_T_!='*'"
        TCQUERY cQuery NEW ALIAS "xA2"
        While ! xA2->(EOF())
          aadd(aErro, {AllTrim(RA_MAT), RA_CIC, AllTrim(RA_NOME), "VERIFIQUE O CADASTRO DO FORNECEDOR (COLABORADOR)", "", ""})
        xA2->(dbSkip())
        EndDo
        xA2->(dbCloseArea())
    Else
        cQuery := "SELECT RA_MAT, RA_CIC, RA_NOME, COALESCE(A2_CGC,'') A2_CGC,  COALESCE(A2_COD,'') A2_COD, COALESCE(A2_LOJA,'') A2_LOJA, A2_ZZTP, RB_CIC, RB_NOME "
        cQuery += "FROM SRB010 AS SRB "
        cQuery += "INNER JOIN SRA010 AS SRA ON RA_FILIAL=RB_FILIAL AND RA_MAT=RB_MAT AND RA_SITFOLH!='D' AND RA_DEMISSA='' AND SRA.D_E_L_E_T_!='*'"
        cQuery += "LEFT JOIN SA2010 AS SA2 ON A2_FILIAL=LEFT(RB_FILIAL,2) AND A2_CGC=RB_CIC AND A2_ZZTP='F' AND SA2.D_E_L_E_T_!='*' "
        cQuery += "WHERE RB_FILIAL='"+xFilial("SRB")+"' AND RB_CIC IN (SELECT DISTINCT RIGHT(RTRIM(ZUP_OBS),11) FROM ZUP010 WHERE ZUP_ARQUIV='"+cArq+"' AND ZUP_MAT!='') AND COALESCE(A2_CGC,'')='' AND SRB.D_E_L_E_T_!='*' "
        TCQUERY cQuery NEW ALIAS "xA2"
        While ! xA2->(EOF())
          aadd(aErro, {AllTrim(RA_MAT), AllTrim(RA_NOME), "VERIFIQUE O CADASTRO DO FORNECEDOR (DEPENDENTE)", RB_NOME, RB_CIC})
        xA2->(dbSkip())
        EndDo
        xA2->(dbCloseArea())
    EndIf

    If ! Empty(aErro)
        lSemErro := .F.
        TcSqlExec("DELETE FROM ZUP010 WHERE ZUP_ARQUIV='"+cArq+"'")  
        GeraExcel(cID, aErro, cArq)
    EndIf

Return lSemErro


*Funcao*****************************************************************************************************************************

Static Function GeraExcel(cID, aErro, cArq)
	
	Local nI			:= 0
	Local cWorkSheet	:= "Cadastro"
	Local cPlanilha		:= "Verificar SA2"
    Local aColumns      := {}
    Local cDiretorio	:= ""
	Local cExtensao	    := ".XML"
    Local cTexto        := ""
    Local oExcel, oExcelApp

	cDiretorio := cGetFile("Arquivos (*" + Upper(cExtensao) + ") | *" + Upper(cExtensao) + " |","Selecione o Local de Destino",,,.F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)
	If !Empty(cDiretorio)
    	oExcel := FWMsExcel():New()
    	oExcel:AddWorkSheet(cWorkSheet)
    	oExcel:AddTable(cWorkSheet,cPlanilha)

        Aadd(aColumns,{"Matricula",1,1,.F.})
    	Aadd(aColumns,{"Colaborador",1,1,.F.})
    	Aadd(aColumns,{"Observação",1,1,.F.})
        If ! cID == "PNS"
        	Aadd(aColumns,{"",1,1,.F.})
	        Aadd(aColumns,{"",1,1,.F.})
        Else
        	Aadd(aColumns,{"Dependente",1,1,.F.})
    	    Aadd(aColumns,{"CPF",1,1,.F.})
        EndIf
		
		//Cria Cabeçalho
	    For nI := 1 To Len(aColumns)
		    oExcel:AddColumn(cWorkSheet,cPlanilha,aColumns[nI,1],aColumns[nI,2],aColumns[nI,3],aColumns[nI,4])
	    Next
		
		//Insere os Dados
	    For nI := 1 To Len(aErro)
	    	oExcel:AddRow(cWorkSheet,cPlanilha,aErro[nI])
    	Next
		
	    oExcel:Activate()
	    oExcel:GetXMLFile(cDiretorio + cExtensao)

        cTexto += "Planilha gerada em: " + CRLF
		cTexto += cDiretorio + cExtensao

		If File(cDiretorio + cExtensao)
            oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cDiretorio + cExtensao)
			oExcelApp:setVisible(.T.)
			Aviso("AVISO","Foi gerado uma planilha com inconsistencia "+cDiretorio,{"OK"},3)
		Else
			Aviso("Erro","Não foi possível gerar a planilha em " + cDiretorio,{"OK"},3)
		EndIf
    EndIf
	
Return
