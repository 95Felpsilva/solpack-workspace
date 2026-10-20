#Include "Protheus.ch"

/*/{Protheus.doc}	M410INIC
ste ponto de entrada é chamado antes da abertura da tela de 
inclusão do pedido de vendas para alimentar os campos customizados

@author				BETE - EQUIPE INTERNA
@date				07/04/2016
 
/*/
User Function M410INIC()
	
	Local aAreaAtu	:= GetArea()	
	Local aAreaSA1	:= SA1->(GetArea())
   	Local aAreaSA4	:= SA4->(GetArea())     
   	Local aAreaSE4	:= SE4->(GetArea()) 
   	Local aAreaSA3	:= SA3->(GetArea())
	 
	
 	If FunName() == "MATA416" .or. FunName() == "CRMA290" 
        M->C5_TRANSP	:= SCJ->CJ_ZZTRANS
    	M->C5_TPFRETE 	:= SCJ->CJ_ZZTPFRE   
    	M->C5_ZZOBS 	:= SCJ->CJ_OBSERV
      	M->C5_ZZDESRS	:= Posicione("SA1",1,xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,"A1_NOME")      
        M->C5_ZZDESCL	:= Posicione("SA1",1,xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,"A1_NREDUZ")   
    	M->C5_ZZCGC		:= Posicione("SA1",1,xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,"A1_CGC")     
    	M->C5_NATUREZ	:= Posicione("SA1",1,xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,"A1_NATUREZ")     
        M->C5_ZZDESCP	:= Posicione("SE4",1,xFilial("SE4") + SCJ->CJ_CONDPAG,"E4_DESCRI")   
        M->C5_ZZDESTR	:= Posicione("SA4",1,xFilial("SA4") + SCJ->CJ_ZZTRANS,"A4_NOME") 
        M->C5_ZZDESVE	:= Posicione("SA3",1,xFilial("SA3") + M->C5_VEND1,"A3_NOME")     
        
              
	EndIf
	
    RestArea(aAreaSA3)    
	RestArea(aAreaSA4)      
	RestArea(aAreaSE4)
    RestArea(aAreaSA1)
	RestArea(aAreaAtu)
	
Return
