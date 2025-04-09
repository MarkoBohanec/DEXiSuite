// Lists.pas is part of
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
// Lists.pas implements extenions to List<T>.
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  ListExtensions<T> = public extension class (List<T>)
  public
    method SetTo(aElement: T);
    method SetTo(aElements: sequence of T);
    method Include(aElement: T);
    method Exclude(aElement: T; aAll: Boolean := true);
    method Include(aElements: sequence of T);
    method Exclude(aElements: sequence of T; aAll: Boolean := true);
  end;

implementation

{$REGION ListExtensions<T>}

method ListExtensions<T>.SetTo(aElement: T);
begin
  RemoveAll;
  &Add(aElement);
end;

method ListExtensions<T>.SetTo(aElements: sequence of T);
begin
  RemoveAll;
  &Add(aElements);
end;

method ListExtensions<T>.Include(aElement: T);
begin
  if not Contains(aElement) then
    &Add(aElement);
end;

method ListExtensions<T>.Exclude(aElement: T; aAll: Boolean := true);
begin
  var lIdx := IndexOf(aElement);
  while lIdx >= 0 do
    begin
      RemoveAt(lIdx);
      if not aAll then
        break;
      lIdx := IndexOf(aElement);
    end;
end;

method ListExtensions<T>.Include(aElements: sequence of T);
begin
  for each lElement in aElements do
    Include(lElement);
end;

method ListExtensions<T>.Exclude(aElements: sequence of T; aAll: Boolean := true);
begin
  for each lElement in aElements do
    Exclude(lElement, aAll);
end;

{$ENDREGION}

end.
