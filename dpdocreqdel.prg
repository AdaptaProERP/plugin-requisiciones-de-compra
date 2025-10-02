// Programa   : DPDOCREQDEL
// Fecha/Hora : 26/03/2010 00:57:48
// Prop�sito  : Validar si es posible o no Modificar Requisicion
// Aplicaci�n : 08
// Tipo       : STD00000
// Creado Por : Jose Miguel Infante
// Modificado : 
// Observaci�n:

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oForm)
  LOCAL lResp:=.T.,cMotivo:="",cMemo
  LOCAL cAction:=""

  IF ValType(oForm)!="O"
     RETURN .F.
  ENDIF

  cAction :=IIF(oForm:nOption=3,"Modificar",cAction)
  cAction :=IIF(oForm:nOption=4,"Anular"   ,cAction)

  IF !oForm:DOR_ESTADO="EL" 

     cMotivo:="Documento :"+oForm:cTitle+" "+oForm:DOR_NUMERO+CRLF+;
            "No puede "+IIF(oForm:nOption=3,"Modificarse","Anularse")+CRLF+;
            "Actualice el documento y estar� disponible para "+CRLF+;
            "la "+IIF(oForm:nOption=3,"Modificaci�n","Anulaci�n")
  ENDIF
  IF MYSQLGET("DPUSUREQ","URQ_EDITAR","URQ_CODUSU"+GetWhere("=",oDp:cUsuario))
     cMotivo:=""
  ENDIF
  IF !Empty(cMotivo)
     MensajeInfo("No se puede Aplicar: "+CRLF+cMotivo,cAction+" "+oForm:cTitle)
     lResp:=.F.
  ENDIF

RETURN lResp
// EOF
