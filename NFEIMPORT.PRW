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
/*/{Protheus.doc} Classe para controle a NFe
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Class NFeImport

	Data cBranch
	Data _cUser 
	Data _cCodUser
	
	Data _cChave
	Data _cCaptcha 
	Data _nId 
	
	Data _cPath 
	Data _cImage
	
	Data _oXml
	Data _cXml
	Data _cTemp
	
	Data oTBitmap
	
	Data _oDlg
	Data oMeter
	
	Data cError   	  	  
	Data cWarning
	
	Data oGetPesq
	Data oDlgPesq

	//Construtor
	Method New() Constructor
	
	//View
	Method Initialize()
	Method Show()
	Method Import()
	Method GenerateCaptcha()
	Method UpdateImage()
	Method DeleteImage()
	Method ViewXML()
	Method Close()
	Method GeneratePreNote() 
	Method GetNFe()
	Method Informative()
	Method UpdateProgressBar()
	Method AdditionalInfor()
	Method GridAdditionalInfor()
	Method SelectBranch()
	Method ConsultProduct()
	Method SetGridAdditionalInfor()
	Method ValidAdditionalInfor() 
	
EndClass
/*/{Protheus.doc} Metodo para Inicializar a Classe
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method New() Class NFeImport 

	Self:_cChave   	:= Space(44)
	Self:_cCaptcha 	:= Space(10)
	Self:_nId	   	:= 0 
	Self:_cXml		:= ""
	Self:_oXml		:= nil
	Self:_cTemp		:= GetTempPath()
	Self:_cPath 	:= Self:_cTemp + "Captcha\" 
	Self:oMeter		:= Nil
	Self:cBranch	:= xFilial('SF1')
	Self:_cUser		:= AllTrim(UsrFullName(RetCodUsr()))
	Self:_cCodUser	:= RetCodUsr()	
	Self:_oDlg		:= Nil	 
			
Return
/*/{Protheus.doc} Metodo para controle da apresentacao
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method Initialize() Class NFeImport
	
	Local _cTitle := OemToAnsi('Importar NFe do Site')
	Local nMeter  := 0

	//DEFINE MSDIALOG Self:oDlg TITLE _cTitle FROM 000, 000  TO 250, 520 COLORS 0, 16777215 PIXEL
	
	Self:_oDlg   := MSDialog():New(000,000,250,520,_cTitle,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	oGroup 		:= TGroup():New(002,002,060,260,'',Self:_oDlg,,,.T.)

	oSay1		:= TSay():New(005, 005,{||'Chave da NFe (Chave de Acesso contida no DANFE)'},oGroup,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
	
	oGet1 		:= TGet():New(013, 005,{|u| If(PCount()== 0, ::_cChave, ::_cChave := u ) },oGroup,150, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::_cChave",,,,)
	
	oSay2		:= TSay():New(030, 005,{||'Código da Imagem'},oGroup,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

	oGet2 		:= TGet():New(039, 005,{|u| If(PCount()== 0, ::_cCaptcha, ::_cCaptcha := u ) },oGroup,060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"::_cCaptcha",,,,)
	
	::oTBitmap 	:= TBitmap():New(010,160,260,184,,::_cImage,.T.,oGroup,{|| Self:UpdateImage() },,.F.,.F.,,,.F.,,.T.,,.F.)

	oTHButton 	:= THButton():New(035,200,"gerar outra imagem",oGroup,{|| Self:UpdateImage()  },60,20,,"Observação") 

	oGroup2 	:= TGroup():New(065,002,100,260,'Progresso',Self:_oDlg,,,.T.)
	
    ::oMeter 	:= TMeter():New(075,005,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oGroup2,250,16,,.T.)
		
	oTButton1 	:= TButton():New( 110, 005, "Importar"			, Self:_oDlg,{|| Self:Import()  }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton2 	:= TButton():New( 110, 048, "Visualizar XML"	, Self:_oDlg,{|| Self:ViewXML() }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	oTButton3 	:= TButton():New( 110, 090, "Cancelar"			, Self:_oDlg,{|| Self:Close()   }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	      		      	
Return 
/*/{Protheus.doc} Metodo para apresentacao das informacoes em tela
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method Show() Class NFeImport

	Self:GenerateCaptcha()
		
	Self:Initialize()
	
	Self:_oDlg:Activate(,,,.T.,{||.T. },,{|| .T. } )
	
