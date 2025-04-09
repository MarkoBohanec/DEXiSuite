// FormReportParameters.pas is part of
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
// FormReportParameters.pas implements a form for editing 'DexiReportParameters'.
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
  /// Summary description for FormReportParameters.
  /// </summary>
  FormReportParameters = partial public class(System.Windows.Forms.Form)
  private
    method ChkFunctMarginals_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctNumeric_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkDeepCompare_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method NumColumns_ValueChanged(sender: System.Object; e: System.EventArgs);
    method GenAttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method NumGenMaxShow_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumGenMaxGenerate_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumGenMaxSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
    method RadGenDegrade_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method RadGenImprov_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method EditGenAlternative_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method EditGoalAttribute_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method NumPlusSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumMinusSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
    method ChkWeiGlobalNormalized_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkWeiLocalNormalized_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkWeiGlobal_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkWeiLocal_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkAttFunct_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkAttScale_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkAttDescription_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkAttName_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctStatus_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctEntered_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctNormWeight_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctWeights_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ChkFunctNumbers_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method EditFunctRepresentation_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method EditMainAlternative_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method EditRootAttribute_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method AttList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
    method AltList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
    method AttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method BtnUncheckAllAtt_Click(sender: System.Object; e: System.EventArgs);
    method BtnCheckAllAtt_Click(sender: System.Object; e: System.EventArgs);
    method ChkSelectAllAtt_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method AltList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method BtnUncheckAllAlt_Click(sender: System.Object; e: System.EventArgs);
    method BtnCheckAllAlt_Click(sender: System.Object; e: System.EventArgs);
    method ChkSelectAllAlt_CheckedChanged(sender: System.Object; e: System.EventArgs);
  private
    fFormText: String;
    fReport: DexiReport;
    fParameters: DexiReportParameters;
    fAltList: List<AlternativeObject>;
    fAttList: DexiAttributeList;
    fRootAttList: DexiAttributeList;
    fRootAttributeSelector: AttributeCondition;
    fAttributeSelector: AttributeCondition;
    fUpdateLevel: Integer;
    fTabParameters: Boolean;
    fTabGenerator: Boolean;
    fTabAlternatives: Boolean;
    fTabAttributes: Boolean;
    fTreeMode: Boolean;
    fEvalMode: Boolean;
    fComparisonMode: Boolean;
    fPlusMinusMode: Boolean;
    fTargetMode: Boolean;
    fFormValidate: Func<Boolean> := nil;
  protected
    method Dispose(aDisposing: Boolean); override;
    method SelAltCount(aExclude: Integer := -1): Integer;
    method SelAttCount: Integer;
    method PlusMinusAttCount: Integer;
    method TargetAttCount: Integer;
    method AttributeChildren(aAtt: DexiAttribute): ImmutableList<DexiAttribute>;
    method UpdateForm;
    method ColumnsToElements;
    method ElementsToColumns;
    method ParametersVisibility(aRootAttribute, aMainAlternative, aElements, aEvaluation, aFunctions, aWeights, aPlusMinus, aCompare, aMessage: Boolean);
    method TabsVisibility(aParameters, aGenerator, aAttributes, aAlternatives: Boolean);
    method ConfigureByReportType;
    method ValidPlusMinusAttribute(aAtt: DexiAttribute): Boolean;
    method ValidTargetAttribute(aAtt: DexiAttribute): Boolean;
    method ValidTargetTreeAttribute(aAtt: DexiAttribute): Boolean;
    method ValidateGeneral: Boolean;
    method ValidateForAlternativeComparison: Boolean;
    method ValidateForSelectiveExplanation: Boolean;
    method ValidateForPlusMinusAnalysis: Boolean;
    method ValidateForTargetAnalysis: Boolean;
  public
    constructor;
    method SetForm(aReport: DexiReport; aParametersOnly: Boolean := false);
    property Model: DexiModel read fParameters.Model;
    property Parameters: DexiReportParameters read fParameters;
    property Format: DexiReportFormat read CtrlFormat.Format;
    property ReportTitle: String read CtrlFormat.ReportTitle;
    property SelectedFont: Font read CtrlFormat.SelectedFont;
    property ChangedFont: Boolean read CtrlFormat.ChangedFont;
    property RootAttributeSelector: AttributeCondition read fRootAttributeSelector write fRootAttributeSelector;
    property AttributeSelector: AttributeCondition read fAttributeSelector write fAttributeSelector;
    property FormValidate: Func<Boolean> read fFormValidate write fFormValidate;
    property TargetMode: Boolean read fTargetMode write fTargetMode;
  end;

