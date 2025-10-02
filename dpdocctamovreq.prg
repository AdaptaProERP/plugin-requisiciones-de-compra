// Programa   : DPDOCCTAMOVREQ
// Fecha/Hora : 07/05/2015 17:21:13
// Propósito  : Asignar Movimiento de Productos Requisiones de Servicios
// Creado Por : José Miguel Infante
// Llamado por: DPDOCREQUIS
// Aplicación : Ventas
// Tabla      : DPDOCREQCTA


#INCLUDE "DPXBASE.CH"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cCodSuc,cTipDes,cTipDoc,cNumero,lEdit,cTitle,cEstado)
  LOCAL cSql,aData,lNivel4:=.F.
  LOCAL oBrw,oCol,oFont,oFontG,oFontB,oSayRef,oTable,oBtn,cWhere
  
  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="REQ",;
          cNumero:="DI-1102005",;
          lEdit  :=.T.,;
          cTipDes:="Requisicón de Compra de Servicios",;
          cEstado:="EL"

  cWhere:=" WHERE CRQ_CODSUC"+GetWhere("=",cCodSuc)+;
          "   AND CRQ_TIPDOC"+GetWhere("=",cTipDoc)+;
          "   AND CRQ_NUMERO"+GetWhere("=",cNumero)

  cSql:=" SELECT CRQ_ITEM,CRQ_DESCRI,CRQ_CANTID,CRQ_EXPORT,CRQ_CANTID-CRQ_EXPORT AS FALTA,CRQ_PRECIB "+;
        " FROM DPDOCREQCTA "+;
        cWhere+;
        " HAVING CRQ_EXPORT<=CRQ_CANTID "+;
        " ORDER BY CRQ_ITEM " 

  aData:=ASQL(cSql)
 
  lNivel4:=MYSQLGET("DPUSUREQ","URQ_NIVEL4","URQ_CODUSU"+GetWhere("=",oDp:cUsuario))

  IF EMPTY(aData)
     MensajeErr("Es Necesario Definir los Tipos de Documentos ")
     RETURN .F.
  ENDIF

  DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

  DPEDIT():New("Actualiza Cantidad Recibida de Requisiciones  de Servicios","DPDOCCTAMOVREQ.EDT","oActreqs",.T.)

  oActreqs:aData     :=ACLONE(aData)
  oActreqs:cNombre   :=cTipDes
  oActreqs:lAcction  :=.F.
  oActreqs:cWhere    :=cWhere
  oActreqs:cCodigo   :=cCodigo
  oActreqs:cNumero   :=cNumero
  oActreqs:cTipDes   :=cTipDes
  oActreqs:nEdit     :=0
  IF cEstado="AP"
     oActreqs:nEdit     :=IF(lNivel4,1,0)
  ENDIF

  @ 4,1 SAY "Número:"  RIGHT

  @ 5,1 SAY oActreqs:cNumero
  
  @ 1,1 SAY "Descripción:" 
  @ 2,1 SAY oActreqs:cTipDes

  @1, 1 SBUTTON oBtn ;
        SIZE 45, 20;
        FILE "BITMAPS\XSALIR.BMP" NOBORDER;
        LEFT PROMPT "Cerrar";
        COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
        ACTION (oActreqs:Close()) CANCEL

  oBtn:lCancel :=.T.
  oBtn:cToolTip:="Cancelar y Cerrar Formulario "
  oBtn:cMsg    :=oBtn:cToolTip

  oBrw:=TXBrowse():New( oActreqs:oDlg )

  oBrw:SetArray( aData, .F. )
  oBrw:lHScroll            := .F.
  oBrw:lFooter             := .F.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 1

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oBrw:CreateFromCode()

  oBrw:aCols[1]:cHeader:="Item"
  oBrw:aCols[1]:nWidth :=60

  oBrw:aCols[2]:cHeader:="Descripción"
  oBrw:aCols[2]:nWidth :=410

  oBrw:aCols[3]:cHeader   :="Cantidad"
  oBrw:aCols[3]:nWidth    :=80
  oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT 
  oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT 
  oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT 
  oBrw:aCols[3]:bStrData:={|nMonto|nMonto:=oActreqs:oBrw:aArrayData[oActreqs:oBrw:nArrayAt,3],FDP(nMonto,'999,999,999.99')}

  oBrw:aCols[4]:cHeader   :="Recibido"
  oBrw:aCols[4]:nWidth    :=80
  oBrw:aCols[4]:nEditType :=oActreqs:nEdit
  oBrw:aCols[4]:bEditBlock:={||oActreqs:EditRecib(4)}
  oBrw:aCols[4]:cEditPicture:='999,999,999.99'
  oBrw:aCols[4]:bOnPostEdit:={|oCol,uValue|oActreqs:ValRecib(oCol,uValue,4)}
  oBrw:aCols[4]:nDataStrAlign:= AL_RIGHT 
  oBrw:aCols[4]:nHeadStrAlign:= AL_RIGHT 
  oBrw:aCols[4]:nFootStrAlign:= AL_RIGHT 
  oBrw:aCols[4]:bStrData     :={|nMonto|nMonto:=oActreqs:oBrw:aArrayData[oActreqs:oBrw:nArrayAt,4],;
                                                 TRAN(nMonto,"999,999,999.99")}  
  oBrw:aCols[4]:cPicture:='999,999,999.99' 

  oBrw:aCols[5]:cHeader   :="Faltante"
  oBrw:aCols[5]:nWidth    :=80
  oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT 
  oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT 
  oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT 
  oBrw:aCols[5]:bStrData:={|nMonto|nMonto:=oActreqs:oBrw:aArrayData[oActreqs:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999.99')}

  oBrw:aCols[6]:cHeader:="Recibido por:"
  oBrw:aCols[6]:nWidth :=150
  oBrw:aCols[6]:nEditType :=oActreqs:nEdit
  oBrw:aCols[6]:bOnPostEdit:={|oCol,uValue|oActreqs:ValPRecib(oCol,uValue,6)}
  oBrw:aCols[6]:lRepeat :=.T.

  oBrw:DelCol(7)

  oBrw:bClrHeader:= {|| {0,14671839 }}
  oBrw:bClrFooter:= {|| {0,14671839 }}


  oBrw:bClrStd   :={|oBrw,nMto,nClrText|oBrw:=oActreqs:oBrw,;
                               nClrText:=0,;
                              {nClrText, iif( oBrw:nArrayAt%2=0, 15790320, 16382457 ) } }

  oBrw:bChange:={||oActreqs:ViewRecib()}
  oBrw:SetFont(oFont)

  oActreqs:oBrw:=oBrw
  oActreqs:Activate({||oActreqs:LeyBar(oActreqs)})

  DpFocus(oBrw)

  STORE NIL TO oBrw,oDlg

RETURN NIL

/*
// Coloca la Barra de Botones
*/
FUNCTION LEYBAR(oActreqs)

  oActreqs:oBrw:SetColor(0,15790320)
  oActreqs:oBrw:nColSel:=4
  oActreqs:ViewRecib()

  SysRefresh(.t.)

RETURN .T.

FUNCTION EditRecib(nCol)
   LOCAL oBrw  :=oActreqs:oBrw,oLbx
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]


   oActreqs:lAcction  :=.T.

   SysRefresh(.t.)

RETURN uValue

FUNCTION ValRecib(oCol,uValue,nCol)
 LOCAL cItem,oTable,cWhere:="",cCtaOld:="",nCantid:=0
 LOCAL nValor:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,4]

 cItem:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,1]
 IF uValue < 0
    RETURN .F.
 ENDIF
 oActreqs:lAcction  :=.F.
 
 nCantid:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,3]
 IF uValue > nCantid
    MsgAlert("Cantidad Recibida no Puede Superar a la Cantidad Solicitada","Alerta")
    RETURN .F.
 ENDIF
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,4]:=uValue
 oCol:VarPut(uValue,.T.)

 SQLUPDATE("DPDOCREQCTA","CRQ_EXPORT",uValue,oActreqs:cWhere+" AND CRQ_ITEM"+GetWhere("=",cItem))
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,5]:=nCantid-uValue
 oActreqs:oBrw:DrawLine(.T.)
 oActreqs:oBrw:KeyBoard(VK_DOWN)
 oActreqs:oBrw:Refresh()
 //SysRefresh(.t.)

