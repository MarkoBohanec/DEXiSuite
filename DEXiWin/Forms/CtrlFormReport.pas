// CtrlFormReport.pas is part of
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
// CtrlFormReport.pas implements a 'CtrlForm' for displaying DEXi reports produced by
// 'RptImageFormatter' (WinFormatter.pas). Reports are paginated and rendered in a
// nicely formatted image format (typically Metafile) that can be exported to other
// documents.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Drawing.Printing,
  System.Drawing.Imaging,
  System.Collections,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows,
  System.Windows.Forms,
  System.ComponentModel,
  BrightIdeasSoftware,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for CtrlFormReport.
  /// </summary>
  CtrlFormReport = public partial class(CtrlForm, ITabReportCtrlForm)
  private
    method FormMenu_ItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
    
    method ItemMenuCropMetafile_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCropBitmap_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolBrowse_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopTwoPages_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopPageWidth_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopFullPage_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopActualSize_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
    method CtrlFormReport_Leave(sender: System.Object; e: System.EventArgs);
    method ItemToolZoom_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
    method ItemToolZoom_ButtonClick(sender: System.Object; e: System.EventArgs);
    method ItemToolStartPageEdit_Leave(sender: System.Object; e: System.EventArgs);
    method ItemToolStartPageEdit_Validated(sender: System.Object; e: System.EventArgs);
    method ItemToolStartPageEdit_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method ItemToolStartPageEdit_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method ItemToolStartPageEdit_Enter(sender: System.Object; e: System.EventArgs);
    method ItemToolLast_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolNext_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPrev_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolFirst_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPrint_Click(sender: System.Object; e: System.EventArgs);
    method Viewer_StartPageChanged(sender: System.Object; e: System.EventArgs);
    method CtrlFormReport_VisibleChanged(sender: System.Object; e: System.EventArgs);
    method ItemToolPageSetup_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
   private
    fReport: DexiReport;
    fParamForm: FormReportParameters;
    fManagerForm: FormReportManager;
    fFormatter: RptImageFormatter;
    fDocument: RptPrintDocument;
    fInitialized := false;
    fNeedRemake: Boolean;
    fUpdateLevel := 0;
    fPageSettings: PageSettings;
    fOnRemake: Action;
    fFormMode: Boolean := false;
  protected
    method Dispose(disposing: Boolean); override;
    method FontMaker(aTag: Integer; aBaseFont: Font): Font;
    method BrushMaker(aTag: Integer): Brush;
    method SetReport(aReport: DexiReport);
    method RemakeReport;
    method ReformatReport;
    method UpdateForm;
    method CommitPageNumber;
    method CommitFormatting;
  public
    constructor;
    method Init;
    method DoEnter;
    method DoLeave;
    method DoFormat;
    method DoKeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method SaveState;
    method DataChanged;
    method ForceRemake;
    method SettingsChanged;
    property Model: DexiModel read fReport:Model;
    property Report: DexiReport read fReport write SetReport;
    property FormMode: Boolean read fFormMode write fFormMode;
    property ParamForm: FormReportParameters read fParamForm write fParamForm;
    property ManagerForm: FormReportManager read fManagerForm write fManagerForm;
    property PageCount: Integer read if fFormatter = nil then 0 else fFormatter.ImagePageCount;
    property StartPage: Integer read Viewer.StartPage write Viewer.StartPage;
    property OnRemake: Action read fOnRemake write fOnRemake;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormReport;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //

  using lPrintDoc := new PrintDocument do
    fPageSettings := lPrintDoc.DefaultPageSettings.Clone as PageSettings;
  if not AppSettings.UseReportBorders then
    begin
      var lBorder := AppSettings.DefaultReportBorder;
      fPageSettings.Margins.Left := lBorder.Left;
      fPageSettings.Margins.Right := lBorder.Right;
      fPageSettings.Margins.Top := lBorder.Top;
      fPageSettings.Margins.Bottom := lBorder.Bottom;
    end;
  CtrlMenu := FormMenu;
  CtrlTool := FormTool;
  fNeedRemake := false;
  StartPage := 0;
  Viewer.Focus;
