namespace DexiWin;

interface

{$HIDE H7}

uses
  System.Drawing,
  System.Collections,
  System.Windows.Forms,
  System.ComponentModel;

type
  CtrlForm = public partial class
  {$REGION Windows Control Designer generated fields}
  private
    components: System.ComponentModel.Container := nil;
    method InitializeComponent;
  {$ENDREGION}
  end;

implementation

{$REGION Windows Control Designer generated code}
method CtrlForm.InitializeComponent;
begin
  self.SuspendLayout();
  self.Name := 'CtrlForm';
  self.VisibleChanged += new System.EventHandler(self.CtrlForm_VisibleChanged);
  self.ResumeLayout(false);
end;
{$ENDREGION}

end.