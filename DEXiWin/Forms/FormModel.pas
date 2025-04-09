// FormModel.pas is part of
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
// FormModel.pas implements a form for editing a single 'DexiModel'. Its GUI essentially
// consists only of a 'CtrlTabs' control aimed at holding other model-editing 'CtrlForms'.
// Additionally, 'FormModel' provides mothods for importing and exporting particular
// DEXi models and their components.
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
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormProject.
  /// </summary>
  FormModel = public partial class(System.Windows.Forms.Form)
  private
    method FormModel_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method FormModel_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
    method FormModel_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
    method ModelTabs_Load(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
    method ReportTabClosed(sender: System.Object; e: System.EventArgs);
    method TreeTabClosed(sender: System.Object; e: System.EventArgs);
  private
    fModel: DexiModel;
    fMergedMenu: MenuStrip := nil;
    fMergedTool: ToolStrip := nil;
    fAltVisibility: AlternativesVisibility;
    fUndoRedo: ModelUndoRedo;
  protected
    method GetFormName: String;
    method ModelStatus: String;
    method NewCtrlRptForm(aReport: DexiReportGroup): ITabReportCtrlForm;
    method ChangeReportTab(aTab: TabPage; aCtrl: ITabReportCtrlForm);
    method SelectAlternativesToExport;
  public
    constructor;
    method OpenForm(aModel: DexiModel);
    method Merge(aMenu: MenuStrip; aTool: ToolStrip);
    method MergeMain;
    property Model: DexiModel read fModel;
    property DrawingAlgorithm := new DexiTreeDrawingAlgorithm(fModel); lazy;
    property FormName: String read GetFormName;
    property AltVisibility: AlternativesVisibility read fAltVisibility;
    property TabPages: array of TabPage read ModelTabs.TabPages;
    property UndoCount: Integer read fUndoRedo.UndoCount;
    property RedoCount: Integer read fUndoRedo.RedoCount;
    property ModelControl: CtrlFormModel;
    property AlternativesControl: CtrlFormAlternatives;
    property EvaluationControl: CtrlFormEvaluation;
    property ChartControl: CtrlFormCharts;
    property ReportControls: List<ITabReportCtrlForm>;
    property TreeControl: CtrlFormTree;
    method Init;
    method UpdateForm;
    method SaveFile;
    method SaveFileAs;
    method CheckFileSave: Boolean;
    method AddReportTab(aReport: DexiReportGroup; aCloseable: Boolean): ClosableTabPage;
    method CanUndo: Boolean;
    method CanRedo: Boolean;
    method CanImportFunct: Boolean;
    method CanExportFunct: Boolean;
    method SaveState;
    method Undo;
    method Redo;
    method ExportTree;
    method ExportModel;
    method ExportAlternatives;
    method ImportAlternatives;
    method ExportFunction;
    method ImportFunction;
    method SignalDataChanged;
    method OpenTreeGraphic;
    method TabIndex(aForm: CtrlForm): Integer;
    method OpenTab(aForm: CtrlForm);
    method ApplySettings(aPrevious: DexiSettings);
    method ChangeReportTabs;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormModel;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  ModelTabs.BringToFront;
  ModelTabs.Dock := DockStyle.Fill;
end;

method FormModel.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    fModel := nil;
    fUndoRedo := nil;
    fMergedMenu := nil;
    fMergedTool := nil;
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormModel.GetFormName: String;
begin
  result := $"{fModel:Name} [{fModel:FileName}]";
end;

method FormModel.OpenForm(aModel: DexiModel);
begin
  fModel := aModel;
  fModel.Modified := false;
  fUndoRedo := new ModelUndoRedo(self);
  fUndoRedo.Active := fModel.Settings.Undoing;
  Text := FormName;
  Init;
  UpdateForm;
  WindowState := FormWindowState.Maximized;
  Show;
  AppData.AppForm.ChildOpened;
  fUndoRedo.SetState;
end;

method FormModel.NewCtrlRptForm(aReport: DexiReportGroup): ITabReportCtrlForm;
begin
  var lManagerForm := new FormReportManager;
  lManagerForm.SetForm(aReport);
  var lCtrlForm :=
    if Model.Settings.RptHtml or AppSettings.ForcedHtmlReports then new CtrlFormBrowse
    else new CtrlFormReport;
  var lCtrlReportForm := lCtrlForm as ITabReportCtrlForm;
  lCtrlReportForm.Report := aReport;
  lCtrlReportForm.ManagerForm := lManagerForm;
  result := lCtrlReportForm;
end;

method FormModel.AddReportTab(aReport: DexiReportGroup; aCloseable: Boolean): ClosableTabPage;
require
  aReport <> nil;
begin
  var lCtrlReportForm := NewCtrlRptForm(aReport);
  var lCtrlForm := CtrlForm(lCtrlReportForm);
  ReportControls.Add(lCtrlReportForm);
  var lPage := ModelTabs.AddPage('ImgReport', aReport.Title, lCtrlForm, aCloseable, Model.Settings.CanMoveTabs);
  lPage.TabClosed += ReportTabClosed;
  lCtrlReportForm.Init;
  result := lPage;
end;

method FormModel.CanUndo: Boolean;
begin
  result := fUndoRedo.CanUndo;
end;

method FormModel.CanRedo: Boolean;
begin
  result := fUndoRedo.CanRedo;
end;

method FormModel.CanImportFunct: Boolean;
begin
  result :=
    if (ModelControl = nil) or not ModelControl.Visible then false
    else ModelControl.CanImportFunct;
end;

method FormModel.CanExportFunct: Boolean;
begin
  result :=
    if (ModelControl = nil) or not ModelControl.Visible then false
    else ModelControl.CanExportFunct;
end;

method FormModel.SaveState;
begin
  fUndoRedo.AddState;
end;

method FormModel.Undo;
begin
  if not fUndoRedo.CanUndo then
    exit;
  fUndoRedo.Undo;
  SignalDataChanged;
  UpdateForm;
end;

method FormModel.Redo;
begin
  if not fUndoRedo.CanRedo then
    exit;
  fUndoRedo.Redo;
  SignalDataChanged;
  UpdateForm;
end;

method FormModel.Init;
begin
  ModelTabs.TabsCtrl.ImageList := AppData.AppImages;
  fAltVisibility := new AlternativesVisibility(Model.AltCount);
  ModelControl := new CtrlFormModel;
  AppData.NewModelContext(Model, self, ModelControl);
  ModelControl.Model := Model; // uses model context
  AlternativesControl := new CtrlFormAlternatives;
  AlternativesControl.Model := Model;
  EvaluationControl := new CtrlFormEvaluation;
  EvaluationControl.Model := Model;
  ChartControl := new CtrlFormCharts;
  ChartControl.Model := Model;
  ModelTabs.AddPage('ImgModel', 'Model', ModelControl, false, Model.Settings.CanMoveTabs);
  ModelTabs.AddPage('ImgAlternatives', 'Alternatives', AlternativesControl, false, Model.Settings.CanMoveTabs);
  ModelTabs.AddPage('ImgEvaluation', 'Evaluation', EvaluationControl, false, Model.Settings.CanMoveTabs);
  ModelControl.Init;
  AlternativesControl.Init;
  EvaluationControl.Init;
  ReportControls := new List<ITabReportCtrlForm>;
  for lRpt in Model.Reports index x do
    if x = 0 then
      AddReportTab(lRpt, false);
  ModelTabs.AddPage('ImgChart', 'Charts', ChartControl, false, Model.Settings.CanMoveTabs);
  ChartControl.Init;
  for lRpt in Model.Reports index x do
    if x > 0 then
      AddReportTab(lRpt, true);
end;

method FormModel.Merge(aMenu: MenuStrip; aTool: ToolStrip);
begin
  fMergedMenu := aMenu;
  fMergedTool := aTool;
  MergeMain;
end;

method FormModel.MergeMain;
begin
  AppData.AppForm.Merge(fMergedMenu, fMergedTool);
end;

method FormModel.ModelStatus: String;
begin
  if fModel = nil then
    exit '';
  var lStat := fModel.Statistics;
  result := String.Format(DexiStrings.ModelStatus,
    lStat.Attributes, lStat.BasicAttributes, lStat.AggregateAttributes, lStat.LinkedAttributes, lStat.Scales, lStat.Functions, lStat.Alternatives);
  if fModel.Modified then
    result := '* ' + result;
  if fModel.Settings.ModelProtect then
    result := result + ' ' + DexiStrings.ModelProtected;
end;

method FormModel.UpdateForm;
begin
  StatusBarText.Text := ModelStatus;
  var lText := GetFormName;
  if Text <> lText then
    begin
      Text := lText;
      AppData.AppForm.Invalidate;
    end;
end;

method FormModel.SaveFile;
begin
  if Model = nil then
    exit;
  if String.IsNullOrEmpty(Model.FileName) then
    begin
      Model.FileName := Model.Name + '.dxi';
      SaveFileAs;
    end
  else
    begin
      Model.SaveToFile(Model.FileName);
      UpdateForm;
    end;
end;

method FormModel.SaveFileAs;
begin
  if Model = nil then
    exit;
  FileSaveAsDialog.FileName := Model.FileName;
  if FileSaveAsDialog.ShowDialog <> DialogResult.OK then
    exit;
  Model.SaveToFile(FileSaveAsDialog.FileName);
  UpdateForm;
end;

method  FormModel.CheckFileSave: Boolean;
begin
  result := true;
  if not fModel.Modified then
    exit;
  var lMsg :=
    if String.IsNullOrEmpty(fModel.FileName) then String.Format(DexiStrings.MsgNewFileSave, fModel.Name)
    else  String.Format(DexiStrings.MsgFileSave, fModel.Name, fModel.FileName);
  var lResponse := MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);
  case lResponse of
    DialogResult.Yes:
      SaveFile;
    DialogResult.No:
      { nothing } ;
    else
      result := false;
  end;
