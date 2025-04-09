// TreeDraw.pas is part of
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
// TreeDraw.pas implements three tree-drawing algorithms:
// - BottomUp: allocates space in a bottom-up way starting with each terminal node
// - Walker's algorithm: BottomUp + optimization of space between subtrees
// - QP (Quadratic-Programming): formulated and solved as a quadratic optimization problem
//
// The algorithms in this file do not render trees on any particular device,
// but rather position tree nodes to give an aesthetically pleasing rendering of the tree.
//
// For further information about the design and purpose of the algorithms, please see:
// Marko Bohanec: DEXiTree: A program for pretty drawing of trees.
//   Proc. Information Society IS 2007, Ljubljana, 8-11, 2007.
//   https://kt.ijs.si/MarkoBohanec/pub/IS2007_DEXiTree.pdf
//
// For a working implementation with examples, see https://kt.ijs.si/MarkoBohanec/dexitree.html
// ----------

namespace DexiUtils;

interface

 uses
  RemObjects.Elements.RTL;

type
  ETreeError = public class(Exception);

const
  STreeCannotInsertToRoot = 'Cannot insert new node "{0}" near to root';
  STreeCircularMove = 'Attempted a circular move of node "{0}"';

type
  TreeOrientation = public enum (TopDown, LeftRight, BottomUp, RightLeft);
  TreeAlignParents = public enum (Descendants, Subtree);
  TreeDrawMethod = public enum (BottomUp, Walker, QP);

type
  TreeDrawNode = public class
  private
    fTreeDrawing: weak TreeDrawingAlgorithm;
    fParent: TreeDrawNode;
    fFirstChild: TreeDrawNode;
    fLastChild: TreeDrawNode;
    fNextChild: TreeDrawNode;
    fChildCount: Integer;
    fPrevChild: TreeDrawNode;
    fLeftNode: TreeDrawNode;
    fRightNode: TreeDrawNode;
    fXPos: Float;
    fXMod: Float;
    fYPos: Float;
    fIdx: Integer;
   protected
    method GetText: String; virtual;
    method GetCount: Integer; virtual;
    method GetIsTerminal: Boolean; virtual;
    method GetLevel: Integer;
    method GetIndex: Integer;
    method GetItem(aIdx: Integer): TreeDrawNode;
    method GetPrevChild: TreeDrawNode;
    method GetLeftNode: TreeDrawNode;
    method GetRightNode: TreeDrawNode;
    method GetWidth: Float; virtual;
    method GetLeftWidth: Float; virtual;
    method GetRightWidth: Float; virtual;
    method GetHeight: Float; virtual;
    method GetTopHeight: Float; virtual;
    method GetBottomHeight: Float; virtual;
    method GetBefore: Float;
    method GetAfter: Float;
    method GetAbove: Float;
    method GetBelow: Float;
    method GetXPosition: Float;
    method GetYPosition: Float;
    method GetFltX: Float;
    method GetFltY: Float;
    method GetFltX0: Float;
    method GetFltY0: Float;
    method GetFltX1: Float;
    method GetFltY1: Float;
    method GetX: Integer;
    method GetY: Integer;
    method GetX0: Integer;
    method GetY0: Integer;
    method GetX1: Integer;
    method GetY1: Integer;
   public
    method DescendantOf(aNode: TreeDrawNode): Boolean;
    method AddChild(aNode: TreeDrawNode): TreeDrawNode;
    method InsertLeft(aNode: TreeDrawNode): TreeDrawNode;
    method InsertRight(aNode: TreeDrawNode): TreeDrawNode;
    method MoveToLeft(aNode: TreeDrawNode): TreeDrawNode;
    method MoveToRight(aNode: TreeDrawNode): TreeDrawNode;
    method Pull: TreeDrawNode;
    method Prune;
    method Modified;
    method IsVirtual: Boolean;
    property TreeDrawing: TreeDrawingAlgorithm read fTreeDrawing write fTreeDrawing;
    property Text: String read GetText;
    property Count: Integer read GetCount;
    property IsTerminal: Boolean read GetIsTerminal;
    property Parent: TreeDrawNode read fParent write fParent;
    property Level: Integer read GetLevel;
    property &Index: Integer read GetIndex;
    property FirstChild: TreeDrawNode read fFirstChild write fFirstChild;
    property LastChild: TreeDrawNode read fLastChild write fLastChild;
    property NextChild: TreeDrawNode read fNextChild write fNextChild;
    property PrevChild: TreeDrawNode read GetPrevChild write fPrevChild;
    property Item[aIdx: Integer]: TreeDrawNode read GetItem;
    property LeftNode: TreeDrawNode read GetLeftNode write fLeftNode;
    property RightNode: TreeDrawNode read GetRightNode write fRightNode;
    property Width: Float read GetWidth;
    property LeftWidth: Float read GetLeftWidth;
    property RightWidth: Float read GetRightWidth;
    property Height: Float read GetHeight;
    property TopHeight: Float read GetTopHeight;
    property BottomHeight: Float read GetBottomHeight;
    property Before: Float read GetBefore;
    property After: Float read GetAfter;
    property Above: Float read GetAbove;
    property Below: Float read GetBelow;
    property XPos: Float read fXPos write fXPos;
    property XMod: Float read fXMod write fXMod;
    property YPos: Float read fYPos write fYPos;
    property Idx: Integer read fIdx write fIdx;
    property XPosition: Float read GetXPosition;
    property YPosition: Float read GetYPosition;
    property FltX: Float read GetFltX;
    property FltY: Float read GetFltY;
    property FltX0: Float read GetFltX0;
    property FltY0: Float read GetFltY0;
    property FltX1: Float read GetFltX1;
    property FltY1: Float read GetFltY1;
    property X: Integer read GetX;
    property Y: Integer read GetY;
    property X0: Integer read GetX0;
    property Y0: Integer read GetY0;
    property X1: Integer read GetX1;
    property Y1: Integer read GetY1;
  end;

