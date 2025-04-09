// FormScaleCreate.pas is part of
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
// FormScaleCreate.pas implements a form for creating a 'DexiScale', offering a choice
// between 'DexiDiscreteScale' and 'DexiContinuousScale'.
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
  /// Summary description for FormScaleCreate.
  /// </summary>
  FormScaleCreate = partial public class(System.Windows.Forms.Form)
  private
    fFormText: String;
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method SetForm(aAttribute: DexiAttribute);
    property Discrete: Boolean read BtnDiscrete.Checked;
    property Continuous: Boolean read BtnContinuous.Checked;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormScaleCreate;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
end;

method FormScaleCreate.Dispose(aDisposing: Boolean);
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

method FormScaleCreate.SetForm(aAttribute: DexiAttribute);
begin
  Text := String.Format(fFormText, aAttribute:Name);
  BtnDiscrete.Checked := true;
end;

end.