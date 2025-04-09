// AppData.pas is part of
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
// AppData.pas implements application-level data, settings and strings for DEXiWin. Specifically:
// - AppVersion class: application identification info, including name, version and copyright
// - ModelContext class: context data of a particular DEXi model operated upon in DEXiWin.
// - AppData class: static application-level data and events.
// - DexiStrings class: message strings.
// ----------

namespace DexiWin;

interface

uses
  System.Windows.Forms,
  System.Drawing,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  AppVersion = public static class
  public
    class property Name: String read 'DEXiWin';
    class property Author: String read 'Marko Bohanec';
    class property MajorVersion: Integer read 1;
    class property MinorVersion: Integer read 2;
    class property Version: String read String.Format('{0}.{1}{2}', MajorVersion, MinorVersion, '');
    class property YearFrom: Integer read 2023;
    class property YearTo: Integer read 2025;
    class property Years: String read
      if YearFrom = YearTo then YearFrom.ToString
      else YearFrom.ToString + '-' + YearTo.ToString;
    class property CopyrightOwner: String
      read 'Department of Knowledge Technologies, Jožef Stefan Institute';
    class property Copyright: String read Years + ' ' + CopyrightOwner;
    class property Software: String read Name + ' ' + Version;
  end;

type
  ModelContext = public class
  private
    fModel: DexiModel;
    fModelForm: FormModel;
    fCtrlForm: CtrlFormModel;
    fFunctionTableStates := new Dictionary<DexiFunction, array of Byte>;
  public
    property Model: DexiModel read fModel;
    property ModelForm: FormModel read fModelForm;
    property CtrlForm: CtrlFormModel read fCtrlForm;
    property FunctionTableStates: Dictionary<DexiFunction, array of Byte> read fFunctionTableStates;
    constructor (aModel: DexiModel; aModelForm: FormModel; aCtrlForm: CtrlFormModel);
  end;

type
  AppModelSettings = public class
  public
    property MainFormMaximized: Boolean := false;
    property MainFormSize: Size := new Size(1000, 600);
    property ModelFormVisibleElements: String := nil;
    property ModelFormColumnWidths: IntArray := nil;
    method Update(aModel: DexiModel);
  end;

type
  AppXmlHandler = public class (DexiXmlHandler)
  private
    fModel: weak DexiModel;
    fAppXmlData: Dictionary<String, XmlElement>;
    fAppModSettings: AppModelSettings;
  protected
    class const AppId = 'DEXiWin';
    method MakeAppXmlElement: XmlElement; virtual;
  public
    constructor (aModel: DexiModel);
    method ReadXml(aXml: XmlElement); override;
    method WriteXml(aXml: XmlElement); override;
    property AppModSettings: AppModelSettings read fAppModSettings;
  end;

// Needed to avoid a major system crash when disposing cell editor controls immediately
type
  AppDisposeHandler = public static class
  private
    fUndisposed := new Queue<Control>;
  public
    method DisposeUndisposed(aKeep: Integer := -1);
    method HandleUndisposed(aItem: Control);
    property KeepUndisposed := 2;
  end;

type
  AppData = public static class
  private
    fModelContexts := new Dictionary<DexiModel, ModelContext>;
    fPredefinedScales: DexiScaleList;
  protected
    method MakePredefinedScales: DexiScaleList;
  public
    property AppForm: MainForm;
    property DefaultAppFont: Font;
    property CurrentAppFont: Font;
    property ModelContext[aModel: DexiModel]: ModelContext read fModelContexts[aModel];
    property NameEditForm := new FormNameEdit; lazy;
    property AboutForm: FormAbout := new FormAbout; lazy;
    property SearchForm: FormSearch := new FormSearch; lazy;
    property ShapeForm := new FormShapeEdit; lazy;
    property AppImages: ImageList read AppForm:AppImages;
    property ModelImages: ImageList read AppForm:ModelImages;
    property ScaleImages: ImageList read AppForm:ScaleImages;
    property ValueImages: ImageList read AppForm:ValueImages;
    property LoadModels: List<String>;
    property RegularFont: Font;
    property BadFont: Font;
    property GoodFont: Font;
    property GoodInfoFont: Font;
    property RegularColor: Color;
    property BadColor: Color;
    property GoodColor: Color;
    property SubtreeCopy: DexiAttribute;
    property SearchParams: SearchParameters;
    property HtmlParams := DexiHtmlParameters.NewParameters; lazy;
    property TextPageDimensions := new FmtLengths(80, 60); lazy;
    property ToDoQueue := new Queue<Control>;
    property PredefinedScales := MakePredefinedScales; lazy;
    method Initialize;
    method MakeFonts(aZoom: Float := 1.0);
    method AppParameters(args: array of String);
    method ResourceFont(aTag: Integer): Font;
    method ResourceColor(aTag: Integer): Color;
    method HandleToDoQueue(sender: Object; e: EventArgs);
    method HandleExit(sender: Object; e: EventArgs);
    method NewModelContext(aModel: DexiModel; aModelForm: FormModel; aCtrlForm: CtrlFormModel): ModelContext;
    method RemoveModelContext(aModel: DexiModel);
  end;

