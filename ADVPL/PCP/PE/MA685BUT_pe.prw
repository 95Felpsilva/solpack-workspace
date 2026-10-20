#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} MA685BUT
No início da Função, antes de montar a ToolBar da Manutenção de Apontamentos, deve ser usado para adicionar botões do usuário, onde nestes serão inclusos as confirmações de apontamentos e as necessidades específicas do usuário.
@author Tiago Faria
@since 17/07/2019
@version 1.0
@return aButtons, array, array com as novas opções da tela

@type function
/*/
user function MA685BUT()
	local aButtons := {}
	
	if INCLUI
		Aadd(aButtons, {'PRODUTO',{||u_A685Mtela()},"# Explosão do 1º nível da estrutura - Solpack","# 1º Nivel - Solpack"}) 
	endif
return aButtons