end;

method CtrlFormReport.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    if fParamForm <> nil then
      begin
        if not fParamForm.IsDisposed then
          fParamForm.Dispose;
        fParamForm := nil;
      end;
    if fManagerForm <> nil then
      begin
        if not fManagerForm.IsDisposed then
          fManagerForm.Dispose;
        fManagerForm := nil;
      end;
    fReport := nil;
  end;
  inherited Dispose(disposing);
end;

{$ENDREGION}

method CtrlFormReport.SetReport(aReport: DexiReport);
begin
  if aReport <> fReport then
    begin
      fReport := aReport;
      fNeedRemake := true;
      SaveReportDialog.FileName :=
        if String.IsNullOrEmpty(Model:Name) then DexiStrings.ReportFileName
        else Model.Name;
      ItemMenuEditAddReport.Visible := aReport is not DexiReportGroup;
      CommitFormatting;
    end;
end;

method CtrlFormReport.FontMaker(aTag: Integer; aBaseFont: Font): Font;
begin
  if fReport:Model:Settings = nil then
    result := DexiFormatMaker.FontMaker(aTag, aBaseFont)
  else
    begin
      var lSettings := fReport.Model.Settings;
      var lStyle :=
        if aTag = 0 then lSettings.NeutralStyle
        else if aTag < 0 then lSettings.BadStyle
        else lSettings.GoodStyle;
      var lFontData := new FontData(aBaseFont, Style := lStyle);
      var lWinStyle := lFontData.WinStyle;
      result := new Font(aBaseFont, lWinStyle);
    end;
end;

method CtrlFormReport.BrushMaker(aTag: Integer): Brush;
begin
  if fReport:Model:Settings = nil then
    result := DexiFormatMaker.BrushMaker(aTag)
  else
    begin
      var lSettings := fReport.Model.Settings;
      var lColorInfo :=
        if aTag = 0 then lSettings.NeutralColor
        else if aTag < 0 then lSettings.BadColor
        else lSettings.GoodColor;
      var lColor := new ColorData(lColorInfo).NewColor;
      result := new SolidBrush(lColor);
    end;
end;

method CtrlFormReport.Init;
begin
  fFormatter := nil;
  fDocument := nil;
  fInitialized := true;
  UpdateForm;
end;

method CtrlFormReport.DoEnter;
begin
  fNeedRemake := true;
  PanelMessage.Visible := true;
  CommitFormatting;
end;

method CtrlFormReport.DoLeave;
begin
  fNeedRemake := true;
  fFormatter := nil;
//  PanelMessage.Visible := true;
end;

method CtrlFormReport.DoFormat;
begin
  if not Disposing and fNeedRemake then
    begin
      PanelMessage.Visible := true;
      Refresh;
      RemakeReport;
    end;
  PanelMessage.Visible := false;
  Viewer.Focus;
  Viewer.RefreshPreview;
end;

method CtrlFormReport.RemakeReport;
begin
  if (fReport = nil) or not fNeedRemake then
    exit;
  Text := fReport.Title;
  fReport.MakeReport(true);
  ReformatReport;
  PanelMessage.Visible := false;
  Viewer.RefreshPreview;
  fNeedRemake := false;
end;

