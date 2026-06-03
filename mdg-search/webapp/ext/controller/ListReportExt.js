sap.ui.define(
    [
        "sap/m/MessageBox",
        "sap/m/SelectDialog",
        "sap/m/StandardListItem",
        "sap/ui/model/Filter",
        "sap/ui/model/FilterOperator"
    ],
    function (MessageBox, SelectDialog, StandardListItem, Filter, FilterOperator) {
    "use strict";

    var oCreateForSystemDialog;
    var sLocalCreateAppUrl = "http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview";

    function navigateToCreateApp(sExternalSystem) {
        if (!sExternalSystem) {
            return;
        }

        if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
            window.location.href = addExternalSystemParameter(sLocalCreateAppUrl, sExternalSystem);
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

    function addExternalSystemParameter(sUrl, sExternalSystem) {
        var aParts = sUrl.split("#");
        var sBaseUrl = aParts[0];
        var sHash = aParts[1] ? "#" + aParts[1] : "";
        var sSeparator = sBaseUrl.indexOf("?") === -1 ? "?" : "&";

        return sBaseUrl + sSeparator + "ExternalSystem=" + encodeURIComponent(sExternalSystem) + sHash;
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

    function getCreateSystemFilters(sValue) {
        if (!sValue) {
            return [];
        }

        return [
            new Filter({
                filters: [
                    new Filter("ExternalSystem", FilterOperator.Contains, sValue),
                    new Filter("Description", FilterOperator.Contains, sValue)
                ],
                and: false
            })
        ];
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

                oBinding.filter(getCreateSystemFilters(sValue));
            },
            confirm: function (oEvent) {
                var oSelectedItem = oEvent.getParameter("selectedItem");

                if (!oSelectedItem) {
                    return;
                }

                navigateToCreateApp(oSelectedItem.getBindingContext("create").getProperty("ExternalSystem"));
            }
        });

        oCreateForSystemDialog.bindAggregation("items", {
            path: "create>/CreateSystems",
            filters: getCreateSystemFilters(),
            parameters: {
                $orderby: "Description"
            },
            template: new StandardListItem({
                title: "{create>Description}"
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
