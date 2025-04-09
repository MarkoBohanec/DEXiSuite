// CtrlPreview.pas is part of
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
// CtrlPreview.pas implements a basic user control for previewing 'RptPrintDocument's.
// Used in CtrlFormReport.pas.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Drawing.Imaging,
  System.Drawing.Printing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  DexiUtils;

type
  /// <summary>
  /// Summary description for CtrlPreview.
  /// </summary>
  CtrlPreview = public partial class(System.Windows.Forms.UserControl)
  private
    fDocument: RptPrintDocument;
    fFormatter: RptImageFormatter;
    fZoomMode: PreviewZoomMode;
    fZoom: Float;
    fStartPage: Integer;
    fBackBrush: Brush;
    fPtLast: Point;
    fPageBottom: Integer;
    fHimm2pix: PointF := new PointF(-1, -1);
    class const MARGIN = 4;
  protected
    method Dispose(aDisposing: Boolean); override;
    method SetDocument(aDocument: RptPrintDocument);
    method SetZoomMode(aZoomMode: PreviewZoomMode);
    method SetZoom(aZoom: Float);
    method SetStartPage(aStartPage: Integer);
    method SetBackColor(aColor: Color);
    method UpdateScrollBars;
    method UpdatePreview;
    method OnStartPageChanged(e: EventArgs);
    method OnPageCountChanged(e: EventArgs);
    method OnZoomModeChanged(e: EventArgs);
    method IsInputKey(keyData: Keys): Boolean; override;
    method OnSizeChanged(e: EventArgs); override;
    method OnMouseDown(e: MouseEventArgs); override;
    method OnMouseUp(e: MouseEventArgs); override;
    method OnMouseMove(e: MouseEventArgs); override;
    method OnMouseWheel(e: MouseEventArgs); override;
    method OnPaintBackground(e: PaintEventArgs); override; empty;
    method OnPaint(e: PaintEventArgs); override;
    method GetImageSizeInPixels(img: Image): Size;
    method GetImageRectangle(img: Image): Rectangle;
    method RenderPage(g: Graphics; img: Image; rc: Rectangle);

  public
    constructor;
    property Document: RptPrintDocument read fDocument write SetDocument;

    [DefaultValue(PreviewZoomMode.PageWidth)]
    property ZoomMode: PreviewZoomMode read fZoomMode write SetZoomMode;

    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    property Zoom: Double read fZoom write SetZoom;

    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    property StartPage: Integer read fStartPage write SetStartPage;

    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    property PageCount: Integer read if fFormatter = nil then 0 else fFormatter.PageCount;

    [DefaultValue(typeOf(Color), "AppWorkspace")]
    property BackColor: Color read inherited BackColor write SetBackColor; override;

    [Browsable(false)]
    property Page[aIdx: Integer]: RptImagePage read fFormatter.ImagePage[aIdx];

    event StartPageChanged: EventHandler;
    event PageCountChanged: EventHandler;
    event ZoomModeChanged: EventHandler;
    method RefreshPreview;
    method Home;
    method OnKeyDown(e: KeyEventArgs); override;
  end;

type
  PreviewZoomMode = public enum (ActualSize, FullPage, PageWidth, TwoPages, Custom);

implementation

{$REGION Construction and Disposition}

constructor CtrlPreview;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  BackColor := SystemColors.AppWorkspace;
  ZoomMode := PreviewZoomMode.PageWidth;
  StartPage := 0;
  SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
end;

method CtrlPreview.Dispose(aDisposing: Boolean);
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

{$REGION CtrlPreview}

method CtrlPreview.SetDocument(aDocument: RptPrintDocument);
begin
  fDocument := aDocument;
  fFormatter := fDocument:Formatter;
  RefreshPreview;
end;

method CtrlPreview.SetZoomMode(aZoomMode: PreviewZoomMode);
begin
  if aZoomMode <> fZoomMode then
    begin
      fZoomMode := aZoomMode;
      UpdateScrollBars;
      OnZoomModeChanged(EventArgs.Empty);
    end;
end;

