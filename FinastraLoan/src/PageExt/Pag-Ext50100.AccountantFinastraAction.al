pageextension 50120 "Finastra Acc. Role Center" extends "Accountant Role Center"
{
    actions
    {

        addlast(creation)
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