type
  AlternativeObject = public class
  public
    property &Index: Integer;
    property Name: String;
    property Description: String;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormReportParameters;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fUpdateLevel := 0;
  fFormText := self.Text;
  AttList.SmallImageList := AppData:ModelImages;
  GenAttList.SmallImageList := AppData:ModelImages;

  AttList.CanExpandGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).IsAggregate
        else false;
    end;

  AttList.ChildrenGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then AttributeChildren(DexiAttribute(x))
        else nil;
    end;

  ColAttribute.ImageGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then 'ImgAtt' + DexiAttribute(x).NodeStatus.ToString
        else nil;
    end;

  AttList.BooleanCheckStateGetter :=
    method(x: Object): Boolean
    begin
      result :=
        if (x is DexiAttribute) then fParameters.IsSelected(DexiAttribute(x))
        else false;
    end;

  AttList.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is DexiAttribute) then
        if chk then fParameters.SelectAttribute(DexiAttribute(x))
        else fParameters.UnSelectAttribute(DexiAttribute(x));
    end;

  GenAttList.CanExpandGetter := AttList.CanExpandGetter;
  GenAttList.ChildrenGetter := AttList.ChildrenGetter;

  GenAttList.BooleanCheckStateGetter :=
    method(x: Object): Boolean
    begin
      result :=
        if (x is DexiAttribute) then fParameters.IsSelected(DexiAttribute(x))
        else false;
    end;

  GenAttList.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is DexiAttribute) then
        begin
          var lAtt := DexiAttribute(x);
          if chk then
            begin
              fParameters.UnSelectAttributes(lAtt.CollectInputs(false));
              fParameters.SelectAttribute(lAtt);
              lAtt := lAtt.Parent;
              while lAtt <> nil do
                begin
                  fParameters.UnSelectAttribute(lAtt);
                  lAtt := lAtt.Parent;
                end;
            end
          else
            fParameters.UnSelectAttribute(lAtt);
        end;
      end;

  ColGenAttribute.ImageGetter := ColAttribute.ImageGetter;

  AltList.BooleanCheckStateGetter :=
    method(x: Object): Boolean
    begin
      result :=
        if (x is AlternativeObject) then fParameters.IsSelected(AlternativeObject(x).Index)
        else false;
    end;

  AltList.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is AlternativeObject) then
        if chk then fParameters.SelectAlternative(AlternativeObject(x).Index)
        else fParameters.UnSelectAlternative(AlternativeObject(x).Index);
    end;

end;

method FormReportParameters.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    AttList.SmallImageList := nil;
    GenAttList.SmallImageList := nil;
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormReportParameters.SelAltCount(aExclude: Integer := -1): Integer;
begin
  result := 0;
  for lAlt := 0 to Model.AltCount - 1 do
    if fParameters.IsSelected(lAlt) and (lAlt <> aExclude) then
      inc(result);
end;

method FormReportParameters.SelAttCount: Integer;
begin
  result := 0;
  for each lAtt in fAttList do
    if fParameters.IsSelected(lAtt) then
      inc(result);
end;

method FormReportParameters.PlusMinusAttCount: Integer;
begin
  result := 0;
  for each lAtt in fAttList do
    if fParameters.IsSelected(lAtt) and not lAtt.IsAggregate and DexiPlusMinusReport.ValidAttribute(lAtt) then
      inc(result);
end;

method FormReportParameters.TargetAttCount: Integer;

  method CountTargetSelected(aAtt: DexiAttribute): Integer;
  begin
    result := 
      if not fParameters.IsSelected(aAtt) then 0
      else if DexiTargetReport.ValidAttribute(aAtt) then 1
      else 0;
    for i := 0 to aAtt.InpCount - 1 do
      result := result + CountTargetSelected(aAtt.Inputs[i]);
  end;

