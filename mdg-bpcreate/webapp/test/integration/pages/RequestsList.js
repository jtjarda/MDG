sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'c4p.mdg.mdgbpcreate',
            componentId: 'RequestsList',
            contextPath: '/Requests'
        },
        CustomPageDefinitions
    );
});