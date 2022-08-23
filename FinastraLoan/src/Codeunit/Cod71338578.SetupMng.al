codeunit 71338578 "FLH Setup Mng."
{
    procedure CreateIntegrationAADApplication()
    var
        AADApplicationInterface: Codeunit "FLH Azure AD Mgt.";
        AppInfo: ModuleInfo;
        ClientDescription: Text[50];
        ContactInformation: Text[50];
        IntegrationDescriptionTxt: Label 'Finastra API Calls';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        ClientDescription := CopyStr(IntegrationDescriptionTxt, 1, MaxStrLen(ClientDescription));
        ContactInformation := CopyStr(AppInfo.Publisher, 1, MaxStrLen(ContactInformation));

        AADApplicationInterface.CreateAADApplication(
            GetIntegrationClientId(),
            ClientDescription,
            ContactInformation,
            AppInfo,
            GetPermissionSets(),
            GetPermissionGroups());
    end;

    procedure GetIntegrationClientId() Id: Guid
    var
        //IntegrationClientIdTok: Label '100316d6-b2e4-4f83-83f9-1e53b3c44100', Locked = true; //create test
        //IntegrationClientIdTok: Label '8d8316d6-b2e4-4f83-83f9-1e53b3c44faf', Locked = true; //original test
        IntegrationClientIdTok: label 'bb6d5d2a-76b9-4aec-986d-5dfde141d707', Locked = true; //work 
    begin
        Id := IntegrationClientIdTok;
    end;

    local procedure GetPermissionSets() PermissionSets: List of [Code[20]]
    begin
        PermissionSets.Add('FINASTRA');
    end;

    local procedure GetPermissionGroups() PermissionGroups: List of [Code[20]]
    begin
        PermissionGroups.Add('D365 AUTOMATION');
        PermissionGroups.Add('D365 BUS PREMIUM');
        PermissionGroups.Add('D365 EXTENSION MGT');
    end;
}
