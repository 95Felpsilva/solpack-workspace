/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPrograma ³SF2460I ºAutor ³ º Data ³ º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ PE para gravar informações do PV no CR. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso ³ SIGAFAT º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function SF2460I

  a_Area := GetArea()
  a_AreaSE1 := SE1->(GetArea())
  a_AreaSD2 := SD2->(GetArea())
  a_AreaSA4 := SA4->(GetArea()) //add p/ Rodrigo Paiva em 18.11.2014
  a_AreaSF2 := SF2->(GetArea()) //add p/ Rodrigo Paiva em 18.11.2014 
  c_ForPag 	:= ""   
  c_Naturez := ""
  _cDoc		:= SF2->F2_DOC //add p/ Rodrigo Paiva em 18.11.2014
  _cSerie	:= SF2->F2_SERIE //add p/ Rodrigo Paiva em 18.11.2014
 
 ///////////////////////////////////////	add p/ Rodrigo Paiva em 18.11.2014	//////////////////////////////////////////////////////////
 //	GRAVACAO DO NOME DA TRANSPORTADORA (A4_NOME) NA TABELA DE NFS (SF2) PARA VISUALIZACAO NO BROWSER (CAMPO PERS. F2_NTRANSP)			//
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
/* dbSelectArea('SF2')
			    SF2->(dbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
			    SF2->(dbGoTop())
			    SF2->(dbSeek(xFilial('SF2') + _cDoc + _cSerie))
			    If !SF2->(Eof()) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == (xFilial('SF2')+_cDoc+_cSerie)
			    	a_AreaSA4 := SA4->(GetArea())
			    	
			    	dbSelectArea('SA4')
			    	SA4->(dbSetOrder(1))//A4_FILIAL+A4_COD                                                                                                                                                
			    	SA4->(dbGoTop())
			    	SA4->(dbSeek(xFilial('SA4') + SF2->F2_TRANSP))
			    	
			    	RecLock('SF2',.F.)
							SF2->F2_NTRANSP	:= SA4->A4_NOME
			    	SF2->(MsUnLock())
			    	SF2->(dbSkip())
                    
				RestArea(a_AreaSF2)
				RestArea(a_AreaSA4)
				EndIf

*/
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  dbSelectArea("SD2")
  dbSetOrder(3)
  If dbSeek(xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
    a_AreaSC5 := SC5->(GetArea())
    
    dbSelectArea("SC5")
    dbSetOrder(1)
    If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
      c_ForPag := SC5->C5_FORPGT  
      c_Nat := SC5->C5_NATUREZ 
    Endif
    
    RestArea(a_AreaSC5)
  Endif
        
  dbSelectArea("SE1")
  dbSetOrder(2)
  dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC))
  While SE1->(!EoF()) .And. SE1->(E1_FILIAL + E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA) == xFilial("SE1") + SF2->(F2_DOC + F2_PREFIXO + F2_CLIENTE + F2_LOJA)
    RecLock("SE1", .F.)

    SE1->E1_FORPGT := c_ForPag  
    SE1->E1_NATUREZ := c_Nat

    MsUnlock()
    SE1->(dbSkip())
    Enddo


  RestArea(a_AreaSD2)
  RestArea(a_AreaSE1)
  RestArea(a_Area)

Return