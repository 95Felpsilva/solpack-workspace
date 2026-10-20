#include "rwmake.ch"    

User Function APONTSEQ()

SetPrvt("_CGRUPO,_CCLAS1,_CCLAS2,CALIAS,CORD")
SetPrvt("CREG,_CCODANT,_CCOD,_CSEQTEMP,_CSEQ,")

/*/{Protheus.doc}	APONTSEQ
Fazer a sequencia automatica no apontamento de vistias CRM 

@author				BETE - EQUIPE INTERNA
@date				04/05/2016
 
/*/
       
cAlias := Alias()
cOrd   := IndexOrd()
cReg   := Recno()

//_cSeqAnt  := ALLTRIM(M->AD5_SEQUEN)
_cDataAnt := DTOS(M->AD5_DATA)
_cVendAnt := M->AD5_VEND


DbSelectArea("AD5")
DbSetOrder(1)
DbSeek(xFilial("AD5")+_cVendAnt+_cDataAnt,.T.)

 If AD5->(Found())=.T.

	While DTOS(AD5->AD5_DATA) == _cDataAnt .AND. AD5->AD5_VEND == _cVendAnt  

		_cSeqTemp := AD5->AD5_SEQUEN

       AD5->(Dbskip())                    

	Enddo    

 Else
 
	 _cSeqTemp := "00"

 Endif

 _cSeq := StrZero(Val(_cSeqTemp)+1,2)
 _cCod := _cSeq 


Dbselectarea(cAlias)
Dbsetorder(cOrd)  
Dbgoto(cReg)

Return(_cCod)           