end;

method FormModel.ModelTabs_Load(sender: System.Object; e: System.EventArgs);
begin
  ModelTabs.TabsCtrl.ImageList := AppData.AppImages;
end;

method FormModel.FormModel_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
begin
  AppData.AppForm.ChildClosed(self);
  AppData.RemoveModelContext(Model);
end;

method FormModel.FormModel_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
begin
  if not CheckFileSave then
    e.Cancel := true;
end;

method FormModel.FormModel_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  // bypass ObjectListView's handling of tree collapsing and expanding keys
  if (e.KeyCode = Keys.Left) or (e.KeyCode = Keys.Right) then
    if EvaluationControl.Visible then
      begin
        EvaluationControl.DoKeyDown(sender, e);
        e.Handled := true;
      end
    else if AlternativesControl.Visible then
      begin
        AlternativesControl.DoKeyDown(sender, e);
        e.Handled := true;
      end;
  if e.KeyCode = Keys.F8 then
    begin
      if ModelControl.Visible then
        ModelControl.ResizeColumns
      else if AlternativesControl.Visible then
        AlternativesControl.ResizeColumns
      else if EvaluationControl.Visible then
        EvaluationControl.ResizeColumns;
      e.Handled := true;
    end;

  if e.KeyCode = Keys.F12 then
    begin
    // temporary testing activation
      e.Handled := true;
    end;
  end;

