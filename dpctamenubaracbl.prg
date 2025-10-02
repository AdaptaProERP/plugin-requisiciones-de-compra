// Programa   : DPCTAMENUBARACBL
// Fecha/Hora : 03/08/2023 04:33:54
// Propósito  : Agrega Controles en la Barra de Botones
// Creado Por : Juan Navas
// Llamado por: DPLBX("DPCTAMENU.LBX")
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oLbx)
  LOCAL aCtaBg:={oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4,oDp:cCtaCo1,oDp:cCtaCo2,;
                oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}
  LOCAL I,oBtn,oFont,cAction
  LOCAL nLastKey:=13,oCol,nContar:=0
  LOCAL nCuantos

  EJECUTAR("GETCTAUTIL")

  IF Empty(oDp:cCtaUti)
    ADEPURA(aCtaBg,{|a,n| Empty(a) }) // .OR. ALLTRIM(a)=ALLTRIM(oDp:cCtaUti)})
  ELSE
    ADEPURA(aCtaBg,{|a,n| Empty(a) .OR. ALLTRIM(a)=ALLTRIM(oDp:cCtaUti)})
  ENDIF

  IF oLbx=NIL
     RETURN .T.
  ENDIF

  DEFAULT oDp:aCtaNombre:={}

  IF Empty(oDp:aCtaNombre) 
     oDp:aCtaNombre:={}
     AEVAL(aCtaBg,{|a,n| AADD(oDp:aCtaNombre,ALLTRIM(SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",a))))})
  ENDIF

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD 

  oLbx:oBar:SetSize(NIL,90,.T.)

  FOR I=1 TO LEN(aCtaBg)

     nCuantos:=COUNT("DPCTA","LEFT(CTA_CODIGO,1)"+GetWhere("=",aCtaBg[I])+" AND CTA_REQUI=1")

     IF nCuantos>1 .AND. ISSQLFIND("DPCTA","LEFT(CTA_CODIGO,1)"+GetWhere("=",aCtaBg[I]))

      nContar++

      aCtaBg[I]:=IF(!Empty(oDp:cCtaUti) .AND. ALLTRIM(aCtaBg[I])=ALLTRIM(oDp:cCtaUti),"RE",aCtaBg[I])


      @ 44+18,20+(35*(nContar-1)) BUTTON oBtn PROMPT aCtaBg[I] SIZE 27,24;
                        FONT oFont;
                        OF oLbx:oBar;
                        PIXEL;
                        ACTION (1=1)

     oBtn:CARGO  :=oLbx // Copia del Boton
     cAction     :=[EJECUTAR("DPCTALBXFIND",]+GetWhere("",aCtaBg[I])+[)]

     oBtn:bAction:=BLOQUECOD(cAction)

     IF Empty(aCtaBg[I])

       oBtn:cToolTip:="Restaurar Todas las Cuentas"

     ELSE

       oBtn:cToolTip:=oDp:aCtaNombre[I]
 
       IF Empty(oDp:aCtaNombre[I])
          oBtn:bWhen:={||.F.}
          oBtn:ForWhen(.T.)
       ENDIF

     ENDIF

     IF aCtaBg[I]="RE"
        oBtn:cToolTip:="Resultado del Ejercicio "+oDp:cCtaUti
     ENDIF

   ENDIF

  NEXT I

RETURN .T.
// EOF

