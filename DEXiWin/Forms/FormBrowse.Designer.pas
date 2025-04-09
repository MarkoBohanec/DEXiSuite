namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormBrowse = partial class
  {$REGION Windows Form Designer generated fields}
  private
    Browser: DexiWin.CtrlFormBrowse;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormBrowse.InitializeComponent;
begin
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(FormBrowse));
  self.Browser := new DexiWin.CtrlFormBrowse();
  self.SuspendLayout();
  self.Browser.Dock := System.Windows.Forms.DockStyle.Fill;
  self.Browser.FileName := nil;
  self.Browser.FormMode := false;
  self.Browser.Html := '';
  self.Browser.Location := new System.Drawing.Point(0, 0);
  self.Browser.ManagerForm := nil;
  self.Browser.Name := 'Browser';
  self.Browser.ParamForm := nil;
  self.Browser.Report := nil;
  self.Browser.Size := new System.Drawing.Size(804, 585);
  self.Browser.TabIndex := 0;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(804, 585);
  self.Controls.Add(self.Browser);
  self.Icon := (resources.GetObject('$this.Icon') as System.Drawing.Icon);
  self.Name := 'FormBrowse';
  self.ShowInTaskbar := false;
  self.Text := 'FormBrowse';
  self.FormClosing += new System.Windows.Forms.FormClosingEventHandler(self.FormBrowse_FormClosing);
  self.Shown += new System.EventHandler(self.FormBrowse_Shown);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.