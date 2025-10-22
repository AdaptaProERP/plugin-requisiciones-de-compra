// Programa   : REQSERCONT
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Requisiciones de Servicios para Contratistas
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cTipDoc) // cCodSuc,cRif,cCenCos,cCodCaj)
   LOCAL cNombre:="",cSql,I,nGroup,aLine:={}
   LOCAL oFont,oFontB,oCursor,oBtn,oBar,oBmp,oCol
   LOCAL oBtn,nGroup,bAction,aBtn:={}
   LOCAL oData     :=DATACONFIG("REQSERPERIODO","ALL")
   LOCAL dDesde    :=oDp:dFchInicio // FCHINIMES(oDp:dFecha)
   LOCAL dHasta    :=oDp:dFchCierre // FCHFINMES(oDp:dFecha)
   LOCAL aPeriodos :=ACLONE(oDp:aPeriodos)
   LOCAL cFileMem  :="USER\ADDON_REQSER.MEM",V_nPeriodo:=10,nPeriodo,aFechas:={},aTotal:={}
   LOCAL V_dDesde  :=CTOD("")
   LOCAL V_dHasta  :=CTOD("")
   LOCAL oDb       :=OpenOdbc(oDp:cDsnData)
   LOCAL aData     :={} 
   LOCAL aDataFis  :={} 
   LOCAL dFecha    :=oDp:dFecha,cServer,cWhere
   LOCAL aTotal    :=ATOTALES(aData)
   LOCAL cCodSucCbt:=""
   LOCAL nBalance  :=0
   LOCAL aLine     :={}
   LOCAL aDataP    :={} // Datos de los ultimos proveedores
   LOCAL cTipPro   :=NIL
   LOCAL cCodSuc   :=oDp:cSucursal
   LOCAL aTipDoc   :=ATABLE("SELECT TDC_TIPO FROM DPTIPDOCPRO WHERE TDC_ACTIVO=1 AND TDC_ORGRES=1 AND TDC_TRIBUT=0")
   LOCAL cWhereReq :=""

   DEFAULT oDp:lAplNomina:=.F. 

   IF Empty(aTipDoc)
      MsgMemo("Es Necesario Definir los tipos documentos del Proveedor "+CRLF+"se Originan desde Requisiciones de Servicios")
      DPLBX("DPTIPDOCPROREQCOM.LBX")
      RETURN .F.
   ENDIF

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:=aTipDoc[1]

   EJECUTAR("DPEMPGETRIF")

   IF Empty(oDp:cRif)
      EJECUTAR("DPCONFIG")
      RETURN {}
   ENDIF

   IF Empty(oDp:cRif)
      oDp:cRif:=ALLTRIM(SQLGET("DPEMPRESA","EMP_RIF","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod)))
   ENDIF

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=oDp:nEjercicio,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

   IF !Empty(aFechas)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

   oData:End(.F.)

   cWhere:=NIL

   nBalance :=100 
   aData    :=LEERREQS(HACERWHEREFIS(dDesde,dHasta,cWhere),NIL,cServer)
   aLine    :=ACLONE(aData[1])
   aDataFis :={}
   cWhereReq:=oDp:cWhere

   AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})
   AADD(aDataFis,aLine)

   aTotal  :=ATOTALES(aDataFis)

   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-11 
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-11

   DpMdi("Menú: Creación de documento para Contratistas de Servicios ","oRSOCONT","")

   oRSOCONT:cCodigo   :=cCodigo
   oRSOCONT:cCodSuc   :=cCodSuc
   oRSOCONT:cNombre   :=cNombre
   oRSOCONT:cWherePro :=" 1=1"
   oRSOCONT:cWhereReq :=cWhereReq
   oRSOCONT:cServer   :=cServer

   oRSOCONT:lSalir    :=.F.
   oRSOCONT:nHeightD  :=45
   oRSOCONT:lMsgBar   :=.F.
   oRSOCONT:oGrp      :=NIL
   oRSOCONT:lEnvAut   :=.F. // SQLGET("DPEMPRESA","EMP_ENVAUT","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
   oRSOCONT:dDesde    :=dDesde
   oRSOCONT:dHasta    :=dHasta
   oRSOCONT:cPeriodo  :=aPeriodos[nPeriodo]
   oRSOCONT:lWhen     :=.T.
   oRSOCONT:cRif      :=ALLTRIM(cRif)
   oRSOCONT:cFileZip  :=""
   oRSOCONT:cServer   :=""
   oRSOCONT:nPeriodo  :=nPeriodo
   oRSOCONT:cWhereQry :=NIL
   oRSOCONT:aDataFis  :=aDataFis
   oRSOCONT:aData     :=aData
   oRSOCONT:cWhere    :=""
   oRSOCONT:cWhere_   :=""
   oRSOCONT:dCbtDesde :=SQLGET("DPCBTE","MIN(CBT_FECHA),MAX(CBT_FECHA)","CBT_CODSUC"+GetWhere("=",cCodSuc))
   oRSOCONT:dCbtHasta :=DPSQLROW(2)
   oRSOCONT:nSucursal :=COUNT("DPSUCURSAL","SUC_ACTIVO=1")
   oRSOCONT:nBalance  :=nBalance
   oRSOCONT:lBuscarProv:=.F.
   oRSOCONT:oOut       :=NIL
   oRSOCONT:cFileZip   :=""
   oRSOCONT:cCodigo    :=SPACE(10)
   oRSOCONT:aTipDoc    :=aTipDoc // {"SCO","ORC","OCA","FAC"}
   oRSOCONT:cTipDoc    :=IF(!Empty(cTipDoc),cTipDoc,aTipDoc[1])
   oRSOCONT:cFileLbx   :=EJECUTAR("LBXTIPPROVEEDOR",cTipPro,.F.)
   oRSOCONT:cWherePro  :=IF(!Empty(cTipPro),"PRO_TIPO"+GetWhere("=",cTipPro)+" AND ","")+"LEFT(PRO_SITUAC,1)='A' AND LEFT(PRO_TIPO,1)<>'R' " // Excluuye receptores de IVA
   oRSOCONT:cFileLbxTip:="TDC_ACTIVO=1 AND TDC_ORGRES=1"
   oRSOCONT:cNumero    :=SPACE(20)
   oRSOCONT:cNumFis    :=SPACE(20)
   oRSOCONT:cCenCos    :=oDp:cCenCos
   oRSOCONT:AGROUP     :=NIL
   oRSOCONT:cCodCaj    :=NIL
   oRSOCONT:lEditNumero:=.F.
   oRSOCONT:nCxP       :=0
   oRSOCONT:dFecha     :=oDp:dFecha
   oRSOCONT:nValCam    :=EJECUTAR("DPGETVALCAM",oDp:cMonedaExt,oDp:dFecha) // nValCam
   oRSOCONT:dFchDec    :=CTOD("")

   oRSOCONT:nClrTex1 :=CLR_HBLUE
   oRSOCONT:nClrTex0 :=0

   oRSOCONT:nAltoBrw  :=160-30 // 100+100+08
   oRSOCONT:nAnchoSpl1:=120+50-220

   SetScript("REQSERCONT")

   AADD(aBtn,{oDp:DPCENCOS                    ,"CENTRODECOSTO.BMP"          ,"CENCOS"}) 
   AADD(aBtn,{oDp:DPDPTO                      ,"DEPARTAMENTOS.BMP"          ,"DPTO"  }) 

   AADD(aBtn,{"Requisiciones de Productos"    ,"PRODUCTO.BMP"               ,"REQINV"   }) 
   AADD(aBtn,{"Requisiciones de Servicios"    ,"prestadoresdeservicios.bmp" ,"REQSER"   }) 


   oRSOCONT:Windows(0,0,oDp:aCoors[3]-(oDp:oBar:nHeight()+120),oDp:aCoors[4]-10,.T.)  

   AADD(aDataP,{"","",0,"",CTOD(""),"","",""})

   oRSOCONT:oBrwP:=TXBrowse():New(oRSOCONT:oWnd)
   oRSOCONT:oBrwP:SetArray( aDataP, .F. )
   oRSOCONT:oBrwP:nHeaderLines:= 2

   oCol:=oRSOCONT:oBrwP:aCols[1]   
   oCol:cHeader      :="Código"+CRLF+"Proveedor"
   oCol:nWidth       :=80-10

   oCol:=oRSOCONT:oBrwP:aCols[2]   
   oCol:cHeader      :="Nombre del"+CRLF+"Proveedor"
   oCol:nWidth       :=120

   oCol:=oRSOCONT:oBrwP:aCols[3]   
   oCol:cHeader      :="Precio"+CRLF+"USD"
   oCol:nWidth       :=80
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrwP:aArrayData[oRSOCONT:oBrwP:nArrayAt,3],;
                                     oCol  := oRSOCONT:oBrwP:aCols[3],;
                                     FDP(nMonto,oCol:cEditPicture)}


   oCol:=oRSOCONT:oBrwP:aCols[4]   
   oCol:cHeader      :="Descripción"
   oCol:nWidth       :=180

   oCol:=oRSOCONT:oBrwP:aCols[5]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=70

   oCol:=oRSOCONT:oBrwP:aCols[6]   
   oCol:cHeader      :="Tipo"+CRLF+"Doc."
   oCol:nWidth       :=40

   oCol:=oRSOCONT:oBrwP:aCols[7]   
   oCol:cHeader      :="#"+CRLF+"Documento"
   oCol:nWidth       :=90

   oCol:=oRSOCONT:oBrwP:aCols[8]   
   oCol:cHeader      :="Origen"
   oCol:nWidth       :=40

   oRSOCONT:oBrwP:bClrStd   := {|oBrw,nClrText,aData|oBrw:=oRSOCONT:oBrwP,;
                                 aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                 nClrText:=0,;
                                {nClrText,iif( oBrw:nArrayAt%2=0, 16774120, 16769217) } }


   oRSOCONT:oBrwP:bClrHeader := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRSOCONT:oBrwP:bClrFooter := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRSOCONT:oBrwP:CreateFromCode()

   oRSOCONT:oBrwP:bLDblClick:={|oBrw|oRSOCONT:VERDOCPRO() }


   oRSOCONT:oBrwP:Move(0,0,.T.)
   oRSOCONT:oBrwP:SetSize(200+oRSOCONT:nAnchoSpl1,355)


   oRSOCONT:oBrw2:=TXBrowse():New(oRSOCONT:oWnd)
   oRSOCONT:oBrw2:SetArray( aData, .F. )

   oRSOCONT:oBrw2:oFont       := oFont
   oRSOCONT:oBrw2:lHScroll    := .T.
   oRSOCONT:oBrw2:nHeaderLines:= 2
   oRSOCONT:oBrw2:nDataLines  := 1
   oRSOCONT:oBrw2:lFooter     :=.T.


   oCol:=oRSOCONT:oBrw2:aCols[1]   
   oCol:cHeader      :="Número"+CRLF+"Req."
   oCol:nWidth       :=80-10
   oCol:cFooter      :=LSTR(LEN(aData))


   oCol:=oRSOCONT:oBrw2:aCols[2]   
   oCol:cHeader      :="Fecha"+CRLF+"Requerida"
   oCol:nWidth       :=70-5

   oCol:=oRSOCONT:oBrw2:aCols[3]   
   oCol:cHeader      :="Cuenta"+CRLF+"Contable"
   oCol:nWidth       :=80

   oCol:=oRSOCONT:oBrw2:aCols[4]   
   oCol:cHeader      :="Nombre "+CRLF+"de la Cuenta"
   oCol:nWidth       :=160

   oCol:=oRSOCONT:oBrw2:aCols[5]   
   oCol:cHeader      :="Descripción"+CRLF+"Requisición"
   oCol:nWidth       :=180

   oCol:=oRSOCONT:oBrw2:aCols[6]   
   oCol:cHeader      :="Unidad"+CRLF+"Medida"
   oCol:nWidth       :=45

   oCol:=oRSOCONT:oBrw2:aCols[7]   
   oCol:cHeader      :="Cantidad"+CRLF+"Requerida"
   oCol:nWidth       :=60
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,7],;
                                     oCol  := oRSOCONT:oBrw2:aCols[7],;
                                     FDP(nMonto,oCol:cEditPicture)}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oRSOCONT:PUTFIELDVALUE(oCol,uValue,7,nKey,NIL,.T.)}


   oCol:=oRSOCONT:oBrw2:aCols[8]   
   oCol:cHeader      :="Precio"+CRLF+"en USD"
   oCol:nWidth       :=80
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,8],;
                                     oCol  := oRSOCONT:oBrw2:aCols[8],;
                                     FDP(nMonto,oCol:cEditPicture)}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oRSOCONT:PUTFIELDVALUE(oCol,uValue,8,nKey,NIL,.T.)}


   oCol:=oRSOCONT:oBrw2:aCols[9]   
   oCol:cHeader      :="Total"+CRLF+"en USD"
   oCol:nWidth       :=80
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,9],;
                                     oCol  := oRSOCONT:oBrw2:aCols[9],;
                                     FDP(nMonto,oCol:cEditPicture)}

   oCol:=oRSOCONT:oBrw2:aCols[10]   
   oCol:cHeader      :="#"+CRLF+"Item"
   oCol:nWidth       :=40


   oCol:=oRSOCONT:oBrw2:aCols[11]   
   oCol:cHeader      :="Centro"+CRLF+"Costo"
   oCol:nWidth       :=50

   oCol:=oRSOCONT:oBrw2:aCols[12]   
   oCol:cHeader      :="Nombre"+CRLF+"Centro de Costo"
   oCol:nWidth       :=120

   oCol:=oRSOCONT:oBrw2:aCols[13]   
   oCol:cHeader      :="Código"+CRLF+"Proyecto"
   oCol:nWidth       :=60

   oCol:=oRSOCONT:oBrw2:aCols[14]   
   oCol:cHeader      :="Nombre"+CRLF+"Proyecto"
   oCol:nWidth       :=120





   oRSOCONT:oBrw2:bClrStd               := {|oBrw,nClrText,aLine|oBrw:=oRSOCONT:oBrw2,aLine:=oBrw:aArrayData[oBrw:nArrayAt],;
                                            nClrText:=IF(aLine[9]>0,oRSOCONT:nClrTex1,oRSOCONT:nClrTex0),;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, 16774120, 16769217) } }


   oRSOCONT:oBrw2:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRSOCONT:oBrw2:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRSOCONT:oBrw2:bLDblClick:={|oBrw|oRSOCONT:RUNCLICK() }

   oRSOCONT:oBrw2:bChange:={||oRSOCONT:BRWCHANGE2()}


   oRSOCONT:oBrw2:CreateFromCode()
   oRSOCONT:oBrw2:Move(0,205+oRSOCONT:nAnchoSpl1,.T.)
   oRSOCONT:oBrw2:SetSize(300,200+oRSOCONT:nAltoBrw)

   oRSOCONT:oBrw:=TXBrowse():New(oRSOCONT:oWnd)
   oRSOCONT:oBrw:SetArray( aDataFis, .F. )

   oRSOCONT:dFchIni  :=CTOD("")
   oRSOCONT:dFchFin  :=CTOD("")

   oRSOCONT:oBrw:SetFont(oFont)

   oRSOCONT:oBrw:lFooter     := .T.
   oRSOCONT:oBrw:lHScroll    := .T.
   oRSOCONT:oBrw:nHeaderLines:= 2
   oRSOCONT:oBrw:nDataLines  := 1
   oRSOCONT:oBrw:nFooterLines:= 1

   oRSOCONT:aData            :=ACLONE(aData)
   oRSOCONT:nClrText :=0
   oRSOCONT:nClrPane1:=16774120
   oRSOCONT:nClrPane2:=16771797

   AEVAL(oRSOCONT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oRSOCONT:oBrw:aCols[1]   
   oCol:cHeader      :="Número"+CRLF+"Req."
   oCol:nWidth       :=80-10
   oCol:cFooter      :=FDP(0,"99")


   oCol:=oRSOCONT:oBrw:aCols[2]   
   oCol:cHeader      :="Fecha"+CRLF+"Requerida"
   oCol:nWidth       :=70-5

   oCol:=oRSOCONT:oBrw:aCols[3]   
   oCol:cHeader      :="Cuenta"+CRLF+"Contable"
   oCol:nWidth       :=80

   oCol:=oRSOCONT:oBrw:aCols[4]   
   oCol:cHeader      :="Nombre "+CRLF+"de la Cuenta"
   oCol:nWidth       :=160

   oCol:=oRSOCONT:oBrw:aCols[5]   
   oCol:cHeader      :="Descripción"+CRLF+"Requisición"
   oCol:nWidth       :=180

   oCol:=oRSOCONT:oBrw:aCols[6]   
   oCol:cHeader      :="Unidad"+CRLF+"Medida"
   oCol:nWidth       :=45

   oCol:=oRSOCONT:oBrw:aCols[7]   
   oCol:cHeader      :="Cantidad"+CRLF+"Requerida"
   oCol:nWidth       :=60
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw:aArrayData[oRSOCONT:oBrw:nArrayAt,7],;
                                     oCol  := oRSOCONT:oBrw:aCols[7],;
                                     FDP(nMonto,oCol:cEditPicture)}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oRSOCONT:PUTFIELDVALUE(oCol,uValue,7,nKey,NIL,.T.)}
   oCol:cFooter      :=FDP(0,"99.99")


   oCol:=oRSOCONT:oBrw:aCols[8]   
   oCol:cHeader      :="Precio"+CRLF+"en USD"
   oCol:nWidth       :=90
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw:aArrayData[oRSOCONT:oBrw:nArrayAt,8],;
                                     oCol  := oRSOCONT:oBrw:aCols[8],;
                                     FDP(nMonto,oCol:cEditPicture)}
   oCol:nEditType    :=1
   oCol:bOnPostEdit  :={|oCol,uValue,nKey|oRSOCONT:PUTFIELDVALUE(oCol,uValue,8,nKey,NIL,.T.)}
 


   oCol:=oRSOCONT:oBrw:aCols[9]   
   oCol:cHeader      :="Total"+CRLF+"en USD"
   oCol:nWidth       :=90
   oCol:cEditPicture :='9,999,999,999,999.99'
   oCol:bStrData     :={|nMonto,oCol|nMonto:= oRSOCONT:oBrw:aArrayData[oRSOCONT:oBrw:nArrayAt,9],;
                                     oCol  := oRSOCONT:oBrw:aCols[9],;
                                     FDP(nMonto,oCol:cEditPicture)}
   oCol:cFooter      :=FDP(0,"99.99")

   oCol:=oRSOCONT:oBrw:aCols[10]   
   oCol:cHeader      :="#"+CRLF+"Item"
   oCol:nWidth       :=40

   oCol:=oRSOCONT:oBrw:aCols[11]   
   oCol:cHeader      :="Centro"+CRLF+"Costo"
   oCol:nWidth       :=50

   oCol:=oRSOCONT:oBrw:aCols[12]   
   oCol:cHeader      :="Nombre"+CRLF+"Centro de Costo"
   oCol:nWidth       :=120

   oCol:=oRSOCONT:oBrw:aCols[13]   
   oCol:cHeader      :="Código"+CRLF+"Proyecto"
   oCol:nWidth       :=60

   oCol:=oRSOCONT:oBrw:aCols[14]   
   oCol:cHeader      :="Nombre"+CRLF+"Proyecto"
   oCol:nWidth       :=120




   oRSOCONT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRSOCONT:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oRSOCONT:nClrPane1, oRSOCONT:nClrPane2 ) } }


   oRSOCONT:oBrw:bClrFooter     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRSOCONT:oBrw:bClrHeader     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRSOCONT:oBrw:bLDblClick:={|oBrw| oRSOCONT:RUNCLICK3() }

   oRSOCONT:oBrw:bChange:={||oRSOCONT:BRWCHANGE()}

   oRSOCONT:oBrw:CreateFromCode()


   oRSOCONT:oBrw:CreateFromCode()
   oRSOCONT:oBrw:Move(205+oRSOCONT:nAltoBrw,205+oRSOCONT:nAnchoSpl1,.T.)
   oRSOCONT:oBrw:SetSize(300,150,.T.)

  @ 200+oRSOCONT:nAltoBrw,205+oRSOCONT:nAnchoSpl1 SPLITTER oRSOCONT:oHSplit ;
              HORIZONTAL ;
              PREVIOUS CONTROLS oRSOCONT:oBrw2 ;
              HINDS CONTROLS oRSOCONT:oBrw ;
              TOP MARGIN 80 ;
              BOTTOM MARGIN 80 ;
              SIZE 300, 4  PIXEL ;
              OF oRSOCONT:oWnd ;
             _3DLOOK

  @ 0,200+oRSOCONT:nAnchoSpl1   SPLITTER oRSOCONT:oVSplit ;
            VERTICAL ;
            PREVIOUS CONTROLS oRSOCONT:oBrwP ;
            HINDS CONTROLS oRSOCONT:oBrw2, oRSOCONT:oHSplit, oRSOCONT:oBrw ;
            LEFT MARGIN 80 ;
            RIGHT MARGIN 80 ;
            SIZE 4, 355  PIXEL ;
            OF oRSOCONT:oWnd ;
            _3DLOOK

   oRSOCONT:Activate("oRSOCONT:FRMINIT()") // ,,"oRSOCONT:oSpl:AdjRight()")
 
   EJECUTAR("DPSUBMENUCREAREG",oRSOCONT,NIL,"A")

   IF COUNT("DPCTA")=0
      MsgMemo("Necesario Importar Plan de Cuentas")
      EJECUTAR("DPCTAIMPORT")
   ENDIF

   oRSOCONT:bGotFocus:={|| oRSOCONT:BTNSETFONT() }

   IF SQLGET("DPASIENTOS","SUM(MOC_MONTO)","MOC_ORIGEN='BAL'")<>0
      EJECUTAR("BRBALINIDIV")
   ENDIF

