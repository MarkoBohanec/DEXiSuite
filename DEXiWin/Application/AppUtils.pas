// AppUtils.pas is part of
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
// AppUtils.pas implements utilities and GUI-related classess to be used in
//   DEXiWin forms and user controls.
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
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  DexiModelExtend = public extension class (DexiModel)
  public
    property AppModSettings: AppModelSettings read AppXmlHandler(XmlHandler):AppModSettings;
  end;

type
  AppUtils = public static class
  private
    class const ExtVals = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  protected
    method SetControlFont(aFont: Font; aControls: Control.ControlCollection);
    method SetAppFont(aFont: Font);
  public
    method Enable(params aObjects: array of Object);
    method Disable(params aObjects: array of Object);
    method Enable(aEnabled: Boolean; params aObjects: array of Object);
    method Show(params aObjects: array of Object);
    method Hide(params aObjects: array of Object);
    method Show(aVisible: Boolean; params aObjects: array of Object);
    method DisposeObjects(params aObjects: array of Object);
    method DisposeObjects(aObjects: sequence of Object);
    method ObjNames(aObjs: sequence of Object): String;
    method ObjNames(aObjs: IList): String;
    method ObjNames(aObjs: IEnumerable): String;
    method ModelForm(aControl: Control): FormModel;
    method ModelForm(aModel: DexiModel): FormModel;
    method UpdateModelForm(aControl: Control);
    method UpdateModelForm(aModel: DexiModel);
    method ReportTabPage(aModel: DexiModel; aReport: DexiReportGroup): TabPage;
    method EditedFloatValue(aStr: String; aAllowUndefined: Boolean := true): DexiValue;
    method EditedFloatNumber(aStr: String): nullable Float;
    method ExtToIntVal(aExtCh: Char): Integer;
    method IntToExtVal(aIntVal: Integer): String;
    method SetAppFontZoom(aZoom: Float);
  end;

type
  TreeListViewExtend = public extension class (TreeListView)
  public
    method DisplayedLevels: Integer;
    method CheckExpandable(aModel: Object): Boolean;
    method CanExpandFurther: Boolean;
    method CanCollapseFurther: Boolean;
    method CollapseOne;
    method ExpandOne;
    method TotalWidth: Integer;
    method RefreshAllObjects;
  end;

type
  RichTextBoxExtend = public extension class (RichTextBox)
  public
    method AppendText(aText: String; aFont: Font; aForeColor: Color; aBackColor: Color);
    method RenderComposite(aComposite: CompositeString; aBackColor: Color);
    method SetScaleText(aScale: DexiScale; aBackColor: Color; aWithName: Boolean := false);
    method SetValueOnScaleText(aValue: DexiValue; aScale: DexiScale; aBackColor: Color);
  end;

type
  CompositeStringRenderer = public abstract class (BaseRenderer)
  private
    fSettings: DexiSettings;
    const NormalTextFormatFlags: TextFormatFlags =
      TextFormatFlags.NoPrefix or TextFormatFlags.NoPadding or TextFormatFlags.EndEllipsis or TextFormatFlags.PreserveGraphicsTranslateTransform;
  protected
    fDexiScaleStrings := new DexiScaleStrings;
    property RowComposite: CompositeString;
    method SetSettings(aSettings: DexiSettings);
    method CalculateContentSize(g: Graphics; r: Rectangle): Size; override;
    method CalculateTextSize(g: Graphics; txt: String; f: Font; aWidth: Integer): Size;
  public
    property Settings: DexiSettings read fSettings write SetSettings;
    property ScaleStrings: DexiScaleStrings read fDexiScaleStrings;
    method Render(g: Graphics; r: Rectangle); override;
    method CompositeRender(g: Graphics; r: Rectangle); virtual;
    method DrawCompositeGdi(g: Graphics; r: Rectangle); virtual;
    method DrawCompositeGdiPlus(g: Graphics; r: Rectangle); virtual;
    method DrawTextGdi(g: Graphics; r: Rectangle; txt: String; f: Font; c: Color): Size; virtual;
    method DrawTextGdiPlus(g: Graphics; r: Rectangle; txt: String; f: Font; c: Color): Size; virtual;
  end;

type
  CompositeModelScaleRenderer = public class (CompositeStringRenderer)
  public
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  CompositeModelFunctRenderer = public class (CompositeStringRenderer)
  public
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  CompositeModelArgRenderer = public class (CompositeStringRenderer)
  private
    fScale: DexiDiscreteScale;
    fArg: Integer;
  public
    constructor (aScale: DexiDiscreteScale; aArg: Integer);
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  CompositeModelValueRenderer = public class (CompositeStringRenderer)
  private
    fScale: DexiScale;
  public
    constructor (aScale: DexiScale);
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  CompositeModelBoundRenderer = public class (CompositeStringRenderer)
  private
    fScale: DexiScale;
    fAssoc: DexiBoundAssociation;
  public
    constructor (aScale: DexiScale; aAssoc: DexiBoundAssociation);
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  CompositeAlternativeValueRenderer = public class (CompositeStringRenderer)
  private
    fAlternative: Integer;
  public
    constructor (aAlternative: Integer);
    method ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object); override;
  end;

type
  SearchParameters = public record
  public
    SearchString: String;
    SearchStringUpper: String;
    SearchName: Boolean;
    SearchDescr: Boolean;
    SearchScale: Boolean;
    MatchCase: Boolean;
  end;

type
  DexiRuleObject = public class
  private
    fNumber: Integer;
    fRule: DexiRule;
    fConsistent: Boolean;
  public
    constructor (aNumber: Integer; aRule: DexiRule);
    property Number: Integer read fNumber;
    property &Index: Integer read fNumber - 1;
    property Arg[aIdx: Integer]: Integer read fRule.Arg[aIdx];
    property Value: DexiValue read fRule:Value;
    property Entered: Boolean read fRule.Entered;
    property Consistent: Boolean read fConsistent;
    method SetConsistency(aFunct: DexiTabularFunction);
  end;

