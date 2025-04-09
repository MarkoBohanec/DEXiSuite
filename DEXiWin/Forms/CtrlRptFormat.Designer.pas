namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  CtrlRptFormat = public partial class
  {$REGION Windows Control Designer generated fields}
  private
    PanelTitle: System.Windows.Forms.Panel;
    PanelDecimals: System.Windows.Forms.Panel;
    PanelFont: System.Windows.Forms.Panel;
    NumDistrib: System.Windows.Forms.NumericUpDown;
    NumDefDet: System.Windows.Forms.NumericUpDown;
    NumWeights: System.Windows.Forms.NumericUpDown;
    NumFloat: System.Windows.Forms.NumericUpDown;
    LblFloat: System.Windows.Forms.Label;
    GrpDecimals: System.Windows.Forms.GroupBox;
    LblDistributions: System.Windows.Forms.Label;
    LblDefDet: System.Windows.Forms.Label;
    LblWeights: System.Windows.Forms.Label;
    BtnFont: System.Windows.Forms.Button;
    BtnResetFont: System.Windows.Forms.Button;
    LblFont: System.Windows.Forms.Label;
    LblTitle: System.Windows.Forms.Label;
    EditTitle: System.Windows.Forms.TextBox;
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Control Designer generated code}
method CtrlRptFormat.InitializeComponent;
begin
  self.LblTitle := new System.Windows.Forms.Label();
  self.EditTitle := new System.Windows.Forms.TextBox();
  self.BtnFont := new System.Windows.Forms.Button();
  self.BtnResetFont := new System.Windows.Forms.Button();
  self.GrpDecimals := new System.Windows.Forms.GroupBox();
  self.NumDistrib := new System.Windows.Forms.NumericUpDown();
  self.NumDefDet := new System.Windows.Forms.NumericUpDown();
  self.NumWeights := new System.Windows.Forms.NumericUpDown();
  self.NumFloat := new System.Windows.Forms.NumericUpDown();
  self.LblDistributions := new System.Windows.Forms.Label();
  self.LblDefDet := new System.Windows.Forms.Label();
  self.LblWeights := new System.Windows.Forms.Label();
  self.LblFloat := new System.Windows.Forms.Label();
  self.LblFont := new System.Windows.Forms.Label();
  self.PanelTitle := new System.Windows.Forms.Panel();
  self.PanelDecimals := new System.Windows.Forms.Panel();
  self.PanelFont := new System.Windows.Forms.Panel();
  self.GrpDecimals.SuspendLayout();
  (self.NumDistrib as System.ComponentModel.ISupportInitialize).BeginInit();
  (self.NumDefDet as System.ComponentModel.ISupportInitialize).BeginInit();
  (self.NumWeights as System.ComponentModel.ISupportInitialize).BeginInit();
  (self.NumFloat as System.ComponentModel.ISupportInitialize).BeginInit();
  self.PanelTitle.SuspendLayout();
  self.PanelDecimals.SuspendLayout();
  self.PanelFont.SuspendLayout();
  self.SuspendLayout();
  self.LblTitle.AutoSize := true;
  self.LblTitle.Location := new System.Drawing.Point(12, 19);
  self.LblTitle.Name := 'LblTitle';
  self.LblTitle.Size := new System.Drawing.Size(58, 13);
  self.LblTitle.TabIndex := 0;
  self.LblTitle.Text := '&Report title';
  self.EditTitle.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.EditTitle.Location := new System.Drawing.Point(90, 15);
  self.EditTitle.Name := 'EditTitle';
  self.EditTitle.Size := new System.Drawing.Size(312, 20);
  self.EditTitle.TabIndex := 11;
  self.EditTitle.TextChanged += new System.EventHandler(self.EditTitle_TextChanged);
  self.BtnFont.Location := new System.Drawing.Point(15, 17);
  self.BtnFont.Name := 'BtnFont';
  self.BtnFont.Size := new System.Drawing.Size(109, 23);
  self.BtnFont.TabIndex := 31;
  self.BtnFont.Text := 'Set &font';
  self.BtnFont.UseVisualStyleBackColor := true;
  self.BtnFont.Click += new System.EventHandler(self.BtnFont_Click);
  self.BtnResetFont.Location := new System.Drawing.Point(15, 49);
  self.BtnResetFont.Name := 'BtnResetFont';
  self.BtnResetFont.Size := new System.Drawing.Size(109, 23);
  self.BtnResetFont.TabIndex := 32;
  self.BtnResetFont.Text := '&Reset font';
  self.BtnResetFont.UseVisualStyleBackColor := true;
  self.BtnResetFont.Click += new System.EventHandler(self.BtnResetFont_Click);
  self.GrpDecimals.Controls.Add(self.NumDistrib);
  self.GrpDecimals.Controls.Add(self.NumDefDet);
  self.GrpDecimals.Controls.Add(self.NumWeights);
  self.GrpDecimals.Controls.Add(self.NumFloat);
  self.GrpDecimals.Controls.Add(self.LblDistributions);
  self.GrpDecimals.Controls.Add(self.LblDefDet);
  self.GrpDecimals.Controls.Add(self.LblWeights);
  self.GrpDecimals.Controls.Add(self.LblFloat);
  self.GrpDecimals.Dock := System.Windows.Forms.DockStyle.Fill;
  self.GrpDecimals.Location := new System.Drawing.Point(0, 0);
  self.GrpDecimals.Name := 'GrpDecimals';
  self.GrpDecimals.Size := new System.Drawing.Size(409, 137);
  self.GrpDecimals.TabIndex := 20;
  self.GrpDecimals.TabStop := false;
  self.GrpDecimals.Text := 'Decimal places for displaying numbers';
  self.NumDistrib.Location := new System.Drawing.Point(143, 104);
  self.NumDistrib.Maximum := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumDistrib.Minimum := new System.Decimal(array of System.Int32([1, 0, 0, -2147483648]));
  self.NumDistrib.Name := 'NumDistrib';
  self.NumDistrib.Size := new System.Drawing.Size(68, 20);
  self.NumDistrib.TabIndex := 24;
  self.NumDistrib.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.NumDistrib.Value := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumDistrib.ValueChanged += new System.EventHandler(self.NumDistrib_ValueChanged);
  self.NumDefDet.Location := new System.Drawing.Point(143, 78);
  self.NumDefDet.Maximum := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumDefDet.Minimum := new System.Decimal(array of System.Int32([1, 0, 0, -2147483648]));
  self.NumDefDet.Name := 'NumDefDet';
  self.NumDefDet.Size := new System.Drawing.Size(68, 20);
  self.NumDefDet.TabIndex := 23;
  self.NumDefDet.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.NumDefDet.Value := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumDefDet.ValueChanged += new System.EventHandler(self.NumDefDet_ValueChanged);
  self.NumWeights.Location := new System.Drawing.Point(143, 52);
  self.NumWeights.Maximum := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumWeights.Minimum := new System.Decimal(array of System.Int32([1, 0, 0, -2147483648]));
  self.NumWeights.Name := 'NumWeights';
  self.NumWeights.Size := new System.Drawing.Size(68, 20);
  self.NumWeights.TabIndex := 22;
  self.NumWeights.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.NumWeights.Value := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumWeights.ValueChanged += new System.EventHandler(self.NumWeights_ValueChanged);
  self.NumFloat.Location := new System.Drawing.Point(143, 26);
  self.NumFloat.Maximum := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumFloat.Minimum := new System.Decimal(array of System.Int32([1, 0, 0, -2147483648]));
  self.NumFloat.Name := 'NumFloat';
  self.NumFloat.Size := new System.Drawing.Size(68, 20);
  self.NumFloat.TabIndex := 21;
  self.NumFloat.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.NumFloat.Value := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.NumFloat.ValueChanged += new System.EventHandler(self.NumFloat_ValueChanged);
  self.LblDistributions.AutoSize := true;
  self.LblDistributions.Location := new System.Drawing.Point(12, 108);
  self.LblDistributions.Name := 'LblDistributions';
  self.LblDistributions.Size := new System.Drawing.Size(64, 13);
  self.LblDistributions.TabIndex := 3;
  self.LblDistributions.Text := '&Distributions';
  self.LblDefDet.AutoSize := true;
  self.LblDefDet.Location := new System.Drawing.Point(12, 82);
  self.LblDefDet.Name := 'LblDefDet';
  self.LblDefDet.Size := new System.Drawing.Size(93, 13);
  self.LblDefDet.TabIndex := 2;
  self.LblDefDet.Text := 'F&unction definition';
  self.LblWeights.AutoSize := true;
  self.LblWeights.Location := new System.Drawing.Point(12, 56);
  self.LblWeights.Name := 'LblWeights';
  self.LblWeights.Size := new System.Drawing.Size(46, 13);
  self.LblWeights.TabIndex := 1;
  self.LblWeights.Text := '&Weights';
  self.LblFloat.AutoSize := true;
  self.LblFloat.Location := new System.Drawing.Point(12, 30);
  self.LblFloat.Name := 'LblFloat';
  self.LblFloat.Size := new System.Drawing.Size(82, 13);
  self.LblFloat.TabIndex := 0;
  self.LblFloat.Text := 'General &number';
  self.LblFont.AutoSize := true;
  self.LblFont.BackColor := System.Drawing.SystemColors.Window;
  self.LblFont.Location := new System.Drawing.Point(140, 17);
  self.LblFont.Name := 'LblFont';
  self.LblFont.Size := new System.Drawing.Size(68, 13);
  self.LblFont.TabIndex := 14;
  self.LblFont.Text := 'Font preview';
  self.PanelTitle.Controls.Add(self.LblTitle);
  self.PanelTitle.Controls.Add(self.EditTitle);
  self.PanelTitle.Dock := System.Windows.Forms.DockStyle.Top;
  self.PanelTitle.Location := new System.Drawing.Point(0, 0);
  self.PanelTitle.Name := 'PanelTitle';
  self.PanelTitle.Size := new System.Drawing.Size(409, 49);
  self.PanelTitle.TabIndex := 10;
  self.PanelDecimals.Controls.Add(self.GrpDecimals);
  self.PanelDecimals.Dock := System.Windows.Forms.DockStyle.Top;
  self.PanelDecimals.Location := new System.Drawing.Point(0, 49);
  self.PanelDecimals.Name := 'PanelDecimals';
  self.PanelDecimals.Size := new System.Drawing.Size(409, 137);
  self.PanelDecimals.TabIndex := 22;
  self.PanelFont.Controls.Add(self.LblFont);
  self.PanelFont.Controls.Add(self.BtnResetFont);
  self.PanelFont.Controls.Add(self.BtnFont);
  self.PanelFont.Dock := System.Windows.Forms.DockStyle.Top;
  self.PanelFont.Location := new System.Drawing.Point(0, 186);
  self.PanelFont.Name := 'PanelFont';
  self.PanelFont.Size := new System.Drawing.Size(409, 88);
  self.PanelFont.TabIndex := 30;
  self.Controls.Add(self.PanelFont);
  self.Controls.Add(self.PanelDecimals);
  self.Controls.Add(self.PanelTitle);
  self.Name := 'CtrlRptFormat';
  self.Size := new System.Drawing.Size(409, 512);
  self.GrpDecimals.ResumeLayout(false);
  self.GrpDecimals.PerformLayout();
  (self.NumDistrib as System.ComponentModel.ISupportInitialize).EndInit();
  (self.NumDefDet as System.ComponentModel.ISupportInitialize).EndInit();
  (self.NumWeights as System.ComponentModel.ISupportInitialize).EndInit();
  (self.NumFloat as System.ComponentModel.ISupportInitialize).EndInit();
  self.PanelTitle.ResumeLayout(false);
  self.PanelTitle.PerformLayout();
  self.PanelDecimals.ResumeLayout(false);
  self.PanelFont.ResumeLayout(false);
  self.PanelFont.PerformLayout();
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.