#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FLAGSEF   ºAutor  ³Donizete            º Data ³  02/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este programa foi criado para fazer um flag no SEF durante º±±
±±º          ³ a contabilização de cheques. Isto foi necessário em função º±±
±±º          ³ do uso do parâmetro MV_CTBAIXA estar setado como "A-Ambos",º±±
±±º          ³ nesta configuração o sistema contabiliza tanto no LP 530   º±±
±±º          ³ quanto no LP 590 gerando um duplicidade. Quando o sistema  º±±
±±º          ³ passar pelo LP 590 o título baixado com 1 cheque para 1    º±±
±±º          ³ título já estará flegado.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Usar em algum campo no LP 530 somente se o parâmetro      º±±
±±º          ³ MV_CTBAIXA estiver como "A-Ambos".                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FlagSEF()

// Variáveis do programa.
Local _xAreaSEF := {}
Local _xArea	:= GetArea()

// Verifica se o número do cheque foi informado.
If Empty(SE5->E5_NUMCHEQ)
	Return(" ")
EndIF

// Carrega arquivo de trabalho e salva área.
dbSelectArea("SEF")
_xAreaSEF := GetArea()
dbSetOrder(3)

// Procura pelo título no SEF.
dbSeek(xFilial("SEF")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_NUMCHEQ)+SE5->E5_SEQ)
// Se encontrar, verificar se não foi aglutinado e fazer um flag no mesmo.
If Found() .And. Empty(SEF->EF_OK)
	If RecLock("SEF",.F.)
		SEF->EF_LA := "S"
		msunlock()
	EndIf
EndIf

// Restaura áreas de trabalho.
RestArea(_xAreaSEF)
RestArea(_xArea)

Return(" ")
