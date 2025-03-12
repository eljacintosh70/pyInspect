program PyInspect;



uses
  Forms,
  Python in '..\common\Python.pas',
  InspectBase in '..\common\InspectBase.pas',
  WndTree in '..\VCL\WndTree.pas' {TreeForm},
  InspectPython in '..\common\InspectPython.pas',
  WndMain in '..\VCL\WndMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
