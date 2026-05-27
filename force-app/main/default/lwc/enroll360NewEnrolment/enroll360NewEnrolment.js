import { LightningElement, wire, track } from "lwc";
import LightningAlert from "lightning/alert";
import getCourses from "@salesforce/apex/enroll360CourseController.getCourses";
import newEnrolmentSubmission from "@salesforce/apex/enroll360EnrolmentController.newEnrolmentSubmission";

export default class Enroll360NewEnrolment extends LightningElement {
  @track courseOptions = [];
  @track selectedCourseId;
  @track courseDuration;
  coursesList;
  enrolmentDetails = {
    studentFirstName: "",
    studentLastName: "",
    studentPhoneNumber: "",
    studentEmail: "",
    studentDob: "",
    studentAddress: "",
    studentCourseId: "",
    studentCourseDuration: "",
    studentEnrolmentDate: "",
    studentUSI: ""
  };
  error;

  // Validation rules
  validationsRules = {
    studentFirstName: (value) => {
      if (!value) return "First name is required";
      if (value.length < 2) return "Minimum 2 characters required";
      return null;
    },
    studentLastName: (value) => {
      if (!value) return "Last name is required";
      if (value.length < 2) return "Minimum 2 characters required";
      return null;
    },
    studentPhoneNumber: (value) => {
      if (!value) return "Phone number is required";
      const phoneRegex = /^[0-9+\-\s()]{8,15}$/;
      if (!phoneRegex.test(value)) {
        return "Enter a valid phone number";
      }
      return null;
    },
    studentEmail: (value) => {
      if (!value) return "Email is required";
      const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!regex.test(value)) return "Invalid email format";
      return null;
    },
    studentDob: (value) => {
      if (!value) return "Date of birth is required";
      const today = new Date();
      const dob = new Date(value);
      if (dob >= today) {
        return "Date of birth must be in the past";
      }
      return null;
    },
    studentAddress: (value) => {
      if (!value) return "Address is required";
      if (value.length < 10) return "Minimum 10 characters required";
      return null;
    },
    studentCourseId: (value) => {
      if (!value) return "Please select a course";
      return null;
    },
    studentEnrolmentDate: (value) => {
      if (!value) return "Enrolment date is required";
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const enrolmentDate = new Date(value);
      enrolmentDate.setHours(0, 0, 0, 0);

      if (enrolmentDate < today) {
        return "Enrolment date must be in the future";
      }
      return null;
    },
    studentUSI: (value) => {
      if (!value) return "Unique Student Identifier is required";
      if (value.length !== 10) return "Minimum 10 characters required";
      return null;
    }
  };

  @wire(getCourses)
  wiredCourses({ data, error }) {
    if (data) {
      this.courseOptions = data.map((course) => ({
        label: `${course.Name} (${course.Course_Code__c})`,
        value: course.Id
      }));
      this.coursesList = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.courseOptions = [];
    }
  }

  handleFieldChange(event) {
    const { name, value } = event.target;
    this.enrolmentDetails = { ...this.enrolmentDetails, [name]: value };
  }

  handleSelectChange(event) {
    this.enrolmentDetails.studentCourseId = event.detail.value;

    const selectedCourse = this.coursesList.find(
      (course) => course.Id === event.detail.value
    );

    if (selectedCourse) {
      this.courseDuration = selectedCourse.Duration__c;
      this.enrolmentDetails.studentCourseDuration = selectedCourse.Duration__c;
    } else {
      this.enrolmentDetails.studentCourseDuration = "";
    }
  }

  validateForm() {
    let isValid = true;

    Object.keys(this.validationsRules).forEach((fieldName) => {
      const field = this.template.querySelector(`[data-field="${fieldName}"]`);
      const value = this.enrolmentDetails[fieldName];

      if (field) {
        const errorMessage = this.validationsRules[fieldName](value);

        if (errorMessage) {
          field.setCustomValidity(errorMessage);
          isValid = false;
        } else {
          field.setCustomValidity("");
        }
        field.reportValidity();
      }
    });

    return isValid;
  }

  async handleEnrolmentSubmission() {
    // Field validation
    const isValid = this.validateForm();
    if (!isValid) {
      return;
    }

    try {
      // Enrolment Form Submission
      newEnrolmentSubmission({ ...this.enrolmentDetails });

      await LightningAlert.open({
        message: `New enrolment has been registered.`,
        theme: "success",
        label: "System Alert"
      });
    } catch (error) {
      await LightningAlert.open({
        message: `${error?.message}`,
        theme: "error",
        label: "System Alert"
      });
    }
  }
}
