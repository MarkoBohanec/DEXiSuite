// DexiFunctions.pas is part of
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
// DexiFunctions.pas implements the abstract class DexiFunction and its non-abstrac descendants:
// DexiTabularFunction and DexiDiscretizeFunction. Both types serve for the aggregation of
// some attribute children's values to the value of that attribute, that is, a one-level evaluation
// in the context of a single aggregate attribute.
//
// - DexiTabularFunction is the common DEXi that aggregates the values of multiple discrete
//   attributes (function arguments) to the value of parent discrete attribute (output).
//   The function is defined in terms of "elementary decision rules": each rule defines the output
//   for some combination of input attributes' category values. Collectively, a DexiTabularFunction
//   contains deciusion rules for all possible combinations of input values, and evaluation is
//   carried out in terms of table lookup.
// - DexiDiscretizeFunction is a less typical function introduced in DEXiLibrary 2023. It is aimed
//   at discretizing a Float value of a single basic attribute to the qualitative value of the
//   parent attributes. A DexiDiscretizeFunction consists of a series of intervals (bounded by
//   DexiBounds) and output values associated with each interval.
// ----------

namespace DexiLibrary;

{$HIDE W28} // obsolete methods

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiFunctionType = public enum (Tabular, Discretize);

type
  RuleValue = public record
    Low, High: Integer;
    Entered: Boolean;
    method EqualTo(aRuleValue: RuleValue): Boolean;
  end;

type
  RuleArray1 = public array of RuleValue;
  RuleArray2 = public array of array of RuleValue;

{ DexiRule }

type
  DexiRule = public class
  private
    fArgs: IntArray;
    fValue: DexiValue;
    fEntered: Boolean;
  protected
    method GetIsDefined: Boolean;
    method SetInt(aInt: Integer);
    method GetLowInt: Integer;
    method SetLowInt(aInt: Integer); deprecated;
    method GetHighInt: Integer;
    method SetHighInt(aInt: Integer); deprecated;
  public
    constructor (aArgs: IntArray; aEntered: Boolean := false);
    constructor (aArgs: IntArray; aInt: Integer; aEntered: Boolean := false);
    constructor (aArgs: IntArray; aLow, aHigh: Integer; aEntered: Boolean := false);
    constructor (aArgs: IntArray; aValue: DexiValue; aEntered: Boolean := false);
    method &Copy: DexiRule;
    method AssignRule(aRule: DexiRule);
    method EqualTo(aRule: DexiRule): Boolean;
    method GetText: String; // for compatibility with pre-DexiLibrary models
    property Args: IntArray read Utils.CopyIntArray(fArgs);
    property ArgCount: Integer read length(fArgs);
    property Arg[aIdx: Integer]: Integer read fArgs[aIdx] write fArgs[aIdx];
    property Value: DexiValue read fValue write fValue;
    property IsDefined: Boolean read GetIsDefined;
    property Int: Integer write SetInt;
    property LowInt: Integer read GetLowInt write SetLowInt;
    property HighInt: Integer read GetHighInt write SetHighInt;
    property Entered: Boolean read fEntered write fEntered;
    property Text: String read GetText;
  end;

type
  DexiComplexRule = public class
  private
    fLow: IntArray;
    fHigh: IntArray;
  protected
    method GetAsString: String;
  public
    class method ToString(aLow, aHigh: IntArray): String;
    class method Compare(r1, r2: DexiComplexRule): Integer;
    constructor (aLow, aHigh: IntArray);
    property Low: IntArray read fLow write fLow;
    property High: IntArray read fHigh write fHigh;
    property AsString: String read GetAsString;
  end;

type
  DexiFunction = public abstract class (DexiObject)
  protected
    fAttribute: weak DexiAttribute;
    method SetAttribute(aAtt: DexiAttribute); virtual;
    method GetCount: Integer; virtual;
    method GetArgCount: Integer; virtual;
    method GetOutValCount: Integer;
    method GetArgValCount(aArg: Integer): Integer;
    method GetDefined: Float; virtual;
    method GetDetermined: Float; virtual;
    method GetFunctString: String; virtual;
    method GetFunctStatus: String; virtual;
    method GetFunctClassDistr: String; virtual;
    method GetClassCount(aClass: Integer): Integer; virtual; abstract;
    method GetItemRatio: String; virtual; abstract;
  public
    class method CanCreateOn(aAtt: DexiAttribute): Boolean; virtual; abstract;
    class method CanCreateAnyFunctionOn(aAtt: DexiAttribute): Boolean;
    class method CreateOn(aAtt: DexiAttribute): DexiFunction;
    constructor (aAtt: DexiAttribute := nil);
    method UsesDexiLibraryFeatures: Boolean; virtual;
    method CanSetAttribute(aAtt: DexiAttribute): Boolean; virtual;
    method Clear; virtual; empty;
    method CopyFunction: InstanceType; virtual; abstract;
    method CanAssignFunction(aFnc: DexiFunction): Boolean; virtual;
    method AssignFunction(aFnc: DexiFunction); virtual;
    method CanUseDominance: Boolean; virtual;
    method CanUseWeights: Boolean; virtual;
    method CanUseMultilinear: Boolean; virtual;
    method CompareValuesMethod(aValue1, aValue2: DexiValue): DexiValueMethod; virtual;
    method CompareValues(aValue1, aValue2: DexiValue): PrefCompare; virtual;
    method IsConsistent: Boolean; virtual; abstract;
    method IsActuallyMonotone: Boolean; virtual; abstract;
    method ArgIsSymmetricWith(aArg1, aArg2: Integer): Boolean; virtual; abstract;
    method ArgIsSymmetric(aArg: Integer): Boolean; virtual; abstract;
    method ArgSymmetricity(aArg: Integer): Float; virtual; abstract;
    method IsSymmetric: Boolean; virtual; abstract;
    method ArgActualOrder(aArg: Integer): ActualScaleOrder; virtual; abstract;
    method ArgAffects(aArg: Integer): Boolean; virtual; abstract;
    method Evaluation(aArgVal: List<String>): String; deprecated; virtual; abstract;
    method Evaluate(aArgs: IntArray): DexiValue; virtual; abstract;
    method Evaluate(aArgs: FltArray): DexiValue; virtual; abstract;
    method ExchangeArgs(aArg1, aArg2: Integer); virtual; empty;
    method ReverseClass; virtual; abstract;
    method ReviseFunction(aAutomation: Boolean := true); virtual; abstract;
    method SaveToStringList(aSettings: DexiSettings): List<String>; virtual; abstract;
    method SaveToFile(aFileName: String; aSettings: DexiSettings); virtual;
    method LoadFromStringList(aList: ImmutableList<String>; aSettings: DexiSettings; out aLoaded, aChanged: Integer); virtual; abstract;
    method LoadFromFile(aFileName: String; aSettings: DexiSettings; out aLoaded, aChanged: Integer); virtual;
    property Attribute: DexiAttribute read fAttribute write SetAttribute;
    property ArgAttribute[aIdx: Integer]: DexiAttribute read fAttribute:Inputs[aIdx];
    property Count: Integer read GetCount;
    property ArgCount: Integer read GetArgCount;
    property OutValCount: Integer read GetOutValCount;
    property ArgValCount[aArg: Integer]: Integer read GetArgValCount;
    property Defined: Float read GetDefined;
    property Determined: Float read GetDetermined;
    property FunctString: String read GetFunctString;
    property FunctStatus: String read GetFunctStatus;
    property FunctClassDistr: String read GetFunctClassDistr;
    property ClassCount[aClass: Integer]: Integer read GetClassCount;
    property ItemRatio: String read GetItemRatio;

    // IUndoable
    method GetUndoState: IUndoable; override;
    method SetUndoState(aState: IUndoable); override;
  end;

type
  DexiSymmetricityStatus = public class
  public
    ArgsCountCompatible: Boolean;
    ArgsOrderCompatible: Boolean;
    Asymmetric: List<IntPair>;
    CanEnforce: List<IntPair>;
    property ArgsCompatible: Boolean read ArgsCountCompatible and ArgsOrderCompatible;
  end;

type
  DexiTabularFunction = public class(DexiFunction)
  private
    fRules: List<DexiRule>;
    fVectors: Vectors;
    fUseWeights: Boolean;
    fUseConsist: Boolean;
    fRounding: Integer;
    fFunctK: Float;
    fFunctN: Float;
    fKNState: Integer;
    fCstState: Integer;
    fRecalcWeights: Boolean;
    fRequiredWeights: FltArray;
    fWeightFactors: FltArray;
    fActualWeights: FltArray;
    fNormActualWeights: FltArray;
    class const RuleVals = '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  protected
    method CreateDecisionTable;
    method SetAttribute(aAtt: DexiAttribute); override;
    method GetCount: Integer; override;
    method GetEntCount: Integer;
    method GetDefCount: Integer;
    method GetEntDefCount: Integer;
    method GetClassCount(aClass: Integer): Integer; override;
    method GetItemRatio: String; override;
    method GetArgVal(aArg, aRule: Integer): Integer;
    method SetArgVal(aArg, aRule, aVal: Integer);
    method GetArgValues(aRule: Integer): IntArray;
    method GetRuleValue(aRule: Integer): DexiValue;
    method SetRuleValue(aRule: Integer; aValue: DexiValue);
    method GetRuleValLow(aRule: Integer): Integer;
    method SetRuleValLow(aRule, aVal: Integer);
    method GetRuleValHigh(aRule: Integer): Integer;
    method SetRuleValHigh(aRule, aVal: Integer);
    method SetRuleVal(aRule, aVal: Integer);
    method SetRuleVal(aRule, aLow, aHigh: Integer);
    method GetRuleEntered(aRule: Integer): Boolean;
    method SetRuleEntered(aRule: Integer; aEnt: Boolean);
    method GetRuleEnteredDefined(aRule: Integer): Boolean;
    method SetUseConsist(aUseConsist: Boolean);
    method GetRuleDefined(aRule: Integer): Boolean;
    method GetDefined: Float; override;
    method GetDetermined: Float; override;
    method GetFunctString: String; override;
    method GetFunctStatus: String; override;
    method GetAsRuleString: String;
    method SetDexOrder(aOrder: Boolean);
    method SortRules;
    method RuleMatch(aRule: Integer; aProj: String): Boolean;  deprecated;
    method RuleMatch(aRule: Integer; aMatch: IntArray): Boolean;
    method SymComparable(lArg1, lArg2, lRule1, lRule2: Integer): Boolean;
  public
    class const SpaceSizeLimit = 10000;
    class method CanCreateOn(aAtt: DexiAttribute): Boolean; override;
    class method ExtToIntVal(aExtCh: Char): Integer;
    class method IntToExtVal(aIntVal: Integer): String;
    method UsesDexiLibraryFeatures: Boolean; override;
    constructor (aAtt: DexiAttribute := nil);
    method CanSetAttribute(aAtt: DexiAttribute): Boolean; override;
    method Clear; override;
    method ClearValue(aRule: Integer);
    method ClearValues;
    method UndefineValue(aRule: Integer);
    method ClearNonEnteredValues;
    method AffectsWeights;
    method CopyFunction: InstanceType; override;
    method CanAssignFunction(aFnc: DexiFunction): Boolean; override;
    method AssignFunction(aFnc: DexiFunction); override;
    method CanUseDominance: Boolean; override;
    method CanUseWeights: Boolean; override;
    method CanUseMultilinear: Boolean; override;
    method UpdateValues;
    method UpdateWeightedRounded;
    method UpdateWeightedRounded(aExistingBounds: Boolean);
    method UpdateFunction(aFreeze: Boolean := false); deprecated;
    method ReviseFunction(aAutomation: Boolean := true); override;
    method IndexOfRule(aRule: IntArray): Integer;
    method IndexOfRule(aRule: String): Integer; deprecated;
    method CompareRules(aRule1, aRule2: Integer): PrefCompare;
    method CompareArgValues(aArg, aRule1, aRule2: Integer): PrefCompare;
    method CompareRuleValues(aRule1, aRule2: Integer): PrefCompare;
    method RuleIsConsistentWith(aRule1, aRule2: Integer): Boolean;
    method RuleIsConsistent(aRule: Integer): Boolean;
    method IsConsistent: Boolean; override;
    method RuleInconsistentWith(aRule: Integer): IntArray;
    method CountInconsistentRules: Integer;
    method IsActuallyMonotone: Boolean; override;
    method ArgIsSymmetricWith(aArg1, aArg2: Integer): Boolean; override;
    method ArgIsSymmetric(aArg: Integer): Boolean; override;
    method ArgSymmetricity(aArg: Integer): Float; override;
    method IsSymmetric: Boolean; override;
    method AsymmetricPairs(aArg1, aArg2: Integer): List<IntPair>;
    method CanEnforceSymmetricity(aArg1, aArg2: Integer): List<IntPair>;
    method SymmetricityStatus(aArg1, aArg2: Integer): DexiSymmetricityStatus;
    method ArgActualOrder(aArg: Integer): ActualScaleOrder; override;
    method ArgAffects(aArg: Integer): Boolean; override;
    method ArgValuePairEqual(aArg, aVal1, aVal2: Integer): Boolean;
    method Evaluation(aArgVal: List<String>): String; override;
    method Evaluate(aArgs: IntArray): DexiValue; override;
    method Evaluate(aArgs: FltArray): DexiValue; override;
    method CalcActualWeights(aAll: Boolean);
    method CalcWeightKN(aAll: Boolean);
    method WeightedRequired(aRule: Integer): Float;
    method WeightedRounded(aRule: Integer): Integer;
    method WeightedActual(aRule: Integer): Float;
    method LinCount(aAll, aStrict: Boolean): Integer;
    method LinDistance(aAll: Boolean): Float;
    method RuleClassProb(aRule, aClass: Integer): Float;
    method ClassProb(aAll: Boolean): FltArray;
    method ClassProbWhere(aAll: Boolean; aArg, aVal: Integer): FltArray;
    method ClassProb(aRules: IntArray): FltArray;
    method CountWhere(aAll: Boolean): Integer;
    method CountWhere(aAll: Boolean; aArg, aVal: Integer): Integer;
    method SplitSizes(aAll: Boolean; aArg: Integer): IntArray;
    method SplitInformation(aAll: Boolean; aArg: Integer): Float;
    method WeightsByGain(aAll: Boolean; aImpurity: ImpurityFunction): FltArray;
    method GiniGain(aAll: Boolean): FltArray;
    method InformationGain(aAll: Boolean): FltArray;
    method GainRatio(aAll: Boolean): FltArray;
    method ChiSquare(aAll: Boolean): FltArray;
    method InsertArgValue(aArg, aVal: Integer);
    method DeleteArgValue(aArg, aVal: Integer);
    method DuplicateArgValue(aArg, aVal: Integer);
    method ExchangeArgs(aArg1, aArg2: Integer); override;
    method ReverseAttr(aIdx: Integer);
    method InsertFunctionValue(aVal: Integer);
    method DeleteFunctionValue(aVal: Integer);
    method DuplicateFunctionValue(aVal: Integer);
    method ReverseClass; override;
    method SetAllEntered(aEntered: Boolean := true);
    method SetRulesEntered(aAll: Boolean);
    method SaveToStringList(aSettings: DexiSettings): List<String>; override;
    method LoadFromStringList(aList: ImmutableList<String>; aSettings: DexiSettings; out aLoaded, aChanged: Integer); override;
    method SetAsRuleString(aStr: String; aForce: Boolean := false): Integer;
    method ProjSum(aIdx: Integer; aAll: Boolean := true): RuleArray1; deprecated;
    method Projection1(aProj: String): RuleArray1; deprecated;
    method Projection2(aProj: String): RuleArray2; deprecated;
    method Projection1(aMatch: IntArray): IntArray;
    method Projection2(aMatch: IntArray): IntMatrix;
    method FunctionStatusReport(aRpt: List<String>); deprecated;
    method FunctionStatusReport: List<String>;
    method ComplexRules(aVal: Integer; aRules: List<String>; fSettings: DexiSettings); deprecated;
    method ComplexRules(aVal: Integer; fAll: Boolean): List<DexiComplexRule>;
    method SelectRules(aCondition: Predicate<Integer> := nil): IntArray;
    method SelectRules(aAll: Boolean): IntArray;
    method SelectRules(aAll: Boolean; aArg, aVal: Integer): IntArray;
    method SelectRules(aAll: Boolean; aArg: Integer; aVals: IntArray): IntArray;
    method SelectRules(aAll: Boolean; aArgs, aArgVals: IntArray; aClass: Integer): IntArray;
    method SelectRulesFrom(aRules: IntArray; aCondition: Predicate<Integer> := nil): IntArray;
    method SelectRulesFrom(aRules: IntArray; aArg, aVal: Integer): IntArray;
    method SelectRulesFrom(aRules: IntArray; aArg: Integer; aVals: IntArray): IntArray;
    method ValuesEqual(aRules: IntArray): Boolean;
    method Marginals(aNorm: Boolean := false): FltMatrix;
    property EntCount: Integer read GetEntCount;
    property DefCount: Integer read GetDefCount;
    property EntDefCount: Integer read GetEntDefCount;
    property ArgVal[aArg, aRule: Integer]: Integer read GetArgVal;
    property ArgValues[aRule: Integer]: IntArray read GetArgValues;
    property RuleValue[aRule: Integer]: DexiValue read GetRuleValue write SetRuleValue;
    property RuleValLow[aRule: Integer]: Integer read GetRuleValLow write SetRuleValLow;
    property RuleValHigh[aRule: Integer]: Integer read GetRuleValHigh write SetRuleValHigh;
    property RuleVal[aRule: Integer]: Integer write SetRuleVal;
    property RuleEntered[aRule: Integer]: Boolean read GetRuleEntered write SetRuleEntered;
    property RuleDefined[aRule: Integer]: Boolean read GetRuleDefined;
    property RuleEnteredDefined[aRule: Integer]: Boolean read GetRuleEnteredDefined;
    property Rules: ImmutableList<DexiRule> read fRules;
    property UseWeights: Boolean read fUseWeights write fUseWeights;
    property UseConsist: Boolean read fUseConsist write SetUseConsist;
    property Rounding: Integer read fRounding write fRounding;
    property KNState: Integer read fKNState;
    property CstState: Integer read fCstState;
    property RequiredWeights: FltArray read fRequiredWeights write fRequiredWeights;
    property WeightFactors: FltArray read fWeightFactors write fWeightFactors;
    property ActualWeights: FltArray read fActualWeights write fActualWeights;
    property NormActualWeights: FltArray read fNormActualWeights write fNormActualWeights;
    property AsRuleString: String read GetAsRuleString;

    // IUndoable
    method EqualStateAs(aObj: IUndoable): Boolean; override;
  end;