begin
  var lAtt := fParameters.Root;
  result := 0;
  for i := 0 to lAtt.InpCount - 1 do
    result := result + CountTargetSelected(lAtt.Inputs[i]);
end;

method FormReportParameters.AttributeChildren(aAtt: DexiAttribute): ImmutableList<DexiAttribute>;
begin
  if AttributeSelector = nil then
    result := aAtt.AllInputs
  else
    begin
      var lList := new List<DexiAttribute>;
      for each lAtt in aAtt.AllInputs do
        if AttributeSelector(lAtt) then
          lList.Add(lAtt);
      result := lList;
    end;
end;

method FormReportParameters.ParametersVisibility(aRootAttribute, aMainAlternative, aElements, aEvaluation, aFunctions, aWeights, aPlusMinus, aCompare, aMessage: Boolean);
begin
  PanelRootAttribute.Visible := aRootAttribute;
  PanelMainAlternative.Visible := aMainAlternative;
  PanelFunctions.Visible := aFunctions;
  PanelElements.Visible := aElements;
  PanelEvaluation.Visible := aEvaluation;
  PanelWeights.Visible := aWeights;
  PanelPlusMinus.Visible := aPlusMinus;
  PanelCompare.Visible := aCompare;
  PanelMessage.Visible := aMessage;
end;

method FormReportParameters.TabsVisibility(aParameters, aGenerator, aAttributes, aAlternatives: Boolean);
begin
  fTabParameters := aParameters;
  fTabGenerator := aGenerator;
  fTabAttributes := aAttributes;
  fTabAlternatives := aAlternatives;
end;

method FormReportParameters.ConfigureByReportType;
begin
  fTreeMode := false;
  fEvalMode := false;
  fComparisonMode := false;
  fPlusMinusMode := false;
  fTargetMode := false;
  FormValidate := @ValidateGeneral;
  if (fReport is DexiModelReport) or (fReport is DexiStatisticsReport) then
    begin
      ParametersVisibility(false, false, false, false, false, false, false, false, false);
      TabsVisibility(false, false, false, false);
    end
  else if fReport is DexiSingleFunctionReport then
    begin
      ParametersVisibility(false, false, false, false, true, false, false, false, false);
      TabsVisibility(true, false, false, false);
    end
  else if fReport is DexiAttributeReport then
    begin
      ParametersVisibility(true, false, true, false, true, false, false, false, false);
      TabsVisibility(true, false, true, false);
      PanelMainAlternative.Visible := false;
      GrpElements.Text := DexiStrings.RptAttributeElements;
    end
  else if fReport is DexiTreeReport then
    begin
      fTreeMode := fReport is DexiTreeAttributeReport;
      fEvalMode := (fReport is DexiTreeEvaluationReport) or (fReport is DexiTreeAlternativesReport);
      ParametersVisibility(true, false, fTreeMode, fEvalMode, false, false, false, false, false);
      TabsVisibility(true, false, true, (fReport is DexiTreeEvaluationReport) or (fReport is DexiTreeAlternativesReport));
      ChkAttName.Checked := true;
      ChkAttName.Enabled := false;
      GrpElements.Text := DexiStrings.RptTreeElements;
      fTreeMode := fReport is DexiTreeAttributeReport;
    end
  else if fReport is DexiFunctionsReport then
    begin
      ParametersVisibility(true, false, false, false, false, false, false, false, false);
      TabsVisibility(true, false, true, false);
    end
  else if fReport is DexiWeightsReport then
    begin
      ParametersVisibility(true, false, false, false, false, true, false, false, false);
      TabsVisibility(true, false, true, false);
    end
  else if fReport is DexiSelectiveExplanationReport then
    begin
      ParametersVisibility(true, false, false, false, false, false, false, false, false);
      TabsVisibility(true, false, true, true);
      FormValidate := @ValidateForSelectiveExplanation;
    end
  else if fReport is DexiAlternativeComparisonReport then
    begin
      ParametersVisibility(false, true, false, false, false, false, false, true, true);
      TabsVisibility(true, false, true, true);
      var lPage := TabsReport.TabPages[2];
      TabsReport.TabPages[2] := TabsReport.TabPages[3];
      TabsReport.TabPages[3] := lPage;
      FormValidate := @ValidateForAlternativeComparison;
      LblMessage.Text := DexiStrings.RptUseAltAtt;
      fComparisonMode := true;
    end
  else if fReport is DexiPlusMinusReport then
    begin
      ParametersVisibility(true, true, false, false, false, false, true, false, false);
      TabsVisibility(true, false, true, false);
      RootAttributeSelector := @ValidPlusMinusAttribute;
      FormValidate := @ValidateForPlusMinusAnalysis;
      fPlusMinusMode := true;
    end
  else if fReport is DexiTargetReport then
    begin
      TabsVisibility(false, true, false, false);
      RootAttributeSelector := @ValidTargetAttribute;
      AttributeSelector := @ValidTargetTreeAttribute;
      FormValidate := @ValidateForTargetAnalysis;
      fTargetMode := true;
    end
  else if fReport is DexiChartReport then
    TabsVisibility(false, false, false, true)
  else if fReport is DexiReportGroup then
    TabsVisibility(false, false, false, false)
  else if fReport.ReportType <> 'DEBUG' then
    raise new EDexiError($'Unhandled report type "{typeOf(fReport).Name}"');
  if not fTabParameters then
    TabsReport.TabPages.Remove(PageParameters);
  if not fTabGenerator then
    TabsReport.TabPages.Remove(PageGenerator);
  if not fTabAttributes then
    TabsReport.TabPages.Remove(PageAttributes);
  if not fTabAlternatives then
    TabsReport.TabPages.Remove(PageAlternatives);