method CtrlFormReport.ReformatReport;
begin
  fFormatter := nil;
  if fReport = nil then
    exit;
  try
    var lWidth := FmtDistances.Inches(fPageSettings.PrintableArea.Width / 100.0);
    var lHeight := FmtDistances.Inches(fPageSettings.PrintableArea.Height / 100.0);
    if fPageSettings.Landscape then
      begin
        var t := lWidth;
        lWidth := lHeight;
        lHeight := t;
      end;
    fFormatter := new RptImageFormatter(Report.Report,
      new RptDimensions(lWidth, lHeight),
      new RptBorders(
        FmtDistances.Inches(fPageSettings.Margins.Left / 100.0),
        FmtDistances.Inches(fPageSettings.Margins.Right / 100.0),
        FmtDistances.Inches(fPageSettings.Margins.Top / 100.0),
        FmtDistances.Inches(fPageSettings.Margins.Bottom / 100.0)
        )
    );
    fFormatter.UseMetafile := true;
    fFormatter.FontMaker := @FontMaker;
    fFormatter.BrushMaker := @BrushMaker;
    if fParamForm <> nil then
      fFormatter.DefaultFont := fParamForm.SelectedFont;
    if fManagerForm <> nil then
      fFormatter.DefaultFont := fManagerForm.SelectedFont;
    if fDocument <> nil then
      fDocument.Dispose;
    fDocument := new RptPrintDocument(fFormatter);
    Viewer.Document := fDocument;
    fFormatter.Format;
    fFormatter.Render;
  except on E: Exception do
    begin
      MessageBox.Show(E.Message);
      MessageBox.Show(DexiStrings.EnforcingHtmlReports);
      AppSettings.ForcedHtmlReports := true;
      var lModelForm := AppUtils.ModelForm(Model);
      if lModelForm <> nil then
        lModelForm.ChangeReportTabs;
    end;
  end;
  UpdateForm;
end;

method CtrlFormReport.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  FirstEditSeparator.Visible := not fFormMode;
  FirstFileSeparator.Visible := not fFormMode;
  var lDocumentReady := (fFormatter <> nil) and (fDocument <> nil) and (PageCount > 0);
  var lFormAvailable := (fParamForm <> nil) or (fManagerForm <> nil);
  ItemToolStartPageEdit.Text := if lDocumentReady then Utils.IntToStr(StartPage + 1) else '';
  ItemToolPageCountLabel.Text := if lDocumentReady then '/ ' + Utils.IntToStr(PageCount) else '';
  AppUtils.Enable(lDocumentReady,
    ItemMenuCopy, ItemMenuCopyBitmap,
    ItemToolCopy, ItemPopCopy, ItemPopCopyBitmap,
    ItemMenuCropMetafile, ItemMenuCropBitmap,
    ItemPopCropMetafile, ItemPopCropBitmap,
    ItemMenuCopyImage, ItemPopCropImage,
    ItemToolSave, ItemMenuSave,
    ItemToolPrint, ItemToolPageSetup,
    ItemMenuPrint, ItemMenuPageSetup,
    ItemToolZoom, ItemMenuViewZoom, ItemPopActualSize, ItemPopFullPage, ItemPopPageWidth, ItemPopTwoPages,
    ItemToolFirst, ItemToolLast,
    ItemMenuBrowse,
    ItemToolStartPageEdit, ItemToolBrowse);
  AppUtils.Enable(lDocumentReady and lFormAvailable, ItemToolSettings, ItemMenuSettings, ItemPopSettings);
  AppUtils.Enable(lDocumentReady, lDocumentReady and (0 <= StartPage < PageCount), ItemToolCopy);
  AppUtils.Enable(lDocumentReady and (StartPage > 0), ItemToolPrev);
  AppUtils.Enable(lDocumentReady and (StartPage < (PageCount - 1)), ItemToolNext);
  AppUtils.UpdateModelForm(self);
  AppData.AppForm.UpdateForm;
end;

method CtrlFormReport.DoKeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
end;

method CtrlFormReport.CtrlFormReport_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  Update;
  if not Disposing and fInitialized and Visible then
    CommitFormatting;
end;

method CtrlFormReport.Viewer_StartPageChanged(sender: System.Object; e: System.EventArgs);
begin
  UpdateForm;
end;

