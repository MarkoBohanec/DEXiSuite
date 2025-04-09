namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormScaleSelect = partial class
  {$REGION Windows Form Designer generated fields}
  private
    ChkPredefined: System.Windows.Forms.CheckBox;
    ColScale: BrightIdeasSoftware.OLVColumn;
    ColName: BrightIdeasSoftware.OLVColumn;
    ChkDefault: System.Windows.Forms.CheckBox;
    ViewScales: BrightIdeasSoftware.ObjectListView;
    LblAvailable: System.Windows.Forms.Label;
    LblSelectedScale: System.Windows.Forms.Label;
    LblCurrentScale: System.Windows.Forms.Label;
    ScaleText: System.Windows.Forms.RichTextBox;
    BtnCancel: System.Windows.Forms.Button;
    BtnOK: System.Windows.Forms.Button;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormScaleSelect.InitializeComponent;
begin
  self.BtnCancel := new System.Windows.Forms.Button();
  self.BtnOK := new System.Windows.Forms.Button();
  self.LblCurrentScale := new System.Windows.Forms.Label();
  self.ScaleText := new System.Windows.Forms.RichTextBox();
  self.LblSelectedScale := new System.Windows.Forms.Label();
  self.LblAvailable := new System.Windows.Forms.Label();
  self.ViewScales := new BrightIdeasSoftware.ObjectListView();
  self.ColName := (new BrightIdeasSoftware.OLVColumn() as BrightIdeasSoftware.OLVColumn);
  self.ColScale := (new BrightIdeasSoftware.OLVColumn() as BrightIdeasSoftware.OLVColumn);
  self.ChkDefault := new System.Windows.Forms.CheckBox();
  self.ChkPredefined := new System.Windows.Forms.CheckBox();
  (self.ViewScales as System.ComponentModel.ISupportInitialize).BeginInit();
  self.SuspendLayout();
  self.BtnCancel.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(94, 399);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 101;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.BtnOK.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(12, 399);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 100;
  self.BtnOK.Text := '&OK';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.LblCurrentScale.AutoSize := true;
  self.LblCurrentScale.Location := new System.Drawing.Point(10, 14);
  self.LblCurrentScale.Name := 'LblCurrentScale';
  self.LblCurrentScale.Size := new System.Drawing.Size(69, 13);
  self.LblCurrentScale.TabIndex := 1;
  self.LblCurrentScale.Text := 'Current scale';
  self.ScaleText.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.ScaleText.BackColor := System.Drawing.SystemColors.Window;
  self.ScaleText.BorderStyle := System.Windows.Forms.BorderStyle.FixedSingle;
  self.ScaleText.Location := new System.Drawing.Point(12, 32);
  self.ScaleText.Multiline := false;
  self.ScaleText.Name := 'ScaleText';
  self.ScaleText.ReadOnly := true;
  self.ScaleText.Size := new System.Drawing.Size(780, 20);
  self.ScaleText.TabIndex := 3;
  self.ScaleText.TabStop := false;
  self.ScaleText.Text := '';
  self.ScaleText.WordWrap := false;
  self.LblSelectedScale.AutoSize := true;
  self.LblSelectedScale.Location := new System.Drawing.Point(192, 14);
  self.LblSelectedScale.Name := 'LblSelectedScale';
  self.LblSelectedScale.Size := new System.Drawing.Size(77, 13);
  self.LblSelectedScale.TabIndex := 2;
  self.LblSelectedScale.Text := 'Selected scale';
  self.LblSelectedScale.Visible := false;
  self.LblAvailable.AutoSize := true;
  self.LblAvailable.Location := new System.Drawing.Point(10, 92);
  self.LblAvailable.Name := 'LblAvailable';
  self.LblAvailable.Size := new System.Drawing.Size(83, 13);
  self.LblAvailable.TabIndex := 5;
  self.LblAvailable.Text := '&Available scales';
  self.ViewScales.AllColumns.Add(self.ColName);
  self.ViewScales.AllColumns.Add(self.ColScale);
  self.ViewScales.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.ViewScales.CellEditUseWholeCell := false;
  self.ViewScales.Columns.AddRange(array of System.Windows.Forms.ColumnHeader([self.ColName, self.ColScale]));
  self.ViewScales.Cursor := System.Windows.Forms.Cursors.Default;
  self.ViewScales.HideSelection := false;
  self.ViewScales.Location := new System.Drawing.Point(12, 110);
  self.ViewScales.MultiSelect := false;
  self.ViewScales.Name := 'ViewScales';
  self.ViewScales.SelectAllOnControlA := false;
  self.ViewScales.SelectColumnsMenuStaysOpen := false;
  self.ViewScales.SelectColumnsOnRightClick := false;
  self.ViewScales.SelectColumnsOnRightClickBehaviour := BrightIdeasSoftware.ObjectListView.ColumnSelectBehaviour.None;
  self.ViewScales.SelectedBackColor := System.Drawing.Color.FromArgb(((192 as System.Byte) as System.Int32), ((255 as System.Byte) as System.Int32), ((255 as System.Byte) as System.Int32));
  self.ViewScales.Size := new System.Drawing.Size(780, 273);
  self.ViewScales.TabIndex := 6;
  self.ViewScales.UseCompatibleStateImageBehavior := false;
  self.ViewScales.View := System.Windows.Forms.View.Details;
  self.ViewScales.SelectedIndexChanged += new System.EventHandler(self.ViewScales_SelectedIndexChanged);
  self.ColName.AspectName := '';
  self.ColName.Groupable := false;
  self.ColName.Hideable := false;
  self.ColName.IsEditable := false;
  self.ColName.MinimumWidth := 100;
  self.ColName.Searchable := false;
  self.ColName.Sortable := false;
  self.ColName.Text := 'Name/Status';
  self.ColName.Width := 200;
  self.ColScale.AspectName := 'ScaleComposite';
  self.ColScale.Groupable := false;
  self.ColScale.Hideable := false;
  self.ColScale.IsEditable := false;
  self.ColScale.MinimumWidth := 100;
  self.ColScale.Searchable := false;
  self.ColScale.Sortable := false;
  self.ColScale.Text := 'Scale';
  self.ColScale.Width := 400;
  self.ChkDefault.AutoSize := true;
  self.ChkDefault.Location := new System.Drawing.Point(12, 58);
  self.ChkDefault.Name := 'ChkDefault';
  self.ChkDefault.Size := new System.Drawing.Size(172, 17);
  self.ChkDefault.TabIndex := 4;
  self.ChkDefault.Text := '&Default scale for new attributes';
  self.ChkDefault.UseVisualStyleBackColor := true;
  self.ChkDefault.CheckedChanged += new System.EventHandler(self.ChkDefault_CheckedChanged);
  self.ChkPredefined.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.ChkPredefined.AutoSize := true;
  self.ChkPredefined.Location := new System.Drawing.Point(653, 58);
  self.ChkPredefined.Name := 'ChkPredefined';
  self.ChkPredefined.Size := new System.Drawing.Size(139, 17);
  self.ChkPredefined.TabIndex := 102;
  self.ChkPredefined.Text := '&Show predefined scales';
  self.ChkPredefined.UseVisualStyleBackColor := true;
  self.ChkPredefined.CheckedChanged += new System.EventHandler(self.ChkPredefined_CheckedChanged);
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(803, 438);
  self.Controls.Add(self.ChkPredefined);
  self.Controls.Add(self.ChkDefault);
  self.Controls.Add(self.ViewScales);
  self.Controls.Add(self.LblAvailable);
  self.Controls.Add(self.LblSelectedScale);
  self.Controls.Add(self.LblCurrentScale);
  self.Controls.Add(self.ScaleText);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.Name := 'FormScaleSelect';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'Select scale of "{0}"';
  (self.ViewScales as System.ComponentModel.ISupportInitialize).EndInit();
  self.ResumeLayout(false);
  self.PerformLayout();
end;

{$ENDREGION}

end.