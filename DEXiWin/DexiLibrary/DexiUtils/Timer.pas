// Timer.pas is part of
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
// Timer.pas implements a simple timer for measuring elapsed time between Start and Stop events.
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  Timer = public class
  private
    fStarted: DateTime;
    fStopped: DateTime;
    fIsRunning: Boolean;
  public
    constructor (aStart: Boolean := true);
    method Start;
    method Stop;
    method Elapsed: TimeSpan;
    method ElapsedMilliSeconds: Double;
    property IsRunning: Boolean read fIsRunning;
    method ToString: String; override;
  end;

implementation

constructor Timer(aStart: Boolean := true);
begin
  if aStart then
    Start;
end;

method Timer.Start;
begin
  fStarted := DateTime.UtcNow;
  fStopped := fStarted;
  fIsRunning := true;
end;

method Timer.Stop;
begin
  fStopped := DateTime.UtcNow;
  fIsRunning := false;
end;

method Timer.Elapsed: TimeSpan;
begin
  var lStopped: DateTime := if IsRunning then DateTime.UtcNow else fStopped;
  result := lStopped - fStarted;
end;

method Timer.ElapsedMilliSeconds: Double;
begin
  result := Elapsed.TotalMilliSeconds;
end;

method Timer.ToString: String;
begin
  result := Elapsed.TotalMilliSeconds.ToString;
end;

end.