type
  AppSettings = public static class
  private
  public
    const SelectedColor = Color.FromArgb(240, 240, 245);
    property UseReportBorders := false;
    property DefaultReportBorder := new ImgBorder(10, 10, 10, 10);
    property ReportWindowState := FormWindowState.Maximized;
    property BrowseWindowState := FormWindowState.Maximized;
    property FunctChartWindowState := FormWindowState.Normal;
    property ForcedHtmlReports := false;
    property EditPen := new Pen(Color.Black, 1, DashPattern := [1, 2]);
  end;

type
  DexiStrings = public class
  public
    const
      NoFileError = 'File not found: "{0}"';
      MsgFileSave = 'Do you want to save the model "{0}" to file "{1}"?';
      MsgNewFileSave = 'Do you want to save the model "{0}" to a file?';

      MsgRuleEntered = 'Rule {0} has been entered by the user.';
      MsgRuleNotEntered = 'Rule {0} has not been entered by the user.';
      MsgRuleEnteredInconsist = 'Rule {0} has been entered by the user.' + Environment.LineBreak + 'It is inconsistent with rule(s):' + Environment.LineBreak + '{1}.';
      MsgRuleNotEnteredInconsist = 'Rule {0} has not been entered by the user.' + Environment.LineBreak + 'It is inconsistent with rule(s):' + Environment.LineBreak + '{1}.';
      MsgInconsistEntry =
        'Rule {0}:' + Environment.LineBreak +
        'You are attempting to enter the value "{1}",' + Environment.LineBreak +
        'which is inconsistent with rule(s) {2}. '+ Environment.LineBreak +
        'The previous value was "{3}"' + Environment.LineBreak +
        'Do you still want to enter the new value?';
      MsgIntervalEntered = 'Interval {0} has been entered by the user.';
      MsgIntervalNotEntered = 'Interval {0} has not been entered by the user.';
      MsgIntervalEnteredInconsist = 'Interval {0} has been entered by the user.' + Environment.LineBreak + 'It is inconsistent with interval(s):' + Environment.LineBreak + '{1}.';
      MsgIntervalNotEnteredInconsist = 'Interval {0} has not been entered by the user.' + Environment.LineBreak + 'It is inconsistent with interval(s):' + Environment.LineBreak + '{1}.';
      MsgInconsistInterval =
        'Interval {0}:' + Environment.LineBreak +
        'You are attempting to enter the value "{1}",' + Environment.LineBreak +
        'which is inconsistent with interval(s) {2}. '+ Environment.LineBreak +
        'The previous value was "{3}"' + Environment.LineBreak +
        'Do you still want to enter the new value?';
      MsgUnmatchedAttributes = 'Unmatched attribute IDs while loading data: {0}';
      MsgAlternativesImported = 'Imported alternative(s): {0}';

      MsgSameAttributes = 'The same attribute selected';
      MsgAsymmetricAttributes = 'Asymmetric attributes: different value count and/or preference order';
      MsgSymmetricAttributes = 'Attributes are symmetric';
      MsgAsymmetricRules = 'Asymmetric rule(s):';
      MsgCanEnforce = 'Possible assignments to enforce symmetricity:';

      ModelStatus = 'Attributes: {0} ({1} basic, {2} aggregate, {3} linked)  |  Scales: {4}  |  Functions: {5}  |  Alternatives: {6}';
      ModelProtected = '[Model editing disabled]';

      TitleModelNameEdit = 'Model name and description';
      LabelModelNameEdit = 'Model &name';
      LabelModelDescrEdit = 'Model &description';
      TitleAttNameEdit = 'Attribute name and description';
      LabelAttNameEdit = 'Attribute &name';
      LabelAttDescrEdit = 'Attribute &description';
      TitleSclNameEdit = 'Scale name and description';
      LabelSclNameEdit = 'Scale &name';
      LabelSclDescrEdit = 'Scale &description';
      TitleValNameEdit = 'Value name and description';
      LabelValNameEdit = 'Value &name';
      LabelValDescrEdit = 'Value &description';
      TitleFncNameEdit = 'Function name and description';
      LabelFncNameEdit = 'Function &name';
      LabelFncDescrEdit = 'Function &description';
      TitleAltNameEdit = 'Alternative name and description';
      LabelAltNameEdit = 'Alternative &name';
      LabelAltDescrEdit = 'Alternative &description';

      TitleFunctChart = 'Chart of {0}';

      TitlePreview = 'DEXiWin Report';
      ReportFileName = 'Report';

      TitleBoundEdit = 'Edit bound';
      TitleBoundAdd = 'Add bound';

      DefaultScale = '(default)';
      CurrentScale = '(current)';

      BadThreshold = '&Bad threshold';
      GoodThreshold = '&Good threshold';

      RptTitleReport = 'Report';
      RptTitleFunction = 'Function {0}';
      RptTitleComparison = 'Compare alternatives';
      RptUseAltAtt = 'Use "Alternatives" and "Attributes" tabs to select alternatives and attributes for comparison';
      RptTitleSelectiveExplanation = 'Selective explanation';
      RptTitlePlusMinus = 'Plus/Minus analysis';
      RptTitleTarget = 'Target analysis';
      RptAttributeElements = 'Elements of attribute information report';
      RptTreeElements = 'Elements of attribute tree report';

      TitleTree = 'Tree';

      EnforcingHtmlReports = 'HTML reports will be enforced hereafter.';
  end;