end;

method FormReportParameters.SetForm(aReport: DexiReport; aParametersOnly: Boolean := false);
require
  aReport <> nil;
  aReport.Parameters <> nil;
  aReport.Parameters.Model <> nil;
  aReport.Format <> nil;
begin
  fReport := aReport;
  fParameters := new DexiReportParameters(fReport.Parameters);
  CtrlFormat.SetForm(aReport, fParameters, aParametersOnly);
  ConfigureByReportType;
  fAltList := new List<AlternativeObject>;
  for lAlt := 0 to Model.AltCount - 1 do
    fAltList.Add(new AlternativeObject(
      &Index := lAlt,
      Name := Model.Alternative[lAlt].Name,
      Description := Model.Alternative[lAlt].Description));
  fRootAttList :=
    if RootAttributeSelector = nil then
      Model.Root.CollectInputs(true)
    else
      Model.Root.CollectInputs(false, RootAttributeSelector);
  fAttList := Model.Root.CollectInputs(false, AttributeSelector);
  inc(fUpdateLevel);
  try
    // RootAttribute
      EditRootAttribute.Items.Clear;
      for each lAtt in fRootAttList do
        if lAtt = Model.Root then
          EditRootAttribute.Items.Add(DexiString.RRooted)
        else
          EditRootAttribute.Items.Add(lAtt.Name);
      EditRootAttribute.SelectedIndex :=
      if fParameters.Root = nil then 0
      else fRootAttList.IndexOf(fParameters.Root);

    // Main alternative
      EditMainAlternative.Items.Clear;
      if Model.AltCount > 0 then
        begin
          for each lAlt in fAltList do
            EditMainAlternative.Items.Add(lAlt.Name);
          if 0 <= fParameters.Alternative < Model.AltCount then
            EditMainAlternative.SelectedIndex := fParameters.Alternative;
        end;

    // Functions
      EditFunctRepresentation.Items.Clear;
      for lRepr := low(DexiRptFunctionRepresentation) to high(DexiRptFunctionRepresentation) do
        EditFunctRepresentation.Items.Add(DexiRptFunctionRepresentation(lRepr).ToString);
      EditFunctRepresentation.SelectedIndex := Integer(fParameters.Representation);
      ChkFunctNumbers.Checked := fParameters.FncShowNumbers;
      ChkFunctWeights.Checked := fParameters.FncShowWeights;
      ChkFunctNormWeight.Checked := fParameters.UseNormalizedWeights;
      ChkFunctEntered.Checked := fParameters.FncEnteredOnly;
      ChkFunctStatus.Checked := fParameters.FncStatus;
      ChkFunctNumericValues.Checked := fParameters.FncShowNumericValues;
      ChkFunctMarginals.Checked := fParameters.FncShowMarginals;

    // Tree/Attribute elements
    if fTreeMode then
      ColumnsToElements
    else
      begin
        ChkAttName.Checked := fParameters.AttName;
        ChkAttDescription.Checked := fParameters.AttDescription;
        ChkAttScale.Checked := fParameters.AttScale;
        ChkAttFunct.Checked := fParameters.AttFunction;
      end;

    // Evaluation
    NumColumns.Value := fParameters.MaxColumns;

    // Weights
    ChkWeiLocal.Checked := fParameters.WeightsLocal;
    ChkWeiGlobal.Checked := fParameters.WeightsGlobal;
    ChkWeiLocalNormalized.Checked := fParameters.WeightsLocalNormalized;
    ChkWeiGlobalNormalized.Checked := fParameters.WeightsGlobalNormalized;

    // Plus/Minus
    NumMinusSteps.Value := fParameters.MinusSteps;
    NumPlusSteps.Value := fParameters.PlusSteps;

    // Compare
    ChkDeepCompare.Checked := fParameters.DeepCompare;

    // Target analysis
    if fTargetMode then
      begin
        EditGoalAttribute.Items.Clear;
        for each lItem in EditRootAttribute.Items do
          EditGoalAttribute.Items.Add(lItem);
        EditGoalAttribute.SelectedIndex := EditRootAttribute.SelectedIndex;

        fParameters.SelectAllAttributesExplicitly(fAttList);
        for each lAtt in fAttList do
          if lAtt.IsAggregate and not DexiAttribute.AttributeIsDiscretization(lAtt) then
            fParameters.UnSelectAttribute(lAtt);

        EditGenAlternative.Items.Clear;
        for each lItem in EditMainAlternative.Items do
          EditGenAlternative.Items.Add(lItem);
        EditGenAlternative.SelectedIndex := EditMainAlternative.SelectedIndex;

        if fParameters.Improve then
          RadGenImprov.Checked := true
        else
          RadGenDegrade.Checked := true;

        NumGenMaxSteps.Value := fParameters.MaxSteps;
        ChkGenUnidirectional.Checked := fParameters.Unidirectional;
        NumGenMaxGenerate.Value := fParameters.MaxGenerate;
        NumGenMaxShow.Value := fParameters.MaxShow;
      end;

    // Alternatives
    var lSelectedAlternatives := fParameters.SelectedAlternatives;
    ChkSelectAllAlt.Checked := lSelectedAlternatives = nil;
    AltList.SetObjects(fAltList);

    // Attributes
    var lSelectedAttributes := fParameters.SelectedAttributes;
    ChkSelectAllAtt.Checked := lSelectedAttributes = nil;
    AttList.SetObjects(AttributeChildren(Model:Root));
    AttList.ExpandAll;
    GenAttList.SetObjects(AttributeChildren(Model:Root));
    GenAttList.ExpandAll;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method FormReportParameters.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    Text := String.Format(fFormText, ReportTitle);
    AppUtils.Show(not ChkSelectAllAlt.Checked, BtnCheckAllAlt, BtnUncheckAllAlt, AltList);
    AppUtils.Show(not ChkSelectAllAtt.Checked, BtnCheckAllAtt, BtnUncheckAllAtt, AttList);
    AppUtils.Enable(not assigned(FormValidate) or FormValidate, BtnOK);
    if fComparisonMode then
      begin
        AltList.EnableObjects(fAltList);
        AltList.DisableObject(fAltList[EditMainAlternative.SelectedIndex]);
      end;
    if fPlusMinusMode then
      for each lAtt in fAttList do
        if lAtt.IsAggregate or not DexiPlusMinusReport.ValidAttribute(lAtt) then
          AttList.DisableObject(lAtt)
        else
          AttList.EnableObject(lAtt);
    if fTargetMode then
      begin
        GenAttList.SetObjects(AttributeChildren(fParameters.Root));
        GenAttList.ExpandAll;
        var lValue: DexiValue := nil;
        try
          lValue := Model.AltValue[fParameters.Alternative, fParameters.Root];
        except // todo
        end;
        TextGenValue.SetValueOnScaleText(
          lValue,
          fParameters.Root:Scale,
          TextGenValue.BackColor);
      end;
  finally
    dec(fUpdateLevel);
  end;
  AltList.Refresh;
