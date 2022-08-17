pageextension 50121 "Finastra Bus. Mng. Role Cntr." extends "Business Manager Role Center"
{
    actions
    {

        addfirst(creation)
        {
            action("Finastra Loan")
            {
                ApplicationArea = All;
                Caption = 'Loan Application by Finastra';
                RunObject = page FinastraLoan;
            }
        }
    }
}