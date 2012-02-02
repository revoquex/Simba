unit ocrtoolunit;

{$mode objfpc}{$H+}


{
  Features:
    - Change Bitmap
    - Set Target (Client)
    - Set Font Directory
    - Change filter(s)(?)
    - Change coords to start at
    - Output text in TEdit?
    - Interactive / show individual step.
}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,

  // Custom
  Client, MufasaTypes, Bitmaps, ocr, windowselector, iomanager;

type

  { TForm1 }

  TForm1 = class(TForm)
    OCRButton: TButton;
    UpCharsDialog: TSelectDirectoryDialog;
    SetFontButton: TButton;
    OCRFileOpen: TOpenDialog;
    SetBitmapButton: TButton;
    SetClientButton: TButton;
    EditFiltersButton: TButton;
    Image1: TImage;
    procedure OCRButtonClick(Sender: TObject);
    procedure SetFontButtonClick(Sender: TObject);
    procedure SetBitmapButtonClick(Sender: TObject);
    procedure SetClientButtonClick(Sender: TObject);
    procedure EditFiltersButtonClick(Sender: TObject);
  private
    { private declarations }
    BitmapPath: String;
    FontPath: String;

    //CliW: TIOManager;
    UseClient: Boolean;

  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.OCRButtonClick(Sender: TObject);
begin

end;

procedure TForm1.SetFontButtonClick(Sender: TObject);
begin
  if UpCharsDialog.Execute then
    FontPath := UpCharsDialog.FileName;
end;

procedure TForm1.SetBitmapButtonClick(Sender: TObject);
begin
  if OCRFileOpen.Execute then
  begin
    BitmapPath := OCRFileOpen.FileName;
    UseClient:=False;
  end;
end;

procedure TForm1.SetClientButtonClick(Sender: TObject);
begin

end;

procedure TForm1.EditFiltersButtonClick(Sender: TObject);
begin

end;

end.

