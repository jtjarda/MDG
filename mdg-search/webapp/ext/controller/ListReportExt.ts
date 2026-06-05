/* eslint-disable @typescript-eslint/no-explicit-any, @sap-ux/fiori-tools/sap-no-hardcoded-url, @sap-ux/fiori-tools/sap-no-localhost, @sap-ux/fiori-tools/sap-no-location-usage */
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

    let oCreateForSystemDialog: any;
    const sLocalCreateAppUrl = "http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview";

    function navigateToCreateApp(sExternalSystem: string) {
        if (!sExternalSystem) {
            return;
        }

        if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
            window.location.href = addExternalSystemParameter(sLocalCreateAppUrl, sExternalSystem);
            return;
        }

        const oShellContainer = (sap as any).ushell?.Container;

        if (!oShellContainer) {
            window.location.hash = "MDGBpRequest-create?ExternalSystem=" + encodeURIComponent(sExternalSystem);
            return;
        }

        oShellContainer.getServiceAsync("CrossApplicationNavigation")
            .then(function (oCrossAppNavigation: any) {
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
            .catch(function (): void {
                MessageBox.error("Navigation to BP request creation could not be started.");
            });
    }

    function addExternalSystemParameter(sUrl: string, sExternalSystem: string): string {
        const aParts = sUrl.split("#");
        const sBaseUrl = aParts[0];
        const sHash = aParts[1] ? "#" + aParts[1] : "";
        const sSeparator = sBaseUrl.indexOf("?") === -1 ? "?" : "&";

        return sBaseUrl + sSeparator + "ExternalSystem=" + encodeURIComponent(sExternalSystem) + sHash;
    }

    function getView(oController: any): any {
        if (oController.editFlow && oController.editFlow.getView) {
            return oController.editFlow.getView();
        }

        if (oController.getView) {
            return oController.getView();
        }

        return null;
    }

    function getCreateSystemFilters(sValue?: string): any[] {
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

    function getCreateForSystemDialog(oController: any): any {
        if (oCreateForSystemDialog) {
            return oCreateForSystemDialog;
        }

        oCreateForSystemDialog = new SelectDialog({
            title: "Select: External System",
            noDataText: "No systems available",
            search: function (oEvent: any): void {
                const sValue = oEvent.getParameter("value") as string;
                const oBinding = oEvent.getSource().getBinding("items");

                oBinding.filter(getCreateSystemFilters(sValue));
            },
            confirm: function (oEvent: any): void {
                const oSelectedItem = oEvent.getParameter("selectedItem");

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

        const oView = getView(oController);

        if (oView) {
            oView.addDependent(oCreateForSystemDialog);
        }

        return oCreateForSystemDialog;
    }

    return {
        onCreateForSystem: function (): void {
            getCreateForSystemDialog(this).open();
        }
    };
});