type DexiIntervalObject = public class
  private
    fNumber: Integer;
    fValueCell: DexiValueCell;
    fLowBound: DexiBound;
    fHighBound: DexiBound;
    fConsistent: Boolean;
  protected
    method GetLowAssoc: String;
    method GetHighAssoc: String;
  public
    constructor (aNumber: Integer; aValueCell: DexiValueCell; aLowBound, aHighBound: DexiBound);
    property Number: Integer read fNumber;
    property &Index: Integer read fNumber - 1;
    property ValueCell: DexiValueCell read fValueCell;
    property Value: DexiValue read fValueCell:Value;
    property Entered: Boolean read fValueCell:Entered;
    property LowBound: DexiBound read fLowBound;
    property HighBound: DexiBound read fHighBound;
    property LowAssoc: String read GetLowAssoc;
    property HighAssoc: String read GetHighAssoc;
    property Consistent: Boolean read fConsistent;
    method Update(aFunct: DexiDiscretizeFunction);
    method SetConsistency(aFunct: DexiDiscretizeFunction);
  end;

type
  ArgClusteringStrategy = public class (ClusteringStrategy)
    private
      fScale: DexiDiscreteScale;
    public
      constructor (aScale: DexiDiscreteScale);
      method GetClusterDisplayLabel(cluster: ICluster): String; override;
  end;

type
  AlternativesVisibility = public class (IUndoable)
  private
    fAlternativeVisibility: SetOfInt;
    fEvaluationVisibility: SetOfInt;
  public
    constructor (aAltCount: Integer);
    constructor (aVisibility: AlternativesVisibility);
    method Assign(aVisibility: AlternativesVisibility);
    method AddAlternative(aAlt: Integer);
    method AddAlternatives(aAlts: SetOfInt);
    method DeleteAlternative(aAlt: Integer);
    method MoveAlternativePrev(aAlt: Integer);
    method MoveAlternativeNext(aAlt: Integer);
    property AlternativeVisibility: SetOfInt read fAlternativeVisibility;
    property EvaluationVisibility: SetOfInt read fEvaluationVisibility;

    // IUnodable
    method CollectUndoableObjects(aList: List<IUndoable>);
    method EqualStateAs(aObj: IUndoable): Boolean;
    method GetUndoState: IUndoable;
    method SetUndoState(aState: IUndoable);
  end;

type
  CellEditMode = public enum (None, Discrete, Continuous, Edit);

type
  ValueEditingParameters = public class
  public
    constructor(aAttribute: DexiAttribute; aAlternative: Integer);
    property Attribute: DexiAttribute;
    property Alternative: Integer;
    property EditMode: CellEditMode;
    property EditedValue: DexiValue;
  end;

type
  DexiHtmlParameters = public class (RptHtmlParameters)
  protected
  public
    class method NewParameters: DexiHtmlParameters;
    constructor;
    constructor (aModel: DexiModel);
    method TagMapper(aTag: Integer): String; override;
    method TextStyle(aColor, aStyle: String): String;
    method Style: String; override;
    method Head: String; override;
    property FontName := 'Arial';
    property FontSize := 10.0;
    property BadColor := "#FF0000";
    property GoodColor := "#008000";
    property BadStyle := "B";
    property GoodStyle := "BI";
  end;

type
  DexiFormatMaker = static public class
  public
    method FontMaker(aTag: Integer; aBaseFont: Font): Font;
    method BrushMaker(aTag: Integer): Brush;
  end;

type
  ReportManager = static public class
  public
    method ReportFont(aFormat: DexiReportFormat): Font;
    method OpenReportViewer(aReport: DexiReport; aParamForm: FormReportParameters);
    method OpenReport(aReport: DexiReport);
    method OpenReportDialog(aReport: DexiReport);
    method OpenFunctionReport(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiFunction := nil);
    method OpenComparisonReport(aModel: DexiModel; aAlternative: Integer);
    method OpenSelectiveExplanationReport(aModel: DexiModel);
    method OpenPlusMinusReport(aModel: DexiModel; aAttribute: DexiAttribute; aAlternative: Integer);
    method OpenTargetReport(aModel: DexiModel; aAttribute: DexiAttribute; aAlternative: Integer);
    method OpenEvaluateQQReport(aModel: DexiModel);
  end;

type
  BrowserManager = static public class
  private
    fTemporaryFiles := new List<String>;
  protected
    method GetTemporaryFileName(aExt: String): String;
  public
    method BrowseReport(aReport: DexiReport; aParamForm: FormReportParameters; aManagerForm: FormReportManager);
    method OpenInBrowser(aHtml: String);
    method DeleteTemporaryFiles;
  end;

type
  ITabReportCtrlForm = public interface
    method Init;
    method DataChanged;
    method SettingsChanged;
    property Report: DexiReport;
    property ParamForm: FormReportParameters;
    property ManagerForm: FormReportManager;
  end;

type
  ModelUndoRedo = public class (UndoRedo<UndoState>, IUndoRedo<UndoState>)
    private
      fModelForm: weak FormModel;
    protected
      method GetPreviousState: UndoState;
    public
      method GetObjectState: UndoState; override;
      method SetObjectState(aState: UndoState); override;
      constructor (aModelForm: FormModel);
      property ModelForm: FormModel read fModelForm write fModelForm;
      property Model: DexiModel read fModelForm:Model;
      property PreviousState: UndoState read GetPreviousState;
  end;

implementation

{$REGION AppUtils}

