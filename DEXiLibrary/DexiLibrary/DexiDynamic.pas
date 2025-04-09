// DexiDynamic.pas is part of
//
// DEXiLibrary, DEXi Decision Modeling Software Library
//
// Copyright (C) 2023-2025 Marko Bohanec
//
// DEXiLibrary is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// DexiDynamic.pas implements classes aimed at the evaluation of "dynamic DEXi models".
// A dynamic DEXi model is a model with cycles, so that its inputs may depend on values of output attributes.
// This dependance is specified by special naming of attributes: Attribute whose name starts with '_' depends
// on an otherwise equally named attribute, except that its name starts with '*'.
// Evaluation is carried out in iterations, observing the convergence of attribute values.
// DexiDynamic.pas is experimental.
//
// DexiDynamic classes:
// - DexiDynaLink: Stores pairs of dynamic source ('*') and destination ('_') attributes.
// - DexiDynaTrace: Keeps the history of dynamic evaluation, including the alternatives evaluated in each iterations.
// - DexiValueSequence: A sequence of DexiValues. While iterating, consecutive values from the sequence
//   are assigned to input attributes. Only "free" input attributes are considered, i.e., those not contained in DexiDynaLinks.
//   If a value sequence is defined for some input attribute, it overrides the initial input value for that attribute.
// - DexiValueSequences: A dictionary of value sequences per attributes, with some convenient helper methods.
// - DexiDynaEvaluator: Dynamic evaluator. Produces a DexiDynaTrace for each evaluated alternative.
// ----------

namespace DexiLibrary;

interface

 uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiDynaLink = public class
  private
    fAttribute: DexiAttribute;
    fDynaLink: DexiAttribute;
    fLag: Integer;
  public
    constructor(aAttribute, aDynaLink: DexiAttribute; aLag: Integer := 0);
    property Attribute: DexiAttribute read fAttribute;
    property DynaLink: DexiAttribute read fDynaLink;
    property Lag: Integer read fLag;
  end;

type
  DexiDynaTrace = public class (DexiAlternatives)
  private
    fTraceEntry: Integer;
    fProbEvaluation: IDexiAlternative;
  private
    method GetTraceCount: Integer;
  public
    constructor (aAlt: IDexiAlternative);
    method ProbEvaluate(aAtts: DexiAttributeList);
    method AsString(aAtts: DexiAttributeList): String;
    property InitialAlternative: IDexiAlternative read Alternative[0];
    property TraceEntry: Integer read fTraceEntry write fTraceEntry;
    property TraceCount: Integer read GetTraceCount;
    property ProbEvaluation: IDexiAlternative read fProbEvaluation;
  end;

type
  BeyondSequence = public enum (Stay, Cycle, NilValue, Undefined);
  DexiValueSequence = public class
  private
    fValues: List<DexiValue>;
    fBeyond: BeyondSequence;
  protected
    method GetValue(aIdx: Integer): DexiValue;
  public
    constructor (aValues: sequence of DexiValue; aBeyond: BeyondSequence := BeyondSequence.Stay);
    constructor (aValues: IntArray; aBeyond: BeyondSequence := BeyondSequence.Stay);
    property Values: List<DexiValue> read fValues write fValues;
    property Count: Integer read if fValues = nil then 0 else fValues.Count;
    property Beyond: BeyondSequence read fBeyond write fBeyond;
    property Value[aIdx: Integer]: DexiValue read GetValue; default;
  end;

type
   DexiValueSequences = public class
   private
      fSequences: Dictionary<DexiAttribute, DexiValueSequence>;
   protected
     method GetCount: Integer;
     method GetMaxLength: Integer;
     method GetValues(aAtt: DexiAttribute): DexiValueSequence;
     method SetValues(aAtt: DexiAttribute; aSeq: DexiValueSequence);
     method GetValue(aAtt: DexiAttribute; aIdx: Integer): DexiValue;
   public
     constructor;
     method AddSequence(aAtt: DexiAttribute; aSeq: DexiValueSequence);
     method DeleteSequence(aAtt: DexiAttribute);
     property Count: Integer read GetCount;
     property MaxLength: Integer read GetMaxLength;
     property Values[aAtt: DexiAttribute]: DexiValueSequence read GetValues write SetValues; default;
     property Value[aAtt: DexiAttribute; aIdx: Integer]: DexiValue read GetValue;
   end;

