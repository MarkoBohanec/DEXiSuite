// FormSystem.pas is part of
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
// FormSystem.pas implements a form that displays the current state of the system and DEXi objects.
// Typically shown only while debugging.
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
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormSystem.
  /// </summary>
  FormSystem = partial public class(System.Windows.Forms.Form)
  private
    method BtnShow_Click(sender: System.Object; e: System.EventArgs);
    method BtnCollect_Click(sender: System.Object; e: System.EventArgs);
    method FormSystem_Shown(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method UpdateForm;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormSystem;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();
  BtnShow.Visible := defined('DEBUG');
  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormSystem.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormSystem.UpdateForm;
begin
  LblNumActive.Text := Utils.IntToStr(DexiObject.ActiveObjects);
  LblNumCreated.Text := Utils.IntToStr(DexiObject.CreatedObjects);
  LblNumFinalized.Text := Utils.IntToStr(DexiObject.FinalizedObjects);
  var lActiveForm := AppData.AppForm:ActiveMdiChild;
  var lModelForm := FormModel(lActiveForm);
  if lModelForm = nil then
    GrpUndoRedo.Visible := false
  else
    begin
      GrpUndoRedo.Visible := true;
      LblNumUndo.Text := Utils.IntToStr(lModelForm.UndoCount);
      LblNumRedo.Text := Utils.IntToStr(lModelForm.RedoCount);
    end;
  LblAppValue.Text := Application.ProductName;
  LblBuildValue.Text := Application.ProductVersion;
  {$IFDEF DEBUG}
  LblConfValue.Text := 'Debug';
  {$ELSE}
  LblConfValue.Text := 'Release';
  {$ENDIF}
  LblPathValue.Text := Application.ExecutablePath;
end;

method FormSystem.FormSystem_Shown(sender: System.Object; e: System.EventArgs);
begin
  UpdateForm;
end;

method FormSystem.BtnCollect_Click(sender: System.Object; e: System.EventArgs);
begin
  GC.Collect(GC.MaxGeneration);
  GC.WaitForPendingFinalizers;
  GC.Collect;
  UpdateForm;
end;

method FormSystem.BtnShow_Click(sender: System.Object; e: System.EventArgs);
begin
  {$IFDEF DEBUG}
  using lListForm := new FormList do
    begin
      lListForm.Text := 'Active DexiObjects';
      var lLines := new List<String>;
      for i := 0 to DexiObject.CreatedObjects do
        if DexiObject.LivingObjects.ContainsKey(i) then
          with lObj := DexiObject.LivingObjects[i] do
            lLines.Add($"{lObj.Number}: {lObj.ObjectType}");
      lListForm.SetAsLines(lLines);
      lListForm.ShowDialog;
    end;
  {$ENDIF}
end;


end.