type
  DexiBoundAssociation = public enum (Down, Up);

type
  DexiBound = public class(DexiObject)
  private
    fBound: Float;
    fAssociation: DexiBoundAssociation;
  protected
  public
    constructor (aBound: Float; aAssociation: DexiBoundAssociation := DexiBoundAssociation.Down);
    method &Copy: DexiBound;
    method EqualTo(aBound: DexiBound): Boolean;
    property Bound: Float read fBound write fBound;
    property Association: DexiBoundAssociation read fAssociation write fAssociation;
  end;

type
  DexiValueCell = public class
  private
    fValue: DexiValue;
    fEntered: Boolean;
  protected
    method GetIsDefined: Boolean;
    method SetInt(aInt: Integer);
  public
    constructor (aEntered: Boolean := false);
    constructor (aInt: Integer; aEntered: Boolean := false);
    constructor (aLow, aHigh: Integer; aEntered: Boolean := false);
    constructor (aValue: DexiValue; aEntered: Boolean := false);
    method &Copy: DexiValueCell;
    method AssignCell(aCell: DexiValueCell);
    method EqualTo(aCell: DexiValueCell): Boolean;
    property Value: DexiValue read fValue write fValue;
    property IsDefined: Boolean read GetIsDefined;
    property Int: Integer write SetInt;
    property Entered: Boolean read fEntered write fEntered;
  end;

type
  DexiDiscretizeFunction = public class (DexiFunction)
  private
    fBounds: List<DexiBound>;
    fIntervals: List<DexiValueCell>;
    fUseConsist: Boolean;
    fCstState: Integer;
  protected
    method SetAttribute(aAtt: DexiAttribute); override;
    method GetCount: Integer; override;
    method GetEntCount: Integer;
    method GetDefCount: Integer;
    method GetEntDefCount: Integer;
    method GetClassCount(aClass: Integer): Integer; override;
    method GetItemRatio: String; override;
    method GetDefined: Float; override;
    method GetDetermined: Float; override;
    method GetBoundCount: Integer;
    method GetBound(aIdx: Integer): DexiBound;
    method GetBoundValue(aIdx: Integer): Float;
    method GetIntervalCount: Integer;
    method GetValueCell(aIdx: Integer): DexiValueCell;
    method SetValueCell(aIdx: Integer; aCell: DexiValueCell);
    method GetIntervalLowBoundIndex(aIdx: Integer): Integer;
    method GetIntervalHighBoundIndex(aIdx: Integer): Integer;
    method GetIntervalLowBound(aIdx: Integer): DexiBound;
    method GetIntervalHighBound(aIdx: Integer): DexiBound;
    method GetIntervalValue(aIdx: Integer): DexiValue;
    method SetIntervalValue(aIdx: Integer; aValue: DexiValue);
    method GetIntervalValLow(aIdx: Integer): Integer;
    method GetIntervalValHigh(aIdx: Integer): Integer;
    method GetIntervalDefined(aIdx: Integer): Boolean;
    method GetIntervalEntered(aIdx: Integer): Boolean;
    method GetIntervalEnteredDefined(aIdx: Integer): Boolean;
    method SetIntervalEntered(aIdx: Integer; aEntered: Boolean);
    method SetUseConsist(aUseConsist: Boolean);
    method GetFunctString: String; override;
    method GetFunctStatus: String; override;
  public
    class method CanCreateOn(aAtt: DexiAttribute): Boolean; override;
    constructor (aAtt: DexiAttribute := nil);
    method CanSetAttribute(aAtt: DexiAttribute): Boolean; override;
    method ClearIntervals;
    method AdaptIntervalsToInputScale;
    method Clear; override;
    method ClearCell(aIdx: Integer);
    method ClearNonEnteredValues;
    method UpdateValues;
    method UpdateFunction; deprecated;
    method ReviseFunction(aAutomation: Boolean := true); override;
    method UndefineInterval(aIdx: Integer);
    method SetIntervalVal(aIdx, aVal: Integer; aEntered: Boolean := true);
    method SetIntervalVal(aIdx, aLow, aHigh: Integer; aEntered: Boolean := true);
    method SetIntervalValue(aIdx: Integer; aValue: DexiValue; aEntered: Boolean := true);
    method CopyFunction: InstanceType; override;
    method CanAssignFunction(aFnc: DexiFunction): Boolean; override;
    method AssignFunction(aFnc: DexiFunction); override;
    method CompareIntervals(aIdx1, aIdx2: Integer): PrefCompare;
    method IntervalIsConsistentWith(aIdx1, aIdx2: Integer): Boolean;
    method IntervalIsConsistent(aIdx: Integer): Boolean;
    method IntervalInconsistentWith(aIdx: Integer): IntArray;
    method IsConsistent: Boolean; override;
    method ActualOrder: ActualScaleOrder;
    method IsActuallyMonotone: Boolean; override;
    method ArgIsSymmetricWith(aArg1, aArg2: Integer): Boolean; override;
    method ArgIsSymmetric(aArg: Integer): Boolean; override;
    method ArgSymmetricity(aArg: Integer): Float; override;
    method IsSymmetric: Boolean;  override;
    method ArgActualOrder(aArg: Integer): ActualScaleOrder;  override;
    method ArgAffects(aArg: Integer): Boolean;  override;
    method InInterval(aIdx: Integer; aArgValue: Float): Boolean;
    method JoinValues(aValue1, aValue2: DexiValue): DexiValue;
    method CanAddBound(aBound: Float): Boolean;
    method AddBound(aBound: Float; aAssociation: DexiBoundAssociation := DexiBoundAssociation.Down): Integer;
    method AddBound(aBound: DexiBound): Integer;
    method CanDeleteBound(aIdx: Integer): Boolean;
    method RemoveBound(aIdx: Integer): DexiBound;
    method DeleteBound(aIdx: Integer);
    method CanChangeBound(aIdx: Integer; aBound: Float): Boolean;
    method ChangeBound(aIdx: Integer; aBound: Float; aAssoc: DexiBoundAssociation): Integer;
    method ChangeBound(aIdx: Integer; aBound: Float): Integer;
    method ReverseClass; override;
    method SetAllEntered(aEntered: Boolean := true);
    method SetIntervalsEntered(aAll: Boolean);
    method FunctionValue(aArgValue: Float): DexiValue;
    method Evaluation(aArgVal: List<String>): String; deprecated; override;
    method Evaluate(aArgs: IntArray): DexiValue;  override;
    method Evaluate(aArgs: FltArray): DexiValue;  override;
    method SaveToStringList(aSettings: DexiSettings): List<String>; override;
    method LoadFromStringList(aList: ImmutableList<String>; aSettings: DexiSettings; out aLoaded, aChanged: Integer); override;
    property BoundCount: Integer read GetBoundCount;
    property Bound[aIdx: Integer]: DexiBound read GetBound;
    property BoundValue[aIdx: Integer]: Float read GetBoundValue;
    property ValueCell[aIdx: Integer]: DexiValueCell read GetValueCell write SetValueCell;
    property IntervalCount: Integer read GetIntervalCount;
    property EntCount: Integer read GetEntCount;
    property DefCount: Integer read GetDefCount;
    property EntDefCount: Integer read GetEntDefCount;
    property IntervalLowBoundIndex[aIdx: Integer]: Integer read GetIntervalLowBoundIndex;
    property IntervalHighBoundIndex[aIdx: Integer]: Integer read GetIntervalHighBoundIndex;
    property IntervalLowBound[aIdx: Integer]: DexiBound read GetIntervalLowBound;
    property IntervalHighBound[aIdx: Integer]: DexiBound read GetIntervalHighBound;
    property IntervalValue[aIdx: Integer]: DexiValue read GetIntervalValue write SetIntervalValue;
    property IntervalValLow[aIdx: Integer]: Integer read GetIntervalValLow;
    property IntervalValHigh[aIdx: Integer]: Integer read GetIntervalValHigh;
    property IntervalDefined[aIdx: Integer]: Boolean read GetIntervalDefined;
    property IntervalEntered[aIdx: Integer]: Boolean read GetIntervalEntered write SetIntervalEntered;
    property IntervalEnteredDefined[aIdx: Integer]: Boolean read GetIntervalEnteredDefined;
    property UseConsist: Boolean read fUseConsist write SetUseConsist;
    property CstState: Integer read fCstState;

    // IUndoable
    method EqualStateAs(aObj: IUndoable): Boolean; override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION RuleValue}

method RuleValue.EqualTo(aRuleValue: RuleValue): Boolean;
begin
  result := (Low = aRuleValue.Low) and (High = aRuleValue.High) and (Entered = aRuleValue.Entered);
end;

{$ENDREGION}

{$REGION DexiRule}

constructor DexiRule(aArgs: IntArray; aEntered: Boolean := false);
begin
  fArgs := Utils.CopyIntArray(aArgs);
  fValue := nil;
  fEntered := aEntered;
end;

constructor DexiRule(aArgs: IntArray; aInt: Integer; aEntered: Boolean := false);
begin
  constructor (aArgs, aEntered);
  fValue := new DexiIntSingle(aInt);
end;

constructor DexiRule(aArgs: IntArray; aLow, aHigh: Integer; aEntered: Boolean := false);
begin
  constructor (aArgs);
  fValue := new DexiIntInterval(aLow, aHigh);
  fValue.Normalize;
end;

constructor DexiRule(aArgs: IntArray; aValue: DexiValue; aEntered: Boolean := false);
begin
  constructor (aArgs);
  Value := aValue;
end;

method DexiRule.GetIsDefined: Boolean;
begin
  result :=
    if fValue = nil then false
    else fValue.IsDefined;
end;

method DexiRule.SetInt(aInt: Integer);
begin
  if (fValue = nil) or not (fValue.IsInteger or fValue.IsInterval) then
    fValue := new DexiIntSingle(aInt);
  fValue.AsInteger := aInt;
end;

method DexiRule.GetLowInt: Integer;
begin
  result :=
    if fValue = nil then low(Integer)
    else fValue.LowInt;
end;

method DexiRule.SetLowInt(aInt: Integer);
begin
  if not DexiValue.ValueIsDefined(fValue) or fValue.IsInteger then
    fValue := new DexiIntInterval(aInt);
  fValue.AsIntInterval := Values.IntInt(aInt, fValue.HighInt);
  fValue.Normalize;
end;

method DexiRule.GetHighInt: Integer;
begin
  result :=
    if fValue = nil then high(Integer)
    else fValue.HighInt;
end;

method DexiRule.SetHighInt(aInt: Integer);
begin
  if (fValue = nil) or fValue.IsSingle then
    fValue := new DexiIntInterval(aInt);
  fValue.AsIntInterval := Values.IntInt(fValue.LowInt, aInt);
  fValue.Normalize;
end;

method DexiRule.Copy: DexiRule;
begin
  result := new DexiRule(fArgs, fEntered);
  result.fValue := DexiValue.CopyValue(fValue);
end;

method DexiRule.AssignRule(aRule: DexiRule);
begin
  fArgs := Utils.CopyIntArray(aRule.fArgs);
  fEntered := aRule.Entered;
  fValue := DexiValue.CopyValue(aRule.fValue);
end;

method DexiRule.EqualTo(aRule: DexiRule): Boolean;
begin
  if aRule = nil then
    exit false;
  result :=
    Utils.IntArrayEq(fArgs, aRule.Args) and
    (fEntered = aRule.Entered) and
    DexiValue.ValuesAreEqual(fValue, aRule.Value);
end;

method DexiRule.GetText: String;
begin
  var lChars := new Char[ArgCount];
  for i := 0 to ArgCount - 1 do
    lChars[i] := chr(fArgs[i] + ord('0'));
  result := new String(lChars);
end;

{$ENDREGION}

{$REGION DexiComplexRule }

class method DexiComplexRule.ToString(aLow, aHigh: IntArray): String;
begin
  result := Utils.IntArrayToStr(aLow) + ':' + Utils.IntArrayToStr(aHigh);
end;

class method DexiComplexRule.Compare(r1, r2: DexiComplexRule): Integer;
require
  length(r1.Low) = length(r1.High);
  length(r1.Low) = length(r2.Low);
  length(r1.High) = length(r2.High);
begin
  result := 0;
  for i := low(r1.Low) to high(r1.Low) do
    begin
      var lDet1 := Math.Abs(r1.High[i] - r1.Low[i]);
      var lDet2 := Math.Abs(r2.High[i] - r2.Low[i]);
      result := Utils.Compare(lDet1, lDet2);
      if result <> 0 then
        exit;
    end;
  result := Utils.Compare(r1.Low, r2.Low);
end;

constructor DexiComplexRule(aLow, aHigh: IntArray);
begin
  fLow := Utils.CopyIntArray(aLow);
  fHigh := Utils.CopyIntArray(aHigh);
end;

method DexiComplexRule.GetAsString: String;
begin
  result := ToString(fLow, fHigh);
end;

{$ENDREGION}

{$REGION DexiFunction }

class method DexiFunction.CanCreateAnyFunctionOn(aAtt: DexiAttribute): Boolean;
begin
  result := DexiTabularFunction.CanCreateOn(aAtt) or DexiDiscretizeFunction.CanCreateOn(aAtt);
end;

class method DexiFunction.CreateOn(aAtt: DexiAttribute): DexiFunction;
begin
  result :=
    if DexiTabularFunction.CanCreateOn(aAtt) then
      new DexiTabularFunction(aAtt)
    else if DexiDiscretizeFunction.CanCreateOn(aAtt) then
      new DexiDiscretizeFunction(aAtt)
    else nil;
end;

constructor DexiFunction(aAtt: DexiAttribute := nil);
begin
  Attribute := aAtt;
end;

method DexiFunction.UsesDexiLibraryFeatures: Boolean;
begin
  result := true;
end;

method DexiFunction.CanSetAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := true;
end;

method DexiFunction.SetAttribute(aAtt: DexiAttribute);
require
  (aAtt = nil) or CanSetAttribute(aAtt);
begin
  fAttribute := aAtt;
end;

method DexiFunction.GetCount: Integer;
begin
  result := 0;
end;

method DexiFunction.GetArgCount: Integer;
begin
  result :=
    if fAttribute = nil then 0
    else fAttribute.InpCount;
end;

method DexiFunction.GetOutValCount: Integer;
begin
  result :=
    if fAttribute:Scale = nil then 0
    else fAttribute.Scale.Count;
end;

method DexiFunction.GetArgValCount(aArg: Integer): Integer;
begin
  result :=
    if fAttribute = nil then 0
    else if fAttribute.Inputs[aArg]:Scale = nil then 0
    else fAttribute.Inputs[aArg].Scale.Count;
end;

method DexiFunction.GetDefined: Float;
begin
  result := 0.0;
end;

method DexiFunction.GetDetermined: Float;
begin
  result := 0.0;
end;

method DexiFunction.GetFunctString: String;
begin
  result := DexiString.MStrFunctionUndef;
end;

method DexiFunction.GetFunctStatus: String;
begin
  result := '';
end;

method DexiFunction.GetFunctClassDistr: String;
begin
  result := '';
  if not (Attribute:Scale is DexiDiscreteScale) then
    exit;
  var lScl := DexiDiscreteScale(Attribute:Scale);
  for c := 0 to OutValCount - 1 do
    begin
      if c > 0 then
        result := result + ',';
      result := result + String.Format('{0}:{1}', [lScl.Names[c], ClassCount[c]]);
    end;
end;

method DexiFunction.CanAssignFunction(aFnc: DexiFunction): Boolean;
begin
  result := aFnc <> nil;
end;

method DexiFunction.AssignFunction(aFnc: DexiFunction);
begin
  if aFnc = nil then
    exit;
  Name := aFnc.Name;
  Description := aFnc.Description;
  fAttribute := aFnc.Attribute;
end;

method DexiFunction.CanUseWeights: Boolean;
begin
  result := false;
end;

method DexiFunction.CanUseMultilinear: Boolean;
begin
  result := false;
end;

method DexiFunction.CanUseDominance: Boolean;
begin
  result := (fAttribute:Scale <> nil) and (OutValCount >= 2) and fAttribute.Scale.IsOrdered;
  if not result then
    exit;
  for i := 0 to ArgCount - 1 do
    begin
      var lAtt := fAttribute.Inputs[i];
      if (lAtt:Scale <> nil) and lAtt.Scale.IsOrdered then
        exit true;
    end;
  result := false;
end;

method DexiFunction.CompareValuesMethod(aValue1, aValue2: DexiValue): DexiValueMethod;
require
  DexiValue.ValueIsDefined(aValue1);
  DexiValue.ValueIsDefined(aValue2);
begin
  result :=
    if aValue1.HasIntSingle and aValue2.HasIntSingle then DexiValueMethod.Single
    else if aValue1.HasIntInterval and aValue2.HasIntInterval then DexiValueMethod.Interval
    else DexiValueMethod.Distr;
end;

method DexiFunction.CompareValues(aValue1, aValue2: DexiValue): PrefCompare;
begin
  result := PrefCompare.No;
  var lScale := fAttribute:Scale;
  if lScale = nil then
    exit;
  if not (DexiValue.ValueIsDefined(aValue1) and DexiValue.ValueIsDefined(aValue2)) then
    exit;
  var lMethod := CompareValuesMethod(aValue1, aValue2);
  result := DexiValue.CompareValues(aValue1, aValue2, lMethod);
  if result <> PrefCompare.Equal then
    if lScale.Order = DexiOrder.None then
      result := PrefCompare.No
    else if lScale.Order = DexiOrder.Descending then
      result := Values.ReversePrefCompare(result);
end;

method DexiFunction.SaveToFile(aFileName: String; aSettings: DexiSettings);
begin
  var lList := SaveToStringList(aSettings);
  File.WriteLines(aFileName, lList);
