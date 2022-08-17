codeunit 50102 "Finastra Security Mgt."
{
    Access = Internal;

    [NonDebuggable]
    procedure GetApiKey(): Text;
    var
        [NonDebuggable]
        ApiKeyLbl: Label '', Locked = true;
    begin
        exit(ApiKeyLbl);
    end;

    [NonDebuggable]
    procedure GetApiSecret(): Text;
    var
        [NonDebuggable]
        ApiSecretLbl: Label '', Locked = true;
    begin
        exit(ApiSecretLbl);
    end;


}