method CtrlPreview.SetZoom(aZoom: Float);
begin
  if (aZoom <> fZoom) or (ZoomMode <> ZoomMode.Custom) then
    begin
      ZoomMode := ZoomMode.Custom;
      fZoom := aZoom;
      UpdateScrollBars;
      OnZoomModeChanged(EventArgs.Empty);
    end;
end;

method CtrlPreview.SetStartPage(aStartPage: Integer);
begin
  if aStartPage > (PageCount - 1) then
    aStartPage := PageCount - 1;
  if aStartPage < 0 then
    aStartPage := 0;
  if aStartPage <> fStartPage then
    begin
      fStartPage := aStartPage;
      UpdateScrollBars;
      OnStartPageChanged(EventArgs.Empty);
    end;
end;

method CtrlPreview.SetBackColor(aColor: Color);
begin
  inherited BackColor := aColor;
  fBackBrush := new SolidBrush(aColor);
end;

method CtrlPreview.UpdateScrollBars;
begin
  //  get image rectangle to adjust scroll size
  var rc: Rectangle := Rectangle.Empty;
  if (fFormatter <> nil) and fFormatter.HasImage(StartPage) then
    using lImage := fFormatter:GetImage(StartPage) do
      rc := GetImageRectangle(lImage);
  //  calculate new scroll size
  var scrollSize: Size := new Size(0, 0);
  case fZoomMode of
    ZoomMode.PageWidth:  scrollSize := new Size(0, rc.Height + (2 * MARGIN));
    ZoomMode.ActualSize,
    ZoomMode.Custom:     scrollSize := new Size(rc.Width + (2 * MARGIN), rc.Height + (2 * MARGIN));
  end;
  //  apply if needed
  if scrollSize <> AutoScrollMinSize then begin
    AutoScrollMinSize := scrollSize;
  end;
  //  ready to update
  UpdatePreview;
end;

method CtrlPreview.UpdatePreview;
begin
  if fStartPage > (PageCount - 1) then
    fStartPage := PageCount - 1;
  if fStartPage < 0 then
    fStartPage := 0;
  Invalidate;
end;

method CtrlPreview.RefreshPreview;
begin
  UpdatePreview;
  UpdateScrollBars;
end;

method CtrlPreview.Home;
begin
  AutoScrollPosition := Point.Empty;
end;

method CtrlPreview.OnStartPageChanged(e: EventArgs);
begin
  if assigned(StartPageChanged) then
    StartPageChanged(self, e);
end;

method CtrlPreview.OnPageCountChanged(e: EventArgs);
begin
  if assigned(PageCountChanged) then
    PageCountChanged(self, e);
end;

method CtrlPreview.OnZoomModeChanged(e: EventArgs);
begin
  if assigned(ZoomModeChanged) then
    ZoomModeChanged(self, e);
end;

method CtrlPreview.IsInputKey(keyData: Keys): Boolean;
begin
  case keyData of
    Keys.Left,
    Keys.Up,
    Keys.Right,
    Keys.Down,
    Keys.PageUp,
    Keys.PageDown,
    Keys.Home,
    Keys.End:
      exit true;
  end;
  exit inherited IsInputKey(keyData);
end;