end;

method DexiFunction.LoadFromFile(aFileName: String; aSettings: DexiSettings; out aLoaded, aChanged: Integer);
begin
  var lList := File.ReadLines(aFileName);
  LoadFromStringList(lList, aSettings, out aLoaded, out aChanged);
end;

method DexiFunction.GetUndoState: IUndoable;
begin
  var lFnc := CopyFunction;
  result := lFnc;
end;

method DexiFunction.SetUndoState(aState: IUndoable);
begin
  inherited SetUndoState(aState);
  var lFnc := aState as DexiFunction;
  AssignFunction(lFnc);
end;

{$ENDREGION}

{$REGION DexiTabularFunction}

class method DexiTabularFunction.CanCreateOn(aAtt: DexiAttribute): Boolean;
begin
  result :=
    (aAtt <> nil) and (aAtt.Scale <> nil) and aAtt.Scale.IsDistributable and
    (aAtt.InpCount > 0) and (0 <= aAtt.SpaceSize <= SpaceSizeLimit);
end;

method DexiTabularFunction.UsesDexiLibraryFeatures: Boolean;
begin
  result := false;
  for a := 0 to ArgCount - 1 do
    begin
      var lScl := Attribute:Inputs[a]:Scale;
      if (lScl = nil) or (lScl.Count < 2) then
        exit true;
    end;
  for r := 0 to Count - 1 do
    begin
      var lValue := RuleValue[r];
      if not DexiValue.ValueIsDefined(lValue) or not lValue.HasIntInterval then
        exit true;
    end;
end;

constructor DexiTabularFunction(aAtt: DexiAttribute := nil);
begin
  inherited constructor(aAtt);
  fRules := nil;
  fVectors := nil;
  fUseWeights := false;
  fUseConsist := true;
  fRounding := 0;
  fKNState := 0;
  fCstState := 0;
  fRecalcWeights := false;
  if aAtt <> nil then
    SetAttribute(aAtt);
end;

method DexiTabularFunction.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiTabularFunction then
    exit false;
  if aObj = self then
    exit true;
  var lFnc := DexiTabularFunction(aObj);
  if not inherited EqualStateAs(lFnc) then
    exit false;
  result :=
    (lFnc.Count = Count) and
    (lFnc.fUseWeights = fUseWeights) and
    (lFnc.fUseConsist = fUseConsist) and
    (lFnc.fRounding = fRounding) and
    (lFnc.fRecalcWeights = fRecalcWeights);
  if result and Utils.BothNonNil(fRules, lFnc.fRules) then
    for i := 0 to Count - 1 do
      if not fRules[i].EqualTo(lFnc.fRules[i]) then
        exit false;
end;

method DexiTabularFunction.CanSetAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := CanCreateOn(aAtt);
end;

method DexiTabularFunction.Clear;
begin
  inherited Clear;
  ClearValues;
end;

method DexiTabularFunction.ClearValue(aRule: Integer);
begin
  fRules[aRule].LowInt := 0;
  fRules[aRule].HighInt := OutValCount - 1;
  fRules[aRule].Entered := false;
  AffectsWeights;
end;

method DexiTabularFunction.ClearValues;
begin
  for i := 0 to Count - 1 do
    ClearValue(i);
end;

method DexiTabularFunction.UndefineValue(aRule: Integer);
begin
  SetRuleValue(aRule, new DexiUndefinedValue);
end;

method DexiTabularFunction.ClearNonEnteredValues;
begin
  for i := 0 to Count - 1 do
    if not RuleEntered[i] then
      ClearValue(i);
end;

method DexiTabularFunction.AffectsWeights;
begin
  fRecalcWeights := true;
end;

method DexiTabularFunction.CopyFunction: InstanceType;
begin
  result := new DexiTabularFunction(Attribute);
  result.AssignFunction(self);
end;

method DexiTabularFunction.CanAssignFunction(aFnc: DexiFunction): Boolean;
begin
  result :=
    inherited CanAssignFunction(aFnc) and (aFnc is DexiTabularFunction) and
    (aFnc.Attribute <> nil) and DexiScale.AssignmentCompatibleScales(Attribute:Scale, aFnc:Attribute.Scale) and
    (aFnc.Count = Count) and Utils.IntArrayEq(aFnc.Attribute.Domain, fAttribute.Domain);
end;

method DexiTabularFunction.AssignFunction(aFnc: DexiFunction);
begin
  inherited AssignFunction(aFnc);
  if CanAssignFunction(aFnc) then
    begin
      var lFnc := DexiTabularFunction(aFnc);
      fRules := new List<DexiRule>;
      fVectors := new Vectors(lFnc.fVectors.LowVector, lFnc.fVectors.HighVector);
      for each lRule in lFnc.Rules do
        fRules.Add(lRule.Copy);
      fUseWeights := lFnc.UseWeights;
      fUseConsist := lFnc.UseConsist;
      fRounding := lFnc.Rounding;
      fFunctK := lFnc.fFunctK;
      fFunctN := lFnc.fFunctN;
      fKNState := lFnc.fKNState;
      fCstState := lFnc.fCstState;
      fRecalcWeights := lFnc.fRecalcWeights;
      fWeightFactors := Utils.CopyFltArray(lFnc.WeightFactors);
      fRequiredWeights := Utils.CopyFltArray(lFnc.RequiredWeights);
      fActualWeights := Utils.CopyFltArray(lFnc.ActualWeights);
      fNormActualWeights := Utils.CopyFltArray(lFnc.NormActualWeights);
    end;
end;

method DexiTabularFunction.CanUseWeights: Boolean;
begin
  result :=
    (fAttribute:Scale <> nil) and (OutValCount >= 2) and fAttribute.Scale.IsOrdered and
    (fAttribute.InpCount >= 2) and (fAttribute.SpaceSize > 0);
  if not result then
    exit;
  for i := 0 to ArgCount - 1 do
    begin
      var lAtt := fAttribute.Inputs[i];
      if (lAtt:Scale <> nil) then
        if not (lAtt.Scale.IsDistributable and lAtt.Scale.IsOrdered) then
          exit false;
    end;
end;

method DexiTabularFunction.CanUseMultilinear: Boolean;
begin
  result :=
    (fAttribute:Scale <> nil) and (OutValCount >= 2) and fAttribute.Scale.IsOrdered and
    (fAttribute.InpCount >= 2) and (fAttribute.SpaceSize > 0);
  if not result then
    exit;
  result := Utils.FloatEq(Determined, 1.0);
end;

method DexiTabularFunction.CanUseDominance: Boolean;
begin
  result := inherited CanUseDominance and (fAttribute.SpaceSize > 0);
end;

method DexiTabularFunction.CreateDecisionTable;
require
  CanSetAttribute(fAttribute);
begin
  var lLow := Utils.NewIntArray(ArgCount, 0);
  var lHigh := fAttribute.Domain;
  fVectors := new Vectors(lLow, lHigh);
  fRules := new List<DexiRule>;
  if fVectors.Count <= 0 then
    exit;
  fVectors.First;
  repeat
    fRules.Add(new DexiRule(fVectors.Vector, 0, OutValCount - 1, false));
  until not fVectors.Next;
end;

method DexiTabularFunction.SetAttribute(aAtt: DexiAttribute);
begin
  inherited SetAttribute(aAtt);
  fRules := nil;
  fVectors := nil;
  if fAttribute = nil then
    exit;
  CreateDecisionTable;
  fWeightFactors := Utils.NewFltArray(ArgCount + 1);
  fActualWeights := Utils.NewFltArray(ArgCount);
  fNormActualWeights := Utils.NewFltArray(ArgCount);
  fRequiredWeights := Utils.NewFltArray(ArgCount, 1.0);
  Values.NormSum(var fRequiredWeights);
  fRecalcWeights := false;
end;

method DexiTabularFunction.UpdateValues;
begin
  if Attribute.Scale.Order = DexiOrder.None then
    begin
      ClearNonEnteredValues;
      exit;
    end;
  for i := 0 to Count - 1 do
    if not RuleEntered[i] and RuleDefined[i] then
      begin
        var l := 0;
        var h := OutValCount - 1;
        for j := 0 to Count - 1 do
          if RuleEnteredDefined[j] then
            case CompareRules(j, i) of
              PrefCompare.Lower:   l := Math.Max(l, RuleValLow[j]);
              PrefCompare.Greater: h := Math.Min(h, RuleValHigh[j]);
              else {nothing}
            end;
          if l <= h then
            SetRuleVal(i, l, h);
//TODO Check this old Dexi code: (What happerns with decreasing scales?)
//        if Attribute.Scale.Order = DexiOrder.Descending then
//          Utils.SwapInt(var l, var h);
//        if l > h then
//          begin
//            ClearNonEnteredValues;
//            exit;
//        end;
//        RuleValLow[i] := l;
//        RuleValHigh[i] := h;
      end;
end;

method DexiTabularFunction.UpdateWeightedRounded;
begin
  if not fUseWeights then
    exit;
  for i := 0 to Count - 1 do
    if not RuleEnteredDefined[i] then
      RuleVal[i] := WeightedRounded(i);
end;

method DexiTabularFunction.UpdateWeightedRounded(aExistingBounds: Boolean);
begin
  if not fUseWeights then
    exit;
  for i := 0 to Count - 1 do
    if not RuleEnteredDefined[i]  then
      if aExistingBounds then
        RuleVal[i] := Math.Max(Math.Min(WeightedRounded(i), RuleValHigh[i]), RuleValLow[i])
      else
        RuleVal[i] := Math.Max(Math.Min(WeightedRounded(i), OutValCount - 1), 0);
end;

method DexiTabularFunction.UpdateFunction(aFreeze: Boolean := false);
begin
  if IsConsistent then
    fCstState := 1
  else
    begin
      fCstState := -1;
      fUseConsist := false;
    end;
  if aFreeze then
    exit;
  if UseConsist then
    UpdateValues
  else
    ClearNonEnteredValues;
  if UseWeights and fRecalcWeights then
    CalcActualWeights(true);
  if (UseWeights or (KNState < 0)) and fRecalcWeights then
    CalcWeightKN(false);
  if UseWeights then
    UpdateWeightedRounded(UseConsist);
  fRecalcWeights := false;
end;

method DexiTabularFunction.ReviseFunction(aAutomation: Boolean := true);
begin
  fCstState := if IsConsistent then 1 else -1;
  if not aAutomation then
    exit;
  if UseConsist then
    UpdateValues
  else
    ClearNonEnteredValues;
  if UseWeights and fRecalcWeights then
    CalcActualWeights(true);
  if (UseWeights or (KNState < 0)) and fRecalcWeights then
    CalcWeightKN(false);
  if UseWeights then
    UpdateWeightedRounded(UseConsist);
  fRecalcWeights := false;
end;

method DexiTabularFunction.IndexOfRule(aRule: IntArray): Integer;
begin
  result := -1;
  if not fVectors.ValidVector(aRule) then
    exit;
  result := fVectors.IndexOf(aRule);
end;

method DexiTabularFunction.IndexOfRule(aRule: String): Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if fRules[i].Text = aRule then
      exit i;
end;

method DexiTabularFunction.GetCount: Integer;
begin
  result :=
    if fRules = nil then 0
    else fRules.Count;
end;

method DexiTabularFunction.GetEntCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if RuleEntered[i] then
      inc(result);
end;

method DexiTabularFunction.GetDefCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if RuleDefined[i] then
      inc(result);
end;

method DexiTabularFunction.GetEntDefCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if RuleEnteredDefined[i] then
      inc(result);
end;

method DexiTabularFunction.GetClassCount(aClass: Integer): Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if fRules[i].IsDefined then
      if RuleValLow[i] <= aClass <= RuleValHigh[i] then
        inc(result);
end;

method  DexiTabularFunction.GetItemRatio: String;
begin
  result := $'{EntCount}/{Count}';
end;

method DexiTabularFunction.GetArgVal(aArg, aRule: Integer): Integer;
begin
  result := fRules[aRule].Arg[aArg];
end;

method DexiTabularFunction.SetArgVal(aArg, aRule, aVal: Integer);
begin
  fRules[aRule].Arg[aArg] := aVal;
  AffectsWeights;
end;

method DexiTabularFunction.GetArgValues(aRule: Integer): IntArray;
begin
  result := fRules[aRule].Args; // no need to copy again (first copy made by DexiRule)
end;

method DexiTabularFunction.GetRuleValue(aRule: Integer): DexiValue;
begin
  result := fRules[aRule].Value;
end;

method DexiTabularFunction.SetRuleValue(aRule: Integer; aValue: DexiValue);
begin
  fRules[aRule].Value := aValue;
  fRules[aRule].Entered := true;
  AffectsWeights;
end;

method DexiTabularFunction.GetRuleValLow(aRule: Integer): Integer;
begin
  result := fRules[aRule].LowInt;
end;

method DexiTabularFunction.SetRuleValLow(aRule, aVal: Integer);
begin
  fRules[aRule].LowInt := aVal;
  AffectsWeights;
end;

method DexiTabularFunction.GetRuleValHigh(aRule: Integer): Integer;
begin
  result := fRules[aRule].HighInt;
end;

method DexiTabularFunction.SetRuleValHigh(aRule, aVal: Integer);
begin
  fRules[aRule].HighInt := aVal;
  AffectsWeights;
end;

method DexiTabularFunction.SetRuleVal(aRule, aVal: Integer);
begin
  SetRuleVal(aRule, aVal, aVal);
end;

method DexiTabularFunction.SetRuleVal(aRule, aLow, aHigh: Integer);
begin
  SetRuleValLow(aRule, aLow);
  SetRuleValHigh(aRule, aHigh);
end;

method DexiTabularFunction.GetRuleEntered(aRule: Integer): Boolean;
begin
  result := fRules[aRule].Entered;
end;

method DexiTabularFunction.SetRuleEntered(aRule: Integer; aEnt: Boolean);
begin
  fRules[aRule].Entered := aEnt;
  AffectsWeights;
end;

method DexiTabularFunction.GetRuleEnteredDefined(aRule: Integer): Boolean;
begin
  result := GetRuleDefined(aRule) and GetRuleEntered(aRule);
end;

method DexiTabularFunction.SetUseConsist(aUseConsist: Boolean);
begin
  fUseConsist := aUseConsist;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.GetRuleDefined(aRule: Integer): Boolean;
begin
  result := (0 <= aRule < Count) and fRules[aRule].IsDefined;
end;

method DexiTabularFunction.GetDefined: Float;
begin
  result :=
    if Count = 0 then 0.0
    else Float(EntCount)/Count;
end;

method DexiTabularFunction.GetDetermined: Float;
begin
  result := 0.0;
  if Count <= 0 then
    exit;
  var u := OutValCount - 1;
  for i := 0 to Count - 1 do
    begin
      var d :=
        if RuleDefined[i] then Math.Abs(RuleValHigh[i] - RuleValLow[i])
        else 0.0;
      result := result + (1.0 - d / u);
    end;
  result := result / Count;
end;

method DexiTabularFunction.GetFunctString: String;
begin
  result :=
    String.Format(
      DexiString.MStrFunctionRule + ' {0}/{1} ({2}%), ' + DexiString.MStrFunctionDef + ' {3:0.##}% [{4}]',
      [EntCount, Count,
       Utils.FltToStr(if Count = 0 then 0.0 else 100.0 * EntCount/Count, 2, false),
       Utils.FltToStr(100.0 * Determined, 2, false),
       FunctClassDistr
      ]);
end;

method DexiTabularFunction.GetFunctStatus: String;
begin
  result := '';
  if Attribute = nil then
    exit;
  if not IsConsistent then
    if CanUseWeights then result := 'X'
    else result := 'x';
  if CstState >= 0 then
    if UseConsist then result := result + 'O'
    else result := result + 'o';
  if KNState >= 0 then
    if UseWeights then result := result + 'W'
    else result := result + 'w'
end;

method DexiTabularFunction.SetDexOrder(aOrder: Boolean);
begin
  if aOrder then
    fRules.Sort(
      method(a1, a2: DexiRule): Integer;
        begin
          result := 0;
          for i := a1.ArgCount - 1 downto 0 do
            if a1.Arg[i] > a2.Arg[i] then exit 1
            else if a1.Arg[i] < a2.Arg[i] then exit -1;
        end
    )
  else
    fRules.Sort(
      method(a1, a2: DexiRule): Integer;
        begin
          result := 0;
          for i := 0 to a1.ArgCount - 1 do
            if a1.Arg[i] > a2.Arg[i] then exit 1
            else if a1.Arg[i] < a2.Arg[i] then exit -1;
        end
    );
end;

method DexiTabularFunction.SortRules;
begin
  SetDexOrder(false);
end;

method DexiTabularFunction.CompareRules(aRule1, aRule2: Integer): PrefCompare;
begin
  result := PrefCompare.Equal;
  for lArg := 0 to ArgCount - 1 do
    begin
      var o := Attribute.Inputs[lArg].Scale.Order;
      var u := ArgVal[lArg, aRule1];
      var v := ArgVal[lArg, aRule2];
      if u = v then {nothing}
      else
        case o of
          DexiOrder.Ascending:
            if u < v then
              if (result = PrefCompare.Equal) or (result = PrefCompare.Lower) then
                result := PrefCompare.Lower
              else
                exit PrefCompare.No
            else
              if (result = PrefCompare.Equal) or (result = PrefCompare.Greater) then
                result := PrefCompare.Greater
              else
                exit PrefCompare.No;
          DexiOrder.Descending:
            if u < v then
              if (result = PrefCompare.Equal) or (result = PrefCompare.Greater) then
                result := PrefCompare.Greater
              else
                exit PrefCompare.No
            else
              if (result = PrefCompare.Equal) or (result = PrefCompare.Lower) then
                result := PrefCompare.Lower
              else
                exit PrefCompare.No;
          else
            exit PrefCompare.No;
        end;
    end;
end;

