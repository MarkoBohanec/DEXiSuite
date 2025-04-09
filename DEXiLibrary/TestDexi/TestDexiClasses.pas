namespace DexiLibrary.Tests;

interface

uses
  {$IFNDEF JAVA}
  System.Reflection,
  {$ENDIF}
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiClassesTest = public class(DexiLibraryTest)
  protected
    method WriteClasses(aNamespaces: List<String>);
  public
    method TestClasses;
  end;

implementation

type
  ClassNode = class
    property Name: String;
    property Subclasses: List<ClassNode>;

    constructor (aName: String);
    begin
      Name := aName;
      Subclasses := new List<ClassNode>;
    end;

    method AddSubclass(aNode: ClassNode);
    begin
      Subclasses.Add(aNode)
    end;

    method AddSubclass(aName: String);
    begin
      AddSubclass(new ClassNode(aName));
    end;

    method FindOrCreateSubclass(aName: String): ClassNode;
    begin
      for each lClass in Subclasses do
        if lClass.Name = aName then
          exit lClass;
      result := new ClassNode(aName);
      AddSubclass(result);
    end;

     method AddTree(aNode: ClassNode; aList: List<String>; aIndent: String);
     begin
       aList.Add(aIndent + aNode.Name);
        for each lClass in aNode.Subclasses do
          lClass.AddTree(lClass, aList, aIndent + '  ');
     end;

    method ClassHierarchy: List<String>;
    begin
      result := new List<String>;
      AddTree(self, result, '');
    end;

  end;

method MakeClassHierarchy(aList: List<String>): ClassNode;
begin
  var lRoot := new ClassNode('*');
  result := lRoot;
  for each aClass in aList do
    begin
      var lNames := aClass.Split('.');
      var lCurrent := lRoot;
      for each lName in lNames do
        lCurrent := lCurrent.FindOrCreateSubclass(lName);
    end;
end;

{$IFNDEF JAVA}
method GetInheritancePath(aType: &Type): String;
begin
  result := '';
  var lCurrent := aType;
  while lCurrent <> nil do
    begin
      if result <> '' then
        result := '.' + result;
      result := lCurrent.Name + result;
      lCurrent := lCurrent.BaseType;
    end;
  result := aType.Namespace + '.' + result;
end;

method ListClasses(aNamespaces: List<String>; aSelect: Predicate<&Type> := nil): List<String>;

  method StringContains(aString: String; aStrings: List<String>): Boolean;
  begin
    result := false;
    for each lStr in aStrings do
      if aString.Contains(lStr) then
        exit true;
  end;

begin
  var lExclude := new List<String>(['.MetaClass', '__Global', '<>c__']);
  var lClassList := new List<String>;
  var lAssembly := System.Reflection.Assembly.GetExecutingAssembly;
  var lTypes := lAssembly.GetTypes;
  var lSelected :=
    from t in lTypes
    where ((aNamespaces = nil) or aNamespaces.Contains(t.Namespace)) and ((aSelect = nil) or aSelect(t))
    select t;
  for lType in lSelected do
    begin
      var lInheritancePath := GetInheritancePath(lType);
      if not StringContains(lInheritancePath, lExclude) then
        lClassList.Add(lInheritancePath);
    end;
  lClassList.Sort(@String.Compare);
  result := lClassList;
end;
{$ENDIF}

method DexiClassesTest.WriteClasses(aNamespaces: List<String>);
begin
  {$IFNDEF JAVA}
  var lClassList := ListClasses(aNamespaces);
  File.WriteLines(TestOutput + 'Classes.txt', lClassList);
  var lHierarchy := MakeClassHierarchy(lClassList);
  File.WriteLines(TestOutput + 'ClassesHierarchy.txt', lHierarchy.ClassHierarchy);
  {$ENDIF}
end;

method DexiClassesTest.TestClasses;
begin
  var lNamespaces := new List<String>(['DexiUtils', 'DexiLibrary']);
  WriteClasses(lNamespaces);
end;

end.
