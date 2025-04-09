// DexiStrings.pas is part of
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
// DexiStrings.pas implements the static class DexiString containing constant message strings
// in the format suitable for String.Format.
// ----------

namespace DexiLibrary;

type
  DexiString = public static class
  public
    property DexSoftware: String := '';
    const
      NonBreakingSpace = #$00A0;
      MinusSign = #$2212;
      PlusSign = #$002B;
      ADexiDestroyingDestroyed = 'Trying to destroy an already destroyed object "{0}"';
      ADexiObjectNotFreed = '{0} pending objects upon exit';

      SDexiListIndex = 'List index "{0}" is out of bounds [0,{1}]';

      SDexiCaption = '{0} [{1}{2}]';

      SDexiFileLoad = 'Error loading file "{0}"';
      SDexiFileFormat = 'Unsupported file format: "{0}"';
      SDexiListFormat = 'Unsupported string format';
      SDexiMainEval = 'Evaluation';
      SDexiReadOnly = '[Editing Disabled]';
      SDexiStatistics = 'Attributes: {0} ({1} basic, {2} linked, {3} aggregate)   |   Scales: {4}   |   Functions: {5}   |   Options: {6}';
      SDexiNewAttribute = 'New';
      SDexiNewAlternative = 'New';
      SDexiAddBasic = 'Adding a new attribute will delete the function "{0}".'+ #13 +
                    'Do you still want to add a new attribute?';
      SDexiDelBasic = 'Do you want to delete basic attribute "{0}"?';
      SDexiCutAtt = 'Do you want to cut attribute "{0}"?';
      SDexiDelOpt = 'Do you want to delete option "{0}"?';
      SDexiDelChildren = 'Do you want to delete subtree "{0}"?';
      SDexiDeletingFunction = 'This will also delete the function of the attribute.';
      SDexiDeletingAttFunction = 'This will also delete the function of attribute "{0}".';
      SDexiCuttingAttFunction = 'Cutting this subtree will delete the function "{0}".'+ #13 +
                              'Do you still want to cut the subtree?';
      SDexiPastingAttFunction = 'Pasting this subtree will delete the function "{0}".'+ #13 +
                              'Do you still want to paste the subtree?';
      SDexiMovingAttFunction = 'Moving subtree "{0}" to "{1}" will delete the function of "{2}".'+ #13 +
                               'Move anyway?';
      SDexiMovingAttFunctions = 'Moving subtree "{0}" to "{1}" will delete the functions of "{2}" and "{3}".'+ #13 +
                                'Move anyway?';
      SDexiDelScaleFunction = 'Deleting the scale of "{0}" will also delete the function of "{1}".'+ #13 +
                               'Delete anyway?';
      SDexiDelScaleFunctions = 'Deleting the scale of "{0}" will also delete the functions of "{1}" and {2}.'+ #13 +
                               'Delete anyway?';
      SDexiReverseScaleFunction = 'Reversing the scale of "{0}" will affect the function of "{1}".'+ #13 +
                               'Reverse anyway?';
      SDexiReverseScaleFunctions = 'Reversing the scale of "{0}" will affect the functions of "{1}" and {2}.'+ #13 +
                               'Reverse anyway?';
      SDexiEditScaleFunction = 'Editing the scale of "{0}" may affect the function of "{1}".'+ #13 +
                               'Edit anyway?';
      SDexiEditScaleFunctions = 'Editing the scale of "{0}" may affect the functions of "{1}" and {2}.'+ #13 +
                               'Edit anyway?';
      SDexiFileExists = 'File "{0}" already exists. Do you want to overwrite this file?';
      SDexiFileSave = 'Do you want to save the model "{0}" to file "{1}"?';
      SDexiNewFileSave = 'Do you want to save the model "{0}" to a file?';
      SDexiUndefValueOperation = 'Attempted operation on an undefined value: "{0}"';
      SDexiUndefValue = '?';
      SDexiUndefinedValue = '<undefined>';
      SDexiUndefined = 'Undefined';
      SDexiNullScale = 'Undefined';
      SDexiNullFunct = 'Undefined';
      SDexiUnsupportedScale = 'Unsupported scale: {0}';
      SDexiNewScaleValue = 'new';
      SDexiScaleValue1 = 'value1';
      SDexiScaleValue2 = 'value2';
      SDexiJDexFunctName = 'Unknown function "{0}"';
      SDexiJDexAttrList = 'Error in function parameters "{0}": "{1}"';
      SDexiJDexCannotCreate = 'Cannot create function "{0}"';
      SDexiJDexUnknownScaleValue = 'Unknown attribute value "{0}": "{1}"';
      SDexiDaxChainWarning = 'Input file contains chain attributes, which will not be automatically linked by DEXi.'#13;
      SDexiDaxGrpWarning = 'Input file contains more than one group of functions. DEXi will use only the first one.'#13;
      SDexiDaxValWarning = 'Input file includes distributions, which are anly partially supported by DEXi. Some data may be lost.'#13;
      SSetTextError = 'Data read error: [Attribute {0}, Option {1}] Value "{2}"';
      SDexiTabFncImport = 'Import function: imported rules: {0}; changed values: {1}';
      SDexiDiscrFncImport = 'Import function: bounds: {0}; intervals: {1}';
      SDexiTabFncPaste = 'Paste function: imported rules: {0}; changed values: {1}';
      SDexiAttNotFound = 'Attribute not found: {0}';
      SDexiRuleNotFound = 'Rule not found: {0}';
      SDexiFrptDetermined = 'Function is not fully determined: {0}%';
      SDexiFrptNoMap = 'Function does not map to value(s): {0}';
      SDexiFrptInconsistent = 'Function has {0} inconsistent rule(s)';
      SDexiFrptDescending = 'Function space uses {0} descending scales; scale reversal is advised';
      SDexiFrptNotAffects = 'Attribute {0} does not influence function value';
      SDexiFrptPairEqual = 'Attribute "{0}": values ''{1}'' and ''{2}'' equally affect function value';
      SDexiValueError = 'Errorneous value(s): "{0}"';
      SDexiIntValueError = 'Errorneous Integer value(s): "{0}"';
      SDexiFltValueError = 'Errorneous Float value(s): "{0}"';
      SDexiIntervalValueError = 'Errorneous interval value(s): "{0}"';
      SDexiValueParseError = 'Error parsing "{0}"';
      SDexiValueParseNullScale = 'Undefined scale context for parsing "{0}"';
      SDexiValueParseOutOfBounds = 'Error parsing "{0}": Value is out of bounds';
      SDexiValueParseInt = 'Error parsing "{0}": Undefined discrete value "{1}"';
      SDexiValueParseFlt = 'Error parsing "{0}": Float value expected instead "{1}"';
      SValueOutOfAttBounds = 'Value "{0}" is out of bounds of attribute "{1}"';
      SDexiEvaluationArguments = 'Erroneous function arguments while evaluating alternative "{1}" at attribute "{0}"';
      SDexiFeatureEval = 'Extended evaluation-control settings';
      SDexiFeatureContScales = 'Continuous scales: {0}';
      SDexiFeatureNonTabFuncts = 'Non-tabular functions: {0}';
      SDexiFeatureExtFuncts = 'Functions using extended value types: {0}';
      SDexiFeatureContData = 'Continuous data about alternatives';
      SDexiDynSource = 'Duplicate dynamic link source: "{0}"';
      SDexiDynIncompatible = 'Incompatible dynamic link scales: "{0}" and "{1}"';
      SDexiDynCannotEvaluate = 'Dynamic evaluator cannot be used for static evaluation of alternatives';
      SDexiGenNilAttribute = 'Attempted to add a NULL attribute';
      SDexiGenLinkedAttribute = 'Attempted to add a linked attribute: "{0}"';
      SDexiGenScale = 'Attempted to add an attribute with an inappropriate scale: "{0}"';
      SDexiGenFunct = 'Attempted to add an attribute with an inappropriate function: "{0}"';
      SDexiGenNilScales = 'Attribute hierarchy contains {0} attribute(s) with undefined or inappropriate scales';
      SDexiGenNilFuncts = 'Attribute hierarchy contains {0} attribute(s) with undefined or inappropriate functions';
      SDexiGenNoAlternative = 'No alternative defined';
      SDexiGenUndefGoal = 'The current alternative has undefined value(s) of the goal attribute';
      SDexiQQOutValues = 'At least two output values required for QQ evaluation';
      SDexiQQArgs = 'At least one function argument required for QQ evaluation';
      SDexiMultilinFunct = "Function is not fully determined and is thus unsuitable for multilinear interpolation";

      SPathSeparator = '/';
      SPathSeparators: array of String = [SPathSeparator, '|', '\', '#', '&', '@', '$', '_', ';', ':', '.', ',', '?', '!', '=', '*', '+', '^', '%'];
      SConcatenateValue = '+';
      SUndefValueShort = '?';
      SUndefValueLong = 'undefined';
      SUndefValueLongLeft = '<';
      SUndefValueLongRight = '>';
      SPrefEq = '=';
      SPrefWorse = '<';
      SPrefBetter = '>';
      SPrefNone = '?';
      SWorseEq = '<=';
      SBetterEq = '>=';
      SListSeparator = ';';
      SIntervalSeparator = ':';
      SFullInterval = '*';
      SDistrSeparator = '/';
      SImprecise = '~';
      SContinuous = 'continuous';
      SAscending = 'ascending';
      SDescending = 'descending';
      SUnordered = 'unordered';
      SDiscrete = 'discrete';
      SUnitLeft = '[';
      SUnitRight = ']';
      SCategoryLeft = '<';
      SCategoryRight = '>';
      SScaleSeparator = ' ';
      SOffsetPlus = '+';
      SLevelText = '. ';

      MStrFunctionUndef = 'Undefined';
      MStrFunctionRule = 'Rules:';
      MStrFunctionInterval = 'Intervals:';
      MStrFunctionDef = 'determined:';
      MStrRootName = 'Root';

      // Report strings
      RReport = 'Report';
      RPage = 'Page ';
      RModDesc = 'Model description';
      RModStat = 'Model statistics';
      RModName = 'Model name';
      RSclName = 'Scale name';
      RFncName = 'Function name';
      RModDim = 'Model dimensions';
      RModDepth = 'Depth';
      RAverageWidth = 'Average width';
      RMin = 'Min';
      RMax = 'Max';
      RAttributes = 'Attributes';
      RBasic = 'Basic';
      RAggregate = 'Aggregate';
      RLinked = 'Linked';

      RTree = 'Attribute tree';
      RDescriptions = 'Attribute descriptions';
      REvaluationResults = 'Evaluation results';
      RQQEvaluationResults = 'Qualitative-Quantitative evaluation results';
      RAlternatives = 'Alternatives';
      RScale = 'Scale';
      RScales = 'Scales';
      RDiscrete = 'Discrete';
      RContinuous = 'Continuous';
      RUndefined = 'Undefined';
      RFunction = 'Function';
      RTabular = 'Tabular';
      RDiscretize = 'Discretize';
      RFunctionWithName = 'Function {0}';
      RFunctions = 'Functions';
      RAverageSize = 'Average size';
      RDescription = 'Description';
      RAlternative = 'Alternative';
      RAttribute = 'Attribute';
      RAttDescription = 'Attribute descriptions';
      RAttScales = 'Scales';
      RAttFunctions = 'Functions';
      RAttFncInformation = 'Function information';
      RAttInformation = 'Attribute information';
      RSclUndefined = 'Undefined scale';
      RFncUndefined = 'Undefined function';
      RFncParentUndefined = 'Undefined parent function';
      RFncFrom = 'From';
      RFncTo = 'To';
      RLinear = 'Linear';
      RQQ1 = 'QQ1';
      RQQ2 = 'QQ2';
      RItems = 'Items';
      RDefined = 'Defined';
      RDetermined = 'Determined';
      RStatus = 'Status';
      RValues='Values';
      RAttFncSummary ='Function summary';
      RSelectiveExplanation = 'Selective explanation';
      RWeakPoints = 'Weak points';
      RStrongPoints = 'Strong points';
      RNormalizedMarginalValues = 'Normalized marginal values';
      RMarginalValues = 'Marginal values';
//      RAttribute='Attribute';
//      RDomain='Scale';
//      RDecisionRule='Tables';
//      RFunctionStatus='Function status';
      RAverageWeights = 'Average weights';
      RWeightsTree = 'Weights tree';
      RLocal = 'Local';
      RGlobal = 'Global';
      RLocNorm = 'Loc.norm.';
      RGlobNorm = 'Glob.norm.';
      RAltCompare = 'Compare alternatives';
      RNone = 'None';
      RPlusMinus = 'Plus/Minus analysis';
      RTarget = 'Target analysis';
      RAltGenNoResults = 'No results found';
      RRooted = 'All model subtrees';
      RChart = 'Chart';
      RImageUndefined = 'Undefined image';
//      RDecisionRules='Decision rules';
//      RGraph='Chart';
//      RUndef='<undefined>';
//      ROptGen='Option generator';
//      RSelExplain='Selective explanation';
//      RSelPlus='Strong points';
//      RSelMinus='Weak points';
      RTreeView = 'Tree view';

      CUndefinedScale = 'Undefined scale';
      CUndefinedScaleBorders = 'Undefined scale borders';

      //  Json
      JObjectExpected = 'Json object expected with key "{0}"';
      JArrayExpected = 'Json array expected with key "{0}"';
      JArrayExpectedSet = 'Array expected for set-type values of attribute "{0}"';
      JDistrExpected = 'Value distribution expected at attribute "{0}"';
      JStringExpected = 'String value expected with Json key "{0}"';
      JBooleanExpected = 'Boolean value expected with Json key "{0}"';
      JIntegerExpected = 'Integer value expected with Json key "{0}"';
      JFloatExpected = 'Float value expected with Json key "{0}"';
      JUnresolvedAttributes = 'Input attributes missing in Json document with alternative {0}: {1}';
      JDuplicateAttributes = 'Duplicate attributes found in Json document with alternative {0}: {1}';
      JIgnoredAttributes = 'Attributes ignored while reading data of alternative {0}: {1}';
      JUnknownAttribute = 'Attribute not found: "{0}"';
      JUndefinedScale = 'Undefined attribute scale: "{0}"';
      JUndefinedCategory = 'Undefined category for attribute "{1}": "{0}"';
      JAttValueOutOfRange = 'Value {1} is out of range for attribute "{0}"';
  end;

end.
