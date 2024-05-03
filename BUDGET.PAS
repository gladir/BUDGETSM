(***************************************************************************)
(*                                                                         *)
(*                            Budget Version 2.01A                         *)
(*                                                                         *)
(*                            Copyright (C) 1991 par                       *)
(*                    Les Chevaliers de Malte International                *)
(*                                                                         *)
(***************************************************************************)

{$M 65520,0,655360 }

Uses Crt,MSGraph,DOS,Printer;

{$I Maitre.pas   }
{$I Ecran.pas    }
{$I Souris.pas   }
{$I Temps.pas    }
{$I Budget01.pas }
{$I Budget02.pas }

Label Debut,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,Exit;

Var Tableau      : Array[0..4001]of Byte;
    CouleurLigne : Array[MinTableau..MaxTableau+1]of Byte;
    Annees       : Array[MinTableau..MaxTableau+1]of Byte;
    Mois         : Array[MinTableau..MaxTableau+1]of Byte;
    Jour         : Array[MinTableau..MaxTableau+1]of Byte;
    ArgentCheque : Array[MinTableau..MaxTableau+1]of Real;
    Depense      : Array[MinTableau..MaxTableau+1,1..20] of Byte;
    CoutDepense  : Array[MinTableau..MaxTableau+1]of Real;
    ArgentBanque : Array[MinTableau..MaxTableau+1]of Real;
    TableauNom        : Array[0..131]of String[12];
    TableauTaille     : Array[0..131]of LongInt;
    TableauDate       : Array[0..131]of String[10];
    TableauHeure      : Array[0..131]of String[8];
    TableauAttribut   : Array[0..131]of LongInt;
    Intermediaire     : Array[0..36] of Byte;
    HandleTemporaire  : Integer;
    Heures,
    Heur,
    Minute,
    Seconde      : String[6];

Procedure Nouveau;
Begin
 FillChar(CouleurLigne[MinTableau],1200,30);
 FillChar(Annees[MinTableau],1200,0);
 FillChar(Jour[MinTableau],1200,0);
 FillChar(Mois[MinTableau],1200,0);
 FillChar(ArgentCheque[MinTableau],4800,0);
 FillChar(Depense[MinTableau,1],24000,0);
 FillChar(CoutDepense[MinTableau],4800,0);
 FillChar(ArgentBanque[MinTableau],4800,0);
End;

Procedure Cross14;
Begin
 InLine($B4/$01/      { MOV AH,01   }
	$B9/$07/$06/  { MOV CX,0607 }
	$CD/$10/      { INT 10      }

	$B8/$01/$00/  { MOV AX,0001 }
	$CD/$33);     { INT 10      }

 Mem[$B8DC:XCordonne*2+13] := 14;
End;

Procedure Cross31;
Begin
  Inline($B4/$01/     { MOV AH,01   }
	 $B9/$07/$08/ { MOV CX,0807 }
	 $CD/$10/     { INT 10      }

	 $B8/$02/$00/ { MOV AX,0002 }
	 $CD/$33);    { INT 33      }

 Mem[$B8DC:XCordonne*2+13] := 31;
End;

Procedure ChoisisFichier;
Label Debut,10,20,Rep,Enter,Exit;
Var YCordonne         : Byte;
    NombreFiles,
    Ligne,
    Compteur          : Integer;
    RepertoireCourant : String64;
    Tableau           : Array[0..4001]of Byte;

 Function Volume(Drive:Char):String12;
 Var Compteur       : Byte;
     OK             : Boolean;
     Chaine         : String[7];
     Cobaye         : String[12];

  Procedure Cross;
  Begin
   Ok:=(Registre.Flags and $0001)=0;
   If(OK)And(Mem[Registre.ES:Registre.BX+21]=8)Then
   Begin
    Compteur:=30;
    While(Mem[Registre.ES:Registre.BX+Compteur]<>0)do
    Begin
     Cobaye:=Cobaye+Chr(Mem[Registre.ES:Registre.BX+Compteur]);
     Compteur:=Compteur+1;
    End;
   End;
  End;

 Begin
  Cobaye:='';
  Chaine := Drive+':\*.*'+#0;
  Registre.AH := $4E;
  Registre.CX := $FFFF;
  Registre.DS := Seg(Chaine[1]);
  Registre.DX := Ofs(Chaine[1]);
  MSDos(Registre);
  Registre.AH := $2F;
  MSDos(Registre);
  Cross;
  Repeat
   Registre.AH := $4F;
   MSDos(Registre);
   Cross;
  Until Not(Ok);
  Volume:=Cobaye;
 End;

 Function NombreFichiers(Chaine:String64;Attribut:Integer):Integer;
 Var Compteur       : Integer;
     OK             : Boolean;
 Begin
  Chaine := Chaine+#0;Compteur:=0;
  Registre.AH := $4E;
  Registre.CX := Attribut;
  Registre.DS := Seg(Chaine[1]);
  Registre.DX := Ofs(Chaine[1]);
  MSDos(Registre);
  Registre.AH := $2F;
  MSDos(Registre);
  Ok:=(Registre.Flags and $0001)=0;
  If((Ok)And(Not(Mem[Registre.ES:Registre.BX+21]=8))And
    Not((Mem[Registre.ES:Registre.BX+30]=46)And
    (Mem[Registre.ES:Registre.BX+31]=00)))
  Then Compteur := 1;
  Repeat
   Registre.AH := $4F;
   MSDos(Registre);
   Ok:=(Registre.Flags and $0001)=0;
   If((Ok)And(Not(Mem[Registre.ES:Registre.BX+21]=8))And
     Not((Mem[Registre.ES:Registre.BX+30]=46)And(Mem[Registre.ES:Registre.BX+31]=00)))
  Then Compteur := Compteur+1;
  Until Not(Ok);
  NombreFichiers:=Compteur;
 End;

 Procedure Fichiers(Chaine:String64;Attribut:Integer);
 Var Compteur,Position : Integer;
     OK                : Boolean;
     CobayeII          : String[4];

  Procedure Fuck;
  Begin
   If(Length(CobayeII)=1)Then CobayeII:='0'+CobayeII;
  End;

  Procedure Cross;
  Begin
   Ok:=(Registre.Flags and $0001)=0;
   If((Ok)And(Not(Mem[Registre.ES:Registre.BX+21]=8))And
   Not((Mem[Registre.ES:Registre.BX+30]=46)And(Mem[Registre.ES:Registre.BX+31]=00)))Then
   Begin
    TableauAttribut[Position]:=Mem[Registre.ES:Registre.BX+21] And 22;
    Compteur:=Mem[Registre.ES:Registre.BX+22]+Mem[Registre.ES:Registre.BX+23]*256;
    Str((Compteur And $ED00) shr 11,CobayeII);
    Fuck;
    TableauHeure[Position]:=CobayeII+':';
    Str((Compteur And $01D0) shr 5,CobayeII);
    Fuck;
    TableauHeure[Position]:=TableauHeure[Position]+CobayeII+':';
    Str((Compteur And $001E)*2,CobayeII);
    Fuck;
    TableauHeure[Position]:=TableauHeure[Position]+CobayeII;
    Compteur:=Mem[Registre.ES:Registre.BX+24]+Mem[Registre.ES:Registre.BX+25]*256;
    Str(((Compteur And $FE00)shr 9)+1980,CobayeII);TableauDate[Position]:=CobayeII+'-';
    Str((Compteur And $01E0)shr 5,CobayeII);Fuck;
    TableauDate[Position]:=TableauDate[Position]+CobayeII+'-';
    Str(Compteur And $001F,CobayeII);Fuck;
    TableauDate[Position]:=TableauDate[Position]+CobayeII;
    TableauTaille[Position] := MemW[Registre.ES:Registre.BX+26]+
			 MemW[Registre.ES:Registre.BX+28]*65536;
    Compteur:=30;TableauNom[Position]:='';
    While(Ord(Mem[Registre.ES:Registre.BX+Compteur])<>0)do
    Begin
     If((Mem[Registre.ES:Registre.BX+Compteur]=46)And(Length(TableauNom[Position])<8)And
	Not((Mem[Registre.ES:Registre.BX+30]=46)And(Mem[Registre.ES:Registre.BX+31]=46)))Then
      While(Length(TableauNom[Position])<8)do TableauNom[Position]:=TableauNom[Position]+' ';
     TableauNom[Position]:=TableauNom[Position]+Chr(Mem[Registre.ES:Registre.BX+Compteur]);
     Compteur := Compteur+1;
    End;
    Position := Position + 1;
   End;
  End;

 Begin
  Chaine := Chaine+#0;
  Position := 0;
  Registre.AH := $4E;
  Registre.CX := Attribut;
  Registre.DS := Seg(Chaine[1]);
  Registre.DX := Ofs(Chaine[1]);
  MSDos(Registre);
  Registre.AH := $2F;
  MSDos(Registre);
  Cross;
  Repeat
   Registre.AH := $4F;
   MSDos(Registre);
   Cross;
  Until Not(Ok);
 End;

 Procedure NomFixee(Y,Ligne:Byte);
 Var Compteur:Byte;
 Begin
  For Compteur:=1 to 12 do
   Mem[$B828:$A+(Compteur+Y*80)*2] :=
    Mem[Seg(TableauNom[Ligne]):Ofs(TableauNom[Ligne])+Compteur];
 End;

 Procedure CrossDeuxiemeGeneration;
 Begin
  GotoXY(49,5+YCordonne);
  Case TableauAttribut[Ligne]of
   $00 : Write('Normal');
   $01 : Write('Lecture');
   $02 : Write('Cache');
   $04 : Write('Systeme');
   $10 : Write('Repertoire');
  End;
 End;

 Procedure FuckCross;
 Begin
  Str(Ligne,Vs);
  VS := Zero(4-Length(VS))+VS;
  Mem[$B828:8+YCordonne*160]:=Ord(Vs[4]);
  Mem[$B828:6+YCordonne*160]:=Ord(Vs[3]);
  Mem[$B828:4+YCordonne*160]:=Ord(Vs[2]);
  Mem[$B828:2+YCordonne*160]:=Ord(Vs[1]);
  NomFixee(YCordonne,Ligne);
  Localise(19,4+YCordonne);
  Write(TableauTaille[Ligne]:11);
  Localise(31,4+YCordonne);
  Ecrit(TableauDate[Ligne],27);
  Localise(42,4+YCordonne);
  Ecrit(Copy(TableauHeure[Ligne],1,5),27);
  CrossDeuxiemeGeneration;
 End;

 Procedure CrossVI;
 Begin
  For Compteur := 0 to 11 do Mem[$B828:(Compteur+YCordonne*80)*2+13] := 27;
 End;

 Procedure FinList;
 Begin
  If NombreFiles>=17 Then
  Begin
   YCordonne := 0;
   BoiteCaractere(6,4,17,21,27);
   BoiteCaractere(48,4,57,21,27);
   For Ligne := NombreFiles-17 to NombreFiles do
   Begin
    TextBackGround(1);
    TextColor(11);
    NomFixee(YCordonne,Ligne);
    Str(Ligne,Vs);
    VS:=Zero(4-Length(VS))+VS;
    Mem[$B828:8+YCordonne*160]:=Ord(Vs[4]);
    Mem[$B828:6+YCordonne*160]:=Ord(Vs[3]);
    Mem[$B828:4+YCordonne*160]:=Ord(Vs[2]);
    Mem[$B828:2+YCordonne*160]:=Ord(Vs[1]);
    Localise(19,4+YCordonne);
    Write(TableauTaille[Ligne]:11);
    Localise(31,4+YCordonne);
    Ecrit(TableauDate[Ligne],27);
    Localise(42,4+YCordonne);
    Ecrit(Copy(TableauHeure[Ligne],1,5),27);
    CrossDeuxiemeGeneration;
    YCordonne := YCordonne + 1;
   End;
   YCordonne := 17;
  End
   else
  Begin
   YCordonne := NombreFiles;
   Ligne     := NombreFiles;
  End;
 End;

 Procedure DebutList;
 Var Compteur : Byte;
 Begin
  BoiteCaractere(6,4,17,21,27);
  BoiteCaractere(48,4,57,21,27);
  Ligne     := 0;
  YCordonne := 0;
  For Ligne:=0 to 17 do
  Begin
   If NombreFiles>YCordonne Then
   Begin
    NomFixee(YCordonne,Ligne);
    Str(YCordonne,Vs);
    VS := Zero(4-Length(VS))+VS;
    Mem[$B828:8+Ligne*160] := Ord(Vs[4]);
    Mem[$B828:6+Ligne*160] := Ord(Vs[3]);
    Mem[$B828:4+Ligne*160] := Ord(Vs[2]);
    Mem[$B828:2+Ligne*160] := Ord(Vs[1]);
    Localise(19,4+YCordonne);
    Write(TableauTaille[Ligne]:11);
    Localise(31,4+YCordonne);
    Ecrit(TableauDate[Ligne],27);
    Localise(42,4+YCordonne);
    Ecrit(Copy(TableauHeure[Ligne],1,5),27);
    CrossDeuxiemeGeneration;
   End;
   YCordonne := YCordonne+1;
  End;
  YCordonne := 0;
  Ligne     := 0;
 End;

 Procedure Descend;
 Begin
  If Not(Ligne=NombreFiles)Then
  Begin
   Ligne := Ligne + 1;
   If YCordonne<17 Then YCordonne:=YCordonne+1 else
   Begin
    InLine($B8/$01/$06/
	 $B7/$1B/
	 $B1/$01/
	 $B5/$04/
	 $B2/$04/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$06/
	 $B7/$1B/
	 $B1/$06/
	 $B5/$04/
	 $B2/$11/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$06/
	 $B7/$1B/
	 $B1/$13/
	 $B5/$04/
	 $B2/$1D/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$06/
	 $B7/$1B/
	 $B1/$1F/
	 $B5/$04/
	 $B2/$28/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$06/
	 $B7/$1B/
	 $B1/$2A/
	 $B5/$04/
	 $B2/$2E/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$06/
	 $B7/$1B/
	 $B1/$30/
	 $B5/$04/
	 $B2/$39/
	 $B6/$15/
	 $CD/$10);
	 FuckCross;
   End;
  End;
 End;

 Procedure Monte;
 Begin
  If Not(Ligne=0)Then
  Begin
   Ligne := Ligne - 1;
   If(YCordonne>0)Then YCordonne:=YCordonne-1 else
   Begin
    InLine($B8/$01/$07/
	 $B7/$1B/
	 $B1/$01/
	 $B5/$04/
	 $B2/$04/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$07/
	 $B7/$1B/
	 $B1/$06/
	 $B5/$04/
	 $B2/$11/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$07/
	 $B7/$1B/
	 $B1/$13/
	 $B5/$04/
	 $B2/$1D/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$07/
	 $B7/$1B/
	 $B1/$1F/
	 $B5/$04/
	 $B2/$28/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$07/
	 $B7/$1B/
	 $B1/$2A/
	 $B5/$04/
	 $B2/$2E/
	 $B6/$15/
	 $CD/$10/

	 $B8/$01/$07/
	 $B7/$1B/
	 $B1/$30/
	 $B5/$04/
	 $B2/$39/
	 $B6/$15/
	 $CD/$10);
    FuckCross;
   End;
  End;
 End;