type
  DexiDynaEvaluator = public class(DexiEvaluator)
  private
    fDynaLinks: List<DexiDynaLink>;
    fMaxLag: Integer;
    fRoot: DexiAttribute;
    fSequences: DexiValueSequences;
    fAttributes: DexiAttributeList;
    fFreeInputs: DexiAttributeList;
    fTrace: DexiDynaTrace;
    fIteration: Integer;
    fMinIterations: Integer;
    fMaxIterations: Integer;
    fMinIterationsThisRun: Integer;
    class var fConverge: Float := 0.0001;
  protected
    method MakeDynaLinks;
    method CollectFreeInputs;
    method Convergent(aAltValue, aPastValue: DexiValue): Boolean; virtual;
    method Convergent(aAlt, aPast: IDexiAlternative): Boolean; virtual;
    method FindTraceEntry(aAlt: DexiAlternative): Integer; virtual;
    method AssignSequenceData(aAlt: IDexiAlternative);
    method NextIteration(aAlt: IDexiAlternative): DexiAlternative;
    method AddTrace(aAlt: DexiAlternative; aForce: Boolean := false): Boolean;
    method DynamicEvaluation;
  public
    class method LagOf(aStr: String): Integer;
    class method CanUseAttribute(aAtt: DexiAttribute): Boolean;
    class property Converge: Float read fConverge write fConverge;
    constructor (aModel: DexiModel);
    method DynaEvaluate(aAlt: IDexiAlternative; aRoot: DexiAttribute := nil; aSeq: DexiValueSequences := nil): DexiDynaTrace;
    property DynaLinks: ImmutableList<DexiDynaLink> read fDynaLinks;
    property DynaLinkCount: Integer read fDynaLinks.Count;
    property MaxLag: Integer read fMaxLag;
    property MinIterations: Integer read fMinIterations write fMinIterations;
    property MaxIterations: Integer read fMaxIterations write fMaxIterations;
   end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiDynaLink}

constructor DexiDynaLink(aAttribute, aDynaLink: DexiAttribute; aLag: Integer := 0);
require
  assigned(aAttribute);
  assigned(aDynaLink);
begin
  fAttribute := aAttribute;
  fDynaLink := aDynaLink;
  fLag := aLag;
end;

{$ENDREGION}

{$REGION DexiDynaTrace}

constructor DexiDynaTrace(aAlt: IDexiAlternative);
require
  assigned(aAlt);
begin
  fTraceEntry := -1;
  AddAlternative(aAlt);
end;

method DexiDynaTrace.GetTraceCount: Integer;
begin
  result :=
    if TraceEntry < 0 then -1
    else AltCount - TraceEntry;
end;

method DexiDynaTrace.AsString(aAtts: DexiAttributeList): String;
begin
  var sb := new StringBuilder;
  for i := 0 to AltCount - 1 do
    begin
      var lAlt := Alternative[i];
      sb.Append($"{lAlt.Name}: ");
      for each lAtt in aAtts do
        sb.Append($" {lAtt.Name}={lAlt[lAtt].AsString}");
      if i = TraceEntry then
        sb.Append(" <==");
      sb.AppendLine;
    end;
  sb.Append("ProbEval: ");
  for each lAtt in aAtts do
    sb.Append($" {lAtt.Name}={ProbEvaluation[lAtt].AsString}");
  sb.AppendLine;
  result := sb.ToString;
end;

method DexiDynaTrace.ProbEvaluate(aAtts: DexiAttributeList);
begin
  fProbEvaluation := nil;
  if fTraceEntry < 0 then
    exit;
  fProbEvaluation := new DexiAlternative(InitialAlternative.Name, InitialAlternative.Description);
  for each lAtt in aAtts do
    if DexiDynaEvaluator.CanUseAttribute(lAtt) then
      begin
        var lCount := 0;
        var lDistr :=  Utils.NewFltArray(lAtt.Scale.Count, 0.0);
        for lAlt := TraceEntry to AltCount - 1 do
          begin
            var lAltValue := Alternative[lAlt][lAtt];
            if DexiValue.ValueIsDefined(lAltValue) then
              begin
                var lAltDistr := lAltValue.AsDistribution;
                Values.NormDistr(var lAltDistr, Normalization.normProb);
                for v := 0 to lAtt.Scale.Count - 1 do
                  lDistr[v] := lDistr[v] + Values.GetDistribution(lAltDistr, v);
                inc(lCount);
              end;
          end;
        Values.NormSum(var lDistr, 1.0);
        fProbEvaluation[lAtt] := new DexiDistribution(0, lDistr);
    end;
end;

{$ENDREGION}

{$REGION DexiValueSequence}

constructor DexiValueSequence(aValues: sequence of DexiValue; aBeyond: BeyondSequence := BeyondSequence.Stay);
begin
  fValues := new List<DexiValue>(aValues);
  fBeyond := aBeyond;
end;

constructor DexiValueSequence(aValues: IntArray; aBeyond: BeyondSequence := BeyondSequence.Stay);
begin
  fValues := new List<DexiValue>;
  for each lInt in aValues do
    fValues.Add(new DexiIntSingle(lInt));
  fBeyond := aBeyond;
end;

