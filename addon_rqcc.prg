// Programa   : ADDON_RQCC
// Fecha/Hora : 18/09/2010 17:22:34
// Propósito  : Menú Requisiciones de compras y Contrataciones de Servicios 
// Creado Por : Juan Navas
// Llamado por: DPINVCON
// Aplicación : Inventario
// Tabla      : DPINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,cRif,cCenCos,cCodCaj)
   LOCAL cNombre:="",cSql,I,nGroup,aLine:={}
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp,oCol
   LOCAL oBtn,nGroup,bAction,aBtn:={}
   LOCAL oData    :=DATACONFIG("ACBLPERIODO","ALL")
   LOCAL dDesde   :=oDp:dFchInicio // FCHINIMES(oDp:dFecha)
   LOCAL dHasta   :=oDp:dFchCierre // FCHFINMES(oDp:dFecha)
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL cFileMem :="USER\ADDON_ACBL.MEM",V_nPeriodo:=10,nPeriodo,aFechas:={},aTotal:={}
   LOCAL V_dDesde :=CTOD("")
   LOCAL V_dHasta :=CTOD("")
   LOCAL oDb      :=OpenOdbc(oDp:cDsnData)
   LOCAL aData    :={} 
   LOCAL aDataFis :={} 
   LOCAL dFecha   :=oDp:dFecha,cServer,cWhere
   LOCAL aTotal   :=ATOTALES(aData)
   LOCAL aTipDoc   :={"FAC","DEB","CRE","PLI","RTI"}
   LOCAL cCodSucCbt:=""
   LOCAL nBalance  :=0

   DEFAULT oDp:lAplNomina:=.F. 

   DEFAULT cCodSuc:=oDp:cSucursal

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

   nBalance:=100 // SQLGET("DPASIENTOS","SUM(MOC_MONTO)",GetWhereOr("MOC_ACTUAL",{"S","A","F"}))
   aDataFis:=LEERDATAFIS(HACERWHEREFIS(dDesde,dHasta,cWhere),NIL,cServer)
   aData   :=EJECUTAR("CONTAB_DEBERES",cCodSuc,oDp:dFechaIni,dFecha)
   aTotal  :=ATOTALES(aDataFis)

   aData[1,1]:="Requisiciones de Servicios por 1era Aprobación"
   aData[2,1]:="Requisiciones de Servicios por 2da Aprobación"
   aData[3,1]:="Requisiciones de Productos por 1era Aprobación"
   aData[4,1]:="Requisiciones de Productos por 2da Aprobación"
   aData[5,1]:="Cantidad de Requisiciones de Productos por Recibir"
   aData[6,1]:="Cantidad de Requisiciones de Servicios por Ejecuta"
   aData[7,1]:="Cantidad de Productos por Recibir"
   aData[8,1]:="Cantidad de Servicios por Ejecutar"


   DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-11 BOLD
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-11 BOLD

   DpMdi("Menú: Requisiciones de Productos y Servicios para el Deparamento de Compras y Contrataciones ","oRQCYC","")

   oRQCYC:cCodigo   :=cCodigo
   oRQCYC:cCodSuc   :=cCodSuc
   oRQCYC:cNombre   :=cNombre
   oRQCYC:lSalir    :=.F.
   oRQCYC:nHeightD  :=45
   oRQCYC:lMsgBar   :=.F.
   oRQCYC:oGrp      :=NIL
   oRQCYC:ADD_AUTEJE:=SQLGET("DPADDON"  ,"ADD_AUTEJE","ADD_CODIGO"+GetWhere("=","ACBL"))
   oRQCYC:lEnvAut   :=SQLGET("DPEMPRESA","EMP_ENVAUT","EMP_CODIGO"+GetWhere("=",oDp:cEmpCod))
   oRQCYC:dDesde    :=dDesde
   oRQCYC:dHasta    :=dHasta
   oRQCYC:cPeriodo  :=aPeriodos[nPeriodo]
   oRQCYC:lWhen     :=.T.
   oRQCYC:cRif      :=ALLTRIM(cRif)
   oRQCYC:cDir      :="ACBL_"+cRif
   oRQCYC:cFileZip  :=""
   oRQCYC:cServer   :=""
   oRQCYC:nPeriodo  :=nPeriodo
   oRQCYC:cCenCos   :=cCenCos
   oRQCYC:cCodCaj   :=cCodCaj
   oRQCYC:SetFunction("MDISETPROCE")
   oRQCYC:cWhereQry :=NIL
   oRQCYC:aDataFis  :=aDataFis
   oRQCYC:aData     :=aData
   oRQCYC:cWhere    :=""
   oRQCYC:cWhere_   :=""
   oRQCYC:dCbtDesde :=SQLGET("DPCBTE","MIN(CBT_FECHA),MAX(CBT_FECHA)","CBT_CODSUC"+GetWhere("=",cCodSuc))
   oRQCYC:dCbtHasta :=DPSQLROW(2)
   oRQCYC:nSucursal :=COUNT("DPSUCURSAL","SUC_ACTIVO=1")
   oRQCYC:nBalance  :=nBalance

   oRQCYC:nAltoBrw  :=160-30 // 100+100+08
   oRQCYC:nAnchoSpl1:=120+50-220

   SetScript("ADDON_ACBL")

   AADD(aBtn,{oDp:DPCENCOS                    ,"CENTRODECOSTO.BMP"          ,"CENCOS"}) 
   AADD(aBtn,{oDp:DPDPTO                      ,"DEPARTAMENTOS.BMP"          ,"DPTO"  }) 

   AADD(aBtn,{"Requisiciones de Productos"    ,"PRODUCTO.BMP"               ,"REQINV"   }) 
   AADD(aBtn,{"Requisiciones de Servicios"    ,"prestadoresdeservicios.bmp" ,"REQSER"   }) 

// AADD(aBtn,{"Requisiciones de Servicios"    ,"prestadoresdeservicios.bmp" ,"REQSER"   }) 