RETURN

FUNCTION BTNSETFONT()
  LOCAL oFont

  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD

  oRSOCONT:oBar:SetFont(oFont)

// oDp:oFrameDp:SetText("AQUI "+TIME())

RETURN .T.

FUNCTION FRMINIT()
  LOCAL oCursor,oBar,oBtn,oFont,oFontI,nCol:=12,nLin:=0,oFontB,oFontF
  LOCAL nLin:=0,nContar:=0,cAction:="",nPorIva:=0
  LOCAL aTipIva:=ACLONE(oDp:aTipIva)

  AEVAL(oDp:aTipIva,{|a,n,nPorIva| nPorIva   :=EJECUTAR("IVACAL",oDp:aTipIva[n],3,oRSOCONT:dDesde),;
                                   aTipIva[n]:={a,nPorIva} })

  ASORT(aTipIva,,, { |x, y| x[2] < y[2] })

  AADD(aTipIva,{"Todos",0})


  DEFINE BUTTONBAR oBar SIZE 44+25,44+20 OF oRSOCONT:oWnd 3D CURSOR oCursor

  oRSOCONT:oBar:=oBar

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -09 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontI NAME "Tahoma" SIZE 0, -10 

// inactivos


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          TOP PROMPT "Grabar"; 
          ACTION oRSOCONT:DOCGRABAR(.F.)

