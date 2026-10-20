#include 'protheus.ch'

/*/{Protheus.doc} IPGeraXML
Classe para gerar XML
@author André Oquendo	
@since 01/07/2019
@version 1.0
@return nil
@type class
/*/

class IPGeraXML 
	data cCaminho 	as string 		//Caminho a ser salvo o XML
	data cArquivo 	as string 		//Nome arquivo
	data cSheet 	as string 		//Nome planilha
	data cTable 	as string 		//Nome tabela
	data aCabec		as array		//Array com o cabeçalho do XML
	data aItens		as array		//Array com os itens do XML
	
	method new() constructor 
	method setCaminho()
	method getCaminho()
	method setArquivo()
	method getArquivo()	
	method setSheet()
	method getSheet()
	method setTable()
	method getTable()	
	method setCabec()
	method setItens()
	method createXML()
	method showXML()

endclass


method new(cCaminho,cArquivo) class IPGeraXML

	Default ::cCaminho	:= GetTempPath()
	Default ::cArquivo	:= UsrRetName(RetCodUsr())+"_"+dtos(dDataBase)+"_"+strtran(time(),":")+".xml"
	Default ::cSheet	:= allTrim(FunName())
	Default ::cTable	:= allTrim(FunName())
	
return

method setCaminho(cNome) class IPGeraXML
	::cCaminho := cNome
return

method getCaminho() class IPGeraXML
return ::cCaminho

method setArquivo(cNome) class IPGeraXML
	::cCaminho := cNome
return

method getArquivo() class IPGeraXML
return ::cArquivo

method setSheet(cNome) class IPGeraXML
	::cSheet := cNome
return

method getSheet() class IPGeraXML
return ::cSheet

method setTable(cNome) class IPGeraXML
	::cSheet := cNome
return

method getTable() class IPGeraXML
return ::cSheet

method setCabec(aDados) class IPGeraXML
	::aCabec := aDados
return

method setItens(aDados) class IPGeraXML
	::aItens := aDados
return

method createXML() class IPGeraXML
	Local oExcel 	:= FWMSEXCEL():New()
	local nR		:= 0

	oExcel:AddworkSheet(::cSheet)
	oExcel:AddTable(::cSheet,::cTable)
	For nR := 1 to len(::aCabec)
		oExcel:AddColumn(::cSheet,::cTable,::aCabec[nR],1,1)
	Next

	For nR := 1 to len(::aItens)
		oExcel:AddRow(::cSheet,::cTable,::aItens[nR])
	Next

	oExcel:Activate()
	oExcel:GetXMLFile(::cCaminho + ::cArquivo)
return

method showXML(lShellScript, cDiretorio, cExtensao) class IPGeraXML
	local oExcelApp 		:= MsExcel():New()

	default cDiretorio 		:= ::cCaminho + ::cArquivo
	default cExtensao		:= ".XML"
	default lShellScript	:= .f.

	if lShellScript
		ShellExecute("Open", "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE", cDiretorio, "", 1)
	else
    	oExcelApp:WorkBooks:Open(::cCaminho + ::cArquivo) // Abre a planilha
    	oExcelApp:SetVisible(.T.)
	endif
return
