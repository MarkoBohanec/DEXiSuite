namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormScaleCreate = partial class
  {$REGION Windows Form Designer generated fields}
  private
    GrpBox: System.Windows.Forms.GroupBox;
    BtnContinuous: System.Windows.Forms.RadioButton;
    BtnDiscrete: System.Windows.Forms.RadioButton;
    BtnCancel: System.Windows.Forms.Button;
    BtnOK: System.Windows.Forms.Button;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormScaleCreate.InitializeComponent;
begin
  self.BtnCancel := new System.Windows.Forms.Button();
  self.BtnOK := new System.Windows.Forms.Button();
  self.GrpBox := new System.Windows.Forms.GroupBox();
  self.BtnContinuous := new System.Windows.Forms.RadioButton();
  self.BtnDiscrete := new System.Windows.Forms.RadioButton();
  self.GrpBox.SuspendLayout();
  self.SuspendLayout();
  self.BtnCancel.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(94, 100);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 101;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.BtnOK.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(12, 100);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 100;
  self.BtnOK.Text := '&OK';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.GrpBox.Controls.Add(self.BtnContinuous);
  self.GrpBox.Controls.Add(self.BtnDiscrete);
  self.GrpBox.Location := new System.Drawing.Point(13, 13);
  self.GrpBox.Name := 'GrpBox';
  self.GrpBox.Size := new System.Drawing.Size(390, 77);
  self.GrpBox.TabIndex := 10;
  self.GrpBox.TabStop := false;
  self.GrpBox.Text := 'Choose scale &type';
  self.BtnContinuous.AutoSize := true;
  self.BtnContinuous.Location := new System.Drawing.Point(7, 44);
  self.BtnContinuous.Name := 'BtnContinuous';
  self.BtnContinuous.Size := new System.Drawing.Size(78, 17);
  self.BtnContinuous.TabIndex := 1;
  self.BtnContinuous.TabStop := true;
  self.BtnContinuous.Text := '&Continuous';
  self.BtnContinuous.UseVisualStyleBackColor := true;
  self.BtnDiscrete.AutoSize := true;
  self.BtnDiscrete.Location := new System.Drawing.Point(7, 20);
  self.BtnDiscrete.Name := 'BtnDiscrete';
  self.BtnDiscrete.Size := new System.Drawing.Size(75, 17);
  self.BtnDiscrete.TabIndex := 0;
  self.BtnDiscrete.TabStop := true;
  self.BtnDiscrete.Text := '&Qualitative';
  self.BtnDiscrete.UseVisualStyleBackColor := true;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(415, 135);
  self.Controls.Add(self.GrpBox);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog;
  self.Name := 'FormScaleCreate';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'Create scale of "{0}"';
  self.GrpBox.ResumeLayout(false);
  self.GrpBox.PerformLayout();
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.