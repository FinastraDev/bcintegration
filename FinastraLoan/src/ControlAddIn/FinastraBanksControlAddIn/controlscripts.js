function Render(html)
{
    $('div#controlAddIn').html(html);
    $('*[data-href]').on('click', function() {
      OpenInNewTab($(this).data("href"));
    });
    $("[src='defaultlogo']").attr("src",Microsoft.Dynamics.NAV.GetImageResource("src/ControlAddIn/FinastraBanksControlAddIn/logo.png"));
}

/*function OpenInFrame(url){
    $('#table').hide();
    $('#bcinfo').show();
    $('#tenantid').html('TenantId: '+TenantId);
    $('#environmentname').html('EnvironmentName: '+EnvironmentName);
    $('#companyid').html('CompanyId: '+CompanyId);
    $('#inframe').show();
    $('#inframe').attr("src", url);
}*/

function OpenInNewTab(url){
  window.open(url, '_blank');
}

function SessionParameters(BcTenantId,BcEnvironmentName,BcCompanyId){
    TenantId = BcTenantId;
    EnvironmentName = BcEnvironmentName;
    CompanyId = BcCompanyId;
}

