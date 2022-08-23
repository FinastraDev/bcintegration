pageextension 71338577 "FLH Headline RC Bus. Mng." extends "Headline RC Business Manager"
{
    layout
    {
        addbefore(Control1)
        {
            field("FLH FinastraLoan"; FinastraTxt)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                begin
                    Page.Run(Page::"FLH FinastraLoan");
                end;
            }

        }
    }

    var
        FinastraTxt: text;

    trigger OnOpenPage()
    begin
        FinastraTxt := 'Find the best loan for your business with Finastra.';
    end;
}