method CtrlFormReport.ItemToolPrint_Click(sender: System.Object; e: System.EventArgs);
begin
  if fDocument = nil then
    exit;
  PrintDlg.Document := fDocument;
  var ps := PrintDlg.PrinterSettings;
  ps.MinimumPage := 1;
  ps.FromPage := 1;
  ps.MaximumPage := fFormatter.PageCount;
  ps.ToPage := fFormatter.PageCount;
  if PrintDlg.ShowDialog(self) = DialogResult.OK then
    fFormatter.Print(fDocument, StartPage, Viewer.ZoomMode = PreviewZoomMode.TwoPages);
end;

method CtrlFormReport.ItemToolPageSetup_Click(sender: System.Object; e: System.EventArgs);
begin
  PageSetupDlg.Document := fDocument;
  PageSetupDlg.PageSettings := fPageSettings;
  fDocument.DefaultPageSettings := fPageSettings;
  if PageSetupDlg.ShowDialog =  DialogResult.OK then
    begin
      fPageSettings := PageSetupDlg.PageSettings;
      ReformatReport;
    end;
end;

method CtrlFormReport.ItemToolFirst_Click(sender: System.Object; e: System.EventArgs);
begin
  StartPage := 0;
  Viewer.Home;
end;

method CtrlFormReport.ItemToolPrev_Click(sender: System.Object; e: System.EventArgs);
begin
  StartPage := StartPage - 1;
  Viewer.Home;
end;

method CtrlFormReport.ItemToolNext_Click(sender: System.Object; e: System.EventArgs);
begin
  StartPage := StartPage + 1;
  Viewer.Home;
end;

method CtrlFormReport.ItemToolLast_Click(sender: System.Object; e: System.EventArgs);
begin
  StartPage := PageCount - 1;
  Viewer.Home;
end;

method CtrlFormReport.ItemToolStartPageEdit_Enter(sender: System.Object; e: System.EventArgs);
begin
  ItemToolStartPageEdit.SelectAll;
end;

