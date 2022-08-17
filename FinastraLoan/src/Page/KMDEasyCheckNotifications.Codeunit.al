/*
codeunit 50104 "KMD Easy Check Notifications"
{
    trigger OnRun()
    var
        UserSetup: Record "User Setup";
        SendTo: List of [Text];
    begin
        IntegrationAdmin.Get();

        DeleteNotificationLogs();
        DeleteOutdatedFiles();
        CheckJobQueueEntryStatus();
        //if SMTPMailSetup.Get() then begin
        UserSetup.SetRange("Receive KMD Easy Notification", true);
        if UserSetup.FindSet() then
            repeat
                SendTo.Add(UserSetup."E-Mail");
            until UserSetup.Next() = 0;

        NotificationLog.Reset();
        NotificationLog.SetRange("Notification Pending", true);
        if NotificationLog.FindSet() then
            repeat
                CreateMail(SendTo, NotificationLog);
            until NotificationLog.Next() = 0;
        //end;
    end;

    local procedure DeleteNotificationLogs()
    var
        DateExpression: Text;
    begin
        if IntegrationAdmin."Notification Data Retention" <> 0 then begin
            DateExpression := '-<' + Format(IntegrationAdmin."Notification Data Retention") + 'M>';
            NotificationLog.SetRange("Notification Pending", false);
            NotificationLog.SetFilter("Created Date", '..%1', CreateDateTime(CalcDate(DateExpression, Today()), 0T));
            NotificationLog.DeleteAll();
        end;
    end;

    local procedure DeleteOutdatedFiles()
    var
        EasyHeader: Record KMD_Easy_Header;
        DateExpression: Text;
    begin
        if IntegrationAdmin."Data Retention" <> 0 then begin
            DateExpression := '-<' + Format(IntegrationAdmin."Data Retention") + 'M>';
            EasyHeader.SetFilter("Created Date", '..%1', CreateDateTime(CalcDate(DateExpression, Today()), 0T));
            EasyHeader.DeleteAll(true);
        end;
    end;

    local procedure CreateMail(SendTo: List of [Text]; NotificationLog: Record KMD_Easy_Notification_Log)
    var
        //CompanyInformation: Record "Company Information";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        //SMTPMailSetup.Get();
        //CompanyInformation.Get();
        //CompanyInformation.TestField("E-Mail");

        EmailMessage.Create(SendTo, format(NotificationLog.Source), NotificationLog."Notification Message", false);
        if Email.Send(EmailMessage) then begin
            NotificationLog."Notification Pending" := false;
            NotificationLog."Notification Sent Date" := CurrentDateTime();
            NotificationLog.Modify();
        end;
    end;

    procedure SendNotificationMissedFile();
    var
        CalendarMgmt: Codeunit "Calendar Management";
        CalChange: Record "Customized Calendar Change";
        BaseCal: Record "Base Calendar";
        FileMissedLbl: Label 'KMD Easy file not found in Azure Blob storage for importing';
    begin
        IntegrationAdmin.Get();
        if BaseCal.Get(IntegrationAdmin."Notifications Calendar") then begin
            CalendarMgmt.SetSource(BaseCal, CalChange);
            if not CalendarMgmt.IsNonworkingDay(Today, CalChange) then
                InsertNotificationLog(FileMissedLbl, KMDNotificationSource::"KMD Easy File Import Job");
        end;
    end;

    procedure InsertNotificationLog(ErrorText: Text; Source: Enum KMDNotificationSource)
    var
        NotificationLog: Record KMD_Easy_Notification_Log;
    begin
        NotificationLog.Init();
        NotificationLog.Source := Source;
        NotificationLog."Notification Message" := CopyStr(ErrorText, 1, 1024);
        NotificationLog."Notification Pending" := true;
        //NotificationLog."Notification Sent Date" := CurrentDateTime();
        NotificationLog."Created Date" := CurrentDateTime();
        NotificationLog.Insert(true);
    end;

    local procedure CheckJobQueueEntryStatus()
    var
        JobEntry: Record "Job Queue Entry";
    begin
        JobEntry.SetRange("Object ID to Run", Codeunit::"KMD Easy Sum. GL File Import");
        JobEntry.SetRange("Object Type to Run", JobEntry."Object Type to Run"::Codeunit);
        JobEntry.SetRange(Status, JobEntry.Status::Error);
        if JobEntry.FindFirst() then begin
            InsertNotificationLog(JobEntry."Error Message", KMDNotificationSource::"KMD Easy File Import Job");
            ShowKMDEasyJobFailedNotification('50103');
            JobEntry.SetStatus(JobEntry.Status::"On Hold");
        end;
        JobEntry.SetRange("Object ID to Run", Codeunit::"KMD Easy Detail GL File Import");
        JobEntry.SetRange("Object Type to Run", JobEntry."Object Type to Run"::Codeunit);
        JobEntry.SetRange(Status, JobEntry.Status::Error);
        if JobEntry.FindFirst() then begin
            InsertNotificationLog(JobEntry."Error Message", KMDNotificationSource::"KMD Easy GL Import Job");
            ShowKMDEasyJobFailedNotification('50106');
            JobEntry.SetStatus(JobEntry.Status::"On Hold");
        end;
    end;

    procedure SetupKMDEasyJobFailedNotification()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetKMDEasyJobFailedNotificationId, 'KMD Easy Integration Job Notification', 'KMD Easy Integration Job Notification', false);
    end;

    procedure ShowKMDEasyJobFailedNotification(ObjId: Text): Boolean
    var
        MyNotifications: Record "My Notifications";
    begin
        if not MyNotifications.IsEnabled(GetKMDEasyJobFailedNotificationId) then
            exit(false);
        CreateAndSendKMDEasyJobFailedNotification(ObjId);
        exit(true);
    end;

    local procedure CreateAndSendKMDEasyJobFailedNotification(ObjId: Text)
    var
        MyNotifications: Record "My Notifications";
        KMDEasyJobFailedNotification: Notification;
        KMDEasyJobFailedNotificationMsg: Label 'KMD Easy Integration %1 Job is Failed to run.';
        KMDEasyJobFailedNotificationLinkTxt: Label 'Job Card';
        JobName: Text;
    begin
        case ObjId of
            '50103':
                JobName := 'Summary';
            '50104':
                JobName := 'Notification';
            '50106':
                JobName := 'Detail';
        end;

        KMDEasyJobFailedNotification.Id := GetKMDEasyJobFailedNotificationId;
        KMDEasyJobFailedNotification.AddAction(KMDEasyJobFailedNotificationLinkTxt, CODEUNIT::"KMD Easy Check Notifications", 'KMDEasyJobFailedNotificationAction');
        KMDEasyJobFailedNotification.SetData('RunObjectId', ObjId);
        KMDEasyJobFailedNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        KMDEasyJobFailedNotification.Message := StrSubstNo(KMDEasyJobFailedNotificationMsg, JobName);
        KMDEasyJobFailedNotification.Send;
    end;

    local procedure GetKMDEasyJobFailedNotificationId(): Guid;
    var
        KMDEasyJobFailedNotificationId: Guid;
        KMDEasyJobFailedNotificationIdTxt: Label '5c314b3e-b92e-4296-a859-e087fcc29eda', Locked = true;
    begin
        Evaluate(KMDEasyJobFailedNotificationId, KMDEasyJobFailedNotificationIdTxt);
        exit(KMDEasyJobFailedNotificationId);
    end;

    procedure CheckKMDJobsStatus();
    begin
        if CheckKMDJobsStatus('50103') then
            ShowKMDEasyJobFailedNotification('50103');
        if CheckKMDJobsStatus('50104') then
            ShowKMDEasyJobFailedNotification('50104');
        if CheckKMDJobsStatus('50106') then
            ShowKMDEasyJobFailedNotification('50106');
    end;

    procedure CheckKMDJobsStatus(ObjId: Text): Boolean;
    var
        JobQueueRec: Record "Job Queue Entry";
        ObjIdToRun: Integer;
    begin
        Evaluate(ObjIdToRun, ObjId);
        JobQueueRec.SetRange("Object Type to Run", JobQueueRec."Object Type to Run"::Codeunit);
        JobQueueRec.SetRange("Object ID to Run", ObjIdToRun);
        JobQueueRec.SetRange(Status, JobQueueRec.Status::Error);
        exit(JobQueueRec.FindFirst());
    end;

    procedure KMDEasyJobFailedNotificationAction(LoadsNotification: Notification)
    var
        JobQueueRec: Record "Job Queue Entry";
        ObjectIDtoRun: Integer;
    begin
        Evaluate(ObjectIDtoRun, LoadsNotification.GetData('RunObjectId'));
        JobQueueRec.SetRange("Object Type to Run", JobQueueRec."Object Type to Run"::Codeunit);
        JobQueueRec.SetRange("Object ID to Run", ObjectIDtoRun);
        if JobQueueRec.FindFirst() then
            Page.Run(Page::"Job Queue Entry Card", JobQueueRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure OnRoleCenterOpen()
    begin
        CheckKMDJobsStatus();
    end;

    var
        NotificationLog: Record KMD_Easy_Notification_Log;
        //SMTPMailSetup: Record "SMTP Mail Setup";
        IntegrationAdmin: Record KMD_Easy_Integration_Admin;
        //MailManagement: Codeunit "Mail Management";
}
*/