end;

method FormReportParameters.ColumnsToElements;
begin
  ChkAttName.Checked := true;
  ChkAttDescription.Checked := false;
  ChkAttScale.Checked := false;
  ChkAttFunct.Checked := false;
  for each lEl in fParameters.Columns do
    case lEl of
      DexiTreeReport.ColDescr: ChkAttDescription.Checked := true;
      DexiTreeReport.ColScale: ChkAttScale.Checked := true;
      DexiTreeReport.ColFunct: ChkAttFunct.Checked := true;
    end;
end;

method FormReportParameters.ElementsToColumns;
begin
  var lColumns := new List<Integer>;
  if ChkAttDescription.Checked then
    lColumns.Add(DexiTreeReport.ColDescr);
  if ChkAttScale.Checked then
    lColumns.Add(DexiTreeReport.ColScale);
  if ChkAttFunct.Checked then
    lColumns.Add(DexiTreeReport.ColFunct);
  fParameters.Columns := lColumns.ToArray;
end;

method FormReportParameters.ValidPlusMinusAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := DexiPlusMinusReport.ValidAttribute(aAtt) and aAtt.IsAggregate;
end;

method FormReportParameters.ValidTargetAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := DexiTargetReport.ValidAttribute(aAtt) and
            aAtt.IsAggregate and not DexiAttribute.AttributeIsDiscretization(aAtt);
