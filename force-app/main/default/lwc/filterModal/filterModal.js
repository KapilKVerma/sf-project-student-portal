import { LightningElement, api } from "lwc";
import LightningModal from "lightning/modal";

export default class FilterModal extends LightningModal {
  @api content;

  handleOkay() {
    this.close("okay");
  }

  handleClose() {
    this.close("cancel");
  }

  handleApply() {
    // you can return data later
    this.close("apply");
  }
}
