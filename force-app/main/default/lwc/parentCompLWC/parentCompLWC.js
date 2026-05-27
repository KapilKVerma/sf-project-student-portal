import { LightningElement } from "lwc";

export default class ParentCompLWC extends LightningElement {
  parentMessage;
  childMessage;

  handleClick() {
    this.parentMessage = "Hello! How are you child?";
  }

  handleMessageFromChild(event) {
    this.childMessage = event.detail.message;
  }
}