type
  TreeDrawingAlgorithm = public class
  private
    fRoot: TreeDrawNode;
    fVirtualRoot: Boolean;
    fModifiedStructure: Boolean;
    fModifiedNodes: Boolean;
    fDrawMethod: TreeDrawMethod;
    fOrientation: TreeOrientation;
    fLevelSeparation: Float;
    fMinLevelSeparation: Float;
    fNodeSeparation: Float;
    fAlignTerminals: Boolean;
    fAlignLevels: Boolean;
    fAlignParents: TreeAlignParents;
    fLeft: Float;
    fHeight: Float;
    fLevels: Integer;
    fLevelFirst: array of TreeDrawNode;
    fLevelLast: array of TreeDrawNode;
    fXMirror: Boolean;
    fYMirror: Boolean;
    fXOffset: Float;
    fYOffset: Float;
    fXSize: Float;
    fYSize: Float;
    fWidth: Float;
    fXStretch: Float;
    fYStretch: Float;
  protected
    method SetRoot(aRoot: TreeDrawNode);
    method SetDrawMethod(aMethod: TreeDrawMethod);
    method SetOrientation(aOrientation: TreeOrientation);
    method SetLevelSeparation(aSeparation: Float);
    method SetMinLevelSeparation(aSeparation: Float);
    method SetNodeSeparation(aSeparation: Float);
    method SetAlignTerminals(aAlign: Boolean);
    method SetAlignLevels(aAlign: Boolean);
    method SetAlignParents(aAlign: TreeAlignParents);
    method SetXStretch(aStretch: Float);
    method SetYStretch(aStretch: Float);
    method SetXSize(aSize: Float);
    method SetYSize(aSize: Float);
    method GetWidth: Float;
    method GetHeight: Float;
    method GetW: Integer;
    method GetH: Integer;
    method GetXS: Integer;
    method GetYS: Integer;
    method GetX0: Integer;
    method GetY0: Integer;
    method GetX1: Integer;
    method GetY1: Integer;
    method GetLevelY(aLev: Integer): Float;
    method GetLevelAbove(aLev: Integer): Float;
    method GetLevelBelow(aLev: Integer): Float;
    method GetXMirror: Boolean; virtual;
    method GetYMirror: Boolean; virtual;
    method MakeLevels;
    method Align(aNode: TreeDrawNode; aMod: Float);
    method Shift(aNode: TreeDrawNode; aMod: Float);
    method PlaceBottomUp; virtual;
    method PlaceWalker; virtual;
    method PlaceSubtrees; virtual;
    method PlaceLevels; virtual;
  public
    constructor;
    method AssureLinks;
    method AssurePlacement;
    method TransX(X: Float): Float; virtual;
    method TransY(Y: Float): Float; virtual;
    method ModifiedStructure;
    method Modified;
    method Place; virtual;
    method LevelSize(aLev: Integer; out aAbove, aBelow: Float);
    property Root: TreeDrawNode read fRoot write SetRoot;
    property VirtualRoot: Boolean read fVirtualRoot write fVirtualRoot;
    property DrawMethod: TreeDrawMethod read fDrawMethod write SetDrawMethod;
    property Orientation: TreeOrientation read fOrientation write SetOrientation;
    property LevelSeparation: Float read fLevelSeparation write SetLevelSeparation;
    property MinLevelSeparation: Float read fMinLevelSeparation write SetMinLevelSeparation;
    property NodeSeparation: Float read fNodeSeparation write SetNodeSeparation;
    property LevelAbove[aLev: Integer]: Float read GetLevelAbove;
    property LevelBelow[aLev: Integer]: Float read GetLevelBelow;
    property LevelY[aLev: Integer]: Float read GetLevelY;
    property XMirror: Boolean read GetXMirror write fXMirror;
    property YMirror: Boolean read GetYMirror write fYMirror;
    property AlignTerminals: Boolean read fAlignTerminals write SetAlignTerminals;
    property AlignLevels: Boolean read fAlignLevels write SetAlignLevels;
    property AlignParents: TreeAlignParents read fAlignParents write SetAlignParents;
    property XOffset: Float read fXOffset write fXOffset;
    property YOffset: Float read fYOffset write fYOffset;
    property XStretch: Float read fXStretch write SetXStretch;
    property YStretch: Float read fYStretch write SetYStretch;
    property XSize: Float read fXSize write SetXSize;
    property YSize: Float read fYSize write SetYSize;
    property Levels: Integer read fLevels;
    property Width: Float read GetWidth write fWidth;
    property Height: Float read GetHeight write fHeight;
    property W: Integer read GetW;
    property H: Integer read GetH;
    property XS: Integer read GetXS;
    property YS: Integer read GetYS;
    property X0: Integer read GetX0;
    property Y0: Integer read GetY0;
    property X1: Integer read GetX1;
    property Y1: Integer read GetY1;
  end;

type
  TreeDrawingAlgorithmQP = public class (TreeDrawingAlgorithm)
  protected
    method PlaceQP; virtual;
    method PlaceSubtrees; override;
  end;

//  method OrientationToStr(o: TTreeOrientation): String;
//  method StrToOrientation(str: String): TTreeOrientation;
//  method MethodToStr(dm: TTreeDrawMethod): String;
//  method StrToMethod(str: String): TTreeDrawMethod;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