method DexiTabularFunction.CompareArgValues(aArg, aRule1, aRule2: Integer): PrefCompare;
begin
  result := PrefCompare.No;
  var lScale := fAttribute:Inputs[aArg]:Scale;
  if lScale = nil then
    exit;
  var lOrder := lScale.Order;
  for lArg := 0 to ArgCount - 1 do
    if lArg <> aArg then
      if ArgVal[lArg, aRule1] <> ArgVal[lArg, aRule2] then
        exit;
  result :=
    if ArgVal[aArg, aRule1] = ArgVal[aArg, aRule2] then PrefCompare.Equal
    else if lOrder = DexiOrder.None then PrefCompare.No
    else if ArgVal[aArg, aRule1] > ArgVal[aArg, aRule2] then PrefCompare.Greater
    else PrefCompare.Lower;
  if lOrder = DexiOrder.Descending then
    result := Values.ReversePrefCompare(result);
end;

method DexiTabularFunction.CompareRuleValues(aRule1, aRule2: Integer): PrefCompare;
begin
  var lValue1 := RuleValue[aRule1];
  var lValue2 := RuleValue[aRule2];
  result := CompareValues(lValue1, lValue2);
end;

method DexiTabularFunction.RuleIsConsistentWith(aRule1, aRule2: Integer): Boolean;
begin
  result := true;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  if not (RuleDefined[aRule1] and RuleDefined[aRule2]) then
    exit;
  var lCompareRules := CompareRules(aRule1, aRule2);
  if lCompareRules = PrefCompare.No then
    exit;
  var lCompareValues := CompareRuleValues(aRule1, aRule2);
  if lCompareValues = PrefCompare.Equal then
    exit;
  result := lCompareRules = lCompareValues;
end;

method DexiTabularFunction.RuleIsConsistent(aRule: Integer): Boolean;
begin
  result := true;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  for lRule := 0 to Count - 1 do
    if RuleEnteredDefined[lRule] then
      if not RuleIsConsistentWith(aRule, lRule) then
        exit false;
end;

method DexiTabularFunction.IsConsistent: Boolean;
begin
  result := true;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  for i := 0 to Count - 1 do
    if RuleEnteredDefined[i] then
      if not RuleIsConsistent(i) then
        exit false;
end;

method DexiTabularFunction.RuleInconsistentWith(aRule: Integer): IntArray;
begin
  if Attribute.Scale.Order = DexiOrder.None then
    exit [];
  var lInconsist := new Boolean[Count];
  for i := low(lInconsist) to high(lInconsist) do
    lInconsist[i] := false;
  var lCnt := 0;
  for lRule := 0 to Count - 1 do
    if RuleEnteredDefined[lRule] and (aRule <> lRule) then
      if not RuleIsConsistentWith(aRule, lRule) then
        begin
          inc(lCnt);
          lInconsist[lRule] := true;
        end;
  if lCnt = 0 then
    exit [];
  result := Utils.NewIntArray(lCnt);
  var lPos := 0;
  for i := low(lInconsist) to high(lInconsist) do
    if lInconsist[i] then
      begin
        result[lPos] := i;
        inc(lPos);
      end;
end;

method DexiTabularFunction.CountInconsistentRules: Integer;
begin
  result := 0;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  for i := 0 to Count - 1 do
    if RuleEnteredDefined[i] then
      if not RuleIsConsistent(i) then
        inc(result);
end;

method DexiTabularFunction.IsActuallyMonotone: Boolean;
var ActOrder: array of ActualScaleOrder;

  method ActCompareRules(aRule1, aRule2: Integer): PrefCompare;
  begin
    result := PrefCompare.Equal;
    for lArg := 0 to ArgCount-1 do
      begin
        var o := ActOrder[lArg];
        var lVal1 := ArgVal[lArg, aRule1];
        var lVal2 := ArgVal[lArg, aRule2];
        if o = ActualScaleOrder.Descending then
          begin
            lVal1 := -lVal1;
            lVal2 := -lVal2;
          end;
        if lVal1 = lVal2 then {nothing}
        else if lVal1 < lVal2 then
          if (result = PrefCompare.Equal) or (result = PrefCompare.Lower) then
            result := PrefCompare.Lower
          else
            exit PrefCompare.No
        else
          if (result = PrefCompare.Equal) or (result = PrefCompare.Greater) then
            result := PrefCompare.Greater
          else
            exit PrefCompare.No;
      end;
  end;

begin
  result := false;
  ActOrder := new ActualScaleOrder[ArgCount];
  for i := 0 to ArgCount - 1 do
    begin
      ActOrder[i] := ArgActualOrder(i);
      if ActOrder[i] = ActualScaleOrder.None then
        exit;
    end;
  result := true;
  for i := 0 to Count - 2 do
    if RuleEnteredDefined[i] then
      for j := i + 1 to Count - 1 do
        if RuleEnteredDefined[j] then
          case ActCompareRules(j, i) of
            PrefCompare.Equal, PrefCompare.No: ; //nothing
            PrefCompare.Lower:
              case CompareRuleValues(j, i) of
                PrefCompare.Equal, PrefCompare.Lower: ; //nothing
                PrefCompare.Greater, PrefCompare.No:
                  exit false;
              end;
            PrefCompare.Greater:
              case CompareRuleValues(j, i) of
                PrefCompare.Equal, PrefCompare.Greater: ; //nothing
                PrefCompare.Lower, PrefCompare.No:
                  exit false;
              end;
          end;
end;

method DexiTabularFunction.SymComparable(lArg1, lArg2, lRule1, lRule2: Integer): Boolean;
begin
  result := (ArgVal[lArg1, lRule1] = ArgVal[lArg2, lRule2]) and (ArgVal[lArg2, lRule1] = ArgVal[lArg1, lRule2]);
  if not result then
    exit;
  for lArg := 0 to ArgCount - 1 do
    if (lArg <> lArg1) and (lArg <> lArg2) then
      if ArgVal[lArg, lRule1] <> ArgVal[lArg, lRule2] then
        exit false;
end;

method DexiTabularFunction.ArgIsSymmetricWith(aArg1, aArg2: Integer): Boolean;
begin
  if Attribute.Inputs[aArg1].Scale.Count <> Attribute.Inputs[aArg2].Scale.Count then
    exit false;
  result := true;
  if aArg1 = aArg2 then
    exit;
  for p := 0 to Count - 2 do
    for r := p + 1 to Count - 1 do
      if SymComparable(aArg1, aArg2, p, r) then
        if CompareRuleValues(p, r) <> PrefCompare.Equal then
          exit false;
end;

method DexiTabularFunction.ArgIsSymmetric(aArg: Integer): Boolean;
begin
  result := true;
  for lArg := 0 to ArgCount - 1 do
    if aArg <> lArg then
      if not ArgIsSymmetricWith(aArg, lArg) then
        exit false;
end;

method DexiTabularFunction.ArgSymmetricity(aArg: Integer): Float;
begin
  if ArgCount <= 1 then
    exit 1.0;
  var c := 0;
  for lArg := 0 to ArgCount - 1 do
    if aArg <> lArg then
      if ArgIsSymmetricWith(aArg, lArg) then
        inc(c);
  result := Float(c) / (ArgCount - 1);
end;

method DexiTabularFunction.IsSymmetric: Boolean;
begin
  result := true;
  for lArg := 0 to ArgCount - 1 do
    if not ArgIsSymmetric(lArg) then
      exit false;
end;

method DexiTabularFunction.AsymmetricPairs(aArg1, aArg2: Integer): List<IntPair>;
begin
  result := new List<IntPair>;
  if aArg1 = aArg2 then
    exit;
  for p := 0 to Count - 2 do
    for r := p + 1 to Count - 1 do
      if SymComparable(aArg1, aArg2, p, r) then
        if CompareRuleValues(p, r) <> PrefCompare.Equal then
          result.Add(new IntPair(p, r));
end;

method DexiTabularFunction.CanEnforceSymmetricity(aArg1, aArg2: Integer): List<IntPair>;
begin
  result := new List<IntPair>;
  if aArg1 = aArg2 then
    exit;
  for f := 0 to Count - 1 do
    if RuleEnteredDefined[f] then
      for t := 0 to Count - 1 do
        if (f <> t) and not RuleEntered[t] and RuleDefined[t] and SymComparable(aArg1, aArg2, f, t) then
          begin
            var lFromLow := RuleValLow[f];
            var lFromHigh := RuleValHigh[f];
            var lToLow := RuleValLow[t];
            var lToHigh := RuleValHigh[t];
            if (lToLow <= lFromLow <= lToHigh) and (lToLow <= lFromHigh <= lToHigh) then
              result.Add(new IntPair(f, t));
          end;
end;

method DexiTabularFunction.SymmetricityStatus(aArg1, aArg2: Integer): DexiSymmetricityStatus;

  method Initialize: DexiSymmetricityStatus;
  begin
    result := new DexiSymmetricityStatus;
    var lAtt1 := fAttribute.Inputs[aArg1];
    var lAtt2 := fAttribute.Inputs[aArg2];
    var lScl1 := lAtt1:Scale;
    var lScl2 := lAtt2:Scale;
    result.ArgsCountCompatible := (lScl1 <> nil) and (lScl2 <> nil) and (lScl1.Count = lScl2.Count);
    result.ArgsOrderCompatible := (lScl1 <> nil) and (lScl2 <> nil) and (lScl1.Order = lScl2.Order);
  end;

begin
  result := Initialize;
  if not result.ArgsCompatible then
    exit;
  result.Asymmetric := AsymmetricPairs(aArg1, aArg2);
  result.CanEnforce := CanEnforceSymmetricity(aArg1, aArg2);
end;

method DexiTabularFunction.ArgActualOrder(aArg: Integer): ActualScaleOrder;
begin
  result := ActualScaleOrder.Constant;
  for i := 0 to Count - 1 do
    if RuleEnteredDefined[i] then
      for j := 0 to Count - 1 do
        if i <> j then
          if RuleEnteredDefined[j] then
            if CompareArgValues(aArg, j, i) = PrefCompare.Greater then
              begin
                case CompareRuleValues(j, i) of
                  PrefCompare.Equal: ; //nothing
                  PrefCompare.No:
                    exit ActualScaleOrder.None;
                  PrefCompare.Lower:
                    case result of
                      ActualScaleOrder.None:
                        exit;
                      ActualScaleOrder.Constant:
                        result := ActualScaleOrder.Descending;
                      ActualScaleOrder.Ascending:
                        exit ActualScaleOrder.None;
                      ActualScaleOrder.Descending: ; // nothing
                    end;
                  PrefCompare.Greater:
                    case result of
                      ActualScaleOrder.None:
                        exit;
                      ActualScaleOrder.Constant:
                        result := ActualScaleOrder.Ascending;
                      ActualScaleOrder.Ascending: ; // nothing
                      ActualScaleOrder.Descending:
                        exit ActualScaleOrder.None;
                    end;
                end;
              end;
end;

method DexiTabularFunction.ArgAffects(aArg: Integer): Boolean;
begin
  result := false;
  for i := 0 to Count - 2 do
    for j := i + 1 to Count - 1 do
      if CompareRuleValues(j, i) <> PrefCompare.Equal then
        exit true;
end;

method DexiTabularFunction.ArgValuePairEqual(aArg, aVal1, aVal2: Integer): Boolean;
begin
  result := true;
  for i := 0 to Count - 2 do
    for j := i + 1 to Count - 1 do
      if (ArgVal[aArg, i] = aVal1) and (ArgVal[aArg, j] = aVal2) then
        if CompareRuleValues(j, i) <> PrefCompare.Equal then
          exit false;
end;

method DexiTabularFunction.Evaluation(aArgVal: List<String>): String;
begin
  result := '';
  var b := Values.EmptySet;
  var f := Values.IntSet(0, OutValCount - 1);
  for i := 0 to Count - 1 do
    begin
      var applies := true;
      var lText := fRules[i].Text;
      for j := 0 to ArgCount - 1 do
        if (aArgVal[j] = '') or (aArgVal[j] = '*') then {nothing: applies}
        else if Utils.Pos0(lText[j], aArgVal[j]) < 0 then
          begin
            applies := false;
            break;
          end;
      if applies then
        for x := RuleValLow[i] to RuleValHigh[i] do
          Values.IntSetInclude(var b, x);
      if Values.IntSetEq(b, f) then
        exit;
    end;
  for i := low(b) to high(b) do
    result := result + chr(b[i] + ord('0'));
end;

method DexiTabularFunction.Evaluate(aArgs: IntArray): DexiValue;
begin
  if not fVectors.ValidVector(aArgs) then
    exit nil;
  var lIdx := fVectors.IndexOf(aArgs);
  result := RuleValue[lIdx];
end;

method DexiTabularFunction.Evaluate(aArgs: FltArray): DexiValue;
begin
  var lArgs := Utils.FltToIntArray(aArgs);
  result := Evaluate(lArgs);
end;

method DexiTabularFunction.CalcActualWeights(aAll: Boolean);

  method LinTEqu(var L: FltMatrix; var y, b: FltArray);
    begin
      for i := 0 to Math.Min(high(y), high(b)) do
        begin
          var s := 0.0;
          for k := 0 to i - 1 do
            s := s + L[k, i] * y[k];
          y[i] :=
            if Utils.FloatEq(L[i, i], 0) then 0
            else (b[i] - s) / L[i, i];
        end;
    end;

  method LinEqu(var U: FltMatrix; var x, y: FltArray);
    begin
      for i := Math.Min(high(x), high(y)) downto 0 do
        begin
          var s := 0.0;
          for k := i + 1 to Math.Min(high(x), high(y)) do
            s := s + U[i, k] * x[k];
          x[i] :=
            if Utils.FloatEq(U[i,i], 0) then 0
            else (y[i] - s) / U[i, i];
        end;
    end;

  method Chol(var A: FltMatrix; var x, b: FltArray): Boolean;
    begin
      var n := Math.Min(high(x), high(b));
      var U := new FltArray[n + 1];
      for i := low(U) to high(U) do
        U[i] := Utils.NewFltArray(n + 1);
      var y := Utils.NewFltArray(n + 1);
      for i := 0 to n do
        begin
          var s := 0.0;
          for j := 0 to i - 1 do
            s := s + U[j, i] * U[j, i];
          U[i, i] := A[i, i] - s;
          if Utils.FloatEq(U[i, i], 0) then
            exit false;
          U[i, i] := Math.Sqrt(U[i, i]);
          for k := i + 1 to n do
            begin
              s := 0.0;
              for j := 0 to i - 1 do
                s := s + U[j, i] * U[j, k];
              U[i, k] := (A[i, k] - s) / U[i, i];
            end;
        end;
      LinTEqu(var U, var y, var b);
      LinEqu(var U, var x, var y);
      result := true;
    end;

  method FormMatrix(var M: FltMatrix);
    begin
      for j := 0 to ArgCount - 1 do
        for k := j to ArgCount - 1 do
          begin
            var s := 0.0;
            for i := 0 to Count - 1 do
              if RuleDefined[i] and (aAll or RuleEntered[i]) then
                s := s + ArgVal[j, i] * ArgVal[k, i];
            M[j, k] := s;
          end;
      for j := 0 to ArgCount - 1 do
        begin
          var s := 0.0;
          for i := 0 to Count - 1 do
            if RuleDefined[i] and (aAll or RuleEntered[i]) then
              s := s + ArgVal[j, i];
          M[j, ArgCount] := s;
        end;
      M[ArgCount, ArgCount] := if aAll then Count else EntCount;
    end;

  method FormVector(var x: FltArray);
    begin
      for j := 0 to high(x) - 1 do
        begin
          var s := 0.0;
          for i := 0 to Count - 1 do
            if (aAll or RuleEntered[i]) and RuleDefined[i] then
              s := s + RuleValue[i].AsFloat * ArgVal[j, i];
          x[j] := s;
        end;
      var s := 0.0;
      for i := 0 to Count - 1 do
        if (aAll or RuleEntered[i]) and RuleDefined[i] then
          s := s + RuleValue[i].AsFloat;
      x[high(x)] := s;
    end;

begin
  var M := new FltArray[ArgCount + 1];
  for i := low(M) to high(M) do
    M[i] := Utils.NewFltArray(ArgCount + 1);
  var b := Utils.NewFltArray(ArgCount + 1);
  var a := Utils.NewFltArray(ArgCount + 1);
  FormMatrix(var M);
  FormVector(var b);
  if Chol(var M, var a, var b) then
    begin
      fActualWeights := Utils.NewFltArray(ArgCount);
      fNormActualWeights := Utils.NewFltArray(ArgCount);
      fWeightFactors := Utils.NewFltArray(ArgCount + 1);
      for i := low(a) to high(a) do
        WeightFactors[i] := a[i];
      for i := low(a) to high(a)-1 do
        begin
          ActualWeights[i] := Math.Abs(a[i]);
          try
            NormActualWeights[i] := Math.Abs(a[i]) * (fAttribute.Inputs[i].Scale.Count - 1);
          except
            NormActualWeights[i] := 0.0;
          end;
        end;
      Values.NormSum(var fActualWeights);
      Values.NormSum(var fNormActualWeights);
    end
  else
    begin
      for i := low(ActualWeights) to high(ActualWeights) do
        ActualWeights[i] := 0.0;
      for i := low(NormActualWeights) to high(NormActualWeights) do
        NormActualWeights[i] := 0.0;
    end;
end;

method DexiTabularFunction.CalcWeightKN(aAll: Boolean);

  method Fail;
  begin
    fFunctK := 0.0;
    fFunctN := 0.0;
    fKNState := -1;
    fUseWeights := false;
  end;

begin
  try
    if length(RequiredWeights) <> ArgCount then
      begin
        fRequiredWeights := Utils.NewFltArray(ArgCount, 1.0);
        Values.NormSum(var fRequiredWeights);
      end;
    var c := if aAll then Count else EntCount;
    if c = 0 then
      begin
        Fail;
        exit;
      end;
    var SW := 0.0;
    var SW2 := 0.0;
    var Sy := 0.0;
    var SWy := 0.0;
    for i := 0 to Count - 1 do
      if (aAll or RuleEntered[i]) and RuleDefined[i] then
        begin
          var w := 0.0;
          for j := 0 to ArgCount - 1 do
            w := w + RequiredWeights[j] * ArgVal[j, i];
          var y := (RuleValHigh[i] + RuleValLow[i]) / 2.0;
          SW := SW + w;
          SW2 := SW2 + w*w;
          Sy := Sy + y;
          SWy := SWy + w * y;
        end;
    fFunctK := (SWy - SW * Sy / c) / (SW2 - SW * SW / c);
    fFunctN := (Sy - fFunctK * SW) / c;
    fKNState := 1;
  except
    Fail;
  end;