Return
/*/{Protheus.doc} Metodo para controle da importacao do xml
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method Import() Class NFeImport

	If Len(::_cChave) <> 44
		Alert("A chave informada é menor/maior que o permitido impossibilitando uma consulta na Sefaz")
		Return
	EndIf 
		
	Self:UpdateProgressBar(25)	
		
	Self:GetNFe()
	
	Self:UpdateProgressBar(25)
		
	If ::cError # "" .or. ::cWarning # ""
		
		cMsg := "Erro: " + ::cError + "  -  Aviso: " + ::cWarning
	
		Self:Informative(cMsg,1)
		
		::_cXml := ""
		::_oXml := Nil
	
	Else	

		If ValType( ::_oXml ) <> Nil
			
			cMsg := "NF-e chave: " + ::_cChave + " importada com sucesso"
			
			Self:Informative(cMsg,2)
			
			If ValType( ::_oDlg ) <> Nil
				If MsgYesNo( "Deseja gerar Pré-Nota?" )
					Processa( {|| Self:GeneratePreNote() }, "Processando...")
				EndIf
			EndIf
		Else
			
			cMsg := "Erro na importação da NF-e chave: " + ::_cChave
			
			Self:Informative(cMsg,1)
			
		EndIf 
	
	EndIf
		
	Self:UpdateImage()
	
	//Limpa variaveis da tela
 	::_cCaptcha := Space(10)
 	//::_nId := 0
	Self:UpdateProgressBar(0)
	
Return
/*/{Protheus.doc} Metodo para consultar a xml na sefaz
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method GetNFe() Class NFeImport

	Local cQString 	  := "?Chave=" + Alltrim( ::_cChave )  + "&Id=" + cValToChar(::_nId) + "&Captcha=" + Alltrim( ::_cCaptcha ) 
	Local oClient	  := FWRest():New( Alltrim(Decode64(URL)) + "/nfe" )
	Local cXml		  := ""
	
	::cError   	  	  := ""
	::cWarning 	  	  := ""
	
	oClient:SetPath("/p/json-path/" + cQString)
	
	If oClient:Get()
	
		Self:UpdateProgressBar(25)
	
		::_cXml := oClient:GetResult()
		
		::_cXml := Alltrim(Substr(::_cXml,At('<nfeProc',::_cXml),Len(::_cXml)))
		::_cXml := StrTran( ::_cXml, '\"', '"' )
		
		::_cXml := '<?xml version="1.0" encoding="UTF-8"?>' + ::_cXml 
		
		::_cXml := Substr(::_cXml,1,Len(::_cXml)-1) //Retiro a ultima aspa
	
		::_oXml := XmlParser( ::_cXml, "_", @::cError, @::cWarning )
				
	Else
	
	   	cMsg := oClient:GetLastError()
		
	   	Self:Informative(cMsg,1)
	   
	Endif
	
	Self:UpdateProgressBar(25)

	FreeObj(oClient)

Return  
/*/{Protheus.doc} Metodo para gerar o captcha
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method GenerateCaptcha() Class NFeImport
	
	Local oRestClient := FWRest():New(Alltrim(Decode64(URL)) + "/captcha")
	Local yObj 	
	Local cResult	  := ""
	Local cCaptcha	  := ""	
	
	oRestClient:setPath("/p/json-path/")
	
	If oRestClient:Get()
	
		cResult := oRestClient:GetResult()
	
		If ValType(yObj) == 'O'
			yObj := FreeObj(yObj)
		EndIf
	
		If !Empty(cResult)	//FWJsonDeserialize(cResult,@yObj)
			
			cCaptcha 	:= Decode64(  Substr(cResult,At('Captcha":',cResult)+10,At(',"Chave":',cResult)-23)  ) //Decode64( yObj:Captcha )
			::_nId      := Val(Substr(cResult,At('{"Id":',cResult)+6,At(',"Captcha":"',cResult)-7))//yObj:Id
			::_cImage	:= ::_cPath  + "CAPTCHA" + STRZERO(::_nId,10) + ".PNG"
						
			If !ExistDir( ::_cPath )
				MakeDir( ::_cPath  )		
			EndIf
						
			MemoWrite( ::_cImage , cCaptcha )
	
		Else
			cMsg := "Erro no processamento do captcha."
		
			Self:Informative(cMsg,1)
			
		EndIf

	Endif
	
	FreeObj(oRestClient)
	
Return  
/*/{Protheus.doc} Metodo para atualizar o captcha
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method UpdateImage() Class NFeImport
	
	::DeleteImage()
	
	::GenerateCaptcha()
	
	::oTBitmap:Load(NIL, ::_cImage )
 	::oTBitmap:SetBmp( ::_cImage ) 
 	
