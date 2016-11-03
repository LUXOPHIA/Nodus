unit LIB.Nodus;

interface //#################################################################### ■

uses System.Types, System.Classes, System.Math.Vectors, System.Threading,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources, FMX.Objects3D,
     LUX, LUX.D3, LUX.Brep.Poin.D3, LUX.Brep.Wire.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TNoduPoin  = class;
     TNoduWire  = class;
     TNoduModel = class;
     TNoduShape = class;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduPoin  //頂点のクラス

     TNoduPoin = class( TPoin3D )
     private
     protected
       _Wire0  :TNoduWire;
       _Wire1  :TNoduWire;
       _Force0 :TSingle3D;
       _Force1 :TSingle3D;
     public
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Wire0  :TNoduWire read _Wire0               ;
       property Wire1  :TNoduWire read _Wire1               ;
       property Force0 :TSingle3D read _Force0 write _Force0;
       property Force1 :TSingle3D read _Force1 write _Force1;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduWire  //線分のクラス

     TNoduWire = class( TWire3D<TNoduPoin> )
     private
     protected
       procedure SetPoin0( const Poin0_:TNoduPoin ); override;
       procedure SetPoin1( const Poin1_:TNoduPoin ); override;
     public
       constructor Create; override;
       destructor Destroy; override;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduModel  //紐のクラス

     TNoduModel = class( TWireModel3D<TNoduPoin,TNoduWire> )
     private
     protected
     public
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduShape  //ポリゴンのクラス

     TNoduShape = class( TControl3D )
     private
       _Poins :TDummy;
       _Wires :TDummy;
       _MatP  :TLightMaterialSource;
       _MatW  :TLightMaterialSource;
     protected
       _Model :TNoduModel;
       ///// アクセス
       procedure SetModel( const Model_:TNoduModel );
     public
       constructor Create( Owner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Model :TNoduModel read _Model write SetModel;  //対象の紐モデル
       ///// メソッド
       procedure MakeGeometry;
       procedure UpdateGeometry;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

    _ThreadPool :TThreadPool;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.UITypes, System.Math,
     LUX.FMX;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduPoin

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TNoduPoin.Create;
begin
     inherited;

end;

destructor TNoduPoin.Destroy;
begin

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduWire

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

procedure TNoduWire.SetPoin0( const Poin0_:TNoduPoin );
begin
     inherited;

     if Assigned( Poin0_ ) then Poin0_._Wire1 := Self;
end;

procedure TNoduWire.SetPoin1( const Poin1_:TNoduPoin );
begin
     inherited;

     if Assigned( Poin1_ ) then Poin1_._Wire0 := Self;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TNoduWire.Create;
begin
     inherited;

end;

destructor TNoduWire.Destroy;
begin

     inherited;
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduModel

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TNoduShape

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

procedure TNoduShape.SetModel( const Model_:TNoduModel );
begin
     _Model := Model_;  MakeGeometry;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TNoduShape.Create( Owner_:TComponent );
begin
     inherited;

     _Poins := TDummy.Create( Self );  _Poins.Parent := Self;
     _Wires := TDummy.Create( Self );  _Wires.Parent := Self;

     _MatP  := TLightMaterialSource.Create( _Poins );  //頂点のマテリアル
     _MatW  := TLightMaterialSource.Create( _Wires );  //線分のマテリアル

     with _MatP do
     begin
          Ambient  := TAlphaColors.Maroon;
          Diffuse  := TAlphaColors.Red;
          Specular := TAlphaColors.Null;
     end;

     with _MatW do
     begin
          Ambient  := TAlphaColors.Green;
          Diffuse  := TAlphaColors.Lime;
          Specular := TAlphaColors.Null;
     end;
end;

destructor TNoduShape.Destroy;
begin

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TNoduShape.MakeGeometry;  //ポリゴンの構築
var
   I :Integer;
begin
     _Poins.DeleteChildren;
     _Wires.DeleteChildren;

     for I := 0 to _Model.PoinModel.ChildsN-1 do
     begin
          with _Model.PoinModel.Childs[ I ] do
          begin
               with TSphere.Create( _Poins ) do
               begin
                    Parent             := _Poins;
                    HitTest            := False;
                    Width              := 1;
                    Height             := 1;
                    Depth              := 1;
                    SubdivisionsAxes   := 16;
                    SubdivisionsHeight := 8;
                    MaterialSource     := _MatP;
               end;
          end;
     end;

     for I := 0 to _Model.ChildsN-1 do
     begin
          with _Model.Childs[ I ] do
          begin
               with TCylinder.Create( _Wires ) do
               begin
                    Parent             := _Wires;
                    HitTest            := False;
                    Width              := 0.5;
                    Height             := 1;
                    Depth              := 0.5;
                    SubdivisionsAxes   := 16;
                    MaterialSource     := _MatW;
               end;
          end;
     end;

     UpdateGeometry;
end;

procedure TNoduShape.UpdateGeometry;  //ポリゴンの更新
begin
     TParallel.For( 0, _Model.PoinModel.ChildsN-1, procedure( I:Integer )
     begin
          with _Model.PoinModel.Childs[ I ] do
          begin
               with TSphere( _Poins.Children[ I ] ) do
               begin
                    Position.Point := 10 * Pos;
               end;
          end;
     end, _ThreadPool );

     TParallel.For( 0, _Model.ChildsN-1, procedure( I:Integer )
     begin
          with _Model.Childs[ I ] do
          begin
               with TCylinder( _Wires.Children[ I ] ) do
               begin
                    LocalMatrix := GapFit( 10 * Poin0.Pos, 10 * Poin1.Pos );  //２つの頂点の間に挟まる姿勢
                    Height      := 10 * Leng;
               end;
          end;
     end, _ThreadPool );

     Repaint;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     _ThreadPool := TThreadPool.Create;

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

     _ThreadPool.Free;

end. //######################################################################### ■