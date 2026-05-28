sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"c4s/mdg/mdgsearch/test/integration/pages/BusinessPartnerSearchList",
	"c4s/mdg/mdgsearch/test/integration/pages/BusinessPartnerSearchObjectPage"
], function (JourneyRunner, BusinessPartnerSearchList, BusinessPartnerSearchObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('c4s/mdg/mdgsearch') + '/test/flp.html#app-preview',
        pages: {
			onTheBusinessPartnerSearchList: BusinessPartnerSearchList,
			onTheBusinessPartnerSearchObjectPage: BusinessPartnerSearchObjectPage
        },
        async: true
    });

    return runner;
});

