// CtrlTabs.pas is part of
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
// CtrlTabs.pas implements a user control containing zero or more tab pages that can be
// optionally closed and/or moved.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Drawing.Drawing2D,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel;

type
  /// <summary>
  /// CtrlTabs is a UserControl that implements a TabControl with closable and movable (drag/drop) tab pages.
  /// It contains only TabCtrl: TabControl component.
  /// It is assumed that tab pages of type ClosableTabPage are added programmatically.
  /// </summary>
  CtrlTabs = public partial class (System.Windows.Forms.UserControl)
  private
    fTabPageState: array of TabPage := nil;  // Initial tab page state before drag/drop, to be restored after cancel
    fPreDraggedTab: ClosableTabPage := nil;  // Tab page to be dragged after mouse movement has been detected
    fDragStartPoint: Point;                  // Initial mouse down location for dragging
    method TabCtrl_QueryContinueDrag(sender: System.Object; e: System.Windows.Forms.QueryContinueDragEventArgs);
    method TabCtrl_DragOver(sender: System.Object; e: System.Windows.Forms.DragEventArgs);
    method TabCtrl_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method TabCtrl_MouseLeave(sender: System.Object; e: System.EventArgs);
    method TabCtrl_MouseMove(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TabCtrl_MouseUp(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TabCtrl_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TabCtrl_DrawItem(sender: System.Object; e: System.Windows.Forms.DrawItemEventArgs);
  protected
    method BeginMove;     // Prepare for tab moving: remember the order of tab pages
    method EndMove;       // Clear dragging-related private data, so that IsMoving = false
    method CancelMove;    // Establish the pre-dragging tab order and EndMove
    method IsDragGesture(aStart, aCurrent: Point): Boolean;
    method GetTabPages: array of TabPage;
    method SetTabPages(aPages: array of TabPage);
    method GetPageIndex: Integer;
    method SwapTabPages(aSrc, aDst: Integer);
    property IsMoving: Boolean read fTabPageState <> nil;
    method Dispose(disposing: Boolean); override;
  public
    constructor;
    class method TrimTextToFit(aGraphics: Graphics; aText: String; aFont: Font; aWidth: Integer): String;
    property TabPadding: Integer read TabCtrl.Padding.X;
    property TabsCtrl: TabControl read TabCtrl; // Exposing TabCtrl to other controls, e.g., for initialization
    property MinimumHorizontalDragDistance := 5;
    property MinimumVerticalDragDistance := 5;
    property TabPages: array of TabPage read GetTabPages write SetTabPages;
    property PageIndex: Integer read GetPageIndex;
    property SelectedPage: CtrlForm read CtrlForm(TabCtrl.SelectedTab.Controls[0]);
    method AddPage(aPage: ClosableTabPage): ClosableTabPage;
    method AddPage(aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
    method AddPage(aImageIndex: Integer; aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
    method AddPage(aImageKey: String; aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
    method RemovePage(aPage: TabPage);
  end;

type
  CloseButtonState = enum (Normal, Hover, Press);
  ClosableTabPage = public class (TabPage)
    var fCloseImage: Image := nil;
    property ParentTabControl: TabControl read TabControl(Parent);
    method CreateCloseButtons;
    method GetCloseButton(aType: CloseButtonState): Image;
  private
    method SetCloseImage(aImage: Image);
    method GetIndex: Integer;
  assembly
    property IsHovering := false;
    property IsHoveringClose := false;
    property IsHoveringPress := false;
    property CloseButtonRectangle: nullable Rectangle := nil;
  public
    property AllowClose := false;
    property AllowMove := false;
    property CloseImage: Image read fCloseImage write SetCloseImage;
    property CloseImageHover: Image := nil;
    property CloseImagePress: Image := nil;
    property &Index: Integer read GetIndex;
    event TabClosed: EventHandler;
    constructor;
    constructor (aText: String; aControl: Control := nil);
    method Close;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlTabs;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  SetStyle(ControlStyles.DoubleBuffer, true);
  SetStyle(ControlStyles.AllPaintingInWmPaint, true);
  SetStyle(ControlStyles.UserPaint, true);
  SetStyle(ControlStyles.SupportsTransparentBackColor, false);
  SetStyle(ControlStyles.Opaque, false);
  SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
  SetStyle(ControlStyles.ResizeRedraw, true);
end;

method CtrlTabs.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    TabCtrl.ImageList := nil;
//    for each lPage in TabCtrl.TabPages do
//      AppUtils.DisposeObjects(lPage);
//    TabCtrl := nil;
//    fTabPageState := nil;
//    fPreDraggedTab := nil;
//    Events.Dispose;
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

{$REGION CtrlTabs}

class method CtrlTabs.TrimTextToFit(aGraphics: Graphics; aText: String; aFont: Font; aWidth: Integer): String;
begin
  if String.IsNullOrEmpty(aText) then
    exit aText;
  result := aText + '...';
  while aGraphics.MeasureString(result, aFont).Width > aWidth do
    begin
      aText := aText.Substring(0, aText.Length - 1);
      result := aText + '...';
    end;
end;

method CtrlTabs.BeginMove;
begin
  if fPreDraggedTab = nil then
    exit;
  fTabPageState := GetTabPages;
  TabCtrl.DoDragDrop(fPreDraggedTab, DragDropEffects.All);
end;

method CtrlTabs.EndMove;
begin
  fTabPageState := nil;
  fPreDraggedTab := nil;
end;

method CtrlTabs.CancelMove;
begin
  if fTabPageState <> nil then
    begin
      SetTabPages(fTabPageState);
      TabCtrl.SelectedTab := fPreDraggedTab;
    end;
  EndMove;
end;

method CtrlTabs.IsDragGesture(aStart, aCurrent: Point): Boolean;
begin
	result :=
    (Math.Abs(aStart.X - aCurrent.X) > MinimumHorizontalDragDistance) or
    (Math.Abs(aStart.Y - aCurrent.Y) > MinimumVerticalDragDistance);
end;

method CtrlTabs.GetTabPages: array of TabPage;
begin
  result := new TabPage[TabCtrl.TabPages.Count];
  for i := 0 to high(result) do
    result[i] := TabCtrl.TabPages[i];
end;

method CtrlTabs.SetTabPages(aPages: array of TabPage);
begin
  TabCtrl.TabPages.Clear;
  TabCtrl.TabPages.AddRange(aPages);
end;

method CtrlTabs.GetPageIndex: Integer;
begin
  result := TabCtrl.SelectedIndex;
end;

method CtrlTabs.SwapTabPages(aSrc, aDst: Integer);
begin
  if aSrc = aDst then
    exit;
  var lSrcTab := TabCtrl.TabPages[aSrc];
  var lDstTab := TabCtrl.TabPages[aDst];
  TabCtrl.TabPages[aDst] := lSrcTab;
  TabCtrl.TabPages[aSrc] := lDstTab;
  TabCtrl.SelectedIndex := aDst;
  TabCtrl.Invalidate;
end;

method CtrlTabs.AddPage(aPage: ClosableTabPage): ClosableTabPage;
begin
  result := aPage;
  if aPage <> nil then
    TabCtrl.TabPages.Add(aPage);
end;

method CtrlTabs.AddPage(aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
begin
  result := new ClosableTabPage(aHead, aControl, AllowClose := aAllowClose, AllowMove := aAllowMove);
  AddPage(result);
end;

method CtrlTabs.AddPage(aImageIndex: Integer; aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
begin
  result := AddPage(aHead, aControl, aAllowClose, aAllowMove);
  result.ImageIndex := aImageIndex;
end;

method CtrlTabs.AddPage(aImageKey: String; aHead: String; aControl: Control := nil; aAllowClose: Boolean := true; aAllowMove: Boolean := false): ClosableTabPage;
begin
  result := AddPage(aHead, aControl, aAllowClose, aAllowMove);
  result.ImageKey := aImageKey;
end;

method CtrlTabs.RemovePage(aPage: TabPage);
begin
//  aPage.Dispose;
  TabCtrl.TabPages.Remove(aPage);
end;

method CtrlTabs.TabCtrl_DrawItem(sender: System.Object; e: System.Windows.Forms.DrawItemEventArgs);
begin
  var iconX := e.Bounds.X;
  var iconY := 0;
  var closeX := e.Bounds.Right;
  var closeY := 0;
  var lTabPage := TabCtrl.TabPages[e.Index];
  var lTab := ClosableTabPage(lTabPage);
  var lTabRect := TabCtrl.GetTabRect(e.Index);
  // --- Draw the border background.
  if e.State = DrawItemState.Selected then
    // ---- Selected tab.
    using brush := new SolidBrush(Color.White) do
      e.Graphics.FillRectangle(brush, lTabRect)
  else if assigned(lTab) and lTab.IsHovering then
    // ---- When hovering over not selected tab.
    using brush := new LinearGradientBrush(lTabRect, Color.White, Color.LightBlue, LinearGradientMode.Vertical) do
      e.Graphics.FillRectangle(brush, lTabRect)
  else
    // ---- Non selected tab.
    using brush := new LinearGradientBrush(lTabRect, Color.White, Color.LightGray, LinearGradientMode.Vertical) do
      e.Graphics.FillRectangle(brush, lTabRect);
  // --- Draw the tab incon if exists.
  if assigned(TabCtrl.ImageList) and ((lTabPage.ImageIndex > -1) or not String.IsNullOrEmpty(lTabPage.ImageKey)) then
    begin
      var lImg :=
        if lTabPage.ImageIndex > -1 then TabCtrl.ImageList.Images[lTabPage.ImageIndex]
        else TabCtrl.ImageList.Images[lTabPage.ImageKey];
      if assigned(lImg) then
        begin
          iconX := lTabRect.X + TabPadding;
          iconY := (lTabRect.Height - lImg.Height) / 2;
          e.Graphics.DrawImageUnscaled(lImg, iconX, iconY + lTabRect.Y);
          iconX := iconX + lImg.Width;
        end;
    end;
  // ---- Draw the close button
  if assigned(lTab) then
    if lTab.AllowClose then
      begin
        var lImg := lTab.CloseImage;
        if lTab.IsHoveringPress and assigned(lTab.CloseImagePress) then
          lImg := lTab.CloseImagePress
        else if lTab.IsHoveringClose and assigned(lTab.CloseImageHover) then
          lImg := lTab.CloseImageHover;
        if assigned(lImg) then
          begin
            closeX := lTabRect.Right - TabPadding - lImg.Width;
            closeY := ((lTabRect.Height - lImg.Height) + lTabRect.Y) / 2;
            lTab.CloseButtonRectangle := new Rectangle(closeX, closeY, lImg.Width, lImg.Height);
            e.Graphics.DrawImageUnscaled(lImg, closeX, closeY + lTabRect.Y);
            e.DrawFocusRectangle;
          end;
      end;
  // ---- Draw the text. If the text is too long then cut off the end and add '...' To avoid this behaviour, set the TabControl.ItemSize to larger value.
  var lText := TabCtrl.TabPages[e.Index].Text;
  var lFont :=
    if e.State = DrawItemState.Selected then new Font(e.Font, FontStyle.Bold)
    else e.Font;
  var lTextSize := e.Graphics.MeasureString(lText, lFont);
  var textX := iconX + TabPadding;
  var textY := ((lTabRect.Height - lTextSize.Height) + lTabRect.Y) / 2;
  // --- calculate if the text fits as is. If not then trim it.
  if (textX + lTextSize.Width) > (closeX - TabPadding) then
    lText := TrimTextToFit(e.Graphics, lText, lFont, closeX - TabPadding - textX);
  e.Graphics.DrawString(lText, lFont, Brushes.Black, textX, textY + lTabRect.Y);
end;

method CtrlTabs.TabCtrl_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if e.Button = MouseButtons.Left then
    for each lTabPage in TabCtrl.TabPages do
      if lTabPage is ClosableTabPage then
        begin
          var lTab := ClosableTabPage(lTabPage);
          var lTabRect := TabCtrl.GetTabRect(lTab.Index);
          if lTab.IsHoveringClose then
            begin
              lTab.IsHoveringPress := true;
              TabCtrl.Invalidate(lTabRect);
              exit;
            end;
          if TabCtrl.AllowDrop and lTab.AllowMove and lTabRect.Contains(e.Location) then
            begin
              fPreDraggedTab := lTab;
              fDragStartPoint := e.Location;
            end;
        end;
end;

method CtrlTabs.TabCtrl_MouseUp(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if e.Button = MouseButtons.Left then
    for each lTabPage in TabCtrl.TabPages do
      if lTabPage is ClosableTabPage then
        begin
          var lTab := ClosableTabPage(lTabPage);
          if assigned(lTab.CloseButtonRectangle) and lTab.CloseButtonRectangle.Contains(e.Location) then
            begin
              lTab.Close;
              exit;
            end;
        end;
end;

method CtrlTabs.TabCtrl_MouseMove(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  for each lTabPage in TabCtrl.TabPages do
    if lTabPage is ClosableTabPage then
      begin
        var lTab := ClosableTabPage(lTabPage);
        var lTabRect := TabCtrl.GetTabRect(lTab.Index);
        // ---- Check for hovering on a close button.
        if assigned(lTab.CloseButtonRectangle) then
          if lTab.CloseButtonRectangle.Contains(e.Location) and not lTab.IsHoveringClose then
            begin
              lTab.IsHoveringClose := true;
              lTab.IsHoveringPress := false;
              TabCtrl.Invalidate(lTabRect);
            end
          else if not lTab.CloseButtonRectangle.Contains(e.Location) and lTab.IsHoveringClose then
            begin
              lTab.IsHoveringClose := false;
              lTab.IsHoveringPress := false;
              TabCtrl.Invalidate(lTabRect);
            end;
        // ---- Check for hovering on a tab.
        if TabCtrl.GetTabRect(lTab.Index).Contains(e.Location) and not lTab.IsHovering then
          begin
            lTab.IsHovering := true;
            TabCtrl.Invalidate(lTabRect);
          end
        else if not TabCtrl.GetTabRect(lTab.Index).Contains(e.Location) and lTab.IsHovering then
          begin
            lTab.IsHovering := false;
            TabCtrl.Invalidate(lTabRect);
        end;
        // ---- Check for dragging
        if TabCtrl.AllowDrop and lTab.AllowMove and lTab.IsHovering and (lTab = fPreDraggedTab) and (e.Button = MouseButtons.Left) and IsDragGesture(fDragStartPoint, e.Location) then
          BeginMove;
      end;
end;

method CtrlTabs.TabCtrl_MouseLeave(sender: System.Object; e: System.EventArgs);
begin
  for each lTabPage in TabCtrl.TabPages do
    if lTabPage is ClosableTabPage then
      begin
        var lTab := ClosableTabPage(lTabPage);
        var lTabRect := TabCtrl.GetTabRect(lTab.Index);
        lTab.IsHovering := false;
        lTab.IsHoveringClose := false;
        lTab.IsHoveringPress := false;
        TabCtrl.Invalidate(lTabRect);
      end;
end;

method CtrlTabs.TabCtrl_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  TabCtrl.Invalidate;
end;

method CtrlTabs.TabCtrl_DragOver(sender: System.Object; e: System.Windows.Forms.DragEventArgs);
begin
  if not IsMoving then
    exit;
  var pt := new Point(e.X, e.Y);
  pt := PointToClient(pt);
  for each lTabPage in TabCtrl.TabPages do
    if lTabPage is ClosableTabPage then
      begin
        var lTab := ClosableTabPage(lTabPage);
        var lTabRect := TabCtrl.GetTabRect(lTab.Index);
        if lTabRect.Contains(pt) then
          begin
				    if e.Data.GetDataPresent(typeOf(ClosableTabPage)) then
              begin
                e.Effect := DragDropEffects.Move;
					      var lDraggedTab := e.Data.GetData(typeOf(ClosableTabPage)) as ClosableTabPage;
                SwapTabPages(lDraggedTab.Index, lTab.Index);
                exit;
              end;
          end;
      end;
end;

method CtrlTabs.TabCtrl_QueryContinueDrag(sender: System.Object; e: System.Windows.Forms.QueryContinueDragEventArgs);
begin
  if e.Action = DragAction.Cancel then
    CancelMove
  else if e.Action = DragAction.Drop then
    EndMove;
end;

{$ENDREGION}

{$REGION ClosableTabPage}

constructor ClosableTabPage;
begin
  inherited constructor;
  CreateCloseButtons;
end;

constructor ClosableTabPage(aText: String; aControl: Control := nil);
begin
  inherited constructor (aText);
  CreateCloseButtons;
  if aControl <> nil then
    Controls.Add(aControl);
end;

method ClosableTabPage.CreateCloseButtons;
begin
  CloseImage      := GetCloseButton(CloseButtonState.Normal);
  CloseImageHover := GetCloseButton(CloseButtonState.Hover);
  CloseImagePress := GetCloseButton(CloseButtonState.Press);
end;

method ClosableTabPage.GetCloseButton(aType: CloseButtonState): Image;
begin
  var bitmap := new Bitmap(16, 16);
  bitmap.MakeTransparent;
  using graphic := Graphics.FromImage(bitmap) do
    using graphPath := new GraphicsPath do
      begin
        if aType = CloseButtonState.Hover then
          graphic.Clear(Color.Firebrick)
        else if aType = CloseButtonState.Press then
          graphic.Clear(Color.DarkRed);
        var xPoints: array of Point :=
          [new Point(4, 4), new Point(6, 4), new Point(8, 6), new Point(10, 4), new Point(12, 4), new Point(9, 7),
           new Point(9, 8), new Point(12, 11), new Point(10, 11), new Point(8, 9), new Point(6, 11), new Point(4, 11),
           new Point(7, 8), new Point(7, 7)];
        var xColor :=
          case aType of
            CloseButtonState.Hover: Color.LightGray;
            CloseButtonState.Press: Color.Gray;
            else Color.Black;
          end;
        graphPath.AddPolygon(xPoints);
        using pen := new Pen(xColor) do
          begin
            graphic.DrawPolygon(pen, graphPath.PathPoints);
            using brush := new SolidBrush(xColor) do
              graphic.FillPolygon(brush, graphPath.PathPoints);
          end;
      end;
  result := bitmap;
end;

method ClosableTabPage.SetCloseImage(aImage: Image);
begin
  AllowClose := assigned(aImage);
  fCloseImage := aImage;
end;

method ClosableTabPage.GetIndex: Integer;
begin
  result :=
    if ParentTabControl = nil then -1
    else ParentTabControl.TabPages.IndexOf(self);
end;

method ClosableTabPage.Close;
begin
  if assigned(ParentTabControl) then
    begin
      var selectedIndex := Math.Min(&Index - 1, 0);
      ParentTabControl.SelectedIndex := selectedIndex;
      ParentTabControl.Controls.Remove(self);
      if assigned(TabClosed) then
        TabClosed(self, EventArgs.Empty);
      Dispose(true);
    end;
end;

{$ENDREGION}

end.