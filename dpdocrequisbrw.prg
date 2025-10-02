// Programa   : DPDOCREQUISBRW
// Fecha/Hora : 17/08/2021 23:27:28
// Propósito  : Restaurar Parámetros del Resized
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oReqs)
   LOCAL cAdd :="" // LSTR(LEN(oDocCxP:oBrwD:aCols))+"_"+LSTR(LEN(oDocCxP:oBrw:aCols))
   LOCAL cFile:="MYFORMS\"+cFileNoExt(oReqs:cFileEdit)+cAdd+".BRWX"
   LOCAL oIni,cParam,nWidth:=0,nHeight:=oReqs:oWnd:nHeight()

   oReqs:nFolder_nTop   :=oReqs:oFolder:nTop()
   oReqs:nFolder_nLeft  :=oReqs:oFolder:nLeft()
   oReqs:nFolder_nHeight:=oReqs:oFolder:nHeight()

   oReqs:oWnd:bResized:={|oBrw,oDlg| oDlg:=oReqs:oDlg,oBrw:=oReqs:aGrids[1],;
                         oReqs:oDlg:Move(0,0,oReqs:oWnd:nWidth()-10,oReqs:oWnd:nHeight()-10,.T.),;
                         oReqs:oFolder:Move(oReqs:nFolder_nTop,oReqs:nFolder_nLeft,oReqs:oWnd:nWidth()-20,oReqs:nFolder_nHeight,.T.),;
                         oReqs:aGrids[1]:oBrw:Move(200-30,0,oDlg:nWidth()-1,oDlg:nHeight()-(50+200),.T.),;
                         oReqs:aGrids[1]:AdjustBtn(.F.),;
                         oReqs:oProducto:Move(oReqs:aGrids[1]:oBrw:nTop()+oReqs:aGrids[1]:oBrw:nHeight(),300,180,20.t.)}



   /*
   // Está en la Pantalla Principal
   */
/*
   oReqs:oFolder:aDialogs[1]:bResized:={|oDlg| oDlg:=oReqs:oDlg,;
                                               oReqs:aGrids[1]:oBrw:Move(200,0,oDlg:nWidth()-1,oDlg:nHeight()-50,.T.)}
*/

/*
// NO ESTA EN UN FOLDER
   oReqs:oFolder:aDialogs[1]:bResized:={|oDlg| oDlg:=oReqs:oFolder:aDialogs[1],;
                                               oReqs:aGrids[1]:oBrw:Move(200,0,oDlg:nWidth()-1,oDlg:nHeight()-50,.T.)}
*/
/*
   oReqs:oFolder:aDialogs[2]:bResized:={|oDlg| oDlg:=oReqs:oFolder:aDialogs[2],;
                                                 oReqs:oBrwD:Move(0,0,oDlg:nWidth()-1,oDlg:nHeight()-1,.T.)}
*/

   IF !FILE(cFile)

      EVal(oReqs:oWnd:bResized)
      RETURN .T.

   ENDIF

   INI oIni File (cFile)

   oIni:Get( "cAlias", "brwdocs" , "" )

   nWidth :=oIni:Get( "cAlias", "nWidth"  , 0   )
   
   EVal(oReqs:oWnd:bResized)

   oReqs:oWnd:SetSize(nWidth,nHeight,.T.)
   oReqs:oDlg:Refresh(.T.)
   oReqs:oWnd:Refresh(.T.)

   EVal(oReqs:oWnd:bResized)
   EVal(oReqs:oFolder:aDialogs[1]:bResized)

RETURN .T.
// EOF

