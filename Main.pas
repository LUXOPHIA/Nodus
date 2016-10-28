unit Main;

interface //#################################################################### ��

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Objects3D, FMX.MaterialSources, FMX.Controls3D,
  FMX.Viewport3D, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation,
  LUX, LUX.D3, LUX.Geometry.D3, LUX.Matrix.L4,
  TUX.Nodus, FMX.Types3D;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    Button3: TButton;
    Viewport3D1: TViewport3D;
    Camera1: TCamera;
    Grid3D1: TGrid3D;
    Timer1: TTimer;
    StrokeCube1: TStrokeCube;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Light1: TLight;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private �錾 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
  public
    { public �錾 }
    _Model :TNoduModel;
    _Shape :TNoduShape;
    _CornN :Integer;
    _SegmN :Integer;
  end;

var
  Form1: TForm1;

implementation //############################################################### ��

{$R *.fmx}

uses System.Threading;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _MouseS := [];

     _Model := TNoduModel.Create;
     _Shape := TNoduShape.Create( Self );

     with _Shape do
     begin
          Parent := Viewport3D1;
          Model  := _Model;
     end;

     _CornN := 10{�p};
     _SegmN := 5{����};
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Shape.Free;
     _Model.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X );
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y );

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
//��������������������������������������������
     procedure MakeWire( const P0_,P1_:TNoduPoin );  //�����_�̐���
     var
        I :Integer;
        P0, P1 :TNoduPoin;
        W :TNoduWire;
     begin
          P0 := P0_;
          for I := 1 to _SegmN-1 do
          begin
               P1 := TNoduPoin.Create( _Model.PoinModel );
               P1.Pos := ( P1_.Pos - P0_.Pos ) * ( I / _SegmN ) + P0_.Pos;

               W := TNoduWire.Create( _Model );
               W.Poin0 := P0;
               W.Poin1 := P1;

               P0 := P1;
          end;

          W := TNoduWire.Create( _Model );
          W.Poin0 := P0;
          W.Poin1 := P1_;
     end;
//��������������������������������������������
var
   I :Integer;
   P0, P1, P2 :TNoduPoin;
   G :TSingle3D;
begin
     _Model.DeleteChilds;  //���f����j��

     ///// �p�_�̐���

     P2 := TNoduPoin.Create( _Model.PoinModel );
     P2.Pos := 2 * TSingle3D.RandBS1;

     P1 := P2;
     for I := 1 to _CornN-1 do
     begin
          P0 := P1;

          P1 := TNoduPoin.Create( _Model.PoinModel );
          P1.Pos := 2 * TSingle3D.RandBS1;

          MakeWire( P0, P1 );
     end;

     MakeWire( P1, P2 );

     ///// �d�S�����_�ֈړ�

     with _Model do
     begin
          G := Barycenter;
          for I := 1 to PoinModel.ChildsN-1 do
          begin
               with PoinModel.Childs[ I ] do Pos := Pos - G;
          end;
     end;

     _Shape.MakeGeometry;  //�|���S���̍\�z
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
var
   N :Integer;
begin
     for N := 1 to 10 do  //�P�t���[�����̍X�V��
     begin
          ///// ���_�̗͂��[���ɏ�����

          TParallel.For( 0, _Model.PoinModel.ChildsN-1, procedure( I:Integer )  //���ׂĂ̒��_�𑖍�
          begin
               with _Model.PoinModel.Childs[ I ] do  //���_
               begin
                    Force0 := TSingle3D.Create( 0, 0, 0 );  //�͂��[���ɏ�����
                    Force1 := TSingle3D.Create( 0, 0, 0 );
               end;
          end,
          _ThreadPool );

          ///// ���_�̗͂��[���ɏ�����

          TParallel.For( 0, _Model.ChildsN-1, procedure( I:Integer )  //���ׂĂ̐����𑖍�
          var
             W0, W1 :TNoduWire;
             F, V :TSingle3D;
             J :Integer;
             L2, L, E :Single;
          begin
               W0 := _Model.Childs[ I ];  //�����O

               ///// �����̎��k

               V := W0.Vector;  //�x�N�g��

               L2 := V.Siz2;  L := Roo2( L2 );  //�x�N�g����

               V := V / L;  //�P�ʃx�N�g��

               E := L - 0;  //���R���̓[��

               F := E * V;

               with W0.Poin0 do Force1 := Force1 + F;
               with W0.Poin1 do Force0 := Force0 - F;

               ///// �������m�̔���

               F := TSingle3D.Create( 0, 0, 0 );
               W1 := W0.Poin1.Wire1;
               for J := 1 to _Model.ChildsN-3 do  //�����Ɨ��׈ȊO�̐����𑖍�
               begin
                    W1 := W1.Poin1.Wire1;  //�����P

                    V := W0.DistanTo( W1 );  //�ŒZ�����x�N�g��

                    L2 := V.Siz2;  L := Roo2( L2 );  //�ŒZ�����x�N�g����

                    V := V / L;  //�ŒZ�����̒P�ʃx�N�g��

                    E := 1 / L2 - 1;  if E < 0 then E := 0;  //���a�P�ȏ�ł̔����͂̓[��

                    F := F - E * V;
               end;
               F := F / Pow2( _Model.ChildsN );

               with W0.Poin0 do Force1 := Force1 + F;
               with W0.Poin1 do Force0 := Force0 + F;
          end,
          _ThreadPool );

          ///// ���_��͂ɉ����Ĉړ�

          TParallel.For( 0, _Model.PoinModel.ChildsN-1, procedure( I:Integer )  //���ׂĂ̒��_�𑖍�
          begin
               with _Model.PoinModel.Childs[ I ] do  //���_
               begin
                    Pos := Pos + 0.1 * ( Force0 + Force1 );  //�͂ɉ����Ĉړ�
               end;
          end,
          _ThreadPool );
     end;

     _Shape.UpdateGeometry;  //�|���S�����X�V

     Viewport3D1.Repaint;  //�s���[���X�V
end;

procedure TForm1.Button2Click(Sender: TObject);  //���s�{�^�����������ꍇ
begin
     Button2.Enabled := False;
     Button3.Enabled := True ;

     Timer1.Enabled := True ;  //�V�~�����[�V�����J�n
end;

procedure TForm1.Button3Click(Sender: TObject);  //��~�{�^�����������ꍇ
begin
     Timer1.Enabled := False;  //�V�~�����[�V������~

     Button2.Enabled := True ;
     Button3.Enabled := False;
end;

end. //######################################################################### ��
