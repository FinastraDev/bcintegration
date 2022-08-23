permissionset 71338575 "FLH FINASTRA"
{
    Assignable = true;

    Caption = 'Finastra API call', MaxLength = 30;
    IncludedPermissionSets = LOGIN;
    Permissions =
        codeunit "FLH Web Services Mgt." = X,
        codeunit "FLH Azure AD Mgt." = X,
        codeunit "FLH Security Mgt." = X,
        codeunit "FLH Event Mgt." = X,
        page "FLH FinastraLoan" = X,
        TableData "Accounting Period" = R,
        TableData "Company Information" = R,
        TableData "General Ledger Setup" = R,
        page "APIV2 - Company Information" = X
        ;
}
