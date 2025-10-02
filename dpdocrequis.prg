// Programa   : DPDOCREQUIS
// Fecha/Hora : 26/03/2010 23:10:42
// Propósito  : Requisicion de Servicios
// Creado Por : Juan Navas
// Llamado por: Requisicion de Servicios
// Aplicación : Requisicion de Servicios
// Tabla      : DPDOCREQ

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

PROCE MAIN(cTipo,cNum)
  LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,oFont,oFontB,oBtn,cTitle,cScope
  LOCAL nMedidas:=0,cCodUnd:=SPACE(4),aMedidas,oBtn,cWhere,lUndMed:=.F.
  LOCAL nLenUnd :=SQLFIELDLEN("DPUNDMED","UND_CODIGO"),cExcluye:="",cNumero:="",cSiglas:=""
  LOCAL oSayRef,lMaterial:=.F.,lValor:=.F.,cUsuario,cTipoDesc:="Material"
  LOCAL aCoors   :=GetCoors( GetDesktopWindow() )
  LOCAL oDb      :=OpenOdbc(oDp:cDsnData)
  LOCAL nClrText :=0

  DEFAULT cTipo  :="S"

  lValor:=.T.

  IF EJECUTAR("ISFIELDMYSQL",oDb,"DPDOCREQ","DOR_FILMAI",.T.) 
    // oDb:EXECUTE("ALTER TABLE DPDOCPROCTA DROP COLUMN DOC_LBCPAR")
    EJECUTAR("DPCAMPOSADD","DPDOCREQ","DOR_FILMAI","N",06,0,"Registro Digital")
    EJECUTAR("DPTIPDOCPROCREA","REQ","Requisición de Compra","N")
    EJECUTAR("DPCAMPOSADD","DPPERSONAL","PER_CODGER","C",03,0,"Código de gerencia")
  ENDIF
 
