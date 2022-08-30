codeunit 71338580 "FLH Install Mgt."
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
    end;

    trigger OnInstallAppPerDatabase()
    var
        AAD: Record "AAD Application";
        SetupMgt: Codeunit "FLH Setup Mng.";
    begin
        if not AAD.Get(SetupMgt.GetIntegrationClientId()) then
            SetupMgt.CreateIntegrationAADApplication();
    end;

}