method DexiValueSequence.GetValue(aIdx: Integer): DexiValue;
begin
  result :=
    if fValues.Count = 0 then nil
    else if 0 <= aIdx < fValues.Count then fValues[aIdx]
    else
      case fBeyond of
        BeyondSequence.Stay: fValues[fValues.Count - 1];
        BeyondSequence.Cycle: fValues[aIdx mod fValues.Count];
        BeyondSequence.Undefined: new DexiUndefinedValue;
        BeyondSequence.NilValue:  nil;
      end;
end;

{$ENDREGION}

{$REGION DexiValueSequences}

constructor DexiValueSequences;
begin
  inherited constructor;
  fSequences := new Dictionary<DexiAttribute, DexiValueSequence>;
end;

method DexiValueSequences.GetCount: Integer;
begin
  result :=
    if fSequences = nil then 0
    else fSequences.Count;
end;

method DexiValueSequences.GetMaxLength: Integer;
begin
  result := 0;
  if fSequences = nil then
    exit;
  for each lAtt in fSequences.Keys do
    result := Math.Max(result, fSequences[lAtt].Count);
end;

method DexiValueSequences.GetValues(aAtt: DexiAttribute): DexiValueSequence;
require
  aAtt <> nil;
begin
  result := fSequences[aAtt];
end;

method DexiValueSequences.SetValues(aAtt: DexiAttribute; aSeq: DexiValueSequence);
require
  aAtt <> nil;
begin
  if fSequences.ContainsKey(aAtt) then
    if aSeq = nil then
      fSequences.Remove(aAtt)
    else
      fSequences[aAtt] := aSeq
  else if aSeq <> nil then
    fSequences.Add(aAtt, aSeq);
end;

method DexiValueSequences.GetValue(aAtt: DexiAttribute; aIdx: Integer): DexiValue;
begin
  var lValues := Values[aAtt];
  result :=
    if lValues = nil then nil
    else lValues[aIdx];
end;

method DexiValueSequences.AddSequence(aAtt: DexiAttribute; aSeq: DexiValueSequence);
begin
  Values[aAtt] := aSeq;
end;

method DexiValueSequences.DeleteSequence(aAtt: DexiAttribute);
begin
  Values[aAtt] := nil;
end;

{$ENDREGION}

{$REGION DexiDynaEvaluator}

class method DexiDynaEvaluator.LagOf(aStr: String): Integer;
begin
  result := 0;
  var lElements := aStr.ToUpper.Split(';');
  for each lEl in lElements do
    begin
      lEl := lEl.Trim;
      if lEl.StartsWith('LAG=') then
        begin
          var lStr := lEl.Substring(4);
          var lLag := Convert.TryToInt32(lStr);
          if lLag <> nil then
            exit lLag;
        end;
    end;
end;

class method DexiDynaEvaluator.CanUseAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt:Scale <> nil) and not aAtt.Scale.IsContinuous and (aAtt.Scale.Count >= 1);
end;

constructor DexiDynaEvaluator(aModel: DexiModel);
begin
  inherited constructor(aModel);
  fMinIterations := -1;
  fMaxIterations := -1;
  MakeDynaLinks;
  CollectFreeInputs;
end;

method DexiDynaEvaluator.MakeDynaLinks;
begin
  fDynaLinks := new List<DexiDynaLink>;
  var lAtts := Model.Root.CollectInputs(@CanUseAttribute);
  for i1 := 0 to lAtts.Count - 2 do
    for i2 := i1 + 1 to lAtts.Count - 1 do
      begin
        var lName1 := lAtts[i1].Name.ToUpper;
        var lName2 := lAtts[i2].Name.ToUpper;
        if lName1.StartsWith('*') and lName2.StartsWith('*') and (lName1 = lName2) then
            raise new EDexiEvaluationError(String.Format(DexiString.SDexiDynSource), [lName1]);
      end;
  for each lOut in lAtts do
    if lOut.IsAggregate and lOut.Name.StartsWith('*') and (lOut.Scale <> nil) and not lOut.Scale.IsContinuous then
      begin
        var lInpName := '_' + lOut.Name.Substring(1);
        for each lInp in lAtts do
          if lInp.IsBasicNonLinked and (lInp.Name = lInpName) then
            begin
              if lInp.Scale.Count <> lOut.Scale.Count then
                raise new EDexiEvaluationError(String.Format(DexiString.SDexiDynIncompatible), [lInp.Name, lOut.Name]);
              fDynaLinks.Add(new DexiDynaLink(lOut, lInp, LagOf(lInp.Description)));
            end;
      end;
  fMaxLag := 0;
  for each lDynaLink in fDynaLinks do
    if lDynaLink.Lag > fMaxLag then
      fMaxLag := lDynaLink.Lag;
end;

