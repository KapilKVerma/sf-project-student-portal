@RestResource(urlMapping='/v1/penetrationTest/*')
global with sharing class PenetrationTestRestService {
  // POST request
  @HttpPost
  global static ResponseWrapper createPenTestRecord() {
    Long startTime = DateTime.now().getTime();

    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    Savepoint sp = Database.setSavepoint();

    if (req.requestBody == null) {
      return errorResponse(req, sp, 400, 'Request body missing', startTime);
    }

    String reqBody = req.requestBody.toString();

    try {
      // Step 1: Deserialise incomming data
      PenetrationTestWrapper deserializedResult = (PenetrationTestWrapper) JSON.deserializeStrict(
        reqBody,
        PenetrationTestWrapper.class
      );

      // Step 2: Validation rule for empty fields
      if (
        deserializedResult.vulnerabilities_found == null ||
        deserializedResult.vulnerabilities_found.isEmpty()
      ) {
        String errMsg = 'No vulnerabilities provided';
        return errorResponse(req, sp, 400, errMsg, startTime);
      }

      //  Step 3: Save Parent Record and return Id
      ID newPenTestId = savePenTest(deserializedResult);

      List<PenetrationTestWrapper.Vulnerability> vulList = deserializedResult.vulnerabilities_found;

      //  Step 4: Collect all CWE codes From each vulnerability
      Set<String> cweCodes = new Set<String>();

      for (PenetrationTestWrapper.Vulnerability vul : vulList) {
        if (String.isNotBlank(vul.cwe_code)) {
          cweCodes.add(vul.cwe_code);
        } else {
          String errMsg = 'CWE Code is missing: ' + vul.Name;
          return errorResponse(req, sp, 400, errMsg, startTime);
        }
      }

      //  Step 5: Query all remedies in ONE SOQL for grouping
      Map<String, List<VulRemedy__mdt>> remedyMap = new Map<String, List<VulRemedy__mdt>>();

      List<VulRemedy__mdt> customVulRemedies = [
        SELECT CWE_Code__c, Remediation_Steps__c, Remedy_Code__c, Description__c
        FROM VulRemedy__mdt
        WHERE CWE_Code__c IN :cweCodes
      ];

      // Step 6: Group VulRemedy__mdt records by CWE_Code__c
      for (VulRemedy__mdt customVulRemedy : customVulRemedies) {
        //  Check if map already has Cwe Code key
        if (!remedyMap.containsKey(customVulRemedy.CWE_Code__c)) {
          remedyMap.put(
            customVulRemedy.CWE_Code__c,
            new List<VulRemedy__mdt>()
          );
        }

        // Add Remedy To That CWE List
        remedyMap.get(customVulRemedy.CWE_Code__c).add(customVulRemedy);
      }

      // Step 7: Prepare Vulnerability records (NO DML in loop)
      List<Vulnerability__c> vulToInsert = new List<Vulnerability__c>();

      for (PenetrationTestWrapper.Vulnerability vul : vulList) {
        List<String> remedyStrings = new List<String>();

        if (remedyMap.containsKey(vul.cwe_code)) {
          for (VulRemedy__mdt vulR : remedyMap.get(vul.cwe_code)) {
            remedyStrings.add(remediationsBody(vulR));
          }
        }

        String remediesNotes = String.join(remedyStrings, '\n');

        Vulnerability__c newVul = new Vulnerability__c();

        newVul.Name = vul.name;
        newVul.OWASP_Category__c = vul.owasp_category;
        newVul.Severity__c = vul.severity;
        newVul.Business_Impact__c = vul.bussines_impact;
        newVul.Remediation_Notes__c = remediesNotes;
        newVul.Penetration_Test_Id__c = newPenTestId;

        vulToInsert.add(newVul);
      }

      // Step 8: Single DML
      if (!vulToInsert.isEmpty()) {
        insert vulToInsert;
      } else {
        String errMsg = 'Error in inserting vulnerabilities';
        return errorResponse(req, sp, 400, errMsg, startTime);
      }

      String domainUrl = URL.getOrgDomainUrl().toExternalForm();

      String successMsg = String.format(
        '*New Penetration Test Record*\n' +
          '*Name:* {0}\n' +
          '*Created at:* {1}\n' +
          '<{2}/{3}|Check Details>',
        new List<Object>{
          deserializedResult.Name,
          System.now().format('dd MMM yyyy hh:mm a'),
          domainUrl,
          newPenTestId
        }
      );

      // Send Slack Notification
      SlackService.sendMessage(successMsg);
      return successResponse(req, 201, successMsg, startTime);
    } catch (Exception e) {
      return errorResponse(req, sp, 500, e.getMessage(), startTime);
    }
  }

  //   --------------------------
  //   Helping Methods
  //   --------------------------

  // Create Remediations Body
  public static String remediationsBody(VulRemedy__mdt vulR) {
    String remedySteps =
      'Code: ' +
      vulR.Remedy_Code__c +
      '\n' +
      'Description: ' +
      vulR.Description__c +
      '\n' +
      '\n' +
      'Remediation Steps: ' +
      '\n' +
      vulR.Remediation_Steps__c.replace(';', '') +
      '\n' +
      '-----------------------------------' +
      '\n';

    return remedySteps;
  }

  // Remedies Notes Cleanup
  public static String remediesNotesCleanup(List<String> vulRemediesList) {
    return String.join(vulRemediesList, '\n');
  }

  // Save Penetration Test
  public static Id savePenTest(PenetrationTestWrapper deserializedResult) {
    Penetration_Test__c newPenTest = new Penetration_Test__c();

    newPenTest.Name = deserializedResult.name;
    newPenTest.External_Scan_Id__c = deserializedResult.external_scan_Id;
    newPenTest.Scan_Tool__c = deserializedResult.scan_tool;
    newPenTest.Scan_Type__c = deserializedResult.scan_type;
    newPenTest.Scan_Start_Date__c = deserializedResult.scan_start_date;
    newPenTest.Scan_End_Date__c = deserializedResult.scan_end_date;

    insert newPenTest;

    return newPenTest.Id;
  }

  // Success Response
  private static ResponseWrapper successResponse(
    RestRequest req,
    Integer statusCode,
    String message,
    Long startTime
  ) {
    RestContext.response.statusCode = statusCode;
    Long executionTime = DateTime.now().getTime() - startTime;

    TransactionLog.logRequest(
      'POST',
      req.requestURI,
      req.requestBody.toString(),
      statusCode,
      message,
      true,
      null,
      'Integration',
      executionTime
    );

    return new ResponseWrapper(true, message);
  }

  // Error Response
  private static ResponseWrapper errorResponse(
    RestRequest req,
    Savepoint sp,
    Integer statusCode,
    String message,
    Long startTime
  ) {
    Database.rollback(sp);
    RestContext.response.statusCode = statusCode;
    Long executionTime = DateTime.now().getTime() - startTime;

    TransactionLog.logRequest(
      'POST',
      req.requestURI,
      req.requestBody.toString(),
      statusCode,
      message,
      false,
      message,
      'Integration',
      executionTime
    );

    return new ResponseWrapper(false, message);
  }

  // Response Wrapper
  global class ResponseWrapper {
    public Boolean success;
    public String message;

    public ResponseWrapper(Boolean success, String message) {
      this.success = success;
      this.message = message;
    }
  }
}
