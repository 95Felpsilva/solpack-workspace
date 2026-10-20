#include 'totvs.ch'

#Define HORA 	24
#Define MINUTO 	60
#Define SEGUNDO 60

user function tstTime()
	RpcSetType(3)
	RpcClearEnv()
	RpcSetEnv("01","0101")

	oTime := Time():new("00:05")

	oTime:subTimeHour(dDataBase,"00:05","50:15")
return

/*/{Protheus.doc} TIME
Classe responsável realizar manipulacao de variaveis do tipo hora
@author Tiago Faria
@since 17/06/2014
@version 1.0
@type class
/*/
CLASS TIME
Data cHora 		as string
Data nHora 		as numeric
Data nSegundo 	as numeric
Data nMinuto 	as numeric
Data nCasaHora	as numeric

METHOD New(cHora,nCasaHor) CONSTRUCTOR
METHOD isTimeOK(lMsg)
METHOD calcTotalHora(dDtIni,cHrIni,dDtFim,cHrFim,lRetSeg,nCasas)
METHOD secToTime(nTime,nStr)
METHOD timeToSec(cHora)
METHOD diffTime(cHoraIni,cHoraFim)
METHOD qtdSecDay()
METHOD qtdSecMinute()
METHOD vldDateTime(dDtIni,cHoraIni,dDtFim,cHoraFim)
METHOD sumSecHour(dDtAtu,nHrAtu,nQtdHr)
METHOD subSecHour(dDtAtu,nHrAtu,nQtdHr)
METHOD sumTimeHour(dDtAtu,cHrAtu,cQtdHr)
METHOD subTimeHour(dDtAtu,cHrAtu,cQtdHr)
/*getter's and setter's*/

METHOD setcHora()
METHOD getcHora()

METHOD setHora()
METHOD getHora()

METHOD setMinuto()
METHOD getMinuto()

METHOD setSegundo()
METHOD getSegundo()

ENDCLASS
/*/{Protheus.doc} New
Metodo construtor da classe TIME
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param cHora, character, recebe hora a ser manipulada na classe TIME, caso a hora passada não tenha segundo a classe automaticamente irá considerar o segundo como 0
@param nCasaHora, numerico, quantidade de casas a considerar nas horas por exemplo "100:00:00" nCasaHoras deverá ser 3, valor default 2
@type method
/*/
METHOD New(cHora,nCasaHora) CLASS TIME
	Default cHora 		:= "00:00:00"
	Default nCasaHora 	:= 2

	cHora := formatHora(cHora)
	self:cHora 		:= cHora
	self:nCasaHora 	:= nCasaHora
	self:setHora(cHora)
	self:setMinuto(cHora)
	self:setSegundo(cHora)
Return self
/*/{Protheus.doc} isHoraOK
Metodo verifica se a hora está digitada corretamente
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param lMsg, logico, se .t. exibe mensagem caso haja inconsistencia na hora digitada se .f. não exibe mensagem
@return lRet, logico, se .t. a hora está ok, se .f. não está
/*/
METHOD isTimeOK(lMsg) CLASS TIME
	Local lRet		:= .t.
	Default lMsg 	:= .f.

	if self:getHora() > 23 .or. self:getMinuto() > 59 .or. self:getSegundo() > 59
		lRet := .f.
		If lMsg
			Help( ,, "isHoraOK",,"Hora informada é invalida", 1, 0)
		EndIf
	endif
