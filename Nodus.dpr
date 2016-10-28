program Nodus;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  LUX.D2 in '_LIBRARY\LUXOPHIA\LUX\LUX.D2.pas',
  LUX.D3 in '_LIBRARY\LUXOPHIA\LUX\LUX.D3.pas',
  LUX in '_LIBRARY\LUXOPHIA\LUX\LUX.pas',
  LUX.D1 in '_LIBRARY\LUXOPHIA\LUX\LUX.D1.pas',
  LUX.Brep in '_LIBRARY\LUXOPHIA\LUX.Brep\LUX.Brep.pas',
  LUX.Brep.Poin.D3 in '_LIBRARY\LUXOPHIA\LUX.Brep\LUX.Brep.Poin.D3.pas',
  LUX.Brep.Poin in '_LIBRARY\LUXOPHIA\LUX.Brep\LUX.Brep.Poin.pas',
  LUX.Geometry.D3 in '_LIBRARY\LUXOPHIA\LUX.Geometry\LUX.Geometry.D3.pas',
  LUX.Geometry in '_LIBRARY\LUXOPHIA\LUX.Geometry\LUX.Geometry.pas',
  LUX.Graph in '_LIBRARY\LUXOPHIA\LUX.Graph\LUX.Graph.pas',
  LUX.Graph.Tree in '_LIBRARY\LUXOPHIA\LUX.Graph\LUX.Graph.Tree.pas',
  LUX.Matrix.L3 in '_LIBRARY\LUXOPHIA\LUX.Matrix\LUX.Matrix.L3.pas',
  LUX.Matrix.L4 in '_LIBRARY\LUXOPHIA\LUX.Matrix\LUX.Matrix.L4.pas',
  LUX.Matrix.L2 in '_LIBRARY\LUXOPHIA\LUX.Matrix\LUX.Matrix.L2.pas',
  TUX.Nodus in '_LIBRARY\TUX.Nodus.pas',
  LUX.Brep.Wire.D3 in '_LIBRARY\LUXOPHIA\LUX.Brep\LUX.Brep.Wire.D3.pas',
  LUX.Brep.Wire in '_LIBRARY\LUXOPHIA\LUX.Brep\LUX.Brep.Wire.pas',
  LUX.FMX in '_LIBRARY\LUXOPHIA\LUX.FMX\LUX.FMX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