/*
   AADD(aBtn,{"AprobacionImportar Nómina Quincenal","TRABAJADOR.BMP" ,"NOMQUINCENAL" }) 

   AADD(aBtn,{"Registrar Presupuesto por Cuenta Contable","objetivos.BMP"    ,"CNDPRESUPUESTO" })
*/
   oRQCYC:Windows(0,0,oDp:aCoors[3]-(oDp:oBar:nHeight()+120),oDp:aCoors[4]-10,.T.)  

  @ 48+40-10+20+15, -1 OUTLOOK oRQCYC:oOut ;
     SIZE (150+250)-(40+220-10), oRQCYC:oWnd:nHeight()-(oDp:oBar:nHeight()+120);
     PIXEL ;
     FONT oFont ;
     OF oRQCYC:oWnd;
     COLOR CLR_BLACK,oDp:nGris

   DEFINE GROUP OF OUTLOOK oRQCYC:oOut PROMPT "&Opciones "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oRQCYC:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oRQCYC:oOut:aGroup)
      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oRQCYC:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT I


   DEFINE GROUP OF OUTLOOK oRQCYC:oOut PROMPT "&Aprobación Nivel #1"

   aBtn:={}
   AADD(aBtn,{"Requisiciones de Productos"    ,"PRODUCTO.BMP"               ,"REQINV"   }) 
   AADD(aBtn,{"Requisiciones de Servicios"    ,"prestadoresdeservicios.bmp" ,"REQSER"   }) 


   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oRQCYC:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oRQCYC:oOut:aGroup)
      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oRQCYC:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   DEFINE GROUP OF OUTLOOK oRQCYC:oOut PROMPT "&Aprobación Nivel #2 "

   aBtn:={}
   AADD(aBtn,{"Requisiciones de Productos"    ,"PRODUCTO.BMP"               ,"REQINV"   }) 
   AADD(aBtn,{"Requisiciones de Servicios"    ,"prestadoresdeservicios.bmp" ,"REQSER"   }) 


   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oRQCYC:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oRQCYC:oOut:aGroup)
      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oRQCYC:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   DEFINE GROUP OF OUTLOOK oRQCYC:oOut PROMPT "&Crear Orden de Compra y/o Contrataciones"

   aBtn:={}
   AADD(aBtn,{"Productos"    ,"PRODUCTO.BMP"               ,"ORCINV"   }) 
   AADD(aBtn,{"Servicios"    ,"prestadoresdeservicios.bmp" ,"ORCSER"   }) 


   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oRQCYC:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oRQCYC:oOut:aGroup)
      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oRQCYC:INVACTION(["+aBtn[I,3]+"],["+aBtn[I,1]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oRQCYC:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I


   oRQCYC:oBrw2:=TXBrowse():New(oRQCYC:oWnd)
   oRQCYC:oBrw2:SetArray( aData, .F. )

   oRQCYC:oBrw2:oFont       := oFont
   oRQCYC:oBrw2:lFooter     := .T.
   oRQCYC:oBrw2:lHScroll    := .F.
   oRQCYC:oBrw2:nHeaderLines:= 2
   oRQCYC:oBrw2:nDataLines  := 2
   oRQCYC:oBrw2:lFooter     :=.F.

// IF .T.

   oCol:=oRQCYC:oBrw2:aCols[1]   
   oCol:cHeader      :="Indicador de Deberes por Realizar"
   oCol:nWidth       :=260+200+50

   oCol:=oRQCYC:oBrw2:aCols[2]   
   oCol:cHeader      :="Etiqueta"
   oCol:nWidth       :=110

   oCol:=oRQCYC:oBrw2:aCols[3]
   oCol:cHeader      :="Objetivo"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw2:aArrayData ) } 
   oCol:nWidth       := 60-5
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|nMonto|nMonto:= oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,3],FDP(nMonto,'99,999,999')}

   oCol:=oRQCYC:oBrw2:aCols[4]
   oCol:cHeader      :="Logrado"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw2:aArrayData ) } 
   oCol:nWidth       := 60-5
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|nMonto|nMonto:= oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,4],FDP(nMonto,'99,999,999')}

   oCol:=oRQCYC:oBrw2:aCols[5]
   oCol:cHeader      :="Por"+CRLF+"Ejecutar"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw2:aArrayData ) } 
   oCol:nWidth       := 60-5
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|nCantid,nPorcen,cPicture|nCantid := oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,05],;
                                                  nPorcen := oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,06],;
                                                  cPicture:= oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,10],;
                                                  FDP(nCantid,cPicture)+CRLF+FDP(nPorcen,'999,999',NIL,.T.,NIL,"%")}

   oCol:=oRQCYC:oBrw2:aCols[6+1]   
   oCol:cHeader      :="Fecha"+CRLF+"Actlz."
   oCol:nWidth       :=55
   oCol:bStrData     :={|dFecha|dFecha:=oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,6+1],F82(dFecha)}

   oRQCYC:oBrw2:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw2,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=oBrw:aArrayData[oBrw:nArrayAt,7+1],;
                                        {nClrText,iif( oBrw:nArrayAt%2=0, 16774120, 16769217) } }

   oRQCYC:oBrw2:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRQCYC:oBrw2:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oRQCYC:oBrw2:bLDblClick:={|oBrw|oRQCYC:RUNCLICK() }


   oRQCYC:oBrw2:DelCol(6)
   oRQCYC:oBrw2:DelCol(8)
   oRQCYC:oBrw2:DelCol(7)
   oRQCYC:oBrw2:DelCol(7)

   oRQCYC:oBrw2:CreateFromCode()
   oRQCYC:oBrw2:Move(0,205+oRQCYC:nAnchoSpl1,.T.)
   oRQCYC:oBrw2:SetSize(300,200+oRQCYC:nAltoBrw)

   oRQCYC:oBrw:=TXBrowse():New(oRQCYC:oWnd)
   oRQCYC:oBrw:SetArray( aDataFis, .F. )

   oRQCYC:dFchIni  :=CTOD("")
   oRQCYC:dFchFin  :=CTOD("")

   oRQCYC:oBrw:SetFont(oFont)

   oRQCYC:oBrw:lFooter     := .T.
   oRQCYC:oBrw:lHScroll    := .T.
   oRQCYC:oBrw:nHeaderLines:= 2
   oRQCYC:oBrw:nDataLines  := 1
   oRQCYC:oBrw:nFooterLines:= 1

   oRQCYC:aData            :=ACLONE(aData)
   oRQCYC:nClrText :=0
   oRQCYC:nClrPane1:=16774120
   oRQCYC:nClrPane2:=16771797

   AEVAL(oRQCYC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})


   oCol:=oRQCYC:oBrw:aCols[1]
   oCol:cHeader      :='Tipo'+CRLF+'Doc.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 30

   oCol:=oRQCYC:oBrw:aCols[2]
   oCol:cHeader      :='Número'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80

   oCol:=oRQCYC:oBrw:aCols[3]
   oCol:cHeader      :='Fecha'+CRLF+"Emisión"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80

   oCol:=oRQCYC:oBrw:aCols[4]
   oCol:cHeader      :='Descripción'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 160

   oCol:=oRQCYC:oBrw:aCols[5]
   oCol:cHeader      :='Tipo'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80
   oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,;
                                              aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                              nClrText:=16711808,;
                                              nClrText:=IF("M"$aData[5],16711935,nClrText),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }


   oCol:=oRQCYC:oBrw:aCols[6]
   oCol:cHeader      :='Fecha'+CRLF+"Requerida"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80


   oCol:=oRQCYC:oBrw:aCols[7]
   oCol:cHeader      :='Fecha'+CRLF+"Aprb. #1"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80

   oCol:=oRQCYC:oBrw:aCols[8]
   oCol:cHeader      :='Fecha'+CRLF+"Aprb. #2"
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80

   oCol:=oRQCYC:oBrw:aCols[9]
   oCol:cHeader      :='Estado'
   oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 80


