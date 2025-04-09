namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormFunctChart = partial class
  {$REGION Windows Form Designer generated fields}
  private
    FunctViewer: DexiWin.CtrlFormFunctChart;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormFunctChart.InitializeComponent;
begin
  self.components := new System.ComponentModel.Container();
  self.FunctViewer := new DexiWin.CtrlFormFunctChart();
  self.SuspendLayout();
  self.FunctViewer.AutoScroll := true;
  self.FunctViewer.Dock := System.Windows.Forms.DockStyle.Fill;
  self.FunctViewer.Location := new System.Drawing.Point(0, 0);
  self.FunctViewer.Name := 'FunctViewer';
  self.FunctViewer.Size := new System.Drawing.Size(916, 653);
  self.FunctViewer.TabIndex := 0;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(916, 653);
  self.Controls.Add(self.FunctViewer);
  self.Name := 'FormFunctChart';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.Text := 'FormFunctChart';
  self.FormClosing += new System.Windows.Forms.FormClosingEventHandler(self.FormFunctChart_FormClosing);
  self.Shown += new System.EventHandler(self.FormFunctChart_Shown);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.