method FormModel.ReportTabClosed(sender: System.Object; e: System.EventArgs);
begin
  var lSender := TabPage(sender);
  if (lSender:Controls <> nil) and (lSender.Controls.Count > 0) and (lSender.Controls[0] is ITabReportCtrlForm) then
    begin
      var lRptCtrl := ITabReportCtrlForm(lSender.Controls[0]);
      var lReport := DexiReportGroup(lRptCtrl.Report);
      if lReport <> nil then
        begin
          Model.Reports.Remove(lReport);
          Model.Modified := true;
        end;
    end;
//  if lSender is ClosableTabPage then
//    ClosableTabPage(lSender).TabClosed -= @ReportTabClosed;
end;

method FormModel.TreeTabClosed(sender: System.Object; e: System.EventArgs);
begin
  var lSender := TabPage(sender);
  if (lSender:Controls <> nil) and (lSender.Controls.Count > 0) and (lSender.Controls[0] is CtrlFormTree) then
    TreeControl := nil;
//  if lSender is ClosableTabPage then
//    ClosableTabPage(lSender).TabClosed -= @TreeTabClosed;
end;

method FormModel.ExportModel;
begin
  if ExportModelDialog.ShowDialog <> DialogResult.OK then
    exit;
  case ExportModelDialog.FilterIndex of
    2:
      begin
        var lSettings := new DexiJsonSettings(Model.Settings.JsonSettings);
        lSettings.IncludeModel := true;
        lSettings.IncludeAlternatives := false;
        Model.SaveToJsonFile(ExportModelDialog.FileName, lSettings);
      end;
    else
      Model.SaveToJsonFile(ExportModelDialog.FileName, Model.Settings.JsonSettings);
  end;