// MENU oRSOCONT:MENU_CNF("MENU_CNFRUN","DOS");
// EJECUTAR("DPCONFIG")

  oBtn:cToolTip:="Grabar Documento"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\BOTONDOWN.BMP";
          TOP PROMPT "Cargar"; 
          ACTION oRSOCONT:DOCGRABAR(.T.)

  oBtn:cToolTip:="Cargar Documentos"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oRSOCONT:oWnd:IsZoomed(),oRSOCONT:oWnd:Restore(),oRSOCONT:oWnd:Maximize())

  oBtn:cToolTip:="Maximizar"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Salir"; 
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRSOCONT:End()

  oBtn:cToolTip:="Cerrar Formulario"

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -11  BOLD

  oBar:SetSize(NIL,70+30,.T.)

  DEFINE FONT oFontF  NAME "Tahoma"   SIZE 0, -11 BOLD

  nLin:=-15 // 45
  nCol:=20
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin+20, nCol COMBOBOX oRSOCONT:oPeriodo  VAR oRSOCONT:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFontF;
                ON CHANGE oRSOCONT:LEEFECHAS();
                WHEN oRSOCONT:lWhen 


  ComboIni(oRSOCONT:oPeriodo )

  @ nLin+20, nCol+103 BUTTON oRSOCONT:oBtn PROMPT " < " SIZE 27,22;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRSOCONT:oPeriodo:nAt,oRSOCONT:oDesde,oRSOCONT:oHasta,-1),;
                         EVAL(oRSOCONT:oBtn:bAction),oRSOCONT:LEEFECHAS());
                 WHEN oRSOCONT:lWhen 


  @ nLin+20, nCol+130 BUTTON oRSOCONT:oBtn PROMPT " > " SIZE 27,22;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRSOCONT:oPeriodo:nAt,oRSOCONT:oDesde,oRSOCONT:oHasta,+1),;
                         EVAL(oRSOCONT:oBtn:bAction),oRSOCONT:LEEFECHAS());
                 WHEN oRSOCONT:lWhen 


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

  @ nLin+20,nCol+170-8 BMPGET oRSOCONT:oDesde  VAR oRSOCONT:dDesde;
                  PICTURE "99/99/9999";
                  PIXEL;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oRSOCONT:oDesde ,oRSOCONT:dDesde);
                  SIZE 76,22;
                  OF   oBar;
                  WHEN oRSOCONT:oPeriodo:nAt=LEN(oRSOCONT:oPeriodo:aItems) .AND. oRSOCONT:lWhen ;
                  FONT oFontF

   oRSOCONT:oDesde:cToolTip:="F6: Calendario"

  @ nLin+20, nCol+252+5 BMPGET oRSOCONT:oHasta  VAR oRSOCONT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRSOCONT:oHasta,oRSOCONT:dHasta);
                SIZE 80,22;
                WHEN oRSOCONT:oPeriodo:nAt=LEN(oRSOCONT:oPeriodo:aItems) .AND. oRSOCONT:lWhen ;
                OF oBar;
                FONT oFontF

   oRSOCONT:oHasta:cToolTip:="F6: Calendario"

   @ nLin+20,nCol+335+15 BUTTON oRSOCONT:oBtn PROMPT " > " SIZE 27,22;
               FONT oFontF;
               OF oBar;
               PIXEL;
               WHEN oRSOCONT:oPeriodo:nAt=LEN(oRSOCONT:oPeriodo:aItems);
               ACTION oRSOCONT:HACERWHERE(oRSOCONT:dDesde,oRSOCONT:dHasta,oRSOCONT:cWhere,.T.);
               WHEN oRSOCONT:lWhen

  oBar:Refresh(.T.)