//   "  DOR_TIPDES, DOR_TIPREQ,DOR_FCHREQ,DOR_FCHAN1,DOR_FCHAN2,DOR_ESTADO,0 AS CERO "+;

/*
   oCol:=oRQCYC:oBrw:aCols[4]
   oCol:cHeader      :='Tipo'+CRLF+'Doc.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
   oCol:nWidth       := 35

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }


  oCol:=oRQCYC:oBrw:aCols[5]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 170


  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }

  oCol:=oRQCYC:oBrw:aCols[6]
  oCol:cHeader      :='Referencia'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:bClrStd      := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                       nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                       nClrText:=IF(aData[23]>0 .AND. nClrText=0,aData[23],oBrw:aArrayData[oBrw:nArrayAt,17]),;
                                      {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }

  oCol:=oRQCYC:oBrw:aCols[7]
  oCol:cHeader      :='Fecha'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oRQCYC:oBrw:aCols[8]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cFooter      :=FDP(aTotal[8],'9,999,999,999,999.99')

  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,8],;
                              oCol   := oRQCYC:oBrw:aCols[8],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oRQCYC:oBrw:aCols[9]
  oCol:cHeader      :='Dias'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,9],FDP(nMonto,'9999999')}

  oCol:=oRQCYC:oBrw:aCols[10]
  oCol:cHeader      :='Estatus'+CRLF+'Registro'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       :=90

  oCol:=oRQCYC:oBrw:aCols[11]
  oCol:cHeader      :='Fecha'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oRQCYC:oBrw:aCols[12]
  oCol:cHeader      :='Dias'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,12],FDP(nMonto,'9999')}

  oCol:=oRQCYC:oBrw:aCols[13]
  oCol:cHeader      :='Estatus'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oRQCYC:oBrw:aCols[14]
  oCol:cHeader      :='Cbte.'+CRLF+'Pago'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  oCol:=oRQCYC:oBrw:aCols[15]
  oCol:cHeader      :='Cbte.'+CRLF+'Contable'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oRQCYC:oBrw:aCols[16]
  oCol:cHeader      :='Dias'+CRLF+'x Transc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,16],FDP(nMonto,'9999')}


  oRQCYC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))


  oCol:=oRQCYC:oBrw:aCols[17]
  oCol:cHeader      :='Color'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oRQCYC:oBrw:aCols[18]
  oCol:cHeader      :='Código'+CRLF+'CxP'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oRQCYC:oBrw:aCols[19]
  oCol:cHeader      :='Número'+CRLF+'Documento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oRQCYC:oBrw:aCols[20]
  oCol:cHeader      :='Código'+CRLF+'Planif.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 65

  oCol:=oRQCYC:oBrw:aCols[21]
  oCol:cHeader      :='Número'+CRLF+'Planificación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 240


  oCol:=oRQCYC:oBrw:aCols[22]
  oCol:cHeader      :='Institución'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 300


  oCol:=oRQCYC:oBrw:aCols[23]
  oCol:cHeader      :='Color'+CRLF+'Tipo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,23],FDP(nMonto,'9999999')}

  oCol:=oRQCYC:oBrw:aCols[24]
  oCol:cHeader      :='Monto'+CRLF+'Calculado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,24],;
                              oCol   := oRQCYC:oBrw:aCols[24],;
                              FDP(nMonto,oCol:cEditPicture)}


  oCol:=oRQCYC:oBrw:aCols[25]
  oCol:cHeader      :='Valor'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :=oDp:cPictValCam
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,25],;
                              oCol   := oRQCYC:oBrw:aCols[25],;
                              FDP(nMonto,oCol:cEditPicture)}

  oCol:=oRQCYC:oBrw:aCols[26]
  oCol:cHeader      :='Monto'+CRLF+'Divisa'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRQCYC:oBrw:aArrayData ) } 
  oCol:nWidth       := 100
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:cEditPicture :='9,999,999,999,999.99'
  oCol:bStrData:={|nMonto,oCol|nMonto:= oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt,26],;
                              oCol   := oRQCYC:oBrw:aCols[26],;
                              FDP(nMonto,oCol:cEditPicture)}
  oCol:cFooter      :=FDP(aTotal[26],'9,999,999,999,999.99')
 

  oRQCYC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=oBrw:aArrayData[oBrw:nArrayAt,17],;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }
*/


  oRQCYC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRQCYC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                          nClrText:=0,;
                                         {nClrText,iif( oBrw:nArrayAt%2=0, oRQCYC:nClrPane1, oRQCYC:nClrPane2 ) } }