//method OrientationToStr(o: TTreeOrientation): String;
//begin
//  result := '';
//  case o of
//    TreeOrientation.TopDown:    result := 'TopDown';
//    TreeOrientation.LeftRight:  result := 'LeftRight';
//    TreeOrientation.BottomUp:   result := 'BottomUp';
//    TreeOrientation.RightLeft:  result := 'RightLeft';
//  end;
//end;
//
//method StrToOrientation(str: String): TTreeOrientation;
//begin
//  if str = 'LeftRight' then result := TreeOrientation.LeftRight
//  else if str = 'BottomUp' then result := TreeOrientation.BottomUp
//  else if str = 'RightLeft' then result := TreeOrientation.RightLeft
//  else result := TreeOrientation.TopDown;
//end;
//
//method MethodToStr(dm: TTreeDrawMethod): String;
//begin
//  result := '';
//  case dm of
//    TreeDrawMethod.BottomUp: result := 'BottomUp';
//    TreeDrawMethod.Walker:   result := 'Walker';
//    TreeDrawMethod.QP:       result := 'QP';
//  end;
//end;
//
//method StrToMethod(str: String): TTreeDrawMethod;
//begin
//  if str='BottomUp' then result := TreeDrawMethod.BottomUp
//  else if str='QP' then result := TreeDrawMethod.QP
//  else result := TreeDrawMethod.Walker;
//end;

{$REGION TreeDrawNode}

method TreeDrawNode.GetText: String;
begin
  result := '';
end;

method TreeDrawNode.GetCount: Integer;
begin
  result :=
    if IsTerminal then 0
    else fChildCount;
end;

method TreeDrawNode.GetIsTerminal: Boolean;
begin
  result := fChildCount = 0;
end;

method TreeDrawNode.GetLevel: Integer;
begin
  result := 0;
  var p := Parent;
  while p <> nil do
    begin
      inc(result);
      p := p.Parent;
    end;
end;

method TreeDrawNode.GetIndex: Integer;
begin
  result := -1;
  var lIdx := -1;
  if Parent = nil then
    exit;
  var p := Parent.FirstChild;
  while p <> nil do
    begin
      inc(lIdx);
      if p = self then
        exit lIdx;
      p := p.NextChild;
    end;
end;

method TreeDrawNode.GetItem(aIdx: Integer): TreeDrawNode;
begin
  result := nil;
  if aIdx < 0 then
    exit;
  result := FirstChild;
  while result <> nil do
    begin
      if aIdx = 0 then
        exit;
      dec(aIdx);
      result := result.NextChild;
    end;
end;

method TreeDrawNode.GetPrevChild: TreeDrawNode;
begin
  fTreeDrawing.AssureLinks;
  result := fPrevChild;
end;

method TreeDrawNode.GetLeftNode: TreeDrawNode;
begin
  fTreeDrawing.AssureLinks;
  result := fLeftNode;
end;

method TreeDrawNode.GetRightNode: TreeDrawNode;
begin
  fTreeDrawing.AssureLinks;
  result := fRightNode;
end;

method TreeDrawNode.GetWidth: Float;
begin
  result := GetLeftWidth + GetRightWidth;
end;

method TreeDrawNode.GetLeftWidth: Float;
begin
  result := 0.5;
end;

method TreeDrawNode.GetRightWidth: Float;
begin
  result := 0.5;
end;

method TreeDrawNode.GetHeight: Float;
begin
  result := GetTopHeight + GetBottomHeight;
end;

method TreeDrawNode.GetTopHeight: Float;
begin
  result := 0.5;
end;

method TreeDrawNode.GetBottomHeight: Float;
begin
  result := 0.5;
end;

method TreeDrawNode.GetBefore: Float;
begin
  result := 0.0;
  case fTreeDrawing.Orientation of
    TreeOrientation.TopDown:   result := GetLeftWidth;
    TreeOrientation.LeftRight: result := GetBottomHeight;
    TreeOrientation.BottomUp:  result := GetRightWidth;
    TreeOrientation.RightLeft: result := GetTopHeight;
  end;
end;

method TreeDrawNode.GetAfter: Float;
begin
  result := 0.0;
  case fTreeDrawing.Orientation of
    TreeOrientation.TopDown:   result := GetRightWidth;
    TreeOrientation.LeftRight: result := GetTopHeight;
    TreeOrientation.BottomUp:  result := GetLeftWidth;
    TreeOrientation.RightLeft: result := GetBottomHeight;
  end;
end;

method TreeDrawNode.GetAbove: Float;
begin
  result := 0.0;
  case fTreeDrawing.Orientation of
    TreeOrientation.TopDown:   result := GetTopHeight;
    TreeOrientation.LeftRight: result := GetLeftWidth;
    TreeOrientation.BottomUp:  result := GetBottomHeight;
    TreeOrientation.RightLeft: result := GetRightWidth;
  end;
end;

method TreeDrawNode.GetBelow: Float;
begin
  result := 0.0;
  case fTreeDrawing.Orientation of
    TreeOrientation.TopDown:   result := GetBottomHeight;
    TreeOrientation.LeftRight: result := GetRightWidth;
    TreeOrientation.BottomUp:  result := GetTopHeight;
    TreeOrientation.RightLeft: result := GetLeftWidth;
  end;
end;

method TreeDrawNode.GetXPosition: Float;
begin
  fTreeDrawing.AssurePlacement;
  result := fXPos;
end;

method TreeDrawNode.GetYPosition: Float;
begin
  fTreeDrawing.AssurePlacement;
  result := fYPos;