/*
  IF !Empty(oRSOCONT:dCbtDesde)

      @ nLin+20,nCol+335+15+35 BUTTON oRSOCONT:oBtnCbtDesde PROMPT DTOC(oRSOCONT:dCbtDesde) SIZE 80,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION  EJECUTAR("BRWCOMPROBACION",NIL,oRSOCONT:dCbtDesde,oRSOCONT:dCbtDesde)

        oRSOCONT:oBtnCbtDesde:cToolTip:="Fecha del primer asiento actualizado"+CRLF+"Genera balance de comprobación"

      @ nLin+20,nCol+335+15+35+82 BUTTON oRSOCONT:oBtnCbtHasta PROMPT DTOC(oRSOCONT:dCbtHasta) SIZE 80,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION EJECUTAR("BRDIARIORES",NIL,oRSOCONT:cCodSuc,oDp:nIndefinida,oRSOCONT:dCbtDesde,oRSOCONT:dCbtHasta)

      oRSOCONT:oBtnCbtHasta:cToolTip:="Fecha del ultimo asiento"+CRLF+"Genera diario resumido general"


     @ nLin+20,nCol+335+15+35+162 BUTTON oRSOCONT:oBtnSucursal PROMPT "SUC("+LSTR(oRSOCONT:nSucursal)+")"+oRSOCONT:cCodSuc SIZE 90,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION DPLBX("DPSUCURSAL.LBX")

      oRSOCONT:oBtnSucursal:cToolTip:="Sucursal Activa "+oRSOCONT:cCodSuc+CRLF+"Cantidad de sucursales activas, desactive las innecesarias"




  ELSE


      @ nLin+20,nCol+335+15+35 BUTTON oRSOCONT:oBtnCbtDesde PROMPT "SUC:"+oRSOCONT:cCodSuc+" sin Asientos" SIZE 160,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION DPLBX("DPSUCURSAL.LBX")

  oRSOCONT:oBtnCbtDesde:cToolTip:="Sucursal sin Asientos Contables"


  ENDIF
*/