// ENDIF


  oRQCYC:oBrw:bClrFooter     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oRQCYC:oBrw:bClrHeader     := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oRQCYC:oBrw:bLDblClick:={|oBrw| oRQCYC:RUNCLICK3() }

  oRQCYC:oBrw:bChange:={||oRQCYC:BRWCHANGE()}

  oRQCYC:oBrw:CreateFromCode()

  oRQCYC:oBrw:aCols[17]:lHide:=.T. // DelCol(17)

  oRQCYC:oBrw:CreateFromCode()
  oRQCYC:oBrw:Move(205+oRQCYC:nAltoBrw,205+oRQCYC:nAnchoSpl1,.T.)
  oRQCYC:oBrw:SetSize(300,150,.T.)

 @ 200+oRQCYC:nAltoBrw,205+oRQCYC:nAnchoSpl1 SPLITTER oRQCYC:oHSplit ;
             HORIZONTAL ;
             PREVIOUS CONTROLS oRQCYC:oBrw2 ;
             HINDS CONTROLS oRQCYC:oBrw ;
             TOP MARGIN 80 ;
             BOTTOM MARGIN 80 ;
             SIZE 300, 4  PIXEL ;
             OF oRQCYC:oWnd ;
             _3DLOOK

  @ 0,200+oRQCYC:nAnchoSpl1   SPLITTER oRQCYC:oVSplit ;
            VERTICAL ;
            PREVIOUS CONTROLS oRQCYC:oOut ;
            HINDS CONTROLS oRQCYC:oBrw2, oRQCYC:oHSplit, oRQCYC:oBrw ;
            LEFT MARGIN 80 ;
            RIGHT MARGIN 80 ;
            SIZE 4, 355  PIXEL ;
            OF oRQCYC:oWnd ;
            _3DLOOK

   oRQCYC:Activate("oRQCYC:FRMINIT()") // ,,"oRQCYC:oSpl:AdjRight()")
 
   EJECUTAR("DPSUBMENUCREAREG",oRQCYC,NIL,"A")

   IF COUNT("DPCTA")=0
      MsgMemo("Necesario Importar Plan de Cuentas")
      EJECUTAR("DPCTAIMPORT")
   ENDIF

   oRQCYC:bGotFocus:={|| oRQCYC:BTNSETFONT() }

   IF SQLGET("DPASIENTOS","SUM(MOC_MONTO)","MOC_ORIGEN='BAL'")<>0
      EJECUTAR("BRBALINIDIV")
   ENDIF

RETURN

FUNCTION BTNSETFONT()
  LOCAL oFont

  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD

  oRQCYC:oBar:SetFont(oFont)

// oDp:oFrameDp:SetText("AQUI "+TIME())

RETURN .T.

FUNCTION FRMINIT()
  LOCAL oCursor,oBar,oBtn,oFont,oFontI,nCol:=12,nLin:=0,oFontB,oFontF
  LOCAL nLin:=0,nContar:=0,cAction:="",nPorIva:=0
  LOCAL aTipIva:=ACLONE(oDp:aTipIva)

  AEVAL(oDp:aTipIva,{|a,n,nPorIva| nPorIva   :=EJECUTAR("IVACAL",oDp:aTipIva[n],3,oRQCYC:dDesde),;
                                   aTipIva[n]:={a,nPorIva} })

  ASORT(aTipIva,,, { |x, y| x[2] < y[2] })

  AADD(aTipIva,{"Todos",0})


  DEFINE BUTTONBAR oBar SIZE 44+25,44+20 OF oRQCYC:oWnd 3D CURSOR oCursor

  oRQCYC:oBar:=oBar

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -09 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -10 BOLD

  DEFINE FONT oFontI NAME "Tahoma" SIZE 0, -10 

// inactivos


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROYECTOS.BMP";
          TOP PROMPT "Proyectos"; 
          MENU oRQCYC:MENU_CNF("MENU_CNFRUN","DOS");
          ACTION DPLBX("DPPROYECTOS.LBX")

//EJECUTAR("DPCONFIG")

  oBtn:cToolTip:="Configuración"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ZOOM.BMP";
          TOP PROMPT "Zoom"; 
          ACTION IF(oRQCYC:oWnd:IsZoomed(),oRQCYC:oWnd:Restore(),oRQCYC:oWnd:Maximize())

  oBtn:cToolTip:="Maximizar"



  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XCALENDARIO.BMP";
          TOP PROMPT "Calendario"; 
          MENU oRQCYC:MENU_CNF("MENU_CNFRUN","DOS");
          ACTION EJECUTAR("DPCONFIG")

  oBtn:cToolTip:="Calendario"


/*
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\contabilidad.BMP";
          MENU oRQCYC:MENU_CTA("MENU_CTARUN","UNO");
          TOP PROMPT "Cuentas"; 
          ACTION 1=1

// IIF(COUNT("DPCTA")<=1,EJECUTAR("DPCTAIMPORT"),DPLBX("DPCTAMENU.LBX"))

  oBtn:cToolTip:="Contabilidad"
*/

