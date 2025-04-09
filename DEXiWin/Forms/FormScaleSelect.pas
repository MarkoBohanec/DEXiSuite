// FormScaleSelect.pas is part of
//
// DEXiWin, DEXi Decision Modeling Software
//
// Copyright (C) 2023-2025 Department of Knowledge Technologies, Jožef Stefan Institute
//
// DEXiWin is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// FormScaleSelect.pas implements a form for selecting a scale to be assigned to some
// attribute from scales compatible with the current scale-state of that attribute.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormScaleSelect.
  /// </summary>
  FormScaleSelect = partial public class(System.Windows.Forms.Form)
  private
    method ChkPredefined_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkDefault_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ViewScales_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fAttribute: DexiAttribute;
    fScales: DexiScaleList;
    fAttScales: DexiScaleList;
    fOriginalScale: DexiScale;
    fSelectedScale: DexiScale;
    fDefaultScale: DexiScale;
    fUpdateLevel: Integer;
  protected
    method Dispose(aDisposing: Boolean); override;
    method ScaleNameStatus(aScl: DexiScale): String;
    method AddPredefinedScales;
  public
    constructor;
    method SetForm(aAttribute: DexiAttribute; aScales: DexiScaleList; aDefaultScale: DexiScale);
    method UpdateForm;
    property SelectedScale: DexiScale read fSelectedScale;
    property DefaultScale: DexiScale read fDefaultScale;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormScaleSelect;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  LblSelectedScale.Left := LblCurrentScale.Left;
  ViewScales.SmallImageList := AppData:ScaleImages;
  ViewScales.SelectedBackColor := Color.SkyBlue;
  ViewScales.SelectedForeColor := ViewScales.ForeColor;
  ViewScales.FullRowSelect := true;
  ColScale.Renderer := new CompositeModelScaleRenderer;

  ColName.AspectGetter :=
    method(x: Object)
    begin
      result :=
      if (x is DexiScale) then ScaleNameStatus(DexiScale(x))
      else '';
    end;

  ColName.ImageGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiScale) then
          if DexiScale(x).IsDiscrete then 'ImgScaleDiscrete'
          else if DexiScale(x).IsContinuous then 'ImgScaleContinuous'
          else nil
        else nil;
    end;

end;

method FormScaleSelect.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    ViewScales.SmallImageList := nil;

//    ColScale.Renderer := nil;
//    ViewScales.SetObjects(nil);
//    ViewScales := nil;
//    fAttribute := nil;
//    fScales := nil;
//    fOriginalScale := nil;
//    fSelectedScale := nil;
//    fDefaultScale := nil;
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormScaleSelect.AddPredefinedScales;

  method TryAddScale(aScl: DexiScale);
  begin
    if aScl = nil then
      exit;
    if not fAttribute.CanSetScale(aScl) then
      exit;
    for each lScl in fScales do
      if lScl.EqualTo(aScl) then
        exit;
    fScales.Add(aScl);
  end;

begin
  fScales := new DexiScaleList;
  for each lScale in fAttScales do
    fScales.Add(lScale);
  var lPredefined := AppData.PredefinedScales;
  for each lScale in lPredefined do
    TryAddScale(lScale);
end;

method FormScaleSelect.ScaleNameStatus(aScl: DexiScale): String;
begin
  result :=
    if (aScl = nil) or (aScl.Name = nil) then ''
    else aScl.Name;
  if aScl = fOriginalScale then
    result := Utils.AppendStr(result, DexiStrings.CurrentScale, ' ');
  if aScl = fDefaultScale then
    result := Utils.AppendStr(result, DexiStrings.DefaultScale, ' ');
end;

method FormScaleSelect.SetForm(aAttribute: DexiAttribute; aScales: DexiScaleList; aDefaultScale: DexiScale);
begin
  fAttribute := aAttribute;
  fOriginalScale := fAttribute:Scale;
  fSelectedScale := fAttribute:Scale;
  fAttScales := aScales;
  fScales := aScales;
  fDefaultScale := aDefaultScale;
  fUpdateLevel := 0;

  if ChkPredefined.Checked then
    AddPredefinedScales;

  inc(fUpdateLevel);
  try
    Text := String.Format(fFormText, fAttribute:Name);
    ViewScales.SetObjects(fScales);
    for i := 0 to fScales.Count - 1 do
      if fScales[i] = fSelectedScale then
        begin
          ViewScales.SelectedIndex := i;
          break;
        end;
    ActiveControl := ViewScales;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method FormScaleSelect.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  AppUtils.Show(fOriginalScale = fSelectedScale, LblCurrentScale);
  AppUtils.Show(fOriginalScale <> fSelectedScale, LblSelectedScale);
  AppUtils.Enable(DexiScale.ScaleIsDiscrete(fSelectedScale), ChkDefault);
  ScaleText.SetScaleText(fSelectedScale, ScaleText.BackColor, true);
  inc(fUpdateLevel);
  try
    ChkDefault.Checked := fSelectedScale = fDefaultScale;
  finally
    dec(fUpdateLevel);
  end;
  AppUtils.Enable((fSelectedScale <> nil) or (fOriginalScale = nil), BtnOK);
end;

method FormScaleSelect.ViewScales_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lIdx := ViewScales.SelectedIndex;
  fSelectedScale :=
    if 0 <= lIdx < fScales.Count then fScales[lIdx]
    else nil;
  UpdateForm;
end;

method FormScaleSelect.ChkDefault_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fDefaultScale :=
    if not ChkDefault.Checked then nil
    else fSelectedScale;
  ViewScales.RefreshObject(fDefaultScale);
  ViewScales.RefreshObject(fSelectedScale);
  UpdateForm;
end;

method FormScaleSelect.ChkPredefined_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  SetForm(fAttribute, fAttScales, fDefaultScale);
end;

end.