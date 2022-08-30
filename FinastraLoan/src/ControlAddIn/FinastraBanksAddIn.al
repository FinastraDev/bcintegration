controladdin "FLH FinastraBanks"
{
    StartupScript = 'src/ControlAddIn/FinastraBanksControlAddIn/startup.js';
    Scripts =
        'https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js',
        'src/ControlAddIn/FinastraBanksControlAddIn/controlscripts.js';
    Images =
    'src/ControlAddIn/FinastraBanksControlAddIn/logo.png' //js "[src='defaultlogo']"
    ;

    StyleSheets = 'https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css'
        , 'src/ControlAddIn/FinastraBanksControlAddIn/control.css';

    HorizontalStretch = true;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalShrink = true;
    RequestedHeight = 300;
    MinimumHeight = 300;
    //MaximumHeight = 300;
    //RequestedWidth = 600;
    //MinimumWidth = 500;
    //MaximumWidth = 500;


    event ControlReady();

    procedure Render(HTML: text);
    procedure SessionParameters(BcTenantId: text; BcEnvironmentName: text; BcCompanyId: text);
}