end;

method TreeDrawNode.GetFltX: Float;
begin
  result := fTreeDrawing.TransX(XPosition);
end;

method TreeDrawNode.GetFltY: Float;
begin
  result := fTreeDrawing.TransY(YPosition);
end;

method TreeDrawNode.GetFltX0: Float;
begin
  result := fTreeDrawing.TransX(XPosition) - LeftWidth;
end;

method TreeDrawNode.GetFltY0: Float;
begin
  result := fTreeDrawing.TransY(YPosition) - TopHeight;
end;

method TreeDrawNode.GetFltX1: Float;
begin
  result := fTreeDrawing.TransX(XPosition) + RightWidth;
end;

method TreeDrawNode.GetFltY1: Float;
begin
  result := fTreeDrawing.TransY(YPosition) + BottomHeight;
end;

method TreeDrawNode.GetX: Integer;
begin
  result := Math.Round(GetFltX);
end;

method TreeDrawNode.GetY: Integer;
begin
  result := Math.Round(GetFltY);
end;

method TreeDrawNode.GetX0: Integer;
begin
  result := Math.Round(GetFltX0);
end;

method TreeDrawNode.GetY0: Integer;
begin
  result := Math.Round(GetFltY0);
end;

method TreeDrawNode.GetX1: Integer;
begin
  result := Math.Round(GetFltX1);
end;

method TreeDrawNode.GetY1: Integer;
begin
  result := Math.Round(GetFltY1);
end;

method TreeDrawNode.DescendantOf(aNode: TreeDrawNode): Boolean;
begin
  result := false;
  var p := Parent;
  while (p <> nil) and not result do
  begin
    result := p = aNode;
    p := p.Parent;
  end;
end;

method TreeDrawNode.AddChild(aNode: TreeDrawNode): TreeDrawNode;
begin
   aNode.Parent := self;
   aNode.fTreeDrawing := fTreeDrawing;
   aNode.NextChild := nil;
   if fChildCount = 0 then
     fFirstChild := aNode
   else
     fLastChild.fNextChild := aNode;
   fLastChild := aNode;
   inc(fChildCount);
   fTreeDrawing.ModifiedStructure;
   result := aNode;
end;

method TreeDrawNode.InsertLeft(aNode: TreeDrawNode): TreeDrawNode;
begin
  if Parent = nil then
    raise new ETreeError(String.Format(STreeCannotInsertToRoot, aNode.Text));
  aNode.Parent := Parent;
  aNode.fTreeDrawing := fTreeDrawing;
  aNode.fNextChild := self;
  if Parent.fFirstChild = self then
    Parent.fFirstChild := aNode
  else
    Parent.Item[&Index - 1].fNextChild := aNode;
  inc(Parent.fChildCount);
  fTreeDrawing.ModifiedStructure;
  result := aNode;
end;

method TreeDrawNode.InsertRight(aNode: TreeDrawNode): TreeDrawNode;
begin
  if Parent=nil then
    raise new ETreeError(String.Format(STreeCannotInsertToRoot, aNode.Text));
  aNode.Parent := fParent;
  aNode.fTreeDrawing := fTreeDrawing;
  aNode.fNextChild := fNextChild;
  fNextChild := aNode;
  if Parent.fLastChild = self then
    Parent.fLastChild := aNode;
  inc(Parent.fChildCount);
  fTreeDrawing.ModifiedStructure;
  result := aNode;
end;

method TreeDrawNode.MoveToLeft(aNode: TreeDrawNode): TreeDrawNode;
begin
  if DescendantOf(aNode) then
    raise new ETreeError(String.Format(STreeCircularMove, aNode.Text));
  result := InsertLeft(aNode.Pull);
end;

method TreeDrawNode.MoveToRight(aNode: TreeDrawNode): TreeDrawNode;
begin
  if DescendantOf(aNode) then
    raise new ETreeError(String.Format(STreeCircularMove, aNode.Text));
  result := InsertRight(aNode.Pull);
end;

method TreeDrawNode.Pull: TreeDrawNode;
begin
  if Parent <> nil then
    begin
      if Parent.fChildCount = 1 then
        begin
          Parent.fFirstChild := nil;
          Parent.fLastChild := nil;
        end
      else if Parent.fFirstChild = self then
        Parent.fFirstChild := fNextChild
      else
        begin
          var p := Parent.Item[&Index - 1];
          if Parent.fLastChild = self then
            Parent.fLastChild := p;
          p.fNextChild := fNextChild;
        end;
      dec(Parent.fChildCount);
      Parent := nil;
    end;
  fNextChild := nil;
  fTreeDrawing.ModifiedStructure;
  result := self;
end;

method TreeDrawNode.Prune;
begin
  fFirstChild := nil;
  fLastChild := nil;
  fChildCount := 0;
  fTreeDrawing.ModifiedStructure;
end;

method TreeDrawNode.Modified;
begin
  fTreeDrawing.Modified;
end;

method TreeDrawNode.IsVirtual: Boolean;
begin
  result := TreeDrawing.VirtualRoot and (self = TreeDrawing.Root);
end;

{$ENDREGION}

{$REGION TreeDrawingAlgorithm}

constructor TreeDrawingAlgorithm;
begin
  inherited Create;
  fVirtualRoot := false;
  fModifiedStructure := false;
  fModifiedNodes := false;
  fRoot := nil;
  fDrawMethod := TreeDrawMethod.BottomUp;
  fOrientation := TreeOrientation.TopDown;
  fLevelSeparation := 1.0;
  fMinLevelSeparation := 0.0;
  fNodeSeparation := 1.0;
  fWidth := 0.0;
  fHeight := 0.0;
  fXStretch := 1.0;
  fYStretch := 1.0;
  fXMirror := false;
  fYMirror := false;
  fAlignTerminals := false;
  fAlignLevels := false;
  fAlignParents := TreeAlignParents.Subtree;
  fLevelFirst := nil;
  fLevelLast := nil;
