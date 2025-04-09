namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormAbout = partial class
  {$REGION Windows Form Designer generated fields}
  private
    LblCopyrightLabel: System.Windows.Forms.Label;
    LblLibraryCopyright: System.Windows.Forms.Label;
    LblLink: System.Windows.Forms.LinkLabel;
    LblLibrary: System.Windows.Forms.Label;
    BtnClose: System.Windows.Forms.Button;
    AboutPanel: System.Windows.Forms.Panel;
    LblCopyright: System.Windows.Forms.Label;
    LblDescription: System.Windows.Forms.Label;
    LblVersion: System.Windows.Forms.Label;
    LblSoftware: System.Windows.Forms.Label;
    AboutIcon: System.Windows.Forms.PictureBox;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormAbout.InitializeComponent;
begin
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(FormAbout));
  self.AboutPanel := new System.Windows.Forms.Panel();
  self.LblCopyright := new System.Windows.Forms.Label();
  self.LblLibraryCopyright := new System.Windows.Forms.Label();
  self.LblLink := new System.Windows.Forms.LinkLabel();
  self.LblLibrary := new System.Windows.Forms.Label();
  self.LblCopyrightLabel := new System.Windows.Forms.Label();
  self.LblDescription := new System.Windows.Forms.Label();
  self.LblVersion := new System.Windows.Forms.Label();
  self.LblSoftware := new System.Windows.Forms.Label();
  self.AboutIcon := new System.Windows.Forms.PictureBox();
  self.BtnClose := new System.Windows.Forms.Button();
  self.AboutPanel.SuspendLayout();
  (self.AboutIcon as System.ComponentModel.ISupportInitialize).BeginInit();
  self.SuspendLayout();
  self.AboutPanel.BackColor := System.Drawing.Color.White;
  self.AboutPanel.BorderStyle := System.Windows.Forms.BorderStyle.FixedSingle;
  self.AboutPanel.Controls.Add(self.LblCopyright);
  self.AboutPanel.Controls.Add(self.LblLibraryCopyright);
  self.AboutPanel.Controls.Add(self.LblLink);
  self.AboutPanel.Controls.Add(self.LblLibrary);
  self.AboutPanel.Controls.Add(self.LblCopyrightLabel);
  self.AboutPanel.Controls.Add(self.LblDescription);
  self.AboutPanel.Controls.Add(self.LblVersion);
  self.AboutPanel.Controls.Add(self.LblSoftware);
  self.AboutPanel.Controls.Add(self.AboutIcon);
  self.AboutPanel.Location := new System.Drawing.Point(12, 12);
  self.AboutPanel.Name := 'AboutPanel';
  self.AboutPanel.Size := new System.Drawing.Size(659, 258);
  self.AboutPanel.TabIndex := 0;
  self.AboutPanel.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(self.AboutPanel_MouseDoubleClick);
  self.LblCopyright.AutoSize := true;
  self.LblCopyright.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblCopyright.Location := new System.Drawing.Point(242, 122);
  self.LblCopyright.Name := 'LblCopyright';
  self.LblCopyright.Size := new System.Drawing.Size(86, 17);
  self.LblCopyright.TabIndex := 7;
  self.LblCopyright.Text := 'Copyright '#169' ';
  self.LblLibraryCopyright.AutoSize := true;
  self.LblLibraryCopyright.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblLibraryCopyright.Location := new System.Drawing.Point(242, 218);
  self.LblLibraryCopyright.Name := 'LblLibraryCopyright';
  self.LblLibraryCopyright.Size := new System.Drawing.Size(86, 17);
  self.LblLibraryCopyright.TabIndex := 6;
  self.LblLibraryCopyright.Text := 'Copyright '#169' ';
  self.LblLink.AutoSize := true;
  self.LblLink.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblLink.LinkVisited := true;
  self.LblLink.Location := new System.Drawing.Point(243, 162);
  self.LblLink.Name := 'LblLink';
  self.LblLink.Size := new System.Drawing.Size(108, 17);
  self.LblLink.TabIndex := 1;
  self.LblLink.TabStop := true;
  self.LblLink.Text := 'https://dex.ijs.si/';
  self.LblLink.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(self.LblLink_LinkClicked);
  self.LblLibrary.AutoSize := true;
  self.LblLibrary.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblLibrary.Location := new System.Drawing.Point(242, 201);
  self.LblLibrary.Name := 'LblLibrary';
  self.LblLibrary.Size := new System.Drawing.Size(40, 17);
  self.LblLibrary.TabIndex := 5;
  self.LblLibrary.Text := 'Uses';
  self.LblCopyrightLabel.AutoSize := true;
  self.LblCopyrightLabel.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblCopyrightLabel.Location := new System.Drawing.Point(242, 105);
  self.LblCopyrightLabel.Name := 'LblCopyrightLabel';
  self.LblCopyrightLabel.Size := new System.Drawing.Size(86, 17);
  self.LblCopyrightLabel.TabIndex := 4;
  self.LblCopyrightLabel.Text := 'Copyright '#169' ';
  self.LblDescription.AutoSize := true;
  self.LblDescription.Font := new System.Drawing.Font('Microsoft Sans Serif', 14.0, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblDescription.Location := new System.Drawing.Point(242, 65);
  self.LblDescription.Name := 'LblDescription';
  self.LblDescription.Size := new System.Drawing.Size(319, 24);
  self.LblDescription.TabIndex := 3;
  self.LblDescription.Text := 'DEX Decision Modeling Software';
  self.LblVersion.Font := new System.Drawing.Font('Microsoft Sans Serif', 10.0, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblVersion.Location := new System.Drawing.Point(390, 23);
  self.LblVersion.Name := 'LblVersion';
  self.LblVersion.Size := new System.Drawing.Size(171, 23);
  self.LblVersion.TabIndex := 2;
  self.LblVersion.Text := 'Version';
  self.LblVersion.TextAlign := System.Drawing.ContentAlignment.TopRight;
  self.LblSoftware.AutoSize := true;
  self.LblSoftware.Font := new System.Drawing.Font('Microsoft Sans Serif', 18.0, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, (238 as System.Byte));
  self.LblSoftware.Location := new System.Drawing.Point(242, 20);
  self.LblSoftware.Name := 'LblSoftware';
  self.LblSoftware.Size := new System.Drawing.Size(116, 29);
  self.LblSoftware.TabIndex := 1;
  self.LblSoftware.Text := 'Software';
  self.AboutIcon.Image := (resources.GetObject('AboutIcon.Image') as System.Drawing.Image);
  self.AboutIcon.Location := new System.Drawing.Point(15, 19);
  self.AboutIcon.Name := 'AboutIcon';
  self.AboutIcon.Size := new System.Drawing.Size(196, 199);
  self.AboutIcon.SizeMode := System.Windows.Forms.PictureBoxSizeMode.StretchImage;
  self.AboutIcon.TabIndex := 0;
  self.AboutIcon.TabStop := false;
  self.BtnClose.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnClose.Location := new System.Drawing.Point(260, 276);
  self.BtnClose.Name := 'BtnClose';
  self.BtnClose.Size := new System.Drawing.Size(75, 23);
  self.BtnClose.TabIndex := 0;
  self.BtnClose.Text := '&Close';
  self.BtnClose.UseVisualStyleBackColor := true;
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(684, 307);
  self.Controls.Add(self.BtnClose);
  self.Controls.Add(self.AboutPanel);
  self.FormBorderStyle := System.Windows.Forms.FormBorderStyle.FixedDialog;
  self.Name := 'FormAbout';
  self.ShowIcon := false;
  self.ShowInTaskbar := false;
  self.StartPosition := System.Windows.Forms.FormStartPosition.CenterParent;
  self.Text := 'About';
  self.AboutPanel.ResumeLayout(false);
  self.AboutPanel.PerformLayout();
  (self.AboutIcon as System.ComponentModel.ISupportInitialize).EndInit();
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.