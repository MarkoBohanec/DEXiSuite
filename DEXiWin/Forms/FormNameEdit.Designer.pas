namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormNameEdit = partial class
  {$REGION Windows Form Designer generated fields}
  private
    NameEdit: DexiWin.CtrlNameEdit;
    BtnOK: System.Windows.Forms.Button;
    BtnCancel: System.Windows.Forms.Button;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormNameEdit.InitializeComponent;
begin
  self.NameEdit := new DexiWin.CtrlNameEdit();
  self.BtnOK := new System.Windows.Forms.Button();
  self.BtnCancel := new System.Windows.Forms.Button();
  self.SuspendLayout();
  self.NameEdit.DescriptionText := '';
  self.NameEdit.Dock := System.Windows.Forms.DockStyle.Top;
  self.NameEdit.Location := new System.Drawing.Point(0, 0);
  self.NameEdit.Multiline := true;
  self.NameEdit.Name := 'NameEdit';
  self.NameEdit.NameText := '';
  self.NameEdit.Size := new System.Drawing.Size(601, 348);
  self.NameEdit.TabIndex := 0;
  self.BtnOK.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnOK.Location := new System.Drawing.Point(8, 350);
  self.BtnOK.Name := 'BtnOK';
  self.BtnOK.Size := new System.Drawing.Size(75, 23);
  self.BtnOK.TabIndex := 1;
  self.BtnOK.Text := '&OK';
  self.BtnOK.UseVisualStyleBackColor := true;
  self.BtnCancel.DialogResult := System.Windows.Forms.DialogResult.Cancel;
  self.BtnCancel.Location := new System.Drawing.Point(90, 350);
  self.BtnCancel.Name := 'BtnCancel';
  self.BtnCancel.Size := new System.Drawing.Size(75, 23);
  self.BtnCancel.TabIndex := 2;
  self.BtnCancel.Text := '&Cancel';
  self.BtnCancel.UseVisualStyleBackColor := true;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(601, 386);
  self.Controls.Add(self.BtnCancel);
  self.Controls.Add(self.BtnOK);
  self.Controls.Add(self.NameEdit);
  self.Name := 'FormNameEdit';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'Edit Name and Description';
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.