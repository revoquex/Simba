program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  { you can add units after this }
  ,simbamp;

type

  { TMyClient }

  TMyClient = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure onStop;
  public
    Stopping: Boolean;
  end;

{ TMyClient }

procedure TMyClient.OnStop;
begin
  Stopping := True;
end;

procedure TMyClient.DoRun;
var
  masterinstanceid: string;
  c: TScriptSideCommunication;
  t: Integer;

begin
  masterinstanceid := Self.Params[1];

  c := TScriptSideCommunication.Create;

  writeln('Master ID: ' + masterinstanceid);

  Stopping := False;

  c.ConnectToMaster(masterinstanceid);
  c.SetupServer;
  c.EventStop := @OnStop;

//  t := GetTickCount;
  while True do
  begin
    sleep(15);
    c.HandleEvents;
   {
    if Get - t > 1000 then
    begin
      t := GetTickCount;
      c.WriteMessage('PING');
    end;
         }
    if Stopping then
      break;
  end;

  c.StopServer;
  c.DisconnectFromMaster;

  c.Free;

  { add your program here }

  // stop program loop
  Terminate;
end;

constructor TMyClient.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TMyClient.Destroy;
begin
  inherited Destroy;
end;

procedure TMyClient.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: TMyClient;

{$R *.res}

begin
  Application:=TMyClient.Create(nil);
  Application.Run;
  Application.Free;
end.

