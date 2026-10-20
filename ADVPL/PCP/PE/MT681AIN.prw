#Include "Protheus.ch"


User Function MT681AIN()

// sempre troca apontamento para Parcial.
RecLock("SH6",.F.)
Replace SH6->H6_PT With "P"
SH6->(MsUnLock())


Return
