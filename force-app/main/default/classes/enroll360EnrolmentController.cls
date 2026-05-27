public with sharing class enroll360EnrolmentController {
  public class NewEnrolmentRequest {
    // Salesforce:
    // Converts the JS object → JSON
    // Sends it to Apex
    // Maps JSON → Apex class (EnrolmentRequest)

    // @AuraEnabled tells Salesforce
    // - It is accessible by LWC/Aura
    // - Include the field in JSON serialize/deserialization
    // - Allow the field in request/response payloads

    @AuraEnabled
    public String studentFirstName;
    @AuraEnabled
    public String studentLastName;
    @AuraEnabled
    public Integer studentPhoneNumber;
    @AuraEnabled
    public String studentEmail;
    @AuraEnabled
    public Date studentDob;
    @AuraEnabled
    public String studentAddress;
    @AuraEnabled
    public Id studentCourseId;
    @AuraEnabled
    public String studentCourseDuration;
    @AuraEnabled
    public Date studentEnrolmentDate;
    @AuraEnabled
    public String studentUSI;
  }

  @AuraEnabled
  public static string newEnrolmentSubmission(NewEnrolmentRequest req) {
    Savepoint sp = Database.setSavepoint();
    try {
      List<Student__c> students = new List<Student__c>();

      students.add(
        new Student__c(
          Name = req.studentFirstName,
          Last_Name__c = req.studentLastName,
          Phone__c = req.studentPhoneNumber,
          Date_of_Birth__c = req.studentDob,
          Email__c = req.studentEmail,
          Address__c = req.studentAddress,
          Unique_Student_Identifier__c = req.studentUSI
        )
      );

      List<Student__c> newStudents = enroll360StudentController.registerStudents(
        students
      );

      if (newStudents.isEmpty()) {
        Database.rollback(sp);
        throw new AuraHandledException(
          'System error: ' + 'Student record is not registered.'
        );
      }

      List<Enrolment__c> newEnrolments = new List<Enrolment__c>();

      for (Student__c s : newStudents) {
        newEnrolments.add(
          new Enrolment__c(
            Student__c = s.Id,
            Course__c = req.studentCourseId,
            Duration__c = req.studentCourseDuration,
            Enrolment_Date__c = req.studentEnrolmentDate,
            Onboarding_Status__c = 'Pending'
          )
        );
      }

      insert newEnrolments;

      return 'Enrolment has been completed';
    } catch (Exception e) {
      Database.rollback(sp);
      throw new AuraHandledException(e.getMessage());
    }
  }
}