end;

method FormReportParameters.ValidTargetTreeAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := DexiTargetReport.ValidAttribute(aAtt);
end;

method FormReportParameters.ValidateGeneral: Boolean;
begin
  result := (not fTabAttributes or (SelAttCount > 0)) and (not fTabAlternatives or (SelAltCount > 0));
end;

method FormReportParameters.ValidateForAlternativeComparison: Boolean;
begin
  var lSelectedAlternative := EditMainAlternative.SelectedIndex;
  result :=
   (0 <= lSelectedAlternative < Model.AltCount) and
   (SelAltCount(lSelectedAlternative) > 0) and
   (SelAttCount > 0);
end;

method FormReportParameters.ValidateForSelectiveExplanation: Boolean;
begin
  result := (SelAltCount > 0) and (SelAttCount > 0);
end;

method FormReportParameters.ValidateForPlusMinusAnalysis: Boolean;
begin
  result := PlusMinusAttCount > 0;
end;

method FormReportParameters.ValidateForTargetAnalysis: Boolean;
begin
  result := TargetAttCount > 0;
end;

method FormReportParameters.ChkSelectAllAlt_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if ChkSelectAllAlt.Checked then
    fParameters.SelectAllAlternatives
  else
    fParameters.SelectAllAlternativesExplicitly(Model.AltCount);
  AltList.RefreshObjects(fAltList);
  UpdateForm;
end;

method FormReportParameters.BtnCheckAllAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.SelectAllAlternativesExplicitly(Model.AltCount);
  AltList.RefreshObjects(fAltList);
  UpdateForm;
end;

method FormReportParameters.BtnUncheckAllAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.UnSelectAllAlternatives;
  AltList.RefreshObjects(fAltList);
  UpdateForm;
end;

method FormReportParameters.AltList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  UpdateForm;
end;

method FormReportParameters.ChkSelectAllAtt_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if ChkSelectAllAtt.Checked then
    fParameters.SelectAllAttributes
  else
    fParameters.SelectAllAttributesExplicitly(fAttList);
  UpdateForm;
end;

method FormReportParameters.BtnCheckAllAtt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.SelectAllAttributesExplicitly(fAttList);
  AttList.RefreshAllObjects;
  UpdateForm;
end;

method FormReportParameters.BtnUncheckAllAtt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.UnSelectAllAttributes;
  AttList.RefreshAllObjects;
  UpdateForm;
end;

method FormReportParameters.AttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  UpdateForm;
end;

method FormReportParameters.AltList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
begin
  if e.Model is AlternativeObject then
    e.Text := Model.Alternative[AlternativeObject(e.Model).Index].Description;
end;

method FormReportParameters.AttList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
begin
  if e.Model is DexiAttribute then
    e.Text := DexiAttribute(e.Model).Description;
end;

