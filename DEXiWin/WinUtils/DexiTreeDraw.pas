// DexiTreeDraw.pas is part of
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
// DexiTreeDraw.pas implements the top-level DEXiWin tree drawing algorithm that connects
// WinTreeDraw.pas with actual DEXi models, DEXiWin format settings and users' selection
// of nodes to display.
// ----------

namespace DexiWin;

interface

 uses
  System.Drawing,
  System.Drawing.Drawing2D,
  System.Windows.Forms,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  DexiTreeDrawingAlgorithm = public class (WinTreeDrawingAlgorithm)
  private
    fModel: weak DexiModel;
    fFormats: TreeNodeFormat;
    fPrunedAttributes := new List<DexiAttribute>;
    fSelectedAttributes := new List<DexiAttribute>;
    fAssignedFormats := new Dictionary<DexiAttribute, TreeNodeFormat>;
  protected
    method MakeFormats;
    method SetDefaults;
  public
    method DefaultClass(aAttribute: DexiAttribute): String;
    method AssignedClass(aAttribute: DexiAttribute): String;
    method DefaultFormat(aAttribute: DexiAttribute): TreeNodeFormat;
    method AssignedFormat(aAttribute: DexiAttribute): TreeNodeFormat;
    method CommonFormat(aAttributes: List<DexiAttribute>): TreeNodeFormat;
    constructor (aModel: DexiModel);
    method Cleanup;
    method MakeNodes;
    method Restructure;
    property Formats: TreeNodeFormat read fFormats;
    property SelectedAttributes: List<DexiAttribute> read fSelectedAttributes;
    property PrunedAttributes: List<DexiAttribute> read fPrunedAttributes;
    property AssignedFormats: Dictionary<DexiAttribute, TreeNodeFormat> read fAssignedFormats;
  end;

type
  DexiTreeDrawNode = public class (WinTreeDrawNode)
  private
    fAttribute: DexiAttribute;
  protected
    method GetDexiDrawingAlgorithm: DexiTreeDrawingAlgorithm;
    method GetNodeClass: String; override;
    method SetNodeClass(aClass: String); override;
    method GetNodeFormat: TreeNodeFormat; override;
    method SetNodeFormat(aFormat: TreeNodeFormat); override;
    method GetIsSelected: Boolean; override;
  public
    constructor (aAttribute: DexiAttribute);
    property DrawingAlgorithm: DexiTreeDrawingAlgorithm read GetDexiDrawingAlgorithm; reintroduce;
    property Attribute: DexiAttribute read fAttribute write fAttribute;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiTreeDrawingAlgorithm}

constructor DexiTreeDrawingAlgorithm(aModel: DexiModel);
require
  aModel <> nil;
begin
  inherited constructor(nil);
  fModel := aModel;
  MakeFormats;
  SetDefaults;
end;

method DexiTreeDrawingAlgorithm.MakeFormats;
begin
  fFormats := new TreeNodeFormat('all',
    Font := SystemFonts.DefaultFont,
    FontBrush := new BrushData(Color.Black),
    LinePen := new PenData(Color.Black),
    NodePen := new PenData(Color.Black),
    NodeBrush := new BrushData(Color.White));
  var lBasic := fFormats.AddChild('basic');
  var lAggregate := fFormats.AddChild('aggregate');
  fFormats.AddChild('link');
  lBasic.AddChild('discrete');
  lBasic.AddChild('continuous');
  lAggregate.AddChild('root');
  lAggregate.AddChild('pruned');
end;

method DexiTreeDrawingAlgorithm.SetDefaults;
begin
  VirtualRoot := true;
  Border := new ImgBorder(5, 5, 5, 5);
  LevelSeparation := 50;
  MinLevelSeparation := 10;
  NodeSeparation := 10;
  AlignLevels := true;
  AlignParents := TreeAlignParents.Subtree;
  DrawMethod := TreeDrawMethod.Walker;
  XStretch := 1.0;
  YStretch := 1.0;
  XOffset := 0;
  YOffset := 0;
end;

method DexiTreeDrawingAlgorithm.DefaultClass(aAttribute: DexiAttribute): String;
begin
  if aAttribute = nil then
    exit nil;
  var lIsRoot := aAttribute.IsRoot or (VirtualRoot and DexiAttribute.AttributeIsRoot(aAttribute.Parent));
  result :=
    if lIsRoot then 'root'
    else if aAttribute.IsLinked then 'link'
    else if aAttribute.IsAggregate then
      if fPrunedAttributes.Contains(aAttribute) then 'pruned'
      else 'aggregate'
    else if aAttribute.IsBasic then
      if aAttribute.Scale = nil then 'basic'
      else if aAttribute.Scale.IsContinuous then 'continuous'
      else 'discrete'
    else 'all';
end;

method DexiTreeDrawingAlgorithm.AssignedClass(aAttribute: DexiAttribute): String;
begin
  result :=
    if fAssignedFormats.ContainsKey(aAttribute) then fAssignedFormats[aAttribute].FormatClass
    else DefaultClass(aAttribute);
end;

method DexiTreeDrawingAlgorithm.DefaultFormat(aAttribute: DexiAttribute): TreeNodeFormat;
begin
  var lFormat := fFormats.Find(DefaultClass(aAttribute));
  result :=
    if lFormat = nil then fFormats
    else lFormat;
end;

method DexiTreeDrawingAlgorithm.AssignedFormat(aAttribute: DexiAttribute): TreeNodeFormat;
begin
  result :=
    if fAssignedFormats.ContainsKey(aAttribute) then fAssignedFormats[aAttribute]
    else DefaultFormat(aAttribute);
