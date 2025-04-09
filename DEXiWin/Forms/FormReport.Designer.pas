namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormReport = partial class
  {$REGION Windows Form Designer generated fields}
  private
    Reporter: DexiWin.CtrlFormReport;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormReport.InitializeComponent;
begin
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(FormReport));
  self.Reporter := new DexiWin.CtrlFormReport();
  self.SuspendLayout();
  self.Reporter.Dock := System.Windows.Forms.DockStyle.Fill;
  self.Reporter.FormMode := false;
  self.Reporter.Location := new System.Drawing.Point(0, 0);
  self.Reporter.ManagerForm := nil;
  self.Reporter.Name := 'Reporter';
  self.Reporter.OnRemake := nil;
  self.Reporter.ParamForm := nil;
  self.Reporter.Report := nil;
  self.Reporter.Size := new System.Drawing.Size(894, 600);
  self.Reporter.StartPage := 0;
  self.Reporter.TabIndex := 0;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(894, 600);
  self.Controls.Add(self.Reporter);
  self.Icon := (resources.GetObject('$this.Icon') as System.Drawing.Icon);
  self.Name := 'FormReport';
  self.ShowInTaskbar := false;
  self.Text := 'FormReport';
  self.WindowState := System.Windows.Forms.FormWindowState.Maximized;
  self.FormClosing += new System.Windows.Forms.FormClosingEventHandler(self.FormReport_FormClosing);
  self.FormClosed += new System.Windows.Forms.FormClosedEventHandler(self.FormReport_FormClosed);
  self.Shown += new System.EventHandler(self.FormReport_Shown);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.