method AppUtils.Enable(params aObjects: array of Object);
begin
  Enable(true, aObjects);
end;

method AppUtils.Disable(params aObjects: array of Object);
begin
  Enable(false, aObjects);
end;

method AppUtils.Enable(aEnabled: Boolean; params aObjects: array of Object);
begin
  for each lObject in aObjects do
    if lObject <> nil then
      if lObject is Control then
        Control(lObject).Enabled := aEnabled
      else if lObject is ToolStripItem then
        ToolStripItem(lObject).Enabled := aEnabled;
end;

method AppUtils.Show(params aObjects: array of Object);
begin
  Show(true, aObjects);
end;

method AppUtils.Hide(params aObjects: array of Object);
begin
  Show(false, aObjects);
end;

method AppUtils.Show(aVisible: Boolean; params aObjects: array of Object);
begin
  for each lObject in aObjects do
    if lObject <> nil then
      if lObject is Control then
        Control(lObject).Visible := aVisible
      else if lObject is ToolStripItem then
        ToolStripItem(lObject).Visible := aVisible
      else if lObject is OLVColumn then
        OLVColumn(lObject).IsVisible := aVisible;
end;

method AppUtils.DisposeObjects(params aObjects: array of Object);
begin
  for each lObject in aObjects do
    if lObject <> nil then
      if lObject is IDisposable then
        IDisposable(lObject).Dispose;
end;

method AppUtils.DisposeObjects(aObjects: sequence of Object);
begin
  for each lObject in aObjects do
    if lObject <> nil then
      if lObject is IDisposable then
        IDisposable(lObject).Dispose;
end;

method AppUtils.ObjNames(aObjs: sequence of Object): String;
begin
  result := '';
  for each lObj in aObjs do
  if lObj is DexiAttribute then
    result := result + DexiAttribute(lObj).Name + ' ';
end;

method AppUtils.ObjNames(aObjs: IList): String;
begin
  result := '';
  for each lObj in aObjs do
  if lObj is DexiAttribute then
    result := result + DexiAttribute(lObj).Name + ' ';
end;

method AppUtils.ObjNames(aObjs: IEnumerable): String;
begin
  result := '';
  for each lObj in aObjs do
  if lObj is DexiAttribute then
    result := result + DexiAttribute(lObj).Name + ' ';
end;

method AppUtils.ModelForm(aControl: Control): FormModel;
begin
  var lCtrl := aControl:Parent;
  while (lCtrl <> nil) and not (lCtrl is FormModel) do
    lCtrl := lCtrl.Parent;
  result := FormModel(lCtrl);
end;

method AppUtils.ModelForm(aModel: DexiModel): FormModel;
begin
  var lContext := AppData.ModelContext[aModel];
  result :=
    if lContext = nil then nil
    else lContext.ModelForm;
end;

method AppUtils.UpdateModelForm(aControl: Control);
begin
  var lForm := ModelForm(aControl);
  if lForm <> nil then
    lForm.UpdateForm;
end;

method AppUtils.UpdateModelForm(aModel: DexiModel);
begin
  var lForm := ModelForm(aModel);
  if lForm <> nil then
    lForm.UpdateForm;
end;

method AppUtils.ReportTabPage(aModel: DexiModel; aReport: DexiReportGroup): TabPage;
begin
  result := nil;
  var lModelForm := ModelForm(aModel);
  if lModelForm = nil then
    exit;
  for each lTab in lModelForm.TabPages do
    if (lTab:Controls <> nil) and (lTab.Controls.Count > 0) and (lTab.Controls[0] is ITabReportCtrlForm) then
    begin
      var lRptCtrl := ITabReportCtrlForm(lTab.Controls[0]);
      if lRptCtrl.Report = aReport then
        exit lTab;
    end;
end;

method AppUtils.EditedFloatValue(aStr: String; aAllowUndefined: Boolean := true): DexiValue;
begin
  result := nil;
  if String.IsNullOrWhiteSpace(aStr) then
    if aAllowUndefined then
      exit new DexiUndefinedValue
    else
      exit;
  aStr := aStr.Trim.ToUpper.Replace(',', '.');
  if aAllowUndefined then
    if (aStr = DexiString.SDexiUndefinedValue.ToUpper) or (aStr = DexiString.SDexiUndefined.ToUpper) or aStr.Contains('?') or aStr.Contains('U') then
      exit new DexiUndefinedValue;
  var lValue : nullable Float := nil;
  try
    lValue := Utils.StrToFlt(aStr, true);
  except
  end;
  if assigned(lValue) and not Consts.IsInfinity(lValue) and not Consts.IsNaN(lValue) then
    result := new DexiFltSingle(lValue);
end;

method AppUtils.EditedFloatNumber(aStr: String): nullable Float;
begin
  result := nil;
  aStr := aStr.Trim.ToUpper.Replace(',', '.');
  if String.IsNullOrWhiteSpace(aStr) then
    exit;
  try
    result := Utils.StrToFlt(aStr, true);
  except
  end;
end;

method AppUtils.ExtToIntVal(aExtCh: Char): Integer;
begin
  result := Utils.Pos0(aExtCh, ExtVals);
end;

method AppUtils.IntToExtVal(aIntVal: Integer): String;
begin
  result :=
    if 0 <= aIntVal <= high(ExtVals) then ExtVals[aIntVal]
    else nil;
end;

method AppUtils.SetControlFont(aFont: Font; aControls: Control.ControlCollection);
begin
  for each lCtrl in aControls do
    if lCtrl is Control then
      with lControl := Control(lCtrl) do
        begin
          lControl.Font := aFont;
          SetControlFont(aFont, lControl.Controls);
        end;
end;

method AppUtils.SetAppFont(aFont: Font);
begin
  SetControlFont(aFont, AppData.AppForm.Controls);
