sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'c4s.mdg.mdgsearch',
            componentId: 'BusinessPartnerSearchList',
            contextPath: '/BusinessPartnerSearch'
        },
        CustomPageDefinitions
    );
});