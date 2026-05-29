sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"c4p/mdg/mdgbpcreate/test/integration/pages/RequestsList",
	"c4p/mdg/mdgbpcreate/test/integration/pages/RequestsObjectPage"
], function (JourneyRunner, RequestsList, RequestsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('c4p/mdg/mdgbpcreate') + '/test/flp.html#app-preview',
        pages: {
			onTheRequestsList: RequestsList,
			onTheRequestsObjectPage: RequestsObjectPage
        },
        async: true
    });

    return runner;
});

