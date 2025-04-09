namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormTree = partial class
  {$REGION Windows Form Designer generated fields}
  private
    TreeViewer: DexiWin.CtrlFormTree;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormTree.InitializeComponent;
begin
  self.components := new System.ComponentModel.Container();
  self.TreeViewer := new DexiWin.CtrlFormTree();
  self.SuspendLayout();
  self.TreeViewer.AutoScroll := true;
  self.TreeViewer.Dock := System.Windows.Forms.DockStyle.Fill;
  self.TreeViewer.Location := new System.Drawing.Point(0, 0);
  self.TreeViewer.Model := nil;
  self.TreeViewer.Name := 'TreeViewer';
  self.TreeViewer.Size := new System.Drawing.Size(775, 644);
  self.TreeViewer.TabIndex := 1;
  self.TreeViewer.Zoom := 0.0;
  self.TreeViewer.ZoomMode := DexiWin.PreviewZoomMode.ActualSize;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(775, 644);
  self.Controls.Add(self.TreeViewer);
  self.Name := 'FormTree';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.Text := 'FormTree';
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.