end;

method FormModel.ExportTree;
begin
  if ExportTreeDialog.ShowDialog <> DialogResult.OK then
    exit;
  case ExportTreeDialog.FilterIndex of
    1: Model.SaveToGMLFile(ExportTreeDialog.FileName);
    2: Model.SaveTreeToTabFile(ExportTreeDialog.FileName);
  end;
end;

method FormModel.SelectAlternativesToExport;
begin
  Model.AltExclude := [];
  var lSelectedPage := ModelTabs.SelectedPage;
  var lAltVisible :=
    if lSelectedPage is CtrlFormAlternatives then AltVisibility.AlternativeVisibility
    else if lSelectedPage is CtrlFormEvaluation then AltVisibility.EvaluationVisibility
    else nil;
  if lAltVisible = nil then
    exit;
  for i := 0 to Model.AltCount - 1 do
    if not lAltVisible.Contains(i) then
      Model.Selected[i] := false;
end;

method FormModel.ExportAlternatives;
begin
  if ExportAltDialog.ShowDialog <> DialogResult.OK then
    exit;
  SelectAlternativesToExport;
  var lTable := new DexiAlternativesTable(Model);
  lTable.LoadFromModel(Model);
  case ExportAltDialog.FilterIndex of
    1: lTable.SaveToTabFile(ExportAltDialog.FileName);
    2: lTable.SaveToCSVFile(ExportAltDialog.FileName);
    3:
      begin
        var lSettings := new DexiJsonSettings(Model.Settings.JsonSettings);
        lSettings.IncludeModel := false;
        lSettings.IncludeAlternatives := true;
        Model.SaveToJsonFile(ExportAltDialog.FileName, lSettings);
      end;
  end;
  Model.AltExclude := [];
end;