implementation

{$REGION ModelContext}

constructor ModelContext(aModel: DexiModel; aModelForm: FormModel; aCtrlForm: CtrlFormModel);
require
  aModel <> nil;
  aModelForm <> nil;
  aCtrlForm <> nil;
begin
  inherited constructor;
  fModel := aModel;
  fModelForm := aModelForm;
  fCtrlForm := aCtrlForm;
end;

{$ENDREGION}

{$REGION AppModelSettings}

method AppModelSettings.Update(aModel: DexiModel);
begin
  MainFormMaximized := AppData.AppForm.WindowState = FormWindowState.Maximized;
  if not MainFormMaximized then
    MainFormSize := new Size(AppData.AppForm.Size.Width, AppData.AppForm.Size.Height);
  var lModelForm := AppData.ModelContext[aModel]:ModelForm:ModelControl;
  ModelFormVisibleElements :=
    if lModelForm <> nil then lModelForm.VisibleElements
    else nil;
  ModelFormColumnWidths :=
    if lModelForm <> nil then lModelForm.ColumnWidths
    else nil;
end;

{$ENDREGION}

{$REGION AppXmlHandler}

constructor AppXmlHandler(aModel: DexiModel);
require
  aModel <> nil;
begin
  inherited constructor;
  fModel := aModel;
  fAppModSettings := new AppModelSettings;
end;

