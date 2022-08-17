codeunit 50103 "Finastra Azure AD Mgt."
{
    procedure CreateAADApplication(ClientId: Guid; ClientDescription: Text[50]; ContactInformation: Text[50]; AppInfo: ModuleInfo; PermissionSets: List of [Code[20]]; PermissionGroups: List of [Code[20]])
    var
        AADApplication: Record "AAD Application";
    begin
        AADApplication := InsertAADApplication(ClientId, ClientDescription, ContactInformation, AppInfo);
        AssignUserGroupsToAADApplication(AADApplication, PermissionGroups);
        AssignPermissionsToAADApplication(AADApplication, PermissionSets, AppInfo);
    end;

    procedure IsAdminConsentGranted(ClientId: Guid): Boolean;
    var
        AADApplication: Record "AAD Application";
    begin
        if AADApplication.Get(ClientId) then
            exit(AADApplication."Permission Granted");
    end;

    local procedure InsertAADApplication(ClientId: Guid; ClientDescription: Text[50]; ContactInformation: Text[50]; AppInfo: ModuleInfo) AADApplication: Record "AAD Application"
    var
        AADApplicationInterface: Codeunit "AAD Application Interface";
    begin
        AADApplicationInterface.CreateAADApplication(ClientId, ClientDescription, ContactInformation, true);
        AADApplication.Get(ClientId);
        AADApplication."App ID" := AppInfo.Id;
        AADApplication."App Name" := AppInfo.Name;
        AADApplication.Modify();
    end;

    local procedure AssignUserGroupsToAADApplication(var AADApplication: Record "AAD Application"; UserGroups: List of [Code[20]])
    var
        UserGroupCode: Text;
    begin
        if not UserExists(AADApplication) then
            exit;

        foreach UserGroupCode in UserGroups do
            AddUserToGroup(AADApplication."User ID", UserGroupCode, '')
    end;

    local procedure AssignPermissionsToAADApplication(var AADApplication: Record "AAD Application"; PermissionSets: List of [Code[20]]; AppInfo: ModuleInfo)
    var
        PermissionSetName: Text;
    begin
        if not UserExists(AADApplication) then
            exit;

        foreach PermissionSetName in PermissionSets do
            AddPermissionSetToUser(AADApplication."User ID", PermissionSetName, '', AppInfo);
    end;

    local procedure AddUserToGroup(UserSecurityID: Guid; UserGroupCode: Code[20]; Company: Text[30])
    var
        UserGroupMember: Record "User Group Member";
    begin
        UserGroupMember.SetRange("User Security ID", UserSecurityID);
        UserGroupMember.SetRange("User Group Code", UserGroupCode);
        UserGroupMember.SetRange("Company Name", Company);

        if not UserGroupMember.IsEmpty() then
            exit;

        UserGroupMember.Init();
        UserGroupMember."User Security ID" := UserSecurityID;
        UserGroupMember."User Group Code" := UserGroupCode;
        UserGroupMember."Company Name" := Company;
        UserGroupMember.Insert(true);
    end;

    local procedure AddPermissionSetToUser(UserSecurityID: Guid; RoleID: Code[20]; Company: Text[30]; AppInfo: ModuleInfo)
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityID);
        AccessControl.SetRange("Role ID", RoleID);
        AccessControl.SetRange("Company Name", Company);

        if not AccessControl.IsEmpty() then
            exit;

        AccessControl.Init();
        AccessControl."User Security ID" := UserSecurityID;
        AccessControl."Role ID" := RoleID;
        AccessControl."Company Name" := Company;
        AccessControl."App ID" := AppInfo.Id;
        // if RoleID = 'SYS VRS' then begin
        //     AccessControl.Scope := AccessControl.Scope::Tenant;
        //     AccessControl."App ID" := AppInfo.Id;
        // end;
        AccessControl.Insert(true);
    end;

    local procedure UserExists(var AADApplication: Record "AAD Application") Result: Boolean
    var
        User: Record User;
    begin
        if IsNullGuid(AADApplication."User ID") then
            exit;

        Result := User.Get(AADApplication."User ID");
    end;

    procedure RequestAdminConsent(ClientId: Text)
    var
        RedirectURL: Text;
        HasGrantConsentFlowSucceeded: Boolean;
        PermissionGrantErrorMsg: Text;
    begin
        //TenantId := '46e85934-1fab-4533-a4ad-de92ce1fd81a';
        //ClientId := '336848c7-96a2-4b95-ae7a-738b9f4d6335';
        OAuth2.GetDefaultRedirectURL(RedirectURL);
        OAuth2.RequestClientCredentialsAdminPermissions(ClientId, StrSubstNo(OAuthAdminConsentUrl, AADTenant.GetAadTenantId().ToLower()), RedirectURL, HasGrantCOnsentFlowSucceeded, PermissionGrantErrorMsg);
        if HasGrantCOnsentFlowSucceeded then
            Message('Admin grant consent has succeeded.')
        else
            Message('Admin grant consent has failed with the error: ' + PermissionGrantErrorMsg);
    end;

    procedure CheckPermissionsOfAADApplication(): Boolean;
    var
        acl: Record "Access Control";
        usr: Record User;
    begin
        usr.SetRange("User Name", 'INTEGRATION WITH FINASTRA');
        if usr.FindFirst() then begin
            acl.SetRange("User Security ID", usr."User Security ID");
            //acl.SetFilter("Role ID", '<>%1&<>%2', 'FINASTRA API', 'FINASTRA SYS');
            acl.SetFilter("Role ID", '<>%1', 'FINASTRA API');
            exit(acl.FindSet());
        end;
    end;

    /*procedure ResetPermissionsForAADApplication();
    var
        SetupService: Codeunit "VRS Setup Mgt.";
        acl: Record "Access Control";
        usr: Record User;
    begin
        usr.SetRange("User Name", 'INTEGRATION WITH FINASTRA');
        if usr.FindFirst() then begin
            acl.SetRange("User Security ID", usr."User Security ID");
            //acl.SetFilter("Role ID", '<>%1&<>%2', 'FINASTRA API VRS', 'FINASTRA SYS VRS');
            acl.SetFilter("Role ID", '<>%1', 'FINASTRA API VRS');
            if acl.FindSet() then
                acl.DeleteAll();
            SetupService.CreateFINASTRAIntegrationAADApplication();
        end;
    end;*/

    var
        OAuth2: Codeunit OAuth2;
        AADTenant: Codeunit "Azure AD Tenant";
        OAuthAdminConsentUrl: Label 'https://login.microsoftonline.com/%1/adminconsent', Locked = true;

    //TODO add new client ids 
}