end;

method AppUtils.SetAppFontZoom(aZoom: Float);
begin
  var lPrevious := AppData.CurrentAppFont;
  AppData.CurrentAppFont := new Font(lPrevious.FontFamily, aZoom * AppData.DefaultAppFont.Size);
  AppData.AppForm.Font := AppData.CurrentAppFont;
  AppData.MakeFonts(aZoom);
  lPrevious.Dispose;
end;

{$ENDREGION}

{$REGION TreeListViewExtend}

method TreeListViewExtend.DisplayedLevels: Integer;
begin
  result := 0;
  for each lModel in ExpandedObjects do
    begin
      var lBranch := TreeModel.GetBranch(lModel);
      if lBranch <> nil then
        result := Math.Max(result, lBranch.Level);
    end;
end;

method TreeListViewExtend.CheckExpandable(aModel: Object): Boolean;
begin
  var lBranch := TreeModel.GetBranch(aModel);
  result := (lBranch <> nil) and not lBranch.IsExpanded and lBranch.CanExpand;
end;

method TreeListViewExtend.CanExpandFurther: Boolean;
begin
  result := false;
  for each lModel in ExpandedObjects do
    begin
      var lBranch := TreeModel.GetBranch(lModel);
      for each lChild in lBranch.Children do
        if CheckExpandable(lChild) then
          exit true;
    end;
  for each lModel in Objects do
    if CheckExpandable(lModel) then
      exit true;
end;

method TreeListViewExtend.CanCollapseFurther: Boolean;
begin
  result := false;
  for each lModel in ExpandedObjects do
    begin
      var lBranch := TreeModel.GetBranch(lModel);
      if (lBranch <> nil) and lBranch.IsExpanded then
        exit true;
    end;
end;

method TreeListViewExtend.CollapseOne;
begin
  var lLevels := DisplayedLevels;
  var lList := new List<Object>;
  for each lModel in ExpandedObjects do
    begin
      var lBranch := TreeModel.GetBranch(lModel);
      if (lBranch <> nil) and lBranch.IsExpanded and (lBranch.Level >= lLevels) then
        lList.Add(lModel);
    end;
  for each lModel in lList do
    self.Collapse(lModel);
end;

method TreeListViewExtend.ExpandOne;
begin
  var lLevels := DisplayedLevels;
  var lList := new List<Object>;
  for each lModel in ExpandedObjects do
    begin
      var lBranch := TreeModel.GetBranch(lModel);
      if lBranch <> nil then
        if lBranch.Level <= lLevels then
          begin
            if CheckExpandable(lModel) then
              lList.Add(lModel);
            for each lChild in lBranch.Children do
              if CheckExpandable(lChild) then
                lList.Add(lChild);
          end;
      end;
  if lLevels = 0 then
    for each lModel in Objects do
      if CheckExpandable(lModel) then
        lList.Add(lModel);
  for each lModel in lList do
    self.Expand(lModel);
end;

method TreeListViewExtend.TotalWidth: Integer;
begin
  result := 0;
  for each lColumn: OLVColumn in Columns do
    if lColumn.IsVisible then
      result := result + lColumn.Width;
end;

method TreeListViewExtend.RefreshAllObjects;
begin
  self.RedrawItems(0, GetItemCount - 1, true);
end;

{$ENDREGION}

{$REGION RichTextBoxExtend }

method RichTextBoxExtend.AppendText(aText: String; aFont: Font; aForeColor: Color; aBackColor: Color);
begin
  var lStart := TextLength;
  AppendText(aText);
  var lEnd := TextLength;
  Select(lStart, lEnd - lStart);
  SelectionColor := aForeColor;
  SelectionFont := aFont;
  SelectionBackColor := aBackColor;
  Select(lEnd, 0);
  ScrollToCaret;
end;

method RichTextBoxExtend.RenderComposite(aComposite: CompositeString; aBackColor: Color);
begin
  for each lItem in aComposite.Elements do
    begin
      var lText := lItem.Str;
      case lItem.Tag of
        DexiScale.BadInfo,
        DexiScale.BadCategory:  AppendText(lText, AppData.BadFont, AppData.BadColor, aBackColor);
        DexiScale.GoodCategory: AppendText(lText, AppData.GoodFont, AppData.GoodColor, aBackColor);
        DexiScale.GoodInfo:     AppendText(lText, AppData.GoodInfoFont, AppData.GoodColor, aBackColor);
        else                    AppendText(lText, AppData.RegularFont, AppData.RegularColor, aBackColor);
      end;
    end;
end;

method RichTextBoxExtend.SetScaleText(aScale: DexiScale; aBackColor: Color; aWithName: Boolean := false);
begin
  Clear;
  Text := '';
  var lStrings := new DexiScaleStrings;
  var lComposite := lStrings.ScaleComposite(aScale, aWithName);
  RenderComposite(lComposite, aBackColor);
end;

method RichTextBoxExtend.SetValueOnScaleText(aValue: DexiValue; aScale: DexiScale; aBackColor: Color);
begin
  Clear;
  Text := '';
  var lStrings := new DexiScaleStrings;
  var lComposite := lStrings.ValueOnScaleComposite(aValue, aScale);
  RenderComposite(lComposite, aBackColor);
end;

{$ENDREGION}

{$REGION CompositeStringRenderer}

method CompositeStringRenderer.SetSettings(aSettings: DexiSettings);
begin
  fSettings := aSettings;
  if fSettings = nil then
    fDexiScaleStrings.ResetDecimals
  else
    begin
      fDexiScaleStrings.MemDecimals := fSettings.MemDecimals;
    end;
end;