/*

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\seniat.BMP";
          MENU oRQCYC:MENU_TRIB("MENU_TRIBRUN","UNO");
          TOP PROMPT "Tributos"; 
          ACTION EJECUTAR("BRCALFISDET")

  oBtn:cToolTip:="Calendario Fiscal"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\trabajador.BMP";
          MENU oRQCYC:MENU_NOM("MENU_NOMRUN","UNO");
          TOP PROMPT "Trabajador"; 
          ACTION DPLBX("NMTRABAJADOR.LBX") 

  oBtn:cToolTip:="Trabajadores"
*/

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Salir"; 
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRQCYC:End()

  oBtn:cToolTip:="Cerrar Formulario"

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris),;
                             nCol:=nCol+o:nWidth()})

  DEFINE FONT oFontB  NAME "Tahoma"   SIZE 0, -11  BOLD

  oBar:SetSize(NIL,70,.T.)

  DEFINE FONT oFontF  NAME "Tahoma"   SIZE 0, -10 BOLD

  nLin:=-15 // 45
  nCol:=20
  AEVAL(oBar:aControls,{|o,n|nCol:=nCol+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ nLin+20, nCol COMBOBOX oRQCYC:oPeriodo  VAR oRQCYC:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFontF;
                ON CHANGE oRQCYC:LEEFECHAS();
                WHEN oRQCYC:lWhen 


  ComboIni(oRQCYC:oPeriodo )

  @ nLin+20, nCol+103 BUTTON oRQCYC:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRQCYC:oPeriodo:nAt,oRQCYC:oDesde,oRQCYC:oHasta,-1),;
                         EVAL(oRQCYC:oBtn:bAction),oRQCYC:LEEFECHAS());
                WHEN oRQCYC:lWhen 


  @ nLin+20, nCol+130 BUTTON oRQCYC:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFontF;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRQCYC:oPeriodo:nAt,oRQCYC:oDesde,oRQCYC:oHasta,+1),;
                         EVAL(oRQCYC:oBtn:bAction),oRQCYC:LEEFECHAS());
                 WHEN oRQCYC:lWhen 


  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

  @ nLin+20,nCol+170-8 BMPGET oRQCYC:oDesde  VAR oRQCYC:dDesde;
                  PICTURE "99/99/9999";
                  PIXEL;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oRQCYC:oDesde ,oRQCYC:dDesde);
                  SIZE 76,24;
                  OF   oBar;
                  WHEN oRQCYC:oPeriodo:nAt=LEN(oRQCYC:oPeriodo:aItems) .AND. oRQCYC:lWhen ;
                  FONT oFontF

   oRQCYC:oDesde:cToolTip:="F6: Calendario"

  @ nLin+20, nCol+252+5 BMPGET oRQCYC:oHasta  VAR oRQCYC:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRQCYC:oHasta,oRQCYC:dHasta);
                SIZE 80,23;
                WHEN oRQCYC:oPeriodo:nAt=LEN(oRQCYC:oPeriodo:aItems) .AND. oRQCYC:lWhen ;
                OF oBar;
                FONT oFontF

   oRQCYC:oHasta:cToolTip:="F6: Calendario"

   @ nLin+20,nCol+335+15 BUTTON oRQCYC:oBtn PROMPT " > " SIZE 27,24;
               FONT oFontF;
               OF oBar;
               PIXEL;
               WHEN oRQCYC:oPeriodo:nAt=LEN(oRQCYC:oPeriodo:aItems);
               ACTION oRQCYC:HACERWHERE(oRQCYC:dDesde,oRQCYC:dHasta,oRQCYC:cWhere,.T.);
               WHEN oRQCYC:lWhen

  oBar:Refresh(.T.)


  IF !Empty(oRQCYC:dCbtDesde)

      @ nLin+20,nCol+335+15+35 BUTTON oRQCYC:oBtnCbtDesde PROMPT DTOC(oRQCYC:dCbtDesde) SIZE 80,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION  EJECUTAR("BRWCOMPROBACION",NIL,oRQCYC:dCbtDesde,oRQCYC:dCbtDesde)

        oRQCYC:oBtnCbtDesde:cToolTip:="Fecha del primer asiento actualizado"+CRLF+"Genera balance de comprobación"

      @ nLin+20,nCol+335+15+35+82 BUTTON oRQCYC:oBtnCbtHasta PROMPT DTOC(oRQCYC:dCbtHasta) SIZE 80,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION EJECUTAR("BRDIARIORES",NIL,oRQCYC:cCodSuc,oDp:nIndefinida,oRQCYC:dCbtDesde,oRQCYC:dCbtHasta)

      oRQCYC:oBtnCbtHasta:cToolTip:="Fecha del ultimo asiento"+CRLF+"Genera diario resumido general"


     @ nLin+20,nCol+335+15+35+162 BUTTON oRQCYC:oBtnSucursal PROMPT "SUC("+LSTR(oRQCYC:nSucursal)+")"+oRQCYC:cCodSuc SIZE 90,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION DPLBX("DPSUCURSAL.LBX")

      oRQCYC:oBtnSucursal:cToolTip:="Sucursal Activa "+oRQCYC:cCodSuc+CRLF+"Cantidad de sucursales activas, desactive las innecesarias"




  ELSE

      @ nLin+20,nCol+335+15+35 BUTTON oRQCYC:oBtnCbtDesde PROMPT "SUC:"+oRQCYC:cCodSuc+" sin Asientos" SIZE 160,24;
        FONT oFontF;
        OF oBar;
        PIXEL;
        ACTION DPLBX("DPSUCURSAL.LBX")

  oRQCYC:oBtnCbtDesde:cToolTip:="Sucursal sin Asientos Contables"


  ENDIF

  @ nLin+50,nCol  CHECKBOX oRQCYC:oADD_AUTEJE VAR oRQCYC:ADD_AUTEJE  PROMPT "Auto-Ejecución";
                  WHEN  (AccessField("DPADDON","ADD_AUTEJE",1));
                  FONT oFontB;
                  SIZE 100,20 OF oBar;
                  ON CHANGE EJECUTAR("ADDONUPDATE","ADD_AUTEJE",oRQCYC:ADD_AUTEJE,"ACBL") PIXEL

  oRQCYC:oADD_AUTEJE:cMsg    :="Auto-Ejecución cuando se Inicia el Sistema"
  oRQCYC:oADD_AUTEJE:cToolTip:="Auto-Ejecución cuando se Inicia el Sistema"


  oBtn:=oRQCYC:oADD_AUTEJE

IF .F.

  FOR I=1 TO LEN(aTipIva)

      nContar++

      nPorIva:=aTipIva[I,2]


      IF "Todos"$aTipIva[I,1]

        @ 34-0,530+(60*(nContar-1)) BUTTON oBtn PROMPT aTipIva[I,1] SIZE 60,24;
                                    FONT oFont;
                                    OF oBar;
                                    PIXEL;
                                    ACTION (1=1)

        cAction     :=[DPLBX("DPIVATIP.LBX")] // ,NIL,"TIP_CODIGO]+GetWhere("=",aTipIva[I,1])+[")]


      ELSE

        @ 34-0,530+(60*(nContar-1)) BUTTON oBtn PROMPT aTipIva[I,1]+"%"+LSTR(nPorIva,3) SIZE 60,24;
                                    FONT oFont;
                                    OF oBar;
                                    PIXEL;
                                    ACTION (1=1)

       cAction     :=[DPLBX("DPIVATIP.LBX",NIL,"TIP_CODIGO]+GetWhere("=",aTipIva[I,1])+[")]

     ENDIF

     oBtn:bAction:=BLOQUECOD(cAction)

     IF "Todos"$aTipIva[I,1]

       oBtn:cToolTip:="Todas las Alicuotas"

     ELSE

/*
       oBtn:cToolTip:=oDp:aCtaNombre[I]
 
       IF Empty(oDp:aCtaNombre[I])
          oBtn:bWhen:={||.F.}
          oBtn:ForWhen(.T.)
       ENDIF
*/
     ENDIF

  NEXT I

ENDIF

/*

  @ 34,oBtn:nRight()+20 BUTTON oRQCYC:oBtnBalance  PROMPT " KPI "+ALLTRIM(FDP(oRQCYC:nBalance,"999,999")) OF oBar SIZE 180,24 PIXEL;
                        FONT oFont ACTION  oRQCYC:BUSCARDESCUADRE()

  oRQCYC:oBtnBalance:cToolTip:="Total del Balance"+CRLF+"Clic presenta balance de comprobación"

*/
  // 17/11/2024

  oRQCYC:oWnd:bResized:={||( oRQCYC:oVSplit:AdjLeft(), ;
                              oRQCYC:oHSplit:AdjRight())}

  Eval( oRQCYC:oWnd:bResized )

  oRQCYC:oBrw2:SetColor(0,oRQCYC:nClrPane1)

  BMPGETBTN(oBar)
                       
RETURN .T.

