@RestResource(urlMapping='/v1/leaves/*')
global with sharing class LeaveRestService {
  //   Post request
  @HttpPost
  global static LeaveResponseWrapper createLeave() {
    Long startTime = DateTime.now().getTime();

    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;

    String requestBody = req.requestBody.toString();

    try {
      // Example logic
      LeaveMngSys_Leave__c leave = [
        SELECT Id, Name
        FROM LeaveMngSys_Leave__c
        WHERE Id = 'a09gL000008ItwLQAS'
        LIMIT 1
      ];

      Long executionTime = DateTime.now().getTime() - startTime;

      // Log the request
      TransactionLog.logRequest(
        'POST',
        req.requestURI,
        requestBody,
        200,
        'Success',
        true,
        null,
        'Integration',
        executionTime
      );

      return new LeaveResponseWrapper(true, leave, requestBody);
    } catch (Exception e) {
      res.statusCode = 400;

      Long executionTime = DateTime.now().getTime() - startTime;

      // Log the request
      TransactionLog.logRequest(
        'POST',
        req.requestURI,
        requestBody,
        500,
        null,
        false,
        e.getMessage(),
        'Integration',
        executionTime
      );

      return new LeaveResponseWrapper(false, null, e.getMessage());
    }
  }

  // Response Wrapper
  global class LeaveResponseWrapper {
    public Boolean success;
    public LeaveMngSys_Leave__c record;
    public String message;

    public LeaveResponseWrapper(
      Boolean success,
      LeaveMngSys_Leave__c record,
      String message
    ) {
      this.success = success;
      this.record = record;
      this.message = message;
    }
  }
}
