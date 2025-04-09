// DualQP.pas is part of
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
// DualQP.pas implements a solver for strictly convex quadratic programs by the Goldfarb-Idnani method:
// Goldfarb, D., Idnani, A.:
//   A numerically stable dual method for solving strictly convex quadratic programs.
//   Math. Prog. 27, (1983), 1-33.
//
// Adapted from Fortran code of P. Spellucci (spellucci@mathematik.th-darmstadt.de).
//
// Problem:
//
//        1   t         t
// f(x) = - x  G x + g0  x = min!
//        2
//
// subject to
//
//         t
// h(x) = CE x + ce0  =  0, constraining equalities
//
//         t
// g(x) = CI x + ci0  >= 0, constraining inequalities
//
// Dimensions:
//
// G : n x n;  g0 : n
// CE: n x p;  ce0: p
// CI: n x m;  ci0: m
//
// G must be symmetric and positive definite
// CE must be of rank p
// ----------

namespace DexiUtils;

interface

uses
  RemObjects.Elements.RTL;

{.DEFINE QPDEBUG}  // compile debugging code
                   // to activate, also assign DualQP.QPDebug

type
  EQPError = public class(Exception);
  QPDebug = public method (const Msg: String);
  QPMatrix = array of FltArray;

  DualQP = public static class
  private
    {$IFDEF QPDEBUG}
      QPIntFormat: String := ' {0,9}';
      QPIdxFormat: String := '{0,10}. ';
      QPFltFormat: String := ' {0,9:F2}';
      method DebugMsg(const Msg: String := '');
      method WriteMatrix(M: QPMatrix);
      method WriteVector(v: FltArray; f: Integer := 0; t: Integer :=-1);
      method WriteVector(v: IntArray; f: Integer := 0; t: Integer := -1);
      method DebugMatrix(const Msg: String; M: QPMatrix);
      method DebugVector(const Msg: String; v: FltArray; f: Integer := 0; t: Integer := -1);
      method DebugVector(const Msg: String; v: IntArray; f: Integer := 0; t: Integer := -1);
    {$ENDIF}
    const SQPZero = 'Null Hessian matrix';
    const SQPDegen = 'Problem is degenerate';
    const SQPMatrixDim = 'Invalid dimension of matrix "{0}": [{1}, {2}] (expected [{3}, {4}])';
    const SQPMatrixPos = 'The Hessian matrix is not positive definite';
    const bigbd = 1.0E20;
    method MatrixDim2(M: QPMatrix): Integer;
    method ValidateMatrix(M: QPMatrix; i, j: Integer; Name: String := '');
    method LeftEl(A: QPMatrix; b, y: FltArray; out yl: Float);
  public
    property QPDebug: QPDebug := nil; // alternatively: @QPDwrite or any other custom QPDebug method;
    method QPMatrix(m, n: Integer): QPMatrix; // create a m x n matrix
    method ZeroMatrix(M: QPMatrix);           // zero the contents of M
    method SProd(a, b: FltArray): Float;
    method SSqr(const a, b: Float): Float;
    method Chol(A: QPMatrix);
    method CholSolve(A: QPMatrix; b, x: FltArray);
    method DualOpt(G, CI, CE: QPMatrix; g0, ci0, ce0: FltArray; out f: Float; out x, u: FltArray; out a: IntArray; out q: Integer);
    // problem dimensions are determined from g0, ci0, and ce0
    // the arrays x, u, and a are created by DualOpt
  end;

{$IFDEF QPDEBUG}

method QPDwrite(const Msg: String);
begin
  writeLn(Msg);
end;

{$ENDIF}

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DualQP.QPMatrix(m, n: Integer): QPMatrix;
begin
  result := new FltArray[m];
  for i := low(result) to high(result) do
    result[i] := Utils.NewFltArray(n);
end;

method DualQP.ZeroMatrix(M: QPMatrix);
begin
  for i := low(M) to high(M) do
    for j := low(M[i]) to high(M[i]) do
      M[i,j] := 0.0;
end;

method DualQP.MatrixDim2(M: QPMatrix): Integer;
begin
  result := if length(M) = 0 then 0 else length(M[0]);
  for i := low(M) + 1 to high(M) do
    result := Math.Min(result, length(M[i]));
