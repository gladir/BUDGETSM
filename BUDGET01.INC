Const MinTableau = 0000;
      MaxTableau = 1200;

Type  Fiche = Record
	     TypeCouleurLigne : Byte;
	     TypeAnnees       : Integer;
	     TypeMois         : Byte;
	     TypeJour         : Byte;
	     TypeArgentCheque : Real;
	     TypeDepense      : String[20];
	     TypeCoutDepense  : Real;
	     TypeArgentBanque : Real;
	    End;

Var VS           : String[16];
    Chaine       : String[16];
    Path         : String64;
    Touche       : Char;
    XCordonne,
    YCordonne,
    Couleur      : Byte;
    Compteur,
    X,Y,Bout,
    Cobaye,
    Ligne,
    ErrVal,
    Somme        : Integer;
    Nom          : String[12];
    Fichier      : File of Fiche;
    VarFiche     : Fiche;

    SepareDate:Char;
    CouleurBordure,
    CouleurIndicateurCurseur,
    CouleurEditeurNumero,
    CouleurEditeurRegulier,
    CouleurEditeurIndicateur,
    CouleurMPTitre,
    CouleurMPBarSelection,
    CouleurMPCadre,
    CouleurMPRegulier,
    CouleurMATitre,
    CouleurMABarSelection,
    CouleurMACadre,
    CouleurMARegulier,
    CouleurMCTitre,
    CouleurMCBarSelection,
    CouleurMCCadre,
    CouleurMCRegulier,
    CouleurIBTitre,
    CouleurIBCadre,
    CouleurIBRegulier,
    CouleurIBSousTitre : Byte;

Procedure Quitter;
Begin
 InLine($B8/$02/$00/
	$CD/$33);
 InitialiseEcran(32,7);
 Ecrit('Au Revoir Budget Sylvain Maltais Version 2.00A'+Espace(39),31);
 InLine($B4/$01/
	$B1/$07/
	$B5/$06/
	$CD/$10);
 Halt;
End;



Procedure InitiationConfiguration;
Label Exit;
Var Fichier:File of Byte;
    Cobaye:Byte;
Begin
 CouleurBordure           := $01;
 SepareDate     	      := '-';
 CouleurIndicateurCurseur := $0E;
 CouleurEditeurNumero     := $1B;
 CouleurEditeurRegulier   := $1F;
 CouleurEditeurIndicateur := $1E;
 CouleurMPTitre	      := $3E;
 CouleurMPBarSelection    := $5E;
 CouleurMPCadre	      := $3F;
 CouleurMPRegulier	      := $3B;
 CouleurMATitre	      := $2E;
 CouleurMABarSelection    := $5E;
 CouleurMACadre	      := $2F;
 CouleurMARegulier	      := $2B;
 CouleurMCTitre	      := $7E;
 CouleurMCBarSelection    := $5E;
 CouleurMCCadre	      := $7F;
 CouleurMCRegulier	      := $7B;
 CouleurIBTitre	      := $2E;
 CouleurIBCadre	      := $2F;
 CouleurIBRegulier	      := $2F;
 CouleurIBSousTitre	      := $2E;
 Assign(Fichier,'Budget.CFG');
 {$I-}Reset(Fichier);{$I+}
 If IOResult<>0 Then Goto Exit;
 Cobaye:=0;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurBordure);
 Cobaye:=1;Seek(Fichier,Cobaye);
 Read(Fichier,Cobaye);SepareDate:=Chr(Cobaye);
 Cobaye:=2;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurIndicateurCurseur);
 Cobaye:=3;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurNumero);
 Cobaye:=4;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurRegulier);
 Cobaye:=5;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurIndicateur);
 Cobaye:=6;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurNumero);
 Cobaye:=7;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurRegulier);
 Cobaye:=8;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurEditeurIndicateur);
 Cobaye:=9;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMPTitre);
 Cobaye:=10;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMPBarSelection);
 Cobaye:=11;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMPCadre);
 Cobaye:=12;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMPRegulier);
 Cobaye:=13;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMATitre);
 Cobaye:=14;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMABarSelection);
 Cobaye:=15;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMACadre);
 Cobaye:=16;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMARegulier);
 Cobaye:=17;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMCTitre);
 Cobaye:=18;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMCBarSelection);
 Cobaye:=19;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMCCadre);
 Cobaye:=20;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurMCRegulier);
 Cobaye:=21;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurIBTitre);
 Cobaye:=22;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurIBCadre);
 Cobaye:=23;Seek(Fichier,Cobaye);
 Read(Fichier,CouleurIBRegulier);
 Cobaye:=24;Seek(Fichier,Cobaye);
 Write(Fichier,CouleurIBSousTitre);
 Close(Fichier);
 Exit :
