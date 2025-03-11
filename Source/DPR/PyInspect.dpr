program PyInspect;



uses
  Forms,
  Python in '..\common\Python.pas',
  Unit1 in '..\VCL\Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
