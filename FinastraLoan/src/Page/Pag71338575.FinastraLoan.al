page 71338575 "FLH FinastraLoan"
{
    Caption = 'Finastra Loan Hub';//'Apply for Finastra loan';
    PageType = Worksheet; //Card //Document //List //ListPlus //Worksheet //ConfirmationDialog //StandardDialog //NavigatePage   ; 

    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = False;
    InsertAllowed = False;
    ModifyAllowed = False;
    DeleteAllowed = False;
    RefreshOnActivate = true;
    LinksAllowed = False;


    layout
    {
        area(content)
        {
            usercontrol(FinastraBanksAddIn; "FLH FinastraBanks")
            {
                ApplicationArea = All;
                trigger ControlReady()
                var
                    Environment: Codeunit "Environment Information";
                    Company: Record Company;
                    AzureAdTenant: codeunit "Azure AD Tenant";
                begin
                    Company.Get(CompanyName);
                    //CurrPage.FinastraBanksAddIn.SessionParameters(AzureAdTenant.GetAadTenantId(), Environment.GetEnvironmentName(), Company.Id);
                    CurrPage.FinastraBanksAddIn.Render(GenerateBanksPage());
                end;
            }
        }
    }

    /* Delete before publication
        actions
        {
            area(Processing)
            {
                action(TextBanks)
                {
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Banks: list of [Dictionary of [text, text]];
                        Dic: Dictionary of [text, text];
                        WebMgt: codeunit FinastraWebServicesMgt;
                        i: integer;
                        msg: text;
                    begin
                        WebMgt.SetTestMode();
                        Banks := WebMgt.GetBanks();
                        for i := 1 to Banks.Count do begin
                            if msg <> '' then msg += '\';
                            Dic := Banks.Get(i);
                            msg += 'i: ' + Format(i) + ', u: "' + Dic.Get('url') + '", p: "' + Dic.Get('picture') + '", d: "' + Dic.Get('description') + '"';
                        end;
                        Message(msg);
                    end;
                }
            }
        }
    */

    trigger OnOpenPage()
    var
        AzureService: Codeunit "FLH Azure AD Mgt.";
        FinastraEventMng: codeunit "FLH Event Mgt.";
        FinastraSetupMgt: codeunit "FLH Setup Mng.";
        Notif: Notification;
        UsrPerm: Codeunit "User Permissions";
    begin
        /*if not AzureService.IsAdminConsentGranted(FinastraSetupMgt.GetIntegrationClientId()) then begin
            if UsrPerm.IsSuper(UserSecurityId()) then
                FinastraEventMng.FinastraGrantConsentNotficationAction(Notif)
            else begin
                Message(lblGrantPermission);
            end;
        end;*/
        CurrPage.Caption := 'Start or continue a loan application by selecting a bank in the list below';
    end;

    local procedure GenerateBanksPage() html: text
    var
        WebMgt: codeunit "FLH Web Services Mgt.";
        BankList: list of [Dictionary of [text, text]];
        Bank: Dictionary of [text, text];
        i: integer;
        picture: text;

    begin
        WebMgt.SetTestMode();
        BankList := WebMgt.GetBanks();

        //Header
        html += '<meta name="viewport" content="width=device-width, initial-scale=1">';
        html += '<style>';
        html += ' img { max-width: 100%; height: auto; padding: 20px; max-height: 120px;}';
        html += ' .mtable { width: 90%; margin-left: auto; margin-right: auto; }';
        html += ' .center{ text-align: center;}';
        html += ' td:nth-child(1) {width: 20%; min-width: 150px;}'; //td proportion
        html += ' td:nth-child(2) {width: 60%;}'; //td proportion
        html += ' [data-href] {cursor: pointer;}';
        html += '</style>';
        //body
        if BankList.Count <> 0 then begin
            html += '<table id="mtable" class="table table-hover mtable">';
            for i := 1 to BankList.Count do begin
                Bank := BankList.Get(i);
                html += '<tr data-href="' + AddGetParams(Bank.Get('url')) + '">';
                html += ' <td class="center">';
                picture := 'defaultlogo';
                if Bank.Get('picture') <> '' then
                    picture := Bank.Get('picture');
                html += ' <img src="' + picture + '" alt="Bank Logo"  class="img-fluid">';
                html += ' </td>';
                html += ' <td>' + Bank.Get('description') + ' </td>';
                html += '</tr>';
            end;
            html += '</table>';
        end;
    end;

    local procedure AddGetParams(BaseUrl: text) NewUrl: Text
    var
        Environment: Codeunit "Environment Information";
        Company: Record Company;
        AzureAdTenant: codeunit "Azure AD Tenant";
    begin
        Company.Get(CompanyName);
        newUrl := BaseUrl;
        if not NewUrl.Contains('?') then NewUrl += '?';
        if not (NewUrl.EndsWith('&') or NewUrl.EndsWith('?')) then NewUrl += '&';
        NewUrl += 'tenatid=' + AzureAdTenant.GetAadTenantId() + '&environment=' + Environment.GetEnvironmentName() + '&company=' + Company.SystemId;
    end;

    var
        lblGrantPermission: label 'The Finastra extension has not been granted the necessary permissions. Please contact your system administrator.';
}