end;

method TreeDrawingAlgorithm.SetRoot(aRoot: TreeDrawNode);
begin
  if fRoot = aRoot then
    exit;
  fRoot := aRoot;
  if fRoot <> nil then
    begin
      fRoot.TreeDrawing := self;
      fRoot.Parent := nil;
    end;
  ModifiedStructure;
end;

method TreeDrawingAlgorithm.SetOrientation(aOrientation: TreeOrientation);
begin
  if fOrientation <> aOrientation then
    Modified;
  fOrientation := aOrientation;
end;

method TreeDrawingAlgorithm.SetDrawMethod(aMethod: TreeDrawMethod);
begin
  if fDrawMethod <> aMethod then
    Modified;
  fDrawMethod := aMethod;
end;

method TreeDrawingAlgorithm.SetLevelSeparation(aSeparation: Float);
begin
  if fLevelSeparation <> aSeparation then
    Modified;
  fLevelSeparation := aSeparation;
end;

method TreeDrawingAlgorithm.SetMinLevelSeparation(aSeparation: Float);
begin
  if fMinLevelSeparation <> aSeparation then
    Modified;
  fMinLevelSeparation := aSeparation;
end;

method TreeDrawingAlgorithm.SetNodeSeparation(aSeparation: Float);
begin
  if fNodeSeparation <> aSeparation then
    Modified;
  fNodeSeparation := aSeparation;
end;

method TreeDrawingAlgorithm.SetAlignTerminals(aAlign: Boolean);
begin
  if fAlignTerminals <> aAlign then
    ModifiedStructure;
  fAlignTerminals := aAlign;
end;

method TreeDrawingAlgorithm.SetAlignLevels(aAlign: Boolean);
begin
  if fAlignLevels <> aAlign then
    Modified;
  fAlignLevels := aAlign;
end;

method TreeDrawingAlgorithm.SetAlignParents(aAlign: TreeAlignParents);
begin
  if fAlignParents <> aAlign then
    Modified;
  fAlignParents := aAlign;
end;

method TreeDrawingAlgorithm.SetXStretch(aStretch: Float);
begin
  fXStretch := aStretch;
  fXSize := fXStretch * fWidth;
end;

method TreeDrawingAlgorithm.SetYStretch(aStretch: Float);
begin
  fYStretch := aStretch;
  fYSize := fYStretch * fHeight;
end;

method TreeDrawingAlgorithm.SetXSize(aSize: Float);
begin
  fXSize := aSize;
  fXStretch := fXSize / fWidth;
end;

method TreeDrawingAlgorithm.SetYSize(aSize: Float);
begin
  fYSize := aSize;
  fYStretch := fYSize / fHeight;
end;

method TreeDrawingAlgorithm.MakeLevels;

  method TraverseLevel(aNode: TreeDrawNode; aLevel: Integer);
  begin
    if aLevel > fLevels then
      fLevels := aLevel;
    var c := aNode.FirstChild;
    while c <> nil do
      begin
        TraverseLevel(c, aLevel + 1);
        c := c.NextChild;
      end;
  end;

begin
  fLevels := 0;
  if Root <> nil then
    begin
      TraverseLevel(Root, 0);
      inc(fLevels);
    end;
  fLevelFirst := new TreeDrawNode[fLevels];
  fLevelLast := new TreeDrawNode[fLevels];
  for i := 0 to fLevels - 1 do
    begin
      fLevelFirst[i] := nil;
      fLevelLast[i] := nil;
    end;
end;

method TreeDrawingAlgorithm.GetHeight: Float;
begin
  AssurePlacement;
  result := fHeight;
end;

method TreeDrawingAlgorithm.GetWidth: Float;
begin
  AssurePlacement;
  result := fWidth;
end;

method TreeDrawingAlgorithm.GetW: Integer;
begin
  result := Math.Round(GetWidth + 0.5);
end;

method TreeDrawingAlgorithm.GetH: Integer;
begin
  result := Math.Round(GetHeight + 0.5);
end;

method TreeDrawingAlgorithm.GetXS: Integer;
begin
  result := Math.Round(XSize + 0.5);
end;

method TreeDrawingAlgorithm.GetYS: Integer;
begin
  result := Math.Round(YSize + 0.5);
end;

method TreeDrawingAlgorithm.GetX0: Integer;
begin
  result := Math.Round(fXOffset);
end;

method TreeDrawingAlgorithm.GetY0: Integer;
begin
  result := Math.Round(fYOffset);
end;

method TreeDrawingAlgorithm.GetX1: Integer;
begin
  result := X0 + Math.Round(fXSize);
end;

method TreeDrawingAlgorithm.GetY1: Integer;
begin
  result := Y0 + Math.Round(fYSize);
end;

method TreeDrawingAlgorithm.GetLevelAbove(aLev: Integer): Float;
begin
  var A, B: Float;
  LevelSize(aLev, out A, out B);
  result := A;
end;

method TreeDrawingAlgorithm.GetLevelBelow(aLev: Integer): Float;
begin
  var A, B: Float;
  LevelSize(aLev, out A, out B);
  result := B;
end;

method TreeDrawingAlgorithm.GetXMirror: Boolean;
begin
  result := fXMirror;
end;