method CompositeStringRenderer.CalculateContentSize(g: Graphics; r: Rectangle): Size;
begin
  if RowComposite = nil then
    exit inherited CalculateContentSize(g, r);
  result := new Size(0, high(Integer));
  for each lItem in RowComposite.Elements do
    begin
      var lSize := CalculateTextSize(g, lItem.Str, AppData.ResourceFont(lItem.Tag), high(Integer));
      result.Width := result.Width + lSize.Width;
      result.Height := Math.Max(result.Height, lSize.Height);
    end;
end;

method CompositeStringRenderer.CalculateTextSize(g: Graphics; txt: String; f: Font; aWidth: Integer): Size;
begin
  UseGdiTextRendering := false;
  if String.IsNullOrEmpty(txt) then
    exit Size.Empty;
  if not String.IsNullOrEmpty(txt) and (txt.Trim = '') then
    txt := txt.Replace(' ', '-');
  if UseGdiTextRendering then
    begin
      var proposedSize := new Size(aWidth, high(Integer));
      result := TextRenderer.MeasureText(g, txt, f, proposedSize, NormalTextFormatFlags);
    end
  else
    using fmt := StringFormat.GenericTypographic do
      begin
        var lSizeF := g.MeasureString(txt, f, new SizeF(aWidth, high(Integer)), fmt);
        result := new Size(Utils.RoundUp(lSizeF.Width), Utils.RoundUp(lSizeF.Height));
      end;
end;

method CompositeStringRenderer.Render(g: Graphics; r: Rectangle);
begin
  UseGdiTextRendering := false;
  if RowComposite = nil then
    exit;
  CompositeRender(g, r);
end;

method CompositeStringRenderer.CompositeRender(g: Graphics; r: Rectangle);
begin
  DrawBackground(g, r);
  r := ApplyCellPadding(r);
  if UseGdiTextRendering then
    DrawCompositeGdi(g, r)
  else
    DrawCompositeGdiPlus(g, r);
  if ObjectListView.ShowCellPaddingBounds then
    g.DrawRectangle(Pens.Purple, r);
end;

method CompositeStringRenderer.DrawCompositeGdi(g: Graphics; r: Rectangle);
begin
  var q := r;
  for each lItem in RowComposite.Elements do
    begin
      if q.Width <= 0 then
        exit;
      var lSize := DrawTextGdi(g, q, lItem.Str, AppData.ResourceFont(lItem.Tag), AppData.ResourceColor(lItem.Tag));
      q.X := q.X + lSize.Width;
      q.Width := q.Width - lSize.Width;
    end;
end;

method CompositeStringRenderer.DrawCompositeGdiPlus(g: Graphics; r: Rectangle);
begin
  var q := r;
  for each lItem in RowComposite.Elements do
    begin
      if q.Width <= 0 then
        exit;
      var lSize := DrawTextGdiPlus(g, q, lItem.Str, AppData.ResourceFont(lItem.Tag), AppData.ResourceColor(lItem.Tag));
      q.X := q.X + lSize.Width;
      q.Width := q.Width - lSize.Width;
    end;
end;

method CompositeStringRenderer.DrawTextGdi(g: Graphics; r: Rectangle; txt: String; f: Font; c: Color): Size;
begin
    var backColor := Color.Transparent;
    var lFlags := NormalTextFormatFlags or CellVerticalAlignmentAsTextFormatFlag;
    if not CanWrap then
      lFlags := lFlags or TextFormatFlags.SingleLine;
    TextRenderer.DrawText(g, txt, f, r, c, backColor, lFlags);
    result := CalculateTextSize(g, txt, f, r.Width);
end;

method CompositeStringRenderer.DrawTextGdiPlus(g: Graphics; r: Rectangle; txt: String; f: Font; c: Color): Size;
begin
  using fmt := StringFormat.GenericTypographic do
    using brsh := new SolidBrush(c)  do
      begin
        fmt.LineAlignment := StringAlignment.Center;
        var rf: RectangleF := r;
        g.DrawString(txt, f, brsh, rf, fmt);
        result := CalculateTextSize(g, txt, f, r.Width);
      end;
end;

{$ENDREGION}

{$REGION CompositeModelScaleRenderer}

method CompositeModelScaleRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  var lScl :=
    if model is DexiScale then DexiScale(model)
    else if model is DexiAttribute then DexiScale(DexiAttribute(model):Scale)
    else nil;
  RowComposite := fDexiScaleStrings.ScaleComposite(lScl);
end;

{$ENDREGION}

{$REGION CompositeModelFunctRenderer}

method CompositeModelFunctRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  var lFnc :=  DexiFunction(DexiAttribute(model):Funct);
  var lStr := new CompositeString;
  lStr.Add(lFnc:FunctString);
  RowComposite := lStr;
end;

{$ENDREGION}

{$REGION CompositeModelArgRenderer}

constructor CompositeModelArgRenderer(aScale: DexiDiscreteScale; aArg: Integer);
begin
  inherited constructor;
  fScale := aScale;
  fArg := aArg;
end;

method CompositeModelArgRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  var lRule :=  DexiRuleObject(model);
  RowComposite := fDexiScaleStrings.ValueOnScaleComposite(lRule.Arg[fArg], fScale);
end;

{$ENDREGION}

{$REGION CompositeModelValueRenderer}

constructor CompositeModelValueRenderer(aScale: DexiScale);
begin
  inherited constructor;
  fScale := aScale;
end;

method CompositeModelValueRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  var lValue: DexiValue :=
    if model is DexiRuleObject then DexiRuleObject(model).Value
    else if model is DexiIntervalObject then DexiIntervalObject(model).Value
    else nil;
  RowComposite :=
    if lValue <> nil then fDexiScaleStrings.ValueOnScaleComposite(lValue, fScale)
    else CompositeString.Empty;
end;

{$ENDREGION}