Begin
 InLine($B8/$02/$00/
	$CD/$33);
 SauvegardeTexte(0,0,79,24,Tableau[1]);
 Debut : NombreFiles := NombreFichiers('*.*',16);
	 CadrePlain(10,8,70,14,63,1);
	 CentreEcriture(11,'Un Instant S.V.P je lit les fichiers... ',62);
	 InLine($B4/$01/
	      $B1/$07/
	      $B5/$06/
	      $CD/$10);
	 FillChar(TableauNom,4200,32);
	 Fichiers('*.*',16);
	 TextBackGround(1);
	 InitialiseEcran(32,31);
	 Inline($B4/$01/
	      $B1/$07/
	      $B5/$08/
	      $CD/$10);
	 ClaireColonne(0,179,31);
	 ClaireColonne(79,179,31);
	 ClaireLigne(0,219,15);
	 ClaireLigne(2,196,31);
	 Mem[$B814:$00] := 195;
	 Mem[$B81D:$0E] := 180;
	 ClaireLigne(22,196,31);
	 Mem[$B8DC:$00] := 195;
	 Mem[$B8E5:$0E] := 180;
	 ClaireLigne(24,219,15);
	 GetDir(0,RepertoireCourant);
	 Localise(3,1);
	 Ecrit('Path =  ',31);
	 If(Copy(RepertoireCourant,Length(RepertoireCourant),1)<>'\')Then
	RepertoireCourant:=RepertoireCourant+'\';
	 Ecrit(RepertoireCourant+'*.*',27);
	 Localise(2,3);
	 Ecrit('no ³    Nom     ³  Taille   ³   Date   ³Heure³ Attribut ³ Volume= ',30);
	 Ecrit(Volume(RepertoireCourant[1]),27);
	 Mem[$B81E:$0B]:=31;
	 Mem[$B820:$05]:=31;
	 Mem[$B821:$0D]:=31;
	 Mem[$B823:$03]:=31;
	 Mem[$B823:$0F]:=31;
	 Mem[$B825:$05]:=31;
	 Mem[$B8E3:$04]:=193;
	 Mem[$B81B:$04]:=194;
	 Mem[$B814:$0A]:=194;
	 Mem[$B816:$04]:=194;
	 Mem[$B817:$0C]:=194;
	 Mem[$B819:$02]:=194;
	 Mem[$B819:$0E]:=194;
	 BoiteCaractere(6,4,17,21,27);
	 BoiteCaractere(1,4,4,21,27);
	 TextBackGround(1);
	 TextColor(11);
	 For YCordonne:=0 to 17 do
	 Begin
	  EcritUnCaractereSansAttributPage0(5,4+YCordonne,179);
	  EcritUnCaractereSansAttributPage0(18,4+YCordonne,179);
	  EcritUnCaractereSansAttributPage0(30,4+YCordonne,179);
	  EcritUnCaractereSansAttributPage0(41,4+YCordonne,179);
	  EcritUnCaractereSansAttributPage0(47,4+YCordonne,179);
	  EcritUnCaractereSansAttributPage0(58,4+YCordonne,179);
	 End;
	 DebutList;
	 Mem[$B82F:$04]:=195;
	 For Compteur:=59 to 78 do Mem[$B800:2*Compteur+640]:=196;
	 Mem[$B831:$0E]:=180;
	 For Compteur:=1 to 12 do Mem[$B8ED:9+Compteur*2]:=27;
	 GotoXY(8,24);
	 Ecrit('Position :',31);
	 Localise(22,23);
	 Ecrit('³ Nombre de Fichier : ',31);
	 Write(NombreFiles-1:5);
	 Ecrit(' ³ Fichier :',31);
	 Mem[$B8DC:$A]:=193;
	 Mem[$B8DE:$4]:=193;
	 Mem[$B8DE:$C]:=194;
	 Mem[$B8DF:$C]:=193;
	 Mem[$B8E1:$2]:=193;
	 Mem[$B8E1:$E]:=193;
	 Mem[$B8E2:$2]:=194;
	 CadreVide(60,6,77,8,31,1);
	 TextColor(14);
	 GotoXY(62,8);
	 Write('Correct');
	 CadreVide(60,10,77,12,31,0);
	 GotoXY(62,12);
	 Write('Retire');
 10    : TextColor(11);
	 GotoXY(18,24);
	 Write(Ligne:4);
	 For Compteur:=1 to 12 do
	Mem[$B8ED:8+Compteur*2]:=Mem[Seg(TableauNom[Ligne]):Ofs(TableauNom[Ligne])+Compteur];
	 For Compteur:=0 to 11 do Mem[$B828:(Compteur+YCordonne*80)*2+13] := 94;
	 InLine($B8/$01/$00/
	      $CD/$33);
 Rep   : PositionEtBouton(X,Y,Bout);
	 If((X>480)And(Y>48)And(X<616)And(Y<64)And(Bout=1))Then
	 Begin
	Touche := #13;
	Goto Enter;
	 End
	else
	 If((X>480)And(Y>80)And(X<616)And(Y<96)And(Bout=1))Then
	 Begin
	Touche := #27;
	Path   := '';
	InLine($B8/$02/$00/
	       $CD/$33);
	Goto Exit;
	 End;
	 If Not(KeyPressed)Then Goto Rep;
	 Touche := ReadKey;
 Enter : InLine($B8/$02/$00/
	      $CD/$33);
	 If( KeyPressed )Then
	 Begin
	Touche := ReadKey;
	CrossVI;
	Case Touche of
	 'G':DebutList;
	 'H':Monte;
	 'O':FinList;
	 'P':Descend;
	 'u':FinList;
	 'w':DebutList;
	End;
	Goto 10;
	 End
	else
	 Begin
	CrossVI;
	Case Touche of
	 ^F:FinList;
	 ^G:DebutList;
	 ^M:Begin
	     If((TableauAttribut[Ligne]=16)And Not(Copy(TableauNom[Ligne],1,2)='..'))Then
	     Begin
	      GetDir(0,RepertoireCourant);
	      If(Copy(RepertoireCourant,Length(RepertoireCourant),1)='\')Then
	       RepertoireCourant:=RepertoireCourant+TableauNom[Ligne]
	      else
	       RepertoireCourant:=RepertoireCourant+'\'+TableauNom[Ligne];
	      ChDir(RepertoireCourant);
	      Goto Debut;
	     End
	      else
	     If((TableauAttribut[Ligne]=16)And(Copy(TableauNom[Ligne],1,2)='..'))Then
	     Begin
	      GetDir(0,RepertoireCourant);
	      Delete(RepertoireCourant,Length(RepertoireCourant),1);
	      While(Copy(RepertoireCourant,Length(RepertoireCourant),1)<>'\')do
	       Delete(RepertoireCourant,Length(RepertoireCourant),1);
	      If Not(Length(RepertoireCourant) = 3)Then
	      Delete(RepertoireCourant,Length(RepertoireCourant),1);
	      ChDir(RepertoireCourant);
	      Goto Debut;
	      End
	       else
	      Begin
	       GetDir(0,RepertoireCourant);
	       If(Copy(RepertoireCourant,Length(RepertoireCourant),1)<>'\')Then
		Path:=RepertoireCourant+'\' + TableauNom[Ligne]
	       else
		Path:=RepertoireCourant+TableauNom[Ligne];
	       HandleTemporaire := Ouvre(Path,0);
	       If(HandleTemporaire = -1)Then
	       Begin
		HandleTemporaire := Ferme(HandleTemporaire);
		CadrePlain(4,5,74,18,79,1);
		CentreEcriture(7,'Erreur Fatal 4.00 : Probleme de Fichier...',78);
		Localise(11,10);
		Ecrit('Fichier InExistant,Introuvable ou Incorrect.',79);
		Localise(11,11);
		Ecrit('Vous devriez retaper le nom du Fichier...',79);
		InLine($B4/$07/
		       $CD/$21);
		Goto Exit;
	       End;
	       CadrePlain(10,8,70,16,63,1);
	       CentreEcriture(11,'Un Instant S.V.P je lit le fichier... ',62);
	       Nouveau;
	       For Compteur := 0 to (TailleFichier(HandleTemporaire) div 36)-1 do
	       Begin
		Localise(31,13);
		Ecrit('Ligne =  ',63);
		Str(Compteur,RepertoireCourant);
		Ecrit(RepertoireCourant,59);
		If(Compteur<MaxTableau)Then
		Begin
		 LitEnregistrement(HandleTemporaire,Compteur,37,Intermediaire);
		 CouleurLigne[Compteur] := Intermediaire[0];
		 Annees[Compteur]       := MemW[Seg(Intermediaire[1]):Ofs(Intermediaire[1])];
		 If(Intermediaire[3] < 13)Then Mois[Compteur] := Intermediaire[3]
					  Else Mois[Compteur] := 0;
		 If(Intermediaire[4] < 32)Then Jour[Compteur] := Intermediaire[4]
					  Else Jour[Compteur] := 0;
		 Move(Intermediaire[5],ArgentCheque[Compteur],4);
		 Move(Intermediaire[9],Depense[Compteur,1],20);
		 Move(Intermediaire[29],CoutDepense[Compteur],4);
		 Move(Intermediaire[33],ArgentBanque[Compteur],4);
		End
		else
		Begin
		 CadrePlain(4,5,74,18,79,1);
		 CentreEcriture(8,'Erreur Fatal 4.1F : Probleme de Fichier...',78);
		 CentreEcriture(10,'Fichier trop gros... il a rempli au maximum la m‚moire...',79);
		 CentreEcriture(12,'Rien a faire... il ne peut en prendre plus...',79);
		 Localise(22,15);
		 Ecrit('Retire',78);
		 CadreVide(20,14,30,16,79,1);
		 InLine($B8/$01/$00/
		      $CD/$33/
		      $B4/$07/
		      $CD/$21/

		      $B8/$02/$00/
		      $CD/$33);
		 Goto Exit;
		End;
	       End;
	       Goto Exit;
	      End;
	    End;
	 ^N : Descend;
	 ^U : Monte;
	 ^Q,#27 : Begin
		 Path := '';
		 Goto Exit;
		End;
	End;
	 End;
	 Goto 10;
Exit   : InLine($B4/$01/
		$B1/$07/
		$B5/$06/
		$CD/$10);
	 AfficheTexte(0,0,79,24,Tableau[1]);
	 If(Path<>'')Then
	 Begin
	Localise(47,23);
	Ecrit(TableauNom[Ligne],27);
 End;
End;

Procedure DepenseFixee(y,Ligne,couleur:Byte);
Begin
 For Cobaye := 1 to 20 do
 Begin
  MemW[$B800:(28+Cobaye+(Y+2)*80)*2] := Depense[Ligne,Cobaye] + Couleur*256;
 End;
End;

Procedure lArtDesCross;
Begin
 TextBackGround(CouleurLigne[Ligne]div 16);
 TextColor(CouleurLigne[Ligne]mod 16);
 If(Annees[Ligne]>0)Then
 Begin
  GotoXY(7,YCordonne+3);
  Write(1985+Annees[Ligne]:4,SepareDate);
 End;
 If(Mois[Ligne]>0)Then
 Begin
  GotoXY(12,YCordonne+3);
  Write(Mois[Ligne]:2,SepareDate);
 End;
 If(Jour[Ligne]>0)Then
 Begin
  GotoXY(15,YCordonne+3);
  Write(Jour[Ligne]:2);
 End;
 If(ArgentCheque[Ligne]>0.009)Then
 Begin
  GotoXY(18,YCordonne+3);
  Write(ArgentCheque[Ligne]:11:2);
 End;
 DepenseFixee(YCordonne,Ligne,CouleurLigne[Ligne]);
 If(CoutDepense[Ligne]>0.009)Then
 Begin
  GotoXY(51,YCordonne+3);
  Write(CoutDepense[Ligne]:12:2);
 End;
 If(ArgentBanque[Ligne]>0.009)Then
 Begin
  GotoXY(64,YCordonne+3);
  Write(ArgentBanque[Ligne]:16:2);
 End;
End;

Procedure FinList;
Begin
 BoiteCaractere(6,2,15,21,30);
 BoiteCaractere(17,2,27,21,30);
 BoiteCaractere(50,2,61,21,30);
 BoiteCaractere(63,2,78,21,30);
 YCordonne:=0;
 For Ligne:= MaxTableau-19 to MaxTableau do
 Begin
  Str(Ligne,Vs);VS:=Zero(4-Length(VS))+VS;
  Mem[$B800:8+(21+Ligne-MaxTableau)*160]:=Ord(Vs[4]);
  Mem[$B800:6+(21+Ligne-MaxTableau)*160]:=Ord(Vs[3]);
  Mem[$B800:4+(21+Ligne-MaxTableau)*160]:=Ord(Vs[2]);
  Mem[$B800:2+(21+Ligne-MaxTableau)*160]:=Ord(Vs[1]);
  TextBackGround(CouleurLigne[Ligne]div 16);
  TextColor(CouleurLigne[Ligne]Mod 16);
  GotoXY(7,YCordonne+3);
  If(Annees[Ligne]>0)Then Write(1985+Annees[Ligne]:4,SepareDate);
  GotoXY(12,YCordonne+3);
  If(Mois[Ligne]>0)Then Write(Mois[Ligne]:2,SepareDate);
  GotoXY(15,Ycordonne+3);
  If(Jour[Ligne]>0)Then Write(Jour[Ligne]:2);
  GotoXY(18,YCordonne+3);
  If(ArgentCheque[Ligne]>0.009)Then Write(ArgentCheque[Ligne]:11:2);
  DepenseFixee(YCordonne,Ligne,CouleurLigne[Ligne]);
  GotoXY(51,YCordonne+3);
  If(CoutDepense[Ligne]>0.009)Then Write(CoutDepense[ligne]:12:2);
  GotoXY(64,YCordonne+3);
  If(ArgentBanque[Ligne]>0.009)Then Write(ArgentBanque[Ligne]:16:2);
  YCordonne:=YCordonne+1;
 End;
 YCordonne:=19;
 Chaine:='';
End;

Procedure DebutList;
Begin
 BoiteCaractere(6,2,15,21,30);
 BoiteCaractere(17,2,27,21,30);
 BoiteCaractere(50,2,61,21,30);
 BoiteCaractere(63,2,78,21,30);
 Ligne:=0;
 XCordonne:=0;
 YCordonne:=0;
 For Compteur := 0 to 19 do
 Begin
  Str(Compteur,Vs);VS:=Zero(4-Length(VS))+VS;
  Mem[$B800:(4+(2+Compteur)*80)*2]:=Ord(Vs[4]);
  Mem[$B800:(3+(2+Compteur)*80)*2]:=Ord(Vs[3]);
  Mem[$B800:(2+(2+Compteur)*80)*2]:=Ord(Vs[2]);
  Mem[$B800:(1+(2+Compteur)*80)*2]:=Ord(Vs[1]);
  TextBackGround(CouleurLigne[Compteur]div 16);
  TextColor(CouleurLigne[Compteur] Mod 16);
  GotoXY(7,Compteur+3);If(Annees[Compteur]>0)Then Write(1985+Annees[Compteur]:4,SepareDate);
  GotoXY(12,Compteur+3);If(Mois[Compteur]>0)Then Write(Mois[Compteur]:2,SepareDate);
  GotoXY(15,Compteur+3);If(Jour[Compteur]>0)Then Write(Jour[Compteur]:2);
  GotoXY(18,Compteur+3);If(ArgentCheque[Compteur]>0.009)Then Write(ArgentCheque[Compteur]:11:2);
  DepenseFixee(Compteur,Compteur,CouleurLigne[Compteur]);
  GotoXY(51,Compteur+3);If(CoutDepense[Compteur]>0.009)Then Write(CoutDepense[Compteur]:12:2);
  GotoXY(64,Compteur+3);If(ArgentBanque[Compteur]>0.009)Then Write(ArgentBanque[Compteur]:16:2);
 End;
 Chaine:='';
End;

Function PositionFinList:Integer;
Label 10,Exit;
Var Compteur : Integer;
Begin
     Compteur := MaxTableau-1;
10 : Compteur := Compteur-2;
     If Compteur=0 Then Goto Exit Else
     If((Annees[Compteur]=0)And(Mois[Compteur]=0)And(Jour[Compteur]=0)And(ArgentCheque[Compteur]<0.009)And(
	(Depense[Compteur,1]=32)And
	(Depense[Compteur,2]=32)And
	(Depense[Compteur,3]=32)And
	(Depense[Compteur,4]=32)And
	(Depense[Compteur,5]=32)And
	(Depense[Compteur,6]=32)And
	(Depense[Compteur,7]=32)And
	(Depense[Compteur,8]=32)And
	(Depense[Compteur,9]=32)And
	(Depense[Compteur,10]=32)))Then
	Begin
	 If(Depense[Compteur,11]=32)Then
	 Begin
	If(Depense[Compteur,12]=32)Then
	Begin
	 If(Depense[Compteur,13]=32)Then
	 Begin
	  If(Depense[Compteur,14]=32)Then
	  Begin
	   If(Depense[Compteur,15]=32)Then
	   Begin
	    If(Depense[Compteur,16]=32)Then
	    Begin
	     If(Depense[Compteur,17]=32)Then
	     Begin
	      If(Depense[Compteur,18]=32)Then
	      Begin
	       If(Depense[Compteur,19]=32)Then
	       Begin
		If(Depense[Compteur,20]=32)Then
		Begin
		 If(CoutDepense[Compteur]<0.009)Then
		 Begin
		If(ArgentBanque[Compteur]<0.009)Then
		Goto 10;
		 End;
		End;
	       End;
	      End;
	     End;
	    End;
	   End;
	  End;
	 End;
	End;
	 End;
	End;
 Exit : PositionFinList := Compteur + 1;
End;

Procedure PrincipalEfface;
Begin
 TextColor(14);
 TextBackGround(1);
 Chaine:='';
 If((XCordonne>56)And(XCordonne<79))Then
 Begin
  ArgentBanque[Ligne]:=0.0;
  GotoXY(64,YCordonne+3);
  Write(Espace(16));
 End
  Else
 If((XCordonne>43)And(XCordonne<56))Then
 Begin
  CoutDepense[Ligne]:=0.0;GotoXY(51,YCordonne+3);
  Write(Espace(12));
 End
  else
 If((XCordonne>22)And(XCordonne<43))Then
 Begin
  FillChar(Depense[Ligne,1],20,32);
  GotoXY(30,Ycordonne+3);
  Write(Espace(20));
 End;
End;

Procedure Avance;
Begin
 XCordonne:=XCordonne+1;
 Case XCordonne of
  10 : XCordonne := 11;
  22 : XCordonne := 23;
  43 : XCordonne := 44;
  56 : XCordonne := 57;
  73 : XCordonne := 72;
 End;
 Chaine:='';
End;

Procedure Recule;
Begin
 XCordonne:=XCordonne-1;
 Case XCordonne of
  56  : XCordonne := 55;
  43  : XCordonne := 42;
  22  : XCordonne := 21;
  10  : XCordonne := 09;
  $FF : XCordonne := 00;
 End;
 Chaine:='';
End;

Procedure Descend;
Begin
 If(Ligne<MaxTableau)Then
 Begin
  Ligne:=Ligne+1;If YCordonne<19 Then YCordonne:=YCordonne+1 Else
  Begin
   InLine($B8/$01/$06/
	$B7/$1B/
	$B1/$01/
	$B5/$02/
	$B2/$04/
	$B6/$15/
	$CD/$10/
	$B8/$01/$06/
	$B7/$1E/
	$B1/$06/
	$B5/$02/
	$B2/$0F/
	$B6/$15/
	$CD/$10/
	$B8/$01/$06/
	$B7/$1E/
	$B1/$11/
	$B5/$02/
	$B2/$1B/
	$B6/$15/
	$CD/$10/
	$B8/$01/$06/
	$B7/$1E/
	$B1/$1D/
	$B5/$02/
	$B2/$30/
	$B6/$15/
	$CD/$10/
	$B8/$01/$06/
	$B7/$1E/
	$B1/$32/
	$B5/$02/
	$B2/$3D/
	$B6/$15/
	$CD/$10/
	$B8/$01/$06/
	$B7/$1E/
	$B1/$3F/
	$B5/$02/
	$B2/$4E/
	$B6/$15/
	$CD/$10);
	Str(Ligne,Vs);
	VS:=Zero(4-Length(VS))+VS;
	Mem[$B8D2:8]:=Ord(Vs[4]);
	Mem[$B8D2:6]:=Ord(Vs[3]);
	Mem[$B8D2:4]:=Ord(Vs[2]);
	Mem[$B8D2:2]:=Ord(Vs[1]);
	lArtDesCross;
  End;
 End;
 Chaine := '';
End;

Procedure Monte;
Begin
 If(Ligne>0)Then
 Begin
  Ligne:=Ligne-1;If(YCordonne>0)Then YCordonne:=YCordonne-1 Else
  Begin
   InLine($B8/$01/$07/$B7/$1B/$B1/$01/$B5/$02/$B2/$04/$B6/$15/$CD/$10/$B8/$01/$07/$B7/$1E/$B1/$06/$B5/$02/$B2/$0F/$B6/$15/
	$CD/$10/$B8/$01/$07/$B7/$1E/$B1/$11/$B5/$02/$B2/$1B/$B6/$15/$CD/$10/$B8/$01/$07/$B7/$1E/$B1/$1D/$B5/$02/$B2/$30/$B6/$15/
	$CD/$10/$B8/$01/$07/$B7/$1E/$B1/$32/$B5/$02/$B2/$3D/$B6/$15/$CD/$10/$B8/$01/$07/$B7/$1E/$B1/$3F/$B5/$02/$B2/$4E/$B6/$15/
	$CD/$10);
   Str(Ligne,Vs);
   VS:=Zero(4-Length(VS))+VS;
   Mem[$B814:8]:=Ord(VS[4]);
   Mem[$B814:6]:=Ord(VS[3]);
   Mem[$B814:4]:=Ord(VS[2]);
   Mem[$B814:2]:=Ord(VS[1]);
   lArtDesCross;
  End;
 End;
 Chaine:='';
End;

Procedure BackSpace;
Begin
 If((XCordonne>22)And(XCordonne<43))Then
 Begin
  Mem[Seg(Depense[Ligne]):Ofs(Depense[Ligne])+(XCordonne-22)]:=32;
  EcritUnCaractere(6+XCordonne,2+YCordonne,32,CouleurLigne[Ligne]);
  Recule;
 End;
End;

Procedure ImprimeListe;
Label 10,15,17,20,25,27,Exit;
Var Compteur,A,B,Erreur : Integer;
    Cobaye              : String[10];
    CompteurB           : 1..20;
Begin
 Move(Mem[$B800:0000],Mem[$B800:12000],4000);
 CadrePlain(5,4,74,19,47,1);
 CentreEcriture(7,'Imprime la Liste',46);
 10   : Localise(11,10);
	Ecrit('J''imprime de la ligne :     ',47);
	Cobaye:='';
 15   : Localise(34,10);
	Ecrit(Cobaye+' ',46);
	InLine($B8/$01/$00/ { MOV AX,0001 }
	     $CD/$33/     { INT 33      }

	     $B4/$01/     { MOV AH,01   }
	     $B1/$07/     { MOV CL,07   }
	     $B5/$06/     { MOV CH,06   }
	     $CD/$10);    { INT 10      }
 17   : CrossI;
	If Not(KeyPressed)Then Goto 17;
	Touche := ReadKey;
	InLine($B4/$01/     { MOV AH,01   }
	     $B1/$07/     { MOV CL,07   }
	     $B5/$08/     { MOV CH,08   }
	     $CD/$10/     { INT 10      }

	     $B8/$02/$00/ { MOV AX,0002 }
	     $CD/$33);    { INT 33      }
	If Not(Touche in ['0'..'9',^E,#27,#13])Then Goto 15;
	If(Touche=#27)Then Goto Exit;
	If(Touche=^E)Then Goto 10;
	If Not((Touche=#13)or(Length(Cobaye)>3))Then
	Begin
	 Cobaye := Cobaye+Touche;
	 Goto 15;
	End;
	Val(Cobaye,A,Erreur);
	If(A>MaxTableau)or(A<0)Then Goto 10;
 20   : Cobaye := '';
	Localise(11,12);
	Ecrit('a la ligne :     ',47);
 25   : Localise(24,12);
	Ecrit(Cobaye+' ',46);
	InLine($B8/$01/$00/ { MOV AX,0001 }
	     $CD/$33/     { INT 33      }

	     $B4/$01/     { MOV AH,01   }
	     $B1/$07/     { MOV CL,07   }
	     $B5/$06/     { MOV CH,06   }
	     $CD/$10);    { INT 10      }
 27   : CrossI;
	If Not(KeyPressed)Then Goto 27;
	Touche := ReadKey;
	InLine($B8/$02/$00/ { MOV AX,0002 }
	     $CD/$33/     { INT 33      }

	     $B4/$01/     { MOV AH,01   }
	     $B1/$07/     { MOV CL,07   }
	     $B5/$08/     { MOV CH,08   }
	     $CD/$10);    { INT 10      }
	If Not(Touche in ['0'..'9',^E,#27,#13])Then Goto 25;
	If(Touche=#27)Then Goto Exit;
	If(Touche=^E)Then Goto 20;
	If Not((Touche=#13)or(Length(Cobaye)>3))Then
	Begin
	 Cobaye := Cobaye + Touche;
	 Goto 25;
	End;
	Val(Cobaye,B,Erreur);
	If(Erreur <> 0)Then Goto Exit;
	If(B<A)or(B>MaxTableau)Then Goto 20;
	CadrePlain(10,8,70,17,127,1);
	CentreEcriture(11,'Je procede a l''imprimage',126);
	Write(Lst,#14+#18+#15+#16+'Ú');
	For Compteur := 0 to 62 do Write(Lst,'Ä');
	WriteLn(Lst,'¿');
	WriteLn(Lst,#14+#18+#15+#16+'³           '+#14+#18+'Budjet Sylvain Maltais  '+#14+#18+#15+#16+'         ³');
	Write(Lst,#14+#18+#15+#16+'À');
	For Compteur:=0 to 62 do Write(Lst,'Ä');
	WriteLn(Lst,'Ù');
	For Compteur:=0 to 78 do Write(Lst,'Â');
	WriteLn(Lst);
	For Compteur := A to B do
	Begin
	 Str(Compteur,Cobaye);
	 Cobaye:=Cobaye+'   ';
	 Localise(31,13);
	 Ecrit('Ligne = ',127);
	 Ecrit(Cobaye,123);
	 Write(Lst,Compteur:4,'³');
	 If(Annees[Compteur]>0)Then
	 Write(Lst,(1985+Annees[Compteur]):4,SepareDate) Else
	 Write(Lst,'     ');
	 If(Mois[Compteur]>0)Then
	 Write(Lst,Mois[Compteur]:2,SepareDate) Else
	 Write(Lst,'   ');
	 If(Jour[Compteur]>0)Then
	 Write(Lst,Jour[Compteur]:2) Else
	 Write(Lst,'  ');
	 Write(Lst,'³');
	 If(ArgentCheque[Compteur]>0.009)Then
	 Write(Lst,ArgentCheque[Compteur]:11:2) Else
	 Write(Lst,'           ');
	 Write(Lst,'³');
	 For CompteurB := 1 to 20 do
	  Write(Lst,Chr(Depense[Compteur,CompteurB]));
	 Write(Lst,'³');
	 If(CoutDepense[Compteur]>0.009)Then
	 Write(Lst,CoutDepense[Compteur]:12:2) Else
	 Write(Lst,'            ');
	 Write(Lst,'³');
	 If(ArgentBanque[Compteur]>0.009)Then
	 Write(Lst,ArgentBanque[Compteur]:16:2) Else
	 Write(Lst,'                ');
	 WriteLn(Lst);
	End;
	For Compteur:=0 to 78 do Write(Lst,'Á');
	WriteLn(Lst);
 Exit : Move(Mem[$B800:12000],Mem[$B800:0000],4000);
End;

Procedure InitialiseTableau;
Label 10,20,Exit;
Var X,Y,Bout : Integer;
Begin
 InLine($B8/$02/$00/ { MOV AX,0002 }
	$CD/$33);    { INT 33      }
 Move(Mem[$B800:0000],Mem[$B800:4000],4000);
 CadrePlain(10,7,70,16,79,1);
 CentreEcriture(9,'Nouveau',206);
 CentreEcriture(11,'Es-tu certain de vouloir Effacer les donnees ?',79);
 Localise(22,13);
 Ecrit('Oui       Non',78);
 CadreVide(20,12,26,14,79,1);
 CadreVide(30,12,36,14,79,0);
 InLine($B8/$00/$00/ { MOV AX,0000 }
	$CD/$33/     { INT 33      }
	$B8/$01/$00/ { MOV AX,0001 }
	$CD/$33);    { INT 33      }
 10   : CrossI;
	PositionetBouton(X,Y,Bout);
	If((X>160)and(X<26*8)and(Y>96)and(Y<14*8)and(Bout=1))Then Goto 20;
	If((X>240)and(X<36*8)and(Y>96)and(Y<14*8)and(Bout=1))Then
	Begin
	 InLine($B8/$02/$00/$CD/$33);
	 Goto Exit;
	End;
	If Not(KeyPressed)Then Goto 10;
	Touche := ReadKey;
	If(KeyPressed)Then Goto 10;
	If((UpCase(Touche)='N')or(Touche=#27))Then Goto Exit Else
	If((UpCase(Touche)='O')or(UpCase(Touche)='Y'))Then Goto 20;
	Goto 10;
 20   : Nouveau;
 Exit : InLine($B8/$02/$00/ { MOV AX,0002 }
	     $CD/$33);    { INT 33      }
	Move(Mem[$B800:4000],Mem[$B800:0000],4000);
	DebutList;
End;

Procedure AjusteCouleur;
Label 10,Rep,Quit;
Var X,Y      : Byte;
    X1,Y1    : Integer;
    Tableau  : Array[0..4001]of Byte;
    Tableau2 : Array[0..4001]of Byte;
Begin
 Move(Mem[$B800:0000],Tableau[1],4000);
 CadrePlain(4,0,76,22,31,1);
 Localise(11,2);
 TextColor(15);
 TextBackGround(1);
 Write('Ligne :');
 TextColor(11);
 Write(Ligne:5);
 TextColor(15);
 Write(' Couleur de Fond :     Couleur Ecriture : ');
 Couleur:=CouleurLigne[Ligne]mod 16;
 CadreVide(14,3,63,20,31,0);
 For X:=0 to 15 do For Y:=0 to 15 do
 Begin
  Mem[$B800:((4+Y)*80+15+X*3)*2+1]:=X*16+Y;
  Mem[$B800:((4+Y)*80+16+X*3)*2+1]:=X*16+Y;
  Mem[$B800:((4+Y)*80+17+X*3)*2+1]:=X*16+Y;
  Mem[$B800:((4+Y)*80+16+X*3)*2]:=120;
 End;
 X := CouleurLigne[Ligne]div 16;
 Y := Couleur;
 CadreVide(65,8,73,10,31,0);
 TextColor(14);
 TextBackGround(1);
 GotoXY(67,10);
 Write('Correct');
 CadreVide(65,12,73,14,31,0);
 GotoXY(67,14);
 Write('Retire');
 10  : Move(Mem[$B800:0],Tableau2[1],4000);
       Localise(41,2);
       Ecrit('ÛÛÛ',X);
       Localise(64,2);
       Ecrit('ÛÛÛ',Y);
       CadreVide(14+X*3,3+Y,18+X*3,5+Y,15,0);
       InLine($B8/$01/$00/ { MOV AX,0001 }
	    $CD/$33);    { INT 33      }
 Rep : CrossI;
       PositionetBouton(X1,Y1,Bout);
       If((Y1>3*8)And(Y1<20*8)And(X1>13*8)And(X1<63*8)And(Bout<>0))Then
       Begin
	Y:=(Y1 div 8)-4;
	X:=((X1 div 8)-18)div 3+1;
	InLine($B8/$02/$00/ { MOV AX,0002 }
	     $CD/$33);    { INT 33      }
	Move(Tableau2[1],Mem[$B800:0],4000);
	Goto 10;
       End Else
       If((X1>65*8)And(Y1>64)And(X1<73*8)And(Y1<80)And(Bout=1))Then
       Begin
	Touche:=#13;
	Goto Quit;
       End Else
       If((X1>65*8)And(Y1>12*8)And(X1<73*8)And(Y1<14*8)And(Bout=1))Then
       Begin
	Touche:=#27;
	Goto Quit;
       End;
       If KeyPressed=False Then Goto Rep;
    Touche := ReadKey;
    InLine($B8/$02/$00/ { MOV AX,0002 }
	 $CD/$33);    { INT 33      }
    Move(Tableau2[1],Mem[$B800:$00],4000);
    If KeyPressed Then
    Begin
     Touche := ReadKey;
     Case Touche of
      'H' : Y:=(Y-1)And 15;
      'P' : Y:=(Y+1)And 15;
      'K' : X:=(X-1)And 15;
      'M' : X:=(X+1)And 15;
     End;
    End;
    If Not((Touche=#13)or(Touche=#27))Then Goto 10;
 Quit : If(Touche=#13)Then CouleurLigne[Ligne]:=16*X+Y;
 InLine($B8/$02/$00/ { MOV AX,0002 }
	$CD/$33);    { INT 33      }
 Move(Tableau[1],Mem[$B800:$00],4000);
 lArtDesCross;
End;

Procedure Calculatrice;
Label 10,Exit;
Var ErreurNature          : Integer;
    Cobaye,Somme          : Real;
    MauditVache           : String[255];
    Operation             : Char;
Begin
       InLine($B8/$02/$00/ { MOV AX,0002 }
	    $CD/$33);    { INT 33      }
       Move(Mem[$B800:0000],Mem[$B800:12000],4000);
       Cobaye := $00;
       Somme  := $00;
       BoiteCaractere(0,1,21,23,63);
       CadreVide(0,1,21,23,63,1);
       TextColor(15);
       TextBackGround(1);
       MauditVache := '';
       Operation   := #0;
       GotoXY(8,15);Write(' ( ');
       GotoXY(13,15);Write(' ) ');
       GotoXY(18,15);Write(' ö ');
       GotoXY(3,17);Write(' 7 ');
       GotoXY(8,17);Write(' 8 ');
       GotoXY(13,17);Write(' 9 ');
       GotoXY(18,17);Write(' x ');
       GotoXY(3,19);Write(' 4 ');
       GotoXY(8,19);Write(' 5 ');
       GotoXY(13,19);Write(' 6 ');
       GotoXY(18,19);Write(' - ');
       GotoXY(3,21);Write(' 1 ');
       GotoXY(8,21);Write(' 2 ');
       GotoXY(13,21);Write(' 3 ');
       GotoXY(18,21);Write(' + ');
       GotoXY(3,23);Write(' 0 ');
       GotoXY(8,23);Write(' . ');
       GotoXY(13,23);Write('+/-');
       GotoXY(18,23);Write(' = ');
       InLine($B8/$00/$00/ { MOV AX,0000 }
	    $CD/$33/     { INT 33      }
	    $B8/$01/$00/ { MOV AX,0001 }
	    $CD/$33);    { INT 33      }
       GotoXY(3,4);
       Write(Somme:18:2);
10   : PositionetBouton(X,Y,Bout);
       CrossI;
       If Not(KeyPressed)Then Goto 10;
       Touche := ReadKey;
       If(KeyPressed)Then
       Begin
	Touche := ReadKey;
	If(Touche='S')Then
	Begin
	 MauditVache := '';
	 Cobaye      := $00;
	 Somme       := $00;
	End;
       End;
       If(Touche in ['+','-','/','X','*','x',#13,'='])Then
       Begin
	Case Operation of
	 '+' : Somme := Somme + Cobaye;
	 '-' : Somme := Somme - Cobaye;
	 'ö' : Somme := Somme / Cobaye;
	 'x' : Somme := Somme * Cobaye;
	 #0  : Somme := Cobaye;
	End;
	MauditVache:='';
	If(Touche in ['x','X','*'])Then Operation:='x' Else
	If(Touche = '+')Then Operation := '+' Else
	If(Touche = '-')Then Operation := '-' Else
	If(Touche = '/')Then Operation := 'ö' Else
	If(Touche = #13)or(Touche = '=')Then Operation:=#0;
       End;
       If(Touche = #8)Then Delete(MauditVache,1,1);
       If(Touche = #27)Then Goto Exit;
       If((Touche >= '0')and(Touche <= '9'))or(Touche = '.')Then
	MauditVache := MauditVache+Touche;
       If(MauditVache <> '')Then
       Begin
	Val(MauditVache,Cobaye,ErreurNature);
	GotoXY(3,4);
	Write(Cobaye:18:2);
       End
	Else
       Begin
	GotoXY(3,4);Write(Somme:18:2);
       End;
       Goto 10;
 Exit : Move(Mem[$B800:12000],Mem[$B800:0000],4000);
End;

Procedure InfoBudjet;
Label 0,10,Exit;

Var Chaine   : String[15];
    Compteur : Byte;

Begin
 0    : Chaine:=#19+#57+#44+#54+#33+#41+#46+#0+#13+#33+#44+#52+#33+#41+#51;
	For Compteur:=1 to 15 do
	If Not(Mem[Seg(Chaine):Ofs(Chaine)+Compteur]=0)Then
	 Mem[Seg(Chaine):Ofs(Chaine)+Compteur]:=64+Mem[Seg(Chaine):Ofs(Chaine)+Compteur]
	Else
	 Mem[Seg(Chaine):Ofs(Chaine)+Compteur]:=32;
	InLine($B8/$02/$00/ { MOV AX,0002 }
	     $CD/$33);    { INT 33      }
	CadrePlain(5,2,72,19,63,0);
	For Compteur := 1 to 7 do
	BoiteCaractere(40-Compteur*4,12-Compteur,40+Compteur*4,12+Compteur,47);
	CadrePlain(9,3,70,21,47,1);
	CentreEcriture(5,'Info - Budjet',46);
	Localise(14,7);
	Ecrit('Programmeur :',46);
	Localise(19,9);Ecrit(Chaine,47);
	Localise(14,11);Ecrit('Graphique & Dessin :',46);
	Localise(19,13);Ecrit(Chaine,47);
	InLine($B8/$01/$00/ { MOV AX,0001 }
	     $CD/$33);    { INT 33      }
 10   : PositionetBouton(X,Y,Bout);
	If(Bout=1)Then Goto Exit;
	If KeyPressed=False Then
	Begin
	 CrossI;
	 Goto 10;
	End;
	InLine($B4/$07/     { MOV AH,07 }
	       $CD/$21);    { INT 21    }
 Exit :
End;

Begin
 Presentation;
 InLine($B8/$03/$00/    { MOV AX,0003 }
	$CD/$10/        { INT 10      }

	$B4/$01/        { MOV AH,01   }
	$B1/$07/        { MOV CL,07   }
	$B5/$08/        { MOV CH,08   }
	$CD/$10/        { INT 10      }

	$B8/$02/$00/    { MOV AX,0002 }
	$CD/$33/        { INT 33      }

	$B8/$00/$00/    { MOV AX,0000 }
	$CD/$33);       { INT 33      }
 LimiteX(0,639);
 LimiteY(0,199);
 For Compteur:=1 to 6 do
  BoiteCaractere(40-Compteur*4,12-Compteur div 3,40+Compteur*4,12+Compteur div 3,63);
 CadrePlain(10,9,70,15,63,1);
 CentreEcriture(12,'Un instant S.V.P je charge mes donn‚es',62);
 InLine($B8/$01/$00/    { MOV AX,0001 }
	$CD/$33);       { INT 33      }
 InitiationConfiguration;
Debut : Nouveau;
	InLine($B8/$03/$00/ { MOV AX,0003 }
	     $CD/$10/     { INT 10      }

	     $B4/$01/     { MOV AH,01   }
	     $B1/$07/     { MOV CL,07   }
	     $B5/$08/     { MOV CH,08   }
	     $CD/$10/     { INT 10      }

	     $B8/$19/$06/ { MOV AX,0619 }
	     $B7/$1F/     { MOV BH,1F   }
	     $B1/$00/     { MOV CL,00   }
	     $B5/$00/     { MOV CH,00   }
	     $B2/$4F/     { MOV DL,4F   }
	     $B6/$19/     { MOV DH,19   }
	     $CD/$10);    { INT 10      }

	(* HiresColor(CouleurBordure); *)
	ClaireColonne(0,179,31);
	ClaireColonne(79,179,31);
	ClaireLigne(0,219,127);
	BoiteCaractere(1,2,4,21,27);
	Localise(2,1);
	Ecrit('no ³   Date   ³  Retrait  ³      Remarque      ³    Depot   ³     Solde',30);
	Mem[$B80A:$0B] := 31;
	Mem[$B80C:$01] := 31;
	Mem[$B80D:$09] := 31;
	Mem[$B810:$03] := 31;
	Mem[$B811:$0D] := 31;
	ClaireLigne(24,219,127);
	For Compteur := 2 to 21 do
	Begin
	 EcritUnCaractereSansAttributPage0(5,Compteur,179);
	 EcritUnCaractereSansAttributPage0(16,Compteur,179);
	 EcritUnCaractereSansAttributPage0(28,Compteur,179);
	 EcritUnCaractereSansAttributPage0(49,Compteur,179);
	 EcritUnCaractereSansAttributPage0(62,Compteur,179);
	End;
	ClaireLigne(22,193,31);
	EcritUnCaractereSansAttributPage0(0,22,195);
	Mem[$B8EF:$09] := 27;
	Mem[$B8EF:$0B] := 27;
	Mem[$B8EF:$06] := 58;
	Mem[$B8EF:$05] := 27;
	Mem[$B8EF:$03] := 27;
	Mem[$B8EF:$00] := 58;
	Mem[$B8EE:$0F] := 27;
	Mem[$B8EE:$0D] := 27;
	Mem[$B8DE:$0A] := 197;
	Mem[$B8E0:$06] := 197;
	Mem[$B8E3:$08] := 197;
	EcritUnCaractere(79,22,180,31);
	Localise(9,23);
	Ecrit('Ligne :     ³ Colonne :   ³ Fichier :              ³ Heure :',31);
	Localise(47,23);
	Ecrit('PasNom  .BSM',27);
	Mem[$B8E8:$09] := 27;
	Mem[$B8E8:$07] := 27;
	Mem[$B8E8:$05] := 27;
	Mem[$B8E8:$03] := 27;
	Mem[$B8EA:$03] := 27;
	Mem[$B8EA:$05] := 27;
	DebutList;
	InLine($B8/$00/$00/
	       $CD/$33);
 10   : Str(Ligne,Vs);
	VS := Zero(4-Length(VS))+VS;
	Mem[$B8E8:$08] := Ord(Vs[4]);
	Mem[$B8E8:$06] := Ord(Vs[3]);
	Mem[$B8E8:$04] := Ord(Vs[2]);
	Mem[$B8E8:$02] := Ord(Vs[1]);
	Str(XCordonne,Vs);
	VS := Zero(2-Length(VS))+VS;
	Mem[$B8EA:$02] := Ord(VS[1]);
	Mem[$B8EA:$04] := Ord(VS[2]);
	Localise(6+XCordonne,2+YCordonne);
	InLine($B4/$01/     { MOV AH,01   }
	       $B9/$07/$06/ { MOV CX,0607 }
	       $CD/$10/     { INT 10      }

	       $B8/$01/$00/ { MOV AX,0001 }
	       $CD/$33);    { INT 33      }

	Mem[$B8DC:XCordonne*2+13] := 14;

 20   : Compteur := (Compteur + 1) and $FF;
	If(Compteur = 5)Then
	Begin
	 Registre.AH := $2C;
	 MSDos(Registre);
	 Str(Registre.CH,Heur);
	 If(Length(Heur)<2)Then Heur:=' '+Heur;
	 Str(Registre.CL,Minute);
	 If(Length(Minute)<2)Then Minute:='0'+Minute;
	 Str(Registre.DH,Seconde);
	 If(Length(Seconde)<2)Then Seconde:='0'+Seconde;
	 Heures := Heur+Minute+Seconde;
	 Mem[$B800:3820] := Ord(Heures[1]);
	 Mem[$B800:3822] := Ord(Heures[2]);
	 Mem[$B800:3826] := Ord(Heures[3]);
	 Mem[$B800:3828] := Ord(Heures[4]);
	 Mem[$B800:3832] := Ord(Heures[5]);
	 Mem[$B800:3834] := Ord(Heures[6]);
	End;
	If(Compteur = 126)Then
	Begin
	PositionetBouton(X,Y,Bout);
	If(Bout=1)And((Y>168)And(Y<184))Then
	Begin
	 Cross31;
	 VS:=Chr(Mem[$B8D2:2])+Chr(Mem[$B8D2:4])+Chr(Mem[$B8D2:6])+Chr(Mem[$B8D2:8]);
	 Val(VS,Somme,Cobaye);
	 Ligne     := Somme;
	 YCordonne := 19;
	 XCordonne := 0;
 30    : For X:=0 to 2 do Descend;
	 Localise(6+XCordonne,2+YCordonne);
	 PositionEtBouton(X,Y,Bout);
	 If(Bout=1)And((Y>168)And(Y<184))Then Goto 30;
	 Str(Ligne,VS);
	 VS := Zero(4-Length(VS))+VS;
	 Mem[$B8E8:$08] := Ord(Vs[4]);
	 Mem[$B8E8:$06] := Ord(Vs[3]);
	 Mem[$B8E8:$04] := Ord(Vs[2]);
	 Mem[$B8E8:$02] := Ord(Vs[1]);
	 Cross14;
	 Goto 20;
	End
	 else
	If(Bout=2)And((Y>168)And(Y<184))Then
	Begin
	 Cross31;
	 VS:=Chr(Mem[$B8D2:2])+Chr(Mem[$B8D2:4])+Chr(Mem[$B8D2:6])+Chr(Mem[$B8D2:8]);
	 Val(VS,Somme,Cobaye);
	 Ligne     := Somme;
	 YCordonne := 19;
	 XCordonne := 0;
 40    : For X := 0 to 9 do Descend;
	 GotoXY(7+XCordonne,3+YCordonne);
	 PositionetBouton(X,Y,Bout);
	 If(Bout=2)And((Y>168)And(Y<184))Then Goto 40;
	 Str(Ligne,VS);
	 VS:=Zero(4-Length(VS))+VS;
	 Mem[$B8E8:$08] := Mem[Seg(VS):Ofs(VS)+4];
	 Mem[$B8E8:$06] := Mem[Seg(VS):Ofs(VS)+3];
	 Mem[$B8E8:$04] := Mem[Seg(VS):Ofs(VS)+2];
	 Mem[$B8E8:$02] := Mem[Seg(VS):Ofs(VS)+1];
	 Cross14;
	 Goto 20;
	End
	 else
	If(Bout=1)Then
	Begin
	 If(((X>40)And(X<128)And(Y>8)And(Y<175))or
	 ((X>128)And(X<224)And(Y>8)And(Y<175))or
	 ((X>224)And(X<392)And(Y>8)And(Y<175))or
	 ((X>392)And(X<496)And(Y>8)And(Y<175))or
	 ((X>496)And(X<632)And(Y>8)And(Y<175)))Then
	 Begin
	Cross31;
	PositionetBouton(X,Y,Bout);
	XCordonne := (X div 8)-6;
	YCordonne := (Y div 8)-2;
	VS[1] := Chr(Mem[$B814:2+YCordonne*160]);
	VS[2] := Chr(Mem[$B814:4+YCordonne*160]);
	VS[3] := Chr(Mem[$B814:6+YCordonne*160]);
	VS[4] := Chr(Mem[$B814:8+YCordonne*160]);
	Val(Vs,Somme,Cobaye);
	Ligne:=Somme;
	 End;
	 TextColor(11);
	 TextBackGround(1);
	 Str(Ligne,VS);
	 GotoXY(18,24);
	 Write(Zero(4-Length(VS)),Ligne);
	 GotoXY(34,24);
	 Str(XCordonne,Vs);
	 Write(Zero(2-Length(VS)),XCordonne);
	 GotoXY(7+XCordonne,3+YCordonne);
	 Cross14;
	 Chaine:='';
	End
	 else
	If(Bout=2)Then
	Begin
	 If(((X>40)And(X<128)And(Y>8)And(Y<175))or
	 ((X>128)And(X<224)And(Y>8)And(Y<175))or
	 ((X>224)And(X<392)And(Y>8)And(Y<175))or
	 ((X>392)And(X<496)And(Y>8)And(Y<175))or
	 ((X>496)And(X<632)And(Y>8)And(Y<175)))Then
	 Begin
	Cross31;
	XCordonne:=(X div 8)-6;
	YCordonne:=(Y div 8)-2;
	VS[1]:=Chr(Mem[$B814:2+YCordonne*160]);
	VS[2]:=Chr(Mem[$B814:4+YCordonne*160]);
	VS[3]:=Chr(Mem[$B814:6+YCordonne*160]);
	VS[4]:=Chr(Mem[$B814:8+YCordonne*160]);
	Val(Vs,Somme,Cobaye);
	Ligne:=Somme;
	TextColor(11);
	TextBackGround(1);
	GotoXY(18,24);
	Write(Zero(4-Length(VS)),Ligne);
	GotoXY(34,24);
	Str(XCordonne,Vs);
	Write(Zero(2-Length(VS)),XCordonne);
	GotoXY(7+XCordonne,3+YCordonne);
	Chaine := '';
	AjusteCouleur;
	Cross14;
	 End;
	End;
	If(Bout=1)And(Y<8)Then
	Begin
			(* Menu Principal *)
 50    : Cross31;
	 Move(Mem[$B800:0],Mem[$B8FA:0],$0FA0);
	 For Compteur := 1 to 7 do
	BoiteCaractere(40-Compteur*4,12-Compteur,40+Compteur*4,12+Compteur,63);
	 CadrePlain(5,2,72,19,63,1);
	 TextBackGround(3);
	 CentreEcriture(4,'Menu Principal',62);
	 CentreEcriture(6,'Ajustement',63);
	 CentreEcriture(7,'Nouveau',63);
	 CentreEcriture(8,'Imprime',63);
	 CentreEcriture(9,'Calculatrice',63);
	 CentreEcriture(10,'Fichier',63);
	 CentreEcriture(11,'Info-Budjet',63);
	 CentreEcriture(12,'Quitter',63);
	 TextColor(14);
	 CadreVide(10,14,18,16,63,1);
	 GotoXY(12,16);
	 Write('Correct');
	 CadreVide(20,14,28,16,63,0);
	 GotoXY(22,16);
	 Write('Retire');
	 Mem[$B9F4:0]:=0;
	 InLine($B8/$00/$00/ { MOV AX,0000 }
	      $CD/$33);    { INT 33      }
 60    : For Compteur:=30 to 50 do
	 Mem[$B83C:(Compteur+Mem[$B9F4:0]*80)*2+1]:=94;
	 InLine($B8/$01/$00/ { MOV AX,0001 }
	      $CD/$33);    { INT 33      }
 70    : CrossI;
	 PositionetBouton(X,Y,Bout);
	 If((Bout=1)And((X>80)And(Y>112)And(X<144)And(Y<128)))Then
	 Begin
	Goto 80;
	 End
	else
	 If((Bout=1)And((X>160)And(Y>112)And(X<224)And(Y<128)))Then
	 Begin
	Goto 110;
	 End
	else
	 If((Bout=1)And(Y>40)And(Y<104)And(X>232)And(X<408))Then
	 Begin
	InLine($B8/$02/$00/  { MOV AX,0002 }
		 $CD/$33); { INT 33      }
	For Compteur := 30 to 50 do
	Mem[$B83C:(Compteur+Mem[$B9F4:0]*80)*2+1]:=63;
	Mem[$B9F4:0]:=(Y div 8)-6;
	Goto 60;
	 End;
	 If Not(KeyPressed)Then Goto 70;
	 Touche := ReadKey;
	 InLine($B8/$02/$00/ { MOV AX,0002 }
		$CD/$33);    { INT 33      }
	 For Compteur := 30 to 50 do
	 Mem[$B83C:(Compteur+Mem[$B9F4:0]*80)*2+1]:=63;
	 If KeyPressed Then
	 Begin
	Touche := ReadKey;
	Case Touche of
	 'P' : Begin
		Mem[$B9F4:0]:=Mem[$B9F4:0]+1;
		If(Mem[$B9F4:0]>6)Then Mem[$B9F4:0]:=0;
	       End;
	 'H' : Begin
		If(Mem[$B9F4:0]=0)Then Mem[$B9F4:0]:=6
		 else
		Mem[$B9F4:0]:=Mem[$B9F4:0]-1;
	       End;
	 'G' : Mem[$B9F4:0]:=0;
	 'O' : Mem[$B9F4:0]:=6;
	End;
	 End
	else
	 Case Touche of
	#13 : Begin
 80            : If(Mem[$B9F4:0]=0)Then
	       Begin
		Ajustement;
		Goto 60;
	       End;
	       If(Mem[$B9F4:0]=1)Then
	       Begin
		Move(Mem[$B8FA:0],Mem[$B800:0000],$0FA0);
		InitialiseTableau;
		Goto 10;
	       End;
	       If(Mem[$B9F4:0]=2)Then
	       Begin
		ImprimeListe;
		Goto 60;
	       End;
	       If(Mem[$B9F4:0]=3)Then Goto 110;
	       If(Mem[$B9F4:0]=4)Then
	       Begin
		Move(Mem[$B8FA:0],Mem[$B800:0],$0FA0);
		ChoisisFichier;
		DebutList;
		Goto 10;
	       End;
	       If(Mem[$B9F4:0]=5)Then
	       Begin
		InfoBudjet;
		Goto 110;
	       End;
	       If(Mem[$B9F4:0]=6)Then
	       Begin
 90             : InLine($B8/$02/$00/ { MOV AX,0002 }
		     $CD/$33);    { INT 33      }
		Move(Mem[$B800:0],Mem[$BA00:0],$0FA0);
		If(Mem[$B9F4:0]<$FF)Then CadrePlain(5,2,72,19,63,0);
		CadrePlain(15,7,65,16,79,1);
		CentreEcriture(9,'Danger !!',206);
		CentreEcriture(11,'Es-tu certain de vouloir Quitter ?',79);
		Localise(22,13);
		Ecrit('Oui       Non',78);
		CadreVide(20,12,26,14,79,1);
		CadreVide(30,12,36,14,79,0);
		InLine($B8/$00/$00/ { MOV AX,0000 }
		     $CD/$33/     { INT 33      }
		     $B8/$01/$00/ { MOV AX,0001 }
		     $CD/$33);    { INT 33      }
 100            : CrossI;
		PositionetBouton(X,Y,Bout);
		If((X>160)and(X<208)and(Y>96)and(Y<112)and(Bout=1))Then Goto Exit;
		If((X>240)and(X<288)and(Y>96)and(Y<112)and(Bout=1))Then
		Begin
		 InLine($B8/$02/$00/ { MOV AX,0002 }
		      $CD/$33);    { INT 33      }
		 Move(Mem[$BA00:0],Mem[$B800:0],$0FA0);
		 If(Mem[$B9F4:0]=$FF)Then Goto 10
		else
		 Goto 60;
		End;
		If Not(KeyPressed)Then Goto 100;
		Touche := ReadKey;
		InLine($B8/$02/$00/ { MOV AX,0002 }
		     $CD/$33);    { INT 33      }
		If Not((UpCase(Touche)='O')or(UpCase(Touche)='Y'))Then
		Begin
		 Move(Mem[$BA00:0],Mem[$B800:0],$0FA0);
		 If(Mem[$B9F4:0]=$FF)Then Goto 10 Else Goto 60;
		End;
		Quitter;
	       End;
	      End;
	#27 : Goto 110;
	     End;
	     Goto 60;
    110    : InLine($B8/$02/$00/ { MOV AX,0002 }
		    $CD/$33);    { INT 33      }
	     Move(Mem[$B8FA:0],Mem[$B800:0],$0FA0);
	     If(Mem[$B9F4:0]=3)Then Calculatrice;
	     Cross14;
	     Goto 10;
	End;
	End;
	If Not(KeyPressed)Then Goto 20;
	Touche := ReadKey;
	Inline($B4/$01/     { MOV AH,01   }
	       $B9/$07/$08/ { MOV CX,0807 }
	       $CD/$10/     { INT 10      }

	       $B8/$02/$00/ { MOV AX,0002 }
	       $CD/$33);    { INT 33      }

	Mem[$B8DC:XCordonne*2+13] := 31;
  If KeyPressed Then
  Begin
   Touche := ReadKey;
   Case Touche of
    #23 : ImprimeListe;
    #25 : StationneDisqueDur;
    '!' : Begin
	 X := PositionFinList;
	 If X>MaxTableau-11 Then FinList Else
	 If X<MinTableau+11 Then DebutList Else
	 Begin
	  YCordonne := 9;
	  Ligne     := X-10;
	  InLine($B4/$01/  { MOV AH,01 }
		 $B1/$07/  { MOV CL,07 }
		 $B5/$08/  { MOV CH,08 }
		 $CD/$10); { INT 10    }
	  BoiteCaractere(6,2,15,21,30);
	  BoiteCaractere(17,2,27,21,30);
	  BoiteCaractere(50,2,61,21,30);
	  BoiteCaractere(63,2,78,21,30);
	  For Compteur:=0 to 19 do
	  Begin
	   Ligne := Ligne + 1;
	   Str(Ligne,Vs);VS:=Zero(4-Length(VS))+VS;
	   Mem[$B814:8+Compteur*160]:=Ord(Vs[4]);
	   Mem[$B814:6+Compteur*160]:=Ord(Vs[3]);
	   Mem[$B814:4+Compteur*160]:=Ord(Vs[2]);
	   Mem[$B814:2+Compteur*160]:=Ord(Vs[1]);
	   TextBackGround(CouleurLigne[Ligne]div 16);
	   TextColor(CouleurLigne[Ligne] Mod 16);
	   GotoXY(7,Compteur+3);
	   If(Annees[Ligne]>0)Then Write(1985+Annees[Ligne]:4,SepareDate);
	   GotoXY(12,Compteur+3);
	   If(Mois[Ligne]>0)Then Write(Mois[Ligne]:2,SepareDate);
	   GotoXY(15,Compteur+3);
	   If(Jour[Ligne]>0)Then Write(Jour[Ligne]:2);
	   GotoXY(18,Compteur+3);
	   If(ArgentCheque[Ligne]>0.009)Then Write(ArgentCheque[Ligne]:11:2);
	   DepenseFixee(Compteur,Ligne,CouleurLigne[Ligne]);
	   GotoXY(51,Compteur+3);
	   If(CoutDepense[Ligne]>0.009)Then Write(CoutDepense[Ligne]:12:2);
	   GotoXY(64,Compteur+3);
	   If(ArgentBanque[Ligne]>0.009)Then Write(ArgentBanque[Ligne]:16:2);
	  End;
	  Ligne := X;
	 End;
	 Chaine:='';
	 Goto 10;
	End;
    '1' : InitialiseTableau;
    '2' : Goto 50;
    '=' : Calculatrice;
    '<' : Begin
	 Ajustement;
	 DebutList;
	End;
    '?' : InfoBudjet;
    'A' : AjusteCouleur;
    'B' : Goto 120;
    'D' : Begin
	 Mem[$B9F4:0]:=$FF;
	 Goto 90;
	End;
    'G' : XCordonne:=0;
    'H' : Monte;
    'K' : Recule;
    'M' : Avance;
    'O' : XCordonne := 57;
    'P' : Descend;
    'S' : PrincipalEfface;
    'u' : FinList;
    'w' : DebutList;
   End;
   Goto 10;
  End
   Else
  Begin
   Case Touche of
    ^A    : Begin
	   Ajustement;
	   DebutList;
	  End;
    ^B    : InfoBudjet;
    ^C    : AjusteCouleur;
    ^D    : XCordonne:=0;
    ^E    : PrincipalEfface;
    ^F    : FinList;
    ^G    : DebutList;
    ^H    : Recule;
    ^J    : Avance;
    ^L    : Begin
	   ChoisisFichier;
	   DebutList;
	  End;
    ^M    : Begin
	   XCordonne := 0;
	   Descend;
	  End;
    ^N    : Descend;
    ^O    : XCordonne := 44;
    ^P    : ImprimeListe;
    ^[,^Q : Begin
	   Mem[$B9F4:0]:=$FF;
	   Goto 90;
	  End;
    ^R    : BackSpace;
    ^S    : Begin
 120       : Move(Mem[$B800:0000],Tableau[1],4000);
	   CadrePlain(4,1,74,22,63,1);
	   TextBackGround(3);
	   CentreEcriture(4,'Sauvergarde',62);
 130       : Nom:='';
	   Localise(11,6);
	   Ecrit('Sous Quelle nom desires-tu le Sauvegarder : xxxxxxxx.BSM',63);
	   Localise(55,6);
	   TextColor(11);
	   InLine($B4/$01/  { MOV AH,01 }
		$B1/$07/  { MOV CL,07 }
		$B5/$06/  { MOV CH,06 }
		$CD/$10); { INT 10    }
 140       : Touche := ReadKey;
	   If(Touche=^E)Then Goto 130;
	   If(Touche=#27)Then Goto 150;
	   If Upcase(Touche) in ['0'..'9','-','A'..'Z'] Then
	   Begin
	    Write(Upcase(Touche));
	    Nom:=Nom+UpCase(Touche);
	    Goto 140;
	   End;
	   If Not((Touche=^M)or(Length(Nom)=8))Then Goto 140;
	   If(Nom<>'')Then Nom := Nom+'.BSM';
	   InLine($B4/$01/  { MOV AH,01 }
		$B1/$07/  { MOV CL,07 }
		$B5/$08/  { MOV CH,08 }
		$CD/$10); { INT 10    }
	   Localise(11,8);
	   Ecrit('Le nom est : ',63);
	   Write(Nom);
	   Localise(11,10);
	   Ecrit('Etes-il exacte ? ',63);
	   InLine($B4/$01/  { MOV AH,01 }
		$B1/$07/  { MOV CL,07 }
		$B5/$06/  { MOV CH,06 }
		$CD/$10); { INT 10    }
	   Repeat Until ReadKey in ['O','N',#27];
	   If(Touche=#27)Then Goto 150 else If(UpCase(Touche)='N')Then Goto 130 Else
	   Begin
	    HandleTemporaire := Ouvre(Nom,2);
	    If(HandleTemporaire = -1)Then HandleTemporaire := Cree(Nom);
	    For Compteur:=0 to PositionFinList do
	    Begin
	     Intermediaire[0] := CouleurLigne[Compteur];
	     MemW[Seg(Intermediaire[1]):Ofs(Intermediaire[1])] := Annees[Compteur];
	     Intermediaire[3] := Mois[Compteur];
	     Intermediaire[4] := Jour[Compteur];
	     Move(ArgentCheque[Compteur],Intermediaire[5],4);
	     Move(Depense[Compteur,1],Intermediaire[9],20);
	     Move(CoutDepense[Compteur],Intermediaire[29],4);
	     Move(ArgentBanque[Compteur],Intermediaire[33],4);
	     ModifieEnregistrement(HandleTemporaire,Compteur,37,Intermediaire);
	    End;
	    Close(Fichier);
	   End;
 150       : InLine($B4/$01/     { MOV AH,01   }
		$B9/$07/$08/ { MOV CX,0807 }
		$CD/$10);    { INT 10      }
	   Move(Tableau[1],Mem[$B800:0000],4000);
	  End;
    ^T    : XCordonne := 23;
    ^U    : Monte;
    ^V    : XCordonne := 57;
    ^W    : XCordonne := 11;
    ^X    : Begin
	   X := Ligne + 19;
	   If X>MaxTableau-11 Then FinList Else
	   Begin
	    YCordonne := 9;
	    Ligne     := X-10;
	    InLine($B4/$01/     { MOV AH,01   }
		 $B9/$07/$08/ { MOV CX,0807 }
		 $CD/$10);    { INT 10      }
	    BoiteCaractere(6,2,15,21,30);
	    BoiteCaractere(17,2,27,21,30);
	    BoiteCaractere(50,2,61,21,30);
	    BoiteCaractere(63,2,78,21,30);
	    For Compteur:=0 to 19 do
	    Begin
	     Ligne := Ligne + 1;
	     Str(Ligne,Vs);VS:=Zero(4-Length(VS))+VS;
	     Mem[$B814:8+Compteur*160]:=Ord(Vs[4]);
	     Mem[$B814:6+Compteur*160]:=Ord(Vs[3]);
	     Mem[$B814:4+Compteur*160]:=Ord(Vs[2]);
	     Mem[$B814:2+Compteur*160]:=Ord(Vs[1]);
	     TextBackGround(CouleurLigne[Ligne]div 16);
	     TextColor(CouleurLigne[Ligne] Mod 16);
	     GotoXY(7,Compteur+3);
	     If(Annees[Ligne]>0)Then Write(1985+Annees[Ligne]:4,SepareDate);
	     GotoXY(12,Compteur+3);
	     If(Mois[Ligne]>0)Then Write(Mois[Ligne]:2,SepareDate);
	     GotoXY(15,Compteur+3);
	     If(Jour[Ligne]>0)Then Write(Jour[Ligne]:2);
	     GotoXY(18,Compteur+3);
	     If(ArgentCheque[Ligne]>0.009)Then Write(ArgentCheque[Ligne]:11:2);
	     DepenseFixee(Compteur,Ligne,CouleurLigne[Ligne]);
	     GotoXY(51,Compteur+3);
	     If(CoutDepense[Ligne]>0.009)Then Write(CoutDepense[Ligne]:12:2);
	     GotoXY(64,Compteur+3);
	     If(ArgentBanque[Ligne]>0.009)Then Write(ArgentBanque[Ligne]:16:2);
	    End;
	    Ligne := X;
	   End;
	   Chaine:='';
	 End;
^Y    : Begin
	 X := Ligne - 19;
	 If X<MinTableau+11 Then DebutList Else
	 Begin
	YCordonne := 9;
	Ligne     := X-10;
	InLine($B4/$01/     { MOV AH,01   }
	       $B9/$07/$08/ { MOV CX,0807 }
	       $CD/$10);    { INT 10      }
	BoiteCaractere(6,2,15,21,30);
	BoiteCaractere(17,2,27,21,30);
	BoiteCaractere(50,2,61,21,30);
	BoiteCaractere(63,2,78,21,30);
	For Compteur:=0 to 19 do
	Begin
	 Ligne := Ligne + 1;
	 Str(Ligne,Vs);
	 VS:=Zero(4-Length(VS))+VS;
	 Mem[$B814:8+Compteur*160]:=Ord(Vs[4]);
	 Mem[$B814:6+Compteur*160]:=Ord(Vs[3]);
	 Mem[$B814:4+Compteur*160]:=Ord(Vs[2]);
	 Mem[$B814:2+Compteur*160]:=Ord(Vs[1]);
	 TextBackGround(CouleurLigne[Ligne]div 16);
	 TextColor(CouleurLigne[Ligne] Mod 16);
	 GotoXY(7,Compteur+3);
	 If(Annees[Ligne]>0)Then Write(1985+Annees[Ligne]:4,SepareDate);
	 GotoXY(12,Compteur+3);
	 If(Mois[Ligne]>0)Then Write(Mois[Ligne]:2,SepareDate);
	 GotoXY(15,Compteur+3);
	 If(Jour[Ligne]>0)Then Write(Jour[Ligne]:2);
	 GotoXY(18,Compteur+3);
	 If(ArgentCheque[Ligne]>0.009)Then Write(ArgentCheque[Ligne]:11:2);
	 DepenseFixee(Compteur,Ligne,CouleurLigne[Ligne]);
	 GotoXY(51,Compteur+3);
	 If(CoutDepense[Ligne]>0.009)Then Write(CoutDepense[Ligne]:12:2);
	 GotoXY(64,Compteur+3);
	 If(ArgentBanque[Ligne]>0.009)Then Write(ArgentBanque[Ligne]:16:2);
	End;
	Ligne := X;
	 End;
	 Chaine:='';
	End;
 ^Z   : Calculatrice;
       End;
      End;
      If(((XCordonne>56)And(XCordonne<79))And(Touche in['0'..'9','.'])And(ArgentBanque[Ligne]<999999999999.99))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,ArgentBanque[Ligne],ErrVal);
       GotoXY(64,3+YCordonne);
       Write(ArgentBanque[Ligne]:16:2);
      End
       else
      If(((XCordonne>43)And(XCordonne<57))And
	 (Touche in['0'..'9','.'])And
	 (CoutDepense[Ligne]<9999999.99))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,CoutDepense[Ligne],ErrVal);
       GotoXY(51,3+YCordonne);
       Write(CoutDepense[Ligne]:12:2);
      End
       else
      If((XCordonne>22)And(XCordonne<43)And(Ord(Touche)>31))Then
      Begin
       Depense[Ligne,XCordonne-22] := Ord(Touche);
       EcritUnCaractere(6+XCordonne,2+YCordonne,Ord(Touche),CouleurLigne[Ligne]);
       Avance;
      End
       else
      If(((XCordonne>10)And(XCordonne<22))And(Touche in['0'..'9','.'])And(ArgentCheque[Ligne]<9999999.99))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,ArgentCheque[Ligne],ErrVal);
       GotoXY(18,3+YCordonne);
       Write(ArgentCheque[Ligne]:11:2);
      End
       else
      If(((XCordonne>=0)And(XCordonne<4))And(Touche in['0'..'9']))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,Cobaye,ErrVal);
       GotoXY(7,3+YCordonne);
       If(Cobaye>1985)Then
       Begin
	Cobaye:=Cobaye-1985;
	Annees[Ligne]:=Trunc(Cobaye);
	Write(Annees[Ligne]+1985,SepareDate);
	XCordonne := 5;
	Chaine    := '';
       End
	else
       Write(Cobaye);
      End
       else
      If(((XCordonne>4)And(XCordonne<7))And(Touche in['0'..'9']))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,Cobaye,ErrVal);
       GotoXY(12,3+YCordonne);
       If(Length(Chaine)=2)Then
       Begin
	Mois[Ligne] := Trunc(Cobaye);
	Write(Mois[Ligne]:2,SepareDate);
	XCordonne := 8;
	Chaine:='';
       End
	else
       Write(Cobaye);
      End
       else
      If(((XCordonne>7)And(XCordonne<10))And(Touche in['0'..'9']))Then
      Begin
       TextBackGround(CouleurLigne[Ligne]div 16);
       TextColor(CouleurLigne[Ligne]Mod 16);
       Chaine:=Chaine+Touche;
       Val(Chaine,Cobaye,ErrVal);
       GotoXY(15,3+YCordonne);
       If(Length(Chaine)=2)Then
       Begin
	Jour[Ligne]:=Trunc(Cobaye);
	Write(Jour[Ligne]:2);
	XCordonne := 11;
	Chaine    := '';
       End
	else
       Write(Cobaye);
       End;
       Goto 10;
Exit : InLine($B4/$01/ { MOV AH,01 }
	    $B1/$07/  { MOV CL,07 }
	    $B5/$06/  { MOV CH,06 }
	    $CD/$10); { INT 10    }
       Quitter;
End.


