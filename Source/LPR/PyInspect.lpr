program PyInspect;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, WndMain, Python, LResources
  { you can add units after this };

{$IFDEF WINDOWS}{$R PyInspect.rc}{$ENDIF}

begin
  {$I PyInspect.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