{$REGION CompositeModelBoundRenderer}

constructor CompositeModelBoundRenderer(aScale: DexiScale; aAssoc: DexiBoundAssociation);
begin
  inherited constructor;
  fScale := aScale;
  fAssoc := aAssoc;
end;

method CompositeModelBoundRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  RowComposite := nil;
  if model is DexiIntervalObject then
    begin
      var lInterval := DexiIntervalObject(model);
      var lBound := if fAssoc = DexiBoundAssociation.Down then lInterval.LowBound.Bound else lInterval.HighBound.Bound;
      RowComposite := fDexiScaleStrings.ValueOnScaleComposite(lBound, fScale);
    end;
end;

{$ENDREGION}

{$REGION CompositeAlternativeValueRenderer}

constructor CompositeAlternativeValueRenderer(aAlternative: Integer);
begin
  inherited constructor;
  fAlternative := aAlternative;
end;

method CompositeAlternativeValueRenderer.ConfigureSubItem(e: DrawListViewSubItemEventArgs; cellBounds: Rectangle; model: Object);
begin
  inherited ConfigureSubItem(e, cellBounds, model);
  RowComposite := nil;
  if model is DexiAttribute then
    begin
      var lAtt := DexiAttribute(model);
      var lScale := lAtt.Scale;
      var lValue := lAtt.AltValue[fAlternative];
      RowComposite := fDexiScaleStrings.ValueOnScaleComposite(lValue, lScale);
    end;
end;

{$ENDREGION}

{$REGION DexiRuleObject}

constructor DexiRuleObject(aNumber: Integer; aRule: DexiRule);
begin
  inherited constructor;
  fNumber := aNumber;
  fRule := aRule;
  fConsistent := false;
end;

method DexiRuleObject.SetConsistency(aFunct: DexiTabularFunction);
begin
  fConsistent :=
    if aFunct.UseConsist then aFunct.RuleIsConsistent(self.Index)
    else true;
end;

{$ENDREGION}

{$REGION DexiIntervalObject}

constructor DexiIntervalObject(aNumber: Integer; aValueCell: DexiValueCell; aLowBound, aHighBound: DexiBound);
begin
  inherited constructor;
  fNumber := aNumber;
  fValueCell := aValueCell;
  fLowBound := aLowBound;
  fHighBound := aHighBound;
end;

method DexiIntervalObject.GetLowAssoc: String;
begin
  result :=
    if fLowBound = nil then ''
    else if fLowBound.Association = DexiBoundAssociation.Up then '['
    else '(';
end;

method DexiIntervalObject.GetHighAssoc: String;
begin
  result :=
    if fHighBound = nil then ''
    else if fHighBound.Association = DexiBoundAssociation.Down then ']'
    else ')';
end;

method DexiIntervalObject.Update(aFunct: DexiDiscretizeFunction);
begin
  fValueCell := aFunct.ValueCell[self.Index];
  fLowBound := aFunct.IntervalLowBound[self.Index];
  fHighBound := aFunct.IntervalHighBound[self.Index];
  SetConsistency(aFunct);
end;

method DexiIntervalObject.SetConsistency(aFunct: DexiDiscretizeFunction);
begin
  fConsistent :=
    if aFunct.UseConsist then aFunct.IntervalIsConsistent(self.Index)
    else true;
end;

{$ENDREGION}

{$REGION ArgClusteringStrategy}

constructor ArgClusteringStrategy(aScale: DexiDiscreteScale);
begin
  inherited constructor;
  fScale := aScale;
end;

method ArgClusteringStrategy.GetClusterDisplayLabel(cluster: ICluster): String;
begin
  var lVal :=Integer(cluster.ClusterKey);
  result :=
    if fScale.InBounds(lVal) then fScale.Names[lVal]
    else DexiString.SDexiUndefined;
end;

{$ENDREGION}

{$REGION AlternativesVisibility}

constructor AlternativesVisibility(aAltCount: Integer);
begin
  inherited constructor;
  fAlternativeVisibility := new SetOfInt(0, aAltCount - 1);
  fEvaluationVisibility := new SetOfInt(0, aAltCount - 1);
end;

constructor AlternativesVisibility(aVisibility: AlternativesVisibility);
begin
  inherited constructor;
  Assign(aVisibility);
end;

method AlternativesVisibility.Assign(aVisibility: AlternativesVisibility);
begin
  fAlternativeVisibility := SetOfInt.CopySet(aVisibility.fAlternativeVisibility);
  fEvaluationVisibility := SetOfInt.CopySet(aVisibility.fEvaluationVisibility);
end;

method AlternativesVisibility.AddAlternative(aAlt: Integer);
begin
  fAlternativeVisibility.IncludeIndex(aAlt);
  fEvaluationVisibility.IncludeIndex(aAlt);
end;

method AlternativesVisibility.AddAlternatives(aAlts: SetOfInt);
begin
  fAlternativeVisibility.Include(aAlts);
  fEvaluationVisibility.Include(aAlts);
end;

method AlternativesVisibility.DeleteAlternative(aAlt: Integer);
begin
  fAlternativeVisibility.ExcludeIndex(aAlt);
  fEvaluationVisibility.ExcludeIndex(aAlt);
end;

method AlternativesVisibility.MoveAlternativePrev(aAlt: Integer);
begin
  fAlternativeVisibility.Exchange(aAlt - 1, aAlt);
  fEvaluationVisibility.Exchange(aAlt - 1, aAlt);
end;

method AlternativesVisibility.MoveAlternativeNext(aAlt: Integer);
begin
  fAlternativeVisibility.Exchange(aAlt + 1, aAlt);
  fEvaluationVisibility.Exchange(aAlt + 1, aAlt);
end;

