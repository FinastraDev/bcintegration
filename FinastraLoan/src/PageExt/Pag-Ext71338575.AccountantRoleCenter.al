pageextension 71338575 "FLH Acc. Role Center" extends "Accountant Role Center"
{
    actions
    {

        addlast(creation)
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
