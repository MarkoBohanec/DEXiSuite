namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormSearch = partial class
  {$REGION Windows Form Designer generated fields}
  private
    BtnCancel: System.Windows.Forms.Button;
    BtnOK: System.Windows.Forms.Button;
    ChkScale: System.Windows.Forms.CheckBox;
    ChkDescr: System.Windows.Forms.CheckBox;
    GrpHow: System.Windows.Forms.GroupBox;
    ChkMatchCase: System.Windows.Forms.CheckBox;
    GrpWhere: System.Windows.Forms.GroupBox;
    ChkName: System.Windows.Forms.CheckBox;
    TextSearch: System.Windows.Forms.TextBox;
    LblSearch: System.Windows.Forms.Label;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormSearch.InitializeComponent;
begin
  self.LblSearch := new System.Windows.Forms.Label();
  self.TextSearch := new System.Windows.Forms.TextBox();
  self.GrpWhere := new System.Windows.Forms.GroupBox();
  self.ChkScale := new System.Windows.Forms.CheckBox();
  self.ChkDescr := new System.Windows.Forms.CheckBox();
  self.ChkName := new System.Windows.Forms.CheckBox();
  self.GrpHow := new System.Windows.Forms.GroupBox();
  self.ChkMatchCase := new System.Windows.Forms.CheckBox();
  self.BtnCancel := new System.Windows.Forms.Button();
  self.BtnOK := new System.Windows.Forms.Button();
  self.GrpWhere.SuspendLayout();
  self.GrpHow.SuspendLayout();
  self.SuspendLayout();
  self.LblSearch.AutoSize := true;
  self.LblSearch.Location := new System.Drawing.Point(16, 10);
  self.LblSearch.Name := 'LblSearch';
  self.LblSearch.Size := new System.Drawing.Size(41, 13);
  self.LblSearch.TabIndex := 0;
  self.LblSearch.Text := '&Search';
  self.TextSearch.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.TextSearch.Location := new System.Drawing.Point(16, 32);
  self.TextSearch.Name := 'TextSearch';
  self.TextSearch.Size := new System.Drawing.Size(256, 20);
  self.TextSearch.TabIndex := 1;
  self.GrpWhere.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.GrpWhere.Controls.Add(self.ChkScale);
  self.GrpWhere.Controls.Add(self.ChkDescr);
  self.GrpWhere.Controls.Add(self.ChkName);
  self.GrpWhere.Location := new System.Drawing.Point(16, 66);
  self.GrpWhere.Name := 'GrpWhere';
  self.GrpWhere.Size := new System.Drawing.Size(256, 95);
  self.GrpWhere.TabIndex := 2;
  self.GrpWhere.TabStop := false;
  self.GrpWhere.Text := 'Where?';
  self.ChkScale.AutoSize := true;
  self.ChkScale.Location := new System.Drawing.Point(14, 70);
  self.ChkScale.Name := 'ChkScale';
  self.ChkScale.Size := new System.Drawing.Size(53, 17);
  self.ChkScale.TabIndex := 2;
  self.ChkScale.Text := '&Scale';
  self.ChkScale.UseVisualStyleBackColor := true;
  self.ChkScale.CheckedChanged += new System.EventHandler(self.ChkName_CheckStateChanged);
  self.ChkDescr.AutoSize := true;
  self.ChkDescr.Location := new System.Drawing.Point(14, 48);
  self.ChkDescr.Name := 'ChkDescr';
  self.ChkDescr.Size := new System.Drawing.Size(119, 17);
  self.ChkDescr.TabIndex := 1;
  self.ChkDescr.Text := 'Attribute &description';
  self.ChkDescr.UseVisualStyleBackColor := true;
  self.ChkDescr.CheckedChanged += new System.EventHandler(self.ChkName_CheckStateChanged);
  self.ChkName.AutoSize := true;
  self.ChkName.Checked := true;
  self.ChkName.CheckState := System.Windows.Forms.CheckState.Checked;
  self.ChkName.Location := new System.Drawing.Point(14, 24);
  self.ChkName.Name := 'ChkName';
  self.ChkName.Size := new System.Drawing.Size(94, 17);
  self.ChkName.TabIndex := 0;
  self.ChkName.Text := 'Attribute &name';
  self.ChkName.UseVisualStyleBackColor := true;
  self.ChkName.CheckedChanged += new System.EventHandler(self.ChkName_CheckStateChanged);
  self.GrpHow.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.GrpHow.Controls.Add(self.ChkMatchCase);
  self.GrpHow.Location := new System.Drawing.Point(16, 176);
  self.GrpHow.Name := 'GrpHow';
  self.GrpHow.Size := new System.Drawing.Size(256, 54);
  self.GrpHow.TabIndex := 3;
  self.GrpHow.TabStop := false;
  self.GrpHow.Text := 'How?';
  self.ChkMatchCase.AutoSize := true;
  self.ChkMatchCase.Location := new System.Drawing.Point(14, 24);
  self.ChkMatchCase.Name := 'ChkMatchCase';
  self.ChkMatchCase.Size := new System.Drawing.Size(82, 17);
  self.ChkMatchCase.TabIndex := 0;
  self.ChkMatchCase.Text := 'Match &case';
  self.ChkMatchCase.UseVisualStyleBackColor := true;
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(101, 248);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 5;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(16, 248);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 4;
  self.BtnOK.Text := '&Find';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(288, 291);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.Controls.Add(self.GrpHow);
  self.Controls.Add(self.GrpWhere);
  self.Controls.Add(self.TextSearch);
  self.Controls.Add(self.LblSearch);
  self.Name := 'FormSearch';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'FormSearch';
  self.Activated += new System.EventHandler(self.FormSearch_Activated);
  self.Load += new System.EventHandler(self.FormSearch_Load);
  self.GrpWhere.ResumeLayout(false);
  self.GrpWhere.PerformLayout();
  self.GrpHow.ResumeLayout(false);
  self.GrpHow.PerformLayout();
  self.ResumeLayout(false);
  self.PerformLayout();
end;

{$ENDREGION}

end.