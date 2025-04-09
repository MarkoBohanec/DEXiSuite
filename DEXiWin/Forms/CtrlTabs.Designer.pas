namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  CtrlTabs = public partial class
  {$REGION Windows Control Designer generated fields}
  private
    TabCtrl: System.Windows.Forms.TabControl;
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Control Designer generated code}
method CtrlTabs.InitializeComponent;
begin
  self.TabCtrl := new System.Windows.Forms.TabControl();
  self.SuspendLayout();
  self.TabCtrl.AllowDrop := true;
  self.TabCtrl.Dock := System.Windows.Forms.DockStyle.Fill;
  self.TabCtrl.DrawMode := System.Windows.Forms.TabDrawMode.OwnerDrawFixed;
  self.TabCtrl.ItemSize := new System.Drawing.Size(120, 24);
  self.TabCtrl.Location := new System.Drawing.Point(0, 0);
  self.TabCtrl.Name := 'TabCtrl';
  self.TabCtrl.SelectedIndex := 0;
  self.TabCtrl.Size := new System.Drawing.Size(668, 388);
  self.TabCtrl.SizeMode := System.Windows.Forms.TabSizeMode.Fixed;
  self.TabCtrl.TabIndex := 0;
  self.TabCtrl.DrawItem += new System.Windows.Forms.DrawItemEventHandler(self.TabCtrl_DrawItem);
  self.TabCtrl.SelectedIndexChanged += new System.EventHandler(self.TabCtrl_SelectedIndexChanged);
  self.TabCtrl.DragOver += new System.Windows.Forms.DragEventHandler(self.TabCtrl_DragOver);
  self.TabCtrl.QueryContinueDrag += new System.Windows.Forms.QueryContinueDragEventHandler(self.TabCtrl_QueryContinueDrag);
  self.TabCtrl.MouseDown += new System.Windows.Forms.MouseEventHandler(self.TabCtrl_MouseDown);
  self.TabCtrl.MouseLeave += new System.EventHandler(self.TabCtrl_MouseLeave);
  self.TabCtrl.MouseMove += new System.Windows.Forms.MouseEventHandler(self.TabCtrl_MouseMove);
  self.TabCtrl.MouseUp += new System.Windows.Forms.MouseEventHandler(self.TabCtrl_MouseUp);
  self.Controls.Add(self.TabCtrl);
  self.Name := 'CtrlTabs';
  self.Size := new System.Drawing.Size(668, 388);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.