Return lRet
/*/{Protheus.doc} calcTotalHora
Metodo responsável por calcular o total de horas entre data e hora inicial e data e hora final
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param dDtIni, data, indica a data inicial
@param cHrIni, caracter, indica a hora inicial
@param dDtFim, data, indica a data final
@param cHrFim, caracter, indica a hora final
@param lRetSeg, logico, se .t. retorna o total em segundos se .f. retorna em string, valor default é .f.
@param nCasas, numerico, indica o numero de casas a ser considerado caso o retorno seja em string, valor default é self:nCasaHora
@return xRet, indefinido, caso lSegundo for igual a true retorna o total de segundos caso seja false retorna o total em string exemplo "120:00:00"
/*/
METHOD calcTotalHora(dDtIni,cHrIni,dDtFim,cHrFim,lRetSeg,nCasas) CLASS TIME
	Local oHrIni 	:= 0
	Local oHrFim 	:= 0
	Local nDiasDiff := nil
	Local nSeg		:= 0
	Local xRet		:= ""

	Default lRetSeg 	:= .f.
	Default nCasas		:= self:nCasaHora
	if empty(dDtIni) .or. empty(strtran(cHrIni,":")) .or. empty(dDtFim) .or. empty(strtran(cHrFim,":"))
		nSeg := 0
	else
		oHrIni 	:= Time():New(cHrIni)
		oHrFim 	:= Time():New(cHrFim)
		nDiasDiff := DateDiffDay(dDtIni,dDtFim)
		nSeg := self:diffTime(oHrIni:getcHora(),oHrFim:getcHora())
		if nDiasDiff > 0
			nSeg += nDiasDiff*self:qtdSecDay()
		endif
	endif
	if !lRetSeg
		xRet := self:secToTime(nSeg,nCasas)
	else
		xRet := nSeg
	endif
Return xRet
/*/{Protheus.doc} timeToSec
Metodo para converter string para segundos
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param cHora, caracter, string com a hora a ser convertida valor default é self:getcHora()
@return nTime, numerico, retorna o total em segundos da hora recebida por parametro
/*/
METHOD timeToSec(cHora) CLASS TIME
	Local oHora := nil
	DEFAULT cHora:= self:getcHora()

	oHora := Time():New(cHora)
	nTime := (oHora:getHora()*3600)+(oHora:getMinuto()*60)+oHora:getSegundo()
Return nTime
/*/{Protheus.doc} secToTime
Metodo para converter segundos em tempo
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param nTime, numerico, indica o numero de segundos a ser convertido
@param nStr, numerico, indica o numero de casas a ser considerado para horas, valor default é 2
@return cTime, numerico, retorna os segundos convertido em string
/*/
METHOD secToTime(nTime,nStr) CLASS TIME
	Local cTime		:= ""
	Local nTemp		:= 0

	DEFAULT nTime := 0
	DEFAULT nStr := 2

	nTemp := Int(nTime/60)

	nHour := Int(nTemp/60)
	
	if nHour == 24
		nHour := 0
	endif
	
	nMinute := nTemp - (nHour*60)

	nSecond := nTime - ((nHour*3600)+(nMinute*60))

	cTime := StrZero(nHour,nStr,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)
Return cTime
/*/{Protheus.doc} diffTime
Metodo responsável por retornar a diferenca em segundos entre duas horas do tipo string
@author Tiago Faria
@since 17/06/2014
@version 1.0
@param cHoraIni, caracter, hora inicial, valor default "00:00:00"
@param cHoraFim, caracter, hora final, valor default "00:00:00"
@return nRet, numerico, retorna a diferenca em segundos
/*/
METHOD diffTime(cHoraIni,cHoraFim) CLASS TIME
	Local nSegIni 	:= 0
	Local nSegFim 	:= 0
	Local nRet		:= 0

	Default cHoraIni := "00:00:00"
	Default cHoraFim := "00:00:00"

	nSegIni 	:= self:timeToSec(cHoraIni)
	nSegFim 	:= self:timeToSec(cHoraFim)

	if nSegIni > nSegFim
		nRet := self:qtdSecDay() - (nSegIni - nSegFim)
	else
		nRet := nSegFim - nSegIni
	endif
Return nRet