end;

method DexiTabularFunction.WeightedRequired(aRule: Integer): Float;
begin
  result := 0.0;
  for j := 0 to ArgCount - 1 do
    result := result + RequiredWeights[j] * ArgVal[j, aRule];
  result := fFunctK * result + fFunctN;
end;

method DexiTabularFunction.WeightedRounded(aRule: Integer): Integer;
begin
  result :=
    if fRounding = 0 then Math.Min(Math.Max(0, Math.Round(WeightedRequired(aRule))), OutValCount - 1)
    else Math.Min(Math.Max(0, Math.Round(WeightedRequired(aRule) + fRounding * Utils.FloatEpsilon)), OutValCount - 1)
end;

method DexiTabularFunction.WeightedActual(aRule: Integer): Float;
begin
  result := 0.0;
  for j := 0 to ArgCount - 1 do
    result := result + WeightFactors[j] * ArgVal[j, aRule];
  result := result + WeightFactors[ArgCount];
end;

method DexiTabularFunction.LinCount(aAll, aStrict: Boolean): Integer;

  method IsCloseEnough(f, v: Float): Boolean;
  begin
    var d := Math.Abs(f - v);
    result :=
      if aStrict then (d - Utils.FloatEpsilon) < 0.5
      else (d + Utils.FloatEpsilon) < 0.5;
  end;

begin
  result := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      begin
        var f := WeightedActual(r);
        if IsCloseEnough(f, RuleValue[r].AsFloat) then
          inc(result);
      end;
end;

method DexiTabularFunction.LinDistance(aAll: Boolean): Float;
begin
  result := 0.0;
  var n := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      begin
        inc(n);
        result := result + Math.Abs(WeightedActual(r) - RuleValue[r].AsFloat);
      end;
  if n > 0 then
    result := result / n;
end;

method DexiTabularFunction.RuleClassProb(aRule, aClass: Integer): Float;
begin
  if not RuleDefined[aRule] then result := 0.0
  else
    begin
      var l := RuleValLow[aRule];
      var h := RuleValHigh[aRule];
      result :=
        if l <= aClass <= h then 1.0/(h - l + 1)
        else 0.0;
    end;
end;

method DexiTabularFunction.ClassProb(aAll: Boolean): FltArray;
begin
  result := Utils.NewFltArray(OutValCount, 0.0);
  var n := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
        begin
          inc(n);
          for v := 0 to OutValCount - 1 do
            result[v] := result[v] + RuleClassProb(r, v);
        end;
  if n > 0 then
    for i := low(result) to high(result) do
      result[i] := result[i]/n;
end;

method DexiTabularFunction.ClassProbWhere(aAll: Boolean; aArg, aVal: Integer): FltArray;
begin
  result := Utils.NewFltArray(OutValCount, 0.0);
  var n := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      if fRules[r].Arg[aArg] = aVal then
        begin
          inc(n);
          for v := 0 to OutValCount - 1 do
            result[v] := result[v] + RuleClassProb(r, v);
        end;
  if n > 0 then
    for i := low(result) to high(result) do
      result[i] := result[i]/n;
end;

method DexiTabularFunction.ClassProb(aRules: IntArray): FltArray;
begin
  result := Utils.NewFltArray(OutValCount, 0.0);
  var n := 0;
  for x := low(aRules) to high(aRules) do
    begin
      var r := aRules[x];
      inc(n);
      for v := 0 to OutValCount - 1 do
        result[v] := result[v] + RuleClassProb(r, v);
    end;
  if n > 0 then
    for i := low(result) to high(result) do
      result[i] := result[i]/n;
end;

method DexiTabularFunction.CountWhere(aAll: Boolean): Integer;
begin
  result := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      inc(result);
end;

method DexiTabularFunction.CountWhere(aAll: Boolean; aArg, aVal: Integer): Integer;
begin
  result := 0;
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      if fRules[r].Arg[aArg] = aVal then
        inc(result);
end;

method DexiTabularFunction.SplitSizes(aAll: Boolean; aArg: Integer): IntArray;
begin
  result := Utils.NewIntArray(fAttribute.Inputs[aArg].Scale.Count, 0);
  for r := 0 to Count - 1 do
    if (aAll or RuleEntered[r]) and RuleDefined[r] then
      inc(result[fRules[r].Arg[aArg]]);
end;

method DexiTabularFunction.SplitInformation(aAll: Boolean; aArg: Integer): Float;
begin
  var lSplitSizes := SplitSizes(aAll, aArg);
  var lProb := Values.NormSum(Utils.IntToFltArray(lSplitSizes), 1.0);
  result := Utils.Entropy(lProb);
end;

method DexiTabularFunction.WeightsByGain(aAll: Boolean; aImpurity: ImpurityFunction): FltArray;
begin
  result := Utils.NewFltArray(ArgCount, 0.0);
  var lTable := aImpurity(ClassProb(aAll));
  var lSize := CountWhere(aAll);
  if lSize <= 0 then
    exit;
  for lArg := 0 to ArgCount - 1 do
    begin
      result[lArg] := lTable;
      for lVal := 0 to fAttribute.Inputs[lArg].Scale.Count - 1 do
        begin
          var lCount := CountWhere(aAll, lArg, lVal);
          var lPart := aImpurity(ClassProbWhere(aAll, lArg, lVal));
          result[lArg] := result[lArg] - lCount * lPart / lSize;
        end;
      end;
end;

method DexiTabularFunction.GiniGain(aAll: Boolean): FltArray;
begin
  result := WeightsByGain(aAll, @Utils.Gini);
end;

method DexiTabularFunction.InformationGain(aAll: Boolean): FltArray;
begin
  result := WeightsByGain(aAll, @Utils.Entropy);
end;

method DexiTabularFunction.GainRatio(aAll: Boolean): FltArray;
begin
  result := InformationGain(aAll);
  for lArg := 0 to ArgCount - 1 do
    result[lArg] := result[lArg] / SplitInformation(aAll, lArg);
end;

method DexiTabularFunction.ChiSquare(aAll: Boolean): FltArray;
begin
  result := Utils.NewFltArray(ArgCount, 0);
  var lSize := CountWhere(aAll);
  if lSize <= 0 then
    exit;
  for lArg := 0 to ArgCount - 1 do
    begin
      // make arrays
      var lArgValCount := fAttribute.Inputs[lArg].Scale.Count;
      var lInpOut := new IntArray[lArgValCount];
      for i := low(lInpOut) to high(lInpOut) do
        lInpOut[i] := Utils.NewIntArray(OutValCount, 0);
      var lOutCount := Utils.NewIntArray(OutValCount, 0);
      var lValCount := Utils.NewIntArray(lArgValCount, 0);

      // make counts
      for r := 0 to Count - 1 do
        if (aAll or RuleEntered[r]) and RuleDefined[r] then
          begin
            inc(lValCount[fRules[r].Arg[lArg]]);
            for c := RuleValLow[r] to RuleValHigh[r] do
              begin
                inc(lOutCount[c]);
                inc(lInpOut[fRules[r].Arg[lArg]][c]);
              end;
          end;

      // calculate
      var s := 0.0;
      for v := 0 to lArgValCount - 1 do
        for c := 0 to OutValCount - 1 do
          begin
            var E := lValCount[v] * lOutCount[c] / Float(lSize);
            var D := lInpOut[v, c] - E;
            s := s + D * D / E;
          end;
      result[lArg] := s;
    end;
end;

method DexiTabularFunction.InsertArgValue(aArg, aVal: Integer);
// do not use when inserting the first value
begin
  var lNewRules := new List<DexiRule>;
  for i := 0 to fRules.Count - 1 do
    begin
      if fRules[i].Arg[aArg] = 0 then
        begin
          var lArgs := Utils.CopyIntArray(fRules[i].Args);
          lArgs[aArg] := aVal;
          lNewRules.Add(new DexiRule(lArgs, 0, OutValCount - 1, false));
        end;
      if fRules[i].Arg[aArg] >= aVal then
        fRules[i].Arg[aArg] := fRules[i].Arg[aArg] + 1;
    end;
  fRules.Add(lNewRules);
  var lHigh := fVectors.HighVector;
  inc(lHigh[aArg]);
  fVectors := new Vectors(fVectors.LowVector, lHigh);
  SortRules;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.DeleteArgValue(aArg, aVal: Integer);
begin
  for i := Count - 1 downto 0 do
    begin
      if fRules[i].Arg[aArg] = aVal then
        fRules.RemoveAt(i)
      else if fRules[i].Arg[aArg] > aVal then
        fRules[i].Arg[aArg] := fRules[i].Arg[aArg] - 1;
    end;
  var lHigh := fVectors.HighVector;
  if lHigh[aArg] > 0 then
    begin
      dec(lHigh[aArg]);
      fVectors := new Vectors(fVectors.LowVector, lHigh);
    end;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.DuplicateArgValue(aArg, aVal: Integer);
// do not use when inserting the first value
begin
  var lNewRules := new List<DexiRule>;
  for i := 0 to fRules.Count - 1 do
    begin
      if fRules[i].Arg[aArg] = 0 then
        begin
          var lArgs := Utils.CopyIntArray(fRules[i].Args);
          lArgs[aArg] := aVal;
          var lSrcArgs := Utils.CopyIntArray(fRules[i].Args);
          lSrcArgs[aArg] := aVal - 1;
          var lSrcIndex := IndexOfRule(lSrcArgs);
          lNewRules.Add(fRules[lSrcIndex].Copy);
        end;
      if fRules[i].Arg[aArg] >= aVal then
        fRules[i].Arg[aArg] := fRules[i].Arg[aArg] + 1;
    end;
  fRules.Add(lNewRules);
  var lHigh := fVectors.HighVector;
  inc(lHigh[aArg]);
  fVectors := new Vectors(fVectors.LowVector, lHigh);
  SortRules;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.ExchangeArgs(aArg1, aArg2: Integer);
begin
  if aArg1 = aArg2 then
    exit;
  for i := 0 to fRules.Count - 1 do
    begin
      var lArgs := fRules[i].Args;
      fRules[i].Arg[aArg1] := lArgs[aArg2];
      fRules[i].Arg[aArg2] := lArgs[aArg1];
    end;
  SortRules;
  var lHigh := fVectors.HighVector;
  Utils.IntArrayExchange(var lHigh, aArg1, aArg2);
  fVectors := new Vectors(fVectors.LowVector, lHigh);
  Utils.FltArrayExchange(var fActualWeights, aArg1, aArg2);
  Utils.FltArrayExchange(var fNormActualWeights, aArg1, aArg2);
  Utils.FltArrayExchange(var fRequiredWeights, aArg1, aArg2);
end;

method DexiTabularFunction.ReverseAttr(aIdx: Integer);
begin
  for i := 0 to Count - 1 do
    begin
      var x := ArgVal[aIdx, i];
      SetArgVal(aIdx, i, Attribute.Inputs[aIdx].Scale.Count - 1 - x);
    end;
  SortRules;
  ReviseFunction;
end;

method DexiTabularFunction.InsertFunctionValue(aVal: Integer);
begin
  for i := 0 to Count - 1 do
    if RuleDefined[i] and RuleValue[i].IsInteger then
      begin
        var lValue := fRules[i].Value as DexiIntValue;
        lValue.Insert(aVal);
      end;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.DeleteFunctionValue(aVal: Integer);
begin
  for i := 0 to Count - 1 do
    if RuleDefined[i] and RuleValue[i].IsInteger then
      begin
        var lValue := fRules[i].Value as DexiIntValue;
        if lValue.HasIntSingle and (lValue.AsInteger = aVal) then
          ClearValue(i)
        else if lValue.IsInterval and (lValue.HighInt = aVal) then
          lValue.AsIntInterval := Values.IntInt(lValue.LowInt, lValue.HighInt - 1)
        else
          lValue.Delete(aVal);
      end;
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.DuplicateFunctionValue(aVal: Integer);
begin
  for i := 0 to Count - 1 do
    if RuleDefined[i] then
      if RuleValue[i].IsInteger and (RuleValue[i].AsInteger = aVal) then
        RuleValue[i] := new DexiIntInterval(aVal, aVal + 1)
      else if RuleValue[i] is DexiIntValue then
        DexiIntValue(RuleValue[i]).Duplicate(aVal);
  AffectsWeights;
  ReviseFunction;
end;

method DexiTabularFunction.ReverseClass;
begin
  for i := 0 to Count - 1 do
   if RuleDefined[i] and RuleValue[i].IsInteger then
      begin
        var lValue := fRules[i].Value as DexiIntValue;
        lValue.Reverse(0, OutValCount - 1);
      end;
  ReviseFunction;
end;

method DexiTabularFunction.SetAllEntered(aEntered: Boolean := true);
begin
  for i := 0 to Count - 1 do
    RuleEntered[i] := aEntered;
  ReviseFunction;
end;

method DexiTabularFunction.SetRulesEntered(aAll: Boolean);
begin
  for i := 0 to Count - 1 do
    if not RuleEntered[i] then
      if aAll or RuleValue[i].HasIntSingle then
        RuleEntered[i] := true;
  ReviseFunction;
end;

method DexiTabularFunction.SaveToStringList(aSettings: DexiSettings): List<String>;
begin
  result := new List<String>;
  if (Attribute:Scale = nil) or (OutValCount < 0) then
    exit;
  var ss := new DexiScaleStrings;
  ss.ValueType := aSettings.FncDataType;
  var sb := new StringBuilder;
  sb.Append(Utils.TabChar);
  for i := 0 to ArgCount - 1 do
    begin
      sb.Append(Attribute.Inputs[i].Name);
      sb.Append(Utils.TabChar);
    end;
  sb.Append(Attribute.Name);
  result.Add(sb.toString);
  for j := 0 to Count - 1 do
    if aSettings.FncDataAll or RuleEntered[j] then
      begin
        sb.Clear;
        sb.Append(Utils.IntToStr(j + 1));
        sb.Append(Utils.TabChar);
        for i := 0 to ArgCount - 1 do
          begin
            sb.Append(ss.ValueOnScaleString(new DexiIntSingle(ArgVal[i, j]), Attribute.Inputs[i].Scale));
            sb.Append(Utils.TabChar);
          end;
        sb.Append(ss.ValueOnScaleString(RuleValue[j], Attribute.Scale));
        if aSettings.FncDataAll then
          begin
            sb.Append(Utils.TabChar);
            sb.Append(if RuleEntered[j] then '+' else '-');
          end;
        result.Add(sb.ToString);
      end;
end;

method DexiTabularFunction.LoadFromStringList(aList: ImmutableList<String>; aSettings: DexiSettings; out aLoaded, aChanged: Integer);
var ss: DexiScaleStrings;

  method ParseLine(aLoadLine: Integer): ImmutableList<String>;
  begin
    var lLine := aList[aLoadLine];
    result := lLine.Split(Utils.TabChar);
  end;

  method ReadLine(aLine: ImmutableList<String>; out aRule: Integer; out aEntered: Boolean): Boolean;
  begin
    result := false;
    if (aLine = nil) or (aLine.Count < ArgCount + 2) then
      exit;
    var lRule := Convert.TryToInt32(aLine[0]);
    if (lRule = nil) or not (0 < lRule <= Count) then
      exit;
    aRule := lRule - 1;
    for i := 0 to ArgCount - 1 do
      begin
        var lParse := ss.TryParseScaleValue(aLine[i + 1], Attribute.Inputs[i].Scale);
        if (lParse:Value = nil) or not lParse.Value.HasIntSingle then
          exit;
        if ArgVal[i, aRule] <> lParse.Value.AsInteger then
          exit;
      end;
    aEntered := true;
    if aLine.Count > ArgCount + 2 then
      begin
        var lEntStr := aLine[aLine.Count - 1].Trim;
        if lEntStr = '-' then
          aEntered := false;
      end;
    result := true;
  end;

begin
  aLoaded := 0;
  aChanged := 0;
  if (aList = nil) or (aList.Count = 0) then
    exit;
  ss := new DexiScaleStrings;
  ss.ValueType := aSettings.FncDataType;
  for lLoadLine := 0 to aList.Count - 1 do
    begin
      var lRule: Integer;
      var lEntered: Boolean;
      var lLine := ParseLine(lLoadLine);
      if ReadLine(lLine, out lRule, out lEntered) then
        begin
          var lParse := ss.TryParseScaleValue(lLine[ArgCount + 1], Attribute.Scale);
          if (lParse:Value = nil) and not String.IsNullOrEmpty(lParse.Error) then
            exit;
          inc(aLoaded);
          var lMethod := CompareValuesMethod(RuleValue[lRule], lParse.Value);
          if DexiScale.CompareValues(RuleValue[lRule], lParse.Value, Attribute.Scale, lMethod) <> PrefCompare.Equal then
            inc(aChanged);
          RuleValue[lRule] := lParse.Value;
          RuleEntered[lRule] := lEntered;
        end;
    end;
end;

method DexiTabularFunction.GetAsRuleString: String;
var u: Integer;

  method ValStr0(n: Integer): String;
  begin
    result := RuleVals[n];
  end;

  method ValStr(l: Integer; h: Integer): String;
  begin
    result :=
      if (l <= 0) and (h >= u) then '*'
      else if l = h then ValStr0(l)
      else ValStr0(l) + '-' + ValStr0(h);
  end;

begin
  result := '';
  if Attribute = nil then
    exit;
  u := DexiDiscreteScale(Attribute.Scale).Count - 1;
  for j := 0 to Count - 1 do
    begin
      var RStr := if result = '' then '' else ' ';
      for i := 0 to ArgCount - 1 do
        RStr := RStr + ValStr0(ArgVal[i, j]);
       RStr := RStr + if RuleEntered[j] then '=' else ':';
      var RVal :=
        if RuleDefined[j] then ValStr(RuleValLow[j], RuleValHigh[j])
        else '_';
      RStr := RStr + RVal;
      if not RuleEntered[j] and (RVal = '*') then // skip rule
      else
        result := result + RStr;
    end;
end;

