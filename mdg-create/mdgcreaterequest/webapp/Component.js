sap.ui.define(
    ["sap/fe/core/AppComponent", "sap/m/MessageBox"],
    function (Component, MessageBox) {
        "use strict";

        return Component.extend("c4p.mdg.mdgcreaterequest.Component", {
            metadata: {
                manifest: "json"
            },

            init: function () {
                Component.prototype.init.apply(this, arguments);
                this._handleStartupCreateForSystem();
            },

            _getStartupParameter: function (sParameterName) {
                var oComponentData = this.getComponentData && this.getComponentData();
                var oStartupParameters = oComponentData && oComponentData.startupParameters;
                var vParameter = oStartupParameters && oStartupParameters[sParameterName];

                if (Array.isArray(vParameter)) {
                    return vParameter[0];
                }

                if (vParameter) {
                    return vParameter;
                }

                return new URLSearchParams(window.location.search).get(sParameterName) ||
                    new URLSearchParams(window.location.hash.split("?")[1] || "").get(sParameterName);
            },

            _handleStartupCreateForSystem: function () {
                var sExternalSystem = this._getStartupParameter("ExternalSystem");

                if (!sExternalSystem || this._bStartupCreateForSystemHandled || window.location.hash.indexOf("&/Requests(") > -1) {
                    return;
                }

                this._bStartupCreateForSystemHandled = true;

                this.getModel().getMetaModel().requestObject("/")
                    .then(function () {
                        return this._createRequestForSystem(sExternalSystem);
                    }.bind(this))
                    .catch(function (oError) {
                        MessageBox.error(
                            "BP request draft could not be created for system " + sExternalSystem + ".",
                            {
                                details: oError && (oError.message || String(oError))
                            }
                        );
                    });
            },

            _createRequestForSystem: function (sExternalSystem) {
                var oModel = this.getModel();
                var oRequestsBinding = oModel.bindList("/Requests");
                var oOperation = oModel.bindContext(
                    "com.sap.gateway.srvd.zui_mdg_req.v0001.CreateForSystem(...)",
                    oRequestsBinding.getHeaderContext()
                );

                oOperation.setParameter("ExternalSystem", sExternalSystem);
                oOperation.setParameter("ResultIsActiveEntity", false);

                return oOperation.execute().then(function () {
                    var oContext = oOperation.getBoundContext();

                    if (!oContext) {
                        throw new Error("CreateForSystem did not return a request context.");
                    }

                    return oContext.requestObject().then(function (oRequest) {
                        if (!oRequest || !oRequest.RequestUuid) {
                            throw new Error("CreateForSystem did not return RequestUuid.");
                        }

                        this._navigateToRequestByKey(oRequest.RequestUuid, oRequest.IsActiveEntity);
                    }.bind(this));
                }.bind(this));
            },

            _navigateToRequestByKey: function (sRequestUuid, bIsActiveEntity) {
                this._navigateToRequest(
                    "/Requests(RequestUuid=" + sRequestUuid +
                    ",IsActiveEntity=" + (bIsActiveEntity === true ? "true" : "false") + ")"
                );
            },

            _navigateToRequest: function (sCanonicalPath) {
                var sKeyPredicate = sCanonicalPath
                    .replace(/^\/Requests\(/, "")
                    .replace(/\)$/, "");
                var oRouter = this.getRouter && this.getRouter();

                if (oRouter) {
                    oRouter.navTo("RequestsObjectPage", {
                        key: encodeURIComponent(sKeyPredicate)
                    }, true);
                }
            }
        });
    }
);