method DexiDynaEvaluator.CollectFreeInputs;

  method RemoveDynamic(aAtt: DexiAttribute);
  begin
    if fFreeInputs.Contains(aAtt) then
      fFreeInputs.Remove(aAtt);
  end;

begin
  fFreeInputs := Model.Root.CollectBasicNonLinked;
  for each lDynaLink in fDynaLinks do
    begin
      RemoveDynamic(lDynaLink.Attribute);
      RemoveDynamic(lDynaLink.DynaLink);
    end;
end;

method DexiDynaEvaluator.Convergent(aAltValue, aPastValue: DexiValue): Boolean;
begin
  result := true;
  if not(DexiValue.ValueIsDefined(aAltValue) and DexiValue.ValueIsDefined(aPastValue)) then
    exit;
  result :=
    if aAltValue.IsDistribution or aPastValue.IsDistribution then
      Values.DistrEq(aAltValue.AsDistribution, aPastValue.AsDistribution, Converge)
    else
      DexiValue.ValuesAreEqual(aAltValue, aPastValue);
end;

method DexiDynaEvaluator.Convergent(aAlt, aPast: IDexiAlternative): Boolean;
begin
  result := true;
  for each lAtt in fAttributes do
    if not Convergent(aAlt[lAtt], aPast[lAtt]) then
      exit false;
end;

method DexiDynaEvaluator.FindTraceEntry(aAlt: DexiAlternative): Integer;
begin
  result := -1;
  for t := fTrace.AltCount - 1 downto 0 do
    if Convergent(aAlt, fTrace.Alternative[t]) then
      exit t;
end;

method DexiDynaEvaluator.AddTrace(aAlt: DexiAlternative; aForce: Boolean := false): Boolean;
require
  fTrace.TraceEntry < 0;
begin
  result := true;
  if aForce then
    fTrace.AddAlternative(aAlt)
  else
    begin
      var t := FindTraceEntry(aAlt);
      if t >= 0 then
        begin
          fTrace.TraceEntry := t;
          exit false;
        end
      else
        fTrace.AddAlternative(aAlt);
    end;
  end;

method DexiDynaEvaluator.AssignSequenceData(aAlt: IDexiAlternative);
begin
  if fSequences = nil then
    exit;
  for each lFree in fFreeInputs do
    if fSequences[lFree] <> nil then
      aAlt[lFree] := fSequences[lFree][fIteration];
end;

method DexiDynaEvaluator.NextIteration(aAlt: IDexiAlternative): DexiAlternative;
begin
  inc(fIteration);
  result := aAlt.Copy;
  AssignSequenceData(result);
  result.Name := $"{fTrace.InitialAlternative.Name}[{fTrace.AltCount}]";
  for each lDynaLink in fDynaLinks do
    begin
      var lLagIdx := fTrace.AltCount - 1 - lDynaLink.Lag;
      if lLagIdx >= 0 then
        begin
          var lPrevAlt := fTrace.Alternative[lLagIdx];
          var lValue := lPrevAlt[lDynaLink.Attribute];
          result[lDynaLink.DynaLink] := DexiValue.CopyValue(lValue);
        end;
    end;
end;

method DexiDynaEvaluator.DynamicEvaluation;
var lStopMax, lContMin, lContLag: Boolean;
begin
  var lNext: DexiAlternative;
  repeat
    var lPrev := fTrace.Alternative[fTrace.AltCount - 1];
    lNext := NextIteration(lPrev);
    Evaluate(lNext, fRoot);
    lStopMax := (fMaxIterations > 0) and (fIteration >= fMaxIterations);
    lContMin := (fMinIterationsThisRun > 0) and (fIteration <= fMinIterationsThisRun);
    lContLag := (MaxLag >= fTrace.AltCount);
  until not AddTrace(lNext, lContLag or lContMin or lStopMax) or lStopMax;
end;

method DexiDynaEvaluator.DynaEvaluate(aAlt: IDexiAlternative; aRoot: DexiAttribute := nil; aSeq: DexiValueSequences := nil): DexiDynaTrace;
require
  assigned(aAlt);
begin
  fRoot := aRoot;
  if fRoot = nil then
    fRoot := Model.Root;
  fSequences := aSeq;
  fIteration := 0;
  fMinIterationsThisRun :=
    if (fMinIterations < 0) and (fSequences <> nil) then fSequences.MaxLength
    else fMinIterations;
  fAttributes := fRoot.CollectInputs(fRoot <> Model.Root, @CanUseAttribute);
  AssignSequenceData(aAlt);
  fTrace := new DexiDynaTrace(aAlt);
  Evaluate(fTrace, aRoot);
  DynamicEvaluation;
  fTrace.ProbEvaluate(fAttributes);
  result := fTrace;
end;

{$ENDREGION}

end.