method CtrlFormReport.ItemToolStartPageEdit_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  var c := e.KeyChar;
  if c = #13 then
    begin
      ProcessTabKey(true);
      CommitPageNumber;
      e.Handled := true;
    end
  else
    if (c > #32) and not Char.IsDigit(c) then
      e.Handled := true;
end;

method CtrlFormReport.ItemToolStartPageEdit_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  CommitPageNumber;
end;

method CtrlFormReport.CommitPageNumber;
begin
  var page: Integer;
  if Integer.TryParse(ItemToolStartPageEdit.Text, out page) then
    StartPage := page - 1;
end;

method CtrlFormReport.CommitFormatting;
begin
  if Visible and fInitialized then
    if not AppData.ToDoQueue.Contains(self) then
      AppData.ToDoQueue.Enqueue(self);
end;

method CtrlFormReport.ItemToolStartPageEdit_Validated(sender: System.Object; e: System.EventArgs);
begin
  Viewer.Focus;
end;

method CtrlFormReport.ItemToolStartPageEdit_Leave(sender: System.Object; e: System.EventArgs);
begin
  Viewer.Focus;
end;

method CtrlFormReport.ItemToolZoom_ButtonClick(sender: System.Object; e: System.EventArgs);
begin
  Viewer.ZoomMode :=
    if Viewer.ZoomMode = PreviewZoomMode.ActualSize then PreviewZoomMode.FullPage
    else PreviewZoomMode.ActualSize;
end;

method CtrlFormReport.CtrlFormReport_Leave(sender: System.Object; e: System.EventArgs);
begin
  DoLeave;
end;

method CtrlFormReport.ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
begin
  if fFormatter = nil then
    exit;
  if SaveReportDialog.ShowDialog = DialogResult.OK then
    case SaveReportDialog.FilterIndex of
      1: // html
        fFormatter.SaveToHtml(SaveReportDialog.FileName, AppData.HtmlParams);
      0, 2: // text
        fFormatter.SaveToText(SaveReportDialog.FileName, AppData.TextPageDimensions);
      3: // bitmaps
        fFormatter.SaveToBitmaps(SaveReportDialog.FileName);
      4: // metafiles
        fFormatter.SaveToMetafiles(SaveReportDialog.FileName);
    end;
end;

method CtrlFormReport.ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Visible then
    exit;
  if fFormatter = nil then
    exit;
  if fFormatter.HasImage(StartPage) then
    using lMetafile := fFormatter.GetImageAsMetafile(StartPage) do
      ClipboardMetafileHelper.PutEnhMetafileOnClipboard(Handle, lMetafile);
end;

method CtrlFormReport.ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
begin
 if not Visible then
    exit;
  if fFormatter = nil then
    exit;
  if fFormatter.HasImage(StartPage) then
    using lBitmap := fFormatter.GetImageAsBitmap(StartPage) do
      Clipboard.SetImage(lBitmap);
end;

method CtrlFormReport.ItemToolZoom_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
begin
  if (e.ClickedItem = ItemToolZoomActualSize) or (e.ClickedItem = ItemMenuZoomActualSize) then
    Viewer.ZoomMode := PreviewZoomMode.ActualSize
  else if (e.ClickedItem = ItemToolZoomFullPage) or (e.ClickedItem = ItemMenuZoomFullPage) then
    Viewer.ZoomMode := PreviewZoomMode.FullPage
  else if (e.ClickedItem = ItemToolZoomPageWidth) or (e.ClickedItem = ItemMenuZoomPageWidth) then
    Viewer.ZoomMode := PreviewZoomMode.PageWidth
  else if (e.ClickedItem = ItemToolZoomTwoPages) or (e.ClickedItem = ItemMenuZoomTwoPages) then
    Viewer.ZoomMode := PreviewZoomMode.TwoPages
  else if (e.ClickedItem = ItemToolZoom10) or (e.ClickedItem = ItemMenuZoom10) then
    Viewer.Zoom := 0.1
  else if (e.ClickedItem = ItemToolZoom25) or (e.ClickedItem = ItemMenuZoom25) then
    Viewer.Zoom := 0.25
  else if (e.ClickedItem = ItemToolZoom50) or (e.ClickedItem = ItemMenuZoom50) then
    Viewer.Zoom := 0.5
  else if (e.ClickedItem = ItemToolZoom75) or (e.ClickedItem = ItemMenuZoom75) then
    Viewer.Zoom := 0.75
  else if (e.ClickedItem = ItemToolZoom100) or (e.ClickedItem = ItemMenuZoom100) then
    Viewer.Zoom := 1
  else if (e.ClickedItem = ItemToolZoom150) or (e.ClickedItem = ItemMenuZoom150) then
    Viewer.Zoom := 1.5
  else if (e.ClickedItem = ItemToolZoom200) or (e.ClickedItem = ItemMenuZoom200) then
    Viewer.Zoom := 2
  else if (e.ClickedItem = ItemToolZoom500) or (e.ClickedItem = ItemMenuZoom500) then
    Viewer.Zoom := 5;
end;

method CtrlFormReport.ItemPopActualSize_Click(sender: System.Object; e: System.EventArgs);
begin
  Viewer.ZoomMode := PreviewZoomMode.ActualSize;
end;

method CtrlFormReport.ItemPopFullPage_Click(sender: System.Object; e: System.EventArgs);
begin
  Viewer.ZoomMode := PreviewZoomMode.FullPage
end;

method CtrlFormReport.ItemPopPageWidth_Click(sender: System.Object; e: System.EventArgs);
begin
    Viewer.ZoomMode := PreviewZoomMode.PageWidth
end;

method CtrlFormReport.ItemPopTwoPages_Click(sender: System.Object; e: System.EventArgs);
begin
  Viewer.ZoomMode := PreviewZoomMode.TwoPages;
end;

method CtrlFormReport.ItemToolBrowse_Click(sender: System.Object; e: System.EventArgs);
begin
  BrowserManager.BrowseReport(Report, fParamForm, fManagerForm);
end;

method CtrlFormReport.ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
begin
  if fParamForm <> nil then
    begin
      if fParamForm.ShowDialog = DialogResult.OK then
        begin
          Report.Parameters := fParamForm.Parameters;
          Report.Format := fParamForm.Format;
          Report.Title := fParamForm.ReportTitle;
          fFormatter.DefaultFont := fParamForm.SelectedFont;
          ForceRemake;
          SaveState;
          UpdateForm;
        end;
    end;
  if fManagerForm <> nil then
    begin
      fManagerForm.SetForm(DexiReportGroup(Report));
      if fManagerForm.ShowDialog = DialogResult.OK then
        begin
          Report.Format := fManagerForm.Format;
          if not Model.ReportIsPrimary(Report) and (Report is DexiReportGroup) then
            begin
              Report.Title := fManagerForm.ReportTitle;
              var lTabPage := AppUtils.ReportTabPage(Model, DexiReportGroup(Report));
              if lTabPage <> nil then
                lTabPage.Text := Report.Title;
            end;
          ForceRemake;
          SaveState;
          UpdateForm;
        end;
    end;
end;

method CtrlFormReport.SaveState;
begin
  var lModelForm := AppUtils.ModelForm(Model);
  if lModelForm <> nil then
    lModelForm.SaveState;
end;

method CtrlFormReport.DataChanged;
begin
  DoEnter;
end;

method CtrlFormReport.ForceRemake;
begin
  fNeedRemake := true;
  RemakeReport;
  Viewer.RefreshPreview;
  if assigned(OnRemake) then
    OnRemake();
end;

method CtrlFormReport.SettingsChanged;
begin
  fReport.SettingsChanged;
  ForceRemake;
end;

method CtrlFormReport.ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
begin
  if fReport is DexiReportGroup then
    exit;
  if Model.RptCount <= 0 then
    exit;
  Model.Reports[0].AddReport(fReport.Copy);
  SaveState;
  UpdateForm;
end;

method CtrlFormReport.ItemMenuCropBitmap_Click(sender: System.Object; e: System.EventArgs);
begin
 if not Visible then
    exit;
  if fFormatter = nil then
    exit;
  if fFormatter.HasImage(StartPage) then
    using lBitmap := fFormatter.GetImageAsBitmap(StartPage) do
      begin
        var lCrop := GraphicsUtils.CroppedRectangle(lBitmap);
        lCrop.Inflate(2, 2);
        using lCroppedBitmap := GraphicsUtils.CropBitmapToRect(lBitmap, lCrop) do
          Clipboard.SetImage(lCroppedBitmap);
      end;
end;

method CtrlFormReport.ItemMenuCropMetafile_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Visible then
    exit;
  if fFormatter = nil then
    exit;
  if fFormatter.HasImage(StartPage) then
    using lMetafile := fFormatter.GetImageAsMetafile(StartPage) do
      begin
        var lFullRect := new Rectangle(0, 0, lMetafile.Width, lMetafile.Height);
        var lCrop := Rectangle.Empty;
        using lFullBitmap := new Bitmap(lFullRect.Width, lFullRect.Height) do
          begin
            using g := Graphics.FromImage(lFullBitmap) do
              g.DrawImage(lMetafile, 0, 0);
            lCrop := GraphicsUtils.CroppedRectangle(lFullBitmap);
          end;
        lCrop.Inflate(2, 2);
        using lCroppedMetafile := GraphicsUtils.CropMetafileToRect(lMetafile, lCrop) do
          ClipboardMetafileHelper.PutEnhMetafileOnClipboard(Handle, lCroppedMetafile);
      end;
end;

method CtrlFormReport.FormMenu_ItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
begin

end;



end.