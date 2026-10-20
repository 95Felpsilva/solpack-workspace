#include 'protheus.ch'
#include 'parmtype.ch'

User function UFINA100(lInterface, aInfos, aLayOut, aSaidas, aVetores)

Local aNewVet := array(3)

aNewVet[1] := {3}//nPosRotina
aNewVet[2] := aClone(aVetores[1]) //aRotAuto
aNewVet[3] := {3} // nOpcAuto onde 3 = Pagar, 4 = Receber, inclusive a opção pode ser conforme a posição de aVetores

Return aClone(aNewVet)
	
