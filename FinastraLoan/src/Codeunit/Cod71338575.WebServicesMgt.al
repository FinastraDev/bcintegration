codeunit 71338575 "FLH Web Services Mgt."
{
    var
        TestMode: boolean;

    procedure SetTestMode()
    begin
        TestMode := True;
    end;

    /// <summary>
    /// GetBanks form Finastra Api
    /// </summary>
    /// <returns>Return variable Banks of type List of [Dictionary of [text, text]] or error</returns>
    procedure GetBanks() Banks: List of [Dictionary of [text, text]]
    var
        json: JsonObject;
        jToken: jsonToken;
        jArray: JsonArray;
        jObject: JsonObject;
        jValue: JsonValue;
        i: Integer;
        Dic: Dictionary of [text, text];
        url: text;
        picture: text;
        descr: text;
    begin
        json := CallBanks;
        /*
        if json.Contains('$.error') then
            if json.SelectToken('$.error', jToken) then 
                Error(jToken.AsValue().AsText());
        */
        if json.Get('banks', jToken) then begin
            jArray := jToken.AsArray();
            for i := 0 to jArray.Count - 1 do begin
                if jArray.Get(i, jToken) then begin
                    jObject := jToken.AsObject();
                    Clear(Dic);
                    Dic.Add('url', GetJsonKeyAsText(jObject, 'url', ''));
                    Dic.Add('picture', GetJsonKeyAsText(jObject, 'picture', ''));
                    Dic.Add('description', GetJsonKeyAsText(jObject, 'description', ''));
                    Banks.Add(Dic);
                end;
            end;
        end;
    end;

    local procedure GetJsonKeyAsText(jObject: jsonObject; sKey: text; sDefault: text): Text
    var
        jToken: jsonToken;
    begin
        if jObject.Get(sKey, jToken) then
            exit(jToken.asValue().AsText());
        exit(sDefault);
    end;


    local procedure GetFinastraURL(): text
    begin
        exit('https://Test.test.finastra');
    end;

    local procedure CallWebService(Parameters: Dictionary of [text, text]): boolean
    var
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Client: HttpClient;
        Header: HttpHeaders;
        RequestBody, ResponseBody : Text;
    begin
        Request.SetRequestUri(Parameters.Get('URL'));
        Request.Method(Parameters.Get('Method'));
        Request.GetHeaders(Header);
        if Parameters.ContainsKey('Authorization') then
            Header.Add('Authorization', Parameters.Get('Authorization'));
        if Parameters.ContainsKey('Accept') then
            Header.Add('Accept', Parameters.Get('Accept'));

        Header.Add('Timeout', '10000');

        if Parameters.ContainsKey('RequestBody') then begin
            RequestBody := Parameters.Get('RequestBody');
            Content.WriteFrom(RequestBody);
        end;
        if Parameters.ContainsKey('ContentType') then begin
            Content.GetHeaders(Header);
            Header.Remove('Content-Type');
            Header.Add('Content-Type', Parameters.Get('ContentType'));
        end;

        if RequestBody <> '' then
            Request.Content := Content;

        if Client.Send(Request, Response) then begin
            if Response.Content.ReadAs(ResponseBody) then
                Parameters.Add('ResponseBody', ResponseBody);
            Parameters.Add('HttpStatusCode', Format(Response.HttpStatusCode));

            exit(true);
        end;

        if not Response.Content.ReadAs(ResponseBody) then
            ResponseBody := '{"error":"' + GetLastErrorText() + '"}';
        Parameters.Add('ResponseBody', ResponseBody);
        exit(false);
    end;

    local procedure ResponseBodyAsJson(Parameters: Dictionary of [text, text]; var json: JsonObject): boolean
    var
        ResponseBody: text;
    begin
        if Parameters.ContainsKey('HttpStatusCode') and Parameters.Get('ResponseBody', ResponseBody) then begin
            exit(json.ReadFrom(ResponseBody));
        end;
    end;

    local procedure GetAuthToken() Token: Text
    var
        SecService: Codeunit "FLH Security Mgt.";
        Parameters: Dictionary of [Text, Text];
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        ResponseBody: Text;
        ExpiersDate: DateTime;
        txtExpiresData: text;
    begin
        if IsolatedStorage.Get('ExpiresDate', txtExpiresData) then
            if Evaluate(ExpiersDate, txtExpiresData, 9) then
                if ExpiersDate > CreateDateTime(Today, Time) then
                    IsolatedStorage.Get('Token', Token);

        if Token <> '' then Exit;

        Parameters.Add('URL', GetFinastraURL());
        Parameters.Add('Method', 'POST');
        Parameters.Add('Accept', 'application/json');
        Parameters.Add('ContentType', 'application/json');
        Parameters.Add('RequestBody', StrSubstNo('{"apiKey":"%1","secret":"%2"}', SecService.GetApiKey(), SecService.GetApiSecret()));
        if CallWebService(Parameters) then begin
            if Parameters.ContainsKey('HttpStatusCode') then begin
                if Parameters.Get('ResponseBody', ResponseBody) then begin
                    if JsonObj.ReadFrom(ResponseBody) then begin
                        if JsonObj.SelectToken('$.token', JsonTok) then begin
                            Token := JsonTok.AsValue().AsText();
                            IsolatedStorage.Set('Token', Token, DataScope::Module);
                            ExpiersDate := CreateDateTime(Today, Time + (60000 * 60 * 2));
                            IsolatedStorage.Set('ExpiresDate', FORMAT(ExpiersDate, 0, 9), DataScope::Module);
                        end;
                    end;
                end;
            end else
                ResponseBody := '';
        end;
    end;

    //Request from Finastra API
    //Return json file 
    // if ok {"banks":["url":"https://b","picture":"https://i","description":"d"]}
    // else {"error":"message"}
    local procedure CallBanks(): JsonObject
    var
        Parameters: Dictionary of [text, text];
        json: JsonObject;
        ResponseBody: text;
    begin
        Parameters.Add('URL', GetFinastraURL());
        Parameters.Add('Method', 'POST');
        Parameters.Add('Accept', 'application/json');
        Parameters.Add('Authorization', StrSubstNo('Bearer %1', GetAuthToken()));
        Parameters.Add('ContentType', 'application/json');
        //todo Body 
        //Parameters.Add('RequestBody', RequestBodyTxt);
        if not TestMode then begin
            if not CallWebService(Parameters) then
                if ResponseBodyAsJson(Parameters, json) then Exit(json)
        end else begin
            if json.readfrom(TestJson) then
                exit(json);
        end;
        exit(json);
    end;

    local procedure TestJson(): text
    begin
        /*exit(
            '{"banks":[' +
                '{' +
                '"url":"https://jupiterbank.uat.businesswebcenter.com/home",' +
                '"picture":"https://upload.wikimedia.org/wikipedia/commons/2/20/Bank_of_America_logo.svg",' +
                '"description":"The Bank of America Corporation is an American multinational investment bank and financial services holding company headquartered in Charlotte, North Carolina. The bank was founded in San Francisco and took its present form when NationsBank of Charlotte acquired it in 1998. It is the second-largest banking institution in the United States, after JPMorgan Chase, and the eighth-largest bank in the world. Bank of America is one of the Big Four banking institutions of the United States. It serves approximately 10.73% of all American bank deposits, in direct competition with JPMorgan Chase, Citigroup, and Wells Fargo. Its primary financial services revolve around commercial banking, wealth management, and investment banking."' +
                '},' +
                '{' +
                '"url":"https://jupiterbank.uat.businesswebcenter.com/home",' +
                '"picture":"https://upload.wikimedia.org/wikipedia/commons/a/aa/HSBC_logo_%282018%29.svg",' +
                '"description":"HSBC Bank USA, National Association, an American subsidiary of UK-based HSBC, is a bank with its operational head office in New York City and its nominal head office in McLean, Virginia (as designated on its charter). HSBC Bank USA, N.A. is a national bank chartered under the National Bank Act, and thus is regulated by the Office of the Comptroller of the Currency (OCC), a part of the U.S. Department of the Treasury. The company has 159 branch locations. "' +
                '},' +
                '{' +
                '"url":"https://jupiterbank.uat.businesswebcenter.com/home",' +
                '"picture":"https://upload.wikimedia.org/wikipedia/commons/1/1d/Citibank.svg",' +
                '"description":"Citibank is the consumer division of financial services multinational Citigroup. Citibank was founded in 1812 as the City Bank of New York, and later became First National City Bank of New York. The bank has 2,649 branches in 19 countries, including 723 branches in the United States and 1,494 branches in Mexico operated by its subsidiary Banamex."' +
                '}' +
            ']' +
            '}'
        );*/
        exit(
            '{"banks":[' +
                '{' +
                '"url":"https://jupitercu.qa.businesswebcenter.com/home",' +
                '"picture":"",' +
                '"description":"Jupiter Bank Credit Union is a multinational banking and financial services organization. Jupiter Bank Credit Union international network comprises around 7,500 offices in over 80 countries and territories in Europe, the Asia-Pacific region, the Americas, the Middle East and Africa."' +
                '},' +
                '{' +
                '"url":"https://jupiterbank.qa.businesswebcenter.com/home",' +
                '"picture":"https://jupiterbank.qa.businesswebcenter.com//configuration/image/logo",' +
                '"description":"Jupiter Bank Credit Union is a multinational banking and financial services organization. Jupiter Bank Credit Union international network comprises around 7,500 offices in over 80 countries and territories in Europe, the Asia-Pacific region, the Americas, the Middle East and Africa."' +
                '}' +
            ']' +
            '}'
        );
    end;
}
