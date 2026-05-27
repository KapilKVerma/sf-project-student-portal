import { LightningElement, api, track } from "lwc";
import LightningAlert from "lightning/alert";
import { RefreshEvent } from "lightning/refresh";
import getStudent from "@salesforce/apex/enroll360StudentController.getStudent";
import updateStudent from "@salesforce/apex/enroll360StudentController.updateStudent";

export default class Enroll360StudentUSIVerify extends LightningElement {
  @api recordId;
  @track studentUSI;
  @track studentUSIVerified = false;

  async connectedCallback() {
    try {
      if (!this.recordId) {
        await LightningAlert.open({
          message: "recordId is undefined",
          theme: "error",
          label: "System Alert"
        });
      }

      const studentDetails = await getStudent({ studentId: this.recordId });

      if (studentDetails) {
        this.studentUSI = studentDetails.Unique_Student_Identifier__c;
        this.studentUSIVerified = studentDetails.USI_Verified__c;
      }
    } catch (error) {
      await LightningAlert.open({
        message: `${error?.message || error?.body?.message}`,
        theme: "error",
        label: "System Alert"
      });
    }
  }

  async handleVerfication() {
    try {
      if (!this.recordId) {
        await LightningAlert.open({
          message: "recordId is undefined",
          theme: "error",
          label: "System Alert"
        });
      }

      const updateUSIVerificationStatus = await updateStudent({
        student: {
          Id: this.recordId,
          USI_Verified__c: !this.studentUSIVerified
        }
      });

      if (updateUSIVerificationStatus) {
        this.studentUSIVerified = updateUSIVerificationStatus.USI_Verified__c;
        this.dispatchEvent(new RefreshEvent());

        await LightningAlert.open({
          message: `Verification Completed`,
          theme: "success",
          label: "System Alert"
        });
      }
    } catch (error) {
      await LightningAlert.open({
        message: `${error?.message || error?.body?.message}`,
        theme: "error",
        label: "System Alert"
      });
    }
  }
}