//   C035=DOC_FILMAI          ,'N',007,0,'','Digitalización',0,''

  cTitle:=oDp:DPDOCREQ + " ["+;
          ALLTRIM(SAYOPTIONS("DPDOCREQ","DOR_TIPREQ",cTipo))+"]"

  // Lee los Privilegios del Usuario
  EJECUTAR("DPPRIVCOMLEE","REQ",.F.)

  // Font Para el Browse
  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
  DEFINE FONT oFontG NAME "Tahoma"   SIZE 0, -11

  IF COUNT("DPUSUARIOS")>0 .AND. !VALIDUSER(oDp:cUsuario)
     RETURN .F.
  ENDIF

  oReqs:=DOCENC(cTitle,"oReqs","DPDOCREQUIS.EDT")
  oReqs:MOR_CODIGO:=SPACE(20)
  oReqs:cUndMed   :=SPACE(20) // según Formula
  oReqs:nCantid   :=0.00      // según Formula
  oReqs:cTipo     :=cTipo
  oReqs:cCodSuc   :=oDp:cSucursal
  oDp:cAlmItem    :=oDp:cAlmacen

  IF cTipo ="M"
     oReqs:lMaterial:=.T.
     oReqs:cTipoDesc:="Material"
    ELSE
     oReqs:lMaterial:=.F.
     oReqs:cTipoDesc:="Servicio"
  ENDIF

  If Empty(cNum)

     cScope:="DOR_CODSUC"+GetWhere("=",oDp:cSucursal)+;
             " AND DOR_TIPREQ"+GetWhere("=",cTipo)

  ELSE

     cScope:="DOR_CODSUC"+GetWhere("=",oDp:cSucursal)+;
             " AND DOR_TIPREQ"+GetWhere("=",cTipo)+;
             " AND DOR_NUMERO"+GetWhere("=",cNum)
  ENDIF

  
  oReqs:DOR_CODSUC:=oDp:cSucursal
  oReqs:MOR_CANTID:=0 // Cantidad en la Orden de Producción
  oReqs:MOR_CODALM:=oDp:cAlmacen
  oReqs:DOR_FECHA :=oDp:dFecha
  oReqs:DOR_CENCOS:=SPACE(10) // Departamento Origen
  oReqs:nGridCant :=0
  oReqs:cList     :=NIL
  oReqs:SetScope(cScope)
  oReqs:cScopeFind:=cScope
  oReqs:SetTable("DPDOCREQ","DOR_CODSUC,DOR_NUMERO")
  oReqs:cWhereRecord:=cScope
  oReqs:cCodSuc   :=oDp:cSucursal
  oReqs:cUsuario  :=oDp:cUsuario
  oReqs:cSiglas   :=""
  oReqs:cNumero   :=""
  oReqs:lFind     :=.T.
  oReqs:cPreSave   :="PREGRABAR"
  oReqs:cPostSave  :="POSTGRABAR"
  oReqs:cPicture   :=FIELDPICTURE("DPMOVREQ","MOR_CANTID",.T.) // Para Existencia

  oReqs:oMnuOpr    :=NIL
  oReqs:cCodFor    :="" // aFormulas[1]
  oReqs:aData      :={}
  oReqs:nBtnStyle  :=1
  oReqs:lBar       :=.T.
  oReqs:lAutoEdit  :=.F.
  oReqs:cNameInv   :=oDp:xDPINV
  oReqs:cNameAlm   :=oDp:xDPALMACEN
  oReqs:lBtnText   :=.T.
  oReqs:oProducto  :=NIL

  oReqs:nBtnWidth   :=oDp:nBtnWidth  +2 // 10
  oReqs:nBtnHeight  :=oDp:nBarnHeight-9

  IF oDp:l800
    oReqs:nBtnWidth   :=oDp:nBtnWidth +10
    oReqs:nBtnHeight  :=oDp:nBarnHeight-2
    oReqs:lBtnText    :=.T. // oDp:lBtnText
  ENDIF

  oReqs:SetTable("DPDOCREQ","DOR_CODSUC,DOR_NUMERO",;
                           " WHERE DOR_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                           " DOR_TIPREQ"+GetWhere("=",'S'))

  oReqs:cSiglas:=MYSQLGET("DPUSUREQ INNER JOIN DPPERSONAL ON PER_CODIGO=URQ_CODPER "+;
                         " INNER JOIN DPGERENCIA ON GER_CODIGO=PER_CODGER",+;
                         " GER_SIGLAS","URQ_CODUSU"+GetWhere("=",oDp:cUsuario))

  IF EMPTY(oReqs:cSiglas) .AND. COUNT("DPPERSONAL")>1
     MsgAlert("Verifique Gerencia en el Registro del empleado","Aviso")
     RETURN .F.
  ENDIF
 
  //oReqs:SetIncremental("DOR_NUMERO","DOR_CODSUC"+GetWhere("=",oDp:cSucursal),STRZERO(0,10))

  //oReqs:SetMemo("DOR_NUMMEM","Descripción Amplia")
  oReqs:nClrText:=0

  oReqs:lAutoSize  :=(aCoors[4]>1200)  // . AND. ISRELEASE("18.11")  // AutoAjuste 

  // oReqs:Windows(0,0,560,890)

  IF oReqs:lAutoSize 
    aCoors[4]:=MIN(aCoors[4],1920)
    // oReqs:Windows(0,0,600-30	,aCoors[4]-20) 
    // oReqs:Windows(0,0,600-25	,aCoors[4]-20) 
    oReqs:Windows(0,0,aCoors[3]-(130+oDp:oBar:nHeight()),aCoors[4]-20) 
  ELSE
    // oDocCxP:Windows(0,0,600-25,1010)
    oReqs:Windows(0,0,560,890)
  ENDIF

  oReqs:AddBtn("OK1.bmp","Nivel Aprobación 1","(oReqs:nOption=0)",;
                  "EJECUTAR('DPDOCREQAP',oReqs:DOR_CODSUC,;
                                         oReqs:DOR_NUMERO,;
                                         oReqs:cUsuario,;
                                         'REQ',oReqs:DOR_ESTADO,oReqs:DOR_ACT,1,oReqs,oReqs:cTipo)")

  oReqs:AddBtn("OK2.bmp","Nivel Aprobación 2","(oReqs:nOption=0)",;
                  "EJECUTAR('DPDOCREQAP',oReqs:DOR_CODSUC,;
                                         oReqs:DOR_NUMERO,;
                                         oReqs:cUsuario,;
                                         'REQ',oReqs:DOR_ESTADO,oReqs:DOR_ACT,2,oReqs,oReqs:cTipo)")

  oReqs:AddBtn("MAYORANALITICO.bmp","Procesar Requisición","(oReqs:nOption=0)",;
                  "EJECUTAR('DPDOCREQAP',oReqs:DOR_CODSUC,;
                                         oReqs:DOR_NUMERO,;
                                         oReqs:cUsuario,;
                                         'REQ',oReqs:DOR_ESTADO,oReqs:DOR_ACT,4,oReqs,oReqs:cTipo)")

  oReqs:AddBtn("CONTAB.INV.bmp","Recepción de Requisición","(oReqs:nOption=0)",;
                  "EJECUTAR('DPDOCCTAMOVREQ',oReqs:DOR_CODSUC,;
                                         oReqs:DOR_TIPDES,;
                                         'REQ',;
                                         oReqs:DOR_NUMERO,NIL,NIL,oReqs:DOR_ESTADO)")

  oReqs:AddBtn("XSECURITY.bmp","Cierre de Requisición","(oReqs:nOption=0)",;
                  "EJECUTAR('DPDOCREQAP',oReqs:DOR_CODSUC,;
                                         oReqs:DOR_NUMERO,;
                                         oReqs:cUsuario,;
                                         'REQ',oReqs:DOR_ESTADO,oReqs:DOR_ACT,5,oReqs,oReqs:cTipo)")

  @ 1.35, 0 FOLDER oReqs:oFolder ITEMS "Documento","Otros Valores","Descripción";
            OF oReqs:oDlg SIZE 880,61
  
  SETFOLDER(3)
  
  @ 2.8, 1.0 GET oReqs:oDOR_MEMO    VAR oReqs:DOR_MEMO  ;
             MEMO SIZE 80,80; 
             ON CHANGE 1=1;
             WHEN (AccessField("DPDOCREQ","DOR_MEMO",oReqs:nOption);
                    .AND. oReqs:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oReqs:oDOR_MEMO  :cMsg    :="Descripcion Amplia"
    oReqs:oDOR_MEMO  :cToolTip:="Descripcion Amplia"

 
  SETFOLDER(1)
  
  @ 0.2,.1 SAY oSayRef PROMPT "Requisicion #:" RIGHT

  SayAction(oSayRef,{|| IIF( .T. ,NIL , NIL )})

  @ 1.5,.1 SAY "Requerido: "  RIGHT      
  @ 2.1,.1 SAY ALLTRIM(oDp:xDPDPTO)+": "   RIGHT   

  @ 2.1,.1 SAY "Aprob. Adm: "   RIGHT 
  @ 2.1,.1 SAY "Aprob. Fnz: "   RIGHT 

  @ 0.8,20 SAY "Solicitante:" RIGHT 

  @ 0.2,40 SAY "" 
 
  @ 1.5,40 SAY "Fecha:" RIGHT    

  @ 1.5,40 SAY "Visita Técnica:"  RIGHT 


  @ 0.8,06 GET oReqs:oDOR_NUMERO VAR oReqs:DOR_NUMERO;
           WHEN (AccessField("DPDOCREQ","DOR_NUMERO",oReqs:nOption);
                .AND. oReqs:nOption!=0 .AND. .F.)

  @ 3,1.0 BMPGET oReqs:oDOR_FECHA  VAR oReqs:DOR_FECHA  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
            VALID (oReqs:VALFCHREQ() .AND. EJECUTAR("DPVALFECHA",oReqs:DOR_FECHA ,.T.,.T.));
          ACTION LbxDate(oReqs:oDOR_FECHA ,oReqs:DOR_FECHA);
          WHEN (AccessField("DPDOCREQ","DOR_FECHA",oReqs:nOption);
                .AND. oReqs:nOption!=0);
          SIZE 40,NIL

  @ 3,1.0 BMPGET oReqs:oDOR_FCHREQ  VAR oReqs:DOR_FCHREQ  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
            VALID (oReqs:VALFCHREQUE() .AND. EJECUTAR("DPVALFECHA",oReqs:DOR_FCHREQ ,.T.,.T.));
          ACTION LbxDate(oReqs:oDOR_FCHREQ ,oReqs:DOR_FCHREQ);
          WHEN (AccessField("DPDOCREQ","DOR_FCHREQ",oReqs:nOption);
                .AND. oReqs:nOption!=0);
          SIZE 40,NIL

  @ 3,1.0 BMPGET oReqs:oDOR_FCHVIS  VAR oReqs:DOR_FCHVIS  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
            VALID (oReqs:VALFCHVIS() .AND. EJECUTAR("DPVALFECHA",oReqs:DOR_FCHVIS ,.T.,.T.));
          ACTION LbxDate(oReqs:oDOR_FCHVIS ,oReqs:DOR_FCHVIS);
          WHEN (AccessField("DPDOCREQ","DOR_FCHVIS",oReqs:nOption);
                .AND. oReqs:nOption!=0);
          SIZE 40,NIL

  cSql :=" SELECT "+SELECTFROM("DPMOVREQ",.F.)+;
         " ,DPINV.INV_DESCRI "+;
         " FROM DPMOVREQ"+;
         " INNER JOIN DPINV ON MOR_CODIGO=INV_CODIGO "

  @ 1.5,40 SAY "Estado:" RIGHT

  @ 1.5,57 SAY oReqs:oEstado PROMPT EJECUTAR("DPDOCREQEDO",oReqs)

  @ 2.6,01 SAY oReqs:oApN1 PROMPT MYSQLGET("DPDOCREQ INNER JOIN DPUSUREQ ON "+;
                       "DOR_CODUN1=URQ_CODUSU INNER JOIN DPPERSONAL ON PER_CODIGO=URQ_CODPER ",;
                       "PER_NOMBRE","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))

  @ 2.6,01 SAY oReqs:oApFN1 PROMPT MYSQLGET("DPDOCREQ","DOR_FCHAN1","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))

  @ 2.6,01 SAY oReqs:oApN2 PROMPT MYSQLGET("DPDOCREQ INNER JOIN DPUSUREQ ON "+;
                       "DOR_CODUN2=URQ_CODUSU INNER JOIN DPPERSONAL ON PER_CODIGO=URQ_CODPER ",;
                       "PER_NOMBRE","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))

  @ 2.6,01 SAY oReqs:oApFN2 PROMPT MYSQLGET("DPDOCREQ","DOR_FCHAN2","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))
  
  @ 2.6,01 SAY oReqs:oSolicitante PROMPT MYSQLGET("DPPERSONAL",;
                                  "PER_NOMBRE","PER_CODIGO"+GetWhere("=",oReqs:DOR_CODPER))

  @ 2.6,01 SAY oReqs:oDpto        PROMPT MYSQLGET("DPGERENCIA",;
                                  "GER_DESCRI","GER_CODIGO"+GetWhere("=",oReqs:DOR_CODGER))

  @ 1.5,40 SAY "Tipo de "+oReqs:cTipoDesc+":" RIGHT

  @ 2.6,13 GET oReqs:oDOR_TIPDES VAR oReqs:DOR_TIPDES VALID .T.;
           WHEN (AccessField("DPDOCREQ","DOR_TIPDES",oReqs:nOption);
                .AND. oReqs:nOption!=0);
           SIZE 80,10 

  @ 1.5,40 SAY "Procesada:" RIGHT

  @ 2.6,01 SAY oReqs:oApN4 PROMPT MYSQLGET("DPDOCREQ INNER JOIN DPUSUREQ ON "+;
                       "DOR_CODUN4=URQ_CODUSU INNER JOIN DPPERSONAL ON PER_CODIGO=URQ_CODPER ",;
                       "PER_NOMBRE","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))

  @ 2.6,01 SAY oReqs:oApFN4 PROMPT MYSQLGET("DPDOCREQ","DOR_FCHAN4","DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO))

  SETFOLDER(2) 

IF .T.

  oDp:lScrollGetSay:=.F.

  oReqs:oScroll:=oReqs:SCROLLGET("DPDOCREQ","DPDOCREQ.SCG",cExcluye)


  IF oReqs:IsDef("oScroll")
    oReqs:oScroll:SetEdit(.F.)
  ENDIF


  iif( Empty(oDp:cModeVideo),oReqs:oScroll:SetColSize(200,250,700) , oReqs:oScroll:SetColSize(240,370,700))
  oReqs:oScroll:SetColorHead(CLR_BLACK,16763025,oFontB) 
  oReqs:oScroll:SetColor(16775408,0,1,16770764,oFontB) 

  oReqs:oScroll:SetColor(16775408,CLR_BLACK,3,16770764,oFontB) 
  oReqs:oScroll:SetColor(16775408,CLR_BLACK,2,16770764,oFont) 

ENDIF

  SETFOLDER(0)

  @ 0,50 SAY oReqs:oProducto PROMPT SPACE(40)

IF .T.

/*
  01/10/2025, 
  @ 6.8, 1.0 FOLDER oReqs:oFolder ITEMS "Servicio",""
  SETFOLDER( 1)

  oReqs:oFolder:aEnable[1]:=!(oReqs:lMaterial)
  oReqs:oFolder:Refresh(.F.)
*/

  cWhere:=" CRQ_CODSUC "+GetWhere("=",oReqs:cCodSuc)

  cSql :=" SELECT CTA_DESCRI,CEN_DESCRI,PRY_DESCRI,"+SELECTFROM("DPDOCREQCTA",.F.)+;
         " FROM DPDOCREQCTA "+;
         " LEFT JOIN DPCTA       ON CRQ_CODCTA=CTA_CODIGO "+;
         " LEFT JOIN DPCENCOS    ON CRQ_CENCOS=CEN_CODIGO "+; 
         " LEFT JOIN DPPROYECTOS ON CRQ_PROYEC=PRY_CODIGO "

// ? cSql

  oGrid:=oReqs:GridEdit( "DPDOCREQCTA" , oReqs:cPrimary , "CRQ_CODSUC,CRQ_NUMERO" , cSql , cWhere , "CRQ_CODCTA") 

  oGrid:cScript  :="DPDOCREQUIS"
  // oGrid:aSize    :={1,0,850+12-5,160}
  oGrid:aSize    :={200-35,0,IIF(Empty(oDp:cModeVideo),765,905+165-70),IIF(Empty(oDp:cModeVideo),185,285)}

  oGrid:lTotal   :=.T.
  oGrid:bWhen    :={||!Empty(oReqs:DOR_NUMERO).AND.!oReqs:lMaterial}
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.F.
  oGrid:cMetodo  :=""
  oGrid:oDlg     :=oReqs:oDlg //  oFolder:aDialogs[2]

  oGrid:cPostSave   :="VGRIDPOSTSAVE"
  //oGrid:cTotal    :="GRIDTOTAL" 
  oGrid:cLoad       :="VGRIDLOAD"
  oGrid:cPreSave    :="VGRIDPRESAVE"
  oGrid:cPreDelete  :="VGRIDPREDELETE"
  oGrid:cPostDelete :="VGRIDPOSTDELETE"
  oGrid:cItem       :="CRQ_ITEM"
  oGrid:oFontH      :=oFontB // Fuente para los Encabezados
  oGrid:oFont       :=oFont  // Fuente para los Encabezados
  oGrid:bWhen       :="!EMPTY(oReqs:DOR_TIPDES)"

//  oGrid:nClrPane1   :=oDp:nClrPane1 // 13303807
//  oGrid:nClrPane2   :=oDp:nClrPane2 // 11266812
//  oGrid:nRecSelColor:=8454143 //   8584661

  oGrid:lHScroll    :=.T. // Fuente para los Encabezado

  oGrid:nClrPane1   :=oDp:nClrPane1
  oGrid:nClrPane2   :=oDp:nClrPane2
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nClrTextH   :=0
  oGrid:nRecSelColor:=oDp:nRecSelColor  // oDp:nLbxClrHeaderPane // 12578047 // 16763283
  oGrid:nHeaderLines:=2

  oGrid:SetMemo("CRQ_NUMMEM","Descripción Amplia",1,1,100,200)

//  oGrid:nClrPaneH:=8454143
//  oGrid:nClrTextH:=CLR_BLACK

  // Valor Agregado
  oCol:=oGrid:AddCol("CRQ_CODCTA")
  oCol:cTitle   :="Código"


IF .T.

  oCol:bValid   :={||oGrid:VCODCTA(oGrid:CRQ_CODCTA)}
  oCol:cMsgValid:="Cuenta"
  oCol:nWidth   :=080
  oCol:cListBox :="DPCTAREQUI.LBX"
  oCol:bPostEdit:='oGrid:ColCalc("CRQ_CENCOS")'
  oCol:lRepeat  :=.T.
  oCol:nEditType:=EDIT_GET_BUTTON

  // NOMBRE DE LA CUENTA
  oCol:=oGrid:AddCol("CTA_DESCRI")
  oCol:cTitle   :="Nombre"+CRLF+"Cuenta"
  oCol:bWhen    :=".F."

  // Renglon C. Costo
  oCol:=oGrid:AddCol("CRQ_CENCOS")
  oCol:cTitle   :="C.Costo"
  oCol:bValid   :={||oGrid:VCENCOS(oGrid:CRQ_CENCOS)}
  oCol:cMsgValid:="Centro de Costo no Existe"
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),60,60)
  oCol:cListBox :="DPCENCOSREQ.LBX"
  oCol:bWhen        :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:lRepeat  :=.T.
  oCol:nEditType:=EDIT_GET_BUTTON


  // NOMBRE DEL CENTRO DE COSTO
  oCol:=oGrid:AddCol("CEN_DESCRI")
  oCol:cTitle   :="Nombre"+CRLF+oDp:DPCENCOS
  oCol:bWhen    :=".F."


  // Renglon Proyectos
  oCol:=oGrid:AddCol("CRQ_PROYEC")
  oCol:cTitle   :="Proyecto"
  oCol:bValid   :={||oGrid:VPROYEC(oGrid:CRQ_PROYEC)}
  oCol:cMsgValid:="Proyecto No Existe"
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),60,60)
  oCol:cListBox :="DPPROYECTOSREQ.LBX"
  oCol:bWhen        :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:lRepeat   :=.T.

  // NOMBRE PROYECTOS
  oCol:=oGrid:AddCol("PRY_DESCRI")
  oCol:cTitle   :=oDp:DPPROYECTOS
  oCol:nWidth   :=080
  oCol:bWhen    :=".F."


/*
  // Renglon Auxiliar
  oCol:=oGrid:AddCol("CRQ_CODAUX")
  oCol:cTitle   :="Auxiliar"
  oCol:bValid   :={||oGrid:VCODAUX(oGrid:CRQ_CODAUX)}
  oCol:cMsgValid:="Auxiliar no Existe"
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),90,80)
  oCol:cListBox :="DPAUXI.LBX"
  oCol:bWhen        :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:lRepeat   :=.T.
*/

  // Renglon Descripción
  oCol:=oGrid:AddCol("CRQ_DESCRI")
  oCol:cTitle:="Descripción"
  oCol:nWidth:=IIF(Empty(oDp:cModeVideo),440,440)
  oCol:bValid:={|| !Empty(oGrid:CRQ_DESCRI) }
  oCol:bWhen        :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:lRepeat   :=.T.

 // Renglón Medida
  oCol:=oGrid:AddCol("CRQ_UNDMED")
  oCol:cTitle    :="Medida"
  oCol:nWidth    :=IIF(Empty(oDp:cModeVideo),50,50)
  oCol:cListBox  :="DPUNDMED.LBX"
  oCol:bValid    :={ ||oGrid:VUNDMED(oGrid:CRQ_UNDMED) }
  oCol:bWhen     :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:lRepeat  :=.T.
  oCol:nEditType :=EDIT_GET_BUTTON

  // Cantidad Requerida
  oCol:=oGrid:AddCol("CRQ_CANTID")
  oCol:cTitle  :="Cantidad"
  oCol:nWidth  :=115
  oCol:bWhen        :="!EMPTY(oGrid:CRQ_CODCTA)"
  oCol:cPicture:="999,999.999"

ENDIF

  SETFOLDER(0)

 
ENDIF

//  oReqs:oFocus:=oFolder:aDialogs[1]


  oDp:nDif:=(oDp:aCoors[3]-180-oReqs:oWnd:nHeight())

  oReqs:lStart:=.F.

  oReqs:Activate({|| oReqs:INICIO() })

  oReqs:oGrid:=oReqs:aGrids[1]
  oReqs:oGrid:AdjustBtn(.T.)
 
  oReqs:CXPRESTBRW()

  oReqs:oFolder:SetOption(1)

  // oDp:oBtn:=oDocCxP:aGrids[1]:aBtn[1,1]
  oDp:aControls:={} // oDocCxP:oNomCta,oDocCxP:oSayCta,oDocCxP:oSayCen,oDocCxP:oDpCenCos,oDocCxP:oDpCtaSay}

  oReqs:oBar:SetSize(NIL,oReqs:nBtnHeight,.T.)

RETURN oReqs


FUNCTION INICIO()

  IF ValType(oReqs:oScroll)="O"
    oReqs:oScroll:oBrw:SetColor(NIL,16775408)
    oReqs:oScroll:oBrw:Gotop()
  ENDIF

  IF oReqs:cTipo="C"
     oReqs:oEOP_CANTID:oBmp:Hide()
  ENDIF

  IF oReqs:nOption=1
     oReqs:Load()
  ENDIF

  EVAL(oReqs:oWnd:bResized)

RETURN .T.
/*
// Carga los Datos
*/
FUNCTION LOAD()
   LOCAL cCodPer:="",cCodGer:=""

   oReqs:DOR_CODSUC:=oDp:cSucursal

   IF oReqs:nOption=1

     oReqs:cNumero   :=EJECUTAR("DPNUMEROREQ",oDp:cSucursal,oReqs:cSiglas,oDp:dFecha)
     oReqs:DOR_FECHA :=oDp:dFecha
     oReqs:SetValue("DOR_FCHREQ" ,oDp:dFecha   )
     oReqs:SetValue("DOR_NUMERO" ,oReqs:cNumero )
     oReqs:SetValue("DOR_SWCHIT" ,.F.)
     oReqs:DOR_HORA  :=TIME()
     oReqs:nGridCant :=0
     oReqs:DOR_ESTADO:="EL"
     oReqs:DOR_TIPREQ:=oReqs:cTipo
     cCodPer:=MYSQLGET("DPUSUREQ","URQ_CODPER","URQ_CODUSU"+GetWhere("=",oDp:cUsuario))
     cCodGer:=MYSQLGET("DPPERSONAL","PER_CODGER","PER_CODIGO"+GetWhere("=",cCodPer))
     oReqs:SetValue("DOR_CODPER" ,cCodPer )
     oReqs:SetValue("DOR_CODGER" ,cCodGer )
     oReqs:DOR_TIPDOC:="REQ"
     oReqs:DOR_CENCOS:=oDp:cCencos
     oReqs:DOR_ACT   :=1
     oReqs:DOR_USUARI:=oDp:cUsuario
     oDp:cTipoReqs   :=oReqs:cTipo
     oReqs:BUILDNUMERO()

     oReqs:oDOR_TIPDES:ForWhen(.T.)

     DPFOCUS(oReqs:oDOR_TIPDES) // oReqs:oDOR_NUMERO)

   ENDIF
 
   IF oReqs:nOption=3
    IF !EJECUTAR("DPDOCREQDEL",oDoc) // Verifica si Puede ser Modificado
       RETURN .F.
    ENDIF
   ENDIF
   //  01/10/2025 folder innecesario oReqs:oFolder:SetOption( IIF(oReqs:lMaterial, 1, 2) ) 
   oDp:cTipoReqs   :=oReqs:cTipo
   oReqs:oDOR_FECHA :Refresh(.T.)
   oReqs:oDOR_FCHREQ :Refresh(.T.)
   oReqs:oDOR_FCHVIS :Refresh(.T.)
   oReqs:oApN1 :Refresh(.T.)
   oReqs:oApN2 :Refresh(.T.)
   oReqs:oApN4 :Refresh(.T.)
   oReqs:oApFN1 :Refresh(.T.)
   oReqs:oApFN2 :Refresh(.T.)
   oReqs:oApFN4 :Refresh(.T.)
   oReqs:oEstado:Refresh(.T.)
   oReqs:oSolicitante:Refresh(.T.)
   oReqs:oDpto:Refresh(.T.)

//   IF oReqs:nOption=0
//      oReqs:LoadData(0)
//   ENDIF

   
RETURN .T.
FUNCTION VALFCHREQ()
  LOCAL dFchMax

  dFchMax:=MYSQLGET("DPDOCREQ","MAX(DOR_FECHA)")
  IF EMPTY(dFchMax)
     dFchMax:=oReqs:DOR_FECHA
  ENDIF
  IF oReqs:nOption=1 .AND. oReqs:DOR_FECHA < dFchMax
     MsgAlert("Fecha Invalida ","Error de Fecha")
     RETURN .F.
  ENDIF
  IF oReqs:nOption=1  
    oReqs:oDOR_FCHREQ:VarPut(oReqs:DOR_FECHA,.T.)
  ENDIF

RETURN .T.
FUNCTION VALFCHREQUE()

  IF oReqs:nOption=1 .AND. oReqs:DOR_FCHREQ < oReqs:DOR_FECHA
     MsgAlert("Fecha Invalida ","Error de Fecha")
     RETURN .F.
  ENDIF

RETURN .T.
FUNCTION VALFCHVIS()

  IF oReqs:nOption=1 .AND. oReqs:DOR_FCHVIS < oReqs:DOR_FECHA
     MsgAlert("Fecha Invalida ","Error de Fecha")
     RETURN .F.
  ENDIF

RETURN .T.

FUNCTION VALIDUSER(cUsuario)
  LOCAL lResp:=.F.
 
  IF !MYSQLGET("DPUSUREQ","URQ_CODUSU","URQ_CODUSU"+GetWhere("=",cUsuario))==cUsuario
     MsgAlert("Usuario Codigo: "+cUsuario+" Sin Acceso" +CRLF+;
              "Informese con Dpto. de Sistemas","Alerta")
     RETURN .F.
  ENDIF
  lResp:=.T.
RETURN lResp

FUNCTION PREGRABAR(lSaved)
  LOCAL oGrid:=oReqs:aGrids[1]
  LOCAL cNumero:=""

//oReqs:lSaved,"lSaved"

  oReqs:oDOR_TIPDES:ForWhen(.T.)

  IF oReqs:nOption=1 .AND. oReqs:cTipo<>"S" .AND. oGrid:GetTotal("MOR_CANTID")=0 
     MensajeErr("Cantidad no puede ser Igual que Cero")
     RETURN .F.
  ENDIF

  IF oReqs:nOption=1 .AND. EMPTY(oReqs:DOR_TIPDES)
     oReqs:oDOR_TIPDES:MsgErr("Descripcion de la Requisicion Vacia","Alerta")
     RETURN .F.
  ENDIF

//  MDebug("Entro a Pregrabar()... ","DPDOCREQUI")

  IF oReqs:nOption=1
    cNumero:=EJECUTAR("DPNUMEROREQ",oDp:cSucursal,oReqs:cSiglas,oDp:dFecha)
    oReqs:SetValue("DOR_NUMERO" ,oReqs:cNumero )
  ENDIF

  oReqs:oDOR_NUMERO:Refresh(.T.)

  IF !oReqs:DOR_SWCHIT 
     MsgAlert("Renglones sin valores","Data Vacia")
     RETURN .F.
  ENDIF

  oReqs:DOR_TIPO  :=oReqs:cTipo 
  oReqs:DOR_TIPTRA:="R" // Entrada

RETURN .T.

FUNCTION POSTGRABAR()

  LOCAL oTable,cWhere,I,aLine,aData,nTotal,nTotalVa:=0,aIni,nCantOrd:=0,oFrm
  LOCAL cCodDep,cCodInv,cCodFor

  IF oReqs:nOption=1
     DPFOCUS(oReqs:oDOR_NUMERO)
  ENDIF

 
  // Busca el Ultimo Dpto
  cWhere:=" DOR_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
          " DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO)

  IF oReqs:cTipo="A"

    oTable:=OpenTable("SELECT * FROM DPEJECUCIONPROD WHERE "+cWhere)

    IF oTable:RecCount()=0
       oTable:Append()
       cWhere:=NIL
    ENDIF
  
    FOR I=1 TO LEN(oTable:aFields)
       oTable:Replace(oTable:FieldName(I),oReqs:Get(oTable:FieldName(I)))
    NEXT I

    oTable:Replace("EOP_CODDEP" , oReqs:EOP_DEPORG )
    oTable:Replace("EOP_TIPTRA" , "S"             )
    oTable:Replace("EOP_CANTID" , oReqs:EOP_CANTID )
    oTable:Replace("EOP_COSTO"  , 0               )
    oTable:Replace("EOP_VALAGR" , 0               )
    oTable:Replace("EOP_ACT"    , -1              )

    oTable:Commit(cWhere)

    oTable:End()

  ENDIF

  IF oReqs:cTipo="C"

    nCantOrd:=SQLGET("DPORDENPRODUCC","ORP_CANTID","ORP_CODSUC"+GetWhere("=",oReqs:EOP_CODSUC)+" AND "+;
                                                   "ORP_NUMERO"+GetWhere("=",oReqs:EOP_ORDPRO))


    aLine:=EJECUTAR("DPORDPVIEWDEP",oReqs:EOP_CODSUC,oReqs:EOP_ORDPRO , .F. , NIL , .F. )

    aLine:=ATAIL(aLine)

    SQLUPDATE("DPORDENPRODUCC" , {"ORP_ESTADO","ORP_DPTFIN"} , {IIF(aLine[4]=nCantOrd,"C","P"), cCodDep } ,;
                                                  "ORP_CODSUC"+GetWhere("=",oReqs:EOP_CODSUC)+" AND "+;
                                                  "ORP_NUMERO"+GetWhere("=",oReqs:EOP_ORDPRO))

    // Verifica, si la OP está Concluida.

    EJECUTAR("DPORDPRODADDINV",oReqs:EOP_NUMERO,oReqs:EOP_CANTID,oReqs:EOP_FECHA,oReqs:EOP_HORA)

  ENDIF

  // Cierra el Menu de Orden de Produccion
  IF ValType(oReqs:oMnuOpr)="O"
      oReqs:oMnuOpr:Close()
  ENDIF

RETURN .T.


/*
// Carga de data del Grid
*/
FUNCTION GRIDLOAD()
  LOCAL I

  oGrid:XMOR_CANTID:=0
  oGrid:aSeriales  :={}
  oGrid:MOR_APLORG :="R"
  oGrid:nLotes     :=0

  IF oGrid:nOption=1

    FOR I=1 TO 10
      oGrid:Set("MOR_TALL"+STRZERO(I,2),0)
    NEXT I


 
    oGrid:Set("MOR_CODALM" , IIF(Empty(oGrid:MOR_CODALM),oDp:cAlmacen,oGrid:MOR_CODALM))
    oGrid:Set("MOR_CANTID" , 1, .T. )
    oGrid:Set("MOR_INVACT" , 1  ) // Transacción Activa
    oGrid:Set("MOR_LOTE"   , CTOEMPTY(oGrid:MOR_LOTE))
    oGrid:Set("MOR_PRECIO" , 0 )
    oGrid:Set("MOR_FCHVEN" , CTOD(""))
    oGridP:aSeriales:={}

  //  oReqs:GETCODTRAN(oGrid:MOR_CODSUC,oGrid:MOR_CODALM)

  ELSE
 
    oGrid:XMOR_CANTID:=oGrid:MOR_CANTID

  ENDIF

RETURN .T.
FUNCTION GRIDPRESAVE()
   LOCAL nEntSal:=1,cNumero:=""
   // Tipo de Transacción
   oGrid:MOR_CODTRA:="E900"
 
   IF EMPTY(oGrid:MOR_CODTRA)
      MensajeErr("Es necesario Código de Transacción")
      RETURN .F.
   ENDIF
   IF oGrid:MOR_CANTID<=0
      MsgAlert("Cantidad Invalida","Aviso")
      RETURN .F.
   ENDIF
   //?? oGrid:MOR_DOCUME
   // Verificar Cod/transacción.
   //EJECUTAR("DPINVTRANINC",oGrid:MOR_CODTRA)

   nEntSal:=IIF(Left(oGrid:MOR_CODTRA,1)="E" ,  1 , nEntSal )
   nEntSal:=IIF(Left(oGrid:MOR_CODTRA,1)="S" , -1 , nEntSal )

   oGrid:MOR_INVACT:=1
   IF oGrid:cMetodo="C" .AND. oGrid:MOR_INVACT<0  // Salidas de Capas de Costos
       oGrid:SET("MOR_COSTO",oGrid:nCostoLote,.T.)
   ENDIF
  
   oGrid:MOR_APLORG:="R"
   oGrid:MOR_CONTAB:=nEntSal // Contable
   oGrid:MOR_LOGICO:=nEntSal // Lógico
   oGrid:MOR_FISICO:=nEntSal // Físico
   oGrid:MOR_INVACT:=1 // Transacción Actia
   oGrid:MOR_FECHA :=oReqs:DOR_FECHA
   oGrid:MOR_TIPDOC:="REQ"  // Documento de Inventario
   oGrid:MOR_CXUND :=EJECUTAR("INVGETCXUND",oGrid:MOR_CODIGO,oGrid:MOR_UNDMED)
   oGrid:MOR_TIPO  :=oReqs:cTipo      // Producto Individual
   oGrid:MOR_USUARI:=oDp:cUsuario
   oGrid:MOR_TOTAL :=oGrid:MOR_CANTID*oGrid:MOR_COSTO
   oGrid:MOR_CODSUC:=oReqs:DOR_CODSUC
   oGrid:MOR_APLORG:="R"
   oGrid:MOR_DOCUME:=oReqs:DOR_NUMERO
   IF oGrid:nOption=1
      oGrid:MOR_HORA  :=TIME() // oReqs:DOC_HORA 
   ENDIF
   oGrid:oSayOpc   :=oReqs:oProducto
RETURN .T.
FUNCTION PRINTER()
 LOCAL oRep,cReporte:="DPDOCREQ"+oReqs:cTipo,cMotivo:=""
 
/*
   IF oReqs:DOR_ESTADO="EL" .OR. oReqs:DOR_ESTADO="RE"
      cMotivo:="Documento :"+oForm:cTitle+" "+oReqs:DOR_NUMERO+CRLF+;
               "No puede Imprimirse"+CRLF+;
               "Actualice el documento y estará disponible "+CRLF+;
               "para la Impresión "

      MsgAlert(cMotivo,"Aviso")
      RETURN .F.
   ENDIF
*/
   oRep:=REPORTE(cReporte)
   oRep:SetRango(1,oReqs:DOR_FECHA,oReqs:DOR_FECHA)
   oRep:SetRango(2,oReqs:DOR_NUMERO,oReqs:DOR_NUMERO)
  
RETURN .T.
FUNCTION PREDELETE()

   IF oReqs:DOR_ESTADO="CE"
       MensajeErr(oDp:xDPDOCREQ+" "+oReqs:DOR_NUMERO+" ya está Cerrada")
       RETURN .F.
   ENDIF

   IF !MsgNoYes("Desea Anular "+oDp:xDPDOCREQ+" "+oReqs:DOR_NUMERO)
      RETURN .F.
   ENDIF

   SQLUPDATE("DPDOCREQ",{"DOR_ACT","DOR_ESTADO"},;
                               {0,"AN"}               ,;
                               "DOR_CODSUC"+GetWhere("=",oReqs:DOR_CODSUC)+" AND "+;
                               "DOR_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO)+" AND "+;
                               "DOR_TIPDOC='REQ'")
   IF oReqs:cTipo ="M"
      SQLUPDATE("DPMOVREQ","MOR_INVACT",0,"MOR_CODSUC"+GetWhere("=",oReqs:DOR_CODSUC)+" AND "+;
                                          "MOR_DOCUME"+GetWhere("=",oReqs:DOR_NUMERO)+" AND "+;
                                          "MOR_TIPDOC='REQ' AND MOR_APLORG='R' ")
   ENDIF
   IF oReqs:cTipo="S"
      SQLUPDATE("DPDOCREQCTA","CRQ_ACT",0,"CRQ_CODSUC"+GetWhere("=",oReqs:DOR_CODSUC)+" AND "+;
                                              "CRQ_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO)+" AND "+;
                                              "CRQ_TIPDOC='REQ' ")
   ENDIF
   oReqs:DOR_ACT:=0
   oReqs:oEstado:Refresh(.T.)

RETURN .F.
FUNCTION POSTDELETE()
RETURN .T.
FUNCTION GRIDLOAD()
  LOCAL cLista:=""

  IF oGrid:nOption=1
  ENDIF

RETURN NIL
FUNCTION GRIDPOSTSAVE()

   oReqs:oDOR_NUMERO:ForWhen(.T.)

RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
RETURN .T.

FUNCTION GRIDSETSCOPE()
RETURN .T.

FUNCTION GRIDPRINT()
RETURN .T.
// EOF

FUNCTION MORCODIGO(cCodInv)
   LOCAL lRet:=.t.
   LOCAL nExi,nCosto:=0,cEquiv,aItems:={}
   LOCAL oGrid:=oReqs:aGrids[1],aUndMed:={},cAlmacen

   IF EMPTY(oGrid:MOR_CODIGO)
      RETURN .F.
   ENDIF
   IF !ISMYSQLGET("DPINV","INV_CODIGO",oGrid:MOR_CODIGO)

      // BUSCA EL EQUIVALENTE
      cEquiv:=SQLGET("DPEQUIV","EQUI_CODIG","EQUI_BARRA"+GetWhere("=",oGrid:MOR_CODIGO))

      IF Empty(cEquiv)
         RETURN .F.
      ENDIF

      oGrid:GetCol("MOR_CODIGO"):VarPut(cEquiv)

   ENDIF

   // Ubica la Unidad de Medida
   IF oGrid:nOption=1
        aUndMed:=ASQL("SELECT IME_UNDMED,IME_CANTID FROM DPINVMED WHERE IME_CODIGO"+GetWhere("=",oGrid:MOR_CODIGO)+" AND "+;
                                                       "IME_COMPRA='S' ORDER BY IME_CANTID DESC")
        IF LEN(aUndMed)>0
           oGrid:Set("MOR_UNDMED",aUndMed[1,1],.T.)
        ENDIF
    ENDIF
   
   cAlmacen:=MYSQLGET("DPINVUBIFISICA","UXP_CODALM","UXP_CODIGO"+GetWhere("=",oGrid:MOR_CODIGO)+" AND "+;
                                                    "UXP_CODSUC"+GetWhere("=",oDp:cSucursal))

   IF EMPTY(cAlmacen)
      MsgAlert("Producto no Tiene Ubicacion Fisica","Aviso")
      RETURN .F.
   ENDIF
   oGrid:Set("MOR_CODALM",cAlmacen,.T.)

   oGrid:cMetodo:=MYSQLGET("DPINV","INV_METCOS,INV_TALLAS","INV_CODIGO"+GetWhere("=",oGrid:MOR_CODIGO))
   oGrid:lTallas:=.F.
   oGrid:cTallas:=""


   IF !Empty(oDp:aRow) .AND. !Empty(oDp:aRow[2])

      oGrid:lTallas:=.T.
      oGrid:cTallas:=oDp:aRow[2]

   ENDIF
RETURN lRet
// Centro de Costo
FUNCTION MORCENCOS(cCencos)

  IF cCencos=NIL
     RETURN .F.
  ENDIF

  IF !(SQLGET("DPCENCOS","CEN_CODIGO","CEN_CODIGO"+GetWhere("=",oGrid:MOR_CENCOS))==oGrid:MOR_CENCOS)
     RETURN .F.
  ENDIF

  oGrid:cAlmacen:="C. Costo"+":"+SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",cCencos))
  
  oReqs:oProducto:SetText(oGrid:cAlmacen)
  SysRefresh(.T.)

RETURN .T.

// Proyecto
FUNCTION MORPROYEC(cProyecto)
 IF cProyecto=NIL
     RETURN .F.
  ENDIF

  IF !(SQLGET("DPPROYECTOS","PRY_CODIGO","PRY_CODIGO"+GetWhere("=",oGrid:MOR_PROYEC))==oGrid:MOR_PROYEC)
     RETURN .F.
  ENDIF

  oGrid:cAlmacen:="Proyecto"+":"+SQLGET("DPPROYECTOS","PRY_DESCRI","PRY_CODIGO"+GetWhere("=",cProyecto))

  oReqs:oProducto:SetText(oGrid:cAlmacen)
  SysRefresh(.T.)

RETURN .T.

/*
// Valida Unidad de Medida
*/
FUNCTION MORUNDMED(cUndMed)

   LOCAL nCosto:=0,dHasta,cHoraMax,nExi

   // Cuando Modifica, debe Buscar el Costo de su momento

   IF oGrid:nOption!=1
      dHasta  :=oGrid:MOR_FECHA
      cHoraMax:=oGrid:MOR_HORA
   ENDIF

   oGrid:Set("MOR_COSTO",nCosto,.T.)

RETURN .T.

/*
// Construye las Opciones
*/
FUNCTION BuildUndMed(lData)

  LOCAL aItem:={}
  LOCAL oGrid:=oReqs:aGrids[1]

  aItem:=EJECUTAR("INVGETUNDMED",oGrid:MOR_CODIGO,NIL,NIL,oGrid)

  IF EMPTY(oGrid:MOR_UNDMED).AND.!Empty(aItem)
     oGrid:Set("MOR_UNDMED",aItem[1])
  ENDIF

RETURN aItem
FUNCTION SETMEDIDA()
RETURN .T.
// FUNCTION VMOR_UNDMED(cUndMed)
// RETURN .T.

FUNCTION VGRIDLOAD()
RETURN .T.
FUNCTION VGRIDPOSTSAVE()
RETURN .T.
FUNCTION VGRIDPREDELETE()
RETURN .T.
FUNCTION VGRIDPOSTDELETE()
   LOCAL aData:={}

   aData:=ASQL("SELECT * FROM DPDOCREQCTA WHERE CRQ_CODSUC"+GetWhere("=",oReqs:DOR_CODSUC)+;
               " AND CRQ_NUMERO"+GetWhere("=",oReqs:DOR_NUMERO),.T.)

   IF LEN(aData)=0
      oReqs:SetValue("DOR_SWCHIT" ,.F. )
   ENDIF
RETURN .T.

FUNCTION VCODCTA(cCodCta)
  LOCAL lResp:=.F.,cDescri
  LOCAL cWhereC:=EJECUTAR("GETWHERELIKE","DPCTA","CTA_DESCRI",cCodCta,"CTA_CODIGO")
  LOCAL oGrid  :=oReqs:aGrids[1],oCol

  oCol   :=oGrid:GetCol("CRQ_CODCTA")
  oCol:cWhereListBox:="CTA_ACTIVO=1"

  IF COUNT("DPCTA",cWhereC)>1
     oCol:cWhereListBox:="CTA_ACTIVO=1 AND "+cWhereC
     RETURN .F.
  ELSE
     cCodCta:=SQLGET("DPCTA","CTA_CODIGO",cWhereC)
     oGrid:Set("CCD_CODCTA",cCodCta,.T.)
  ENDIF


  IF !ISSQLFIND("DPCTA","CTA_CODIGO"+GetWhere("=",cCodCta))
    RETURN .F.
  ENDIF

  IF !EJECUTAR("ISCTADET",cCodCta , .F. )
    oGrid:GetCol("CCD_CODCTA"):MensajeErr("Cuenta no Acepta Asientos")
    RETURN .F.
  ENDIF

  cDescri:=SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta))

  oGrid:SET("CTA_DESCRI",cDescri,.T.)
  

RETURN .T.
FUNCTION VCENCOS(cCenCos)
  LOCAL lResp:=.F.,cDescri:=""

  IF !ALLTRIM(SQLGET("DPCENCOS","CEN_CODIGO","CEN_CODIGO"+GetWhere("=",cCenCos)))==ALLTRIM(cCenCos)
    RETURN .F.
  ENDIF

  IF !EJECUTAR("ISCENDET",cCenCos , .F. )
    oGrid:GetCol("CCD_CENCOS"):MensajeErr("Centro de Costo no Acepta Asientos")
    RETURN .F.
  ENDIF

  cDescri:=SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",cCenCos))

  oGrid:SET("CEN_DESCRI",cDescri,.T.)
  
RETURN .T.
FUNCTION VPROYEC(cProyec)
  LOCAL lResp:=.F.,cDescri

  IF !ALLTRIM(SQLGET("DPPROYECTOS","PRY_CODIGO","PRY_CODIGO"+GetWhere("=",cProyec)))==ALLTRIM(cProyec)
    RETURN .F.
  ENDIF

  cDescri:=SQLGET("DPPROYECTOS","PRY_DESCRI","PRY_CODIGO"+GetWhere("=",cProyec))

  oGrid:SET("PRY_DESCRI",cDescri,.T.)

RETURN .T.
/*
// Valida Unidad de Medida
*/
FUNCTION VUNDMED(cUndMed)
  LOCAL lRet:=.T.

  lRet:=(cUndMed==SQLGET("DPUNDMED","UND_CODIGO","UND_CODIGO"+GetWhere("=",cUndMed)))

RETURN lRet

FUNCTION VCODAUX(cAux)
  LOCAL lResp:=.F.

  IF !ALLTRIM(SQLGET("DPAUXI","AUX_CODIGO","AUX_CODIGO"+GetWhere("=",cAux)))==ALLTRIM(cAux)
    RETURN .F.
  ENDIF
RETURN .T.
FUNCTION VGRIDPRESAVE()

   IF oGrid:CRQ_CANTID<=0
      MsgAlert("Cantidad Invalida","Aviso")
      RETURN .F.
   ENDIF
   IF EMPTY(oGrid:CRQ_UNDMED)
      MsgAlert("Se requiere Unnidad de Medida","Aviso")
      RETURN .F.
   ENDIF
   IF EMPTY(oGrid:CRQ_CENCOS)
      MsgAlert("Se requiere Centro de Costo","Aviso")
      RETURN .F.
   ENDIF
   IF EMPTY(oGrid:CRQ_CODCTA)
      MsgAlert("Se requiere Codigo de Cuenta","Aviso")
      RETURN .F.
   ENDIF
   IF EMPTY(oGrid:CRQ_PROYEC)
      MsgAlert("Se requiere Codigo de Proyecto","Aviso")
      RETURN .F.
   ENDIF
   IF EMPTY(oGrid:CRQ_DESCRI)
      MsgAlert("Se requiere Descripcion del Renglon","Aviso")
      RETURN .F.
   ENDIF

   
   oReqs:BUILDNUMERO()

   oReqs:SetValue("DOR_SWCHIT" ,.T.)
   oGrid:CRQ_USUARI:=oDp:cUsuario
   oGrid:CRQ_TPTRA:="R"
   oGrid:CRQ_ACT:=1 // Transacción Actia
   oGrid:CRQ_FECHA :=oReqs:DOR_FECHA
   oGrid:CRQ_TIPDOC:="REQ"  // Documento de Rrquisicion
   oGrid:CRQ_CODAUX:="0000000001"
   oGrid:oSayOpc   :=oReqs:oProducto

RETURN .T.


FUNCTION CONSULTAR()

//  EJECUTAR("DPFORMULASCON",oReqs:INV_CODIGO,oReqs:cCodFor,oReqs:nCantid)

RETURN .T.
FUNCTION BUILDNUMERO()
  LOCAL cNumero

  IF oReqs:nOption=1

    cNumero:=EJECUTAR("DPNUMEROREQ",oDp:cSucursal,oReqs:cSiglas,oDp:dFecha)
    oReqs:SetValue("DOR_NUMERO" ,oReqs:cNumero )

    // oReqs:DOR_NUMERO:=SQLINCREMENTAL("DPDOCREQ","DOR_NUMERO","DOR_CODSUC"+GetWhere("=",oReqs:cCodSuc))
    // oReqs:oDOR_NUMERO:Refresh(.T.)
  ENDIF

RETURN .T.

FUNCTION MORALMACE(cCodAlm)

   IF SQLGET("DPALMACEN","ALM_CODIGO","ALM_CODIGO"+GetWhere("=",cCodAlm))!=cCodAlm
      RETURN .F.
   ENDIF
   oDp:cAlmItem:=cCodAlm
RETURN .T.
FUNCTION MORCANTID()
  LOCAL nExi:=0
  LOCAL oGridT:=oReqs:aGrids[1]
  IF oGridT:MOR_CANTID<=0
      MsgAlert("Cantidad Invalida","Aviso")
      RETURN .F.
  ENDIF

RETURN .T.
FUNCTION GETCODTRAN(cCodSuc,cCodAlm)
   LOCAL cCodTra:="E900"
   LOCAL oGridP:=oEjp:aGrids[1]

   oGridP:Set("MOR_CODTRA" , cCodTra, .T.)

RETURN .T.
FUNCION GRID_EXISTENCIA(lShow)
  LOCAL nExiste:=0,dFecha,cHora,oGridP

  dFecha:=oReqs:DOR_FECHA
  cHora :=NIL // TIME() // oReqs:DOC_HORA 

  DEFAULT lShow:=.F.

  oGridP:=oReqs:aGrids[1]

  IF oGridP:nOption=3 .AND. !oReqs:nOption=1
     dFecha:=oGridP:MOR_FECHA
     cHora :=oGridP:MOR_HORA
  ENDIF

  oGridP:nExiste:=nExiste

RETURN nExiste
FUNCTION GRID_COSTO()

   LOCAL nCosto:=0,cHora

   LOCAL oGridT:=oReqs:aGrids[1]

   IF LEFT(oGridT:MOR_CODTRA,1)="S"

      nCosto:=EJECUTAR("INVGETCOSTO"   ,oGridT:MOR_CODIGO ,oGridT:MOV_UNDMED    , oReqs:EOP_CODSUC, oReqs:EOP_FECHA , cHora , oGridT:MOR_CANTID  )

   ELSE

      nCosto:=EJECUTAR("INVGETULTCOS" , oGridT:MOR_CODIGO , oGridT:MOR_UNDMED   , oReqs:EOP_CODSUC , oReqs:EOP_FECHA , cHora )

   ENDIF

   oGridT:Set("MOR_COSTO",nCosto,.T.)

RETURN nCosto

FUNCTION LIST(cWhereEdo,cTitle2)
  LOCAL cWhere:="",dDesde,dHasta
  LOCAL cWhereEdo:=""
  LOCAL nAt:=ASCAN(oReqs:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oReqs:aBtn[nAt,1],NIL)

  DEFAULT cWhereEdo:="",;
          cTitle2  :=""

  cWhere:="DOR_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "DOR_TIPREQ"+GetWhere("=",oReqs:cTipo)

  dHasta:=SQLGETMAX("DPDOCREQ","DOR_FECHA",oReqs:cScope+IF(Empty(cWhereEdo),""," AND ")+cWhereEdo)
  dDesde:=FCHINIMES(dHasta)

  IF !EJECUTAR("CSRANGOFCH","DPDOCREQ",cWhere,"DOR_FECHA",dDesde,dHasta,oBtnBrw,oReqs:cTitle)
      RETURN .T.
  ENDIF

  cWhere:=" DOR_CODSUC"+GetWhere("=",oDp:cSucursal)+;
          " AND DOR_TIPREQ"+GetWhere("=",oReqs:cTipo)+;
          " AND (DOR_FECHA"+GetWhere(">=",oDp:dFchIniDoc)+;
          " AND DOR_FECHA"+GetWhere("<=",oDp:dFchFinDoc)+")"
        
  oDp:nCountReq:=COUNT("DPDOCREQ",cWhere)
  oDp:cWhereReq:=cWhere

  IF oDp:nCountReq > 0 
    oReqs:ListBrw(cWhere,"DPDOCREQ2.BRW",oDp:DPDOCREQ)
  ENDIF
 
RETURN .T.

FUNCTION CXPRESTBRW()
RETURN EJECUTAR("DPDOCREQUISBRW",oReqs)

FUNCTION CANCEL()
   oReqs:nOption:=0
   oReqs:LoadData(0)
RETURN .T.
// EOF

