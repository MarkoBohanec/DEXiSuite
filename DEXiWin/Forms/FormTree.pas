// FormTree.pas is part of
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
// FormTree.pas implements a form for displaying DEXi trees of attributes.
// Uses 'CtrlFormTree'.
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
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormTree.
  /// </summary>
  FormTree = public partial class(System.Windows.Forms.Form)
  private
  protected
    fModel: DexiModel;
    method Dispose(aDisposing: Boolean); override;
	  method SetModel(aModel: DexiModel);
  public
    constructor;
    property Model: DexiModel read fModel write SetModel;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormTree;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormTree.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormTree.SetModel(aModel: DexiModel);
begin
  fModel := aModel;
  TreeViewer.Model := aModel;
end;

end.
