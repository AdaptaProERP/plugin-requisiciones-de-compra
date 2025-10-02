// Programa   : DPDOCREQAP 
// Fecha/Hora : 25/03/2010 17:15:32
// Propósito  : Aprobacion de Requisicion de Compras
// Aplicación : Requisicion de Compras
// Tipo       : STD00000
// Creado Por : José Miguel Infante
// Observación:
#include "dpxbase.ch"

PROCE MAIN(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel,oReq,cTipo)
  LOCAL I,aData:={},cSql,oTable,cWhere:="",lNivel1:=.F.,lNivel2:=.F.,cNombre:="",lNivel4:=.F.
  LOCAL lNivel5:=.F.

  DEFAULT cCodSuc :=STRZERO(1,6),;
          cNumero :=STRZERO(1,10),;
          cUsuario:=STRZERO(1,3),;
          cTipDoc :="REQ",;
          cEstado :="CE",;
          nAct    :=0,;
          cTipo   :="S"
  
  IF EMPTY(cEstado) .OR. nAct=0
     RETURN .F.
  ENDIF
  lNivel1:=MYSQLGET("DPUSUREQ","URQ_NIVEL1","URQ_CODUSU"+GetWhere("=",cUsuario))
  lNivel2:=MYSQLGET("DPUSUREQ","URQ_NIVEL2","URQ_CODUSU"+GetWhere("=",cUsuario))
  lNivel4:=MYSQLGET("DPUSUREQ","URQ_NIVEL4","URQ_CODUSU"+GetWhere("=",cUsuario))
  lNivel5:=MYSQLGET("DPUSUREQ","URQ_NIVEL4","URQ_CODUSU"+GetWhere("=",cUsuario))
  cNombre:=MYSQLGET("DPUSUREQ INNER JOIN DPPERSONAL ON PER_CODIGO=URQ_CODPER",+;
                    "PER_NOMBRE","URQ_CODUSU"+GetWhere("=",cUsuario))

  IF !lNivel1 .AND. !lNivel2 .AND. (nNIvel=1.OR.nNivel=2)
     MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
              " Sin Autorización para Aprobación Nivel: "+ALLTRIM(STR(nNivel))+CRLF+;
              " de la Requisición #: "+cNumero+CRLF+CRLF+;
              " Comuniquese con Departamento de Sistemas "+CRLF+;
              " Será Auditado el Acceso Indebido","Alerta de Seguridad")

    
     AUDITAR("APNU" , NIL ,"DPDOCREQAP" , "Usuario: "+cUsuario+" - "+cNombre+" Nivel: "+STR(nNivel))
     RETURN .F.
  ENDIF
  IF !lNivel4 .AND. nNivel=4
     MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
              " Sin Autorización para Procesar La Requisición #: "+cNumero+CRLF+CRLF+;
              " Comuniquese con Departamento de Sistemas "+CRLF+;
              " Será Auditado el Acceso Indebido","Alerta en Procesar Req.")
    
     AUDITAR("APNU" , NIL ,"DPDOCREQAP" , "Usuario: "+cUsuario+" - "+cNombre+" Nivel: "+STR(nNivel))
     RETURN .F.
  ENDIF
  IF !lNivel5 .AND. nNivel=5
     MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
              " Sin Autorización para Cerrar La Requisición #: "+cNumero+CRLF+CRLF+;
              " Comuniquese con Departamento de Sistemas "+CRLF+;
              " Será Auditado el Acceso Indebido","Alerta en Procesar Req.")
    
     AUDITAR("APNU" , NIL ,"DPDOCREQAP" , "Usuario: "+cUsuario+" - "+cNombre+" Nivel: "+STR(nNivel))
     RETURN .F.
  ENDIF
  IF nNivel = 1 .AND. lNivel1
    IF !cEstado="EL"
       MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
                " Verifique el Estado de la Requisicion" +" No.:"+cNumero,"Aviso")
       RETURN .F.
     ENDIF
     IIF(MSGYESNO("Desea Aprobar Nivel 1 Requisicion No.: "+;
        cNumero+"?","Aprobación..."),NIVEL1(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel),NIL)
  ENDIF
  IF nNivel = 2 .AND. !cEstado="RE"
    MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
              " Sin Autorización para Aprobación" +CRLF+;
              " Será Auditado el Acceso Indebido","Alerta")
    
     AUDITAR("APNU" , NIL ,"DPDOCREQAP" , "Usuario: "+cUsuario+" - "+cNombre+" Nivel: "+STR(nNivel))
  ENDIF
  IF nNivel = 2 .AND. lNivel2 .AND. cEstado ="RE"
    IIF(MSGYESNO("Desea Aprobar Nivel 2 Requisicion No.: "+;
        cNumero+"?","Aprobación..."),NIVEL2(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel),NIL)
  ENDIF
  IF nNivel = 4 .AND. lNivel4
    IF !cEstado="AP"
       MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
                " Verifique el Estado de la Requisicion" +" No.:"+cNumero,"Aviso")
       RETURN .F.
     ENDIF
     IIF(MSGYESNO("Desea Procesar (Cerrar) La Requisicion No.: "+;
        cNumero+"?","Aprobación..."),NIVEL4(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel,cTipo),NIL)
  ENDIF
  IF nNivel = 5 .AND. lNivel5
    IF !cEstado="AP"
       MsgAlert(" Usuario : "+cUsuario+" - "+cNombre+CRLF+;
                " Verifique el Estado de la Requisicion" +" No.:"+cNumero,"Aviso")
       RETURN .F.
     ENDIF
     IIF(MSGYESNO("Desea Cerrar La Requisicion No.: "+;
        cNumero+", para no Gestionar más Compras?","Aprobación..."),;
        NIVEL5(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel,cTipo),NIL)
  ENDIF
