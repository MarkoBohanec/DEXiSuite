// FormMain.pas is part of
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
// FormMain.pas implements the main form of DEXiWin as an MDI environment for
// model-editing forms ('FormModel').
// 'FormMain' defines global menus and toolbars, and some centralized image lists.
// Warning: To avoid memory leaks, any references to these image lists from other
// forms must be explicitly nullified while diposing those forms.
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
  RemObjects.Elements.RTL,
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for MainForm.
  /// </summary>
  MainForm = public partial class(System.Windows.Forms.Form)
  private
    method ItemAppHelpHelp_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppFileClose_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowFontShrink_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowFontEnlarge_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowFontResize_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppHelpSystem_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolRedo_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolUndo_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppSettings_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppExportModel_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppImportFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppExportFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppImportAlt_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppExportAlt_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppExportTree_Click(sender: System.Object; e: System.EventArgs);
    method MainForm_MdiChildActivate(sender: System.Object; e: System.EventArgs);
    method MainForm_Activated(sender: System.Object; e: System.EventArgs);
    method ItemAppFileSaveAs_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppFileSave_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppHelpAbout_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppFileExit_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppFileOpen_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppFileNew_Click(sender: System.Object; e: System.EventArgs);
    method MainForm_Load(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowNormal_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowMaximize_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowMinimize_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowArrange_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowTileVertically_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowTileHorizontally_Click(sender: System.Object; e: System.EventArgs);
    method ItemAppWindowCascade_Click(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(disposing: Boolean); override;
    method SetFontZoom(aFontZoom: Float);
  private
    fChildCount: Integer := 0;
    fMergedMenu: MenuStrip := nil;
    fMergedTool: ToolStrip := nil;
    fFontZoom := 1.0;
    class const LowZoom = 0.7;
    class const HighZoom = 1.5;
    class const PercZoom = 0.1;
  public
    constructor;
    method UpdateForm;
    method ChildOpened;
    method ChildClosed(aForm: Form);
    method OpenModel(aFileName: String);
    method Merge(aMenu: MenuStrip; aTool: ToolStrip);
    property AppImages: ImageList read MainImages;
    property ModelImages: ImageList read TreeImages;
    property ScaleImages: ImageList read ScaleImages;
    property ValueImages: ImageList read ValueImages;
    property FontZoom: Float read fFontZoom write SetFontZoom;
  end;

type LoadProjectType = public enum (DexProject, DexModel, DexiModel);

implementation

{$REGION Construction and Disposition}
constructor MainForm;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  Text := AppVersion.Name;

  {$IFDEF DEBUG}
    ItemAppHelpSystem.Visible := true;
  {$ELSE}
    ItemAppHelpSystem.Visible := false;
  {$ENDIF}
end;

method MainForm.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method MainForm.SetFontZoom(aFontZoom: Float);
begin
  if (aFontZoom < LowZoom) or (aFontZoom > HighZoom) then
    exit;
  fFontZoom := aFontZoom;
  AppUtils.SetAppFontZoom(fFontZoom);
  UpdateForm;
end;

method MainForm.UpdateForm;
begin
  ItemAppWindow.Visible := fChildCount > 0;
  var lMdiActive := (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel);
  AppUtils.Enable((fChildCount > 0) and lMdiActive,
    ItemAppFileClose, ItemAppFileSave, ItemAppFileSaveAs, ItemToolSave, ItemAppImport, ItemAppExport, ItemAppSettings);
  AppUtils.Enable((fChildCount > 0) and lMdiActive and FormModel(ActiveMdiChild).CanUndo, ItemAppEditUndo, ItemToolUndo);
  AppUtils.Enable((fChildCount > 0) and lMdiActive and FormModel(ActiveMdiChild).CanRedo, ItemAppEditRedo, ItemToolRedo);
  AppUtils.Enable((fChildCount > 0) and lMdiActive and FormModel(ActiveMdiChild).CanImportFunct, ItemAppImportFunct);
  AppUtils.Enable((fChildCount > 0) and lMdiActive and FormModel(ActiveMdiChild).CanExportFunct, ItemAppExportFunct);
  AppUtils.Enable(((1 + PercZoom) * fFontZoom < HighZoom) and lMdiActive, ItemAppWindowFontEnlarge);
  AppUtils.Enable(((1 - PercZoom) * fFontZoom > LowZoom)  and lMdiActive, ItemAppWindowFontShrink);
end;

method MainForm.ChildOpened;
begin
  inc(fChildCount);
  UpdateForm;
end;

method MainForm.ChildClosed(aForm: Form);
begin
  dec(fChildCount);
  UpdateForm;
end;

method MainForm.OpenModel(aFileName: String);
begin
  var lModel := new DexiModel;
  lModel.XmlHandler := new AppXmlHandler(lModel);
  lModel.LoadFromFile(aFileName);
  var lModForm := new FormModel;
  lModForm.MdiParent := self;
  lModForm.OpenForm(lModel);
  lModel.Modified := false;
end;

method MainForm.Merge(aMenu: MenuStrip; aTool: ToolStrip);
begin
  if Disposing then
    exit;
  if aMenu <> fMergedMenu then
    begin
      if fMergedMenu <> nil then
        begin
          ToolStripManager.RevertMerge(AppMenu, fMergedMenu);
          fMergedMenu := nil;
        end;
      if aMenu <> nil then
        begin
          ToolStripManager.Merge(aMenu, AppMenu);
          fMergedMenu := aMenu;
        end;
    end;
  if aTool <> fMergedTool then
    begin
      if fMergedTool <> nil then
        begin
          ToolStripManager.RevertMerge(AppTool, fMergedTool);
          fMergedTool := nil;
        end;
      if aTool <> nil then
        begin
          ToolStripManager.Merge(aTool, AppTool);
          fMergedTool := aTool;
        end;
    end;
end;

method MainForm.ItemAppWindowCascade_Click(sender: System.Object; e: System.EventArgs);
begin
  LayoutMdi(MdiLayout.Cascade);
end;

method MainForm.ItemAppWindowTileHorizontally_Click(sender: System.Object; e: System.EventArgs);
begin
  LayoutMdi(MdiLayout.TileHorizontal);
end;

method MainForm.ItemAppWindowTileVertically_Click(sender: System.Object; e: System.EventArgs);
begin
  LayoutMdi(MdiLayout.TileVertical);
end;

method MainForm.ItemAppWindowArrange_Click(sender: System.Object; e: System.EventArgs);
begin
    LayoutMdi(MdiLayout.ArrangeIcons);
end;

method MainForm.ItemAppWindowMinimize_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lChild in MdiChildren do
    lChild.WindowState := FormWindowState.Minimized;
end;

method MainForm.ItemAppWindowMaximize_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lChild in MdiChildren do
    lChild.WindowState := FormWindowState.Maximized;
end;

method MainForm.ItemAppWindowNormal_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lChild in MdiChildren do
    lChild.WindowState := FormWindowState.Normal;
end;

method MainForm.MainForm_Load(sender: System.Object; e: System.EventArgs);
begin
  UpdateForm;
end;

method MainForm.ItemAppFileNew_Click(sender: System.Object; e: System.EventArgs);
begin
  var lModel := DexiModel.NewModel(DexiString.SDexiNewAttribute + Utils.IntToStr(fChildCount + 1));
  lModel.XmlHandler := new AppXmlHandler(lModel);
  var lModForm := new FormModel;
  lModForm.MdiParent := self;
  lModForm.OpenForm(lModel);
end;

method MainForm.ItemAppFileOpen_Click(sender: System.Object; e: System.EventArgs);
begin
  if OpenModelDialog.ShowDialog <> DialogResult.OK then
    exit;
  OpenModel(OpenModelDialog.FileName);
end;

method MainForm.ItemAppFileExit_Click(sender: System.Object; e: System.EventArgs);
begin
  Close;
end;

method MainForm.ItemAppHelpAbout_Click(sender: System.Object; e: System.EventArgs);
begin
  AppData.AboutForm.ShowDialog;
end;

method MainForm.ItemAppFileSave_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).SaveFile;
end;

method MainForm.ItemAppFileSaveAs_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).SaveFileAs;
end;

