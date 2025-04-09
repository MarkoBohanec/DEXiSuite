namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormList = partial public class
  {$REGION Windows Form Designer generated fields}
  private
    Contents: System.Windows.Forms.RichTextBox;
    BottomPanel: System.Windows.Forms.Panel;
    BtnClose: System.Windows.Forms.Button;
    
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormList.InitializeComponent;
begin
  self.BottomPanel := new System.Windows.Forms.Panel();
  self.BtnClose := new System.Windows.Forms.Button();
  self.Contents := new System.Windows.Forms.RichTextBox();
  self.BottomPanel.SuspendLayout();
  self.SuspendLayout();
  self.BottomPanel.Controls.Add(self.BtnClose);
  self.BottomPanel.Dock := System.Windows.Forms.DockStyle.Bottom;
  self.BottomPanel.Location := new System.Drawing.Point(0, 290);
  self.BottomPanel.Name := 'BottomPanel';
  self.BottomPanel.Size := new System.Drawing.Size(383, 46);
  self.BottomPanel.TabIndex := 0;
  self.BtnClose.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnClose.Location := new System.Drawing.Point(12, 12);
  self.BtnClose.Name := 'BtnClose';
  self.BtnClose.Size := new System.Drawing.Size(75, 23);
  self.BtnClose.TabIndex := 0;
  self.BtnClose.Text := 'Close';
  self.BtnClose.UseVisualStyleBackColor := true;
  self.Contents.Dock := System.Windows.Forms.DockStyle.Fill;
  self.Contents.Location := new System.Drawing.Point(0, 0);
  self.Contents.Name := 'Contents';
  self.Contents.Size := new System.Drawing.Size(383, 290);
  self.Contents.TabIndex := 1;
  self.Contents.Text := '';
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(383, 336);
  self.Controls.Add(self.Contents);
  self.Controls.Add(self.BottomPanel);
  self.Name := 'FormList';
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen;
  self.BottomPanel.ResumeLayout(false);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.