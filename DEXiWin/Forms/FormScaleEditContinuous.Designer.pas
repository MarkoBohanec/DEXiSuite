namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormScaleEditContinuous = partial class
  {$REGION Windows Form Designer generated fields}
  private
    EditDecimals: System.Windows.Forms.NumericUpDown;
    LblDecimals: System.Windows.Forms.Label;
    PanelHigh: System.Windows.Forms.Panel;
    LabelHighBG: System.Windows.Forms.Label;
    LabelLowBG: System.Windows.Forms.Label;
    PanelUnordered: System.Windows.Forms.Panel;
    PanelNeutral: System.Windows.Forms.Panel;
    PanelLow: System.Windows.Forms.Panel;
    TextHP: System.Windows.Forms.TextBox;
    TextLP: System.Windows.Forms.TextBox;
    LblUpBound: System.Windows.Forms.Label;
    LblLowBound: System.Windows.Forms.Label;
    GrpBounds: System.Windows.Forms.GroupBox;
    LblUnit: System.Windows.Forms.Label;
    TextUnit: System.Windows.Forms.TextBox;
    FormTool: System.Windows.Forms.ToolStrip;
    ItemToolScaleDescr: System.Windows.Forms.ToolStripButton;
    toolStripSeparator5: System.Windows.Forms.ToolStripSeparator;
    ItemToolOrder: System.Windows.Forms.ToolStripComboBox;
    toolStripSeparator1: System.Windows.Forms.ToolStripSeparator;
    BtnCancel: System.Windows.Forms.Button;
    BtnOK: System.Windows.Forms.Button;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormScaleEditContinuous.InitializeComponent;
