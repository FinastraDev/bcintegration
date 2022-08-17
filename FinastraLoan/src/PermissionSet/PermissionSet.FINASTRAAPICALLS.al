permissionset 50100 "FINASTRA"
{
    Assignable = true;
    Caption = 'Finastra API call', MaxLength = 30;
    IncludedPermissionSets = LOGIN;
    Permissions =
        codeunit FinastraWebServicesMgt = X,
        codeunit "Finastra Azure AD Mgt." = X,
        codeunit "Finastra Security Mgt." = X,
        codeunit "Finastra Event Mgt." = X,
        page FinastraLoan = X,
        TableData "Accounting Period" = R,
        TableData "Company Information" = R,
        TableData "General Ledger Setup" = R,
        page "APIV2 - Company Information" = X
        ;
}
