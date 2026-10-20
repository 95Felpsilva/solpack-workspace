#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function COND4OP(lGatilho)
   Local oDlg, oLbx
   Local aD4  := {}
   Local aRet   := {}
   Local lRet   := .F.
   local cGrupo := ''
   local cQuery := ""
   local cAlias := ''
//   local aD4 := {}
   local cOp := alltrim(FwFldGet("Z5_OP"))
   if empty(cOp )
      msgAlert('OP Não Informada')
      return .F.
   endif

 

   cGrupo := superGetMv('ZZ_GBOBINA',.F.,'4010')
   cAlias := getNextAlias()

    cQuery := "select distinct "                            + CRLF
    cQuery += "D4_COD AS COD,"                              + CRLF
    cQuery += "B1_DESC AS B1_DESC"                          + CRLF
    cQuery += "FROM  " + RETSQLTAB("SD4")                   + CRLF
    cQuery += "INNER JOIN  " + RETSQLTAB("SB1")             + CRLF
    cQuery += "   ON " + RETSQLFIL("SB1")                   + CRLF
    cQuery += "  AND " + RETSQLDEL("SB1")                   + CRLF
    cQuery += "  AND B1_COD = D4_COD"                       + CRLF
    cQuery += "  AND B1_GRUPO = '" + cGrupo + "'"           + CRLF
    cQuery += "WHERE " + RETSQLFIL("SD4")                   + CRLF
    cQuery += "  AND " + RETSQLDEL("SD4")                   + CRLF
    cQuery += "  AND D4_OP = '" + cOp + "'"                 + CRLF
    cQuery += "ORDER BY D4_COD"                             + CRLF
	TCQUERY cQuery NEW ALIAS &cAlias

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	if (cAlias)->(!EoF())
        while (cAlias)->(!EoF())
            aadd(aD4,{(cAlias)->COD,(cAlias)->B1_DESC})
            (cAlias)->(dbSkip())
        end
    ENDIF
	(cAlias)->(DbCloseArea())     

   if lGatilho 
      if len(aD4) == 1
         return aD4[1]
      else
         return ''
      endif
   endif


   If Len(aD4) < 1
      aAdd(aD4,{" "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Bobinas" FROM 0,0 TO 240,500 PIXEL

     @ 10,10 LISTBOX oLbx FIELDS HEADER 'Produto' /*"Roteiro"*/, 'Descrição' SIZE 230,95 OF oDlg PIXEL

     oLbx:SetArray( aD4 )
     oLbx:bLine     := {|| {aD4[oLbx:nAt,1], aD4[oLbx:nAt,2]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1]}}}

  DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
     If Empty(aRet[1])
        lRet := .F.
     else
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial('SB1')+padr(aRet[1],tamSX3('B1_COD')[1],'')))
     EndIf
  EndIf
Return lRet