method MainForm.MainForm_Activated(sender: System.Object; e: System.EventArgs);
begin
  try
    for each lModFile in AppData.LoadModels do
      if File.Exists(lModFile) then
        OpenModel(lModFile)
      else
        raise new EDexiError(String.Format(DexiStrings.NoFileError, lModFile));
  finally
    AppData.LoadModels.RemoveAll;
  end;
end;

method MainForm.MainForm_MdiChildActivate(sender: System.Object; e: System.EventArgs);
begin
  Merge(nil, nil);
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).MergeMain;
end;

method MainForm.ItemAppExportTree_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ExportTree;
end;

method MainForm.ItemAppExportAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ExportAlternatives;
end;

method MainForm.ItemAppImportAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ImportAlternatives;
end;

method MainForm.ItemAppExportFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ExportFunction;
end;

method MainForm.ItemAppImportFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ImportFunction;
end;

method MainForm.ItemAppExportModel_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).ExportModel;
end;

method MainForm.ItemAppSettings_Click(sender: System.Object; e: System.EventArgs);
begin
  var lModel :=
    if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then FormModel(ActiveMdiChild).Model
    else nil;
  using lForm := new FormSettings do
    begin
      lForm.SetForm(lModel);
      if lForm.ShowDialog = DialogResult.OK then
        begin
          if lModel <> nil then
            begin
              var lPrevSettings := lModel.Settings;
              lModel.Settings := lForm.Settings;
              lModel.ChartParameters := lForm.ChartParameters;
              lModel.Modify;
              var lModelForm := AppUtils.ModelForm(lModel);
              if lModelForm <> nil then
                begin
                  lModelForm.ApplySettings(lPrevSettings);
                  lModelForm.SaveState;
                  lModelForm.SignalDataChanged;
                end;
            end;
        end;
    end;
end;

method MainForm.ItemToolUndo_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).Undo;
end;

method MainForm.ItemToolRedo_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    FormModel(ActiveMdiChild).Redo;
end;

method MainForm.ItemAppHelpSystem_Click(sender: System.Object; e: System.EventArgs);
begin
  using lForm := new FormSystem do
    lForm.ShowDialog;
end;

method MainForm.ItemAppWindowFontResize_Click(sender: System.Object; e: System.EventArgs);
begin
  FontZoom := 1.0;
end;

method MainForm.ItemAppWindowFontEnlarge_Click(sender: System.Object; e: System.EventArgs);
begin
  FontZoom := (1 + PercZoom) * FontZoom;
end;

method MainForm.ItemAppWindowFontShrink_Click(sender: System.Object; e: System.EventArgs);
begin
  FontZoom := (1 - PercZoom) * FontZoom;
end;

method MainForm.ItemAppFileClose_Click(sender: System.Object; e: System.EventArgs);
begin
  if (ActiveMdiChild <> nil) and (ActiveMdiChild is FormModel) then
    ActiveMdiChild.Close;
end;

method MainForm.ItemAppHelpHelp_Click(sender: System.Object; e: System.EventArgs);
begin
  System.Diagnostics.Process.Start("https://dex.ijs.si/documentation/DEXiWin/DEXiWin.html");
end;

end.