//  oBar:SetSize(110,NIL,.T.)

  nCol:=20
  nLin:=65

  @ nLin,nCol  CHECKBOX oRSOCONT:oBuscarProv VAR oRSOCONT:lBuscarProv  PROMPT "Auto-Búsqueda";
                  WHEN  .T.;
                  FONT oFontB;
                  SIZE 120,20 OF oBar;
                  ON CHANGE oRSOCONT:BRWCHANGE2() PIXEL

// ? oRSOCONT:oBuscarProv:Classname()
//EJECUTAR("ADDONUPDATE","BuscarProv",oRSOCONT:BuscarProv,"REQSER") PIXEL

  oRSOCONT:oBuscarProv:cMsg    :="Auto-Ejecución cuando se Inicia el Sistema"
  oRSOCONT:oBuscarProv:cToolTip:="Auto-Ejecución cuando se Inicia el Sistema"


  oBtn:=oRSOCONT:oBuscarProv

  nCol:=224+67
  nLin:=30


  @ nLin+0, nCol SAY "Proveedor "    PIXEL;
                 SIZE 80,20;
 	            OF oBar BORDER ;
                 FONT oFontF;
                 COLOR oDp:nClrLabelText,oDp:nClrLabelPane RIGHT

   @ nLin+21, nCol SAY "Tipo. Doc. "    PIXEL;
                   SIZE 80,20;
 	              OF oBar BORDER ;
                   FONT oFontF;
                   COLOR oDp:nClrLabelText,oDp:nClrLabelPane RIGHT

   @ nLin+42, nCol SAY "Número "    PIXEL;
                   SIZE 80,20;
 	              OF oBar BORDER ;
                   FONT oFontF;
                   COLOR oDp:nClrLabelText,oDp:nClrLabelPane RIGHT


  @ nLin+42, nCol+280 SAY "Divisa "+oDp:cMonedaExt+" " PIXEL;
                      SIZE 80,20;
 	                 OF oBar BORDER ;
                      FONT oFontF;
                      COLOR oDp:nClrLabelText,oDp:nClrLabelPane RIGHT


  @ nLin+0, nCol+81 BMPGET oRSOCONT:oCodigo  VAR oRSOCONT:cCodigo;
                   PIXEL;
                   NAME "BITMAPS\FIND.BMP";
                   ACTION oRSOCONT:LBXPROVEEDOR();
                   SIZE 80,20;
                   WHEN .T.;
                   VALID EJECUTAR("VALFINDCODENAME",oRSOCONT:oCodigo,"DPPROVEEDOR","PRO_CODIGO","PRO_NOMBRE") .AND.;
                         EJECUTAR("DPCEROPROV",oRSOCONT:cCodigo,oRSOCONT:oCodigo);
                        .AND. oRSOCONT:VALCODPRO();
                   OF oBar;
                   FONT oFontF

  oRSOCONT:oCodigo:bKeyDown:={|nKey|IF(nKey=13,EVAL(oRSOCONT:oCodigo:bValid),NIL)}


 @ nLin+0, nCol+182 SAY oRSOCONT:oProveedor PROMPT " "+SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oRSOCONT:cCodigo));
                    PIXEL;
                    SIZE 280,20;
                    OF oBar;
                    FONT oFontF;
                    COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER


// oRSOCONT:oHasta:cToolTip:="F6: Calendario"

 @ nLin+21, nCol+81 BMPGET oRSOCONT:oTipDoc  VAR oRSOCONT:cTipDoc;
                    PIXEL;
                    NAME "BITMAPS\FIND.BMP";
                    ACTION oRSOCONT:LBXTIPDOC();
                    SIZE 40,20;
                    WHEN .T.;
                    VALID EJECUTAR("VALFINDCODENAME",oRSOCONT:oTipDoc,"DPTIPDOCPRO","TDC_TIPO","TDC_DESCRI") .AND.;
                          oRSOCONT:VALCODTIP();
                    OF oBar;
                    FONT oFontF

  oRSOCONT:oTipDoc:bKeyDown:={|nKey|IF(nKey=13,EVAL(oRSOCONT:oTipDoc:bValid),NIL)}


 @ nLin+21, nCol+182 SAY oRSOCONT:oTipDescri PROMPT " "+SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oRSOCONT:cTipDoc));
                     PIXEL;
                     SIZE 280,20;
                     OF oBar;
                     FONT oFontF;
                     COLOR oDp:nClrYellowText,oDp:nClrYellow BORDER



 @ nLin+42, nCol+81 GET oRSOCONT:oNumero  VAR oRSOCONT:cNumero;
                    PIXEL;
                    SIZE 160,20;
                    WHEN oRSOCONT:lEditNumero;
                    VALID oRSOCONT:VALNUMERO();
                    OF oBar;
                    FONT oFontF

  oRSOCONT:oNumero:bKeyDown:={|nKey|IF(nKey=13,EVAL(oRSOCONT:oNumero:bValid),NIL)}


  @ nLin+42, nCol+361 GET oRSOCONT:oValCam  VAR oRSOCONT:nValCam PICT oDp:cPictValCam;
                      VALID oRSOCONT:VALCAMBIO();
                      SIZE 100,20 RIGHT OF oBar;
                      FONT oFontF PIXEL



  // 17/11/2024

  oRSOCONT:oWnd:bResized:={||( oRSOCONT:oVSplit:AdjLeft(), ;
                               oRSOCONT:oHSplit:AdjRight())}

  Eval( oRSOCONT:oWnd:bResized )

  oRSOCONT:oBrw2:SetColor(0,oRSOCONT:nClrPane1)
  oRSOCONT:oBrwP:SetColor(0,oRSOCONT:nClrPane1)

  BMPGETBTN(oBar)

  oRSOCONT:oTipDescri:Refresh(.T.)
  oRSOCONT:oProveedor:Refresh(.T.)

  oRSOCONT:BUILDNUMERO()
                     
RETURN .T.

FUNCTION INVACTION(cAction,cTexto,lUpload)
  LOCAL cTitle:=NIL,cWhere:=NIL,aFiles:={},cFileZip,cFileUp,lOk,cDir,nT1:=SECONDS()

// ? cAction,"cAction"

  IF "CENC"$cAction
     RETURN DPLBX("DPCENCOS.LBX")
  ENDIF

  IF "DPT"$cAction
    RETURN DPLBX("DPDPTO.LBX")
  ENDIF

  IF "REQSER"$cAction
     RETURN EJECUTAR("DPDOCREQUIS")
  ENDIF

  IF "REQINV"$cAction
     RETURN EJECUTAR("DPDOCREQUIM")
  ENDIF
         

