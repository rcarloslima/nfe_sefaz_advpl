#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RWMAKE.CH"  

#IFNDEF VAR_NAME_LEN
	#DEFINE VAR_NAME_LEN	50
	#DEFINE URL 
#ENDIF	                                                                                                         

/*/{Protheus.doc} CapturaNfe
(      Rotina para chamada no menu    )
@type function
@author Ruann Carlos
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
/*/
User Function CapturaNfe()

	Local oNFe 		:= Nil
	Local _nVarName := SetVarNameLen( VAR_NAME_LEN ) 
	
	oNFe := NFeImport():New()
	oNFe:Show()	

	FreeObj(oNFe)
	
	SetVarNameLen( _nVarName )  

Return