method AlternativesVisibility.CollectUndoableObjects(aList: List<IUndoable>);
begin
  // none
end;

method AlternativesVisibility.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not AlternativesVisibility then
    exit false;
  var lVisibility := AlternativesVisibility(aObj);
  result :=
    SetOfInt.EqualSets(fAlternativeVisibility, lVisibility.fAlternativeVisibility) and
    SetOfInt.EqualSets(fEvaluationVisibility, lVisibility.fEvaluationVisibility);
end;

method AlternativesVisibility.GetUndoState: IUndoable;
begin
  result := new AlternativesVisibility(self);
end;

method AlternativesVisibility.SetUndoState(aState: IUndoable);
begin
  var lVisibility := aState as AlternativesVisibility;
  Assign(lVisibility);
end;

{$ENDREGION}

{$REGION ValueEditingParameters}

constructor ValueEditingParameters(aAttribute: DexiAttribute; aAlternative: Integer);
begin
  Attribute := aAttribute;
  Alternative := aAlternative;
  EditMode := CellEditMode.None;
  EditedValue := nil;
end;

{$ENDREGION}

{$REGION DexiHtmlParameters}

constructor DexiHtmlParameters;
begin
  inherited constructor;
  HtmlTitle := 'DEXi Report';

  HtmlHead :=
"<!DOCTYPE html>
<html>
<head>
<title>{0}</title>
<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8""/>
<meta http-equiv=""X-UA-Compatible"" content=""IE=edge""/>
<style type=""text/css"">
{1}
</style>
</head>
<body>
";

  HtmlStyle :=
"body {{
    font-family: ""{0}"", ""Arial"", ""Verdana"", ""Helvetica"", sans-serif;
    font-size: {1}pt;}}
td {{padding-right: 6px;}}
table {{border-collapse: collapse;}}
.section {{page-break-before: auto; page-break-inside: avoid;}}
.bad {{{2}}}
.good {{{3}}}
.tree {{font-family: monospace; font-size: larger; line-height: 0px; vertical-align: middle;}}
.underlined {{border-bottom: solid 1px black;}}
.hfill {{width: 100%;}}
.vfill {{height: 100%;}}
.tree-line {{border-left: 1px solid gray; border-bottom: 1px solid gray; position: absolute;}}
@media print {{ .tree-line {{display: none; }} }}
";

  HtmlScript :=
"<script src='https://ajax.googleapis.com/ajax/libs/jquery/3.6.1/jquery.min.js'></script>
<script type='text/javascript'>

function resizeReport() {
  var prevLines = jQuery('.tree-line');
  if (prevLines) { prevLines.remove(); }
  var trees = jQuery('.tree');
  trees.each( function (index, element) {
    var tree = $(this);
    var parentId = tree.attr('data-dex-parent');
    if (!parentId) { return; }
    var parent = jQuery('#' + parentId);
    if (!parent) { return; }
    var parentPos = parent.offset();
    var treePos = tree.offset();
    var lines = jQuery('<span />').attr({'class': 'tree-line' , 'text':'' });
    tree.after(lines);
    var css = {
      top: parentPos.top + parent.height(),
      left: parentPos.left + 4,
      height: treePos.top - parentPos.top - tree.height()/2 + 2,
      width: tree.width() + treePos.left - parentPos.left - 8,
    }
    lines.css(css);
  });
}
window.onresize = resizeReport;
resizeReport();
</script>
";

  HtmlFoot :=
"</body>
</html>
";
end;

constructor DexiHtmlParameters(aModel: DexiModel);
begin
  constructor;
  if aModel:Settings = nil then
    exit;
  FontName := aModel.Settings.ReportFontInfo.Name;
  FontSize := aModel.Settings.ReportFontInfo.Size;
  if String.IsNullOrEmpty(FontName) or (FontSize <= 0) then
    begin
      FontName := SystemFonts.DefaultFont.Name;
      FontSize := SystemFonts.DefaultFont.Size;
    end;
  BadColor := '#' + aModel.Settings.BadColor.ToHexString;
  GoodColor := '#' + aModel.Settings.GoodColor.ToHexString;
  BadStyle := aModel.Settings.BadStyle;
  GoodStyle := aModel.Settings.GoodStyle;
end;

class method DexiHtmlParameters.NewParameters: DexiHtmlParameters;
begin
  result := new DexiHtmlParameters;
end;

method DexiHtmlParameters.TagMapper(aTag: Integer): String;
begin
  result :=
    if aTag < 0 then 'bad'
    else if aTag > 0 then 'good'
    else nil;
end;

method DexiHtmlParameters.TextStyle(aColor, aStyle: String): String;
begin
  result := '';
  if not String.IsNullOrEmpty(aColor) then
    result := result + 'color: ' + aColor + '; ';
  if String.IsNullOrEmpty(aStyle) then
    exit;
  aStyle := aStyle.ToUpper;
  if aStyle.Contains('B') then
    result := result + 'font-weight: bold; ';
  if aStyle.Contains('I') then
    result := result + 'font-style: italic; ';
  if aStyle.Contains('U') then
    result := result + 'text-decoration: underline; ';
  result := result.TrimEnd;
end;

method DexiHtmlParameters.Style: String;
begin
  result := String.Format(HtmlStyle, FontName, Utils.FltToStr(FontSize), TextStyle(BadColor, BadStyle), TextStyle(GoodColor, GoodStyle));
end;

method DexiHtmlParameters.Head: String;
begin
  result := String.Format(HtmlHead, HtmlTitle, Style);
end;

{$ENDREGION}

{$REGION DexiFormatMaker}

method DexiFormatMaker.FontMaker(aTag: Integer; aBaseFont: Font): Font;
begin
  result :=
   if aTag = 0 then new Font(aBaseFont, AppData.RegularFont.Style)
   else if aTag < 0 then new Font(aBaseFont, AppData.BadFont.Style)
   else new Font(aBaseFont, AppData.GoodFont.Style)