begin
  self.BtnCancel := new System.Windows.Forms.Button();
  self.BtnOK := new System.Windows.Forms.Button();
  self.FormTool := new System.Windows.Forms.ToolStrip();
  self.ItemToolScaleDescr := new System.Windows.Forms.ToolStripButton();
  self.toolStripSeparator5 := new System.Windows.Forms.ToolStripSeparator();
  self.ItemToolOrder := new System.Windows.Forms.ToolStripComboBox();
  self.toolStripSeparator1 := new System.Windows.Forms.ToolStripSeparator();
  self.LblUnit := new System.Windows.Forms.Label();
  self.TextUnit := new System.Windows.Forms.TextBox();
  self.GrpBounds := new System.Windows.Forms.GroupBox();
  self.LabelHighBG := new System.Windows.Forms.Label();
  self.LabelLowBG := new System.Windows.Forms.Label();
  self.PanelUnordered := new System.Windows.Forms.Panel();
  self.PanelHigh := new System.Windows.Forms.Panel();
  self.PanelNeutral := new System.Windows.Forms.Panel();
  self.PanelLow := new System.Windows.Forms.Panel();
  self.TextHP := new System.Windows.Forms.TextBox();
  self.TextLP := new System.Windows.Forms.TextBox();
  self.LblUpBound := new System.Windows.Forms.Label();
  self.LblLowBound := new System.Windows.Forms.Label();
  self.EditDecimals := new System.Windows.Forms.NumericUpDown();
  self.LblDecimals := new System.Windows.Forms.Label();
  self.FormTool.SuspendLayout();
  self.GrpBounds.SuspendLayout();
  (self.EditDecimals as System.ComponentModel.ISupportInitialize).BeginInit();
  self.SuspendLayout();
  self.BtnCancel.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(91, 235);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 9;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.BtnOK.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(9, 235);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 8;
  self.BtnOK.Text := '&OK';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.FormTool.BackColor := System.Drawing.SystemColors.Control;
  self.FormTool.Items.AddRange(array of System.Windows.Forms.ToolStripItem([self.ItemToolScaleDescr, self.toolStripSeparator5, self.ItemToolOrder, self.toolStripSeparator1]));
  self.FormTool.Location := new System.Drawing.Point(0, 0);
  self.FormTool.Name := 'FormTool';
  self.FormTool.Size := new System.Drawing.Size(626, 25);
  self.FormTool.TabIndex := 13;
  self.FormTool.Text := 'toolStrip1';
  self.ItemToolScaleDescr.DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Image;
  self.ItemToolScaleDescr.Image := DEXiWin.Properties.Resources.ImgScaleDescr;
  self.ItemToolScaleDescr.ImageTransparentColor := System.Drawing.Color.Magenta;
  self.ItemToolScaleDescr.Name := 'ItemToolScaleDescr';
  self.ItemToolScaleDescr.Size := new System.Drawing.Size(23, 22);
  self.ItemToolScaleDescr.Text := 'Scale description...';
  self.ItemToolScaleDescr.ToolTipText := 'Edit scale name and description';
  self.ItemToolScaleDescr.Click += new System.EventHandler(self.ItemToolScaleDescr_Click);
  self.toolStripSeparator5.Name := 'toolStripSeparator5';
  self.toolStripSeparator5.Size := new System.Drawing.Size(6, 25);
  self.ItemToolOrder.DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList;
  self.ItemToolOrder.Items.AddRange(array of System.Object(['ascending', 'descending', 'unordered']));
  self.ItemToolOrder.Name := 'ItemToolOrder';
  self.ItemToolOrder.Size := new System.Drawing.Size(121, 25);
  self.ItemToolOrder.ToolTipText := 'Scale order';
  self.ItemToolOrder.SelectedIndexChanged += new System.EventHandler(self.ItemToolOrder_SelectedIndexChanged);
  self.toolStripSeparator1.Name := 'toolStripSeparator1';
  self.toolStripSeparator1.Size := new System.Drawing.Size(6, 25);
  self.LblUnit.AutoSize := true;
  self.LblUnit.Location := new System.Drawing.Point(9, 158);
  self.LblUnit.Name := 'LblUnit';
  self.LblUnit.Size := new System.Drawing.Size(57, 13);
  self.LblUnit.TabIndex := 6;
  self.LblUnit.Text := 'Scale &unit:';
  self.TextUnit.Location := new System.Drawing.Point(12, 174);
  self.TextUnit.Name := 'TextUnit';
  self.TextUnit.Size := new System.Drawing.Size(166, 20);
  self.TextUnit.TabIndex := 7;
  self.TextUnit.TextChanged += new System.EventHandler(self.TextUnit_TextChanged);
  self.GrpBounds.Controls.Add(self.LabelHighBG);
  self.GrpBounds.Controls.Add(self.LabelLowBG);
  self.GrpBounds.Controls.Add(self.PanelUnordered);
  self.GrpBounds.Controls.Add(self.PanelHigh);
  self.GrpBounds.Controls.Add(self.PanelNeutral);
  self.GrpBounds.Controls.Add(self.PanelLow);
  self.GrpBounds.Controls.Add(self.TextHP);
  self.GrpBounds.Controls.Add(self.TextLP);
  self.GrpBounds.Controls.Add(self.LblUpBound);
  self.GrpBounds.Controls.Add(self.LblLowBound);
  self.GrpBounds.Location := new System.Drawing.Point(12, 38);
  self.GrpBounds.Name := 'GrpBounds';
  self.GrpBounds.Size := new System.Drawing.Size(578, 101);
  self.GrpBounds.TabIndex := 1;
  self.GrpBounds.TabStop := false;
  self.GrpBounds.Text := 'Scale &bounds';
  self.LabelHighBG.AutoSize := true;
  self.LabelHighBG.Location := new System.Drawing.Point(338, 28);
  self.LabelHighBG.Name := 'LabelHighBG';
  self.LabelHighBG.Size := new System.Drawing.Size(44, 13);
  self.LabelHighBG.TabIndex := 4;
  self.LabelHighBG.Text := 'HighBG';
  self.LabelLowBG.AutoSize := true;
  self.LabelLowBG.Location := new System.Drawing.Point(158, 28);
  self.LabelLowBG.Name := 'LabelLowBG';
  self.LabelLowBG.Size := new System.Drawing.Size(42, 13);
  self.LabelLowBG.TabIndex := 2;
  self.LabelLowBG.Text := 'LowBG';
  self.PanelUnordered.BackColor := System.Drawing.SystemColors.ControlDark;
  self.PanelUnordered.Location := new System.Drawing.Point(64, 68);
  self.PanelUnordered.Name := 'PanelUnordered';
  self.PanelUnordered.Size := new System.Drawing.Size(451, 10);
  self.PanelUnordered.TabIndex := 7;
  self.PanelHigh.Location := new System.Drawing.Point(424, 52);
  self.PanelHigh.Name := 'PanelHigh';
  self.PanelHigh.Size := new System.Drawing.Size(90, 10);
  self.PanelHigh.TabIndex := 6;
  self.PanelNeutral.BackColor := System.Drawing.SystemColors.ControlDark;
  self.PanelNeutral.Location := new System.Drawing.Point(243, 52);
  self.PanelNeutral.Name := 'PanelNeutral';
  self.PanelNeutral.Size := new System.Drawing.Size(90, 10);
  self.PanelNeutral.TabIndex := 5;
  self.PanelLow.Location := new System.Drawing.Point(64, 52);
  self.PanelLow.Name := 'PanelLow';
  self.PanelLow.Size := new System.Drawing.Size(90, 10);
  self.PanelLow.TabIndex := 4;
  self.TextHP.Location := new System.Drawing.Point(338, 47);
  self.TextHP.Name := 'TextHP';
  self.TextHP.Size := new System.Drawing.Size(80, 20);
  self.TextHP.TabIndex := 5;
  self.TextHP.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.TextHP.Validating += new System.ComponentModel.CancelEventHandler(self.TextHP_Validating);
  self.TextHP.Validated += new System.EventHandler(self.TextHP_Validated);
  self.TextLP.Location := new System.Drawing.Point(158, 47);
  self.TextLP.Name := 'TextLP';
  self.TextLP.Size := new System.Drawing.Size(80, 20);
  self.TextLP.TabIndex := 3;
  self.TextLP.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.TextLP.Validating += new System.ComponentModel.CancelEventHandler(self.TextLP_Validating);
  self.TextLP.Validated += new System.EventHandler(self.TextLP_Validated);
  self.LblUpBound.AutoSize := true;
  self.LblUpBound.Location := new System.Drawing.Point(518, 50);
  self.LblUpBound.Name := 'LblUpBound';
  self.LblUpBound.Size := new System.Drawing.Size(43, 13);
  self.LblUpBound.TabIndex := 1;
  self.LblUpBound.Text := 'Infinity ]';
  self.LblLowBound.AutoSize := true;
  self.LblLowBound.Location := new System.Drawing.Point(12, 50);
  self.LblLowBound.Name := 'LblLowBound';
  self.LblLowBound.Size := new System.Drawing.Size(46, 13);
  self.LblLowBound.TabIndex := 0;
  self.LblLowBound.Text := '[ -Infinity';
  self.EditDecimals.Location := new System.Drawing.Point(196, 174);
  self.EditDecimals.Maximum := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.EditDecimals.Minimum := new System.Decimal(array of System.Int32([1, 0, 0, -2147483648]));
  self.EditDecimals.Name := 'EditDecimals';
  self.EditDecimals.Size := new System.Drawing.Size(68, 20);
  self.EditDecimals.TabIndex := 52;
  self.EditDecimals.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.EditDecimals.Value := new System.Decimal(array of System.Int32([10, 0, 0, 0]));
  self.EditDecimals.ValueChanged += new System.EventHandler(self.EditDecimals_ValueChanged);
  self.LblDecimals.AutoSize := true;
  self.LblDecimals.Location := new System.Drawing.Point(193, 158);
  self.LblDecimals.Name := 'LblDecimals';
  self.LblDecimals.Size := new System.Drawing.Size(88, 13);
  self.LblDecimals.TabIndex := 53;
  self.LblDecimals.Text := 'Display &decimals:';
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(626, 270);
  self.Controls.Add(self.LblDecimals);
  self.Controls.Add(self.EditDecimals);
  self.Controls.Add(self.GrpBounds);
  self.Controls.Add(self.TextUnit);
  self.Controls.Add(self.LblUnit);
  self.Controls.Add(self.FormTool);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.Name := 'FormScaleEditContinuous';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'Edit scale of "{0}"';
  self.FormTool.ResumeLayout(false);
  self.FormTool.PerformLayout();
  self.GrpBounds.ResumeLayout(false);
  self.GrpBounds.PerformLayout();
  (self.EditDecimals as System.ComponentModel.ISupportInitialize).EndInit();
  self.ResumeLayout(false);
  self.PerformLayout();
end;

{$ENDREGION}

end.