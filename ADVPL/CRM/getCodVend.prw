#include 'protheus.ch'
#include 'parmtype.ch'

user function getCodVend()
return IIF(INCLUI,"",RETFIELD("SA1",1,XFILIAL("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA),"SA1->A1_VEND"))     