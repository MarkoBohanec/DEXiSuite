// Programs.pas is part of
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
// Programs.pas implements the main entry point of the DEXiWin application.
// ----------

namespace DexiWin;

interface

uses
  System.Threading,
  System.Windows.Forms;

type
  Program = assembly static class
  private
    class method OnThreadException(sender: Object; e: ThreadExceptionEventArgs);
  protected
  public
    class method Main(args: array of String);
  end;

implementation

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread]
class method Program.Main(args: array of String);
begin
  Application.EnableVisualStyles();
  Application.SetCompatibleTextRenderingDefault(false);
  Application.ThreadException += OnThreadException;
  using lMainForm := new MainForm do
    begin
      AppData.AppForm := lMainForm;
      AppData.Initialize;
      AppData.AppParameters(args);
      Application.Run(lMainForm);
    end;
end;

/// <summary>
/// Default exception handler
/// </summary>
class method Program.OnThreadException(sender: Object; e: ThreadExceptionEventArgs);
begin
  MessageBox.Show(e.Exception.Message);
end;

end.