method CtrlPreview.OnKeyDown(e: KeyEventArgs);
begin
  inherited OnKeyDown(e);
  if e.Handled then
    exit;
  var lCtrlKey := (ModifierKeys and Keys.Control) = Keys.Control;
  case e.KeyCode of
    Keys.Left,
    Keys.Up,
    Keys.Right,
    Keys.Down:
      begin
        if (ZoomMode = ZoomMode.FullPage) or (ZoomMode = ZoomMode.TwoPages) then
          case e.KeyCode of
            Keys.Left, Keys.Up:    StartPage := StartPage - 1;
            Keys.Right, Keys.Down: StartPage := StartPage + 1;
          end;
        var pt: Point := AutoScrollPosition;
        case e.KeyCode of
          Keys.Left:  pt.X := pt.X + 20;
          Keys.Right: pt.X := pt.X - 20;
          Keys.Up:    pt.Y := pt.Y + 20;
          Keys.Down:  pt.Y := pt.Y - 20;
        end;
        AutoScrollPosition := new Point(-pt.X, -pt.Y);
      end;
    Keys.PageUp:
      if lCtrlKey then
        begin
          AutoScrollPosition := Point.Empty;
          StartPage := 0;
        end
      else
        StartPage := StartPage - 1;
    Keys.PageDown:
      if lCtrlKey then
        begin
          AutoScrollPosition := Point.Empty;
          StartPage := PageCount - 1;
        end
      else
        StartPage := StartPage + 1;
    Keys.Home:
      begin
        if lCtrlKey then
          StartPage := 0;
        AutoScrollPosition := Point.Empty;
      end;
    Keys.End:
      begin
        if lCtrlKey then
          begin
            StartPage := PageCount - 1;
            AutoScrollPosition := Point.Empty;
          end
        else
          AutoScrollPosition := new Point(0, fPageBottom);
      end;
    else
      exit;
  end;
  //  if we got here, the event was handled
  e.Handled := true;
end;

method CtrlPreview.OnSizeChanged(e: EventArgs);
begin
  UpdateScrollBars;
  inherited OnSizeChanged(e);
end;

method CtrlPreview.OnMouseDown(e: MouseEventArgs);
begin
  inherited OnMouseDown(e);
  if (e.Button = MouseButtons.Left) and (AutoScrollMinSize <> Size.Empty) then
    begin
      Cursor := Cursors.NoMove2D;
      fPtLast := new Point(e.X, e.Y);
    end;
end;

method CtrlPreview.OnMouseUp(e: MouseEventArgs);
begin
  inherited OnMouseUp(e);
  if (e.Button = MouseButtons.Left) and (Cursor = Cursors.NoMove2D) then
    Cursor := Cursors.Default;
end;

method CtrlPreview.OnMouseMove(e: MouseEventArgs);
begin
  inherited OnMouseMove(e);
  if Cursor = Cursors.NoMove2D then
    begin
      var dx := e.X - fPtLast.X;
      var dy := e.Y - fPtLast.Y;
      if (dx <> 0) or (dy <> 0) then
        begin
          var pt := AutoScrollPosition;
          AutoScrollPosition := new Point(-pt.X - dx, -pt.Y - dy);
          fPtLast := new Point(e.X, e.Y);
        end;
  end;
end;

method CtrlPreview.OnMouseWheel(e: MouseEventArgs);
begin
  if (Control.ModifierKeys and Keys.Control) <> 0 then
    begin
      //  calculate event position in document percentage units
      var asp := AutoScrollPosition;
      var sms := AutoScrollMinSize;
      var ptMouse := e.Location;
      var ptDoc := new PointF(
        (if sms.Width > 0 then ((ptMouse.X - asp.X) / Single(sms.Width)) else (0)),
        (if sms.Height > 0 then ((ptMouse.Y - asp.Y) / Single(sms.Height)) else (0)));
      //  update the zoom
      var lZoom := Zoom * (if e.Delta > 0 then (1.1) else (0.9));
      Zoom := Math.Min(5, Math.Max(0.1, lZoom));
      //  restore position in document percentage units
      sms := AutoScrollMinSize;
      self.AutoScrollPosition := new Point(Integer((ptDoc.X * sms.Width) - ptMouse.X), Integer((ptDoc.Y * sms.Height) - ptMouse.Y));
    end
  else
    inherited OnMouseWheel(e);
end;

