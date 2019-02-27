unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SpinEx, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, MaskEdit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RadioGroup1: TRadioGroup;
    SpinEditEx1: TSpinEditEx;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioGroup1SelectionChanged(Sender: TObject);
  private
    function BinToInt(s : string; swidth: integer):integer;
    function GetStrWidth:Integer;
  public

  end;

  TShowBit = class
    BitEdit : TEdit;
    constructor Create; overload;
    procedure ShowABit(AOwner : TComponent; Top, Left : Integer);
    procedure FillABit(s : string);
  public
   destructor Destroy; override;
  end;

  TWord = class
    BitList : TList;
    constructor Create; overload;
    procedure ClearWord;
    procedure CreateNBits(N: Integer);
    procedure ShowNBits(AOwner : TComponent; Top, Left : Integer);
    procedure FillBits(s : string);
  public
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation
uses math;

{$R *.lfm}

{ TForm1 }

var
  Word1, Word2 : TWord;

constructor TShowBit.Create;
begin
  inherited;
  BitEdit := TEdit.Create(nil);
  BitEdit.Width := 18;
  BitEdit.Height := 23;
  BitEdit.MaxLength := 1;
  BitEdit.Alignment := taCenter;
end;

destructor TShowBit.Destroy;
begin
  BitEdit.Parent := nil;
  BitEdit.Free;
  BitEdit := nil;
  inherited;
end;

procedure TShowBit.ShowABit(AOwner : TComponent; Top, Left : Integer);
begin
  BitEdit.Parent := TWinControl(AOwner);
  BitEdit.Top := Top;
  BitEdit.Left := Left;

end;

procedure TShowBit.FillABit(s : string);
begin
  BitEdit.Text:=s;
end;

procedure TWord.ClearWord;
var
  i,j : integer;
begin
  i := BitList.Count;
  for j:= 0 to i-1 do begin
    TShowBit(BitList[j]).Free;
//    ShowMessage('OK');
  end;
end;

destructor TWord.Destroy;
begin
  ClearWord;
  BitList.Free;
  inherited;
end;

constructor TWord.Create;
begin
  inherited;
  BitList := TList.Create;
end;

procedure TWord.CreateNBits(N: Integer);
var
  i : integer;
  aBit : TShowBit;
begin
  for i:= 1 to N do begin
    aBit := TShowBit.Create;
    BitList.Add(aBit);
  end;
end;

procedure TWord.ShowNBits(AOwner : TComponent; Top, Left : Integer);
var
  i : integer;
begin
  // from right to left
  for i:= 0 to BitList.Count-1 do begin
    TShowBit(BitList[i]).ShowABit(AOwner, Top, Left - (i * (18+2)));
  end;
end;

procedure TWord.FillBits(s : string);
var
  i : integer;
  b : string;
begin
   for i:= 0 to s.Length-1 do begin
     b := s[i+1];
     TShowBit(BitList[BitList.Count-1-i]).FillABit(b);
   end;
end;

function TForm1.BinToInt(s : string; swidth: integer):integer;
var
  i : integer;
  value : Integer;
begin
  value := 0;
  for i:= 1 to swidth do begin
    value := value + StrToInt(s[swidth-i+1]) * trunc(Power(2, (i-1)));
  end;
  BinToInt := value;
end;

function TForm1.GetStrWidth:Integer;
begin
  case RadioGroup1.ItemIndex of
    0: GetStrWidth := 4;
    1: GetStrWidth := 8;
    2: GetStrWidth := 16;
    3: GetStrWidth := 32;
    4: GetStrWidth := 64;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
 i : integer;
 s1,s2 : string;
 strWidth : Integer;
begin
  StrWidth := GetStrWidth;
  s1 := binStr(SpinEditEx1.Value, StrWidth);
  s2 := s1;
  Word1.FillBits(s1);
  Word2.FillBits(s2);
  i := StrWidth+1;
  repeat
    dec(i);
    s2[i] := s1[i];
  until StrToInt(s1[i]) = 1;
  dec(i);

  while i > 0 do begin
    if(s1[i] = '0')then
      s2[i] := '1'
    else
      s2[i] := '0';
    dec(i);
  end;
  Word2.FillBits(s2);
  i :=BinToInt(s1, StrWidth);
  if(s1[1] = '0')then begin //positiv
    //do nothing
  end
  else begin //negativ *)
    i := BinToInt(s1, StrWidth);
    i := i - trunc(Power(2, StrWidth));
  end;
  Label9.Caption:= IntToStr(i);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Word1 := TWord.Create;
  Word2 := TWord.Create;
  Word1.CreateNBits(GetStrWidth);



  Word1.ShowNBits(Self, 115, Label4.Left + (GetStrWidth-1) * (18+2));
  Word2.CreateNBits(GetStrWidth);
  Word2.ShowNBits(Self, 233, Label4.Left + (GetStrWidth-1) * (18+2));

  Label3.Caption := 'Eine Ganzzahl eingeben (0-'
                   + IntToStr(trunc(Power(2, GetStrWidth))-1)
                   +')';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Word1.Free;
  Word2.Free;
end;


procedure TForm1.RadioGroup1SelectionChanged(Sender: TObject);
begin
  SpinEditEx1.MaxValue := Power(2, GetStrWidth)-1;
  Word1.Free;
  Word2.Free;
  FormCreate(Sender);
end;


end.

