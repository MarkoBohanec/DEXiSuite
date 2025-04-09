// FormSearch.pas is part of
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
// FormSearch.pas implements a form for defining tha search string and parameters for
// finding an attribute in a DEXi model.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel;

type
  /// <summary>
  /// Summary description for FormSearch.
  /// </summary>
  FormSearch = partial public class(System.Windows.Forms.Form)
  private
    method FormSearch_Activated(sender: System.Object; e: System.EventArgs);
    method FormSearch_Load(sender: System.Object; e: System.EventArgs);
    method ChkName_CheckStateChanged(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
    method GetSearchParams: SearchParameters;
    method SetSearchParams(aParams: SearchParameters);
  public
    constructor;
    method UpdateForm;
    property SearchParams: SearchParameters read GetSearchParams write SetSearchParams;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormSearch;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  AcceptButton := BtnOK;
end;

method FormSearch.Dispose(aDisposing: Boolean);
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

method FormSearch.GetSearchParams: SearchParameters;
begin
  result.SearchString := TextSearch.Text;
  result.SearchStringUpper := TextSearch.Text.ToUpper;
  result.SearchName := ChkName.Checked;
  result.SearchDescr := ChkDescr.Checked;
  result.SearchScale := ChkScale.Checked;
  if not (result.SearchName or result.SearchDescr or result.SearchScale) then
    result.SearchName := true;
  result.MatchCase := ChkMatchCase.Checked;
end;

method FormSearch.SetSearchParams(aParams: SearchParameters);
begin
  TextSearch.Text := aParams.SearchString;
  ChkName.Checked := aParams.SearchName;
  ChkDescr.Checked := aParams.SearchDescr;
  ChkScale.Checked := aParams.SearchScale;
  ChkMatchCase.Checked := aParams.MatchCase;
end;

method FormSearch.UpdateForm;
begin
  AppUtils.Enable(ChkName.Checked or ChkDescr.Checked or ChkScale.Checked, BtnOK)
end;

method FormSearch.ChkName_CheckStateChanged(sender: System.Object; e: System.EventArgs);
begin
  UpdateForm;
end;

method FormSearch.FormSearch_Load(sender: System.Object; e: System.EventArgs);
begin
  UpdateForm;
end;

method FormSearch.FormSearch_Activated(sender: System.Object; e: System.EventArgs);
begin
  TextSearch.Focus;
end;

end.