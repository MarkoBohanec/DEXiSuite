namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  CtrlNameEdit = public partial class
  {$REGION Windows Control Designer generated fields}
  private
    TextName: System.Windows.Forms.TextBox;
    TextDescription: System.Windows.Forms.TextBox;
    LblName: System.Windows.Forms.Label;
    LblDescription: System.Windows.Forms.Label;
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Control Designer generated code}
method CtrlNameEdit.InitializeComponent;
begin
  self.LblName := new System.Windows.Forms.Label();
  self.LblDescription := new System.Windows.Forms.Label();
  self.TextName := new System.Windows.Forms.TextBox();
  self.TextDescription := new System.Windows.Forms.TextBox();
  self.SuspendLayout();
  self.LblName.AutoSize := true;
  self.LblName.Location := new System.Drawing.Point(4, 12);
  self.LblName.Name := 'LblName';
  self.LblName.Size := new System.Drawing.Size(35, 13);
  self.LblName.TabIndex := 0;
  self.LblName.Text := '&Name';
  self.LblDescription.AutoSize := true;
  self.LblDescription.Location := new System.Drawing.Point(4, 60);
  self.LblDescription.Name := 'LblDescription';
  self.LblDescription.Size := new System.Drawing.Size(60, 13);
  self.LblDescription.TabIndex := 2;
  self.LblDescription.Text := '&Description';
  self.TextName.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.TextName.Location := new System.Drawing.Point(6, 30);
  self.TextName.Name := 'TextName';
  self.TextName.Size := new System.Drawing.Size(526, 20);
  self.TextName.TabIndex := 1;
  self.TextName.TextChanged += new System.EventHandler(self.TextName_TextChanged);
  self.TextDescription.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.TextDescription.Location := new System.Drawing.Point(6, 78);
  self.TextDescription.Multiline := true;
  self.TextDescription.Name := 'TextDescription';
  self.TextDescription.Size := new System.Drawing.Size(526, 184);
  self.TextDescription.TabIndex := 3;
  self.TextDescription.SizeChanged += new System.EventHandler(self.TextDescription_TextChanged);
  self.TextDescription.TextChanged += new System.EventHandler(self.TextDescription_TextChanged);
  self.Controls.Add(self.TextDescription);
  self.Controls.Add(self.TextName);
  self.Controls.Add(self.LblDescription);
  self.Controls.Add(self.LblName);
  self.Name := 'CtrlNameEdit';
  self.Size := new System.Drawing.Size(538, 270);
  self.ResumeLayout(false);
  self.PerformLayout();
end;
{$ENDREGION}

end.