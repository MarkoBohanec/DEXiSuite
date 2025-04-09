namespace DexiLibrary.Tests;

interface

uses
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit,
  DEXiUtils;

type
  GraphicsTest = public class(DexiLibraryTest)
  protected
  public
    method TestImgBorder;
    method TestImgRectangle;
    method TestColorInfoGet;
    method TestColorInfoSet;
    method TestFontInfo;
    method TestScaleMakerMinMax;
    method TestScaleMakerEqual;
    method TestMap3to2D;
  end;

implementation

method GraphicsTest.TestImgBorder;

  method CheckStr(b: ImgBorder; s: String);
  begin
    var bs := b.AsString;
    Assert.AreEqual(bs, s);
    var c := new ImgBorder(0, 0, 0, 0);
    c.AsString := s;
    Assert.IsTrue(b.EqualTo(c));
  end;

  method CheckRelStr(b, r: ImgBorder; s: String);
  begin
    var bs := b.RelativeString(r);
    Assert.AreEqual(bs, s);
    var c := new ImgBorder;
    c.SetFromRelativeString(s, r);
    Assert.IsTrue(b.EqualTo(c));
  end;

begin
  var b := new ImgBorder(10, 20, 30, 40);
  var c := new ImgBorder(10, 20, 30, 40);
  Assert.IsTrue(b.EqualTo(c));
  Assert.IsTrue(c.EqualTo(b));

  CheckStr(b, '10;20;30;40');
  
  c.Right := 0;

  Assert.IsFalse(b.EqualTo(c));
  Assert.IsFalse(c.EqualTo(b));

  CheckStr(c, '10;0;30;40');
  
  c := new ImgBorder;

  CheckStr(c, '0;0;0;0');
  
  c := new ImgBorder(b);
  Assert.IsTrue(b.EqualTo(c));
  Assert.IsTrue(c.EqualTo(b));

  CheckStr(c, '10;20;30;40');

  var r := new ImgBorder(0, 20, 0, 40);

  CheckRelStr(b, b, nil);
  CheckRelStr(b, r, '10;;30');

  c := new ImgBorder(12, 22, 32, 42);
  CheckRelStr(c, r, '12;22;32;42');
end;

method GraphicsTest.TestImgRectangle;

  method CheckRect(r: ImgRectangle; aLeft, aTop, aWidth, aHeight: Integer);
  begin
    Assert.AreEqual(r.Left, aLeft);
    Assert.AreEqual(r.Top, aTop);
    Assert.AreEqual(r.X, aLeft);
    Assert.AreEqual(r.Y, aTop);
    Assert.AreEqual(r.Width, aWidth);
    Assert.AreEqual(r.Height, aHeight);
    Assert.AreEqual(r.Right, r.Left + r.Width - 1);
    Assert.AreEqual(r.Bottom, r.Top + r.Height - 1);
  end;

begin
  var r := new ImgRectangle(10, 11, 12, 13);
  CheckRect(r, 10, 11, 12, 13);
  Assert.AreEqual(r.AsString, "10, 11, 12, 13");

  var p := new ImgRectangle(r);
  CheckRect(p, 10, 11, 12, 13);
  Assert.AreEqual(p.AsString, "10, 11, 12, 13");

  var f := new FmtRectangle(100, 101, 102, 103);
  p := new ImgRectangle(f);
  CheckRect(p, 100, 101, 102, 103);

  p.Clear;
  CheckRect(p, 0, 0, 0, 0);

  p.Assign(r);
  CheckRect(p, 10, 11, 12, 13);
  p.Right := 20;
  p.Bottom := 100;
  CheckRect(p, 10, 11, 11, 90);

  p.AsString := "1, 2";
  CheckRect(p, 1, 2, 11, 90);

  p.AsString := "101, , , 102";
  CheckRect(p, 101, 2, 11, 102);

  p.AsString := "1, 2, 3, 4";
  CheckRect(p, 1, 2, 3, 4);

  var q := new ImgRectangle(p.ToFmtRectangle);
  CheckRect(q, 1, 2, 3, 4);
