import { LightningElement, api } from "lwc";

export default class ChildCompLWC extends LightningElement {
  @api parentmessage;

  sendMessageToParent() {
    // Custom event that is catch by parent component
    const event = new CustomEvent("messagefromchild", {
      detail: {
        message: "Hello! How are you parent?"
      }
    });
    this.dispatchEvent(event);
  }
}