method TreeDrawingAlgorithm.GetYMirror: Boolean;
begin
  result := fYMirror;
end;

method TreeDrawingAlgorithm.GetLevelY(aLev: Integer): Float;
begin
  result := fLevelFirst[aLev].Y;
end;

method TreeDrawingAlgorithm.ModifiedStructure;
begin
  fModifiedStructure := true;
end;

method TreeDrawingAlgorithm.Modified;
begin
  fModifiedNodes := true;
end;

method TreeDrawingAlgorithm.Align(aNode: TreeDrawNode; aMod: Float);
begin
  aNode.XPos := aNode.XPos + aMod;
  aMod := aMod + aNode.XMod;
  fWidth := Math.Max(fWidth, aNode.XPos + aNode.After);
  fLeft := Math.Min(fLeft, aNode.XPos - aNode.Before);
  aNode := aNode.FirstChild;
  while aNode <> nil do
    begin
      Align(aNode, aMod);
      aNode := aNode.NextChild;
    end;
end;

method TreeDrawingAlgorithm.Shift(aNode: TreeDrawNode; aMod: Float);
begin
  aNode.XPos := aNode.XPos + aMod;
  aNode := aNode.FirstChild;
  while aNode <> nil do
    begin
      Shift(aNode, aMod);
      aNode := aNode.NextChild;
    end;
end;

method TreeDrawingAlgorithm.AssureLinks;

  method AssureChildren(aNode: TreeDrawNode);
  begin
    aNode := aNode.FirstChild;
    var lPrev: TreeDrawNode := nil;
    while aNode <> nil do
      begin
        aNode.PrevChild := lPrev;
        lPrev := aNode;
        aNode := aNode.NextChild;
      end;
  end;

  method Assure(aNode: TreeDrawNode; aLev: Integer; var TermFirst, TermLast: TreeDrawNode);
  begin
    var Last: TreeDrawNode;
    if fAlignTerminals and aNode.IsTerminal then
      begin
        if TermFirst = nil then
          TermFirst := aNode;
        Last := TermLast;
      end
    else
      begin
        if fLevelFirst[aLev] = nil then
          fLevelFirst[aLev] := aNode;
        Last := fLevelLast[aLev];
      end;
    aNode.LeftNode := Last;
    if Last <> nil then
      Last.RightNode := aNode;
    aNode.RightNode := nil;
    if fAlignTerminals and aNode.IsTerminal then
      TermLast := aNode
    else
      fLevelLast[aLev] := aNode;
    if aNode.Parent = nil then
      aNode.PrevChild := nil
    else
      AssureChildren(aNode);
    aNode := aNode.FirstChild;
    while aNode <> nil do
      begin
        Assure(aNode, aLev + 1, var TermFirst, var TermLast);
        aNode := aNode.NextChild;
      end;
  end;

begin
  if (fRoot = nil) or not fModifiedStructure then
    exit;
  var TermFirst: TreeDrawNode := nil;
  var TermLast: TreeDrawNode := nil;
  MakeLevels;
  Assure(fRoot, 0, var TermFirst, var TermLast);
  if fAlignTerminals and (fLevelFirst.Count > 0) then
    begin
      fLevelFirst[fLevelFirst.Count - 1] := TermFirst;
      fLevelLast[fLevelLast.Count -1 ] := TermLast;
    end;
  fModifiedStructure := false;
  Modified;
end;

method TreeDrawingAlgorithm.AssurePlacement;
begin
  AssureLinks;
  if fModifiedNodes then
    Place;
  fModifiedNodes := false;
end;

method TreeDrawingAlgorithm.LevelSize(aLev: Integer; out aAbove, aBelow: Float);
begin
  aAbove := 0.0;
  aBelow := 0.0;
  var n := fLevelFirst[aLev];
  while n <> nil do
    begin
      aAbove := Math.Max(aAbove, n.Above);
      aBelow := Math.Max(aBelow, n.Below);
      n := n.RightNode;
    end;
end;

method TreeDrawingAlgorithm.PlaceLevels;

  method PlaceLevel(Y: Float; aLev: Integer);
  begin
    var n := fLevelFirst[aLev];
    while n <> nil do
      begin
        n.YPos := Y;
        n := n.RightNode;
      end;
  end;

begin
  if Levels <= 0 then
    exit;
  var A, B: Float;
  LevelSize(0, out A, out B);
  var Y := A;
  PlaceLevel(Y, 0);
  for lLev := 1 to high(fLevelFirst) do
    begin
      var Bprev := B;
      LevelSize(lLev, out A, out B);
      var Diff := fLevelSeparation;
      if fAlignLevels then
        begin
          var Sep := fLevelSeparation - Bprev - A;
          if Sep < fMinLevelSeparation then
            Diff := Diff + fMinLevelSeparation - Sep;
        end;
      if VirtualRoot and (lLev = 1) then
        // leave Y intact
      else
        Y := Y + Diff;
      PlaceLevel(Y, lLev);
    end;
  fHeight := Y + B;
end;

