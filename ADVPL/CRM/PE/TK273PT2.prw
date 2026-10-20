#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TK273PT2
Ponto de entrada executado após a conversão do prospect em cliente, para gravação de campos padrão e personalizados na tabela SA1 (Clientes). 
Este ponto de entrada é executado após gravação do cliente.
@author Cristiano Pedroni
@since 06/12/2017
/*/

User Function TK273PT2()

Local aArea := GetArea()
Local aSA1	:= SA1->(GETAREA())

Reclock("SA1",.F.)                                
SA1->A1_CODPAIS := SUS->US_ZZCODPA // Código do Pais BACEN   
SA1->A1_SEGMENT := SUS->US_ZZSEG   // Segmento
SA1->A1_ZZORI   := SUS->US_ZZORI   // Origem do cliente      
SA1->A1_PAIS    := SUS->US_PAIS    // País
SA1->A1_CONTRIB := SUS->US_CONTRIB // Contribuinte        
SA1->A1_FAX     := SUS->US_FAX     // Telefone 2 
SA1->A1_TELEX   := SUS->US_ZZTEL   // Telefone 3 
SA1->A1_CONTATO := SUS->US_ZZCONT  // Contato    
SA1->A1_GRUPO   := '1'             // Grupo (campo personalizado)
SA1->A1_NATUREZ := SUS->US_NATUREZ // Natureza    
SA1->A1_RISCO   := 'E'             // Risco do Cliente
SA1->A1_ZZVEND  := RETFIELD("SA3",1,xfilial("SA3")+SA1->A1_VEND,"A3_NOME") // Nome do Vendedor                                               
MsUnlock()

SA1->(RestArea(aSA1))
RestArea(aArea)

Return