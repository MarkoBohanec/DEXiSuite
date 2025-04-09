// FormAbout.pas is part of
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
// FormAbout.pas displays basic information about the DEDXiWin application.
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
  System.Diagnostics,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormAbout.
  /// </summary>
  FormAbout = public partial class(System.Windows.Forms.Form)
  private
    method AboutPanel_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    fVersion: String;
    fFullVersion := false;
    
    method LblLink_LinkClicked(sender: System.Object; e: System.Windows.Forms.LinkLabelLinkClickedEventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
    method SetVersion;
  public
    constructor;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormAbout;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fVersion := LblVersion.Text;
  Text := Text + ' ' + AppVersion.Name;
  LblSoftware.Text := AppVersion.Name;
  SetVersion;
  LblCopyrightLabel.Text := LblCopyrightLabel.Text + ' ' + AppVersion.Years;
  LblCopyright.Text := AppVersion.CopyrightOwner;
  LblLibrary.Text := LblLibrary.Text + ' ' + DexiLibrary.LibraryString;
  LblLibraryCopyright.Text := LblLibraryCopyright.Text + ' ' + DexiLibrary.Copyright;
end;

method FormAbout.Dispose(aDisposing: Boolean);
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

method FormAbout.SetVersion;
begin
  LblVersion.Text := fVersion + ' ' + if fFullVersion then Application.ProductVersion else AppVersion.Version;
end;

method FormAbout.LblLink_LinkClicked(sender: System.Object; e: System.Windows.Forms.LinkLabelLinkClickedEventArgs);
begin
  Process.Start(LblLink.Text);
end;

method FormAbout.AboutPanel_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  fFullVersion := not fFullVersion;
  SetVersion;
end;

end.