method FormReportParameters.EditRootAttribute_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lIndex := EditRootAttribute.SelectedIndex;
  if not (0 <= lIndex < fRootAttList.Count) then
    exit;
  fParameters.Root := fRootAttList[lIndex];
  if fParameters.Root = Model.Root then
    fParameters.Root := nil;
  UpdateForm;
end;

method FormReportParameters.EditMainAlternative_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lIndex := EditMainAlternative.SelectedIndex;
  if 0 <= lIndex < Model.AltCount then
    fParameters.Alternative := lIndex;
  UpdateForm;
end;

method FormReportParameters.EditFunctRepresentation_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.Representation := DexiRptFunctionRepresentation(EditFunctRepresentation.SelectedIndex);
end;

method FormReportParameters.ChkFunctNumbers_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncShowNumbers := ChkFunctNumbers.Checked;
end;

method FormReportParameters.ChkFunctWeights_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncShowWeights := ChkFunctWeights.Checked;
end;

method FormReportParameters.ChkFunctNormWeight_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.UseNormalizedWeights := ChkFunctNormWeight.Checked;
end;

method FormReportParameters.ChkFunctEntered_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncEnteredOnly := ChkFunctEntered.Checked;
end;

method FormReportParameters.ChkFunctStatus_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncStatus := ChkFunctStatus.Checked;
end;

method FormReportParameters.ChkFunctNumeric_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncShowNumericValues := ChkFunctNumericValues.Checked;
end;

method FormReportParameters.ChkAttName_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.AttName := ChkAttName.Checked;
end;

method FormReportParameters.ChkAttDescription_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.AttDescription := ChkAttDescription.Checked;
  if fTreeMode then
    ElementsToColumns;
end;

method FormReportParameters.ChkAttScale_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.AttScale := ChkAttScale.Checked;
  if fTreeMode then
    ElementsToColumns;
end;

method FormReportParameters.ChkAttFunct_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.AttFunction := ChkAttFunct.Checked;
  if fTreeMode then
    ElementsToColumns;
end;

method FormReportParameters.ChkWeiLocal_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.WeightsLocal := ChkWeiLocal.Checked;
end;

method FormReportParameters.ChkWeiGlobal_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.WeightsGlobal := ChkWeiGlobal.Checked;
end;

method FormReportParameters.ChkWeiLocalNormalized_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.WeightsLocalNormalized := ChkWeiLocalNormalized.Checked;
end;

method FormReportParameters.ChkWeiGlobalNormalized_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.WeightsGlobalNormalized := ChkWeiGlobalNormalized.Checked;
end;

method FormReportParameters.NumMinusSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.MinusSteps := Integer(NumMinusSteps.Value);
end;

method FormReportParameters.NumPlusSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.PlusSteps := Integer(NumPlusSteps.Value);
end;

method FormReportParameters.EditGoalAttribute_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lIndex := EditGoalAttribute.SelectedIndex;
  if not (0 <= lIndex < fRootAttList.Count) then
    exit;
  fParameters.Root := fRootAttList[lIndex];
  UpdateForm;
end;

method FormReportParameters.EditGenAlternative_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lIndex := EditGenAlternative.SelectedIndex;
  if 0 <= lIndex < Model.AltCount then
    fParameters.Alternative := lIndex;
  UpdateForm;
end;

method FormReportParameters.RadGenImprov_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  fParameters.Improve := true;
end;

method FormReportParameters.RadGenDegrade_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  fParameters.Improve := false;
end;

method FormReportParameters.NumGenMaxSteps_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  fParameters.MaxSteps := Integer(NumGenMaxSteps.Value);
end;

method FormReportParameters.NumGenMaxGenerate_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  fParameters.MaxGenerate := Integer(NumGenMaxGenerate.Value);
end;

method FormReportParameters.NumGenMaxShow_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  fParameters.MaxShow := Integer(NumGenMaxShow.Value);
end;

method FormReportParameters.GenAttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  GenAttList.Refresh;
  UpdateForm;
end;

method FormReportParameters.NumColumns_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.MaxColumns := Integer(NumColumns.Value);
end;

method FormReportParameters.ChkDeepCompare_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.DeepCompare := ChkDeepCompare.Checked;
end;

method FormReportParameters.ChkFunctMarginals_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.FncShowMarginals := ChkFunctMarginals.Checked;
end;

end.