pageextension 50101 "Finastra Headline RC Bus. Mng." extends "Headline RC Business Manager"
{
    layout
    {
        addbefore(Control1)
        {
            field(FinastraLoan; FinastraTxt)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                begin
                    Page.Run(Page::FinastraLoan);
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