RETURN .T.

/*
// genera calendario fiscal del periodo
*/
FUNCTION HACERWHERE(dDesde,dHasta)
   EJECUTAR("CREARCALFIS",dDesde,dHasta,.F.,.F.)
RETURN ""

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRSOCONT:oPeriodo:nAt,cWhere:=""

  CursorWait()

  oRSOCONT:nPeriodo:=nPeriodo

  IF oRSOCONT:oPeriodo:nAt=LEN(oRSOCONT:oPeriodo:aItems)

     oRSOCONT:oDesde:ForWhen(.T.)
     oRSOCONT:oHasta:ForWhen(.T.)
     oRSOCONT:oBtn  :ForWhen(.T.)

     DPFOCUS(oRSOCONT:oDesde)

  ELSE

     oRSOCONT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,oRSOCONT:dDesde,oRSOCONT:dHasta)

     oRSOCONT:oDesde:VarPut(oRSOCONT:aFechas[1] , .T. )
     oRSOCONT:oHasta:VarPut(oRSOCONT:aFechas[2] , .T. )

     oRSOCONT:dDesde:=oRSOCONT:aFechas[1]
     oRSOCONT:dHasta:=oRSOCONT:aFechas[2]

     cWhere:=oRSOCONT:HACERWHERE(oRSOCONT:dDesde,oRSOCONT:dHasta,oRSOCONT:cWhere,.T.)

     oRSOCONT:aData   :=EJECUTAR("CONTAB_DEBERES",oRSOCONT:cCodSuc,oDp:dFechaIni,oRSOCONT:dHasta)

     oRSOCONT:aDataFis:=oRSOCONT:LEERREQS(oRSOCONT:HACERWHEREFIS(oRSOCONT:dDesde,oRSOCONT:dHasta,cWhere),NIL,oRSOCONT:cServer)

     IF !Empty(oRSOCONT:aData)
       oRSOCONT:oBrw2:aArrayData:=ACLONE(oRSOCONT:aData)
       oRSOCONT:oBrw2:Refresh(.T.)
       oRSOCONT:oBrw2:GoTop()
     ENDIF

     IF !Empty(oRSOCONT:aDataFis)
       oRSOCONT:oBrw:aArrayData:=ACLONE(oRSOCONT:aDataFis)
       oRSOCONT:oBrw:Refresh(.T.)
       oRSOCONT:oBrw:GoTop()
     ENDIF

  ENDIF

  oRSOCONT:SAVEPERIODO()

RETURN .T.

FUNCTION LEERDATA()
RETURN .T.