method AppXmlHandler.MakeAppXmlElement: XmlElement;
begin
  fAppModSettings := new AppModelSettings;
  fAppModSettings.Update(fModel);
  var lAppData := new XmlElement withName('DEXiWin');
  if fAppModSettings.MainFormMaximized then
    lAppData.AddElement(new XmlElement withName('MAXIMIZED' ) Value(Utils.BooleanToStr(fAppModSettings.MainFormMaximized)));
  lAppData.AddElement(new XmlElement withName('MAINFORMWIDTH') Value(Utils.IntToStr(fAppModSettings.MainFormSize.Width)));
  lAppData.AddElement(new XmlElement withName('MAINFORMHEIGHT') Value(Utils.IntToStr(fAppModSettings.MainFormSize.Height)));
  if fAppModSettings.ModelFormVisibleElements <> nil then
    lAppData.AddElement(new XmlElement withName('MODELVISIBLEELEMENTS') Value(fAppModSettings.ModelFormVisibleElements));
  if fAppModSettings.ModelFormColumnWidths <> nil then
    lAppData.AddElement(new XmlElement withName('MODELCOLUMNWIDTHS') Value(Utils.IntArrayToStr(fAppModSettings.ModelFormColumnWidths)));
  result := lAppData;
end;

method AppXmlHandler.ReadXml(aXml: XmlElement);
begin
  fAppXmlData := nil;
  if aXml = nil then
    exit;
  var lAppData: XmlElement := nil;
  fAppModSettings := nil;
  fAppXmlData := new Dictionary<String, XmlElement>;
  for each lItem in aXml.Elements do
    if lItem.LocalName = 'APPDATA' then
      for each lAppItem in lItem.Elements do
        begin
          fAppXmlData.Add(lAppItem.LocalName, lAppItem);
          if lAppItem.LocalName = 'DEXiWin' then
            lAppData := lAppItem;
        end;
  if lAppData = nil then
    exit;
  fAppModSettings := new AppModelSettings;
  for each lItem in lAppData.Elements do
    if lItem.LocalName = 'MAXIMIZED' then
      fAppModSettings.MainFormMaximized := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'MAINFORMWIDTH' then
      fAppModSettings.MainFormSize.Width := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MAINFORMHEIGHT' then
      fAppModSettings.MainFormSize.Height := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MODELVISIBLEELEMENTS' then
      fAppModSettings.ModelFormVisibleElements := lItem.Value
    else if lItem.LocalName = 'MODELCOLUMNWIDTHS' then
      fAppModSettings.ModelFormColumnWidths := Utils.StrToIntArray(lItem.Value);
end;

method AppXmlHandler.WriteXml(aXml: XmlElement);
begin
  var lElement := MakeAppXmlElement;
  if lElement <> nil then
    begin
      if fAppXmlData = nil then
        fAppXmlData := new Dictionary<String, XmlElement>;
      fAppXmlData[AppId] := lElement;
    end;
  if (fAppXmlData = nil) or (fAppXmlData.Count = 0) then
    exit;
  var lData := new XmlElement withName('APPDATA');
  for each lKey in fAppXmlData.Keys do
    lData.AddElement(fAppXmlData[lKey]);
  aXml.AddElement(lData);
end;

{$ENDREGION}

{$REGION AppDisposeHandler}

method AppDisposeHandler.DisposeUndisposed(aKeep: Integer := -1);
begin
  if aKeep < 0 then
    aKeep := Math.Max(0, KeepUndisposed);
  while fUndisposed.Count > aKeep do
    with lItem := fUndisposed.Dequeue do
      if not lItem.IsDisposed then
        lItem.Dispose;
end;

method AppDisposeHandler.HandleUndisposed(aItem: Control);
begin
  DisposeUndisposed(KeepUndisposed);
  if aItem <> nil then
    fUndisposed.Enqueue(aItem);
end;

{$ENDREGION}

{$REGION AppData}

method AppData.Initialize;
begin
  DexiString.DexSoftware := AppVersion.Software;
  SearchParams := SearchForm.SearchParams;
  DefaultAppFont := AppForm.Font;
  CurrentAppFont := FontData.CopyFont(DefaultAppFont);
  MakeFonts;
  RegularColor := AppForm.ForeColor;
  BadColor := Color.Red;
  GoodColor := Color.Green;
  Application.Idle += new EventHandler(HandleToDoQueue);
  Application.ApplicationExit += new EventHandler(HandleExit);
end;