RETURN .T.
FUNCTION ValPRecib(oCol,uValue,nCol)
 LOCAL cItem,oTable,cWhere:="",cCtaOld:="",nCantid:=0
 LOCAL cValor:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,6]
 LOCAL nMaximo:=0

 cItem:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,1]
 nMaximo:=LEN(oCol:oBrw:aArrayData)
 
 oActreqs:lAcction  :=.F.
 
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,6]:=uValue
 oCol:VarPut(uValue,.T.)

 SQLUPDATE("DPDOCREQCTA","CRQ_PRECIB",uValue,oActreqs:cWhere+" AND CRQ_ITEM"+GetWhere("=",cItem))
 SQLUPDATE("DPDOCREQCTA","CRQ_FRECIB",oDp:dFecha,oActreqs:cWhere+" AND CRQ_ITEM"+GetWhere("=",cItem))

 oActreqs:oBrw:DrawLine(.T.)
 oActreqs:oBrw:KeyBoard(VK_DOWN)
 IF  oActreqs:oBrw:nArrayAt < nMaximo
    oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt+1,6]:=uValue
 ENDIF

 oActreqs:oBrw:Refresh()
 //SysRefresh(.t.)
RETURN .T.
FUNCTION ViewRecib()
 LOCAL nCol:=4
 LOCAL oBrw:=oActreqs:oBrw,uValue,nCol:=oBrw:nColSel

 uValue :=oBrw:aArrayData[oBrw:nArrayAt,nCol]
 
RETURN .T.

FUNCTION QUITAR()
RETURN .T.

// EOF