FUNCTION LEERREQS(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={},I,nMes:=MONTH(oDp:dFecha)
   LOCAL oDb,aOptions:={}

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cSql:=" SELECT  "+;
          " CRQ_NUMERO,"+;
          " DOR_FCHREQ,"+;
          " CRQ_CODCTA,"+;
          " CTA_DESCRI,"+;
          " CRQ_DESCRI,"+;
          " CRQ_UNDMED,"+;
          " CRQ_CANTID-CRQ_EXPORT AS FALTA, "+;
          " CRQ_MONTO, 0 AS TOTAL,CRQ_ITEM,CRQ_CENCOS,CEN_DESCRI,CRQ_PROYEC,PRY_DESCRI  "+;
          " FROM DPDOCREQCTA "+;
          " INNER JOIN dpdocreq    ON CRQ_NUMERO=DOR_NUMERO "+;
          " INNER JOIN dpcta       ON CRQ_CODCTA=CTA_CODIGO "+;
          " LEFT  JOIN dpcencos    ON CRQ_CENCOS=CEN_CODIGO "+;
          " LEFT  JOIN dpproyectos ON CRQ_PROYEC=PRY_CODIGO "+;
          " WHERE CRQ_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND CRQ_TIPDOC='REQ' AND DOR_ESTADO='RE'"+;
          " AND CRQ_CANTID-CRQ_EXPORT>0 "+;
          " ORDER BY DOR_FCHREQ DESC "


   aData:=ASQL(cSql,oDb)

   DPWRITE("TEMP\REQSERCONT.SQL",cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oRSOCONT:cSql   :=cSql
      oRSOCONT:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      EJECUTAR("BRWCALTOTALES",oBrw,.T.)

      AEVAL(oRSOCONT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRSOCONT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION HACERWHEREFIS(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDOCREQ.DOR_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDOCREQ.DOR_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF

   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oRSOCONT:cWhereQry)
       cWhere:=cWhere + oRSOCONT:cWhereQry
     ENDIF

     oRSOCONT:LEERREQS(cWhere,oRSOCONT:oBrw,oRSOCONT:cServer)

   ENDIF


RETURN cWhere

/*
// Aqui ejecuta Proceso Automático
*/
FUNCTION RUNCLICK()
/*
  LOCAL cProce:=oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,9]

  oDp:lPanel:=.F.

  IF !Empty(cProce)
    EJECUTAR("DPPROCESOSRUN", cProce )
  ENDIF
*/
RETURN .T

FUNCTION BRWCHANGE()
// oDp:oFrameDp:SetText("move")
RETURN .T.

FUNCTION BRWCHANGE2()
  LOCAL cDescri:=oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,5]
  LOCAL aLines :={}
  LOCAL cWhere :="",aDataP:={}
  LOCAL cSql   :=""
  LOCAL aNo    :=_VECTOR("PARA,LOS,DEL,CON")

  IF !oRSOCONT:lBuscarProv

     IF !Empty(oRSOCONT:oBrwP:aArrayData[1,1])
       AADD(aDataP,{"","",0,"",CTOD(""),"","",""})
       oRSOCONT:oBrwP:aArrayData:=ACLONE(aDataP)
       oRSOCONT:oBrwP:Refresh(.T.)
     ENDIF

     RETURN .F.

  ENDIF

  AEVAL(aNo,{|a,n| cDescri:=STRTRAN(cDescri," "+a+" ","") })

  aLines:=_VECTOR(cDescri," ")

  ADEPURA(aLines,{|a,n| LEN(a)<3})

  AEVAL(aLines,{|a,n| cWhere:=cWhere + IF(!Empty(cWhere)," OR ","") +;
                      "CCD_DESCRI LIKE "+GetWhere("","%"+a+"%")})

  IF !Empty(cWhere)

   cSql:=[ SELECT CCD_CODIGO,PRO_NOMBRE,CCD_MONTO/DOC_VALCAM AS MONTO,CCD_DESCRI,DOC_FECHA,DOC_TIPDOC,DOC_NUMERO,DOC_DOCORG ]+;
           [ FROM dpdocprocta ]+;
           [ INNER JOIN dpdocpro    ON CCD_CODSUC=DOC_CODSUC AND CCD_TIPDOC=DOC_TIPDOC AND CCD_CODIGO=DOC_CODIGO AND CCD_NUMERO=DOC_NUMERO AND CCD_TIPTRA=DOC_TIPTRA ]+;
           [ INNER JOIN dpproveedor ON DOC_CODIGO=PRO_CODIGO ]+;
           [ WHERE  ]+cWhere+;
           [ GROUP BY CCD_CODIGO ]+;
           [ ORDER BY DOC_FECHA DESC LIMIT 5]

    aDataP:=ASQL(cSql)

  ENDIF

  IF Empty(aDataP)
     aDataP:={}
     AADD(aDataP,{"","",0,"",CTOD(""),"","",""})
  ENDIF

  oRSOCONT:oBrwP:aArrayData:=ACLONE(aDataP)
  oRSOCONT:oBrwP:Refresh(.T.)

RETURN .T.


FUNCTION MENU_CNF(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oRSOCONT:cVarName

   AADD(aOption,{"Seleccionar cuentas para requisiciones",""})
   AADD(aOption,{"Permisos por Usuario",""})

   C5MENU oPopFind POPUP;
          COLOR    oDp:nMenuItemClrText,oDp:nMenuItemClrPane;
          COLORSEL oDp:nMenuItemSelText,oDp:nMenuItemSelPane;
          COLORBOX oDp:nMenuBoxClrText;
          HEIGHT   oDp:nMenuHeight;
          FONT     oDp:oFontMenu;
          LOGOCOLOR oDp:nMenuMainClrText

          FOR I=1 TO LEN(aOption)

           IF Empty(aOption[I,1])

              C5SEPARATOR

            ELSE

              nContar++

              bAction:=cFrm+":lTodos:=.F.,oRSOCONT:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_CNFRUN(nOption,cPar2,cPar3)
   LOCAL oFrm
   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      DPLBX("DPCTAREQ.LBX")
      RETURN
   ENDIF

   IF nOption=2
     RETURN DPLBX("DPUSUREQ.LBX")
   ENDIF
                                                                                                 
RETURN .T.



FUNCTION RUNCLICK3()
   LOCAL lFecha:=.T.
RETURN EJECUTAR("BRCALFISDETRUN",lFecha,oRSOCONT)

FUNCTION SAVEPERIODO()
  LOCAL cFileMem  :="USER\ADDON_REQSER.MEM"
  LOCAL V_nPeriodo:=oRSOCONT:nPeriodo
  LOCAL V_dDesde  :=oRSOCONT:dDesde
  LOCAL V_dHasta  :=oRSOCONT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

FUNCTION BUSCARDESCUADRE()
  LOCAL cWhere:="MOC_ACTUAL"+GetWhere("<>","N")+" AND ABS(MOC_MONTO)"+GetWhere("=",oRSOCONT:nBalance)

  EJECUTAR("BRWCOMPROBACION",NIL,oRSOCONT:dDesde,oRSOCONT:dHasta)

RETURN .T.

/*
// Grabar Registro
*/
FUNCTION PUTFIELDVALUE(oCol,uValue,nCol,nKey,NIL,lSave,cField)
  LOCAL aLine :={},aFields:={},aValues:={}
  LOCAL nTotal:=0

  oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,nCol]:=uValue

  aLine :=oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt]
  nTotal:=aLine[7]*aLine[8]

  oRSOCONT:oBrw2:aArrayData[oRSOCONT:oBrw2:nArrayAt,9]:=nTotal


  oRSOCONT:oBrw2:DrawLine()

RETURN .T.


FUNCTION VERDOCPRO()
  LOCAL aLine  :=oRSOCONT:oBrwP:aArrayData[oRSOCONT:oBrwP:nArrayAt]
  LOCAL cCodigo:=aLine[2]
  LOCAL cTipDoc:=aLine[6]
  LOCAL cNumero:=aLine[7]
  LOCAL cDocOrg:=aLine[8]

  IF Empty(aLine[1])
     oRSOCONT:lBuscarProv:=.T.
     oRSOCONT:BRWCHANGE2()
     RETURN .T.
  ENDIF

RETURN EJECUTAR("VERDOCPRO",oRSOCONT:cCodSuc,cTipDoc,cCodigo,cNumero,cDocOrg)

FUNCTION LBXPROVEEDOR()
   LOCAL cWhere:="(PRO_SITUAC='A' OR PRO_SITUAC='C') AND "+oRSOCONT:cWherePro
   LOCAL cTitle:=NIL,oDpLbx

   oDpLbx:=DpLbx(oRSOCONT:cFileLbx,cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oRSOCONT:oCodigo)

   oDpLbx:GetValue("PRO_CODIGO",oRSOCONT:oCodigo)

RETURN .F.

FUNCTION VALCODPRO()

  EJECUTAR("VALFINDCODENAME",oRSOCONT:oCodigo,"DPPROVEEDOR","PRO_CODIGO","PRO_NOMBRE") 

  IF Empty(oRSOCONT:cCodigo) .OR. !ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",oRSOCONT:cCodigo))
     DPFOCUS(oRSOCONT:oCodigo)
     EVAL(oRSOCONT:oCodigo:bAction)
     RETURN .T.
  ENDIF

  oRSOCONT:oProveedor:Refresh(.T.)

RETURN .T.

/*
// LBX de tipo de Documentos
*/
FUNCTION LBXTIPDOC()
  LOCAL cWhere:=GetWhereOr("TDC_TIPO",oRSOCONT:aTipDoc)
  LOCAL cTitle:=NIL,oDpLbx

  oDpLbx:=DpLbx("DPTIPDOCPROREQCOM.LBX",cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oRSOCONT:oTipDoc)
  oDpLbx:GetValue("TDC_TIPO",oRSOCONT:oTipDoc)


RETURN .T.

/*
// Validar Tipo de Documento
*/
FUNCTION VALCODTIP()
  LOCAL cWhere:="TDC_ACTIVO=1 AND TDC_ORGRES=1 AND TDC_TRIBUT=0"

  EJECUTAR("VALFINDCODENAME",oRSOCONT:oTipDoc,"DPTIPDOCPRO","TDC_TIPO","TDC_DESCRI",cWhere) 

  IF Empty(oRSOCONT:cTipDoc) .OR. !ISSQLFIND("DPTIPDOCPRO","TDC_TIPO"+GetWhere("=",oRSOCONT:cTipDoc))
     DPFOCUS(oRSOCONT:oTipDoc)
     EVAL(oRSOCONT:oTipDoc:bAction)
     RETURN .T.
  ENDIF

  oRSOCONT:oTipDescri:Refresh(.T.)

RETURN .T.

FUNCTION VALNUMERO()
RETURN .T.

FUNCTION BUILDNUMERO()
  LOCAL oDb   :=NIL,cMax:=NIL,lZero:=.T.,nLen:=10
  LOCAL cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc         )+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oRSOCONT:cTipDoc)+" AND "+;
                "DOC_TIPTRA"+GetWhere("=","D")

  oRSOCONT:cNumero:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO",cWhere,oDb,cMax,lZero,nLen)  
  oRSOCONT:oNumero:Refresh(.T.)
  oRSOCONT:oNumero:ForWhen(.T.)

RETURN .T.

