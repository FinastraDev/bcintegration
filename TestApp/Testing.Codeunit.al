codeunit 50146 FinastraTestApp
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure CheckWebServices()
    begin
        //Test phase
        Assert.IsTrue(CheckFLHPageExists(), StrSubstNo(Err1Msg));
    end;

    local procedure CheckFLHPageExists(): Boolean
    var
        AllObj: record AllObj;
    begin
        EXIT(AllObj.Get(AllObj."Object Type"::Page, Page::"FLH FinastraLoan"));
    end;

    var
        Assert: Codeunit "Library Assert";
        Err1Msg: Label 'Finastra page "FLH FinastraLoan" does not exists!';
}