method FormModel.ImportAlternatives;
begin
  if ImportAltDialog.ShowDialog <> DialogResult.OK then
    exit;
  var lAdded := new SetOfInt;
  if ImportAltDialog.FilterIndex = 3 then // Json
    begin
      var lJsonReader := new DexiJsonReader;
      var lRead := lJsonReader.LoadAlternativesFromFile(ImportAltDialog.FileName, Model);
      if lRead.Success then
        begin
          if lRead.Warnings.Count > 0 then
            if MessageBox.Show(String.Join(Environment.LineBreak, lRead.Warnings),
              "Warning(s)", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning) = DialogResult.Cancel then
                exit;
          var lAlternatives := lRead.Alternatives;
          lAdded := Model.AddAlternatives(lAlternatives, true);
        end
      else
        begin
          MessageBox.Show(String.Join(Environment.LineBreak, lRead.Errors),
            "Error(s)", MessageBoxButtons.OK, MessageBoxIcon.Error);
          exit;
        end;
    end
  else
    begin
      var lTable := new DexiAlternativesTable(Model);
      case ImportAltDialog.FilterIndex of
        1: lTable.LoadFromTabFile(ImportAltDialog.FileName, Model);
        2: lTable.LoadFromCSVFile(ImportAltDialog.FileName, Model);
      end;
      lTable.SaveToModel(false);
      var lUnmatched := lTable.UnmatchedAttributes;
      if not String.IsNullOrEmpty(lUnmatched) then
        if MessageBox.Show(String.Format(DexiStrings.MsgUnmatchedAttributes, lUnmatched),
          'Warning', MessageBoxButtons.OKCancel, MessageBoxIcon.Warning) = DialogResult.Cancel then
            exit;
      lAdded := lTable.AddedAlternatives;
    end;
  AltVisibility.AddAlternatives(lAdded);
  SaveState;
  SignalDataChanged;
  MessageBox.Show(String.Format(DexiStrings.MsgAlternativesImported, lAdded.Count),
    "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
end;

method FormModel.ExportFunction;
begin
  if ExportFncDialog.ShowDialog <> DialogResult.OK then
    exit;
  ModelControl.ExportFunct(ExportFncDialog.FileName);
end;

method FormModel.ImportFunction;
begin
  if not CanImportFunct then
    exit;
  if ImportFncDialog.ShowDialog <> DialogResult.OK then
    exit;
  ModelControl.ImportFunct(ImportFncDialog.FileName);
end;

method FormModel.SignalDataChanged;
begin
  ModelControl.ModelChanged;
  AlternativesControl.DataChanged;
  EvaluationControl.DataChanged;
  for lRptForm in ReportControls do
    lRptForm.DataChanged;
  ChartControl.DataChanged;
end;

method FormModel.OpenTreeGraphic;
begin
  if TreeControl = nil then
    begin
      TreeControl := new CtrlFormTree;
      TreeControl.Model := Model;
      var lPage := ModelTabs.AddPage('ImgTree', DexiStrings.TitleTree, TreeControl, true, Model.Settings.CanMoveTabs);
      lPage.TabClosed += TreeTabClosed;
      TreeControl.Init;
    end;
  OpenTab(TreeControl);
end;

method FormModel.TabIndex(aForm: CtrlForm): Integer;
begin
  result := -1;
  for each lTabPage in TabPages index x do
    if (lTabPage:Controls <> nil) and (lTabPage.Controls.Count > 0) then
      if lTabPage.Controls[0] = aForm then
        exit x;
end;

method FormModel.OpenTab(aForm: CtrlForm);
begin
  var lIdx := TabIndex(aForm);
  if lIdx >= 0 then
    ModelTabs.TabsCtrl.SelectedIndex := lIdx;
end;

method FormModel.ChangeReportTab(aTab: TabPage; aCtrl: ITabReportCtrlForm);
begin
  var aToHtml := Model.Settings.RptHtml or AppSettings.ForcedHtmlReports;
  if (aCtrl is CtrlFormBrowse) and aToHtml then
    exit;
  if (aCtrl is CtrlFormReport) and not aToHtml then
    exit;
  var lCtrlReportForm := NewCtrlRptForm(aCtrl.Report as DexiReportGroup);
  var lCtrlForm := CtrlForm(lCtrlReportForm);
  ReportControls.Remove(aCtrl);
  ReportControls.Add(lCtrlReportForm);
  var lPrev := CtrlForm(aCtrl);
  aTab.Controls.Remove(lPrev);
  aTab.Controls.Add(lCtrlForm);
  lPrev.Dispose;
  lCtrlReportForm.Init;
  lCtrlForm.Activate;
end;

method FormModel.ChangeReportTabs;
begin
  for each lTabPage in TabPages do
    if (lTabPage:Controls <> nil) and (lTabPage.Controls.Count > 0) then
      for each lCtrl in lTabPage.Controls do
        if lCtrl is ITabReportCtrlForm then
          begin
            ChangeReportTab(lTabPage, ITabReportCtrlForm(lCtrl));
            break;
          end;
end;

method FormModel.ApplySettings(aPrevious: DexiSettings);
begin
  if Model.Settings.Undoing <> fUndoRedo.Active then
    fUndoRedo.Active := Model.Settings.Undoing;
  if (aPrevious = nil) or (aPrevious.CanMoveTabs <> Model.Settings.CanMoveTabs) then
    for each lTab in TabPages do
      if lTab is ClosableTabPage then
        ClosableTabPage(lTab).AllowMove := Model.Settings.CanMoveTabs;
  if (aPrevious <> nil) and (aPrevious.RptHtml <> Model.Settings.RptHtml) then
    ChangeReportTabs;
  // if modifying settings affects only the main report, leaving others as is
  if ReportControls.Count > 0 then
    ReportControls[0].SettingsChanged;
  (*
  // if modifying Settings affects all reports
  for each lRptCtrl in ReportControls do
    lRptCtrl.SettingsChanged;
  *)
  ChartControl.SettingsChanged;
end;

end.