end;

method DualQP.ValidateMatrix(M: QPMatrix; i, j: Integer; Name: String := '');
begin
  if Name <> '' then Name := ' "' + Name + '"';
  if (length(M) <> i) or (MatrixDim2(M) <> j) then
    raise new EQPError(String.Format(SQPMatrixDim, [Name, length(M), MatrixDim2(M), i, j]));
end;

{$IFDEF QPDEBUG}

method DualQP.DebugMsg(const Msg: String := '');
begin
  if assigned(QPDebug) then
    QPDebug(Msg);
end;

method DualQP.WriteMatrix(M: QPMatrix);
begin
  if not assigned(QPDebug) then exit;
  for i := low(M) to high(M) do
    begin
      var Msg := String.Format(QPIdxFormat, [i]);
      for j := low(M[i]) to high(M[i]) do
        Msg := Msg + String.Format(QPFltFormat, [M[i, j]]);
      DebugMsg(Msg);
    end;
end;

method DualQP.WriteVector(v: FltArray; f: Integer := 0; t: Integer :=-1);
begin
  if not assigned(QPDebug) then exit;
  if t < 0 then t := high(v);
  for i := f to t do
    DebugMsg(String.Format(QPIdxFormat + QPFltFormat, [i, v[i]]));
end;

method DualQP.WriteVector(v: IntArray; f: Integer := 0; t: Integer := -1);
begin
  if not assigned(QPDebug) then exit;
  if t<0 then t := high(v);
  for i := f to t do
    DebugMsg(String.Format(QPIdxFormat + QPIntFormat, [i, v[i]]));
end;

method DualQP.DebugMatrix(const Msg: String; M: QPMatrix);
begin
  if not assigned(QPDebug) then exit;
  DebugMsg;
  DebugMsg(Msg);
  WriteMatrix(M);
end;

method DualQP.DebugVector(const Msg: String; v: FltArray; f: Integer := 0; t: Integer := -1);
begin
  if not assigned(QPDebug) then exit;
  DebugMsg;
  DebugMsg(Msg);
  WriteVector(v, f, t);
end;

method DualQP.DebugVector(const Msg: String; v: IntArray; f: Integer := 0; t: Integer := -1);
begin
  if not assigned(QPDebug) then exit;
  DebugMsg;
  DebugMsg(Msg);
  WriteVector(v, f, t);
end;

{$ENDIF}

method DualQP.Chol(A: QPMatrix);
begin
  for i := 0 to high(A) do
    begin
      var h := A[i,i];
      for j := 0 to i - 1 do
        h := h - A[j, i] * A[j, i];
      if h <= 0.0 then
        raise new EQPError(SQPMatrixPos);
      h := Math.Sqrt(h);
      A[i, i] := h;
      h := 1 / h;
      for k := i + 1 to high(A) do
        begin
          var s := 0.0;
          for j := 0 to i - 1 do
            s := s + A[j, i] * A[j, k];
          s := (A[k, i] - s) * h;
          A[i, k] := s;
        end;
    end;
end;

method DualQP.CholSolve(A: QPMatrix; b, x: FltArray);
begin
  var c := Utils.NewFltArray(length(A));
  for i := 0 to high(A) do
    begin
      var s := 0.0;
      for j := 0 to i - 1 do
        s := s + A[j, i] * c[j];
      c[i] := (b[i] - s) / A[i, i];
    end;
  for i := high(A) downto 0 do
    begin
      var s := 0.0;
      for j := i + 1 to high(A) do
        s := s+A[i, j] * x[j];
      x[i] := (c[i] - s) / A[i, i];
    end;
end;

method DualQP.LeftEl(A: QPMatrix; b, y: FltArray; out yl: Float);
begin
  yl := 0.0;
  for i := 0 to high(A) do
    begin
      var h := b[i];
      for j := 0 to i - 1 do
        h := h - A[j, i] * y[j];
      h := h / A[i, i];
      y[i] := h;
      yl := yl + h*h;
    end;
end;

method DualQP.SProd(a, b: FltArray): Float;
begin
  result := 0.0;
  for i := 0 to Math.Min(high(a), high(b)) do
    result := result + a[i] * b[i];
end;