method TreeDrawingAlgorithm.PlaceBottomUp;
var
  X: Float;
  ReAlign: Boolean;

  method PlaceSubtrees(aNode: TreeDrawNode; out LBound, RBound: Float);
  begin
    aNode.XMod := 0.0;
    if ANode.IsTerminal then
      begin
        if X > 0.0 then
          X := X + fNodeSeparation;
        LBound := X;
        X := X + aNode.Before;
        aNode.XPos := X;
        X := X + aNode.After;
        RBound := X;
      end
    else
      begin
        var c := aNode.FirstChild;
        var L, R: Float;
        PlaceSubtrees(c, out L, out R);
        LBound := L;
        RBound := R;
        var Lc := c.XPos;
        var Rc := c.XPos;
        c := c.NextChild;
        while c <> nil do
          begin
            PlaceSubtrees(c, out L, out R);
            LBound := Math.Min(LBound, L);
            RBound := Math.Max(RBound, R);
            Rc := c.XPos;
            c := c.NextChild;
          end;
        if fAlignParents = TreeAlignParents.Descendants then
          aNode.XPos := (Lc + Rc) / 2
        else
          aNode.XPos := (LBound + RBound) / 2;
        var Ext := (aNode.Before + aNode.After) - (RBound - LBound);
        if Ext > 0.0 then
          begin
            ReAlign := true;
            X := X + Ext;
            RBound := RBound + Ext;
            Ext := Ext / 2;
            aNode.XPos := aNode.XPos + Ext;
            aNode.XMod := aNode.XMod + Ext;
          end;
      end;
  end;

begin
  if fRoot = nil then
    exit;
  X := 0.0;
  ReAlign := false;
  var LBound, RBound: Float;
  PlaceSubtrees(fRoot, out LBound, out RBound);
  fWidth := RBound - LBound;
  if ReAlign then
    begin
      fLeft := 0;
      Align(fRoot, 0);
      if fLeft < 0.0 then
        begin
          Shift(fRoot, -fLeft);
          fWidth := fWidth - fLeft;
        end;
    end;
end;

method TreeDrawingAlgorithm.PlaceWalker;

  method GetLeftmost(aNode: TreeDrawNode; aLevel, aDepth: Integer): TreeDrawNode;
  begin
    if aLevel >= aDepth then
      result := aNode
    else if aNode.IsTerminal then
      result := nil
    else
      begin
        var RNode := aNode.FirstChild;
        var LNode := GetLeftmost(RNode, aLevel + 1, aDepth);
        while (LNode = nil) and (RNode.RightNode <> nil) do
          begin
            RNode := RNode.RightNode;
            LNode := GetLeftmost(RNode, aLevel + 1, aDepth);
          end;
        result := LNode;
      end;
  end;

  method Apportion(aNode: TreeDrawNode);
  begin
    var RNode := aNode.FirstChild;
    var LNode := RNode.LeftNode;
    var CLev := 1;
    while (RNode <> nil) and (LNode <> nil) do
      begin
        var LMod := 0.0;
        var RMod := 0.0;
        var LAnc := LNode;
        var RAnc := RNode;
        for i := 1 to CLev do
          begin
            LAnc := LAnc.Parent;
            RAnc := RAnc.Parent;
            LMod := LMod + LAnc.XMod;
            RMod := RMod + RAnc.XMod;
          end;
        var Mov: Float := LNode.XPos + LMod + LNode.After + fNodeSeparation +
                   RNode.Before - (RNode.XPos + RMod);
        if Mov > 0.0 then
          begin
            var TNode := aNode;
            var CSib := 0;
            while (TNode <> nil) and (TNode <> LAnc) do
              begin
                inc(CSib);
                TNode := TNode.LeftNode;
              end;
            if TNode = nil then
              exit;
            TNode := aNode;
            var Por := Mov / CSib;
            while TNode <> LAnc do
              begin
                TNode.XPos := TNode.XPos + Mov;
                TNode.XMod := TNode.XMod + Mov;
                Mov := Mov - Por;
                TNode := TNode.LeftNode;
              end;
          end;
        inc(CLev);
        if RNode.IsTerminal then
          RNode := GetLeftmost(aNode, 0, CLev)
        else
          RNode := RNode.FirstChild;
        if RNode <> nil then
          LNode := RNode.LeftNode;
      end;
  end;

  method GetBounds(aNode: TreeDrawNode; Sum: Float; out LBound,RBound: Float);
  begin
    var X := aNode.XPos + Sum;
    if aNode.IsTerminal then
      begin
        LBound := X - aNode.Before;
        RBound := X + aNode.After;
      end
    else
      begin
        var c := aNode.FirstChild;
        while c <> nil do
          begin
            var L, R: Float;
            GetBounds(c, Sum + aNode.XMod, out L, out R);
            var Ext := ((c.Before + c.After) - (R - L)) / 2;
            if Ext > 0.0 then
              begin
                L := L - Ext;
                R := R + Ext;
              end;
            if c = aNode.FirstChild then
              begin
                LBound := L;
                RBound := R;
              end
            else
              begin
                LBound := Math.Min(LBound, L);
                RBound := Math.Max(RBound, R);
              end;
            c := c.NextChild;
          end;
      end;
  end;

  method FirstWalk(aNode: TreeDrawNode);
  begin
    aNode.XMod := 0.0;
    if aNode.IsTerminal then
      begin
        if aNode.LeftNode = nil then
          aNode.XPos := aNode.Before
        else
          with lNode := aNode.LeftNode do
            aNode.XPos := lNode.XPos + lNode.After + fNodeSeparation + aNode.Before;
      end
    else
      begin
        var c := aNode.FirstChild;
        var L := 0.0;
        var R := 0.0;
        while c <> nil do
          begin
            FirstWalk(c);
            R := c.XPos;
            if c = aNode.FirstChild then
              L := R;
            c := c.NextChild;
          end;
        if fAlignParents = TreeAlignParents.Subtree then
          GetBounds(aNode, 0.0, out L, out R); //*complex
        var M := (L + R) / 2;
        if aNode.LeftNode = nil then
          aNode.XPos := M
        else
          begin
            with lNode := aNode.LeftNode do
              aNode.XPos := lNode.XPos + lNode.After + fNodeSeparation + aNode.Before;
            aNode.XMod := aNode.XPos - M;
            Apportion(aNode);
          end;
      end;
  end;

