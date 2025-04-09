namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormBoundEdit = partial class
  {$REGION Windows Form Designer generated fields}
  private
    GrpAssoc: System.Windows.Forms.GroupBox;
    RBtnHigher: System.Windows.Forms.RadioButton;
    RBtnLower: System.Windows.Forms.RadioButton;
    BtnCancel: System.Windows.Forms.Button;
    BtnOK: System.Windows.Forms.Button;
    EditBound: System.Windows.Forms.TextBox;
    LblBound: System.Windows.Forms.Label;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormBoundEdit.InitializeComponent;
begin
  self.LblBound := new System.Windows.Forms.Label();
  self.BtnCancel := new System.Windows.Forms.Button();
  self.BtnOK := new System.Windows.Forms.Button();
  self.EditBound := new System.Windows.Forms.TextBox();
  self.GrpAssoc := new System.Windows.Forms.GroupBox();
  self.RBtnHigher := new System.Windows.Forms.RadioButton();
  self.RBtnLower := new System.Windows.Forms.RadioButton();
  self.GrpAssoc.SuspendLayout();
  self.SuspendLayout();
  self.LblBound.AutoSize := true;
  self.LblBound.Location := new System.Drawing.Point(13, 13);
  self.LblBound.Name := 'LblBound';
  self.LblBound.Size := new System.Drawing.Size(67, 13);
  self.LblBound.TabIndex := 0;
  self.LblBound.Text := '&Bound value';
  self.BtnCancel.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnCancel.CausesValidation := false;
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(94, 134);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 40;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.BtnOK.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(12, 134);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 30;
  self.BtnOK.Text := '&OK';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.EditBound.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.EditBound.Location := new System.Drawing.Point(16, 29);
  self.EditBound.Name := 'EditBound';
  self.EditBound.Size := new System.Drawing.Size(193, 20);
  self.EditBound.TabIndex := 10;
  self.EditBound.TextAlign := System.Windows.Forms.HorizontalAlignment.Right;
  self.EditBound.Validating += new System.ComponentModel.CancelEventHandler(self.EditBound_Validating);
  self.EditBound.Validated += new System.EventHandler(self.EditBound_Validated);
  self.GrpAssoc.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.GrpAssoc.Controls.Add(self.RBtnHigher);
  self.GrpAssoc.Controls.Add(self.RBtnLower);
  self.GrpAssoc.Location := new System.Drawing.Point(17, 55);
  self.GrpAssoc.Name := 'GrpAssoc';
  self.GrpAssoc.Size := new System.Drawing.Size(192, 72);
  self.GrpAssoc.TabIndex := 20;
  self.GrpAssoc.TabStop := false;
  self.GrpAssoc.Text := '&Associate bound with';
  self.RBtnHigher.AutoSize := true;
  self.RBtnHigher.Location := new System.Drawing.Point(7, 44);
  self.RBtnHigher.Name := 'RBtnHigher';
  self.RBtnHigher.Size := new System.Drawing.Size(93, 17);
  self.RBtnHigher.TabIndex := 22;
  self.RBtnHigher.TabStop := true;
  self.RBtnHigher.Text := '&Higher interval';
  self.RBtnHigher.UseVisualStyleBackColor := true;
  self.RBtnHigher.Click += new System.EventHandler(self.RBtnHigher_Click);
  self.RBtnLower.AutoSize := true;
  self.RBtnLower.Location := new System.Drawing.Point(7, 20);
  self.RBtnLower.Name := 'RBtnLower';
  self.RBtnLower.Size := new System.Drawing.Size(91, 17);
  self.RBtnLower.TabIndex := 21;
  self.RBtnLower.TabStop := true;
  self.RBtnLower.Text := '&Lower interval';
  self.RBtnLower.UseVisualStyleBackColor := true;
  self.RBtnLower.Click += new System.EventHandler(self.RBtnLower_Click);
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(225, 169);
  self.Controls.Add(self.GrpAssoc);
  self.Controls.Add(self.EditBound);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.Controls.Add(self.LblBound);
  self.Name := 'FormBoundEdit';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'FormBoundEdit';
  self.GrpAssoc.ResumeLayout(false);
  self.GrpAssoc.PerformLayout();
  self.ResumeLayout(false);
  self.PerformLayout();
end;
{$ENDREGION}

end.