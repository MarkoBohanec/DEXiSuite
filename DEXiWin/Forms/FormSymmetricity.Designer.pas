namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  FormSymmetricity = partial public class
  {$REGION Windows Form Designer generated fields}
  private
    BtnEnforce: System.Windows.Forms.Button;
    Att1Edit: System.Windows.Forms.ComboBox;
    Att2Edit: System.Windows.Forms.ComboBox;
    BtnClose: System.Windows.Forms.Button;
    StatusGrp: System.Windows.Forms.GroupBox;
    StatusBox: System.Windows.Forms.RichTextBox;
    
    
    Att1Label: System.Windows.Forms.Label;
    Att2Label: System.Windows.Forms.Label;
    var components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Form Designer generated code}
method FormSymmetricity.InitializeComponent;
begin
  self.BtnClose := new System.Windows.Forms.Button();
  self.StatusGrp := new System.Windows.Forms.GroupBox();
  self.StatusBox := new System.Windows.Forms.RichTextBox();
  self.Att1Edit := new System.Windows.Forms.ComboBox();
  self.Att2Edit := new System.Windows.Forms.ComboBox();
  self.Att1Label := new System.Windows.Forms.Label();
  self.Att2Label := new System.Windows.Forms.Label();
  self.BtnEnforce := new System.Windows.Forms.Button();
  self.StatusGrp.SuspendLayout();
  self.SuspendLayout();
  self.BtnClose.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left as System.Windows.Forms.AnchorStyles);
  self.BtnClose.DialogResult := System.Windows.Forms.DialogResult.OK;
  self.BtnClose.Location := new System.Drawing.Point(20, 304);
  self.BtnClose.Name := 'BtnClose';
  self.BtnClose.Size := new System.Drawing.Size(75, 23);
  self.BtnClose.TabIndex := 8;
  self.BtnClose.Text := 'Close';
  self.BtnClose.UseVisualStyleBackColor := true;
  self.StatusGrp.Anchor := (System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Left or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.StatusGrp.Controls.Add(self.StatusBox);
  self.StatusGrp.Location := new System.Drawing.Point(16, 73);
  self.StatusGrp.Name := 'StatusGrp';
  self.StatusGrp.Size := new System.Drawing.Size(458, 212);
  self.StatusGrp.TabIndex := 9;
  self.StatusGrp.TabStop := false;
  self.StatusGrp.Text := 'Symmetricity status';
  self.StatusBox.Dock := System.Windows.Forms.DockStyle.Fill;
  self.StatusBox.Location := new System.Drawing.Point(3, 16);
  self.StatusBox.Name := 'StatusBox';
  self.StatusBox.ReadOnly := true;
  self.StatusBox.Size := new System.Drawing.Size(452, 193);
  self.StatusBox.TabIndex := 0;
  self.StatusBox.TabStop := false;
  self.StatusBox.Text := '';
  self.Att1Edit.DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList;
  self.Att1Edit.FormattingEnabled := true;
  self.Att1Edit.Location := new System.Drawing.Point(20, 32);
  self.Att1Edit.Name := 'Att1Edit';
  self.Att1Edit.Size := new System.Drawing.Size(220, 21);
  self.Att1Edit.TabIndex := 10;
  self.Att1Edit.SelectedIndexChanged += new System.EventHandler(self.Att1Edit_SelectedIndexChanged);
  self.Att2Edit.DropDownStyle := System.Windows.Forms.ComboBoxStyle.DropDownList;
  self.Att2Edit.FormattingEnabled := true;
  self.Att2Edit.Location := new System.Drawing.Point(250, 32);
  self.Att2Edit.Name := 'Att2Edit';
  self.Att2Edit.Size := new System.Drawing.Size(220, 21);
  self.Att2Edit.TabIndex := 11;
  self.Att2Edit.SelectedIndexChanged += new System.EventHandler(self.Att1Edit_SelectedIndexChanged);
  self.Att1Label.AutoSize := true;
  self.Att1Label.Location := new System.Drawing.Point(20, 16);
  self.Att1Label.Name := 'Att1Label';
  self.Att1Label.Size := new System.Drawing.Size(55, 13);
  self.Att1Label.TabIndex := 12;
  self.Att1Label.Text := 'Attribute 1';
  self.Att2Label.AutoSize := true;
  self.Att2Label.Location := new System.Drawing.Point(250, 16);
  self.Att2Label.Name := 'Att2Label';
  self.Att2Label.Size := new System.Drawing.Size(55, 13);
  self.Att2Label.TabIndex := 13;
  self.Att2Label.Text := 'Attribute 2';
  self.BtnEnforce.Anchor := (System.Windows.Forms.AnchorStyles.Bottom or System.Windows.Forms.AnchorStyles.Right as System.Windows.Forms.AnchorStyles);
  self.BtnEnforce.Location := new System.Drawing.Point(395, 304);
  self.BtnEnforce.Name := 'BtnEnforce';
  self.BtnEnforce.Size := new System.Drawing.Size(75, 23);
  self.BtnEnforce.TabIndex := 14;
  self.BtnEnforce.Text := 'Enforce';
  self.BtnEnforce.UseVisualStyleBackColor := true;
  self.BtnEnforce.Click += new System.EventHandler(self.BtnEnforce_Click);
  self.AutoScaleDimensions := new System.Drawing.SizeF(6.0, 13.0);
  self.AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font;
  self.ClientSize := new System.Drawing.Size(489, 339);
  self.Controls.Add(self.BtnEnforce);
  self.Controls.Add(self.Att2Label);
  self.Controls.Add(self.Att1Label);
  self.Controls.Add(self.Att2Edit);
  self.Controls.Add(self.Att1Edit);
  self.Controls.Add(self.StatusGrp);
  self.Controls.Add(self.BtnClose);
  self.MinimumSize := new System.Drawing.Size(505, 250);
  self.Name := 'FormSymmetricity';
  self.Text := 'Symmetricity: {0}';
  self.StatusGrp.ResumeLayout(false);
  self.ResumeLayout(false);
  self.PerformLayout();
end;
{$ENDREGION}

end.