@isTest
public class enroll360StudentControllerTest {
  @isTest
  static void testRegisterStudent_Success() {
    // Test Data
    String studentFirstName = 'John';
    String studentLastName = 'Doe';
    Integer studentPhoneNumber = 1234567890;
    String studentEmail = 'john.doe@test.com';
    Date studentDob = Date.newInstance(2000, 1, 1);
    String studentAddress = '123 test street';
    String studentUSI = 'U123456778';

    Test.startTest();

    // Call Method
    Id studentId = enroll360StudentController.registerStudent(
      studentFirstName,
      studentLastName,
      studentPhoneNumber,
      studentEmail,
      studentDob,
      studentAddress,
      studentUSI
    );

    Test.stopTest();

    // Verify record was created
    Student__c insertedStudent = [
      SELECT Id, Name, Last_Name__c
      FROM Student__c
      WHERE Id = :studentId
    ];

    System.assertNotEquals(null, studentId, 'Student Id should not be null');
    System.assertEquals(studentFirstName, insertedStudent.Name);
    System.assertEquals(studentLastName, insertedStudent.Last_Name__c);
  }

  @istest
  static void testRegisterStudents_Success() {
    // Test Data
    List<Student__c> studentsTestData = new List<Student__c>();

    for (Integer i = 1; i <= 200; i++) {
      Student__c newStudentTestData = new Student__c();

      newStudentTestData.Name = 'Student First Name- ' + i;
      newStudentTestData.Last_Name__c = 'Student Last Name- ' + i;
      newStudentTestData.Phone__c = 1234567890;
      newStudentTestData.Date_of_Birth__c = Date.newInstance(2000, 1, 1);
      newStudentTestData.Email__c = 'studentEmail' + i + '@gail.com';
      newStudentTestData.Address__c = '1234' + i + 'avenue NSW';
      newStudentTestData.Unique_Student_Identifier__c = 'US1234567' + i;

      studentsTestData.add(newStudentTestData);
    }

    Test.startTest();
    // Call Method
    List<Student__c> newStudents = enroll360StudentController.registerStudents(
      studentsTestData
    );

    Test.stopTest();

    // Assertion
    System.assertEquals(newStudents.size(), 200);
    System.assertEquals(studentsTestData[0].Name, newStudents[0].Name);
    System.assertEquals(studentsTestData[50].Name, newStudents[50].Name);
    System.assertEquals(
      studentsTestData[0].Last_Name__c,
      newStudents[0].Last_Name__c
    );
    System.assertEquals(
      studentsTestData[50].Last_Name__c,
      newStudents[50].Last_Name__c
    );
  }

  @isTest
  static void testRegisterStudent_Exception() {
    Test.startTest();

    try {
      // Pass invalid data (e.g., null required fields if any exist)
      enroll360StudentController.registerStudent(
        null,
        null,
        null,
        null,
        null,
        null,
        null
      );

      System.assert(false, 'Exception should have been thrown');
    } catch (AuraHandledException e) {
      System.assert(e.getMessage() != null);
    }

    Test.stopTest();
  }

  @isTest
  static void testRegisterStudents_Exception() {
    Test.startTest();
    try {
      // Call method that should fail
      enroll360StudentController.registerStudents(null);

      // If no exception → FAIL test
      System.assert(false, 'Exception was not thrown');
    } catch (Exception e) {
      System.assert(e.getMessage() != null);
    }

    Test.stopTest();
  }

  @isTest
  static void testRegisterStudents_USIDuplicateValues() {
    // Test Data

    // Step 1: Insert first student
    Student__c student1 = new Student__c(
      Name = 'Student First Name- 1',
      Last_Name__c = 'Student Last Name- 1',
      Phone__c = 1234567890,
      Date_of_Birth__c = Date.newInstance(2000, 1, 1),
      Email__c = 'studentEmail1@mail.com',
      Address__c = '1234 avenue NSW',
      Unique_Student_Identifier__c = 'US12345671'
    );

    insert student1;

    // Step 2: Create duplicate student
    List<Student__c> studentsTestData = new List<Student__c>{
      new Student__c(
        Name = 'Student First Name- 2',
        Last_Name__c = 'Student Last Name- 2',
        Phone__c = 1234567890,
        Date_of_Birth__c = Date.newInstance(2000, 1, 1),
        Email__c = 'studentEmail2@mail.com',
        Address__c = '5678 avenue NSW',
        Unique_Student_Identifier__c = 'US12345671' // duplicate
      )
    };

    Test.startTest();

    try {
      // Call method that should fail
      enroll360StudentController.registerStudents(studentsTestData);

      // If no exception → FAIL test
      System.assert(false, 'Exception was not thrown');
    } catch (AuraHandledException e) {
      System.assert(e.getMessage().contains('Script-thrown exception'));
    }

    Test.stopTest();
  }
}
