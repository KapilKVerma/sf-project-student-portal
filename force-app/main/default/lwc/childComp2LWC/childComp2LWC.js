import { LightningElement, api } from "lwc";

export default class ChildComp2LWC extends LightningElement {
  @api parentmessage;

  sendMessage() {
    const event = new CustomEvent("messagefromchild2", {
      detail: {
        message: "Hello! How are you parent? I am child 2"
      }
    });

    this.dispatchEvent(event);
  }
}
