Procedure Presentation;
Var Compteur : Word;

 Procedure Ecrit(X,Y:Byte;Phrase:String255;Couleur:Byte);
 Var Compteur : Byte;
 Begin
  For Compteur := 1 to Length(Phrase) do
  Begin
   If(Phrase[Compteur] <> #32)Then
   Begin
    If(Phrase[Compteur] ='X')Then Phrase[Compteur]:=#32;
    EcritUnCaractere(X+Compteur-1,Y,Ord(Phrase[Compteur]),Couleur);
   End;
  End;
 End;

Begin
 InLine($B8/$03/$00/
	$CD/$10/

	$B4/$01/
	$B1/$07/
	$B5/$08/
	$CD/$10);
 BoiteCaractere(0,0,79,24,31);
 HauteCouleur(1);
 For Compteur := 0 to 500 do MemW[AdresseEcran:Random(2000)*2] := (16+Random(15)) * 256 + 250;
 Ecrit(4,3,'��������ͻ   �ͻ   �ͻ  �������ͻ   ��������ͻ  �������ͻ  �������ͻ',63);
 Ecrit(4,4,'�X����ͻXȻ  �X�   �X�  �X���ͻXȻ  �X����ͻX�  �X�����ͼ  ��ͻX��ͼ',63);
 Ecrit(4,5,'�X�    �XX�  �X�   �X�  �X�   ȻX�  �X�    �ͼ  �X�           �X�',63);
 Ecrit(4,6,'�X����ͼXɼ  �X�   �X�  �X�    �X�  �X�         �X���ͻ       �X�',63);
 Ecrit(4,7,'�X����ͻXȻ  �X�   �X�  �X�    �X�  �X�  ���ͻ  �X���ͼ       �X�',63);
 Ecrit(4,8,'�X�    �XX�  �X�   �X�  �X�   ɼX�  �X�  �ͻX�  �X�           �X�',63);
 Ecrit(4,9,'�X����ͼXɼ  �X���ͼX�  �X���ͼXɼ  �X����ͼX�  �X�����ͻ     �X�',63);
 Ecrit(4,10,'��������ͼ   �������ͼ  �������ͼ   ��������ͼ  �������ͼ     �ͼ',63);
 Ecrit(4,12,'��������ͻ  �����������ͻ       �������ͻ  �������ͻ  �������ͻ',63);
 Ecrit(4,13,'�X������ͼ  �X��ͻX��ͻX�       ��ͻX��ͼ  ��ͻX��ͼ  ��ͻX��ͼ',63);
 Ecrit(4,14,'�X�         �X�  �X�  �X�          �X�        �X�        �X�   ',63);
 Ecrit(4,15,'�X������ͻ  �X�  �X�  �X�          �X�        �X�        �X�   ',63);
 Ecrit(4,16,'������ͻX�  �X�  �X�  �X�          �X�        �X�        �X�   ',63);
 Ecrit(4,17,'       �X�  �X�  �X�  �X�          �X�        �X�        �X�   ',63);
 Ecrit(4,18,'������ͼX�  �X�  �X�  �X�       ��ͼX��ͻ  ��ͼX��ͻ  ��ͼX��ͻ',63);
 Ecrit(4,19,'��������ͼ  �ͼ  �ͼ  �ͼ       �������ͼ  �������ͼ  �������ͼ',63);
 Delay(1500);
End;
