sap.ui.define(["sap/ui/model/Filter", "sap/ui/model/FilterOperator"], function (Filter, FilterOperator) {
    "use strict";

    return {
        onAddressNameContains: function (vValue: string | string[] | null | undefined) {
            let sValue = Array.isArray(vValue) ? vValue[0] : vValue;

            if (!sValue || !String(sValue).trim()) {
                return null;
            }

            sValue = String(sValue).trim();

            return new Filter({
                filters: [
                    new Filter({
                        path: "CompanyName",
                        operator: FilterOperator.Contains,
                        value1: sValue
                    }),
                    new Filter({
                        path: "PersonName",
                        operator: FilterOperator.Contains,
                        value1: sValue
                    }),
                    new Filter({
                        path: "_AllAddresses",
                        operator: FilterOperator.Any,
                        variable: "addr",
                        condition: new Filter({
                            filters: [
                                new Filter({
                                    path: "addr/CompanyName",
                                    operator: FilterOperator.Contains,
                                    value1: sValue
                                }),
                                new Filter({
                                    path: "addr/PersonName",
                                    operator: FilterOperator.Contains,
                                    value1: sValue
                                })
                            ],
                            and: false
                        })
                    })
                ],
                and: false
            });
        }
    };
});
