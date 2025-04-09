namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormModel = partial class
  {$REGION Windows Form Designer generated fields}
  private
    ExportModelDialog: System.Windows.Forms.SaveFileDialog;
    ImportFncDialog: System.Windows.Forms.OpenFileDialog;
    ExportFncDialog: System.Windows.Forms.SaveFileDialog;
    ImportAltDialog: System.Windows.Forms.OpenFileDialog;
    ExportAltDialog: System.Windows.Forms.SaveFileDialog;
    ExportTreeDialog: System.Windows.Forms.SaveFileDialog;
    FileSaveAsDialog: System.Windows.Forms.SaveFileDialog;
    StatusBarText: System.Windows.Forms.ToolStripStatusLabel;
    StatusBar: System.Windows.Forms.StatusStrip;
    ModelTabs: DexiWin.CtrlTabs;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormModel.InitializeComponent;
begin
  self.StatusBar := new System.Windows.Forms.StatusStrip();
  self.StatusBarText := new System.Windows.Forms.ToolStripStatusLabel();
  self.FileSaveAsDialog := new System.Windows.Forms.SaveFileDialog();
  self.ExportTreeDialog := new System.Windows.Forms.SaveFileDialog();
  self.ExportAltDialog := new System.Windows.Forms.SaveFileDialog();
  self.ImportAltDialog := new System.Windows.Forms.OpenFileDialog();
  self.ExportFncDialog := new System.Windows.Forms.SaveFileDialog();
  self.ImportFncDialog := new System.Windows.Forms.OpenFileDialog();
  self.ExportModelDialog := new System.Windows.Forms.SaveFileDialog();
  self.ModelTabs := new DexiWin.CtrlTabs();
  self.StatusBar.SuspendLayout();
  self.SuspendLayout();
  self.StatusBar.Items.AddRange(array of System.Windows.Forms.ToolStripItem([self.StatusBarText]));
  self.StatusBar.LayoutStyle := System.Windows.Forms.ToolStripLayoutStyle.Flow;
  self.StatusBar.Location := new System.Drawing.Point(0, 352);
  self.StatusBar.Name := 'StatusBar';
  self.StatusBar.Size := new System.Drawing.Size(723, 20);
  self.StatusBar.TabIndex := 1;
  self.StatusBar.Text := 'StatusBar';
  self.StatusBarText.Name := 'StatusBarText';
  self.StatusBarText.Size := new System.Drawing.Size(77, 15);
  self.StatusBarText.Text := 'StatusBarText';
  self.FileSaveAsDialog.DefaultExt := 'dxi';
  self.FileSaveAsDialog.Filter := 'DEXi Model|*.dxi';
  self.FileSaveAsDialog.Title := 'Save model';
  self.ExportTreeDialog.Filter := 'GML|*.gml|Tab-Delimited|*.tab';
  self.ExportTreeDialog.Title := 'Export tree';
  self.ExportAltDialog.Filter := 'Tab-delimited|*.tab|Comma-separated (CSV)|*.csv|Json (alternatives only, contents according to Settings/Json)|*.json';
  self.ExportAltDialog.Title := 'Export alternatives';
  self.ImportAltDialog.DefaultExt := 'dat';
  self.ImportAltDialog.Filter := 'Tab-delimited|*.*|Comma-separated (CSV)|*.csv|Json|*.json';
  self.ImportAltDialog.Title := 'Import alternatives';
  self.ExportFncDialog.DefaultExt := 'dat';
  self.ExportFncDialog.Filter := 'Tab-delimited|*.*';
  self.ExportFncDialog.Title := 'Export function';
  self.ImportFncDialog.DefaultExt := 'dat';
  self.ImportFncDialog.Filter := 'Tab-delimited|*.*';
  self.ImportFncDialog.Title := 'Import function';
  self.ExportModelDialog.DefaultExt := 'json';
  self.ExportModelDialog.Filter := 'Json (contents according to Settings/Json)|*.json|Json (model without alternatives)|*.json';
  self.ExportModelDialog.Title := 'Export model';
  self.ModelTabs.Dock := System.Windows.Forms.DockStyle.Fill;
  self.ModelTabs.Location := new System.Drawing.Point(0, 0);
  self.ModelTabs.MinimumHorizontalDragDistance := 5;
  self.ModelTabs.MinimumVerticalDragDistance := 5;
  self.ModelTabs.Name := 'ModelTabs';
  self.ModelTabs.Size := new System.Drawing.Size(723, 372);
  self.ModelTabs.TabIndex := 0;
  self.ModelTabs.TabPages := new System.Windows.Forms.TabPage[0];
  self.ModelTabs.Load += new System.EventHandler(self.ModelTabs_Load);
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(723, 372);
  self.Controls.Add(self.StatusBar);
  self.Controls.Add(self.ModelTabs);
  self.KeyPreview := true;
  self.Name := 'FormModel';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.Text := 'FormModel';
  self.WindowState := System.Windows.Forms.FormWindowState.Minimized;
  self.FormClosing += new System.Windows.Forms.FormClosingEventHandler(self.FormModel_FormClosing);
  self.FormClosed += new System.Windows.Forms.FormClosedEventHandler(self.FormModel_FormClosed);
  self.KeyDown += new System.Windows.Forms.KeyEventHandler(self.FormModel_KeyDown);
  self.StatusBar.ResumeLayout(false);
  self.StatusBar.PerformLayout();
  self.ResumeLayout(false);
  self.PerformLayout();
end;

{$ENDREGION}

end.