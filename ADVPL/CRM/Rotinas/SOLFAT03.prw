#include 'protheus.ch'
#include 'TopConn.ch'

/*/{Protheus.doc} User Function SOLFAT03
    Tela para envio de mensagem ao CRM
    @type  Function
    @author Ramão Oliveira
    @since 15/03/2022
    @version 01
    @param , , 
    @return , ,  
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function SOLFAT03()
    local cPerg := ''
    local cEquipe := ''
    local cCodEquipe := ''
    local lResponder := .F.


//    local cEmpres:= '01'
//	local cFilia := '01'
//    RpcSetEnv(cEmpres,cFilia ,'','','FAT','U_SOLFAT01',{},.F.,.T.,.T.,.T.)

    if !select('ZZ1')
        dbSelectArea('ZZ1')
        ZZ1->(dbSetOrder(1))
    endif
    ZZ1->(dbGoTop())
    WHILE ZZ1->(!eof())
        cCodEquipe := ZZ1->ZZ1_EQUIPE
        cEquipe := UsrRetName(cCodEquipe)
        
        if ZZ1->ZZ1_RESPON == 'F'
            cPerg := ZZ1->ZZ1_PERGUN
            exit
        endif
        ZZ1->(dbSkip())
    ENDDO

    if !empty(cPerg)
        lResponder := msgYesNo("Nova Mensagem de: " + cEquipe + ". Deseja responder?" + CRLF + 'Mensagem: ' + CRLF + cPerg,'Mensagem de: ' + cEquipe)
        if lResponder
            U_SOLFAT01(,cCodEquipe)
        endif
    endif

    ZZ1->(dbGoTop())
return 


