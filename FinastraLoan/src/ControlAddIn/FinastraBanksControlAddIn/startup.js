(function ($) {
    $(document).ready(function () {
        //$('div#controlAddIn').html('Start');
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady",[]);
    });
})(jQuery);
