#include 'totvs.ch'

user function tstGridMVC()

	GridMVCSQL()
	gridMVCJson()
	gridMVCArray()
return

static function GridMVCSql()
	local oGrid := GridMVCSQL():new("PE_TSTGRIDMVC"/*cIDModel*/)

	oGrid:setQuery("SELECT TOP 10 B1_COD,B1_DESC,B1_UM FROM SB1010 WHERE D_E_L_E_T_ <> '*'")
	oGrid:activate()
return

static function GridMVCJSON()
	local oGrid := GridMVCJSON():new("PE_TSTGRIDMVC"/*cIDModel*/)
	local cJSON := ""
	local oJSON := JsonObject():new()

	cJson += '{' + CRLF
	cJson += '  "content": [' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "aprovacao_documentos",' + CRLF
	cJson += '      "processDescription": "Aprovação de Documentos",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    },' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "FLUIGADHOCPROCESS",' + CRLF
	cJson += '      "processDescription": "Executar Tarefa Ad Hoc",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    },' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "inclusao_ferias",' + CRLF
	cJson += '      "processDescription": "inclusao_ferias",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    },' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "FLUIGADHOC",' + CRLF
	cJson += '      "processDescription": "Listar Tarefas",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    },' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "solicitacao_contratacao",' + CRLF
	cJson += '      "processDescription": "solicitacao_contratacao",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    },' + CRLF
	cJson += '    {' + CRLF
	cJson += '      "processId": "teste",' + CRLF
	cJson += '      "processDescription": "teste",' + CRLF
	cJson += '      "teste": "Aprovação de Documentos"' + CRLF
	cJson += '    }' + CRLF
	cJson += '  ],' + CRLF
	cJson += '  "message": {' + CRLF
	cJson += '    "message": "OK",' + CRLF
	cJson += '    "detail": "OK",' + CRLF
	cJson += '    "type": "INFO",' + CRLF
	cJson += '    "errorCode": null' + CRLF
	cJson += '  }' + CRLF
	cJson += '}' + CRLF

	oJson:fromJson(cJson)

	oGrid:setJson(oJson["content"])
    oGrid:setOnlyView(.t.)
    oGrid:setTitle("Lista de Processos Fluig")
    oGrid:setTitleField('processId',"ID")
    oGrid:setTitleField('processDescription',"Descrição")
    oGrid:setViewDef({|oView| modifyView(oView)})
    //oGrid:addOnlyField("ProcessDescription")
	oGrid:activate()
return

static function modifyView(oView)
    oView:showUpdateMsg(.f.)
    oView:showInsertMsg(.f.)
    oView:SetCloseOnOK({||.t.})
    oView:SetViewProperty("VIEW_GRID","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| MyDoubleClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})
return oView

static function MyDoubleClick(oFormulario,cFieldName,nLineGrid,nLineModel)
    local lRet := .f.
    local oView := FwViewActive()
    oView:lModify := .f.
    oView:ButtonCancelAction()
return lRet

static function gridMVCArray()
	local oGrid 	:= GridMVCArray():new("PE_TSTGRIDMVC"/*cIDModel*/)
	local aLines 	:= {}

	aAdd(aLines,{.t.,"01","TESTE 1","TESTE 2"})
	aAdd(aLines,{.t.,"02","TESTE 1","TESTE 2"})
	aAdd(aLines,{.t.,"03","TESTE 1","TESTE 2"})
	aAdd(aLines,{.t.,"04","TESTE 1","TESTE 2"})
	aAdd(aLines,{.t.,"05","TESTE 1","TESTE 2"})
	aAdd(aLines,{.t.,"06","TESTE 1","TESTE 2"})

	oGrid:addFieldTable("FIELD_MARK","L",1,0)
	oGrid:addFieldTable("FIELD_1","C",2,0)
	oGrid:addFieldTable("FIELD_2","C",10,0)
	oGrid:addFieldTable("FIELD_3","C",10,0)
	oGrid:setMarkField("FIELD_MARK")
	oGrid:setArray(aLines)
	oGrid:ACTIVATE()
return