end;

method DexiTreeDrawingAlgorithm.CommonFormat(aAttributes: List<DexiAttribute>): TreeNodeFormat;

  method CommonPath(aMain, aPath: List<TreeNodeFormat>);
  begin
    var lCommonLength := 0;
    for x := 0 to Math.Min(aMain.Count, aPath.Count) - 1 do
      if aMain[x] = aPath[x] then
        inc(lCommonLength)
      else
        break;
    for x := aMain.Count - 1 downto lCommonLength do
      aMain.RemoveAt(x);
  end;

begin
  result := fFormats;
  if (aAttributes = nil) or (aAttributes.Count = 0) then
    exit;
  var lAssignedFormats := new List<TreeNodeFormat>;
  var lDefaultFormats := new List<TreeNodeFormat>;
  for each lAtt in aAttributes do
    begin
      var lFmt := AssignedFormat(lAtt);
      if not lAssignedFormats.Contains(lFmt) then
        lAssignedFormats.Add(lFmt);
      lFmt := DefaultFormat(lAtt);
      if not lDefaultFormats.Contains(lFmt) then
        lDefaultFormats.Add(lFmt);
    end;
  if lAssignedFormats.Count = 1 then
    exit lAssignedFormats[0];
  if lDefaultFormats.Count = 1 then
    exit lDefaultFormats[0];
  var lPath := lDefaultFormats[0].ParentPath;
  for i := 1 to lDefaultFormats.Count - 1 do
    begin
      var lFmt := lDefaultFormats[i];
      var lFmtPath := lFmt.ParentPath;
      CommonPath(lPath, lFmtPath);
    end;
  result := lPath.Last;
end;

method DexiTreeDrawingAlgorithm.Cleanup;
begin
  if fModel = nil then
    begin
      fPrunedAttributes.RemoveAll;
      fAssignedFormats.RemoveAll;
      exit;
    end;
  var lAttributes := fModel.Root.CollectInputs(false);
  var lToRemove := new List<DexiAttribute>;
  for each lAtt in fPrunedAttributes do
    if not lAttributes.Contains(lAtt) then
      lToRemove.Add(lAtt);
  for each lAtt in lToRemove do
    fPrunedAttributes.Remove(lAtt);
  lToRemove.RemoveAll;
  for each lAtt in fAssignedFormats.Keys do
    if not lAttributes.Contains(lAtt) then
      lToRemove.Add(lAtt);
  for each lAtt in lToRemove do
    fAssignedFormats.Remove(lAtt);
end;

method DexiTreeDrawingAlgorithm.MakeNodes;

  method CreateTree(aAtt: DexiAttribute; aNode: TreeDrawNode);
  begin
    if fPrunedAttributes.Contains(aAtt) then
      exit;
    for i := 0 to aAtt.InpCount - 1 do
      begin
        var lInp := aAtt.Inputs[i];
        var lNode := new DexiTreeDrawNode(lInp);
        aNode.AddChild(lNode);
        CreateTree(lInp, lNode);
      end;
   end;

require
  fModel <> nil;
begin
  Cleanup;
  Root := new DexiTreeDrawNode(fModel.Root);
  CreateTree(fModel.Root, Root);
end;

method DexiTreeDrawingAlgorithm.Restructure;
begin
  MakeNodes;
end;

{$ENDREGION}

{$REGION DexiTreeDrawNode}

constructor DexiTreeDrawNode(aAttribute: DexiAttribute);
require
  aAttribute <> nil;
begin
  inherited constructor (aAttribute.Name);
  fAttribute := aAttribute;
end;

method DexiTreeDrawNode.GetDexiDrawingAlgorithm: DexiTreeDrawingAlgorithm;
begin
  result := GetWinDrawingAlgorithm as DexiTreeDrawingAlgorithm;
end;

method DexiTreeDrawNode.GetNodeClass: String;
begin
  result := DrawingAlgorithm.AssignedClass(self.fAttribute);
end;

method DexiTreeDrawNode.SetNodeClass(aClass: String);
begin
  if String.IsNullOrEmpty(aClass) then
    begin
      NodeFormat := nil;
      exit;
    end;
  var lOldFormat := NodeFormat;
  var lClsFormat := DrawingAlgorithm.Formats.Find(aClass);
  if (lOldFormat <> nil) and (lOldFormat = lClsFormat) then
    exit;
  var lNewFormat :=
    if lClsFormat <> nil then lClsFormat
    else new TreeNodeFormat(aClass, lOldFormat);
  NodeFormat := lNewFormat;
end;

method DexiTreeDrawNode.GetNodeFormat: TreeNodeFormat;
begin
  result := DrawingAlgorithm.AssignedFormat(self.fAttribute);
end;

method DexiTreeDrawNode.SetNodeFormat(aFormat: TreeNodeFormat);
begin
  if DrawingAlgorithm.AssignedFormats.ContainsKey(fAttribute) then
    if aFormat = nil then
      DrawingAlgorithm.AssignedFormats.Remove(fAttribute)
    else
      DrawingAlgorithm.AssignedFormats[fAttribute] := aFormat
  else if aFormat <> nil then
    DrawingAlgorithm.AssignedFormats.Add(fAttribute, aFormat);
end;

method DexiTreeDrawNode.GetIsSelected: Boolean;
begin
  result := DrawingAlgorithm.SelectedAttributes.Contains(fAttribute);
end;

{$ENDREGION}

end.
