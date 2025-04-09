namespace TestDEXiModJava;

interface

uses
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

implementation

begin
  java.util.Locale.setDefault(java.util.Locale.GERMANY);
  var lTests := Discovery.DiscoverTests();
  Runner.RunTests(lTests) withListener(Runner.DefaultListener);
  writeLn('java');
  readLn;
end.