begin
  if fRoot = nil then
    exit;
  AssureLinks;
  FirstWalk(fRoot);
  fLeft := 0;
  Align(fRoot, 0);
  if fLeft < 0.0 then
    begin
      Shift(fRoot, -fLeft);
      fWidth := fWidth - fLeft;
    end;
end;

method TreeDrawingAlgorithm.PlaceSubtrees;
begin
  if fAlignTerminals then
    PlaceBottomUp
  else if fDrawMethod = TreeDrawMethod.Walker then
    PlaceWalker
  else
    PlaceBottomUp;
end;

method TreeDrawingAlgorithm.Place;
begin
  AssureLinks;
  fWidth := 0.0;
  fHeight := 0;
  PlaceLevels;
  PlaceSubtrees;
  SetXStretch(fXStretch);
  SetYStretch(fYStretch);
end;

method TreeDrawingAlgorithm.TransX(X: Float): Float;
begin
  if XMirror then X := fWidth - X;
  result := fXStretch * X + fXOffset;
end;

method TreeDrawingAlgorithm.TransY(Y: Float): Float;
begin
  if YMirror then Y := fHeight - Y;
  result := fYStretch * Y + fYOffset;
end;

{$ENDREGION}

{$REGION TreeDrawingAlgorithmQP}

method TreeDrawingAlgorithmQP.PlaceQP;
var
  n, me, mi, q: Integer;
  G, CI, CE: QPMatrix;
  g0, ci0, ce0, x, u: FltArray;
  a: IntArray;
  f: Float;

  method AsEquality(aNode: TreeDrawNode): Boolean;
  begin
    result :=
      aNode.IsTerminal and
      (aNode.NextChild <> nil) and
      aNode.NextChild.IsTerminal and
      (aNode.Parent = aNode.NextChild.Parent);
  end;

  method GetDim(aNode: TreeDrawNode);
  begin
    aNode.Idx := n;
    inc(n);
    if aNode.RightNode <> nil then
      if AsEquality(aNode) then
        inc(me)
      else
        inc(mi);
    var c := aNode.FirstChild;
    while c <> nil do
      begin
        GetDim(c);
        c := c.NextChild;
      end;
  end;

  method Formulate(aNode: TreeDrawNode);
  begin
    if aNode.Idx >= 0 then
      begin
        G[aNode.Idx, aNode.Idx] := 2.0 * (1 + aNode.Count);
        if (aNode.Parent <> nil) and (aNode.Parent.Idx >= 0) then
          begin
            G[aNode.Idx, aNode.Parent.Idx] := -2;
            G[aNode.Parent.Idx, aNode.Idx] := -2;
          end;
      end;
    if aNode.RightNode <> nil then
      if AsEquality(aNode) then
        begin
          CE[aNode.Idx, me] := -1;
          CE[aNode.RightNode.Idx, me] := 1;
          ce0[me] := -(aNode.After + NodeSeparation + aNode.RightNode.Before);
          inc(me);
        end
      else
        begin
          CI[aNode.Idx, mi] := -1;
          CI[aNode.RightNode.Idx, mi] := 1;
          ci0[mi] := -(aNode.After + NodeSeparation + aNode.RightNode.Before);
          inc(mi);
        end;
    var c := aNode.FirstChild;
    while c <> nil do
      begin
        Formulate(c);
        c := c.NextChild;
      end;
  end;

  method GetBounds(aNode: TreeDrawNode; var LBound, RBound: Float);
  begin
    var xx :=
      if aNode.Idx >= 0 then x[aNode.Idx]
      else 0;
    LBound := Math.Min(LBound, xx - aNode.Before);
    RBound := Math.Max(RBound, xx + aNode.After);
    var c := aNode.FirstChild;
    while c <> nil do
      begin
        GetBounds(c, var LBound, var RBound);
        c := c.NextChild;
    end;
  end;

  method SetPos(aNode: TreeDrawNode);
  begin
    if aNode.Idx >= 0 then
      aNode.XPos := x[aNode.Idx] + Root.XPos;
    var c := aNode.FirstChild;
    while c <> nil do
      begin
        SetPos(c);
        c := c.NextChild;
      end;
  end;

begin
  n := -1;
  me := 0;
  mi := 0;
  GetDim(Root);
  if n = 0 then
    begin
      Root.XPos := 0;
      x := new Float[0];
    end
  else
    begin
      G := DualQP.QPMatrix(n, n);   DualQP.ZeroMatrix(G);  g0 := Utils.NewFltArray(n);
      CE := DualQP.QPMatrix(n, me); DualQP.ZeroMatrix(CE); ce0 := Utils.NewFltArray(me);
      CI := DualQP.QPMatrix(n, mi); DualQP.ZeroMatrix(CI); ci0 := Utils.NewFltArray(mi);
      me := 0;
      mi := 0;
      Formulate(Root);
      DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
    end;
  var LBound := 0.0;
  var RBound := 0.0;
  GetBounds(Root, var LBound, var RBound);
  Root.XPos := -LBound;
  x := Utils.ConcatenateFltArrays(x, [Root.XPos]);
  Width := RBound + Root.XPos;
  SetPos(Root);
end;

method TreeDrawingAlgorithmQP.PlaceSubtrees;
begin
  if AlignTerminals then
    PlaceBottomUp
  else if DrawMethod = TreeDrawMethod.QP then
    PlaceQP
  else
    inherited PlaceSubtrees;
end;

{$ENDREGION}

end.