/*/{Protheus.doc} qtdSecDay
Retorna quantidade de segundos referente a 1 dia
@author Tiago Faria
@since 17/06/2015
@version 1.0
/*/
METHOD qtdSecDay() CLASS TIME
Return HORA*MINUTO*SEGUNDO
/*/{Protheus.doc} qtdSecMinute
Retorna quantidade de segundos referente a 1 minuto
@author Tiago Faria
@since 17/06/2015
@version 1.0
/*/
METHOD qtdSecMinute() CLASS TIME
Return MINUTO*SEGUNDO
/*/{Protheus.doc} vldDateTime
Funcao responsavel por validar a hora inicial e final, considerando datas
@author Tiago Faria
@since 18/06/2015
@param dDtIni, data, indica a data inicial
@param cHrIni, caracter, indica a hora inicial
@param dDtFim, data, indica a data final
@param cHrFim, caracter, indica a hora final
@param lMsg, logico, se .t. exibe mensagem informando o erro se .f. não exibe mensagem, valor default é .f.
@obs caso alguns dos parametros estejam vazios não é realizado validação e retorna .t.
@version 1.0
/*/
METHOD vldDateTime(dDtIni,cHrIni,dDtFim,cHrFim,lMsg) CLASS TIME
	Local lRet := .t.
	Local oHoraIni := Time():New(cHrIni)
	Local oHoraFim := Time():New(cHrFim)
	Default lMsg := .f.

	if empty(dDtIni) .or. empty(strtran(cHrFim,":")) .or. empty(dDtFim) .or. empty(strtran(cHrFim,":"))
		lRet := .T.
	else
		if dDtFim < dDtIni
			if lMsg
				Help( ,, "vldDateTime",,"Data final, " + dtoc(dDtFim) + " é menor que a data inicial " + dtoc(dDtIni) + ". Digite uma data maior ou igual a " + dtoc(dDtIni) , 1, 0)
			endif
			lRet := .f.
		elseif dDtFim == dDtIni .and. self:timeToSec(oHoraIni:getcHora()) > self:timeToSec(oHoraFim:getcHora())
			if lMsg
				Help( ,, "vldDateTime",,"Hora final " + oHoraFim:getcHora() + " não pode ser menor que a hora Inicial " + oHoraIni:getcHora() + ". Digite uma hora maior ou igual a " + oHoraIni:getcHora() , 1, 0)
			endif
			lRet := .f.
		endif
	endif
Return lRet
/*/{Protheus.doc} sumSecHour
Método responsável por realizar a soma de hora de acordo com uma data e hora inicial, informadas por parametro
@author Tiago Faria
@since 24/06/2015
@param dDtAtu, data, Data a ser considerada na soma
@param nHrAtu, numerico, hora em segundos a ser considerado como hora inicial
@param nQtdHr, numerico, quantidade de horas em segundos a ser somado
@return aDateSum, array, retorna array com a data e hora somados exemplo retorno{<data>,<nSegundos>,<cHora>}
@version 1.0
/*/
METHOD sumSecHour(dDtAtu,nHrAtu,nQtdHr) CLASS TIME
	Local aDateSum 		:= {}
	Local nHrSum 		:= nHrAtu+nQtdHr
	Local nQtdDaySum 	:= 0

	if nHrSum >= ::qtdSecDay()
		nQtdDaySum := int((nHrSum-::qtdSecDay())/::qtdSecDay())+1
		dDtAtu+=nQtdDaySum
	endif
	nHrSum := ::timetosec(::secToTime(nHrSum-(nQtdDaySum*::qtdSecDay())))
	aDateSum := {dDtAtu,nHrSum,::secToTime(nHrSum)}
return aDateSum

