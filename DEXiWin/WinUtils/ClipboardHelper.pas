// ClipboardHelper.pas is part of
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
// ClipboardHelper.pas implements copying and pasting of Metafiles to and from the system clipboard.
// Unfortunately, WinForms treats Metafiles than other image formats and lacks a consistent
// error-free support for common operations such as copy/paste. Thus this helper, largely
// borrowed from various discussions on https://stackoverflow.com/
// ----------

namespace DexiUtils;

uses
  System.Drawing.Imaging,
  System.Runtime.InteropServices,
  System.Drawing;

type
  ClipboardMetafileHelper = public class
  private
    const CF_BITMAP = 2;
    const CF_DIB = 8;
    const CF_ENHMETAFILE = 14;
    const SRCCOPY = $00CC0020;

    [DllImport("user32.dll")]
    class method OpenClipboard(hWndNewOwner: IntPtr): Boolean; external;

    [DllImport("user32.dll")]
    class method EmptyClipboard: Boolean; external;

    [DllImport("user32.dll")]
    class method IsClipboardFormatAvailable(format: UInt32): Boolean; external;

    [DllImport("user32.dll")]
    class method GetClipboardData(format: UInt32): IntPtr; external;

    [DllImport("user32.dll")]
    class method SetClipboardData(uFormat: UInt32; hMem: IntPtr): IntPtr; external;

    [DllImport("user32.dll")]
    class method CloseClipboard: Boolean; external;

    [DllImport("gdi32.dll")]
    class method CopyEnhMetaFile(hemfSrc: IntPtr; hNULL: IntPtr): IntPtr; external;

    [DllImport("gdi32.dll")]
    class method DeleteEnhMetaFile(hemf: IntPtr): Boolean; external;

    // Metafile mf is set to a state that is not valid inside this function.
    class method PutEnhMetafileOnClipboard(hWnd: IntPtr; mf: Metafile): Boolean; public;
    begin
      var bResult: Boolean := false;
      var hEMF: IntPtr;
      var hEMF2: IntPtr;
      hEMF := mf.GetHenhmetafile();
      //  invalidates mf
      if not hEMF.Equals(IntPtr.Zero) then
        begin
          hEMF2 := CopyEnhMetaFile(hEMF, IntPtr.Zero);
          if not hEMF2.Equals(IntPtr.Zero) then
            begin
              if OpenClipboard(hWnd) then
                try
                  if EmptyClipboard then
                    begin
                      var hRes: IntPtr := SetClipboardData(CF_ENHMETAFILE, hEMF2);
                      bResult := hRes.Equals(hEMF2);
                    end;
                finally
                  CloseClipboard;
                end;
            end;
          DeleteEnhMetaFile(hEMF);
        end;
      result := bResult;
    end;

  end;

end.
