/* eslint-disable @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
sap.ui.define(
    [
        "sap/m/MessageBox"
    ],
    function (MessageBox: any) {
        "use strict";

        function getText(oController: any, sKey: string): string {
            const oResourceBundle = oController.getView?.().getModel?.("i18n")?.getResourceBundle?.();

            return oResourceBundle?.getText?.(sKey) || sKey;
        }

        return {
            onNavigateToSearch: function (): void {
                const oShellContainer = (sap as any).ushell?.Container;

                if (!oShellContainer) {
                    window.location.hash = "#ZMDGBusinessPartner-search";
                    return;
                }

                oShellContainer.getServiceAsync("CrossApplicationNavigation")
                    .then(function (oCrossAppNavigation: any): void {
                        oCrossAppNavigation.toExternal({
                            target: {
                                semanticObject: "ZMDGBusinessPartner",
                                action: "search"
                            }
                        });
                    })
                    .catch(function (): void {
                        MessageBox.error(getText(this, "navigationToSearchFailed"));
                    }.bind(this));
            }
        };
    }
);