/*/{Protheus.doc} subSecHour
Método responsável por realizar a subtração de hora de acordo com uma data e hora inicial, informadas por parametro
@author Tiago Faria
@since 24/06/2015
@param dDtAtu, data, Data a ser considerada na soma
@param nHrAtu, numerico, hora em segundos a ser considerado como hora inicial
@param nQtdHr, numerico, quantidade de horas em segundos a ser somado
@return aDateSum, array, retorna array com a data e hora somados exemplo retorno{<data>,<nSegundos>,<cHora>}
@version 1.0
/*/
METHOD subSecHour(dDtAtu,nHrAtu,nQtdHr) CLASS TIME
	Local aDateSub 		:= {}
	Local nHrSub 		:= nHrAtu-nQtdHr
	Local nQtdDaySub 	:= 0

	if nHrSub < 0
		nHrSub := (nHrSub * -1)
		nQtdDaySub := int(nHrSub / ::qtdSecDay()) + 1
		dDtAtu-=nQtdDaySub
	endif
	
	while nHrSub > ::qtdSecDay()
		nHrSub -= ::qtdSecDay()
	enddo
	//nHrSub := ::qtdSecDay() - nHrSub
	aDateSub := {dDtAtu,nHrSub,::secToTime(nHrSub)}
return aDateSub

/*/{Protheus.doc} sumTimeHour
Método responsável por realizar a soma de hora de acordo com uma data e hora inicial, informadas por parametro
@author Tiago Faria
@since 24/06/2015
@param dDtAtu, data, Data a ser considerada na soma
@param cHrAtu, caracter, hora em caracter a ser considerado como hora inicial
@param cHrSum, caracter, quantidade de horas em caracter a ser somado
@return aDateSum, array, retorna array com a data e hora somados exemplo retorno{<data>,<hora>}
@version 1.0
/*/
METHOD sumTimeHour(dDtAtu,cHrAtu,cHrSum) class TIME
	Local aDateSum 	:= {}
	Local nHrAtu	:= ::timetosec(formatHora(cHrAtu))
	Local nHrSum	:= ::timetosec(formatHora(cHrSum))

	aDateSum := ::sumSecHour(dDtAtu,nHrAtu,nHrSum)

return aDateSum

/*/{Protheus.doc} subTimeHour
Método responsável por realizar a subtração de hora de acordo com uma data e hora inicial, informadas por parametro
@author Tiago Faria
@since 24/06/2015
@param dDtAtu, data, Data a ser considerada na soma
@param cHrAtu, caracter, hora em caracter a ser considerado como hora inicial
@param cHrSum, caracter, quantidade de horas em caracter a ser somado
@return aDateSum, array, retorna array com a data e hora somados exemplo retorno{<data>,<hora>}
@version 1.0
/*/
METHOD subTimeHour(dDtAtu,cHrAtu,cHrSub) class TIME
	Local aDateSub 	:= {}
	Local nHrAtu	:= ::timetosec(formatHora(cHrAtu))
	Local nHrSub	:= ::timetosec(formatHora(cHrSub))

	aDateSub := ::subsecHour(dDtAtu,nHrAtu,nHrSub)
return aDateSub

METHOD setcHora(cHora) CLASS TIME
	Default cHora := "00:00:00"
	self:cHora := formatHora(cHora)
	self:setnHora(cHora)
	self:setnMinuto(cHora)
	self:setnSegundo(cHora)
Return

METHOD getcHora() CLASS TIME
Return self:cHora

METHOD setHora(cHora) CLASS TIME
	self:nHora := val(subStr(cHora,1,self:nCasaHora))
Return

METHOD getHora() CLASS TIME
Return self:nHora

METHOD setMinuto(cHora) CLASS TIME
	self:nMinuto := val(subStr(cHora,self:nCasaHora+2,2))
Return

METHOD getMinuto() CLASS TIME
return self:nMinuto

METHOD setSegundo(cHora) CLASS TIME
	if len(cHora) > 5
		self:nSegundo := val(subStr(cHora,self:nCasaHora+5,2))
	else
		self:nSegundo := 0
	endif
Return

METHOD getSegundo() CLASS TIME
Return self:nSegundo

Static Function formatHora(cHora)
	if len(cHora) == 5 .and. !empty(strtran(cHora,":"))
		cHora += ":00"
	endif
Return cHora
