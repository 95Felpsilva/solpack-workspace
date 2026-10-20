User Function MA261IN()

Local aArea    	:= GetArea()  
Local aAreaSD3 	:= SD3->(GetArea())  
Local nI		:= 0          
Local cPosTurno 	:= aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_ZZTURNO'})
/*
Local cPosOp	:= aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_OP'})
Local cPosReq 	:= aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_ZZREQ'})
Local cPosDev 	:= aScan(aHeader, {|x| AllTrim(Upper(x[2]))=='D3_ZZDEVFM'})


For n:=1 to Len(aCols)
	aCols[n,cPosOP]	:= SD3->D3_OP
	aCols[n,cPosReq]:= SD3->D3_ZZREQ
	aCols[n,cPosDev]:= SD3->D3_ZZDEVFM
Next
*/


For nI := 1 to Len(aCols)  

	SD3->(dbSetOrder(4))  
 	If  SD3->(dbSeek( xFilial("SD3")+GdFieldGet("D3_NUMSEQ",nI) ))  

		GdFieldPut("D3_ZZTURNO" 	,cPosTurno	,nI)  
             

	EndIf 

Next nI



RestArea(aAreaSD3)  
RestArea(aArea)  

Return

