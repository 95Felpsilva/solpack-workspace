#include "Totvs.ch"
/*/{protheus.doc} SPRNFITE
Relatorio de notas fiscais por itens     
@author Sergio Braz
@since 18/10/18
/*/

User Function SPRNFITE
	Local cQ := RetField("SX3",2,"D2_QUANT","Alltrim(X3_PICTURE)")
	Local cV := RetField("SX3",2,"D2_TOTAL","Alltrim(X3_PICTURE)")
	Private oRep,oDoc,oItens 
	If AskMe()              
		oRep := tReport():New(ProcName(),"Notas Fiscais por Itens",,{|| PrintRep()})
		oDoc := TrSection():New(oRep,"Documentos",{})
		TrCell():New(oDoc,"DOC",,"Nota Fiscal","@!",15,.f.,{|| SF2->(F2_DOC+'/'+F2_SERIE)})
		TrCell():New(oDoc,"DAT",,"Emissao",,15,.f.,{|| SF2->F2_EMISSAO})
		TrCell():New(oDoc,"VEN",,"Vendedor",,40,.f.,{|| RetField("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_COD+'-'+A3_NOME")})
		TrCell():New(oDoc,"VBR",,"Total",cV,15,.f.,{|| SF2->F2_VALBRUT},"RIGHT",,"RIGHT")
		oDoc:SetLineStyle(.t.)
		oDoc:SetLeftMargin(3)
		oItens := TrSection():New(oDoc,"Itens",{})
		TrCell():New(oItens,"COD",,"Produto"  ,,15,.f.,{|| D2->D2_COD})
		TrCell():New(oItens,"DES",,"Descricao",,30,.f.,{|| RetField("SB1",1,xFilial("SB1")+D2->D2_COD,"B1_DESC")})
		TrCell():New(oItens,"CFO",,"CFOP"     ,,05,.f.,{|| D2->D2_CF})
		TrCell():New(oItens,"QTD",,"Quant"    ,cQ,14,.f.,{|| D2->D2_QUANT},"RIGHT",,"RIGHT")
		TrCell():New(oItens,"UNI",,"Vl.Unit",cV,14,.f.,{|| D2->D2_PRCVEN},"RIGHT",,"RIGHT")
		TrCell():New(oItens,"VAL",,"Total",cV,14,.f.,{|| D2->D2_TOTAL},"RIGHT",,"RIGHT")
		TrCell():New(oItens,"PED",,"Pedido",,06,.f.,{|| D2->D2_PEDIDO})
		oItens:SetLeftMargin(6)
		oRep:PrintDialog()		
	Endif
Return                    

Static Function PrintRep
	Local nRegs
	BeginSql Alias "F2"
		Select Distinct F2_DOC DOC, F2_SERIE SERIE, F2_EMISSAO
		From %Table:SD2% SD2, %Table:SF2% SF2
		Where SD2.%NotDel% and SD2.D2_FILIAL = %xFilial:SD2% and SD2.D2_CF Between %Exp:MV_PAR05% and %Exp:MV_PAR06% and SD2.D2_TES Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
		and SF2.%NotDel% and SF2.F2_FILIAL = %xFilial:SF2% and SF2.F2_VEND1 Between %Exp:MV_PAR07% and %Exp:MV_PAR08% and F2_EMISSAO Between %Exp:MV_PAR01% and %Exp:MV_PAR02% 
		and SF2.F2_DOC=SD2.D2_DOC and SF2.F2_SERIE=SD2.D2_SERIE and SF2.F2_CLIENTE=SD2.D2_CLIENTE and SF2.F2_LOJA=SD2.D2_LOJA                                                                          
		and SF2.F2_DOC Between %Exp:MV_PAR03% and %Exp:MV_PAR04%
		Order by SF2.F2_EMISSAO
	EndSql            
	Count to nRegs 
	oRep:SetMeter(nRegs)
	F2->(DbGoTop())
	oDoc:Init()                                      
	While F2->(!Eof())  
		Posicione("SF2",1,xFilial("SF2")+F2->(DOC+SERIE),"")
		oDoc:PrintLine()                            
		oItens:Init()  
		BeginSql Alias "D2"
			Select D2_ITEM, D2_COD, D2_CF, D2_TES, D2_PRCVEN, D2_QUANT, D2_TOTAL, D2_PEDIDO
			From %Table:SD2% SD2
			Where SD2.%NotDel% and SD2.D2_FILIAL=%xFilial:SD2% and SD2.D2_CF Between %Exp:MV_PAR05% and %Exp:MV_PAR06% and SD2.D2_TES Between %Exp:MV_PAR09% and %Exp:MV_PAR10%
			   and D2_DOC = %Exp:SF2->F2_DOC% and  D2_SERIE = %Exp:SF2->F2_SERIE% and D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND D2_LOJA = %Exp:SF2->F2_LOJA%
			Order By D2_ITEM
		EndSql
		While D2->(!Eof())
			oItens:PrintLine()
			D2->(DbSkip())
		End 
		D2->(DbCloseArea())
		oItens:Finish()       
		oRep:SkipLine(2)
		oRep:IncMeter()
		F2->(DbSkip())
	End
	oDoc:Finish()       
	F2->(DbCloseArea())
Return

               
Static Function AskMe                 
	Local aPergs := {}              
	AADD(aPergs,{1,"Da data",ctod(""),,'.t.',,'.t.',60,.f.})
	AADD(aPergs,{1,"Ate data",ctod(""),,'.t.',,'.t.',60,.f.})
	AADD(aPergs,{1,"Da Nota",CriaVar("F2_DOC",.f.),"@!",'.t.','SF2','.t.',80,.f.})
	AADD(aPergs,{1,"Ate Nota",CriaVar("F2_DOC",.f.),"@!",'.t.','SF2','.t.',80,.f.})
	AADD(aPergs,{1,"Do CFOP",CriaVar("D2_CF",.f.),"@!",'.t.','13','.t.',60,.f.})
	AADD(aPergs,{1,"Ate CFOP",CriaVar("D2_CF",.f.),"@!",'.t.','13','.t.',60,.f.})
	AADD(aPergs,{1,"Do Vendedor",CriaVar("A3_COD",.f.),"@!",'.t.','SA3','.t.',60,.f.})
	AADD(aPergs,{1,"Ate Vendedor",CriaVar("A3_COD",.f.),"@!",'.t.','SA3','.t.',60,.f.})
	AADD(aPergs,{1,"Do TES",CriaVar("D2_TES",.f.),"@!",'.t.','SF4','.t.',60,.f.})
	AADD(aPergs,{1,"Ate TES",CriaVar("D2_TES",.f.),"@!",'.t.','SF4','.t.',60,.f.})
Return ParamBox(aPergs,"Parametros",{})

/*User Function Xpto
RpcSetEnv("01","0101","admin","8220","FAT")
Define MsDialog oMainWnd from 0,0 to 800,1400 Pixel
@ 05,05 Button "ok" of omainwnd pixel action u_SPRNFITE()
Activate MsDialog oMainWnd 
Return*/