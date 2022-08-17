codeunit 50101 "Finastra Event Mgt."
{

    trigger OnRun()
    begin
        ShowFinastaraNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', False, False)]
    local procedure SetFinastaraNotification()
    var
        MyNotification: record "My Notifications";
    begin
        MyNotification.InsertDefault(NotificationId, NotificationName, NotificationDescription, True);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', False, False)]
    local procedure DoShowFinastaraNotification()
    begin
        ShowFinastaraNotification();
    end;

    local procedure ShowFinastaraNotification(): Boolean
    var
        MyNotifications: Record "My Notifications";
        AzureService: codeunit "Finastra Azure AD Mgt.";
        FinastraSetupMng: codeunit "Finastra Setup Mng.";
    begin
        if not MyNotifications.IsEnabled(NotificationId) then
            exit(false);
        if AzureService.IsAdminConsentGranted(FinastraSetupMng.GetIntegrationClientId()) then
            exit(False);
        CreateAndSendFinastraNotification();
        exit(true);
    end;

    local procedure CreateAndSendFinastraNotification()
    var
        FinastraNotification: Notification;
    begin
        FinastraNotification.ID := NotificationId;
        FinastraNotification.Message := NotificationMessage;
        FinastraNotification.Scope := NotificationScope::LocalScope;
        //FinastraNotification.AddAction('Finastra Loan', Codeunit::"Finastra Event Mgt.", 'FinastraLoanNotificationAction');
        FinastraNotification.AddAction(lblGrantConsent, Codeunit::"Finastra Event Mgt.", 'FinastraGrantConsentNotficationAction');
        FinastraNotification.AddAction(lblDontShowMeAgain, Codeunit::"Finastra Event Mgt.", 'FinastraDontShowMeAgainNotficationAction');
        FinastraNotification.Send();
    end;

    procedure FinastraLoanNotificationAction(FinastraNotification: Notification)
    begin
        Page.Run(Page::FinastraLoan);
    end;

    procedure FinastraGrantConsentNotficationAction(FinastraNotification: Notification)
    var
        AAD: Record "AAD Application";
        SetupMgt: Codeunit "Finastra Setup Mng.";
    begin
        if not AAD.Get(SetupMgt.GetIntegrationClientId()) then begin
            SetupMgt.CreateIntegrationAADApplication();
            AAD.Get(SetupMgt.GetIntegrationClientId())
        end;
        Page.Run(Page::"AAD Application Card", AAD);
    end;

    procedure FinastraDontShowMeAgainNotficationAction(FinastraNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(NotificationId);
    end;

    var
        NotificationId: Label '86e09e9d-1ba0-441d-b5c4-e7b2f42b0890', Locked = true;
        NotificationName: label 'Finastra Notification', locked = true;
        NotificationDescription: label 'Finastra provides an opportunity to obtain a loan.', locked = true;
        NotificationMessage: label 'To complete your installation of the Finastra Loan Hub, please grant access to the application.';
        lblGrantConsent: label 'Grant Consent';
        lblDontShowMeAgain: label 'Don''t show me again';
}
