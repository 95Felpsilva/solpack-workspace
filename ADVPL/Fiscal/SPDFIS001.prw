#INCLUDE "PROTHEUS.CH"

/*/
Programa:SPDFIS001 
Autor:Ana Flávia Souza
Data:11/02/2020
Descricao  Ponto de entrada disponibilizado para tratar tipos de prod
           uto criados pelo usuario, relacionando-os com os tipos des
           critos no registro 0200 do Ato Cotepe 09/2008.            
           Ponto de entrada chamado a cada produto novo a ser lancado
           no registro 0200.                                         

Sintaxe    SPDFIS001(< PARAMIXB >)                                   

Parametros aTipo - Array of Record - Array com os tipos de produto pa
           drão do sistema.                                          
           É passado como parametro um array (aTipo) contendo o relac 
           ionamento dos tipos de produto que o sistema tem por padra
           o, e a sua correspondencia com a tabela de tipos do SPED F
           iscal.                                                    

Retorno    Array com os tipos de produto padrão do sistema acrescidos
           dos tipos criados pelo usuario                            

Uso        Protheus 12 > SIGAFIS                                     
/*/
User Function SPDFIS001()
Local aArea		:= GetArea()
Local aReturn	:= PARAMIXB[1]
	
	aAdd (aReturn,{"AI","08"})
	aAdd (aReturn,{"SV","09"})
	aAdd (aReturn,{"MP","01"})
	aAdd (aReturn,{"EM","02"})    
	aAdd (aReturn,{"PI","06"})
	aAdd (aReturn,{"MC","07"})
	aAdd (aReturn,{"PA","04"})
	aAdd (aReturn,{"SP","05"})
	aAdd (aReturn,{"SU|MO|SM","99"})
	aAdd (aReturn,{"MR","00"})
	aAdd (aReturn,{"PR","10"})
	
	RestArea(aArea)
	
Return (aReturn)