class method DexiTabularFunction.ExtToIntVal(aExtCh: Char): Integer;
begin
  result := Utils.Pos0(aExtCh, RuleVals);
end;

class method DexiTabularFunction.IntToExtVal(aIntVal: Integer): String;
begin
  result :=
    if 0 <= aIntVal <= high(RuleVals) then RuleVals[aIntVal]
    else nil;
end;

type
  RuleParseRec = record
    Rule: array of Char;
    Low, High: Integer;
    Entered: Boolean;
    Defined: Boolean;
    method SetRuleStr(aStr: String); begin Rule := aStr.ToCharArray; end;
    property RuleString: String read new String(Rule) write SetRuleStr;
  end;

method DexiTabularFunction.SetAsRuleString(aStr: String; aForce: Boolean := false): Integer;
var lParse: RuleParseRec;

  method ParseRule(const aRuleStr: String; u: Integer): Boolean;
  begin
    result := false;
    var p := Utils.Pos0(':', aRuleStr);
    var q := Utils.Pos0('=', aRuleStr);
    var LStr := '';
    var RStr := '';
    if p >= 0 then
      begin
        lParse.Entered := false;
        LStr := Utils.CopyFromTo(aRuleStr, 0, p - 1);
        RStr := Utils.RestOf(aRuleStr, p + 1);
      end
    else if q >= 0 then
      begin
        lParse.Entered := true;
        LStr := Utils.CopyFromTo(aRuleStr, 0, q - 1);
        RStr := Utils.RestOf(aRuleStr, q + 1);
      end
    else
      exit;
    if (length(LStr) <> ArgCount) then
      exit;
    lParse.Rule := new Char[length(LStr)];
    for i := 0 to length(LStr) - 1 do
      begin
        var v := ExtToIntVal(LStr[i]);
        if v < 0 then
          exit;
        lParse.Rule[i] := chr(v + ord('0'));
      end;
    lParse.Defined := RStr <> '_';
    if lParse.Defined then
      begin
        if RStr = '*' then
          begin
            lParse.Low := 0;
            lParse.High := u;
          end
        else
          begin
            p := Utils.Pos0('-', RStr);
            if (p < 0) and (length(RStr) = 1) then
              begin
                lParse.Low := ExtToIntVal(RStr[0]);
                lParse.High := lParse.Low;
              end
            else if (p = 1) and (length(RStr) = 3) then
              begin
                lParse.Low := ExtToIntVal(RStr[0]);
                lParse.High := ExtToIntVal(RStr[2]);
              end
            else
              exit;
            if lParse.Low > lParse.High then
              Utils.Swap(var lParse.Low, var lParse.High);
            if (lParse.Low < 0) or (lParse.High < 0) then
              exit;
          end;
      end;
    result := true;
  end;

begin
  result := -1;
  ClearValues;
  if Attribute = nil then
    exit;
  result := 0;
  var RuleStrings := aStr.Split(' ');
  var u := DexiDiscreteScale(Attribute.Scale).Count - 1;
  for i := 0 to RuleStrings.Count - 1 do
    begin
      if not ParseRule(RuleStrings[i], u) then
        inc(result)
      else
        begin
          var rx := IndexOfRule(lParse.RuleString);
          if rx < 0 then
            inc(result)
          else if not lParse.Defined then
            begin
              if aForce or not RuleEntered[rx] then
                begin
                  UndefineValue(rx);
                  RuleEntered[rx] := lParse.Entered;
                end
            end
          else if (lParse.Low > u) or (lParse.High > u) then
            inc(result)
          else if aForce or not RuleEntered[rx] then
            begin
              RuleValLow[rx] := lParse.Low;
              RuleValHigh[rx] := lParse.High;
              RuleEntered[rx] := lParse.Entered;
            end;
        end;
    end;
end;

method DexiTabularFunction.RuleMatch(aRule: Integer; aProj: String): Boolean;
begin
  result := false;
  if length(aProj) <> ArgCount then
    exit;
  var RStr := fRules[aRule].Text;
  for i := 0 to aProj.Length - 1 do
    if (aProj[i] >= '0') and (aProj[i] <> RStr[i]) then
      exit;
  result := true;
end;

method DexiTabularFunction.RuleMatch(aRule: Integer; aMatch: IntArray): Boolean;
begin
  result := false;
  if length(aMatch) <> ArgCount then
    exit;
  for i := low(aMatch) to high(aMatch) do
    if (aMatch[i] >= 0) and (ArgVal[i, aRule] <> aMatch[i]) then
      exit;
  result := true;
end;

method DexiTabularFunction.ProjSum(aIdx: Integer; aAll: Boolean := true): RuleArray1;
begin
  result := nil;
  if (aIdx < 0) or (aIdx >= ArgCount) then
    exit;
  result := new RuleValue[Attribute.Inputs[aIdx].Scale.Count];
  for i := low(result) to high(result) do
    begin
      result[i].Low := 0;
      result[i].High := 0;
      result[i].Entered := false;
    end;
  for i := 0 to Count - 1 do
    if aAll or RuleEntered[i] then
      begin
        result[ArgVal[aIdx, i]].Low := result[ArgVal[aIdx, i]].Low + RuleValLow[i];
        result[ArgVal[aIdx, i]].High := result[ArgVal[aIdx, i]].High + RuleValHigh[i];
      end;
end;