end;

method DexiFormatMaker.BrushMaker(aTag: Integer): Brush;
begin
  var lColor :=
    if aTag = 0 then AppData.RegularColor
    else if aTag < 0 then AppData.BadColor
    else AppData.GoodColor;
  result := new SolidBrush(lColor);
end;

{$ENDREGION}

{$REGION ReportManager}

method ReportManager.ReportFont(aFormat: DexiReportFormat): Font;
begin
  result :=
    if String.IsNullOrEmpty(aFormat.FontName) or (aFormat.FontSize <= 0.0) then
      SystemFonts.DefaultFont
    else
      new Font(aFormat.FontName, aFormat.FontSize);
end;

method ReportManager.OpenReportViewer(aReport: DexiReport; aParamForm: FormReportParameters);
begin
  if aReport.Model:Settings.RptHtml or AppSettings.ForcedHtmlReports then
    BrowserManager.BrowseReport(aReport, aParamForm, nil)
  else
    using lReportForm := new FormReport do
      begin
        lReportForm.Report := aReport;
        lReportForm.ParamForm := aParamForm;
        lReportForm.ShowDialog;
      end;
end;

method ReportManager.OpenReport(aReport: DexiReport);
begin
  var lParamForm := new FormReportParameters;
  lParamForm.SetForm(aReport);
  OpenReportViewer(aReport, lParamForm);
end;

method ReportManager.OpenReportDialog(aReport: DexiReport);
begin
  var lParamForm := new FormReportParameters;
  lParamForm.SetForm(aReport);
  if lParamForm.ShowDialog = DialogResult.OK then
    begin
      aReport.Parameters := lParamForm.Parameters;
      aReport.Format := lParamForm.Format;
      aReport.Title := lParamForm.ReportTitle;
      OpenReportViewer(aReport, lParamForm);
    end;
end;

method ReportManager.OpenFunctionReport(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiFunction := nil);
require
  aModel <> nil;
begin
  var lReport := aModel.NewFunctionReport(aAttribute, aFunct);
  OpenReport(lReport);
end;

method ReportManager.OpenComparisonReport(aModel: DexiModel; aAlternative: Integer);
require
  aModel <> nil;
begin
  var lReport := aModel.NewComparisonReport(aAlternative);
  OpenReportDialog(lReport);
end;

method ReportManager.OpenSelectiveExplanationReport(aModel: DexiModel);
require
  aModel <> nil;
begin
  var lReport := aModel.NewSelectiveExplanationReport;
  OpenReportDialog(lReport);
end;

method ReportManager.OpenPlusMinusReport(aModel: DexiModel; aAttribute: DexiAttribute; aAlternative: Integer);
require
  aModel <> nil;
begin
  var lReport := aModel.NewPlusMinusReport(aAttribute, aAlternative);
  OpenReportDialog(lReport);
end;

method ReportManager.OpenTargetReport(aModel: DexiModel; aAttribute: DexiAttribute; aAlternative: Integer);
require
  aModel <> nil;
begin
  var lReport := aModel.NewTargetReport(aAttribute, aAlternative);
  OpenReportDialog(lReport);
end;

method ReportManager.OpenEvaluateQQReport(aModel: DexiModel);
require
  aModel <> nil;
begin
  var lReport := aModel.NewEvaluateQQReport;
  OpenReportDialog(lReport);
end;

{$ENDREGION}

{$REGION BrowserManager}

method BrowserManager.GetTemporaryFileName(aExt: String): String;
begin
  var lTempName := System.IO.Path.GetTempFileName;
  result := Path.ChangeExtension(lTempName, aExt);
  fTemporaryFiles.Add(result);
  try
    File.Delete(lTempName);
  except
  end;
end;

method BrowserManager.OpenInBrowser(aHtml: String);
begin
  var lFileName := GetTemporaryFileName('.html');
  File.WriteText(lFileName, aHtml);
  System.Diagnostics.Process.Start(lFileName);
end;

method BrowserManager.DeleteTemporaryFiles;
begin
  for each lFileName in fTemporaryFiles do
  try
    File.Delete(lFileName);
  except
  end;
  fTemporaryFiles.RemoveAll;
end;

method BrowserManager.BrowseReport(aReport: DexiReport; aParamForm: FormReportParameters; aManagerForm: FormReportManager);
begin
  aReport.MakeReport(true);
  if aReport.Model.Settings.DefBrowser then
    begin
      using lHtmlWriter := new RptHtmlWriter(aReport.Report, AppData.HtmlParams) do
        OpenInBrowser(lHtmlWriter.AsString);
    end
  else
    using lBrowser := new FormBrowse do
      begin
        lBrowser.ParamForm := aParamForm;
        lBrowser.ManagerForm := aManagerForm;
        lBrowser.Report := aReport;
        lBrowser.ShowDialog;
      end;
end;

{$ENDREGION}

{$REGION ModelUndoRedo}

constructor ModelUndoRedo(aModelForm: FormModel);
begin
  inherited constructor;
  fModelForm := aModelForm;
end;

method ModelUndoRedo.GetObjectState: UndoState;
require
  Model <> nil;
begin
  var lUndoable := new List<IUndoable>;
  Model.CollectUndoableObjects(lUndoable);
  lUndoable.Add(fModelForm.AltVisibility);
  result := new UndoState(lUndoable, PreviousState);
end;

method ModelUndoRedo.SetObjectState(aState: UndoState);
begin
  aState.Apply;
end;

method ModelUndoRedo.GetPreviousState: UndoState;
begin
  result := PeekUndoState;
end;

{$ENDREGION}

end.