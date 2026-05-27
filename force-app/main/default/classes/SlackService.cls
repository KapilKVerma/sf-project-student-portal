public with sharing class SlackService {
  @future(callout=true)
  public static void sendMessage(String message) {
    Http http = new Http();
    HttpRequest req = new HttpRequest();

    try {
      req.setEndpoint('callout:Slack_Webhook_2');
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/json');
      req.setTimeout(10000);

      //   Build JSON Body
      Map<String, Object> payload = new Map<String, Object>();
      List<Object> blocks = new List<Object>();

      payload.put('text', message);

      req.setBody(JSON.serialize(payload));

      HttpResponse res = http.send(req);

      if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        System.debug('Slack message sent successfully' + payload.toString());
      } else {
        System.debug(
          'Slack error: ' + res.getStatusCode() + ' - ' + res.getBody()
        );
      }
    } catch (Exception e) {
      System.debug('SlackService error message: ' + e.getMessage());
    }
  }
}