end;

method GraphicsTest.TestColorInfoGet;
begin
  var lCI := new ColorInfo($010203);
  Assert.AreEqual(lCI.ARGB, $010203);
  Assert.AreEqual(lCI.Alpha, $00);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '00010203');

  lCI := new ColorInfo($01, $02, $03);
  Assert.AreEqual(lCI.ARGB, $FF010203);
  Assert.AreEqual(lCI.Alpha, $FF);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '010203');

  lCI := new ColorInfo($55, $01, $02, $03);
  Assert.AreEqual(lCI.ARGB, $55010203);
  Assert.AreEqual(lCI.Alpha, $55);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '55010203');

  lCI := new ColorInfo('010203');
  Assert.AreEqual(lCI.ARGB, $FF010203);
  Assert.AreEqual(lCI.Alpha, $FF);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '010203');
end;

method GraphicsTest.TestColorInfoSet;
begin
  var lCI := new ColorInfo('44010203');
  Assert.AreEqual(lCI.ARGB, $44010203);
  Assert.AreEqual(lCI.Alpha, $44);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '44010203');

  lCI.Alpha := $11;
  Assert.AreEqual(lCI.ARGB, $11010203);
  Assert.AreEqual(lCI.Alpha, $11);
  Assert.AreEqual(lCI.Red, $01);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '11010203');

  lCI.Red := $10;
  Assert.AreEqual(lCI.ARGB, $11100203);
  Assert.AreEqual(lCI.Alpha, $11);
  Assert.AreEqual(lCI.Red, $10);
  Assert.AreEqual(lCI.Green, $02);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '11100203');

  lCI.Green := $20;
  Assert.AreEqual(lCI.ARGB, $11102003);
  Assert.AreEqual(lCI.Alpha, $11);
  Assert.AreEqual(lCI.Red, $10);
  Assert.AreEqual(lCI.Green, $20);
  Assert.AreEqual(lCI.Blue, $03);
  Assert.AreEqual(lCI.AsString, '11102003');

  lCI.Blue := $33;
  Assert.AreEqual(lCI.ARGB, $11102033);
  Assert.AreEqual(lCI.Alpha, $11);
  Assert.AreEqual(lCI.Red, $10);
  Assert.AreEqual(lCI.Green, $20);
  Assert.AreEqual(lCI.Blue, $33);
  Assert.AreEqual(lCI.AsString, '11102033');
end;

method GraphicsTest.TestFontInfo;
begin
  var lFI := new FontInfo('XY', 1.1);
  Assert.AreEqual(lFI.Name, 'XY');
  Assert.AreEqual(lFI.Size, 1.1);
  Assert.AreEqual(lFI.Style, '');

  lFI.Name := 'YX';
  Assert.AreEqual(lFI.Name, 'YX');
  Assert.AreEqual(lFI.Size, 1.1);
  Assert.AreEqual(lFI.Style, '');

  lFI.Size := 2.2;
  Assert.AreEqual(lFI.Name, 'YX');
  Assert.AreEqual(lFI.Size, 2.2);
  Assert.AreEqual(lFI.Style, '');

  Assert.AreEqual(lFI.AsString, 'YX;2.2;');

  lFI.Bold := true;
  Assert.IsTrue(lFI.Bold);
  Assert.IsFalse(lFI.Italic);
  Assert.IsFalse(lFI.Underline);
  Assert.AreEqual(lFI.Style, 'B');

  lFI.Italic := true;
  Assert.IsTrue(lFI.Bold);
  Assert.IsTrue(lFI.Italic);
  Assert.IsFalse(lFI.Underline);
  Assert.AreEqual(lFI.Style, 'BI');

  lFI.Underline := true;
  Assert.IsTrue(lFI.Bold);
  Assert.IsTrue(lFI.Italic);
  Assert.IsTrue(lFI.Underline);
  Assert.AreEqual(lFI.Style, 'BIU');

  Assert.AreEqual(lFI.AsString, 'YX;2.2;BIU');

  lFI.Style := 'bu';
  Assert.IsTrue(lFI.Bold);
  Assert.IsFalse(lFI.Italic);
  Assert.IsTrue(lFI.Underline);

  lFI.AsString := 'Sans Serif;8.5';
  Assert.AreEqual(lFI.Name, 'Sans Serif');
  Assert.AreEqual(lFI.Size, 8.5);
  Assert.AreEqual(lFI.Style, '');

  lFI.AsString := 'Sans Serif;9;UX';
  Assert.AreEqual(lFI.Name, 'Sans Serif');
  Assert.AreEqual(lFI.Size, 9.0);
  Assert.AreEqual(lFI.Style, 'U');
