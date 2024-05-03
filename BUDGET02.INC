Procedure EcritUnCaractereSansAttributPage0(X,Y,Caractere:Byte);
Begin
 Mem[$B800:(Y*80+X)*2] := Caractere;
End;


Procedure StationneDisqueDur;
Label 10,20,Exit;
Var Tableau  : Array[0..4002]of Byte;
    X,Y,Bout : Integer;

 Function Parque:Boolean;
 Var Disque,Nombre       : Byte;
     CodeErreur,Compteur : Integer;
 Begin
  CodeErreur  := $00;
  Registre.AH := $08;
  Registre.DL := $80;
  Intr($13,Registre);
  Nombre := Registre.DL;
  For Compteur := $00 to (Nombre-1) do
  Begin
   Registre.AX := $0C01;
   Registre.CX := Registre.CX + 1;
   Registre.DL := $80 + Compteur;
   Intr($13,Registre);
   If((Registre.Flags and 1)<>0)Then CodeErreur := CodeErreur + Registre.AX;
   Registre.AH := $08;
   Registre.DL := $80 + Compteur;
   Intr($13,Registre);
  End;
  If(CodeErreur<>0)Then Parque := Faux Else Parque := Vrai;
 End;

Begin
 Move(Mem[$B800:0000],Tableau[1],4000);
 If(Parque)Then
 Begin
  For Compteur := 1 to 7 do
   BoiteCaractere(40-Compteur*4,12-Compteur,40+Compteur*4,12+Compteur,47);
  CadrePlain(10,4,70,21,47,1);
  CentreEcriture(7,'Disque dur',46);
  CentreEcriture(10,'Stationnement du disque dur Reussit...',43);
 End
  else
 If(Parque=False)Then
 Begin
  For Compteur := 1 to 7 do
   BoiteCaractere(40-Compteur*4,12-Compteur,40+Compteur*4,12+Compteur,94);
  CadrePlain(10,4,70,21,94,1);
  CentreEcriture(10,'Erreur de parquage du disque dur...',93);
 End;
 CentreEcriture(12,'Tu peux maintenant fermer l''ordinateur...',43);
 CentreEcriture(13,'ou presse une touche pour retourner au Budjet...',43);
 CadreVide(15,15,25,17,47,1);
 Localise(18,16);
 Ecrit('Retour',46);
 InLine($B8/$01/$00/
	$CD/$33);
 20   : PositionetBouton(X,Y,Bout);
	If((Bout=1)And(X>15*8)And(Y>15*8)And(X<25*8)And(Y<17*8))Then Goto Exit;
	If Not(KeyPressed)Then Goto 20;
	Touche := ReadKey;
 Exit : InLine($B8/$02/$00/
	     $CD/$33);
	Move(Tableau[1],Mem[$B800:0000],4000);
End;

Procedure ReelEnDoubleMot(Reel : LongInt; Var Grand,Petit : Word);
Var Temporaire : LongInt;
Begin
 Grand := Trunc( Reel / 65536 );
 Temporaire := Reel - ( Grand * 65536 );
 Petit := Trunc(Temporaire);
End;

Function DoubleMotEnReel(Grand,Petit : Word) : LongInt;
Var Temporaire : LongInt;
Begin
 Temporaire := Petit;
 If(Temporaire < 0)Then Temporaire := Temporaire + 65536;
 DoubleMotEnReel := (Grand * 65536) + Temporaire;
End;

Procedure Positionne(Handle : Integer; RecNum : LongInt; Taille : Word);
Var Grand,Petit : Word;
    Position    : LongInt;
Begin
 Position := RecNum * Taille;
 ReelEnDoubleMot(Position,Grand,Petit);
 Registre.AX := $4200;
 Registre.BX := Handle;
 Registre.CX := Grand;
 Registre.DX := Petit;
 MsDos(Registre);
End;

Function TailleFichier(Handle : Integer) : LongInt;
Begin
 Registre.AX := $4202;
 Registre.BX := Handle;
 Registre.CX := $0000;
 Registre.DX := $0000;
 MsDos(Registre);
 If((Registre.Flags And 1) <> 0)Then
 Begin
  TailleFichier := -1;
 End
  Else
 Begin
  TailleFichier := DoubleMotEnReel(Registre.DX,Registre.AX);
 End;
