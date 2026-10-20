#INCLUDE 'RWMAKE.CH'

/*/{Protheus.doc} User Function MT415BRW
    (long_description)
    @type  Function
    @author Ramão Oliveira
    @since 01/04/2022
    @version 01
    @param , , 
    @return , , 
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MT415BRW()
    //Local cFiltro := "CJ_NUM <> '000001'"
    local cFiltro := ''
    if isInCallStack('CRMA290')
   	    U_SOLFAT02()
    endif
    RETURN cFiltro
Return 
