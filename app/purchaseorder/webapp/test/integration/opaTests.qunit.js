sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'mycap/po/purchaseorder/test/integration/FirstJourney',
		'mycap/po/purchaseorder/test/integration/pages/POsList',
		'mycap/po/purchaseorder/test/integration/pages/POsObjectPage',
		'mycap/po/purchaseorder/test/integration/pages/POItemsObjectPage'
    ],
    function(JourneyRunner, opaJourney, POsList, POsObjectPage, POItemsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('mycap/po/purchaseorder') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onThePOsList: POsList,
					onThePOsObjectPage: POsObjectPage,
					onThePOItemsObjectPage: POItemsObjectPage
                }
            },
            opaJourney.run
        );
    }
);