Return  
/*/{Protheus.doc} Metodo para deletar a imagem
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method DeleteImage() Class NFeImport
	
	If File(::_cImage)
		Ferase(::_cImage)
	EndIf
	
Return 
/*/{Protheus.doc} Metodo para apresentar xml em tela
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method ViewXML() Class NFeImport

	Local oDlg
	
	If Empty( ::_oXml )
		
		cMsg := "Utilize a rotina de importar primeiro"
		
		Self:Informative(cMsg,1)
		
	Else 
		
		cFile := ::_cPath  + "XML" + STRZERO(::_nId,10) + ".xml"
		
		MemoWrite( cFile , ::_cXml  )
				
		oDlg := TDialog():New(150,150,500,500,'',,,,,,,,,.T.)
		
		oXml := TXMLViewer():New(10, 10, oDlg , cFile, 150, 150, .T. )
		
		If !oXml:setXML( cFile )
			Ferase(cFile)
		Else
			
			cMsg := "Arquivo XML não localizado."
		
			Self:Informative(cMsg,1)
			
		EndIf
		
		oDlg:Activate()
	EndIf
	
Return 
/*/{Protheus.doc} Metodo para fechar a execucao do programa
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method Close() Class NFeImport
	::DeleteImage()
	::_oDlg:End()
Return 
/*/{Protheus.doc} Metodo para criacao da pre-nota
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method GeneratePreNote() Class NFeImport
	
	Local _aItens := {}
	Local _aNFe   := {}
	Local oNF
	Local _aProd  := {}
	
	Private nPosValDes := 16
	//Private aRotina := {}
	
	If ValType( ::_oXml ) <> Nil
		
		If ::cError # "" .or. ::cWarning # ""
			
			cMsg := "Erro: " + ::cError + "  -  Aviso: " + ::cWarning
		
			Self:Informative(cMsg,1)
			
			::_cXml := ""
			::_oXml := Nil
		
		Else
		
			oNF 	   		:= ::_oXml:_NFeProc:_NFE
			oEmitente  		:= oNF:_InfNfe:_Emit
			oIdent     		:= oNF:_InfNfe:_IDE
			oDestino   		:= oNF:_InfNfe:_Dest
			oTotal     		:= oNF:_InfNfe:_Total
			oTransp    		:= oNF:_InfNfe:_Transp
			oDet       		:= oNF:_InfNfe:_Det
			oDet 	   		:= IIf(ValType(oDet)=="O",{oDet},oDet)
			oDestinatario 	:= oNF:_InfNfe:_Dest
			oFrete 			:= oTotal:_ICMSTot
			
			If Type("oNF:_InfNfe:_ICMS")<> "U"
				oICM := oNF:_InfNfe:_ICMS
			Else
				oICM := nil
			Endif
		
			oProtNFe 	 := ::_oXml:_NFeProc:_protNFe
			oChNFe 		 := oProtNFe:_infProt
		
			_cFilCNPJ    := oDestino:_CNPJ:Text
			_cFornCNPJ   := oEmitente:_CNPJ:Text
			_cNumNota    := oIdent:_NNF:Text
			_cSerNota    := oIdent:_SERIE:Text
			_dEmissao    := oIdent:_DEMI:Text
			_dEmissao    := IIF(!Empty(_dEmissao),SUBSTR(_dEmissao,1,4)+SUBSTR(_dEmissao,6,2)+SUBSTR(_dEmissao,9,2),"")
			_dEmissao	 := STOD(_dEmissao)
			_cTipo       := oIdent:_TPNF:Text
			_cChNFe 	 := AllTrim(oChNFe:_chNFe:TEXT)
			_cFrete 	 := IIf(Type("oFrete:_vFrete:TEXT")=="U",Nil,AllTrim(oFrete:_vFrete:TEXT))				
						
			// verifica se fornecedor existe
			If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2")+_cFornCNPJ))
				MsgAlert("CNPJ do fornecedor diferente da filial: (" + Transform(_cFornCNPJ,"@r 99.999.999/9999-99") + ") " + chr(13)+chr(10) + "nao e possivel processar a importacao desta NFE.")
				Return
			Endif
			
			// CGC da filial atual do usuario logado
			cCGCLocal := AllTrim(SM0->M0_CGC)
			
			_cNumNota := Right("000000000"+Alltrim(_cNumNota),9)
	
			// verifica se nota fiscal existe
			If SF1->(DbSeek(XFilial("SF1")+_cNumNota+Padr(_cSerNota,3)+SA2->A2_COD+SA2->A2_LOJA))
				MsgAlert("Nota fiscal numero: (" + Alltrim(_cNumNota) + "/" + _cSerNota + ") do fornecedor: (" + SA2->A2_COD + ") ja existe." + chr(13)+chr(10) + "Nao e possivel processar a importacao desta NFE.")
				Return
			EndIf
		
			/*
			// verifica se CNPJ do DESTINATARIO da NFE/XML e igual ao da filial atual
			If (cCGCLocal <> _cFilCNPJ)
				MsgAlert("O CNPJ: (" + Transform(_cFilCNPJ,"@r 99.999.999/9999-99") + ") da Nota Fiscal atual diferente do" + chr(13)+chr(10) + "CNPJ: (" + Transform(cCGCLocal,"@r 99.999.999/9999-99") + ") da filial atual." )
				Self:SelectBranch()
			Endif
	
			If Empty(::cBranch)
				MsgAlert("FIlial em branco.")
				Return
			EndIf
			*/	
			
			//Itens da Nota Fiscal
			If Valtype( oDet ) = "O"
				XmlNode2Arr( oDet, "_DET" )
			Endif
			
			_aDetAx :=  oDet
			_aItens :={}
			
			For _nTmp := 1 To Len( _aDetAx )
			
				_cCodProd    := _aDetAx[_nTmp]:_Prod:_cProd:Text
				_cDescProd   := _aDetAx[_nTmp]:_Prod:_xProd:Text
				_cNumItem    := _aDetAx[_nTmp]:_nItem:Text
				_cUm         := _aDetAx[_nTmp]:_Prod:_Ucom:Text
				_cQuant      := _aDetAx[_nTmp]:_Prod:_Qcom:Text
				_cValUnit    := _aDetAx[_nTmp]:_Prod:_VunCom:Text
				_cVlTot      := _aDetAx[_nTmp]:_Prod:_VProd:Text
				
				If Empty(_cCodProd)
					MsgInfo("Código do Produto em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
				
				If Empty(_cNumItem)
					MsgInfo("Numero do Item do Cabeçalho da Nota Fiscal em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
				
				If Empty(_cUm)
					MsgInfo("Unidade de Medida do Produto em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
				
				If Empty(_cQuant)
					MsgInfo("Quantidade do Produto em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
				
				If Empty(_cValUnit)
					MsgInfo("Valor do Produto em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
				
				If Empty(_cVlTot)
					MsgInfo("Valor Total do Produto em Branco !","***A T E N Ç Ã O***")
					Return
				Endif
						
				//Parametro com o armazém a ser utilizado
				_cLocal := "01"
				
				aAdd(_aProd, { _cCodProd          			,; //[01] Codigo Produto Xml
								_cUm						,; //[02] Unidade Medida Produto Xml
								Val(_cQuant)				,; //[03] Quantidade Produto Xml
								Val(_cValUnit)				,; //[04] Valor unitário Produto Xml
								Val(_cVlTot)				,; //[05] Valor Total Produto Xml
								Strzero(Val(_cNumItem),4) 	,; //[06] Numero do item Xml
								_cLocal						,; //[07] Armazém
								SA2->A2_COD					,; //[08] Código do Fornecedor
								SA2->A2_LOJA				,; //[09] Código da Loja
								::cBranch					,; //[10] Filial
								""							,; //[11] Código do Produto no protheus
								_cNumNota					,; //[12] Numero da Nota Fiscal Xml
								Strzero(Val(_cSerNota),3)	,; //[13] Serie da Nota Fiscal Xml
								_dEmissao					,; //[14] Emissao da Nota Fiscal Xml
								SA2->A2_NOME				,; //[15] Razao Social
								_cDescProd					,; //[16] Descricao do Produto
								""							,; //[17] Unidade de Medida do Produto
								""							,; //[18] Observacao
								CTOD("")					,; //[19] Dt Pagamento
								""							,; //[20] Setor
								""							}) //[21] Forma Pagto
								
								
			Next

			If Len(_aProd) > 0 
				Self:ConsultProduct ( @_aProd )
				Self:AdditionalInfor( @_aProd ) 
			EndIf
			
			// carrega array do cabecalho da nota
			aadd(_aNFe,{"F1_FILIAL" ,_aProd[1][10]			,Nil,Nil})
			aadd(_aNFe,{"F1_TIPO"   ,"N"					,Nil,Nil})
			aadd(_aNFe,{"F1_FORMUL" ,"N"					,Nil,Nil})
			aadd(_aNFe,{"F1_DOC"    ,_aProd[1][12]			,Nil,Nil})
			aadd(_aNFe,{"F1_SERIE"  ,_aProd[1][13]			,Nil,Nil})
			aadd(_aNFe,{"F1_EMISSAO",_aProd[1][14]			,Nil,Nil})
			aadd(_aNFe,{"F1_FORNECE",_aProd[1][08]			,Nil,Nil})
			aadd(_aNFe,{"F1_LOJA"   ,_aProd[1][09]			,Nil,Nil})
			aadd(_aNFe,{"F1_ESPECIE","SPED"					,Nil,Nil})
			aadd(_aNFe,{"F1_EST"	,SA2->A2_EST			,Nil,Nil})
			aadd(_aNFe,{"F1_COND"   ,"001"					,Nil,Nil}) 
		   	aadd(_aNFe,{"F1_XFORNEC",_aProd[1][15]			,Nil,Nil}) 
		   	aadd(_aNFe,{"F1_XUSER"	,::_cUser				,Nil,Nil}) 
		   	aadd(_aNFe,{"F1_XDTPAG" ,_aProd[1][19]	  		,Nil,Nil}) 
		   	aadd(_aNFe,{"F1_XSETOR" ,_aProd[1][20]  		,Nil,Nil})
		   	aadd(_aNFe,{"F1_XFPAG"  ,_aProd[1][21] 			,Nil,Nil}) 
		   	aadd(_aNFe,{"F1_XOP" 	,"XXXXXX"		   		,Nil,Nil})
		   	aadd(_aNFe,{"F1_XOBSOP" ,"XXXXXXXXXXXXXXXXXX"	,Nil,Nil})
			aadd(_aNFe,{"F1_XCCPRO" ,""			   			,Nil,Nil})
			aadd(_aNFe,{"F1_XNATURE",""			   			,Nil,Nil})
			aadd(_aNFe,{"F1_CHVNFE" ,::_cChave			   	,Nil,Nil})
			
			For nI := 1 To Len( _aProd )
							 
				aLinha := {} 
				 aadd(aLinha,{"D1_FILIAL"   ,::cBranch				, Nil, Nil})
			     aadd(aLinha,{"D1_ITEM"		, _aProd[nI][06]		, Nil, Nil})
			     aadd(aLinha,{"D1_COD"		, _aProd[nI][11]		, Nil, Nil}) 
			     aadd(aLinha,{"D1_QUANT"	, _aProd[nI][03]		, Nil, Nil}) 
			     aadd(aLinha,{"D1_VUNIT"	, _aProd[nI][04]		, Nil, Nil}) 
			     aadd(aLinha,{"D1_TOTAL"	, _aProd[nI][05]		, Nil, Nil}) 
			     aadd(aLinha,{"D1_CC"		, ""					, Nil, Nil})
			     aadd(aLinha,{"D1_XDESCCC"	, ""					, Nil, Nil})
			     aadd(aLinha,{"D1_LOTECTL"	, ""					, Nil, Nil})
			     aadd(aLinha,{"D1_NUMLOTE"	, ""					, Nil, Nil}) 
			     aadd(aLinha,{"D1_SERVIC"	, ""					, Nil, Nil})
			     aadd(aLinha,{"D1_VALDESC"	, 0						, Nil, Nil}) 
			      
			     aadd(_aItens,aLinha)
						
			Next
	
			If Len(_aItens) > 0
						
				DbSelectArea("SB1")
				DbSelectArea("SA2")
				DbSelectArea("SA5")
				DbSelectArea("SF1")
				
				SB1->(dbSetOrder(1))
				SA2->(dbSetOrder(1))
				SA5->(dbSetOrder(1))
				SF1->(dbSetOrder(1))
				
				MATA140(_aNFe,_aItens,3,.F.,1)
				
				If 	(;
							  SF1->F1_FILIAL 	== _aProd[1][10]	;
						.And. SF1->F1_DOC 		== _aProd[1][12]	;
						.And. SF1->F1_SERIE 	== _aProd[1][13]	;
						.And. SF1->F1_FORNECE	== _aProd[1][08]	;
						.And. SF1->F1_LOJA		== _aProd[1][09]	;
					)
					
					Reclock("SF1",.F.)
					
						SF1->F1_XFORNEC := _aProd[1][15] 
					   	SF1->F1_XUSER 	:= ::_cUser		 
					   	SF1->F1_XDTPAG 	:= _aProd[1][19]	 
					   	SF1->F1_XSETOR 	:= _aProd[1][20]
					   	SF1->F1_XFPAG 	:= _aProd[1][21] 	 
					   	SF1->F1_XOP   	:= "XXXXXX"		
					   	SF1->F1_XOBSOP 	:= "XXXXXXXXXXXXXXXXXX"	
						SF1->F1_XCCPRO 	:= ""			   		
						SF1->F1_XNATURE := ""			   		
						SF1->F1_CHVNFE 	:= ::_cChave
					
					SF1->( MsUnLock() )			   	
				EndIf
				
				SB1->( dbCloseArea() )
				SA2->( dbCloseArea() )
				SA5->( dbCloseArea() )
				SF1->( dbCloseArea() )
			
			EndIf
			
		Endif	
	EndIf
	
Return
/*/{Protheus.doc} Metodo para apresentacao das informacoes para o usuario
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method Informative(cMsg,nTipo) Class NFeImport

	If Valtype( ::_oDlg ) == "O"
		
		Do Case
			Case nTipo == 1 //Alert
				MsgAlert(cMsg)
			Case nTipo == 2 //Info
				MsgInfo(cMsg)
			
		End Case
	Else
		
		Conout(cMsg)
		
	EndIf	
	
Return
/*/{Protheus.doc} Metodo para controlar a barra de progresso
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method UpdateProgressBar(nVlr) Class NFeImport
	
	If Valtype( ::oMeter ) <> Nil

		::oMeter:SetTotal(100)
	
		If nVlr <> 0 
		
			nCurrent := Eval(::oMeter:bSetGet)
			
			::oMeter:Set(nCurrent+nVlr)
			
			Sleep( 500 ) //Apenas para ver a barra andando
		Else
			::oMeter:Set(0)
		EndIf
	EndIf	
	
Return
/*/{Protheus.doc} Metodo para montar a tela de dados adicionais da NFe
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method AdditionalInfor( aProd ) Class NFeImport
	
	Local _cNF		:= aProd[01][12] + ' - ' + aProd[01][13]
	Local _cFornece := aProd[01][08] + ' - ' + aProd[01][09]
	Local _dEmissao := aProd[01][14]
	Local _cRSocial := aProd[01][15]
	Local _cObs		:= Space(200)
	Local _dDtPagto := CTOD("//")
	Local _cSetor	:= ""
	Local _aSetor   := {"","1=Obra","2=Comercial","3=Administrativo","4=RH","5=Projetos","6=Escritorios","7=Manutencao","8=Juridico"}
	Local _cFPagto	:= ""
	Local _aFPagto  := {"","1=Boleto","2=Ted/Doc","3=Transferencia","4=Debito em Conta","5=Cheque"}
	Local oDlgPesq	:= ::oDlgPesq
	Local bOk		:= {|| Processa( {|| IIF(Self:ValidAdditionalInfor( @aProd, {_cObs,_dDtPagto,_cSetor,_cFPagto} ),oDlgPesq:End(),) } ,"Carregando...")  }
	Local bCancel	:= {|| Alert("Opção não disponível")  }
	Local _nLinW 	:= SuperGetMv( "CT_ENCH12" , .F. , 0 ,  ) 

	Private cCadastro := 'Vincular Produtos com Cadastro'		

	DEFINE DIALOG oDlgPesq TITLE cCadastro FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	
	oDlgPesq:lEscClose := .F.
    	
	DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD
	
	@ _nLinW+005, 004 SAY 		oSay3 PROMPT "Série - Nota Fiscal :" 		SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold 
	
	@ _nLinW+003, 065 MSGET 	oNum VAR _cNF   							SIZE 070, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .F.
	
	@ _nLinW+019, 004 SAY 		oSay3 PROMPT "Fornecedor - Loja  :" 		SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold
	
	@ _nLinW+017, 065 MSGET 	oNum VAR _cFornece   						SIZE 070, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .F.

	@ _nLinW+005, 140 SAY 		oSay3 PROMPT "Emissão            :" 		SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold
	
	@ _nLinW+003, 190 MSGET 	oNum VAR _dEmissao   						SIZE 070, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .F. Valid (_dEmissao >= Date())
	
	@ _nLinW+019, 140 SAY 		oSay3 PROMPT "Razão Social    :" 			SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold
	
	@ _nLinW+017, 190 MSGET 	oNum VAR _cRSocial   						SIZE 150, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .F.

		    
	Self:GridAdditionalInfor()
	
	//Alimenta o aCols com os dados enviados
	::oGetPesq:aCols := Self:SetGridAdditionalInfor( @aProd )
	 	    
	//Atualiza o objeto
	::oGetPesq:Refresh()
	
	@ _nLinW+185, 004 SAY 		oSay3 PROMPT "Observação :" 				SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold 
	
	@ _nLinW+183, 065 MSGET 	oNum VAR _cObs   							SIZE 350, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .T.

	@ _nLinW+199, 004 SAY 		oSay3 PROMPT "Setor:" 						SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold 
	
	@ _nLinW+197, 065 MSCOMBOBOX oCbC2 VAR _cSetor  ITEMS _aSetor			SIZE 050, 007							OF oDlgPesq PIXEL  WHEN .T.
	
	
	
	@ _nLinW+199, 140 SAY 		oSay3 PROMPT "Forma Pagto:" 				SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold
	
	@ _nLinW+197, 190 MSCOMBOBOX oCbC2 VAR _cFPagto  ITEMS _aFPagto			SIZE 050, 007							OF oDlgPesq PIXEL  WHEN .T.
	
	@ _nLinW+199, 276 SAY 		oSay3 PROMPT "Dt Pagto:" 					SIZE 055, 007 COLORS 0, 16777215 PIXEL	OF oDlgPesq FONT oBold
	
	@ _nLinW+197, 315 MSGET 	oNum VAR _dDtPagto   						SIZE 055, 010 COLORS 0, 16777215 PIXEL	OF oDlgPesq WHEN .T.
	
	 	 
	ACTIVATE MSDIALOG oDlgPesq ON INIT EnchoiceBar(oDlgPesq,bOk,bCancel,,{}) CENTERED

Return
/*/{Protheus.doc} Metodo para montar o grid de apresentacao dos produtos do xml
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method GridAdditionalInfor() Class NFeImport

	Local nX			:= 0
	Local aCpoGDa       := {	"B1_COD"		,; 
								"B1_DESC"		,;
								"C1_PRODUTO"	,;
								"C1_DESCRI"	,;
								"D1_TES"		;	
							}

	Local aAlter       	:= { "C1_PRODUTO"	,;
							 "D1_TES"	}					// Vetor com os campos que poderao ser alterados
	Local nOpc         	:= 1					// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
	Local cLinhaOk     	:= "AllwaysTrue"    	// Funcao executada para validar o contexto da linha atual do aCols
	Local cTudoOk      	:= "AllwaysTrue"    	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos     	:= ""               	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
                                           			// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                          			// segundo campo>+..."                                                               
	Local nFreeze      	:= 000              	// Campos estaticos na GetDados.
	Local nMax         	:= 000              	// Numero maximo de linhas permitidas. Valor padrao 99
	Local cCampoOk     	:= "AllwaysTrue"    	// Funcao executada na validacao do campo
	Local cSuperApagar 	:= ""               	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cApagaOk     	:= "AllwaysTrue"    	// Funcao executada para validar a exclusao de uma linha do aCols
	Local oWnd          := ::oDlgPesq			// Objeto no qual a MsNewGetDados sera criada
	Local aHead        	:= {}               	// Array a ser tratado internamente na MsNewGetDados como aHeader
	Local aCol         	:= {}               	// Array a ser tratado internamente na MsNewGetDados como aCols
	Local _nLinW 		:= SuperGetMv( "CT_ENCH12" , .F. , 0 ,  ) 
	Local _nSuperior	:= 035+_nLinW
	Local _nEsquerda	:= 004
	Local _nInferior	:= 200
	Local _nDireita		:= 450
                                                                                                                             
	// Carrega aHead                                                                                                                
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHead,{ AllTrim(X3Titulo())	,;
						SX3->X3_CAMPO	,;
						SX3->X3_PICTURE	,;
						SX3->X3_TAMANHO	,;
						SX3->X3_DECIMAL	,;
						""				,;
						SX3->X3_USADO	,;
						SX3->X3_TIPO	,;
						SX3->X3_F3 		,;
						SX3->X3_CONTEXT	,;
						SX3->X3_CBOX	,;
						""				,;
						SX3->X3_WHEN	,;
						SX3->X3_TRIGGER	})
				
		Endif
	Next nX
	
	
	
	aHead[01][01] := "Produto do XML"
	aHead[02][01] := "Descrição do XML"
	aHead[02][04] := 40
	aHead[03][01] := "Produto do Sistema"
	aHead[04][01] := "Descrição do Sistema"
	aHead[04][04] := 40

	SX3->(DbCloseArea())
	
	// Carregue aqui a Montagem da sua aCol                                                                                         
	aAux := {}

	For nX := 1 to Len(aCpoGDa)
		aadd(aAux,CriaVar(aHead[nX,2]))
	Next nX

	Aadd(aAux,.F.)
	Aadd(aCol,aAux)

	::oGetPesq := MsNewGetDados():New(_nSuperior,_nEsquerda,_nInferior,_nDireita, GD_UPDATE , cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax, cCampoOk, cSuperApagar, cApagaOk, oWnd, aHead, aCol)
	
Return
/*/{Protheus.doc} Metodo para adicionar os produtos do xml no grid da tela
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method SetGridAdditionalInfor( aProd ) Class NFeImport

	Local _cDesc := ""
	Local _cTe   := "" 
	Local aDados := {}

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If Len( aProd ) > 0 

		For nI := 1  To Len( aProd )
			
			_cDesc := Space( TamSx3("B1_COD")[1] )
			_cTe   := Space( TamSx3("B1_TE")[1] )
			
			If !Empty(aProd[nI][11])
				If SB1->(DbSeek(xFilial("SB1")+aProd[nI][11]))
					_cDesc := SB1->B1_DESC
					_cTe   := SB1->B1_TE
				EndIf
			EndIf
			
			aAdd( aDados, { 	aProd[nI][01]	,;
								aProd[nI][16]	,;
								Iif(Empty(aProd[nI][11]),Space( TamSx3("B1_COD")[1] ),aProd[nI][11])	,;
								_cDesc			,;
								_cTe			,;
								.F. 			})
			
		Next
	Else
		aAdd( aDados, { "","","","","",.F. })		
	EndIf

Return aDados
/*/{Protheus.doc} Metodo para atualizacao do array de controle e tabela sa5
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method ValidAdditionalInfor( aProd, aTela ) Class NFeImport

	//Verificar se foi preenchido todos os produtos
	For nI := 1 To Len( ::oGetPesq:aCols )
		
		If Empty( ::oGetPesq:aCols[nI][ GDFieldPos("C1_PRODUTO", ::oGetPesq:aHeader )  ] )
			MsgAlert("Por favor informar o código do produto no sistema para os produtos da NFe")
			Return .F.
		EndIf

	Next
	
	DbSelectArea('SA5')
	SA5->( DbSetOrder(2) )//A5_FILIAL + A5_PRODUTO + A5_FORNECE
	
	//Atualiza a tabela SA5
	For nI := 1 To Len( ::oGetPesq:aCols )
	
		If SA5->( DbSeek(xFilial('SA5') + ::oGetPesq:aCols[nI][ GDFieldPos("C1_PRODUTO"	, ::oGetPesq:aHeader )  ] + aProd[1][08]  ))
			RecLock( 'SA5' , .F. )
		Else
			RecLock( 'SA5' , .T. )
		EndIf
		
			SA5->A5_FILIAL 	:= xFilial('SA5') 
			SA5->A5_FORNECE := aProd[1][08]
			SA5->A5_LOJA    := aProd[1][09]
			SA5->A5_NOMEFOR := aProd[1][15] 
			SA5->A5_PRODUTO := ::oGetPesq:aCols[nI][ GDFieldPos("C1_PRODUTO", ::oGetPesq:aHeader )  ]
			SA5->A5_NOMPROD := ::oGetPesq:aCols[nI][ GDFieldPos("C1_DESCRI"	, ::oGetPesq:aHeader )  ] 
			SA5->A5_CODPRF	:= ::oGetPesq:aCols[nI][ GDFieldPos("B1_COD"	, ::oGetPesq:aHeader )  ] 
			SA5->A5_DESCPRF	:= ::oGetPesq:aCols[nI][ GDFieldPos("B1_DESC"	, ::oGetPesq:aHeader )  ]
			SA5->A5_TESCP  	:= ::oGetPesq:aCols[nI][ GDFieldPos("D1_TES"	, ::oGetPesq:aHeader )  ]
		
		SA5->( MsUnLock() )	
			
	Next  
	
	For nI := 1 To Len( aProd )
	
		aProd[nI][18] := aTela[1]
		aProd[nI][19] := aTela[2]
		aProd[nI][20] := aTela[3]
		aProd[nI][21] := aTela[4]
		
	Next 
	
	Self:ConsultProduct( @aProd ) 
	
Return .T.
/*/{Protheus.doc} Metodo para selecionar a filial de lancamento -- Nao implementado
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method SelectBranch() Class NFeImport
             
	Local _oDlg4 
	               
	DEFINE MSDIALOG _oDlg4 TITLE "Filial" FROM 000,000 TO 095,175 PIXEL
		 
	 @ 002,010 Say OemToAnsi( 'Filial:' )        							 OF _oDlg4 Pixel
	 @ 008,010 MsGet oEdit2 Var ::cBranch Size 070,009 COLOR CLR_BLACK PIXEL OF _oDlg4 F3 "SM0"
	 
	 @ 025,010 Button "&Confirma" Size 30,12 PIXEL OF _oDlg4 Action ( _lRet := .T.,	_oDlg4:End() ) 
	 @ 025,050 Button "&Cancelar" Size 30,12 PIXEL OF _oDlg4 Action ( _lRet := .F., _oDlg4:End() )
	
	ACTIVATE MSDIALOG _oDlg4 CENTERED  

Return 
/*/{Protheus.doc} Metodo para consultar a vinculação do produto x fornecedor
@Return		Nil
@Author		Ruann Carlos
@Version	Protheus 12.1.7
@Since		04/11/2016
@Obs		04/11/2016 - Ruann Carlos - Criação do Programa fonte em sua versão inicial
/*/
Method ConsultProduct( aProd ) Class NFeImport

	Local _cSql   := ""
	Local _cAlias := GetNextAlias()
		
	For nI := 1 To Len( aProd )

		_cSql   := "	SELECT				"
		_cSql   += "		DISTINCT A5_PRODUTO	" //Apenas uma ocorrência
		_cSql   += "		,	A5_NOMPROD	"
		_cSql   += "	FROM				"
		_cSql   += 			RetSqlName('SA5') + " SA5 	"
		_cSql   += "	WHERE							"
		_cSql   += "			SA5.D_E_L_E_T_ = ''		"
		_cSql   += "		AND SA5.A5_FORNECE = '" + aProd[nI][08] + "'		"
		_cSql   += "		AND SA5.A5_CODPRF  = '" + aProd[nI][01] + "'		"
	
		TCQUERY _cSql NEW ALIAS (_cAlias)
		
		If (_cAlias)->(!EOF())
			aProd[nI][11] := (_cAlias)->A5_PRODUTO
			aProd[nI][17] := Posicione("SB1",1,xFilial("SB1")+(_cAlias)->A5_PRODUTO,"B1_UM") 
		EndIf
		
		(_cAlias)->(DbCloseArea())
		
	Next
	
Return