method DexiTabularFunction.Projection1(aProj: String): RuleArray1;
begin
  result := nil;
  if length(aProj) <> ArgCount then
    exit;
  var PAtt := Utils.Pos0(#0, aProj);
  if PAtt < 0 then
    exit;
  result := new RuleValue[Attribute.Inputs[PAtt].Scale.Count];
  for i := low(result) to high(result) do
    begin
      result[i].Low := 0;
      result[i].High := OutValCount - 1;
      result[i].Entered := false;
    end;
  for i := 0 to Count - 1 do
    if RuleMatch(i, aProj) then
      begin
        result[ArgVal[PAtt, i]].Low := RuleValLow[i];
        result[ArgVal[PAtt, i]].High := RuleValHigh[i];
        result[ArgVal[PAtt, i]].Entered := RuleEntered[i];
      end;
end;

method DexiTabularFunction.Projection2(aProj: String): RuleArray2;
begin
  result := nil;
  if length(aProj)<>ArgCount then
    exit;
  var PAtt1 := Utils.Pos0(#0, aProj);
  var PAtt2 := Utils.Pos0(#1, aProj);
  if (PAtt1 < 0) or (PAtt2 < 0) then
    exit;
  result := new RuleArray1[Attribute.Inputs[PAtt1].Scale.Count];
  for i := low(result) to high(result) do
    result[i] := new RuleValue[Attribute.Inputs[PAtt2].Scale.Count];
  for i := low(result) to high(result) do
    for j := low(result[i]) to high(result[i]) do
      begin
        result[i, j].Low := 0;
        result[i, j].High := OutValCount - 1;
        result[i, j].Entered := false;
      end;
  for i := 0 to Count - 1 do
    if RuleMatch(i, aProj) then
      begin
        result[ArgVal[PAtt1, i], ArgVal[PAtt2, i]].Low := RuleValLow[i];
        result[ArgVal[PAtt1, i], ArgVal[PAtt2, i]].High := RuleValHigh[i];
        result[ArgVal[PAtt1, i], ArgVal[PAtt2, i]].Entered := RuleEntered[i];
      end;
end;

method DexiTabularFunction.Projection1(aMatch: IntArray): IntArray;
begin
  result := nil;
  if length(aMatch) <> ArgCount then
    exit;
  var lPos := -1;
  for i := low(aMatch) to high(aMatch) do
    if aMatch[i] < 0 then
      if lPos >= 0 then
        exit
      else
        lPos := i;
  if lPos < 0 then
    exit;
  var lArgs := Utils.CopyIntArray(aMatch);
  var lCount := Attribute.Inputs[lPos].Scale.Count;
  result := Utils.NewIntArray(lCount, -1);
  for i := 0 to lCount - 1 do
    begin
      lArgs[lPos] := i;
      result[i] := fVectors.IndexOf(lArgs);
    end;
end;

method DexiTabularFunction.Projection2(aMatch: IntArray): IntMatrix;
begin
  result := nil;
  if length(aMatch) <> ArgCount then
    exit;
  var lPos1 := -1;
  var lPos2 := -1;
  for i := low(aMatch) to high(aMatch) do
    if aMatch[i] < 0 then
      if lPos1 < 0 then
        lPos1 := i
      else if lPos2 < 0 then
        lPos2 := i
      else
        exit;
  if (lPos1 < 0) or (lPos2 < 0) then
    exit;
  var lArgs := Utils.CopyIntArray(aMatch);
  var lCount1 := Attribute.Inputs[lPos1].Scale.Count;
  var lCount2 := Attribute.Inputs[lPos2].Scale.Count;
  result := new IntArray[lCount1];
  for i := low(result) to high(result) do
    result[i] := Utils.NewIntArray(lCount2, -1);
  for i := 0 to lCount1 - 1 do
    for j := 0 to lCount2 - 1 do
      begin
        lArgs[lPos1] := i;
        lArgs[lPos2] := j;
        result[i][j] := fVectors.IndexOf(lArgs);
      end;
end;

method DexiTabularFunction.FunctionStatusReport(aRpt: List<String>);
begin
  aRpt.RemoveAll;
  var lDet := Determined;
  if lDet < 1.0 then
    aRpt.Add(String.Format(DexiString.SDexiFrptDetermined, [100.0 * lDet]));
  var S := '';
  var lDesc := 0;
  if Attribute.Scale.Order = DexiOrder.Descending then
    inc(lDesc);
  for i := 0 to ArgCount - 1 do
    if (Attribute.Inputs[i].Scale <> nil) and (Attribute.Inputs[i].Scale.Order = DexiOrder.Descending) then
      inc(lDesc);
  if lDesc > 0 then
    aRpt.Add(String.Format(DexiString.SDexiFrptDescending, [lDesc]));
  for c := 0 to OutValCount - 1 do
    if ClassCount[c] = 0 then
      begin
        if S <> '' then
          S := S + ', ';
        S := S + DexiDiscreteScale(Attribute.Scale).Names[c];
      end;
  if S <> '' then
    aRpt.Add(String.Format(DexiString.SDexiFrptNoMap, [S]));
  var lCons := CountInconsistentRules;
  if lCons > 0 then
    aRpt.Add(String.Format(DexiString.SDexiFrptInconsistent, [lCons]));
  for i := 0 to ArgCount - 1 do
    begin
      if ArgAffects(i) then
        begin
          for v1 := 0 to Attribute.Inputs[i].Scale.Count - 2 do
            for v2 := v1 + 1 to Attribute.Inputs[i].Scale.Count - 1 do
              if ArgValuePairEqual(i, v1, v2) then
                begin
                  var lScl := DexiDiscreteScale(Attribute.Inputs[i].Scale);
                  aRpt.Add(String.Format(DexiString.SDexiFrptPairEqual,
                    [Attribute.Inputs[i].Name, lScl.Names[v1], lScl.Names[v2]]));
                end;
        end
      else
        aRpt.Add(String.Format(DexiString.SDexiFrptNotAffects, [Attribute.Inputs[i].Name]));
  end;
end;

method DexiTabularFunction.FunctionStatusReport: List<String>;
begin
  result := new List<String>;
  FunctionStatusReport(result);
end;

method DexiTabularFunction.ComplexRules(aVal: Integer; aRules: List<String>; fSettings: DexiSettings);
var
 ToCover := new List<String>;
 ArgsToIndex := new Dictionary<String, Integer>;
 BeenThere := new Dictionary<String, Boolean>;

  procedure MakeArgsToIndex;
  begin
    for i := 0 to Count - 1 do
      ArgsToIndex.Add(Rules[i].Text, i);
  end;

  method GetToCover;
  begin
    for i := 0 to Count - 1 do
      if (not fSettings.FncEnteredOnly or RuleEntered[i]) and RuleDefined[i] and (RuleValLow[i] <= aVal) and (RuleValHigh[i] >= aVal) then
        ToCover.Add(Rules[i].Text);
    ToCover.Sort((a, b) -> a.CompareTo(b));
  end;

  method CoversClass(r: String): Boolean;
  begin
    if not ArgsToIndex.ContainsKey(r) then
      result := false
    else
      begin
        var x := ArgsToIndex[r];
        result := (RuleValLow[x] <= aVal) and (RuleValHigh[x] >= aVal);
      end;
  end;

  method CoveringClass(l, h: String): Boolean;
  begin
    var lh := l + h;
    if BeenThere.ContainsKey(lh) then
      result := BeenThere[lh]
    else
      begin
        result := true;
        for i := 0 to Count - 1 do
          begin
            var s := Rules[i].Text;
            var c := true;
            for k := 0 to ArgCount - 1 do
              if not((s[k] >= l[k]) and (s[k] <= h[k])) then
                begin
                  c := false;
                  break;
                end;
            if c then
              result := (RuleValLow[i] <= aVal) and (RuleValHigh[i] >= aVal);
            if not result then
              break;
           end;
        BeenThere.Add(lh, result);
      end;
  end;

  method Cover(l, h: String): Boolean;
  begin
    result := CoveringClass(l, h);
    if not result then
      exit;
    var NextCover := false;
    for i := 0 to ArgCount - 1 do
      if ord(h[i]) - ord('0') < Attribute.Inputs[i].Scale.Count - 1 then
        begin
          var x := h.ToCharArray;
          inc(x[i]);
          var nh := Utils.CharsToString(x);
          if CoversClass(nh) then
            if Cover(l, nh) then
              NextCover := true;
        end;
    for i := 0 to ArgCount - 1 do
      if l[i] > '0' then
        begin
          var x := l.ToCharArray;
          dec(x[i]);
          var nl := Utils.CharsToString(x);
          if CoversClass(nl) then
            if Cover(nl, h) then
              NextCover := true;
        end;
    if not NextCover then
      if aRules.IndexOf(l + h) < 0 then
        aRules.Add(l + h);
  end;

  method DeleteCovered;
  begin
    for i := 0 to aRules.Count - 1 do
      begin
        if ToCover.Count = 0 then
          exit;
        var l := aRules[i].SubString(0, ArgCount);
        var h := aRules[i].SubString(ArgCount);
        for j := ToCover.Count - 1 downto 0 do
          begin
            var s := ToCover[j];
            var c := true;
            for k := 0 to ArgCount - 1 do
              if not((s[k] >= l[k]) and (s[k] <= h[k])) then
                begin
                  c := false;
                  break;
                end;
            if c then
              ToCover.RemoveAt(j);
        end;
    end;
  end;

begin
  aRules.RemoveAll;
  if (Attribute = nil) or not CanCreateOn(Attribute) then
    exit;
  MakeArgsToIndex;
  GetToCover;
  while ToCover.Count > 0 do
    begin
      Cover(ToCover[0], ToCover[0]);
      DeleteCovered;
    end;
end;

method DexiTabularFunction.ComplexRules(aVal: Integer; fAll: Boolean): List<DexiComplexRule>;
var
 FoundRules: List<DexiComplexRule>;
 ToCover: IntSet;
 BeenThere := new Dictionary<String, Boolean>;

  method GetToCover: IntSet;
  begin
    result := Values.EmptySet;
    for i := 0 to Count - 1 do
      if (fAll or RuleEntered[i]) and RuleDefined[i] and RuleValue[i].Member(aVal) then
        Values.IntSetInclude(var result, i);
  end;

  method AddRule(aLow, aHigh: IntArray);
  begin
    for i := 0 to FoundRules.Count - 1 do
      if Utils.IntArrayEq(aLow, FoundRules[i].Low) and Utils.IntArrayEq(aHigh, FoundRules[i].High) then
        exit;
    FoundRules.Add(new DexiComplexRule(aLow, aHigh));
  end;

  method CoversClass(lArgs: IntArray): Boolean;
  begin
    if not fVectors.ValidVector(lArgs) then
      exit false;
    var lIdx := fVectors.IndexOf(lArgs);
    result := RuleDefined[lIdx] and RuleValue[lIdx].Member(aVal);
  end;

  method CoveringClass(aLow, aHigh: IntArray): Boolean;
  begin
    var lKey := DexiComplexRule.ToString(aLow, aHigh);
    if BeenThere.ContainsKey(lKey) then
      result := BeenThere[lKey]
    else
      begin
        result := true;
        for i := 0 to Count - 1 do
          if RuleDefined[i] then
            begin
              var c := true;
              for k := 0 to ArgCount - 1 do
                if not((aLow[k] <= ArgVal[k, i] <= aHigh[k])) then
                  begin
                    c := false;
                    break;
                  end;
              if c then
                result := RuleValue[i].Member(aVal);
              if not result then
                break;
             end;
        BeenThere.Add(lKey, result);
      end;
  end;

  method DefinedArgument(aArg: Integer): Boolean;
  begin
    var lScale := Attribute:Inputs[aArg]:Scale;
    result := (lScale <> nil) and (lScale.Count > 1);
  end;

  method Cover(aLow, aHigh: IntArray): Boolean;
  begin
    result := CoveringClass(aLow, aHigh);
    if not result then
      exit;
    var NextCover := false;
    for i := 0 to ArgCount - 1 do
      if DefinedArgument(i) then
        if aHigh[i] < Attribute.Inputs[i].Scale.Count - 1 then
          begin
            var lNewHigh := Utils.CopyIntArray(aHigh);
            inc(lNewHigh[i]);
            if CoversClass(lNewHigh) then
              if Cover(aLow, lNewHigh) then
                NextCover := true;
          end;
    for i := 0 to ArgCount - 1 do
      if DefinedArgument(i) then
        if aLow[i] > 0 then
          begin
            var lNewLow := Utils.CopyIntArray(aLow);
            dec(lNewLow[i]);
            if CoversClass(lNewLow) then
              if Cover(lNewLow, aHigh) then
                NextCover := true;
          end;
    if not NextCover then
      AddRule(aLow, aHigh);
  end;

  method Cover(aIdx1, aIdx2: Integer): Boolean;
  begin
    var lLow := fRules[ToCover[aIdx1]].Args;
    var lHigh := fRules[ToCover[aIdx2]].Args;
    result := Cover(lLow, lHigh);
  end;

  method DeleteCovered;
  begin
    for i := 0 to FoundRules.Count - 1 do
      begin
        if length(ToCover) = 0 then
          exit;
        var rLow := FoundRules[i].Low;
        var rHigh := FoundRules[i].High;
        var lToCover := Values.IntSet(ToCover);
        for j := high(lToCover) downto low(lToCover) do
          begin
            var lRule := fRules[lToCover[j]].Args;
            var c := true;
            for k := 0 to ArgCount - 1 do
              if not(rLow[k] <= lRule[k] <= rHigh[k]) then
                begin
                  c := false;
                  break;
                end;
            if c then
              Values.IntSetExclude(var ToCover, lToCover[j]);
        end;
    end;
  end;

begin
  FoundRules := new List<DexiComplexRule>;
  if (Attribute = nil) or not CanCreateOn(Attribute) then
    exit;
  ToCover := GetToCover;
  while length(ToCover) > 0 do
    begin
      Cover(0, 0);
      DeleteCovered;
    end;
  FoundRules.Sort(@DexiComplexRule.Compare);
  result := FoundRules;
end;

method DexiTabularFunction.SelectRules(aCondition: Predicate<Integer> := nil): IntArray;
begin
  if not assigned(aCondition) then
    exit Utils.RangeArray(Count, 0);
  var lCount := 0;
  for r := 0 to Count - 1 do
    if aCondition(r) then
      inc(lCount);
  result := Utils.NewIntArray(lCount);
  var x := 0;
  for r := 0 to Count - 1 do
    if aCondition(r) then
      begin
        result[x] := r;
        inc(x);
      end;
end;

method DexiTabularFunction.SelectRules(aAll: Boolean): IntArray;
begin
  result :=
    if aAll then SelectRules
    else SelectRules((r) -> (RuleEntered[r]));
end;

method DexiTabularFunction.SelectRules(aAll: Boolean; aArg, aVal: Integer): IntArray;
begin
  result := SelectRules((r) -> ((aAll or RuleEntered[r]) and (fRules[r].Arg[aArg] = aVal)));
end;

method DexiTabularFunction.SelectRules(aAll: Boolean; aArg: Integer; aVals: IntArray): IntArray;
begin
  result := SelectRules((r) -> ((aAll or RuleEntered[r]) and Utils.IntArrayContains(aVals, fRules[r].Arg[aArg])));
end;

method DexiTabularFunction.SelectRules(aAll: Boolean; aArgs, aArgVals: IntArray; aClass: Integer): IntArray;

  method SelectRule(aRule: Integer): Boolean;
  begin
    result := false;
    if not (aAll or RuleEntered[aRule]) then
      exit;
    if not RuleDefined[aRule] then
      exit;
    var lArgs := ArgValues[aRule];
    for i := low(aArgs) to high (aArgs) do
      if lArgs[aArgs[i]] <> aArgVals[i] then
        exit;
    result :=
      if aClass < 0 then true
      else RuleValLow[aRule] <= aClass <= RuleValHigh[aRule];
  end;

require
  length(aArgs) = length(aArgVals);
begin
  result := SelectRules((r) -> (SelectRule(r)));
end;

method DexiTabularFunction.SelectRulesFrom(aRules: IntArray; aCondition: Predicate<Integer> := nil): IntArray;
begin
  if aRules = nil then
    exit nil;
  if not assigned(aCondition) then
    exit Utils.CopyIntArray(aRules);
  var lCount := 0;
  for r := low(aRules) to high(aRules) do
    if aCondition(aRules[r]) then
      inc(lCount);
  result := Utils.NewIntArray(lCount);
  var x := 0;
  for r := low(aRules) to high(aRules) do
    if aCondition(aRules[r]) then
      begin
        result[x] := aRules[r];
        inc(x);
      end;
end;

method DexiTabularFunction.SelectRulesFrom(aRules: IntArray; aArg, aVal: Integer): IntArray;
begin
  result := SelectRulesFrom(aRules, (r) -> (fRules[r].Arg[aArg] = aVal));
end;

method DexiTabularFunction.SelectRulesFrom(aRules: IntArray; aArg: Integer; aVals: IntArray): IntArray;
begin
  result := SelectRulesFrom(aRules, (r) -> (Utils.IntArrayContains(aVals, fRules[r].Arg[aArg])));
end;

method DexiTabularFunction.ValuesEqual(aRules: IntArray): Boolean;
begin
  result := true;
  if length(aRules) <= 1 then
    exit;
  var r0 := aRules[0];
  for x := low(aRules) + 1 to high(aRules) do
    if not DexiValue.ValuesAreEqual(RuleValue[r0], RuleValue[aRules[x]]) then
      exit false;
end;

method DexiTabularFunction.Marginals(aNorm: Boolean := false): FltMatrix;
begin
  result := new FltArray[ArgCount];
  var lCount := new IntArray[ArgCount];
  var lNorm :=
    if aNorm then OutValCount - 1
    else 1.0;
  for i := 0 to ArgCount - 1 do
    begin
      result[i] := Utils.NewFltArray(ArgValCount[i]);
      lCount[i] := Utils.NewIntArray(ArgValCount[i]);
    end;
  for r := 0 to Count - 1 do
    if RuleDefined[r] then
      begin
        var c := (RuleValHigh[r] + RuleValLow[r]) / 2.0;
        for i := 0 to ArgCount - 1 do
          begin
            var v := ArgVal[i, r];
            result[i][v] := result[i][v] + c;
            inc(lCount[i, v]);
          end;
      end;
  for i := 0 to ArgCount - 1 do
    for j := low(result[i]) to high(result[i]) do
      if lCount[i][j] > 0 then
        result[i][j] := result[i][j] / lCount[i][j] / lNorm;
end;

{$ENDREGION}

{$REGION DexiBound}

constructor DexiBound(aBound: Float; aAssociation: DexiBoundAssociation := DexiBoundAssociation.Down);
begin
  fBound := aBound;
  fAssociation := aAssociation;
end;

method DexiBound.Copy: DexiBound;
begin
  result := new DexiBound(fBound, fAssociation);
end;

method DexiBound.EqualTo(aBound: DexiBound): Boolean;
begin
  if aBound = nil then
    exit false;
  result :=
    (fBound = aBound.fBound) and
    (fAssociation = aBound.fAssociation);
end;

{$ENDREGION}

{$REGION DexiValueCell}

constructor DexiValueCell(aEntered: Boolean := false);
begin
  constructor (nil, aEntered);
end;

constructor DexiValueCell(aInt: Integer; aEntered: Boolean := false);
begin
  constructor (new DexiIntSingle(aInt), aEntered);
end;

constructor DexiValueCell(aLow, aHigh: Integer; aEntered: Boolean := false);
begin
  constructor (new DexiIntInterval(aLow, aHigh), aEntered);
end;

constructor DexiValueCell(aValue: DexiValue; aEntered: Boolean := false);
begin
  fValue := aValue;
  fEntered := aEntered;
end;

method DexiValueCell.GetIsDefined: Boolean;
begin
  result := DexiValue.ValueIsDefined(fValue);
end;

method DexiValueCell.SetInt(aInt: Integer);
begin
  fValue := new DexiIntSingle(aInt);
end;

method DexiValueCell.Copy: DexiValueCell;
begin
  result := new DexiValueCell;
  result.AssignCell(self);
end;

method DexiValueCell.AssignCell(aCell: DexiValueCell);
begin
  if aCell = nil then
    begin
      fValue := nil;
      fEntered := false;
    end
  else
    begin
      fValue := DexiValue.CopyValue(aCell.Value);
      fEntered := aCell.Entered;
    end;
end;

method DexiValueCell.EqualTo(aCell: DexiValueCell): Boolean;
begin
  if aCell = nil then
    exit false;
  result :=
    DexiValue.ValuesAreEqual(fValue, aCell.fValue) and
    (fEntered = aCell.Entered);
end;

{$ENDREGION}

{$REGION DexiDiscretizeFunction}

class method DexiDiscretizeFunction.CanCreateOn(aAtt: DexiAttribute): Boolean;
begin
  result :=
    (aAtt <> nil) and (aAtt.Scale <> nil) and aAtt.Scale.IsDistributable and
    (aAtt.InpCount = 1) and DexiScale.ScaleIsContinuous(aAtt.Inputs[0]:Scale);
end;

constructor DexiDiscretizeFunction(aAtt: DexiAttribute := nil);
begin
  inherited constructor(aAtt);
  SetAttribute(aAtt);
  fUseConsist := true;
  fCstState := 0;
end;

method DexiDiscretizeFunction.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiDiscretizeFunction then
    exit false;
  if aObj = self then
    exit true;
  var lFnc := DexiDiscretizeFunction(aObj);
  if not inherited EqualStateAs(lFnc) then
    exit false;
  result :=
    (lFnc.Count = Count) and
    (lFnc.fUseConsist = fUseConsist);
  if result and Utils.BothNonNil(fBounds, lFnc.fBounds) then
    for i := 0 to fBounds.Count - 1 do
      if not fBounds[i].EqualTo(lFnc.fBounds[i]) then
        exit false;
  if result and Utils.BothNonNil(fIntervals, lFnc.fIntervals) then
    for i := 0 to fIntervals.Count - 1 do
      if not fIntervals[i].EqualTo(lFnc.fIntervals[i]) then
        exit false;
end;

method DexiDiscretizeFunction.CanSetAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := CanCreateOn(aAtt);
end;

method DexiDiscretizeFunction.SetAttribute(aAtt: DexiAttribute);
begin
  inherited SetAttribute(aAtt);
  ClearIntervals;
end;

method DexiDiscretizeFunction.ClearIntervals;
begin
  fBounds := new List<DexiBound>;
  fBounds.Add(new DexiBound(Consts.NegativeInfinity, DexiBoundAssociation.Up));
  fBounds.Add(new DexiBound(Consts.PositiveInfinity, DexiBoundAssociation.Down));
  fIntervals := new List<DexiValueCell>;
  var lValue :=
    if Attribute = nil then new DexiUndefinedValue
    else new DexiIntSet(Attribute.FullSet);
  fIntervals.Add(new DexiValueCell(lValue, false));
end;

method DexiDiscretizeFunction.AdaptIntervalsToInputScale;
begin
  ClearIntervals;
  if fAttribute = nil then
    exit;
  var lInpScale := fAttribute.Inputs[0]:Scale;
  if (lInpScale = nil) or not lInpScale.IsOrdered then
    exit;
  if not Consts.IsInfinity(lInpScale.BGLow) then
    AddBound(lInpScale.BGLow, DexiBoundAssociation.Down);
  if not Consts.IsInfinity(lInpScale.BGHigh) then
    AddBound(lInpScale.BGHigh, DexiBoundAssociation.Up);
end;

method DexiDiscretizeFunction.Clear;
begin
  inherited Clear;
  ClearIntervals;
end;

method DexiDiscretizeFunction.ClearCell(aIdx: Integer);
begin
  var lValue :=
    if Attribute = nil then new DexiUndefinedValue
    else new DexiIntSet(Attribute.FullSet);
  fIntervals[aIdx] := new DexiValueCell(lValue, false);
end;

method DexiDiscretizeFunction.ClearNonEnteredValues;
begin
  for i := 0 to IntervalCount - 1 do
    if not IntervalEntered[i] then
      ClearCell(i);
end;

method DexiDiscretizeFunction.UpdateValues;
begin
  var lInp := Attribute.Inputs[0];
  if (Attribute.Scale.Order = DexiOrder.None) or (lInp.Scale.Order = DexiOrder.None) then
    exit;
  for i := 0 to IntervalCount - 1 do
    if not IntervalEntered[i] then
      begin
        var l := 0;
        var h := OutValCount - 1;
        for j := 0 to IntervalCount - 1 do
          if (j <> i) and IntervalDefined[j] and IntervalEntered[j] then
            if (j < i) xor (lInp.Scale.Order = DexiOrder.Descending) then l := Math.Max(l, IntervalValHigh[j])
            else h := Math.Min(h, IntervalValLow[j]);
        if l <= h then
          fIntervals[i] := new DexiValueCell(l, h, false);
      end;
end;

method DexiDiscretizeFunction.UpdateFunction;
begin
  if IsConsistent then
    fCstState := 1
  else
    begin
      fCstState := -1;
      fUseConsist := false;
    end;
  if UseConsist then
    UpdateValues
  else
    ClearNonEnteredValues;
end;

method DexiDiscretizeFunction.ReviseFunction(aAutomation: Boolean := true);
begin
  fCstState := if IsConsistent then 1 else -1;
  if not aAutomation then
    exit;
  if UseConsist then
    UpdateValues
  else
    ClearNonEnteredValues;
end;

method DexiDiscretizeFunction.GetCount: Integer;
begin
  result := IntervalCount;
end;

method DexiDiscretizeFunction.GetEntCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if IntervalEntered[i] then
      inc(result);
end;

method DexiDiscretizeFunction.GetDefCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if IntervalDefined[i] then
      inc(result);
end;

method DexiDiscretizeFunction.GetEntDefCount: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if IntervalEntered[i] and IntervalDefined[i] then
      inc(result);
end;

method DexiDiscretizeFunction.GetClassCount(aClass: Integer): Integer;
begin
  result := 0;
  for i := 0 to IntervalCount - 1 do
    if fIntervals[i].IsDefined then
      if IntervalValLow[i] <= aClass <= IntervalValHigh[i] then
        inc(result);
end;

method  DexiDiscretizeFunction.GetItemRatio: String;
begin
  result := $'{EntCount}/{Count}';
end;

method DexiDiscretizeFunction.GetDefined: Float;
begin
  result :=
    if Count = 0 then 0.0
    else Float(EntCount)/Count;
end;

method DexiDiscretizeFunction.GetDetermined: Float;
begin
  result := 0.0;
  if IntervalCount <= 0 then
    exit;
  var u := OutValCount - 1;
  for i := 0 to IntervalCount - 1 do
    begin
      var d :=
        if IntervalDefined[i] then Math.Abs(IntervalValHigh[i] - IntervalValLow[i])
        else 0.0;
      result := result + (1.0 - d / u);
    end;
  result := result / IntervalCount;
end;

method DexiDiscretizeFunction.GetBoundCount: Integer;
begin
  result := fBounds.Count;
end;

method DexiDiscretizeFunction.GetBound(aIdx: Integer): DexiBound;
begin
  result := fBounds[aIdx];
end;

method DexiDiscretizeFunction.GetBoundValue(aIdx: Integer): Float;
begin
  result := GetBound(aIdx).Bound;
end;

method DexiDiscretizeFunction.GetIntervalCount: Integer;
begin
  result := fIntervals.Count;
end;

method DexiDiscretizeFunction.GetValueCell(aIdx: Integer): DexiValueCell;
begin
  result := fIntervals[aIdx];
end;

method DexiDiscretizeFunction.SetValueCell(aIdx: Integer; aCell: DexiValueCell);
begin
  fIntervals[aIdx] := aCell;
end;

method DexiDiscretizeFunction.GetIntervalLowBoundIndex(aIdx: Integer): Integer;
begin
  result := aIdx;
end;

method DexiDiscretizeFunction.GetIntervalHighBoundIndex(aIdx: Integer): Integer;
begin
  result := aIdx + 1;
end;

method DexiDiscretizeFunction.GetIntervalLowBound(aIdx: Integer): DexiBound;
begin
  result := fBounds[aIdx];
end;

method DexiDiscretizeFunction.GetIntervalHighBound(aIdx: Integer): DexiBound;
begin
  result := fBounds[aIdx + 1];
end;

method DexiDiscretizeFunction.GetIntervalValue(aIdx: Integer): DexiValue;
begin
  result := fIntervals[aIdx].Value;
end;

method DexiDiscretizeFunction.SetIntervalValue(aIdx: Integer; aValue: DexiValue);
begin
  fIntervals[aIdx].Value := aValue;
end;

method DexiDiscretizeFunction.SetIntervalValue(aIdx: Integer; aValue: DexiValue; aEntered: Boolean := true);
begin
  fIntervals[aIdx].Value := aValue;
  fIntervals[aIdx].Entered := aEntered;
  ReviseFunction;
end;

method DexiDiscretizeFunction.UndefineInterval(aIdx: Integer);
begin
  SetIntervalValue(aIdx, new DexiUndefinedValue, true);
end;

method DexiDiscretizeFunction.GetIntervalValLow(aIdx: Integer): Integer;
begin
  result := fIntervals[aIdx].Value.LowInt;
end;

method DexiDiscretizeFunction.GetIntervalValHigh(aIdx: Integer): Integer;
begin
  result := fIntervals[aIdx].Value.HighInt;
end;

method DexiDiscretizeFunction.SetIntervalVal(aIdx, aVal: Integer; aEntered: Boolean := true);
begin
  SetIntervalValue(aIdx, new DexiIntSingle(aVal), aEntered);
end;

method DexiDiscretizeFunction.SetIntervalVal(aIdx, aLow, aHigh: Integer; aEntered: Boolean := true);
begin
  SetIntervalValue(aIdx, new DexiIntInterval(aLow, aHigh), aEntered);
end;

method DexiDiscretizeFunction.GetIntervalDefined(aIdx: Integer): Boolean;
begin
  result := (0 <= aIdx < IntervalCount) and fIntervals[aIdx].IsDefined;
end;

method DexiDiscretizeFunction.GetIntervalEntered(aIdx: Integer): Boolean;
begin
  result := fIntervals[aIdx].Entered;
end;

method DexiDiscretizeFunction.GetIntervalEnteredDefined(aIdx: Integer): Boolean;
begin
  result := GetIntervalDefined(aIdx) and GetIntervalEntered(aIdx);
end;

method DexiDiscretizeFunction.SetIntervalEntered(aIdx: Integer; aEntered: Boolean);
begin
  fIntervals[aIdx].Entered := aEntered;
  ReviseFunction;
end;

method DexiDiscretizeFunction.SetUseConsist(aUseConsist: Boolean);
begin
  fUseConsist := aUseConsist;
  ReviseFunction;
end;

method  DexiDiscretizeFunction.GetFunctString: String;
begin
  result :=
    String.Format(
      DexiString.MStrFunctionInterval + ' {0}/{1} ({2}%), ' + DexiString.MStrFunctionDef + ' {3:0.##}% [{4}]',
      [EntCount, Count,
       Utils.FltToStr(if IntervalCount = 0 then 0.0 else 100.0 * EntCount/IntervalCount, 2, false),
       Utils.FltToStr(100.0 * Determined, 2, false),
       FunctClassDistr
      ]);
end;

method DexiDiscretizeFunction.GetFunctStatus: String;
begin
  result := '';
  if Attribute = nil then
    exit;
  if not IsConsistent then
    if CanUseWeights then result := 'X'
    else result := 'x';
  if CstState >= 0 then
    if UseConsist then result := result + 'O'
    else result := result + 'o';
end;

method DexiDiscretizeFunction.CopyFunction: InstanceType;
begin
  result := new DexiDiscretizeFunction(Attribute);
  result.AssignFunction(self);
end;

method DexiDiscretizeFunction.CanAssignFunction(aFnc: DexiFunction): Boolean;
begin
  result :=
    inherited CanAssignFunction(aFnc) and (aFnc is DexiDiscretizeFunction) and
    (aFnc.Attribute <> nil) and DexiScale.AssignmentCompatibleScales(Attribute.Scale, aFnc.Attribute.Scale);
end;

method DexiDiscretizeFunction.AssignFunction(aFnc: DexiFunction);
begin
  inherited AssignFunction(aFnc);
  if CanAssignFunction(aFnc) then
    begin
      var lFnc := DexiDiscretizeFunction(aFnc);
      fBounds := new List<DexiBound>;
      for each lBound in lFnc.fBounds do
        fBounds.Add(lBound.Copy);
      fIntervals := new List<DexiValueCell>;
      for each lInterval in lFnc.fIntervals do
        fIntervals.Add(lInterval.Copy);
      fUseConsist := lFnc.UseConsist;
      fCstState := lFnc.fCstState;
    end;
end;

method DexiDiscretizeFunction.CompareIntervals(aIdx1, aIdx2: Integer): PrefCompare;
begin
  var lValue1 := IntervalValue[aIdx1];
  var lValue2 := IntervalValue[aIdx2];
  result := CompareValues(lValue1, lValue2);
end;

method DexiDiscretizeFunction.IntervalIsConsistentWith(aIdx1, aIdx2: Integer): Boolean;
begin
  result := true;
  var lInp := Attribute:Inputs[0];
  if (Attribute:Scale = nil) or (lInp:Scale = nil) or (Attribute.Scale.Order = DexiOrder.None) or (lInp.Scale.Order = DexiOrder.None) then
    exit;
  if not (IntervalDefined[aIdx1] and IntervalDefined[aIdx2]) then
    exit;
  var lBound1 := IntervalLowBound[aIdx1].Bound;
  var lBound2 := IntervalLowBound[aIdx2].Bound;
  var lCompareBounds := lInp.Scale.Compare(lBound1, lBound2);
  if lCompareBounds = PrefCompare.No then
    exit;
  var lCompareIntervals := CompareIntervals(aIdx1, aIdx2);
  if lCompareIntervals = PrefCompare.Equal then
    exit;
  result := lCompareBounds = lCompareIntervals;
end;

method DexiDiscretizeFunction.IntervalIsConsistent(aIdx: Integer): Boolean;
begin
  result := true;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  for lIdx := 0 to IntervalCount - 1 do
    if (lIdx <> aIdx) and IntervalDefined[lIdx] and IntervalEntered[lIdx] then
      if not IntervalIsConsistentWith(aIdx, lIdx) then
        exit false;
end;

method DexiDiscretizeFunction.IntervalInconsistentWith(aIdx: Integer): IntArray;
begin
  if Attribute.Scale.Order = DexiOrder.None then
    exit [];
  var lInconsist := new Boolean[IntervalCount];
  for i := low(lInconsist) to high(lInconsist) do
    lInconsist[i] := false;
  var lCnt := 0;
  for lIdx := 0 to IntervalCount - 1 do
    if IntervalEnteredDefined[lIdx] and (aIdx <> lIdx) then
      if not IntervalIsConsistentWith(aIdx, lIdx) then
        begin
          inc(lCnt);
          lInconsist[lIdx] := true;
        end;
  if lCnt = 0 then
    exit [];
  result := Utils.NewIntArray(lCnt);
  var lPos := 0;
  for i := low(lInconsist) to high(lInconsist) do
    if lInconsist[i] then
      begin
        result[lPos] := i;
        inc(lPos);
      end;
end;

method DexiDiscretizeFunction.IsConsistent: Boolean;
begin
  result := true;
  if Attribute.Scale.Order = DexiOrder.None then
    exit;
  for i := 0 to IntervalCount - 1 do
    if IntervalDefined[i] and IntervalEntered[i] then
      if not IntervalIsConsistent(i) then
        exit false;
end;

method DexiDiscretizeFunction.ActualOrder: ActualScaleOrder;
begin
  result := ActualScaleOrder.Constant;
  for i := 0 to IntervalCount - 2 do
    begin
      case CompareIntervals(i, i + 1) of
        PrefCompare.Equal: ; // nothing
        PrefCompare.No: result := ActualScaleOrder.None;
        PrefCompare.Lower:
          case result of
            ActualScaleOrder.None: ; // nothing
            ActualScaleOrder.Constant: result := ActualScaleOrder.Ascending;
            ActualScaleOrder.Ascending: ; // nothing
            ActualScaleOrder.Descending: result := ActualScaleOrder.None;
          end;
        PrefCompare.Greater:
          case result of
            ActualScaleOrder.None: ; // nothing
            ActualScaleOrder.Constant: result := ActualScaleOrder.Descending;
            ActualScaleOrder.Ascending:  result := ActualScaleOrder.None;
            ActualScaleOrder.Descending: ; // nothing
          end;
      end;
      if result = ActualScaleOrder.None then
        break;
    end;
end;

method DexiDiscretizeFunction.IsActuallyMonotone: Boolean;
begin
  result := ActualOrder <> ActualScaleOrder.None;
end;

method DexiDiscretizeFunction.ArgIsSymmetricWith(aArg1, aArg2: Integer): Boolean;
require
  ArgCount = 1;
  aArg1 = 0;
  aArg2 = 0;
begin
  result := true;
end;

method DexiDiscretizeFunction.ArgIsSymmetric(aArg: Integer): Boolean;
require
  ArgCount = 1;
  aArg = 0;
begin
  result := true;
end;

method DexiDiscretizeFunction.ArgSymmetricity(aArg: Integer): Float;
require
  ArgCount = 1;
  aArg = 0;
begin
  result := 1.0;
end;

method DexiDiscretizeFunction.IsSymmetric: Boolean;
require
  ArgCount = 1;
begin
  result := true;
end;

method DexiDiscretizeFunction.ArgActualOrder(aArg: Integer): ActualScaleOrder;
require
  ArgCount = 1;
  aArg = 0;
begin
  result := ActualOrder;
end;

method DexiDiscretizeFunction.ArgAffects(aArg: Integer): Boolean;
begin
  result := false;
  for i := 0 to IntervalCount - 1 do
    for j := 0 to IntervalCount - 1 do
      if i <> j then
          if CompareIntervals(j, i) <> PrefCompare.Equal then
            exit true;
end;

method DexiDiscretizeFunction.InInterval(aIdx: Integer; aArgValue: Float): Boolean;
begin
  var lLow := IntervalLowBound[aIdx];
  var lHigh := IntervalHighBound[aIdx];
  result :=
    case lLow.Association of
      DexiBoundAssociation.Down:
        case lHigh.Association of
          DexiBoundAssociation.Down: lLow.Bound < aArgValue <= lHigh.Bound;
          DexiBoundAssociation.Up:   lLow.Bound < aArgValue < lHigh.Bound;
        end;
      DexiBoundAssociation.Up:
        case lHigh.Association of
          DexiBoundAssociation.Down: lLow.Bound <= aArgValue <= lHigh.Bound;
          DexiBoundAssociation.Up:   lLow.Bound <= aArgValue < lHigh.Bound;
        end;
    end;
end;

method DexiDiscretizeFunction.JoinValues(aValue1, aValue2: DexiValue): DexiValue;
begin
  if aValue1 = nil then
    if aValue2 = nil then
      exit nil
    else
      exit aValue2
  else if aValue2 = nil then
    exit aValue1;
  if not aValue1.IsDefined then
    if not aValue2.IsDefined then
      exit aValue1
    else
      exit aValue2
  else if not aValue2.IsDefined then
    exit aValue1;
  if Attribute.Scale.Order = DexiOrder.None then
    begin
      var lSet1 := aValue1.AsIntSet;
      var lSet2 := aValue2.AsIntSet;
      var lSet := Values.IntSetUnion(lSet1, lSet2);
      result := new DexiIntSet(lSet);
    end
  else
    begin
      var lLow := Math.Min(aValue1.LowInt, aValue2.LowInt);
      var lHigh := Math.Max(aValue1.HighInt, aValue2.HighInt);
      result := new DexiIntInterval(lLow, lHigh);
    end;
  result := DexiValue.SimplifyValue(result);
end;

method DexiDiscretizeFunction.CanAddBound(aBound: Float): Boolean;
begin
  result := true;
  if Consts.IsInfinity(aBound) then
    exit false;
  for b := 1 to BoundCount - 2 do
    if Utils.FloatEq(aBound, fBounds[b].Bound) then
      exit false;
end;

method DexiDiscretizeFunction.AddBound(aBound: Float; aAssociation: DexiBoundAssociation := DexiBoundAssociation.Down): Integer;
require
  CanAddBound(aBound);
begin
  var lIdx := 0;
  while aBound > fBounds[lIdx].Bound do
    inc(lIdx);
  var lValue := DexiValue.CopyValue(IntervalValue[lIdx - 1]);
  fBounds.Insert(lIdx, new DexiBound(aBound, aAssociation));
  fIntervals.Insert(lIdx, new DexiValueCell(lValue, false));
  ReviseFunction;
  result := lIdx;
end;

method DexiDiscretizeFunction.AddBound(aBound: DexiBound): Integer;
begin
  AddBound(aBound.Bound, aBound.Association);
end;

method DexiDiscretizeFunction.CanDeleteBound(aIdx: Integer): Boolean;
begin
  result := 1 <= aIdx <= BoundCount - 2;
end;

method DexiDiscretizeFunction.RemoveBound(aIdx: Integer): DexiBound;
require
  CanDeleteBound(aIdx);
begin
  result := fBounds[aIdx];
  fBounds.RemoveAt(aIdx);
  if IntervalEntered[aIdx - 1] or IntervalEntered[aIdx] then
    begin
      var lValue1 := IntervalValue[aIdx - 1];
      var lValue2 := IntervalValue[aIdx];
      var lValue := JoinValues(lValue1, lValue2);
      SetIntervalValue(aIdx - 1, lValue, true);
    end;
  fIntervals.RemoveAt(aIdx);
  ReviseFunction;
end;

method DexiDiscretizeFunction.DeleteBound(aIdx: Integer);
begin
  RemoveBound(aIdx);
end;

method DexiDiscretizeFunction.CanChangeBound(aIdx: Integer; aBound: Float): Boolean;
begin
  result := (1 <= aIdx <= BoundCount - 2) and ((fBounds[aIdx].Bound = aBound) or CanAddBound(aBound));
end;

method DexiDiscretizeFunction.ChangeBound(aIdx: Integer; aBound: Float): Integer;
require
  CanChangeBound(aIdx, aBound);
begin
  if InInterval(aIdx, aBound) then
    begin
      fBounds[aIdx].Bound := aBound;
      result := aIdx;
    end
  else
    begin
      var lOldBound := RemoveBound(aIdx);
      result := AddBound(aBound, lOldBound.Association);
    end;
end;

method DexiDiscretizeFunction.ChangeBound(aIdx: Integer; aBound: Float; aAssoc: DexiBoundAssociation): Integer;
begin
  var lIdx := ChangeBound(aIdx, aBound);
  Bound[lIdx].Association := aAssoc;
end;

method DexiDiscretizeFunction.ReverseClass;
begin
  for i := 0 to IntervalCount - 1 do
   if IntervalDefined[i] and IntervalValue[i].IsInteger then
      begin
        var lValue := IntervalValue[i] as DexiIntValue;
        lValue.Reverse(0, OutValCount - 1);
      end;
  ReviseFunction;
end;

method DexiDiscretizeFunction.SetAllEntered(aEntered: Boolean := true);
begin
  for i := 0 to IntervalCount - 1 do
    IntervalEntered[i] := aEntered;
  ReviseFunction;
end;

method DexiDiscretizeFunction.SetIntervalsEntered(aAll: Boolean);
begin
  for i := 0 to IntervalCount - 1 do
    if not IntervalEntered[i] then
      if aAll or IntervalValue[i].HasIntSingle then
        IntervalEntered[i] := true;
  ReviseFunction;
end;

method DexiDiscretizeFunction.FunctionValue(aArgValue: Float): DexiValue;
begin
  result := nil;
  for lIdx := 0 to IntervalCount - 1 do
    if InInterval(lIdx, aArgValue) then
      exit IntervalValue[lIdx];
end;

method DexiDiscretizeFunction.Evaluation(aArgVal: List<String>): String;
begin
  raise new EDexiEvaluationError('Method "Evaluation" is not supported for DexiDiscretizeFunction');
end;

method DexiDiscretizeFunction.Evaluate(aArgs: IntArray): DexiValue;
begin
  result := nil;
  if (length(aArgs) <> 1) or (ArgCount <> 1) then
    exit;
  result := DexiValue.SimplifyValue(FunctionValue(aArgs[0]));
end;

method DexiDiscretizeFunction.Evaluate(aArgs: FltArray): DexiValue;
begin
  result := nil;
  if (length(aArgs) <> 1) or (ArgCount <> 1) then
    exit;
  result := DexiValue.SimplifyValue(FunctionValue(aArgs[0]));
end;

method DexiDiscretizeFunction.SaveToStringList(aSettings: DexiSettings): List<String>;
begin
  result := new List<String>;
  if (Attribute:Scale = nil) or (OutValCount < 0) then
    exit;
  var ss := new DexiScaleStrings;
  ss.ValueType := aSettings.FncDataType;
  var sb := new StringBuilder;
  sb.Append(Utils.TabChar);
  for i := 0 to ArgCount - 1 do
    begin
      sb.Append(Attribute.Inputs[i].Name);
      sb.Append(Utils.TabChar);
      sb.Append(Utils.TabChar);
    end;
  sb.Append(Attribute.Name);
  result.Add(sb.ToString);
  for j := 0 to Count - 1 do
    begin
      if j > 0 then
        begin
          sb.Clear;
          sb.Append(Utils.TabChar);
          sb.Append(Utils.FltToStr(BoundValue[j], true));
          sb.Append(Utils.TabChar);
          sb.Append(if Bound[j].Association = DexiBoundAssociation.Down then ']' else '[');
          sb.Append(Utils.TabChar);
          result.Add(sb.ToString);
        end;
    if aSettings.FncDataAll or IntervalEntered[j] then
      begin
        sb.Clear;
        sb.Append(Utils.IntToStr(j + 1));
        sb.Append(Utils.TabChar);
        sb.Append(Utils.TabChar);
        sb.Append(Utils.TabChar);
        sb.Append(ss.ValueOnScaleString(IntervalValue[j], Attribute.Scale));
        if aSettings.FncDataAll then
          begin
            sb.Append(Utils.TabChar);
            sb.Append(if IntervalEntered[j] then '+' else '-');
          end;
        result.Add(sb.ToString);
      end;
    end;
end;

method DexiDiscretizeFunction.LoadFromStringList(aList: ImmutableList<String>; aSettings: DexiSettings; out aLoaded, aChanged: Integer);
var
  ss: DexiScaleStrings;

  method ParseLine(aLoadLine: Integer): ImmutableList<String>;
  begin
    var lLine := aList[aLoadLine];
    result := lLine.Split(Utils.TabChar);
  end;

  method ReadBound(aLine: ImmutableList<String>): DexiBound;
  begin
    result := nil;
    if (aLine = nil) or (aLine.Count < 3) then
      exit;
    var lBound := Convert.TryToDouble(aLine[1], Locale.Invariant);
    if lBound = nil then
      exit;
    var lAssoc := if aLine[2] = ']' then DexiBoundAssociation.Down else DexiBoundAssociation.Up;
    result := new DexiBound(lBound, lAssoc);
  end;

  method ReadValueCell(aLine: ImmutableList<String>; out aInterval: Integer): DexiValueCell;
  begin
    result := nil;
    if (aLine = nil) or (aLine.Count < 4) then
      exit;
    var lInterval := Convert.TryToInt32(aLine[0]);
    if lInterval = nil then
      exit;
    aInterval := lInterval - 1;
    var lParse := ss.TryParseScaleValue(aLine[3], Attribute.Scale);
    if lParse.Value <> nil then
      begin
        var lEntered :=
          if aLine.Count <= 4 then true
            else aLine[4] = '+';
        result := new DexiValueCell(lParse.Value, lEntered);
      end;
  end;

begin
  aLoaded := 0;
  aChanged := 0;
  if (aList = nil) or (aList.Count = 0) then
    exit;
  if not DexiDiscretizeFunction.CanCreateOn(Attribute) then
    exit;
  ss := new DexiScaleStrings;
  ss.ValueType := aSettings.FncDataType;
  var lFunct := new DexiDiscretizeFunction(Attribute);
  for lLoadLine := 0 to aList.Count - 1 do
    begin
      var lLine := ParseLine(lLoadLine);
      var lBound := ReadBound(lLine);
      if lBound <> nil then
        begin
          lFunct.AddBound(lBound);
          inc(aLoaded);
        end;
    end;
  for lLoadLine := 0 to aList.Count - 1 do
    begin
      var lLine := ParseLine(lLoadLine);
      var lInterval: Integer;
      var lValueCell := ReadValueCell(lLine, out lInterval);
      if (lValueCell <> nil) and (0 <= lInterval < lFunct.IntervalCount) then
        begin
          lFunct.ValueCell[lInterval] := lValueCell;
          inc(aChanged);
        end;
    end;
  if (aLoaded > 0) or (aChanged > 0) then
    AssignFunction(lFunct);
end;

{$ENDREGION}

end.

