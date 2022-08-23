pageextension 71338576 "FLH Bus. Mng. Role Cntr." extends "Business Manager Role Center"
{
    actions
    {

        addfirst(creation)
        {
            action("FLH Finastra Loan")
            {
                ApplicationArea = All;
                Caption = 'Loan Application by Finastra';
                RunObject = page "FLH FinastraLoan";
            }
        }
    }
}