/*
// Mover los documentos
*/
FUNCTION DOCGRABAR(lAdd)
  LOCAL aNew   :={},aLines:={},nAt2:=oRSOCONT:oBrw2:nArrayAt,oCol
  LOCAL aData  :={},cOrg  :="D",cWhere:="",cSql,cWhere:="",aNumDoc:={},aTotales:={}
  LOCAL oTableO:=NIL,oTableC:=NIL,I,cNeto
  LOCAL oDb    :=OpenOdbc(oDp:cDsnData)

  DEFAULT lAdd:=.F.

  oRSOCONT:aOrigen:=ACLONE(oRSOCONT:oBrw2:aArrayData)

  IF Empty(oRSOCONT:oBrw:aArrayData[1,1])
    oRSOCONT:oBrw:aArrayData:={}
  ENDIF

  aLines:=ACLONE(oRSOCONT:oBrw2:aArrayData[1])
  AEVAL(aLines,{|a,n| aLines[n]:=CTOEMPTY(a)})
  
  AEVAL(oRSOCONT:oBrw2:aArrayData,{|a,n| IF(a[9]>0, AADD(oRSOCONT:oBrw:aArrayData,a),AADD(aNew,a))})

  IF Empty(aNew)
     AADD(aNew,aLines)
  ENDIF

  IF Empty(oRSOCONT:oBrw:aArrayData)
     AADD(oRSOCONT:oBrw:aArrayData,aLines)
  ENDIF

  oRSOCONT:oBrw2:aArrayData:=ACLONE(aNew)
  oRSOCONT:oBrw2:nArrayAt:=MIN(nAt2,oRSOCONT:oBrw2:nArrayAt)


  oCol:=oRSOCONT:oBrw2:aCols[1]   
  oCol:cFooter      :=LSTR(LEN(oRSOCONT:oBrw2:aArrayData))

  oRSOCONT:oBrw2:Refresh(.F.)
  oRSOCONT:oBrw:Refresh(.F.)

  EJECUTAR("BRWCALTOTALES",oRSOCONT:oBrw,.T.)

  IF lAdd
     RETURN .F.
  ENDIF

  IF Empty(oRSOCONT:cCodigo) .OR. !ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",oRSOCONT:cCodigo))
     DPFOCUS(oRSOCONT:oCodigo)
     RETURN .F.
  ENDIF

  aTotales:=ATOTALES(oRSOCONT:oBrw:aArrayData)
  cNeto   :="Monto Neto ("+LSTR(oDp:nTasaGN)+"% IVA) ="+;
             ALLTRIM(FDP(aTotales[9]+PORCEN(aTotales[9],oDp:nTasaGN),"999,999,999,999.99"))+oDp:cMonedaExt

  IF !MsgNoYes("Desea Crear "+oRSOCONT:cTipDoc+" "+ALLTRIM(oRSOCONT:oTipDescri:GetText())+CRLF+;
               "#"+oRSOCONT:cNumero+CRLF+;
               "Monto Base= "+ALLTRIM(FDP(aTotales[9],"999,999,999,999.99"))+oDp:cMonedaExt+CRLF+;
               cNeto)
     RETURN .F.
  ENDIF

 
  oDb:Execute(" SET FOREIGN_KEY_CHECKS = 0")

  EJECUTAR("DPDOCPROCREA",oRSOCONT:cCodSuc,oRSOCONT:cTipDoc,oRSOCONT:cNumero,oRSOCONT:cNumFis,oRSOCONT:cCodigo,oRSOCONT:dFecha,oDp:cMonedaExt,cOrg,oRSOCONT:cCenCos,0,;
                          0,oRSOCONT:nValCam,oRSOCONT:dFchDec,NIL,oTableO,oRSOCONT:nCxP)

  AEVAL(oRSOCONT:oBrw:aArrayData,{|a,n| AADD(aData,{a[3],a[5],a[9]*oRSOCONT:nValCam,oDp:cTasaGN,oDp:nTasaGN,0,"REQ",a[1],a[10],a[7],a[6],a[11],a[13],a[2]}) })


  EJECUTAR("DPDOCPROCTAADD",oRSOCONT:cCodSuc,oRSOCONT:cTipDoc,oRSOCONT:cCodigo,oRSOCONT:cNumero,oRSOCONT:cCenCos,aData,oTableC,oRSOCONT:nValCam)
  EJECUTAR("DPDOCCLIIVA"   ,oRSOCONT:cCodSuc,oRSOCONT:cTipDoc,oRSOCONT:cCodigo,oRSOCONT:cNumero,.T.,0,0,0,0,"C",0)

  /*
  // ACtualizar documento de Origen
  */
  aData:=ACLONE(oRSOCONT:oBrw:aArrayData)

  FOR I=1 TO LEN(aData) 

      cWhere:="CRQ_CODSUC"+GetWhere("=",oRSOCONT:cCodSuc)+" AND "+;
              "CRQ_TIPDOC"+GetWhere("=","REQ"           )+" AND "+;
              "CRQ_NUMERO"+GetWhere("=",aData[I,01]     )+" AND "+;
              "CRQ_ITEM  "+GetWhere("=",aData[I,10]     )

      cSql:=[ UPDATE DPDOCREQCTA SET CRQ_EXPORT=CRQ_EXPORT+]+LSTR(aData[I,7],19,2)+" WHERE "+cWhere

      oDb:Execute(cSql)
     
      AADD(aNumDoc,aData[I,01])

  NEXT I  

  /*
  // Cambiar estatus Requisiciones Concluidas
  */
  cSql :=[ SELECT  CRQ_CODSUC,CRQ_TIPDOC,CRQ_NUMERO,SUM(CRQ_CANTID-CRQ_EXPORT) AS FALTA FROM dpdocreqcta  ]+;
         [ INNER JOIN dpdocreq    ON CRQ_NUMERO=DOR_NUMERO ]+;
         [ WHERE DOR_ESTADO='RE' AND ]+GetWhereOr("DOR_NUMERO",aNumDoc)+;
         [ GROUP BY CRQ_CODSUC,CRQ_TIPDOC,CRQ_NUMERO ]

  aData:=ASQL(cSql)

  FOR I=1 TO LEN(aData) 

  IF aData[I,4]<=0       

     cWhere:="DOR_CODSUC"+GetWhere("=",oRSOCONT:cCodSuc)+" AND "+;
             "DOR_TIPDOC"+GetWhere("=","REQ"           )+" AND "+;
             "DOR_NUMERO"+GetWhere("=",aData[I,3]      )
      
     cSql   :=[ UPDATE DPDOCREQ SET DOR_ESTADO='EX' WHERE ]+cWhere

     oDb:Execute(cSql)

   ENDIF

  NEXT I  

  SQLUPDATE("DPTIPDOCPRO","TDC_DOCEDI",.T.,"TDC_TIPO"+GetWhere("=",oRSOCONT:cTipDoc))

  oDb:Execute(" SET FOREIGN_KEY_CHECKS = 1")

  oRSOCONT:oBrw:aArrayData:={}
  AADD(oRSOCONT:oBrw:aArrayData,aLines)
  oRSOCONT:oBrw:Gotop()

  oRSOCONT:LEERREQS(oRSOCONT:cWhereReq,oRSOCONT:oBrw2,oRSOCONT:cServer)

  EJECUTAR("VERDOCPRO",oRSOCONT:cCodSuc,oRSOCONT:cTipDoc,oRSOCONT:cCodigo,oRSOCONT:cNumero,cOrg,"Documentos del Proveedor")

RETURN .T.
// EOF
