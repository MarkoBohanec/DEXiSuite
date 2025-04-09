namespace DEXiEval;

uses
  RemObjects.Elements.RTL;

type
  Program = class
  public

    class method Main(args: array of String): Int32;
    begin
      DEXiEval.Run(args, '.NET Core');
    end;

  end;

end.