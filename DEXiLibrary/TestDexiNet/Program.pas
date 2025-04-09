namespace TestDEXiModNet;

interface

uses
  DEXiLibrary,
  RemObjects.Elements.EUnit;

implementation

begin
  System.Globalization.CultureInfo.CurrentCulture := new System.Globalization.CultureInfo("de-DE");
  var lTests := Discovery.DiscoverTests();
  Runner.RunTests(lTests) withListener(Runner.DefaultListener);
  writeLn('.NET');
  readLn;
end.