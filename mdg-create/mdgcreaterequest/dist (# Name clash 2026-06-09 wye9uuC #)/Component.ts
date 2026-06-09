/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-return */
sap.ui.define(
    ["sap/fe/core/AppComponent", "sap/m/MessageBox"],
    function (Component: any, MessageBox: any) {
        "use strict";

        return Component.extend("c4p.mdg.mdgcreaterequest.Component", {
            metadata: {
                manifest: "json"
            },

            init: function () {
                Component.prototype.init.apply(this, arguments);
                this._handleStartupCreateRequest();
            },

            _getStartupParameter: function (sParameterName: string): string | null {
                const oComponentData = this.getComponentData && this.getComponentData();
                const oStartupParameters = oComponentData && oComponentData.startupParameters;
                const vParameter = oStartupParameters && oStartupParameters[sParameterName];

                if (Array.isArray(vParameter)) {
                    return vParameter[0];
                }

                if (vParameter) {
                    return vParameter;
                }

                return new URLSearchParams(window.location.search).get(sParameterName) ||
                    new URLSearchParams(window.location.hash.split("?")[1] || "").get(sParameterName);
            },

            _handleStartupCreateRequest: function (): void {
                const sExternalSystem = this._getStartupParameter("ExternalSystem");
                const sPartnerGid = this._getStartupParameter("PartnerGID") ||
                    this._getStartupParameter("PartnerGid");

                if ((!sExternalSystem && !sPartnerGid) || this._bStartupCreateRequestHandled || window.location.hash.indexOf("&/Requests(") > -1) {
                    return;
                }

                this._bStartupCreateRequestHandled = true;

                this.getModel().getMetaModel().requestObject("/")
                    .then(function () {
                        return this._createRequest(sExternalSystem, sPartnerGid);
                    }.bind(this))
                    .catch(function (oError: Error) {
                        MessageBox.error(
                            this._getText("createRequestDraftFailed"),
                            {
                                details: oError && (oError.message || String(oError))
                            }
                        );
                    }.bind(this));
            },

            _getText: function (sKey: string): string {
                const oResourceBundle = this.getModel("i18n")?.getResourceBundle?.();

                return oResourceBundle?.getText?.(sKey) || sKey;
            },

            _createRequest: function (sExternalSystem?: string, sPartnerGid?: string): Promise<void> {
                return this._executeCreateRequest(sExternalSystem, sPartnerGid);
            },

            _executeCreateRequest: function (sExternalSystem?: string, sPartnerGid?: string): Promise<void> {
                const oModel = this.getModel();
                const oRequestsBinding = oModel.bindList("/Requests");
                const oOperation = oModel.bindContext(
                    "com.sap.gateway.srvd.zui_mdg_req.v0001.CreateRequest(...)",
                    oRequestsBinding.getHeaderContext()
                );

                oOperation.setParameter("ExternalSystem", sExternalSystem || "");
                oOperation.setParameter("PartnerGID", sPartnerGid || "");
                oOperation.setParameter("ResultIsActiveEntity", false);

                return oOperation.execute().then(function () {
                    const oContext = oOperation.getBoundContext();

                    if (!oContext) {
                        throw new Error("CreateRequest did not return a request context.");
                    }

                    return oContext.requestObject().then(function (oRequest: { RequestUuid?: string; IsActiveEntity?: boolean }) {
                        if (!oRequest || !oRequest.RequestUuid) {
                            throw new Error("CreateRequest did not return RequestUuid.");
                        }

                        this._navigateToRequestByKey(oRequest.RequestUuid, oRequest.IsActiveEntity);
                    }.bind(this));
                }.bind(this));
            },

            _navigateToRequestByKey: function (sRequestUuid: string, bIsActiveEntity?: boolean): void {
                this._navigateToRequest(
                    "/Requests(RequestUuid=" + sRequestUuid +
                    ",IsActiveEntity=" + (bIsActiveEntity === true ? "true" : "false") + ")"
                );
            },

            _navigateToRequest: function (sCanonicalPath: string): void {
                const sKeyPredicate = sCanonicalPath
                    .replace(/^\/Requests\(/, "")
                    .replace(/\)$/, "");
                const oRouter = this.getRouter && this.getRouter();

                if (oRouter) {
                    oRouter.navTo("RequestsObjectPage", {
                        key: sKeyPredicate
                    }, true);
                }
            }
        });
    }
);
