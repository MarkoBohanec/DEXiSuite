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
  /// Summary description for FormList.
  /// </summary>
  FormList = partial public class(System.Windows.Forms.Form)
  private
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method SetAsLines(aLines: List<String>);
    method SetAsText(aText: String);
  end;

implementation

{$REGION Construction and Disposition}
constructor FormList;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormList.Dispose(aDisposing: Boolean);
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

method FormList.SetAsLines(aLines: List<String>);
begin
  Contents.Lines := aLines.ToArray;
end;

method FormList.SetAsText(aText: String);
begin
  Contents.Text := aText;
end;

end.