FUNCTION INVACTION(cAction,cTexto,lUpload)
  LOCAL cTitle:=NIL,cWhere:=NIL,aFiles:={},cFileZip,cFileUp,lOk,cDir,nT1:=SECONDS()

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

  IF "ORCSER"$cAction
     RETURN EJECUTAR("REQSERCONT")
  ENDIF

/*
  IF cAction="COMPRAS" 
     EJECUTAR("BRLIBCOMFCH",cWhere,oRQCYC:cCodSuc,oRQCYC:nPeriodo,oRQCYC:dDesde,oRQCYC:dHasta,cTitle,oRQCYC:cCenCos,oRQCYC:cCodCaj,.F.)
  ENDIF

  IF cAction="VENTAS" 
     EJECUTAR("BRLIBCOMFCH",cWhere,oRQCYC:cCodSuc,oRQCYC:nPeriodo,oRQCYC:dDesde,oRQCYC:dHasta,cTitle,oRQCYC:cCenCos,oRQCYC:cCodCaj,.T.)
  ENDIF

  IF cAction="CNDPRESUPUESTO"
    cWhere:=[(LEFT(CTA_CODIGO,1)="4" OR LEFT(CTA_CODIGO,1)="6")]
    EJECUTAR("BRCNDPLAGENXCTA",cWhere,oDp:cSucMain,oDp:nEjercicio,oDp:dFchInicio,oDp:dFchCierre," [General sin Prestadores de Servicios]",STRZERO(0,10))
  ENDIF

  IF cAction="NOMQUINCENAL"
     EJECUTAR("BRMOMXLSQUIN")
  ENDIF

  IF cAction="VENTAS" .OR. Empty(cAction)
//     EJECUTAR("ACBLVENTAS",oRQCYC:cCodSuc,oRQCYC:dDesde,oRQCYC:dHasta,oRQCYC:cDir)
  ENDIF
*/

RETURN .T.

/*
// genera calendario fiscal del periodo
*/
FUNCTION HACERWHERE(dDesde,dHasta)
   EJECUTAR("CREARCALFIS",dDesde,dHasta,.F.,.F.)
RETURN ""

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRQCYC:oPeriodo:nAt,cWhere:=""

  CursorWait()

  oRQCYC:nPeriodo:=nPeriodo

  IF oRQCYC:oPeriodo:nAt=LEN(oRQCYC:oPeriodo:aItems)

     oRQCYC:oDesde:ForWhen(.T.)
     oRQCYC:oHasta:ForWhen(.T.)
     oRQCYC:oBtn  :ForWhen(.T.)

     DPFOCUS(oRQCYC:oDesde)

  ELSE

     oRQCYC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo,oRQCYC:dDesde,oRQCYC:dHasta)

     oRQCYC:oDesde:VarPut(oRQCYC:aFechas[1] , .T. )
     oRQCYC:oHasta:VarPut(oRQCYC:aFechas[2] , .T. )

     oRQCYC:dDesde:=oRQCYC:aFechas[1]
     oRQCYC:dHasta:=oRQCYC:aFechas[2]

     cWhere:=oRQCYC:HACERWHERE(oRQCYC:dDesde,oRQCYC:dHasta,oRQCYC:cWhere,.T.)

     oRQCYC:aData   :=EJECUTAR("CONTAB_DEBERES",oRQCYC:cCodSuc,oDp:dFechaIni,oRQCYC:dHasta)

     oRQCYC:aDataFis:=oRQCYC:LEERDATAFIS(oRQCYC:HACERWHEREFIS(oRQCYC:dDesde,oRQCYC:dHasta,cWhere),NIL,oRQCYC:cServer)

     IF !Empty(oRQCYC:aData)
       oRQCYC:oBrw2:aArrayData:=ACLONE(oRQCYC:aData)
       oRQCYC:oBrw2:Refresh(.T.)
       oRQCYC:oBrw2:GoTop()
     ENDIF

     IF !Empty(oRQCYC:aDataFis)
       oRQCYC:oBrw:aArrayData:=ACLONE(oRQCYC:aDataFis)
       oRQCYC:oBrw:Refresh(.T.)
       oRQCYC:oBrw:GoTop()
     ENDIF

  ENDIF

  oRQCYC:SAVEPERIODO()

RETURN .T.

FUNCTION LEERDATA()
RETURN .T.

