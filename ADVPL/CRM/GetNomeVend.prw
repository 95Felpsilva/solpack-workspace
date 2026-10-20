#include 'protheus.ch'
#include 'parmtype.ch'

user function GetNomeVend()
return IF(INCLUI,"",RETFIELD("SA3",1,XFILIAL("SA3")+RETFIELD("SA1",1,XFILIAL("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA),"SA1->A1_VEND"),"SA3->A3_NOME"))