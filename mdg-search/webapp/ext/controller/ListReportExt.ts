/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-argument */
/* eslint-disable no-use-before-define, @sap-ux/fiori-tools/sap-no-hardcoded-url, @sap-ux/fiori-tools/sap-no-localhost */
/* eslint-disable @sap-ux/fiori-tools/sap-no-location-usage */
sap.ui.define(
    [
        "sap/m/MessageBox",
        "sap/m/SelectDialog",
        "sap/m/StandardListItem",
        "sap/ui/core/BusyIndicator",
        "sap/ui/model/Filter",
        "sap/ui/model/FilterOperator"
    ],
    function (MessageBox, SelectDialog, StandardListItem, BusyIndicator, Filter, FilterOperator) {
    "use strict";

    let sSelectedPartnerGidForRequest = "";
    let sSelectedSystemPath = "/CreateSystems";
    const sLocalCreateAppUrl = "http://localhost:8080/test/flp.html?sap-ui-xx-viewCache=false#app-preview";

    function getText(oController: any, sKey: string): string {
        const oResourceBundle = getView(oController)?.getModel?.("i18n")?.getResourceBundle?.();

        return oResourceBundle?.getText?.(sKey) || sKey;
    }

    function createRequestDraft(oController: any, sExternalSystem?: string, sPartnerGid?: string): void {
        if (!sExternalSystem && !sPartnerGid) {
            return;
        }

        const oCreateModel = getView(oController)?.getModel?.("create");

        if (!oCreateModel) {
            MessageBox.error(getText(oController, "createRequestDraftFailed"));
            return;
        }

        const oRequestsBinding = oCreateModel.bindList("/Requests");
        const oOperation = oCreateModel.bindContext(
            "com.sap.gateway.srvd.zui_mdg_req.v0001.CreateRequest(...)",
            oRequestsBinding.getHeaderContext()
        );

        oOperation.setParameter("ExternalSystem", sExternalSystem || "");
        oOperation.setParameter("PartnerGID", sPartnerGid || "");
        oOperation.setParameter("ResultIsActiveEntity", false);

        BusyIndicator.show(0);

        oOperation.execute()
            .then(function () {
                const oContext = oOperation.getBoundContext();

                if (!oContext) {
                    throw new Error("CreateRequest did not return a request context.");
                }

                return oContext.requestObject();
            })
            .then(function (oRequest: { RequestUuid?: string; IsActiveEntity?: boolean }) {
                if (!oRequest || !oRequest.RequestUuid) {
                    throw new Error("CreateRequest did not return RequestUuid.");
                }

                navigateToCreatedDraft(oController, oRequest.RequestUuid, oRequest.IsActiveEntity);
            })
            .catch(function (oError: Error): void {
                MessageBox.error(getText(oController, "createRequestDraftFailed"), {
                    details: oError && (oError.message || String(oError))
                });
            })
            .finally(function (): void {
                BusyIndicator.hide();
            });
    }

    function navigateToCreatedDraft(oController: any, sRequestUuid: string, bIsActiveEntity?: boolean): void {
        const sAppSpecificRoute = "&/Requests(RequestUuid=" + sRequestUuid +
            ",IsActiveEntity=" + (bIsActiveEntity === true ? "true" : "false") + ")";

        if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
            window.location.href = sLocalCreateAppUrl + sAppSpecificRoute;
            return;
        }

        const oShellContainer = (sap as any).ushell?.Container;

        if (!oShellContainer) {
            window.location.hash = "#MDGBpRequest-create" + sAppSpecificRoute;
            return;
        }

        oShellContainer.getServiceAsync("CrossApplicationNavigation")
            .then(function (oCrossAppNavigation: any) {
                oCrossAppNavigation.toExternal({
                    target: {
                        semanticObject: "MDGBpRequest",
                        action: "create"
                    },
                    appSpecificRoute: sAppSpecificRoute
                });
            })
            .catch(function (): void {
                MessageBox.error(getText(oController, "navigationToCreateFailed"));
            });
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
        const oCreateForSystemDialog = new SelectDialog({
            title: getText(oController, "selectExternalSystem"),
            noDataText: getText(oController, "noSystemsAvailable"),
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

                createRequestDraft(
                    oController,
                    oSelectedItem.getBindingContext("create").getProperty("ExternalSystem"),
                    sSelectedPartnerGidForRequest
                );
            },
            afterClose: function (oEvent: any): void {
                oEvent.getSource().destroy();
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
            oDialog.setTitle(getText(this, "selectExternalSystem"));
            oDialog.setNoDataText(getText(this, "noSystemsAvailable"));
            bindSystemDialogItems(oDialog);
            oDialog.open();
        },

        onChange: function (oEvent: any): void {
            const sPartnerGid = getCurrentPartnerGid(this, oEvent);

            if (!sPartnerGid) {
                MessageBox.error(getText(this, "partnerGidMissing"));
                return;
            }

            sSelectedPartnerGidForRequest = sPartnerGid;
            sSelectedSystemPath = "/ChangeSystems";

            const oDialog = getCreateForSystemDialog(this);
            oDialog.setTitle(getText(this, "selectExternalSystem"));
            oDialog.setNoDataText(getText(this, "noSystemsAvailable"));
            bindSystemDialogItems(oDialog);
            oDialog.open();
        }
    };
});