method DualQP.SSqr(const a, b: Float): Float;
begin
  var aa := Math.Abs(a);
  var ab := Math.Abs(b);
  result :=
    if aa > ab then aa * Math.Sqrt(1.0 + (ab / aa) * (ab / aa))
    else if ab > aa then ab * Math.Sqrt(1.0 + (aa / ab) * (aa / ab))
    else aa * Math.Sqrt(2.0);
end;

method DualQP.DualOpt(G, CI, CE: QPMatrix; g0, ci0, ce0: FltArray; out f: Float; out x, u: FltArray; out a: IntArray; out q: Integer);
  var
    n, me, mi: Integer;
    l, p: Integer;
    t, t1, t2, cond, rnorm: Float;
    z, vr, s, d, np: FltArray;
    iai: IntArray;
    XJ, R: QPMatrix;

  method InitArrays;
  begin
    x := Utils.NewFltArray(n);
    u := Utils.NewFltArray(mi + me);
    a := Utils.NewIntArray(mi + me);
    z := Utils.NewFltArray(n);
    d := Utils.NewFltArray(n);
    np := Utils.NewFltArray(n);
    XJ := QPMatrix(n, n);
    R := QPMatrix(n, n);
    z := Utils.NewFltArray(n);
    s := Utils.NewFltArray(mi);
    vr := Utils.NewFltArray(mi + me);
    iai := Utils.NewIntArray(mi + me);
    for i := 0 to mi - 1 do
      iai[i] := i + 1;
  end;

  method Init;
  begin
    n := length(g0);
    mi := length(ci0);
    me := length(ce0);
    if n = 0 then
      raise new EQPError(SQPZero);
    ValidateMatrix(G,  n, n, 'G');
    ValidateMatrix(CI, n, mi, 'CI');
    ValidateMatrix(CE, n, me, 'CE');
    q := 0;
    InitArrays;
  end;

  method ZUp;
  begin
    for i := 0 to n - 1 do
      begin
        var s := 0.0;
        for j := 0 to n - 1 do
          s := s + XJ[j, i] * np[j];
        d[i] := s;
      end;
    for i := 0 to n - 1 do
      begin
        z[i] := 0.0;
        for j := q to n - 1 do
          z[i] := z[i] + XJ[i, j] * d[j];
      end;
  end;

  method RUp;
  begin
    for i := q - 1 downto 0 do
      begin
        var s := 0.0;
        for j := i + 1 to q - 1 do
          s := s + R[i, j] * vr[j];
        vr[i] := (d[i] - s) / R[i, i];
      end;
  end;

  method AddC;
  begin
    {$IFDEF QPDEBUG}
      DebugMsg; DebugMsg('Adding new restriction');
    {$ENDIF}
    for j := n - 1 downto q + 1 do
      begin
        var cc := d[j - 1];
        var ss := d[j];
        var h := SSqr(cc, ss);
        if h <> 0.0 then
          begin
            d[j] := 0.0;
            var s1 := ss / h;
            var c1 := cc / h;
            if c1 < 0.0 then
              begin
                c1 := -c1;
                s1 := -s1;
                d[j - 1] := -h;
              end
            else
              d[j - 1] := h;
            var xny := s1/(1.0+c1);
            for k := 0 to n - 1 do
              begin
                var t1 := XJ[k, j-1];
                var t2 := XJ[k, j];
                XJ[k, j-1] := t1 * c1 + t2 * s1;
                XJ[k,j] := xny * (t1 + XJ[k, j - 1]) - t2;
              end;
          end;
      end;
    inc(q);
    for i := 0 to q - 1 do
      R[i, q - 1] := d[i];
    if Math.Abs(d[q - 1]) <= Utils.Epsilon(var rnorm) * rnorm then
      raise new EQPError(SQPDegen);
    rnorm := Math.Max(rnorm, Math.Abs(d[q - 1]));
    {$IFDEF QPDEBUG}
      if q <> 0 then DebugMatrix('Matrix R', R);
      DebugMatrix('Matrix XJ', XJ);
    {$ENDIF}
  end;

  method DelC(l: Integer);
  begin
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg($'Deleting restriction {l}');
    {$ENDIF}
      var qq := 0;
      for i := me to q - 1 do
        if a[i] = l then
          begin
            qq := i;
            break;
          end;
      for i := qq to q - 2 do
        begin
          a[i] := a[i + 1];
          u[i] := u[i + 1];
          for j := 0 to n - 1 do
            R[j,i] := R[j, i + 1];
        end;
      a[q-1] := a[q];
      u[q-1] := u[q];
      a[q] := 0;
      u[q] := 0.0;
      for j := 0 to q - 1 do
        R[j,q-1] := 0.0;
      dec(q);
      if q <> 0 then
        begin
          for j := qq to q - 1 do
            begin
              var cc := R[j, j];
              var ss := R[j + 1, j];
              var h := SSqr(cc, ss);
              if h <> 0.0 then
                begin
                  var c1 := cc / h;
                  var s1 := ss / h;
                  R[j + 1, j] := 0.0;
                  if c1 < 0.0 then
                    begin
                      R[j,j] := -h;
                      c1 := -c1;
                      s1 := -s1;
                    end
                  else R[j, j] := h;
                  var xny := s1 / (1.0 + c1);
                  for k := j + 1 to q - 1 do
                    begin
                      var t1 := R[j, k];
                      var t2 := R[j + 1, k];
                      R[j, k] := t1 * c1 + t2 * s1;
                      R[j + 1, k] := xny * (t1 + R[j, k]) - t2;
                    end;
                  for k := 0 to n - 1 do
                    begin
                      var t1 := XJ[k, j];
                      var t2 := XJ[k, j + 1];
                      XJ[k, j] := t1 * c1 + t2 * s1;
                      XJ[k, j + 1] := xny * (XJ[k, j] + t1) - t2;
                    end;
                end;
            end;
        end;
      {$IFDEF QPDEBUG}
        if q <> 0 then DebugMatrix('Matrix R', R);
        DebugMatrix('Matrix XJ', XJ);
      {$ENDIF}
  end;

  method SolveUnconstrained;
  begin
    Chol(G);
    CholSolve(G, g0, x);
    for i := 0 to n - 1 do
      x[i] := -x[i];
    f := 0.5 * SProd(g0, x);
    {$IFDEF QPDEBUG}
      DebugVector('Unconstrained solution', x);
    {$ENDIF}
  end;

  method CondXJ: Float;
  begin
    var c1 := 0.0;
    for i := 0 to n - 1 do
      c1 := c1 + G[i, i];
    var c2 := 0.0;
    rnorm := 1.0;
    for i := 0 to n - 1 do
      begin
        if i > 0 then d[i - 1] := 0.0;
        d[i] := 1.0;
        var yl: Float;
        LeftEl(G, d, z, out yl);
        for j := 0 to n - 1 do
          XJ[i,j] := z[j];
        c2 := c2 + z[i];
      end;
    result := mi * Utils.Epsilon(var c1) * c1 * c2 * 100;
  end;

  method AddCE;
  begin
    for i := 0 to me-1 do
      begin
        {$IFDEF QPDEBUG}
          DebugMsg;
          DebugMsg($'Adding equality constraint {i}');
        {$ENDIF}
        for j := 0 to n - 1 do
          np[j] := CE[j, i];
        ZUp;
        if q <> 0 then
          RUp;
        var t := 0.0;
        if SProd(z, z) <> 0.0 then
          t := (-SProd(np, x) - ce0[i]) / SProd(z,np);
        for k := 0 to n - 1 do
          x[k] := x[k] + t * z[k];
        u[q] := t;
        for k := 0 to q - 1 do
          u[k] := u[k] - t * vr[k];
        f := f + t2*t2 * 0.5 * SProd(z,np);
        {$IFDEF QPDEBUG}
          DebugVector('Vector z', z);
          DebugVector('Vector u', u, 0, q);
          DebugVector('Vector x', x);
        {$ENDIF}
        a[i] := -1;
        AddC;
      end;
  end;

  method Psi: Float;
  begin
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg(new String('=', 50));
    {$ENDIF}
    result := 0.0;
    for i := 0 to mi - 1 do
      begin
        var su := 0.0;
        for j := 0 to n - 1 do
          su := su + CI[j,i] * x[j];
      su := su + ci0[i];
      s[i] := su;
      result := result + Math.Min(0.0, su);
    end;
    {$IFDEF QPDEBUG}
      DebugVector('Vector g[x]',s,0,mi-1);
      DebugMsg('Sum of infeasibilities: ' + String.Format(QPFltFormat, [result]));
    {$ENDIF}
  end;

  method FindRestriction(var p: Integer): Boolean;
  begin
    for i := me to q - 1 do
      iai[a[i] - 1] := 0;
    var ss := 0.0;
    p := 0;
    for i := 0 to mi - 1 do
      if (s[i] < ss) and (iai[i] <> 0) then
        begin
          ss := s[i];
          p := i + 1;
        end;
    result := ss < 0.0;
    if not result then
      exit;
    for i := 0 to n - 1 do
      np[i] := CI[i, p-1];
    u[q] := 0.0;
    a[q] := p;
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg($'Introduce restriction p={p}');
      DebugVector('Working set', a, 0, q);
      DebugVector('Gradient', np);
    {$ENDIF}
  end;

   method SolveUp;
    begin
     {$IFDEF QPDEBUG}
       DebugMsg;
       DebugMsg(new String('-', 50));
    {$ENDIF}
    ZUp;
    if q <> 0 then
      RUp;
    {$IFDEF QPDEBUG}
      DebugVector('Vector d', d);
      DebugVector('Primal correction z',z);
      if q > 0 then
        DebugVector('Dual correction v', vr, 0, q - 1);
    {$ENDIF}
  end;

  method FindStepSizes(var t, t1, t2: Float): Boolean;
  begin
    l := 0;
    t1 := bigbd;
    for k := me to q - 1 do
      if vr[k] > 0.0 then
        if u[k] / vr[k] < t1 then
        begin
          t1 := u[k] / vr[k];
          l := a[k];
        end;
    t2 :=
      if SProd(z, z) <> 0.0 then -s[p - 1] / SProd(z, np)
      else bigbd;
    t := Math.Min(t1, t2);
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg('Stepsizes: ' + String.Format(QPFltFormat + QPFltFormat, [t1, t2]));
    {$ENDIF}
    result := t < bigbd;
  end;

  method CalcF;
  begin
    for k := 0 to n - 1 do
      x[k] := x[k] + t * z[k];
    f := f + t * SProd(z, np) * (0.5 * t + u[q]);
    {$IFDEF QPDEBUG}
      DebugVector('Current solution',x);
      DebugMsg('Function value: ' + String.Format(QPFltFormat, [f]));
   {$ENDIF}
    for k := 0 to q - 1 do
      u[k] := u[k] + t * (-vr[k]);
    u[q] := u[q] + t;
  end;

  method PartialStep;
  begin
    iai[l - 1] := l;
    DelC(l);
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg('Partial step');
      DebugVector('Working set', a, 0, q - 1);
      DebugVector('Vector u', u, 0, q - 1);
   {$ENDIF}
    var su := 0.0;
    for k := 0 to n - 1 do
      su := su + CI[k, p - 1] * x[k];
    s[p - 1] := su + ci0[p - 1];
  end;

  method PartialStepDuals;
  begin
    for k := 0 to q - 1 do
      u[k] := u[k] + t * (-vr[k]);
    u[q] := u[q] + t;
    iai[l - 1] := l;
    DelC(l);
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg('Partial step in the duals only');
      DebugVector('Working set', a, 0, q - 1);
      DebugVector('Vector u', u, 0, q - 1);
     {$ENDIF}
  end;

  method FullStep;
  begin
    AddC;
    iai[p - 1] := 0;
    {$IFDEF QPDEBUG}
      DebugMsg;
      DebugMsg('Full step');
      DebugVector('Working set', a, 0, q - 1);
      DebugVector('Vector u', u, 0, q - 1);
  {$ENDIF}
  end;

begin
  Init;
  SolveUnconstrained;
  cond := CondXJ;
  AddCE;
  while (Math.Abs(Psi) > cond) and FindRestriction(var p) do
    begin
      repeat
        SolveUp;
        if not FindStepSizes(var t, var t1, var t2) then
          exit;
        if t2 >= bigbd then
          PartialStepDuals
        else
          begin
            CalcF;
            if t <> t2 then
              PartialStep;
          end;
      until t = t2;
      FullStep;
    end;
end;

end.
