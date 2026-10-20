#include 'protheus.ch'
#include 'topconn.ch'

User Function MT105QRY             
Local cQuery 
Local cAdmin := '000000'

If !__cUserId$cAdmin //!(FWIsAdmin(__cUserID ))
	cQuery = " CP_USER ='" + RetCodUsr() + "' "
Endif


Return cQuery