End;

Function Ferme(Handle : Integer) : Integer;
Begin
 Registre.AX := $3E00;
 Registre.BX := Handle;
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then Ferme := Registre.AX Else Ferme := $0000;
End;

Function Ouvre(Nom : Chemin;Mode:Byte) : Integer;
Var Temporaire : Chemin;
Begin
 Temporaire := Nom + #00;
 Registre.AX := $3D40+Mode;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then
 Begin
  Ouvre  := -1;
 End
  else
 Begin
  Ouvre  := Registre.AX;
 End;
End;

Function Cree(Nom : Chemin) : Integer;
Var Temporaire : Chemin;
Begin
 Move(Nom[1],Temporaire,Length(Nom));
 Temporaire:= Nom + #00;
 Registre.AX := $3C00;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 Registre.CX := $0000;
 MsDos(Registre);
 If((Registre.Flags and 1)<>0)Then Cree := -1
			Else Cree := Registre.AX;
End;

Function Efface(Nom : Chemin) : Integer;
Var Temporaire : Chemin;
Begin
 Temporaire := Nom + #00;
 Registre.AX := $4100;
 Registre.DS := Seg(Temporaire[1]);
 Registre.DX := Ofs(Temporaire[1]);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then Efface := Registre.AX
			  Else Efface := $0000;
End;

Procedure LitEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Var BytesLus : Integer;
Begin
 Positionne(Handle,RecNum,Taille);
 Registre.AX := $3F00;
 Registre.BX := Handle;
 Registre.CX := Taille;
 Registre.DS := Seg(Buffer);
 Registre.DX := Ofs(Buffer);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then BytesLus := 0
			  Else BytesLus := Registre.AX;
End;

Procedure ModifieEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Var Ecrits : Word;
Begin
 Positionne(Handle,RecNum,Taille);
 Registre.AX := $4000;
 Registre.BX := Handle;
 Registre.CX := Taille;
 Registre.DS := Seg(Buffer);
 Registre.DX := Ofs(Buffer);
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then Ecrits := 0
			  Else Ecrits := Registre.AX;
End;

Procedure AjouteEnregistrement(Handle : Integer; RecNum : LongInt; Taille : Word; Var Buffer);
Begin
 RecNum := Trunc((TailleFichier(Handle))/Taille);
 ModifieEnregistrement(Handle,RecNum,Taille,Buffer);
End;

Function MajDirectoire(Handle : Integer) : Integer;
Begin
 Registre.AX := $4500;
 Registre.BX := Handle;
 MsDos(Registre);
 If((Registre.Flags and 1) <> 0)Then MajDirectoire := Registre.AX Else MajDirectoire := Ferme(Registre.AX);
End;

Function Bouton : Byte;
Begin
 Registre.AX := $0003;
 Intr($33,Registre);
 Bouton := Registre.BX;
End;

Procedure Presentation;
Var Compteur : Byte;
Begin
 InLine($B8/$03/$00/ { MOV AX,0003 }
	$CD/$10/     { INT 10      }

	$B4/$01/     { MOV AH,01   }
	$B9/$07/$08/ { MOV CX,0807 }
	$CD/$10/     { INT 10      }

	$B8/$00/$00/ { MOV AX,0000 }
	$CD/$33);    { INT 33      }

 For Compteur := 0 to 255 do
 Begin
  MemW[$B800:(80*Random(24)+Random(79))*2] := $FA + Random(15)*256;
 End;
 For Compteur := 1 to 6 do
 Begin
  CadrePlain(40-Compteur*4,12-Compteur,40+Compteur*4,12+Compteur,31,1);
 End;
 CentreEcriture(10,'Budget Sylvain Maltais',27);
 CentreEcriture(12,'Version 3.01A',27);
 CentreEcriture(13,'Copyright (C) 1991 par',27);
 CentreEcriture(14,'Les Chevaliers de Malte International',27);
 InLine($B8/$01/$00/ { MOV AX,0001 }
	$CD/$33);    { INT 33      }
 Repeat Until ((KeyPressed) or (Bouton > 0))
End;


