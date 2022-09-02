import { api, LightningElement } from "lwc";

export default class CustomAlertEditor extends LightningElement {
  _inputVariables = [];
  @api
  get inputVariables() {
    return this._inputVariables;
  }

  set inputVariables(variables) {
    this._inputVariables = variables;
  }

  get variant() {
    const param = this.inputVariables.find(({ name }) => name === "variant");
    return param && param.value;
  }

  get options() {
    return [
      {
        label: "Warning",
        value: "slds-alert_warning"
      },
      {
        label: "Error",
        value: "slds-alert_error"
      },
      {
        label: "Offline",
        value: "slds-alert_offline"
      }
    ];
  }

  handleChange(event) {
    if (event && event.detail) {
      const newValue = event.detail.value;
      const valueChangedEvent = new CustomEvent(
        "configuration_editor_input_value_changed",
        {
          bubbles: true,
          cancelable: false,
          composed: true,
          detail: {
            name: "variant",
            newValue,
            newValueDataType: "String"
          }
        }
      );
      this.dispatchEvent(valueChangedEvent);
    }
  }
}