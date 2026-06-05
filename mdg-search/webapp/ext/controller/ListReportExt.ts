/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-argument */
/* eslint-disable no-use-before-define, @sap-ux/fiori-tools/sap-no-hardcoded-url, @sap-ux/fiori-tools/sap-no-localhost */
/* eslint-disable @sap-ux/fiori-tools/sap-no-location-usage */
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
    let sSelectedPartnerGidForRequest = "";
    let sSelectedSystemPath = "/CreateSystems";
    const sLocalCreateAppUrl = "http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview";

    function navigateToCreateApp(sExternalSystem?: string, sPartnerGid?: string) {
        if (!sExternalSystem && !sPartnerGid) {
            return;
        }

        if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
            window.location.href = addRequestParameters(sLocalCreateAppUrl, sExternalSystem, sPartnerGid);
            return;
        }

        const oShellContainer = (sap as any).ushell?.Container;

        if (!oShellContainer) {
            window.location.hash = "MDGBpRequest-create" + getRequestParameterQuery(sExternalSystem, sPartnerGid);
            return;
        }

        oShellContainer.getServiceAsync("CrossApplicationNavigation")
            .then(function (oCrossAppNavigation: any) {
                const mParams: Record<string, string[]> = {};

                if (sExternalSystem) {
                    mParams.ExternalSystem = [sExternalSystem];
                }

                if (sPartnerGid) {
                    mParams.PartnerGID = [sPartnerGid];
                }

                oCrossAppNavigation.toExternal({
                    target: {
                        semanticObject: "MDGBpRequest",
                        action: "create"
                    },
                    params: mParams
                });
            })
            .catch(function (): void {
                MessageBox.error("Navigation to BP request creation could not be started.");
            });
    }

    function addRequestParameters(sUrl: string, sExternalSystem?: string, sPartnerGid?: string): string {
        const aParts = sUrl.split("#");
        const sBaseUrl = aParts[0];
        const sHash = aParts[1] ? "#" + aParts[1] : "";
        const sQuery = getRequestParameterQuery(sExternalSystem, sPartnerGid);

        if (!sQuery) {
            return sUrl;
        }

        return sBaseUrl + (sBaseUrl.indexOf("?") === -1 ? "?" : "&") + sQuery.substring(1) + sHash;
    }

    function getRequestParameterQuery(sExternalSystem?: string, sPartnerGid?: string): string {
        const aParameters: string[] = [];

        if (sExternalSystem) {
            aParameters.push("ExternalSystem=" + encodeURIComponent(sExternalSystem));
        }

        if (sPartnerGid) {
            aParameters.push("PartnerGID=" + encodeURIComponent(sPartnerGid));
        }

        return aParameters.length ? "?" + aParameters.join("&") : "";
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

    function getSystemFilters(sValue?: string): any[] {
        const aFilters: any[] = [];

        if (sSelectedSystemPath === "/ChangeSystems") {
            aFilters.push(
                new Filter({
                    filters: [
                        new Filter("PartnerGID", FilterOperator.EQ, ""),
                        new Filter("PartnerGID", FilterOperator.EQ, sSelectedPartnerGidForRequest)
                    ],
                    and: false
                })
            );
        }

        if (!sValue) {
            return aFilters;
        }

        aFilters.push(
            new Filter({
                filters: [
                    new Filter("ExternalSystem", FilterOperator.Contains, sValue),
                    new Filter("Description", FilterOperator.Contains, sValue)
                ],
                and: false
            })
        );

        return aFilters;
    }

    function getCurrentPartnerGid(oController: any, oEvent?: any): string {
        const oSourceContext = oEvent?.getSource?.().getBindingContext?.();
        const oViewContext = getView(oController)?.getBindingContext?.();
        const oContext = oSourceContext || oViewContext;
        const sPartnerGid = oContext?.getProperty?.("PartnerGID") as string | undefined;

        return sPartnerGid || "";
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

                oBinding.filter(getSystemFilters(sValue));
            },
            confirm: function (oEvent: any): void {
                const oSelectedItem = oEvent.getParameter("selectedItem");

                if (!oSelectedItem) {
                    return;
                }

                navigateToCreateApp(
                    oSelectedItem.getBindingContext("create").getProperty("ExternalSystem"),
                    sSelectedPartnerGidForRequest
                );
            }
        });

        bindSystemDialogItems(oCreateForSystemDialog);

        const oView = getView(oController);

        if (oView) {
            oView.addDependent(oCreateForSystemDialog);
        }

        return oCreateForSystemDialog;
    }

    function bindSystemDialogItems(oDialog: any): void {
        oDialog.bindAggregation("items", {
            path: "create>" + sSelectedSystemPath,
            filters: getSystemFilters(),
            parameters: {
                $orderby: "Description"
            },
            template: new StandardListItem({
                title: "{create>Description}"
            })
        });
    }

    return {
        onCreateForSystem: function (): void {
            sSelectedPartnerGidForRequest = "";
            sSelectedSystemPath = "/CreateSystems";

            const oDialog = getCreateForSystemDialog(this);
            bindSystemDialogItems(oDialog);
            oDialog.open();
        },

        onChange: function (oEvent: any): void {
            const sPartnerGid = getCurrentPartnerGid(this, oEvent);

            if (!sPartnerGid) {
                MessageBox.error("Business partner ID could not be determined.");
                return;
            }

            sSelectedPartnerGidForRequest = sPartnerGid;
            sSelectedSystemPath = "/ChangeSystems";

            const oDialog = getCreateForSystemDialog(this);
            bindSystemDialogItems(oDialog);
            oDialog.open();
        }
    };
});