FUNCTION LEERDATAFIS(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={},I,nMes:=MONTH(oDp:dFecha)
   LOCAL oDb,aOptions:={}

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cSql:= "  SELECT  "+;
          "  DOR_TIPDOC, "+;
          "  DOR_NUMERO, "+;
          "  DOR_FECHA , "+;
          "  DOR_TIPDES, DOR_TIPREQ,DOR_FCHREQ,DOR_FCHAN1,DOR_FCHAN2,DOR_ESTADO "+;
          "  FROM DPDOCREQ   "+;
          "  WHERE "+cWhere+;
          "  GROUP BY DOR_NUMERO "+;
          "  ORDER BY DOR_NUMERO  "+;
          ""

   aData:=ASQL(cSql,oDb)

/*
   AEVAL(aData,{|a,n| aData[n,2] :=LEFT(CMES(a[1]),3)   ,;
                      aData[n,3] :=LEFT(CSEMANA(a[1]),3),;
                      aData[n,16]:=a[1]-oDp:dFecha})

*/
   DPWRITE("TEMP\BRCALFISDET.SQL",cSql)


   FOR I=1 TO LEN(aData)

      IF LEFT(aData[I,5],1)="M"
         aData[I,5]:="Material"
      ENDIF

      IF LEFT(aData[I,5],1)="S"
         aData[I,5]:="Servicios"
      ENDIF

      IF LEFT(aData[I,9],2)="AP"
         aData[I,9]:="Aprobado"
      ENDIF

      IF LEFT(aData[I,9],2)="AN"
         aData[I,9]:="Nulo"
      ENDIF

      IF LEFT(aData[I,9],2)="RE"
         aData[I,9]:="Rechaza"
      ENDIF

      IF LEFT(aData[I,9],2)="EL"
         aData[I,9]:="Elaboración"
      ENDIF

      IF LEFT(aData[I,9],2)="CE"
         aData[I,9]:="Cerrado"
      ENDIF


   NEXT I

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   IF ValType(oBrw)="O"

      oRQCYC:cSql   :=cSql
      oRQCYC:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      EJECUTAR("BRWCALTOTALES",oBrw,.T.)

      FOR I=1 TO LEN(aData)
        IF ASCAN(aOptions,aData[I,10])=0
          AADD(aOptions,aData[I,10])
        ENDIF
      NEXT I

      ADEPURA(aOptions,{|a,n| Empty(a)})

      AADD(aOptions,"Todos")

      oRQCYC:oOptions:aItems:=ACLONE(aOptions)


      AEVAL(oRQCYC:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRQCYC:SAVEPERIODO()

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

     IF !Empty(oRQCYC:cWhereQry)
       cWhere:=cWhere + oRQCYC:cWhereQry
     ENDIF

     oRQCYC:LEERDATAFIS(cWhere,oRQCYC:oBrw,oRQCYC:cServer)

   ENDIF


RETURN cWhere

/*
// Aqui ejecuta Proceso Automático
*/
FUNCTION RUNCLICK()
  LOCAL cProce:=oRQCYC:oBrw2:aArrayData[oRQCYC:oBrw2:nArrayAt,9]

  oDp:lPanel:=.F.

  IF !Empty(cProce)
    EJECUTAR("DPPROCESOSRUN", cProce )
  ENDIF

RETURN .T

FUNCTION BRWCHANGE()
RETURN .T.

PROCE MENU_NOM(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oRQCYC:cVarName

   AADD(aOption,{"Seleccionar Nómina",""})
   AADD(aOption,{"Pre-Nómina",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Actualizar Nómina (Generar Recibos) ",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Reversar"  ,[COUNT("NMFECHAS")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Variaciones"  ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Liquidaciones",[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Vacaciones"   ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"Ausencias"    ,[COUNT("NMTRABAJADOR")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Conceptos"      ,""})
   AADD(aOption,{"Constantes"     ,""})
   AADD(aOption,{"Feriados"       ,""})
   AADD(aOption,{"Tipos de Nómina",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Importar Trabajadores desde EXCEL",""})



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

              bAction:=cFrm+":lTodos:=.F.,oRQCYC:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_NOMRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF !oDp:lAplNomina
      MsgRun("Aperturando Nómina")
      EJECUTAR("APLNOM")
   ENDIF

   IF nOption=1
      EJECUTAR("NMSELTIPO")    
      RETURN
   ENDIF

   IF nOption=2
      EJECUTAR("PRENOMINA")
      RETURN
   ENDIF

   IF nOption=3
      EJECUTAR("ACTUALIZA")
      RETURN
   ENDIF

   IF nOption=4
      EJECUTAR("REVERSAR")
      RETURN
   ENDIF
 
   IF nOption=5
      EJECUTAR("VARIACIONES")                                                                                                 
   ENDIF

   IF nOption=6
      DPLBX("NMTABLIQ.LBX")
      RETURN
   ENDIF

   IF nOption=7
      DPLBX("NMTABVAC.LBX")
      RETURN
   ENDIF

   IF nOption=8
      DPLBX("NMAUSENCIA.LBX")
      RETURN
   ENDIF

   IF nOption=9
      DPLBX("NMCONCEPTOS.LBX")
      RETURN
   ENDIF

   IF nOption=10
      DPLBX("NMCONSTANTES")
      RETURN
   ENDIF

   IF nOption=11
      DPLBX("DPFERIADOS.LBX")
      RETURN
   ENDIF

   IF nOption=11
      DPLBX("DPFERIADOS.LBX")
      RETURN
   ENDIF

   IF nOption=12
      DPLBX("NMOTRASNM.LBX")                                                                                                  
   ENDIF

   IF nOption=13
      EJECUTAR("NMIMPTRABXLS")                                                                                         
   ENDIF

                                                                                                 
RETURN .T.

FUNCTION MENU_CNF(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oRQCYC:cVarName

   AADD(aOption,{"Seleccionar cuentas para requisiciones",""})
   AADD(aOption,{"Permisos por Usuario",""})
   AADD(aOption,{"Tipos de Documentos" ,""})


/*
   AADD(aOption,{"Crear Empresa",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Integración Contable"  ,""})
   AADD(aOption,{"Uso de las cuentas"    ,""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Importar Asientos desde Excel"  ,""})
   AADD(aOption,{"Trazabilidad de Asientos importados desde excel",""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Importar Compras desde Excel"  ,""})
   AADD(aOption,{"Trazabilidad de Compras importados desde excel",""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Subir integración contable en AdaptaPro Server"  ,".f."})
   AADD(aOption,{"Descargar integración contable desde AdaptaPro Server"  ,".f."})
*/

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

              bAction:=cFrm+":lTodos:=.F.,oRQCYC:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

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

   IF nOption=3
     RETURN DPLBX("DPTIPDOCPROREQCOM.LBX")
   ENDIF
                                                                                                 
RETURN .T.


PROCE MENU_CTA(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oRQCYC:cVarName

   AADD(aOption,{"Código de Integración",""})
   AADD(aOption,{"Ejercicios Contables" ,[]})
   AADD(aOption,{"Centro de Costos"     ,[]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Comprobantes Todos"       ,[COUNT("DPCTA")>0]})
   AADD(aOption,{"Comprobantes Diferidos"   ,[COUNT("DPCTA")>0]})
   AADD(aOption,{"Comprobantes Actualizados",[COUNT("DPCTA")>0]})
   AADD(aOption,{"",""})
   AADD(aOption,{"Actualizar"                    ,""})
   AADD(aOption,{"Reversar"                      ,""})
   AADD(aOption,{"Comprobantes Fijos Repetitivos",""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Contabilizar Compras",""})
   AADD(aOption,{"Contabilizar Ventas" ,""})
   AADD(aOption,{"Contabilizar Nómina" ,""})
   AADD(aOption,{"",""})
   AADD(aOption,{"Balance General"                 ,""})
   AADD(aOption,{"Mayor Analítico"                 ,""})
   AADD(aOption,{"Balance de Comprobación"         ,""})
   AADD(aOption,{"Ganancias y Pérdidas (Resultado)",""})


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

              bAction:=cFrm+":lTodos:=.F.,oRQCYC:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_CTARUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      DPLBX("DPCODINTEGRA.LBX")                                                                                               
      RETURN
   ENDIF

  IF nOption=2
      DPLBX("DPEJERCICIOS.LBX")                                                                                               
      RETURN
   ENDIF

   IF nOption=3
      DPLBX("DPCENCOS.LBX")                                                                                                   
      RETURN
   ENDIF

   IF nOption=4+0
      EJECUTAR("BRASIENTOSEDIT",nil,nil,oDp:nEjercicio,oDp:dFchInicio,oDp:dFchCierre)                                                                                                
      RETURN
   ENDIF


   IF nOption=4+1
      EJECUTAR("DPCBTE","N")                                                                                                  
      RETURN
   ENDIF

   IF nOption=5+1
      EJECUTAR("DPCBTE","S")                                                                                                  
      RETURN
   ENDIF
 
   IF nOption=6+1
      RETURN EJECUTAR("DPCBTEACT")                                                                                                   
   ENDIF

   IF nOption=7+1
      RETURN EJECUTAR("DPCBTEREV")                                                                                                   
   ENDIF

   IF nOption=8+1
      RETURN EJECUTAR("BRCBTFIJORES",NIL,NIL,11)                                                                                     
   ENDIF

   IF nOption=9+1
      RETURN EJECUTAR("DPCONTABCXP")
   ENDIF

   IF nOption=10+1
      RETURN EJECUTAR("DPCONTABCXC")                                                                                                 
   ENDIF
   
   IF nOption=11+1
      RETURN EJECUTAR("NMCONTABILIZAR")                                                                                              
   ENDIF

   IF nOption=12+1
     RETURN EJECUTAR("BRWBALANCEGENERAL",NIL,oRQCYC:dHasta,NIL,NIL,NIL,NIL,NIL,oRQCYC:cCodSuc)
   ENDIF 

   IF nOption=13+1
      RETURN EJECUTAR("BRWMAYORANALITICO",NIL,oRQCYC:dDesde,oRQCYC:dHasta)
   ENDIF

   IF nOption=14+1
      RETURN EJECUTAR("BRWCOMPROBACION",NIL,oRQCYC:dDesde,oRQCYC:dHasta)
   ENDIF

   IF nOption=15+1
     RGO_C11:=oConEje:cCodSuc
     RGO_C11:=IF(!oDp:lSucEmpresa,CTOEMPTY(RGO_C11),RGO_C11)
     RETURN EJECUTAR("BRWGANANCIAYP",NIL,oRQCYC:dDesde,oRQCYC:dHasta,4)
   ENDIF
                                                                                                 
RETURN .T.


PROCE MENU_TRIB(cFunction,cQuien)
   LOCAL oPopFind,I,cBuscar,bAction,cFrm,bWhen
   LOCAL aOption:={},nContar:=0

   cFrm:=oRQCYC:cVarName

   AADD(aOption,{"Gacetas Oficiales",""})
   AADD(aOption,{"Multas y Sanciones",""})
   AADD(aOption,{"Búscar en legislación laboral",""})
   AADD(aOption,{"Búscar en Biblioteca Jurídica",""})
   AADD(aOption,{"",""})
   AADD(aOption,{"XML Retenciones ISLR",""})
   AADD(aOption,{"TXT Retenciones IVA ",""})
   AADD(aOption,{"ARC-Anual"      ,""})
   AADD(aOption,{"Forma 30"       ,""})

   AADD(aOption,{"",""})
   AADD(aOption,{"Tipo de Alícuotas",""})
   AADD(aOption,{"% Alicuotas de IVA",""})
   AADD(aOption,{"% Retenciones ISLR",""})


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

              bAction:=cFrm+":lTodos:=.F.,oRQCYC:"+cFunction+"("+LSTR(nContar)+",["+cQuien+"]"+",["+aOption[I,1]+"]"+")"

              bAction  :=BloqueCod(bAction)

              bWhen    :=aOption[I,2]
              bWhen    :=IF(Empty(bWhen),".T.",bWhen)
              bWhen    :=BloqueCod(bWhen)

              C5MenuAddItem(aOption[I,1],NIL,.F.,NIL,bAction,NIL,NIL,NIL,NIL,NIL,NIL,.F.,NIL,bWhen,.F.,,,,,,,,.F.,)

            ENDIF

          NEXT I

   C5ENDMENU

RETURN oPopFind

FUNCTION MENU_TRIBRUN(nOption,cPar2,cPar3)

   CursorWait()

   DEFAULT cPar3:=""

   IF nOption=1
      EJECUTAR("WEBLEEGACETA")
      DPLBX("DPGACETA.LBX")
      RETURN
   ENDIF

   IF nOption=2
      EJECUTAR("COTMULTASSANCIONES")
      RETURN
   ENDIF

   IF nOption=3
      EJECUTAR("NMLEYTRA")
      RETURN
   ENDIF

   IF nOption=4
      RETURN EJECUTAR("DPLEYES")
   ENDIF

   IF nOption=5
      RETURN EJECUTAR("DPISLRXML",nil,nil,nil,nil,nil,nil,.T.)
   ENDIF

   IF nOption=6
      RETURN EJECUTAR("DPLIBRTITXT",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,.T.)
   ENDIF

   IF nOption=7
      RETURN EJECUTAR("BRARCANUALXCALC")
   ENDIF

   IF nOption=8
      RETURN EJECUTAR("EDITFORMA30",NIL,NIL,"")
   ENDIF

 
   IF nOption=8+1
      RETURN DPLBX("DPIVATIP.LBX")
   ENDIF

   IF nOption=9+1
      RETURN EJECUTAR("DPIVATAB")  
   ENDIF

   IF nOption=10+1
      DPLBX("DPTARIFASRET.LBX")
      RETURN NIL
   ENDIF

 
RETURN .T.

FUNCTION RUNCLICK3()
   LOCAL lFecha:=.T.
RETURN EJECUTAR("BRCALFISDETRUN",lFecha,oRQCYC)

FUNCTION HACERQUINCENA()
   LOCAL aLine  :=oRQCYC:oBrw:aArrayData[oRQCYC:oBrw:nArrayAt]
   LOCAL dDesde :=aLine[1],dHasta

   EJECUTAR("GETQUINCENAFISCAL",dDesde)

   oRQCYC:dFchIni:=oDp:aLine[1]
   oRQCYC:dFchFin:=oDp:aLine[2]

RETURN .T.


FUNCTION SAVEPERIODO()
  LOCAL cFileMem  :="USER\ADDON_ACBL.MEM"
  LOCAL V_nPeriodo:=oRQCYC:nPeriodo
  LOCAL V_dDesde  :=oRQCYC:dDesde
  LOCAL V_dHasta  :=oRQCYC:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

FUNCTION BUSCARDESCUADRE()
  LOCAL cWhere:="MOC_ACTUAL"+GetWhere("<>","N")+" AND ABS(MOC_MONTO)"+GetWhere("=",oRQCYC:nBalance)

  //  IF COUNT("DPASIENTOS",cWhere)

  EJECUTAR("BRWCOMPROBACION",NIL,oRQCYC:dDesde,oRQCYC:dHasta)

RETURN .T.

// EOF
