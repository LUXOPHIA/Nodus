unit Main;

interface //#################################################################### ■

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
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
  public
    { public 宣言 }
    _Model :TNoduModel;
    _Shape :TNoduShape;
    _CornN :Integer;
    _SegmN :Integer;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

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

     _CornN := 10{角};
     _SegmN := 5{分割};
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
//････････････････････････････････････････････
     procedure MakeWire( const P0_,P1_:TNoduPoin );  //分割点の生成
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
//････････････････････････････････････････････
var
   I :Integer;
   P0, P1, P2 :TNoduPoin;
   G :TSingle3D;
begin
     _Model.DeleteChilds;  //モデルを破棄

     ///// 角点の生成

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

     ///// 重心を原点へ移動

     with _Model do
     begin
          G := Barycenter;
          for I := 1 to PoinModel.ChildsN-1 do
          begin
               with PoinModel.Childs[ I ] do Pos := Pos - G;
          end;
     end;

     _Shape.MakeGeometry;  //ポリゴンの構築
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
var
   N :Integer;
begin
     for N := 1 to 10 do  //１フレーム内の更新数
     begin
          ///// 頂点の力をゼロに初期化

          TParallel.For( 0, _Model.PoinModel.ChildsN-1, procedure( I:Integer )  //すべての頂点を走査
          begin
               with _Model.PoinModel.Childs[ I ] do  //頂点
               begin
                    Force0 := TSingle3D.Create( 0, 0, 0 );  //力をゼロに初期化
                    Force1 := TSingle3D.Create( 0, 0, 0 );
               end;
          end,
          _ThreadPool );

          ///// 線分からの力を頂点へ加算

          TParallel.For( 0, _Model.ChildsN-1, procedure( I:Integer )  //すべての線分を走査
          var
             W0, W1 :TNoduWire;
             F, V :TSingle3D;
             J :Integer;
             L2, L, E :Single;
          begin
               W0 := _Model.Childs[ I ];  //線分０

               ///// 線分の収縮

               V := W0.Vector;  //ベクトル

               L2 := V.Siz2;  L := Roo2( L2 );  //ベクトル長

               V := V / L;  //単位ベクトル

               E := L - 0;  //自然長はゼロ

               F := E * V;

               with W0.Poin0 do Force1 := Force1 + F;
               with W0.Poin1 do Force0 := Force0 - F;

               ///// 線分同士の反発

               F := TSingle3D.Create( 0, 0, 0 );
               W1 := W0.Poin1.Wire1;
               for J := 1 to _Model.ChildsN-3 do  //自分と両隣以外の線分を走査
               begin
                    W1 := W1.Poin1.Wire1;  //線分１

                    V := W0.DistanTo( W1 );  //最短距離ベクトル

                    L2 := V.Siz2;  L := Roo2( L2 );  //最短距離ベクトル長

                    V := V / L;  //最短距離の単位ベクトル

                    E := 1 / L2 - 1;  if E < 0 then E := 0;  //半径１以上での反発力はゼロ

                    F := F - E * V;
               end;
               F := F / Pow2( _Model.ChildsN );

               with W0.Poin0 do Force1 := Force1 + F;
               with W0.Poin1 do Force0 := Force0 + F;
          end,
          _ThreadPool );

          ///// 頂点を力に応じて移動

          TParallel.For( 0, _Model.PoinModel.ChildsN-1, procedure( I:Integer )  //すべての頂点を走査
          begin
               with _Model.PoinModel.Childs[ I ] do  //頂点
               begin
                    Pos := Pos + 0.1 * ( Force0 + Force1 );  //力に応じて移動
               end;
          end,
          _ThreadPool );
     end;

     _Shape.UpdateGeometry;  //ポリゴンを更新

     Viewport3D1.Repaint;  //ピューを更新
end;

procedure TForm1.Button2Click(Sender: TObject);  //実行ボタンを押した場合
begin
     Button2.Enabled := False;
     Button3.Enabled := True ;

     Timer1.Enabled := True ;  //シミュレーション開始
end;

procedure TForm1.Button3Click(Sender: TObject);  //停止ボタンを押した場合
begin
     Timer1.Enabled := False;  //シミュレーション停止

     Button2.Enabled := True ;
     Button3.Enabled := False;
end;

end. //######################################################################### ■
