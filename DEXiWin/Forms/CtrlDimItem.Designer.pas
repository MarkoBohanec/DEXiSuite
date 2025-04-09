namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  CtrlDimItem = public partial class
  {$REGION Windows Control Designer generated fields}
  private
    ChkPanel: System.Windows.Forms.Panel;
    PanelIndent: System.Windows.Forms.Panel;
    ChkBox: System.Windows.Forms.CheckBox;
    RadioBtn: System.Windows.Forms.RadioButton;
    LblText: System.Windows.Forms.Label;
    DimImgList: System.Windows.Forms.ImageList;
    LblImage: System.Windows.Forms.Label;
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Control Designer generated code}
method CtrlDimItem.InitializeComponent;
begin
  self.components := new System.ComponentModel.Container();
  var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeOf(CtrlDimItem));
  self.PanelIndent := new System.Windows.Forms.Panel();
  self.ChkBox := new System.Windows.Forms.CheckBox();
  self.RadioBtn := new System.Windows.Forms.RadioButton();
  self.LblText := new System.Windows.Forms.Label();
  self.DimImgList := new System.Windows.Forms.ImageList(self.components);
  self.LblImage := new System.Windows.Forms.Label();
  self.ChkPanel := new System.Windows.Forms.Panel();
  self.SuspendLayout();
  self.PanelIndent.BackColor := System.Drawing.Color.Transparent;
  self.PanelIndent.Dock := System.Windows.Forms.DockStyle.Left;
  self.PanelIndent.Location := new System.Drawing.Point(0, 0);
  self.PanelIndent.Name := 'PanelIndent';
  self.PanelIndent.Size := new System.Drawing.Size(32, 20);
  self.PanelIndent.TabIndex := 0;
  self.ChkBox.AutoCheck := false;
  self.ChkBox.AutoSize := true;
  self.ChkBox.BackColor := System.Drawing.Color.Transparent;
  self.ChkBox.Dock := System.Windows.Forms.DockStyle.Left;
  self.ChkBox.Location := new System.Drawing.Point(47, 0);
  self.ChkBox.Name := 'ChkBox';
  self.ChkBox.Size := new System.Drawing.Size(15, 20);
  self.ChkBox.TabIndex := 2;
  self.ChkBox.UseVisualStyleBackColor := false;
  self.ChkBox.Click += new System.EventHandler(self.ChkBox_Click);
  self.RadioBtn.AutoCheck := false;
  self.RadioBtn.AutoSize := true;
  self.RadioBtn.BackColor := System.Drawing.Color.Transparent;
  self.RadioBtn.Dock := System.Windows.Forms.DockStyle.Left;
  self.RadioBtn.Location := new System.Drawing.Point(62, 0);
  self.RadioBtn.Name := 'RadioBtn';
  self.RadioBtn.Size := new System.Drawing.Size(14, 20);
  self.RadioBtn.TabIndex := 3;
  self.RadioBtn.TabStop := true;
  self.RadioBtn.UseVisualStyleBackColor := false;
  self.RadioBtn.Click += new System.EventHandler(self.RadioBtn_Click);
  self.LblText.BackColor := System.Drawing.Color.Transparent;
  self.LblText.Dock := System.Windows.Forms.DockStyle.Fill;
  self.LblText.ImageAlign := System.Drawing.ContentAlignment.MiddleLeft;
  self.LblText.ImageIndex := 0;
  self.LblText.Location := new System.Drawing.Point(92, 0);
  self.LblText.Name := 'LblText';
  self.LblText.Size := new System.Drawing.Size(58, 20);
  self.LblText.TabIndex := 5;
  self.LblText.Text := 'Text';
  self.LblText.TextAlign := System.Drawing.ContentAlignment.MiddleLeft;
  self.LblText.Click += new System.EventHandler(self.LblText_Click);
  self.DimImgList.ImageStream := (resources.GetObject('DimImgList.ImageStream') as System.Windows.Forms.ImageListStreamer);
  self.DimImgList.TransparentColor := System.Drawing.Color.Transparent;
  self.DimImgList.Images.SetKeyName(0, 'ImgDimDown');
  self.DimImgList.Images.SetKeyName(1, 'ImgDimLD');
  self.DimImgList.Images.SetKeyName(2, 'ImgDimLU');
  self.DimImgList.Images.SetKeyName(3, 'ImgDimRD');
  self.DimImgList.Images.SetKeyName(4, 'ImgDimRU');
  self.DimImgList.Images.SetKeyName(5, 'ImgDimUp');
  self.DimImgList.Images.SetKeyName(6, 'ImgDimEmpty');
  self.LblImage.BackColor := System.Drawing.Color.Transparent;
  self.LblImage.Dock := System.Windows.Forms.DockStyle.Left;
  self.LblImage.ImageIndex := 5;
  self.LblImage.ImageList := self.DimImgList;
  self.LblImage.Location := new System.Drawing.Point(76, 0);
  self.LblImage.Name := 'LblImage';
  self.LblImage.Size := new System.Drawing.Size(16, 20);
  self.LblImage.TabIndex := 4;
  self.LblImage.Click += new System.EventHandler(self.LblImage_Click);
  self.ChkPanel.Dock := System.Windows.Forms.DockStyle.Left;
  self.ChkPanel.Location := new System.Drawing.Point(32, 0);
  self.ChkPanel.Name := 'ChkPanel';
  self.ChkPanel.Size := new System.Drawing.Size(15, 20);
  self.ChkPanel.TabIndex := 1;
  self.BackColor := System.Drawing.Color.Transparent;
  self.Controls.Add(self.LblText);
  self.Controls.Add(self.LblImage);
  self.Controls.Add(self.RadioBtn);
  self.Controls.Add(self.ChkBox);
  self.Controls.Add(self.ChkPanel);
  self.Controls.Add(self.PanelIndent);
  self.Name := 'CtrlDimItem';
  self.Size := new System.Drawing.Size(150, 20);
  self.ResumeLayout(false);
  self.PerformLayout();
end;
{$ENDREGION}

end.