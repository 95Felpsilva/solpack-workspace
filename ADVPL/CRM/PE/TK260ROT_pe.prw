

/*/{Protheus.doc} User Function TK260ROT
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
User Function TK260ROT()
    local aMenu := {}
    if isInCallStack('CRMA290')
        U_SOLFAT02()
    endif
Return aMenu