method AppData.MakeFonts(aZoom: Float := 1.0);
begin
  var lSize := aZoom * DefaultAppFont.Size;
  if RegularFont <> nil then
    RegularFont.Dispose;
  RegularFont := new Font(DefaultAppFont.Name,  lSize, FontStyle.Regular);
  if BadFont <> nil then
    BadFont.Dispose;
  BadFont := new Font(DefaultAppFont.Name, lSize, FontStyle.Bold);
  if GoodFont <> nil then
    GoodFont.Dispose;
  GoodFont := new Font(DefaultAppFont.Name, lSize, FontStyle.Bold + FontStyle.Italic);
  if GoodInfoFont <> nil then
    GoodInfoFont.Dispose;
  GoodInfoFont := new Font(DefaultAppFont.Name, lSize, FontStyle.Bold);
end;

method AppData.AppParameters(args: array of String);
begin
  LoadModels := new List<String>(args);
end;

method AppData.ResourceFont(aTag: Integer): Font;
begin
  result :=
    case aTag of
      DexiScale.BadInfo: BadFont;
      DexiScale.BadCategory: BadFont;
      DexiScale.GoodCategory: GoodFont;
      DexiScale.GoodInfo: GoodInfoFont;
      else RegularFont;
    end;
end;

method AppData.ResourceColor(aTag: Integer): Color;
begin
  result :=
    case aTag of
      DexiScale.BadInfo: BadColor;
      DexiScale.BadCategory: BadColor;
      DexiScale.GoodCategory: GoodColor;
      DexiScale.GoodInfo: GoodColor;
      else RegularColor;
    end;
end;

method AppData.HandleToDoQueue(sender: Object; e: EventArgs);
begin
  if ToDoQueue.Count > 0 then
    begin
      var lControl := ToDoQueue.Dequeue;
      if lControl is CtrlFormReport then
        CtrlFormReport(lControl).DoFormat;
    end;
end;

method AppData.HandleExit(sender: Object; e: EventArgs);
begin
  BrowserManager.DeleteTemporaryFiles;
end;

method AppData.NewModelContext(aModel: DexiModel; aModelForm: FormModel; aCtrlForm: CtrlFormModel): ModelContext;
begin
  result := new ModelContext(aModel, aModelForm, aCtrlForm);
  fModelContexts.Add(aModel, result);
end;

method AppData.RemoveModelContext(aModel: DexiModel);
begin
  fModelContexts.Remove(aModel);
end;

method AppData.MakePredefinedScales: DexiScaleList;
begin
  if fPredefinedScales <> nil then
    exit fPredefinedScales;
  fPredefinedScales := new DexiScaleList;
  fPredefinedScales.Add(new DexiDiscreteScale(['false', 'true'], Name := 'BooleanAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['false', 'true'], Name := 'BooleanDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['false', 'true'], Name := 'BooleanUnordered', &Order := DexiOrder.None));
  fPredefinedScales.Add(new DexiDiscreteScale(['true', 'false'], Name := 'BooleanReverseAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['true', 'false'], Name := 'BooleanReverseDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['no', 'yes'], Name := 'NoYesAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['no', 'yes'], Name := 'NoYesDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['no', 'yes'], Name := 'NoYesUnordered', &Order := DexiOrder.None));
  fPredefinedScales.Add(new DexiDiscreteScale(['yes', 'no'], Name := 'YesNoAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['yes', 'no'], Name := 'YesNoDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['low', 'med', 'high'], Name := 'LMHAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['low', 'med', 'high'], Name := 'LMHDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['low', 'med', 'high'], Name := 'LMHUnordered', &Order := DexiOrder.None));
  fPredefinedScales.Add(new DexiDiscreteScale(['high', 'med', 'low'], Name := 'HMLAscending', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['high', 'med', 'low'], Name := 'HMLDescending', &Order := DexiOrder.Descending));
  fPredefinedScales.Add(new DexiDiscreteScale(['high', 'med', 'low'], Name := 'HMLUnordered', &Order := DexiOrder.None));
  fPredefinedScales.Add(new DexiDiscreteScale(['unacc', 'acc', 'good'], Name := 'Acceptability3', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['unacc', 'acc', 'good', 'exc'], Name := 'Acceptability4', &Order := DexiOrder.Ascending));
  fPredefinedScales.Add(new DexiDiscreteScale(['unacc', 'acc', 'good', 'v-good', 'exc'], Name := 'Acceptability5', &Order := DexiOrder.Ascending));
  result := fPredefinedScales;
end;

{$ENDREGION}

end.