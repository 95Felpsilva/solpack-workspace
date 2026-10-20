#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TMKGRSP
Este ponto de entrada é chamado após a gravação da conversão do Suspect para o Prospect.
Finalidade: gravação de campos personalizados na tabela SUS.
@author Cristiano Pedroni
@since 18/12/2017
/*/

User Function TMKGRSP(cprospect,cloja)

Local aArea := GetArea()
Local aSUS	:= SUS->(GETAREA())

Reclock("SUS",.F.)                                
SUS->US_ZZORI   := ACH->ACH_ZZORI // origem do cliente 
SUS->US_ZZSEG   := ACH->ACH_ZZSEG // segmento do cliente  
SUS->US_PAIS    := '105'          // país
SUS->US_ZZCODPA := '01058'        // país Bacen
MsUnlock()

SUS->(RestArea(aSUS))
RestArea(aArea)

Return

