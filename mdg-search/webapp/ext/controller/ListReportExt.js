sap.ui.define(
    [
        "sap/m/MessageBox",
        "sap/m/SelectDialog",
        "sap/m/StandardListItem",
        "sap/ui/model/Filter",
        "sap/ui/model/FilterOperator",
        "sap/ui/model/json/JSONModel"
    ],
    function (MessageBox, SelectDialog, StandardListItem, Filter, FilterOperator, JSONModel) {
    "use strict";

    var oCreateForSystemDialog;

    function getCreateSystemModel() {
        return new JSONModel({
            systems: [
                {
                    ExternalSystem: "S4HCLNT140",
                    Description: "S/4HANA Client 140"
                },
                {
                    ExternalSystem: "SAPCLNT100",
                    Description: "SAP Client 100"
                }
            ]
        });
    }

    function navigateToCreateApp(sExternalSystem) {
        if (!sExternalSystem) {
            return;
        }

        if (!sap.ushell || !sap.ushell.Container) {
            window.location.hash = "MDGBpRequest-create?ExternalSystem=" + encodeURIComponent(sExternalSystem);
            return;
        }

        sap.ushell.Container.getServiceAsync("CrossApplicationNavigation")
            .then(function (oCrossAppNavigation) {
                oCrossAppNavigation.toExternal({
                    target: {
                        semanticObject: "MDGBpRequest",
                        action: "create"
                    },
                    params: {
                        ExternalSystem: [sExternalSystem]
                    }
                });
            })
            .catch(function () {
                MessageBox.error("Navigation to BP request creation could not be started.");
            });
    }

    function getView(oController) {
        if (oController.editFlow && oController.editFlow.getView) {
            return oController.editFlow.getView();
        }

        if (oController.getView) {
            return oController.getView();
        }

        return null;
    }

    function getCreateForSystemDialog(oController) {
        if (oCreateForSystemDialog) {
            return oCreateForSystemDialog;
        }

        oCreateForSystemDialog = new SelectDialog({
            title: "Select: External System",
            noDataText: "No systems available",
            search: function (oEvent) {
                var sValue = oEvent.getParameter("value");
                var oBinding = oEvent.getSource().getBinding("items");

                oBinding.filter([
                    new Filter({
                        filters: [
                            new Filter("ExternalSystem", FilterOperator.Contains, sValue),
                            new Filter("Description", FilterOperator.Contains, sValue)
                        ],
                        and: false
                    })
                ]);
            },
            confirm: function (oEvent) {
                var oSelectedItem = oEvent.getParameter("selectedItem");

                if (!oSelectedItem) {
                    return;
                }

                navigateToCreateApp(oSelectedItem.getBindingContext().getProperty("ExternalSystem"));
            }
        });

        oCreateForSystemDialog.setModel(getCreateSystemModel());
        oCreateForSystemDialog.bindAggregation("items", {
            path: "/systems",
            template: new StandardListItem({
                title: "{ExternalSystem}",
                description: "{Description}"
            })
        });

        var oView = getView(oController);

        if (oView) {
            oView.addDependent(oCreateForSystemDialog);
        }

        return oCreateForSystemDialog;
    }

    return {
        onCreateForSystem: function () {
            getCreateForSystemDialog(this).open();
        }
    };
});