method CtrlPreview.GetImageRectangle(img: Image): Rectangle;
begin
  //  start with regular image rectangle
  var sz: Size := GetImageSizeInPixels(img);
  var rc: Rectangle := new Rectangle(0, 0, sz.Width, sz.Height);
  //  calculate zoom
  var rcCli: Rectangle := self.ClientRectangle;
  case fZoomMode of
    ZoomMode.ActualSize:
      fZoom := 1;
    ZoomMode.TwoPages:
      begin
        rc.Width := rc.Width * 2;
        var zoomX: Double := (if rc.Width > 0 then (rcCli.Width / Double(rc.Width)) else (0));
        var zoomY: Double := (if rc.Height > 0 then (rcCli.Height / Double(rc.Height)) else (0));
        fZoom := Math.Min(zoomX, zoomY);
      end;
    ZoomMode.FullPage:
      begin
        var zoomX: Double := (if rc.Width > 0 then (rcCli.Width / Double(rc.Width)) else (0));
        var zoomY: Double := (if rc.Height > 0 then (rcCli.Height / Double(rc.Height)) else (0));
        fZoom := Math.Min(zoomX, zoomY);
      end;
    ZoomMode.PageWidth:
      fZoom := (if rc.Width > 0 then (rcCli.Width / Double(rc.Width)) else (0));
  end;
  //  apply zoom factor
  rc.Width := Integer(rc.Width * fZoom);
  rc.Height := Integer(rc.Height * fZoom);
  //  center image
  var dx: Integer := (rcCli.Width - rc.Width) / 2;
  if dx > 0 then begin
    rc.X := rc.X + dx;
  end;
  var dy: Integer := (rcCli.Height - rc.Height) / 2;
  if dy > 0 then begin
    rc.Y := rc.Y + dy;
  end;
  //  add some extra space
  rc.Inflate(-MARGIN, -MARGIN);
  if fZoomMode = ZoomMode.TwoPages then
    rc.Inflate(-MARGIN / 2, 0);
  //  done
  result := rc;
end;

method CtrlPreview.GetImageSizeInPixels(img: Image): Size;
begin
  //  get image size
  var szf: SizeF := img.PhysicalDimension;
  //  if it is a metafile, convert to pixels
  if img is Metafile then
    begin
    //  get screen resolution
    if fHimm2pix.X < 0 then
      using g := self.CreateGraphics() do
        begin
          fHimm2pix.X := g.DpiX / 2540.0;
          fHimm2pix.Y := g.DpiY / 2540.0;
        end;
    //  convert himetric to pixels
    szf.Width := szf.Width * fHimm2pix.X;
    szf.Height := szf.Height * fHimm2pix.Y;
  end;
  //  done
  result := Size.Truncate(szf);
end;

method CtrlPreview.RenderPage(g: Graphics; img: Image; rc: Rectangle);
begin
  //  draw the page
  rc.Offset(1, 1);
  g.DrawRectangle(Pens.Black, rc);
  rc.Offset(-1, -1);
  g.FillRectangle(Brushes.White, rc);
  g.DrawImage(img, rc);
  g.DrawRectangle(Pens.Black, rc);
  //  exclude cliprect to paint background later
  rc.Width := rc.Width + 1;
  rc.Height := rc.Height + 1;
  g.ExcludeClip(rc);
  rc.Offset(1, 1);
  g.ExcludeClip(rc);
  fPageBottom := rc.Bottom;
end;

method CtrlPreview.OnPaint(e: PaintEventArgs);
begin
  e.Graphics.FillRectangle(fBackBrush, ClientRectangle);
  if fFormatter = nil then
    exit;
  if fFormatter.HasImage(StartPage) then
    using img := fFormatter.GetImage(StartPage) do
      begin
        var rc := GetImageRectangle(img);
        if (rc.Width > 2) and (rc.Height > 2) then
          begin
            //  adjust for scrollbars
            rc.Offset(AutoScrollPosition);
            //  render single page
            if fZoomMode <> ZoomMode.TwoPages then
              RenderPage(e.Graphics, img, rc)
            else
              begin
                //  render first page
                rc.Width := (rc.Width - MARGIN) / 2;
                RenderPage(e.Graphics, img, rc);
                //  render second page
                if fFormatter.HasImage(StartPage + 1) then
                  using img2 := fFormatter.GetImage(StartPage + 1) do
                    begin
                      //  update bounds in case orientation changed
                      rc := GetImageRectangle(img2);
                      rc.Width := (rc.Width - MARGIN) / 2;
                      //  render second page
                      rc.Offset(rc.Width + MARGIN, 0);
                      RenderPage(e.Graphics, img2, rc);
                    end;
              end;
        end;
    end;
end;

{$ENDREGION}

end.