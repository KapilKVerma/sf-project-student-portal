public with sharing class enroll360StudentController {
  @AuraEnabled
  public static Student__c getStudent(Id studentId) {
    try {
      List<Student__c> students = [
        SELECT
          Id,
          Name,
          Last_Name__c,
          Unique_Student_Identifier__c,
          USI_Verified__c
        FROM Student__c
        WHERE Id = :studentId
        LIMIT 1
      ];

      return students.isEmpty() ? null : students[0];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // Single record
  public static Id registerStudent(
    String studentFirstName,
    String studentLastName,
    Integer studentPhoneNumber,
    String studentEmail,
    Date studentDob,
    String studentAddress,
    String studentUSI
  ) {
    try {
      Student__c newStudent = new Student__c(
        Name = studentFirstName,
        Last_Name__c = studentLastName,
        Phone__c = studentPhoneNumber,
        Date_of_Birth__c = studentDob,
        Email__c = studentEmail,
        Address__c = studentAddress,
        Unique_Student_Identifier__c = studentUSI
      );

      insert newStudent;

      return newStudent.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // Bulk records
  public static List<Student__c> registerStudents(List<Student__c> students) {
    try {
      insert students;
      return students;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Student__c updateStudent(Student__c student) {
    try {
      update student;
      return student;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
