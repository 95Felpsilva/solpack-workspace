#INCLUDE "TOPCONN.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

User Function MA261CPO()
Local aTam := {}


aTam := TamSX3('D3_ZZTURNO')
Aadd(aHeader, {'Turno' , 'D3_ZZREQ' , PesqPict('SD3', 'D3_ZZTURNO' , aTam[1]) , aTam[1], aTam[2], '', USADO, 'C', 'SD3', ''})


Return Nil