//Nivel de Aprobacion Nivel 1
FUNCTION NIVEL1(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel)

 SQLUPDATE("DPDOCREQ","DOR_ESTADO","RE","DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                        "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                        "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                        "DOR_ESTADO"+GetWhere("=",cEstado))

 SQLUPDATE("DPDOCREQ","DOR_CODUN1",cUsuario,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                            "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                            "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                            "DOR_ESTADO"+GetWhere("=",'RE'))

 SQLUPDATE("DPDOCREQ","DOR_FCHAN1",oDp:dFecha,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                              "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                              "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                              "DOR_ESTADO"+GetWhere("=",'RE'))


 //MensajeErr(" Requisición No.: "+cNumero+" Aprobada Nivel 1","Proceso Finalizado")
   
   oReq:oApN1  :Refresh(.T.)
   oReq:oApN2  :Refresh(.T.)
   oReq:oApFN1 :Refresh(.T.)
   oReq:oApFN2 :Refresh(.T.)
   oReq:SET("DOR_ESTADO","RE",.T.)
   oReq:oEstado:Refresh(.T.)

RETURN .T.
//Nivel de Aprobacion Nivel 2
FUNCTION NIVEL2(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel)
 SQLUPDATE("DPDOCREQ","DOR_ESTADO","AP","DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                        "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                        "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                        "DOR_ESTADO"+GetWhere("=",cEstado))

 SQLUPDATE("DPDOCREQ","DOR_CODUN2",cUsuario,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                            "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                            "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                            "DOR_ESTADO"+GetWhere("=",'AP'))

 SQLUPDATE("DPDOCREQ","DOR_FCHAN2",oDp:dFecha,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                              "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                              "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                              "DOR_ESTADO"+GetWhere("=",'AP'))


 //MensajeErr(" Requisición No.: "+cNumero+" Aprobada Nivel 2","Proceso Finalizado")

   oReq:oApN1  :Refresh(.T.)
   oReq:oApN2  :Refresh(.T.)
   oReq:oApFN1 :Refresh(.T.)
   oReq:oApFN2 :Refresh(.T.)
   oReq:SET("DOR_ESTADO","AP",.T.)
   oReq:oEstado:Refresh(.T.)

RETURN .T.
FUNCTION NIVEL4(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel,cTipo)
   LOCAL cWhere:="",oTable,cSql:="",cWhereDet:=""

  IF MsgYesNo("Desea Cambiar el Status de la Requisición #"+cNumero+" A PROCESADA?"+CRLF+CRLF+;
               "Recuerde que este proceso actualizará todos los Ítem como Recibidos"+CRLF+;
               "De no Ser Así se recuerda que debe recepcionar cada Ítem Recibido"+CRLF+;
               "y Posteriormente CERRARLA por la Opción de Procesos","Desea Procesar")

     SQLUPDATE("DPDOCREQ","DOR_ESTADO","PR","DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                            "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                            "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                            "DOR_ESTADO"+GetWhere("=",cEstado))

     SQLUPDATE("DPDOCREQ","DOR_CODUN4",cUsuario,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                            "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                            "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                            "DOR_ESTADO"+GetWhere("=",'PR'))

     SQLUPDATE("DPDOCREQ","DOR_FCHAN4",oDp:dFecha,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                              "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                              "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                              "DOR_ESTADO"+GetWhere("=",'PR'))
    IF cTipo="S"
     cWhere:="CRQ_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "CRQ_NUMERO"+GetWhere("=",cNumero)+" AND "+;
             "CRQ_TIPDOC"+GetWhere("=",cTipDoc)

     cSql:=" SELECT CRQ_ITEM,CRQ_CANTID "+;
           " FROM DPDOCREQCTA "+;
           " WHERE "+cWhere

     oTable:=OpenTable(cSql,.T.)

     WHILE !oTable:Eof()
        cWhereDet:=cWhere+" AND CRQ_ITEM"+GetWhere("=",oTable:CRQ_ITEM)
        IF !EMPTY(cWhereDet)
           SQLUPDATE("DPDOCREQCTA","CRQ_EXPORT",oTable:CRQ_CANTID,cWhereDet)
        ENDIF

        oTable:DbSkip()
     ENDDO

    ENDIF
    IF cTipo="M"
     cWhere:="MOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "MOR_DOCUME"+GetWhere("=",cNumero)+" AND "+;
             "MOR_TIPDOC"+GetWhere("=",cTipDoc)

     cSql:=" SELECT MOR_CODIGO,MOR_ITEM,MOR_CANTID "+;
           " FROM DPMOVREQ "+;
           " WHERE "+cWhere

     oTable:=OpenTable(cSql,.T.)

     WHILE !oTable:Eof()
        cWhereDet:=cWhere+" AND MOR_ITEM  "+GetWhere("=",oTable:MOR_ITEM)+;
                         +" AND MOR_CODIGO"+GetWhere("=",oTable:MOR_CODIGO)
        IF !EMPTY(cWhereDet)
           SQLUPDATE("DPMOVREQ","MOR_EXPORT",oTable:MOR_CANTID,cWhereDet)
        ENDIF

        oTable:DbSkip()
     ENDDO

    ENDIF
   ENDIF

   oReq:oApN4  :Refresh(.T.)
   oReq:oApFN4 :Refresh(.T.)
   oReq:SET("DOR_ESTADO","PR",.T.)
   oReq:oEstado:Refresh(.T.)

RETURN .T.
//Nivel de Aprobacion Nivel 5
FUNCTION NIVEL5(cCodSuc,cNumero,cUsuario,cTipDoc,cEstado,nAct,nNivel)

IF MsgYesNo("Desea Cambiar el Status de la Requisición #"+cNumero+" A CERRADA?"+CRLF+CRLF+;
               "Recuerde que este proceso no Permitirá más Gestiones de Compras,"+CRLF+;
               "y cada Ítem Recibido quedará según lo recibido hasta el Momento."+CRLF+;
               "Posteriormente de CERRARDA No podrá Aperturarse nuevamente","Desea Hacer el Cierre")

   SQLUPDATE("DPDOCREQ","DOR_ESTADO","CE","DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                        "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                        "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                        "DOR_ESTADO"+GetWhere("=",cEstado))

   SQLUPDATE("DPDOCREQ","DOR_CODCIE",cUsuario,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                            "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                            "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                            "DOR_ESTADO"+GetWhere("=",'CE'))

   SQLUPDATE("DPDOCREQ","DOR_FCHCIE",oDp:dFecha,"DOR_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                              "DOR_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                              "DOR_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                              "DOR_ESTADO"+GetWhere("=",'CE'))


   oReq:SET("DOR_ESTADO","CE",.T.)
   oReq:oEstado:Refresh(.T.)

ENDIF


RETURN .T.