end;

method GraphicsTest.TestScaleMakerMinMax;
begin
  var lSM := new ScaleMaker(100, 200);
  Assert.AreEqual(lSM.MinPoint, 100);
  Assert.AreEqual(lSM.MaxPoint, 200);
  Assert.AreEqual(lSM.MaxTicks, 10);
  Assert.AreEqual(lSM.NiceMin, 100.0);
  Assert.AreEqual(lSM.NiceMax, 200.0);
  Assert.AreEqual(lSM.TickSpacing, 10.0);

  lSM := new ScaleMaker(990, 1990);
  Assert.AreEqual(lSM.MinPoint, 990);
  Assert.AreEqual(lSM.MaxPoint, 1990);
  Assert.AreEqual(lSM.MaxTicks, 10);
  Assert.AreEqual(lSM.NiceMin, 900.0);
  Assert.AreEqual(lSM.NiceMax, 2000.0);
  Assert.AreEqual(lSM.TickSpacing, 100.0);
end;

method GraphicsTest.TestScaleMakerEqual;
begin
  var lSM := new ScaleMaker(100, 100);
  Assert.AreEqual(lSM.MinPoint, 100);
  Assert.AreEqual(lSM.MaxPoint, 100);
  Assert.AreEqual(lSM.MaxTicks, 10);
  Assert.AreEqual(lSM.NiceMin, 90.0);
  Assert.AreEqual(lSM.NiceMax, 110.0);
  Assert.AreEqual(lSM.TickSpacing, 2.0);

  lSM := new ScaleMaker(0, 0);
  Assert.AreEqual(lSM.MinPoint, 0);
  Assert.AreEqual(lSM.MaxPoint, 0);
  Assert.AreEqual(lSM.MaxTicks, 10);
  Assert.AreEqual(lSM.NiceMin, -1);
  Assert.AreEqual(lSM.NiceMax, +1);
  Assert.AreEqual(lSM.TickSpacing, 0.2);
end;

method GraphicsTest.TestMap3to2D;
var lMap := new Map3to2D;

  method TestMap(x, y, z, px, py: Float);
  begin
    var p := lMap.Proj(x, y, z);
    Assert.IsTrue(Utils.FloatEq(p.X, px, 0.000001));
    Assert.IsTrue(Utils.FloatEq(p.Y, py, 0.000001));
  end;

begin
  TestMap(0, 0, 0, 0,        0);
  TestMap(1, 0, 0, 0.707107, 0.183013);
  TestMap(0, 1, 0,-0.707107, 0.183013);
  TestMap(0, 0, 1, 0,        0.965926);
  lMap.VerticalRotation := 30;
  TestMap(0, 0, 0, 0,        0);
  TestMap(1, 0, 0, 0.707107, 0.353553);
  TestMap(0, 1, 0,-0.707107, 0.353553);
  TestMap(0, 0, 1, 0,        0.866025);
end;

end.