End;

Procedure CrossI;
Var Heures : String[6];
Begin
 Heures := Heure;
 Mem[$B800:3820] := Ord(Heures[1]);
 Mem[$B800:3822] := Ord(Heures[2]);
 Mem[$B800:3826] := Ord(Heures[3]);
 Mem[$B800:3828] := Ord(Heures[4]);
 Mem[$B800:3832] := Ord(Heures[5]);
 Mem[$B800:3834] := Ord(Heures[6]);
End;

Procedure Ajustement;
Label Debut,10,20,30,Exit,ACDebut,AC10,AC20,ACExit,ACB10,ACB20;
Label ACBExit,IB10,IB20,IBExit,MP10,MP20,MPExit,AE10,AE20,AEExit,
      MA10,MA20,MAEXit,MC10,MC20,MCExit;
Var Compteur,Position:Byte;
    Fichier:File of Byte;
    Bout,X,Y:Integer;
    Tableau,TableauA:Array[0..4001]of Byte;

 Function SelectionCouleur(CouleurDepart:Byte):Byte;
 Label 10,20,Exit;
 Var Tableau1,Tableau2:Array[0..4001]of Byte;
     Compteur,Position:Byte;
 Begin
  Move(Mem[$B800:0000],Tableau1[1],4000);
  CadrePlain(10,1,43,22,95,1);
  For Compteur:=0 to 7 do For Position:=0 to 15 do
  Begin
   Mem[$B800:((4+Position)*80+15+Compteur*3)*2+1]:=Compteur*16+Position;
   Mem[$B800:((4+Position)*80+16+Compteur*3)*2+1]:=Compteur*16+Position;
   Mem[$B800:((4+Position)*80+17+Compteur*3)*2+1]:=Compteur*16+Position;
   Mem[$B800:((4+Position)*80+16+Compteur*3)*2]:=120;
  End;
  Compteur:=CouleurDepart div 16;
  Position:=CouleurDepart mod 16;
  10 : Move(Mem[$B800:0000],Tableau2[1],4000);
       CadreVide(14+Compteur*3,3+Position,18+Compteur*3,5+Position,15,0);
       InLine($B8/$01/$00/$CD/$33);
  20 : Touche := ReadKey;
       InLine($B8/$02/$00/$CD/$33);
       Move(Tableau2[1],Mem[$B800:0000],4000);
       If(KeyPressed)Then
       Begin
	Touche := ReadKey;
	Case Touche of
	 'H':Position:=(Position-1)And 15;
	 'P':Position:=(Position+1)And 15;
	 'K':Compteur:=(Compteur-1)And 7;
	 'M':Compteur:=(Compteur+1)And 7;
	End;
       End;
       If(Touche=#27)Then Goto Exit;
       If(Touche=#13)Then
       Begin
	SelectionCouleur:=16*Compteur+Position;
	Goto Exit;
       End;
       Goto 10;
 Exit: Move(Tableau1[1],Mem[$B800:0000],4000);
 End;
 Procedure AjustementCaractere;
 Label 30,40;
 Begin
  Localise(30,16);
  Ecrit('Entrer le Caractere :  ',CouleurMATitre);
  InLine($B4/$01/$B1/$07/$B5/$06/$CD/$10/$B8/$01/$00/$CD/$33);
  Touche := ReadKey;
  InLine($B8/$02/$00/$CD/$33);
  If(KeyPressed)Then
  Begin
   InLine($B4/$07/$CD/$21);
   Goto 40;
  End;
 If(Touche=#27)Then Goto 40;
 SepareDate:=Touche;
 Ecrit(Touche,CouleurMARegulier);
 CentreEcriture(18,'Presse une Touche... ',CouleurMATitre);
 30 : InLine($B4/$07/$CD/$21);
 40 : InLine($B4/$01/$B1/$07/$B5/$08/$CD/$10);
 End;
 Begin
  InLine($B4/$01/$B1/$07/$B5/$08/$CD/$10/$B8/$02/$00/$CD/$33);
  Move(Mem[$B800:0000],Mem[$B800:12000],4000);
  For Compteur := 1 to 7 do BoiteCaractere(40-Compteur*3,12-Compteur,40+Compteur*3,12+Compteur,CouleurMACadre);
 Debut : CadrePlain(15,5,65,22,CouleurMACadre,1);
	 CentreEcriture(8,'Menu d''Ajustement',CouleurMATitre);
	 CentreEcriture(10,'Separateur de la Date',CouleurMARegulier);
	 CentreEcriture(11,'Ajuster les Couleurs',CouleurMARegulier);
	 CentreEcriture(12,'Sauvegarder Ajustement',CouleurMARegulier);
	 CentreEcriture(13,'Quitter l''Ajustement',CouleurMAREgulier);
	 Position:=0;
 10    : For Compteur:=25 to 55 do Mem[$B800:(Compteur+(Position+10)*80)*2+1] := CouleurMABarSelection;
	 InLine($B8/$01/$00/$CD/$33);
	 Touche := ReadKey;
	 InLine($B8/$02/$00/$CD/$33);
	 If(KeyPressed)Then
	 Begin
	Touche := ReadKey;
	For Compteur:=25 to 55 do Mem[$B800:(Compteur+(Position+10)*80)*2+1]:=CouleurMARegulier;
	Case Touche of
	 'G':Position:=0;
	 'H':Position:=(Position-1)And 3;
	 'O':Position:=3;
	 'P':Position:=(Position+1)And 3;
	End;
	Goto 10;
	 End;
	 Case Touche of
	#13:Begin
	     If(Position=0)Then AjustementCaractere
	      Else
	     If(Position=1)Then
	     Begin
	      Move(Mem[$B800:0000],Tableau[1],4000);
 ACDebut      : CadrePlain(13,7,67,23,CouleurMCCadre,1);
	      CentreEcriture(10,'Menu des Couleurs',CouleurMCTitre);
	      CentreEcriture(12,'Bordure de l''‚cran',CouleurMCRegulier);
	      CentreEcriture(13,'Message de verification',CouleurMCRegulier);
	      CentreEcriture(14,'Editeur',CouleurMCRegulier);
	      CentreEcriture(15,'Cherche un Fichier',CouleurMCRegulier);
	      CentreEcriture(16,'Menu Principal',CouleurMCRegulier);
	      CentreEcriture(17,'Menu d''Ajustement',CouleurMCRegulier);
	      CentreEcriture(18,'Menu des Couleurs',CouleurMCRegulier);
	      CentreEcriture(19,'Info-Budjet',CouleurMCRegulier);
	      Position:=0;
 AC10         : For Compteur:=27 to 52 do
	       Mem[$B800:((12+Position)*80+Compteur)*2+1]:=CouleurMCBarSelection;
	      Touche := ReadKey;
	      For Compteur:=27 to 52 do Mem[$B800:((12+Position)*80+Compteur)*2+1]:=CouleurMCRegulier;
	      If(KeyPressed)Then
	      Begin
	       Touche := ReadKey;
	       Case Touche of
		'H':Position:=(Position-1)And 7;
		'P':Position:=(Position+1)And 7;
		'G':Position:=0;
		'O':Position:=7;
	       End;
	       Goto AC10;
	      End;
	      If(Touche=#27)Then Goto ACExit;
	      If(Touche=^M)Then
	      Begin
	       Move(Mem[$B800:0000],TableauA[1],4000);
	       Case Position of
		0:Begin
		 CadrePlain(28,13,51,21,95,1);
		 Position:=CouleurBordure;
		 For Compteur:=0 to 15 do Mem[$B800:(32+Compteur+16*80)*2]:=219;
		 For Compteur:=0 to 15 do Mem[$B800:(32+Compteur+16*80)*2+1]:=Compteur;
 ACB10             : Mem[$B800:(32+Position+18*80)*2]:=30;
		 (*  HiresColor(Position); *)
		 InLine($B8/$01/$00/$CD/$33);
		 Touche := ReadKey;
		 InLine($B8/$02/$00/$CD/$33);
		 Mem[$B800:(32+Position+18*80)*2]:=32;
		 If(KeyPressed)Then
		 Begin
		  Touche := ReadKey;
		  Case Touche of
		   'K':Position:=(Position-1)And $F;
		   'M':Position:=(Position+1)And $F;
		   'G':Position:=0;'O':Position:=$F;
		  End;
		 End;
		 If(Touche=^M)Then
		 Begin
		  CouleurBordure:=Position;
		  Goto ACBExit;
		 End
		  Else
		 If(Touche=#27)Then Goto ACBExit;
		 Goto ACB10;
 ACBExit          : End;
	      1 : Begin
		End;
	      2 : Begin
		 CadrePlain(22,9,72,23,111,1);
		 Localise(30,12);
		 Ecrit('Menu d''Ajustement d''Editeur',110);
		 Localise(32,14);
		 Ecrit('Indicateur du Curseur',107);
		 Localise(32,15);
		 Ecrit('Indicateur des Numeros',107);
		 Localise(32,16);
		 Ecrit('l''Ensemble Regulier',107);
		 Localise(32,17);Ecrit('Sous-Titre Indicateur',107);
		 Position:=0;
 AE10	         : For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=94;
 AE20              : Touche := ReadKey;
		 For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=107;
		 If(KeyPressed)Then
		 Begin
		  Touche := ReadKey;
		  Case Touche of
		   'H':Position:=(Position-1)And 3;
		   'P':Position:=(Position+1)And 3;
		   'G':Position:=0;
		   'O':Position:=3;
		  End;
		  Goto AE10;
		 End;
		 If(Touche=#27)Then Goto AEExit;
		 If(Touche=^M)Then
		 Begin
		  Case Position of
		   0:CouleurIndicateurCurseur:=SelectionCouleur(CouleurIndicateurCurseur);
		   1:CouleurEditeurNumero:=SelectionCouleur(CouleurEditeurNumero);
		   2:CouleurEditeurRegulier:=SelectionCouleur(CouleurEditeurRegulier);
		   3:CouleurEditeurIndicateur:=SelectionCouleur(CouleurEditeurIndicateur);End;Goto AE10;
		  End;
		  Goto AE10;
 AEExit            : End;
	       3 : Begin
		 End;
	       4 : Begin
		  CadrePlain(22,9,72,23,111,1);
		  Localise(30,12);
		  Ecrit('Menu d''Ajustement du Principal',110);
		  Localise(32,14);
		  Ecrit('Cadre',107);
		  Localise(32,15);
		  Ecrit('Titre',107);
		  Localise(32,16);
		  Ecrit('Regulier',107);
		  Localise(32,17);
		  Ecrit('Bar Selection',107);
		  Position:=0;
 MP10               : For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=94;
 MP20               : Touche := ReadKey;
		  For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=107;
		  If(KeyPressed)Then
		  Begin
		   Touche := Readkey;
		   Case Touche of
		    'H':Position:=(Position-1)And 3;
		    'P':Position:=(Position+1)And 3;
		    'G':Position:=0;
		    'O':Position:=3;
		   End;
		   Goto MP10;
		  End;
		  If(Touche=#27)Then Goto MPExit;
		  If(Touche=^M)Then
		  Begin
		   Case Position of
		    0:CouleurMPCadre:=SelectionCouleur(CouleurMPCadre);
		    1:CouleurMPTitre:=SelectionCouleur(CouleurMPTitre);
		    2:CouleurMPRegulier:=SelectionCouleur(CouleurMPRegulier);
		    3:CouleurMPBarSelection:=SelectionCouleur(CouleurMPBarSelection);
		   End;
		   Goto MP10;
		  End;
		  Goto MP10;
 MPExit             : End;
		5 : Begin
		   CadrePlain(22,9,72,23,111,1);
		   Localise(30,12);
		   Ecrit('Menu d''Ajustement d''Ajustement',110);
		   Localise(32,14);
		   Ecrit('Cadre',107);
		   Localise(32,15);
		   Ecrit('Titre',107);
		   Localise(32,16);
		   Ecrit('Regulier',107);
		   Localise(32,17);
		   Ecrit('Bar Selection',107);
		   Position:=0;
 MA10                : For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=94;
 MA20                : Touche := ReadKey;
		   For Compteur := 31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=107;
		   If(KeyPressed)Then
		   Begin
		    Touche := ReadKey;
		    Case Touche of
		     'H':Position:=(Position-1)And 3;
		     'P':Position:=(Position+1)And 3;
		     'G':Position:=0;
		     'O':Position:=3;
		    End;
		    Goto MA10;
		   End;
		   If(Touche=#27)Then Goto MAExit;If(Touche=^M)Then
		   Begin
		    Case Position of
		     0:CouleurMACadre:=SelectionCouleur(CouleurMACadre);
		     1:CouleurMATitre:=SelectionCouleur(CouleurMATitre);
		     2:CouleurMARegulier:=SelectionCouleur(CouleurMARegulier);
		     3:CouleurMABarSelection:=SelectionCouleur(CouleurMABarSelection);
		    End;
		    Goto MA10;
		   End;
		   Goto MA10;
 MAExit             : End;
		6 : Begin
		   CadrePlain(22,9,72,23,111,1);
		   Localise(30,12);
		   Ecrit('Menu d''Ajustement de Couleur',110);
		   Localise(32,14);
		   Ecrit('Cadre',107);
		   Localise(32,15);
		   Ecrit('Titre',107);
		   Localise(32,16);
		   Ecrit('Regulier',107);
		   Localise(32,17);
		   Ecrit('Bar Selection',107);
		   Position := $00;
 MC10                : For Compteur:=31 to 56 do
		    Mem[$B800:((14+Position)*80+Compteur)*2+1]:=94;
 MC20                : Touche := ReadKey;
		   For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=107;
		   If(KeyPressed)Then
		   Begin
		    Touche := ReadKey;
		    Case Touche of
		     'H':Position:=(Position-1)And 3;
		     'P':Position:=(Position+1)And 3;
		     'G':Position:=0;
		     'O':Position:=3;
		    End;
		    Goto MC10;
		   End;
		   If(Touche=#27)Then Goto MCExit;
		   If(Touche=^M)Then
		   Begin Case Position of
		    0:CouleurMCCadre:=SelectionCouleur(CouleurMCCadre);
		    1:CouleurMCTitre:=SelectionCouleur(CouleurMCTitre);
		    2:CouleurMCRegulier:=SelectionCouleur(CouleurMCRegulier);
		    3:CouleurMCBarSelection:=SelectionCouleur(CouleurMCBarSelection);
		   End;
		   Goto MC10;
		  End;
		  Goto MC10;
 MCExit            : End;
	       7 : Begin
		  CadrePlain(22,9,72,23,111,1);
		  CentreEcriture(12,'Menu d''Ajustement Info-Budget',110);
		  Localise(32,14);
		  Ecrit('Cadre',107);
		  Localise(32,15);
		  Ecrit('Titre',107);
		  Localise(32,16);
		  Ecrit('Regulier',107);
		  Localise(32,17);
		  Ecrit('Sous-Titre',107);
		  Position:=0;
 IB10               : For Compteur:=31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=94;
 IB20               : Touche := ReadKey;
		  For Compteur := 31 to 56 do Mem[$B800:((14+Position)*80+Compteur)*2+1]:=107;
		  If(KeyPressed)Then
		  Begin
		   Touche := ReadKey;
		   Case Touche of
		    'H':Position:=(Position-1)And 3;
		    'P':Position:=(Position+1)And 3;
		    'G':Position:=0;
		    'O':Position:=3;
		   End;
		   Goto IB10;
		  End;
		  If(Touche=#27)Then Goto IBExit;
		  If(Touche=#13)Then
		  Begin
		   Case Position of
		    0:CouleurIBCadre:=SelectionCouleur(CouleurIBCadre);
		    1:CouleurIBTitre:=SelectionCouleur(CouleurIBTitre);
		    2:CouleurIBRegulier:=SelectionCouleur(CouleurIBRegulier);
		    3:CouleurIBSousTitre:=SelectionCouleur(CouleurIBSousTitre);
		   End;
		   Goto IB10;
		  End;
		  Goto IB10;
 IBExit            : End;
		End;
		Move(TableauA[1],Mem[$B800:0000],4000);
		Goto ACDebut;
		 End;
		 Goto AC10;
 ACExit          : Move(Tableau[1],Mem[$B800:0000],4000);
		End
		 Else
		If(Position=2)Then
		Begin
		 Assign(Fichier,'Budget.CFG');
		 {$I-}Reset(Fichier);{$I+}
		 If(IOResult<>0)Then ReWrite(Fichier);
		 Seek(Fichier,0);
		 Write(Fichier,CouleurBordure);
		 Seek(Fichier,1);
		 Position:=Ord(SepareDate);
		 Write(Fichier,Position);
		 Seek(Fichier,2);
		 Write(Fichier,CouleurIndicateurCurseur);
		 Seek(Fichier,3);
		 Write(Fichier,CouleurEditeurNumero);
		 Seek(Fichier,4);
		 Write(Fichier,CouleurEditeurRegulier);
		 Seek(Fichier,5);
		 Write(Fichier,CouleurEditeurIndicateur);
		 Seek(Fichier,6);
		 Write(Fichier,CouleurEditeurNumero);
		 Seek(Fichier,7);
		 Write(Fichier,CouleurEditeurRegulier);
		 Seek(Fichier,8);
		 Write(Fichier,CouleurEditeurIndicateur);
		 Seek(Fichier,9);
		 Write(Fichier,CouleurMPTitre);
		 Seek(Fichier,10);
		 Write(Fichier,CouleurMPBarSelection);
		 Seek(Fichier,11);
		 Write(Fichier,CouleurMPCadre);
		 Seek(Fichier,12);
		 Write(Fichier,CouleurMPRegulier);
		 Seek(Fichier,13);
		 Write(Fichier,CouleurMATitre);
		 Seek(Fichier,14);
		 Write(Fichier,CouleurMABarSelection);
		 Seek(Fichier,15);
		 Write(Fichier,CouleurMACadre);
		 Seek(Fichier,16);
		 Write(Fichier,CouleurMARegulier);
		 Seek(Fichier,17);
		 Write(Fichier,CouleurMCTitre);
		 Seek(Fichier,18);
		 Write(Fichier,CouleurMCBarSelection);
		 Seek(Fichier,19);
		 Write(Fichier,CouleurMCCadre);
		 Seek(Fichier,20);
		 Write(Fichier,CouleurMCRegulier);
		 Seek(Fichier,21);
		 Write(Fichier,CouleurIBTitre);
		 Seek(Fichier,22);
		 Write(Fichier,CouleurIBCadre);
		 Seek(Fichier,23);
		 Write(Fichier,CouleurIBRegulier);
		 Seek(Fichier,24);
		 Write(Fichier,CouleurIBSousTitre);
		 Seek(Fichier,25);
		 Write(Fichier,CouleurIBTitre);
		 Seek(Fichier,26);
		 Write(Fichier,CouleurIBCadre);
		 Seek(Fichier,27);
		 Write(Fichier,CouleurIBRegulier);
		 Seek(Fichier,28);
		 Write(Fichier,CouleurIBSousTitre);
		 Close(Fichier);
		End
		 Else
		If(Position=3)Then Goto Exit;
		Goto Debut;
	       End;
	       #27:Goto Exit;
	      End;
	      Goto 10;
 Exit         : Move(Mem[$B800:12000],Mem[$B800:0000],4000);
End;

