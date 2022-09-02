@RestResource(urlMapping='/portal/timeline/*')
global without sharing class PortalAPITimeline {
  public static String portalUserId;

  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params.size() > 3) {
      portalUserId = params[3];
      List<Activity> activities = new List<Activity>();

      activities.addAll(getRecentUploads());
      activities.addAll(getRecentTermsheetSigatures());
      activities.addAll(getRecentFundingsRequests());
      activities.sort();

      if (activities.size() > 10) {
        List<Activity> tempList = new List<Activity>();
        for (Integer i = 0; i < 10; i++) {
          tempList.add(activities[i]);
        }

        activities = tempList;
      }

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(activities));
    } else {
      res.addHeader('Content-Type', 'application/json');

      res.responseBody = Blob.valueOf(JSON.serialize(new List<Activity>()));
    }
  }

  public class Activity implements Comparable {
    String activityType;
    String label;
    Date activityDate;
    Integer daysAgo;
    DateTime activityDateTime;

    public Integer compareTo(Object compareTo) {
      Activity compareToActivity = (Activity) compareTo;

      if (compareToActivity.activityDateTime == this.activityDateTime) {
        return 0;
      }

      if (activityDateTime > compareToActivity.activityDateTime) {
        return -1;
      }

      return 1;
    }
  }

  public static List<Activity> getRecentUploads() {
    List<Activity> activities = new List<Activity>();

    Set<Id> contentVersionIds = (new Map<Id, ContentVersion>(
        [
          SELECT id, createddate
          FROM contentversion
          WHERE
            Uploaded_From_Portal_Id__c = :portalUserId
            AND Linked_To_Record__c = TRUE
          ORDER BY CreatedDate DESC
          LIMIT 10
        ]
      ))
      .keySet();

    for (Deal_Document__c doc : [
      SELECT Id, Document_Type__c, CreatedDate
      FROM Deal_Document__c
      WHERE ContentVersion_Id__c IN :contentVersionIds
    ]) {
      Activity activity = new Activity();
      activity.activityType = 'documentUpload';
      activity.activityDate = doc.CreatedDate.date();
      activity.daysAgo = activity.activityDate.daysBetween(system.today());
      activity.label = 'You uploaded ' + doc.Document_Type__c;
      activity.activityDateTime = doc.createdDate;
      activities.add(activity);
    }

    return activities;
  }

  public static List<Activity> getRecentTermsheetSigatures() {
    List<Activity> activities = new List<Activity>();

    Set<Id> dealIds = (new Map<Id, Opportunity>(
        [
          SELECT Id
          FROM Opportunity
          WHERE
            Application__r.Alchemy_User_Id__c = :portalUserId
            AND Application__r.Term_Sheet_Sent__c = TRUE
        ]
      ))
      .keySet();

    for (Deal_Document__c dealDoc : [
      SELECT Id, Borrower_Term_Sheet_Signature_Date__c, Deal__r.Name
      FROM Deal_Document__c
      WHERE
        Deal__c IN :dealIds
        AND Document_Type__c = 'Executed Term Sheet'
        AND Borrower_Term_Sheet_Signature_Date__c != NULL
      ORDER BY Borrower_Term_Sheet_Signature_Date__c DESC
      LIMIT 10
    ]) {
      Activity activity = new Activity();
      activity.activityType = 'termsheetSigned';
      activity.activityDate = dealDoc.Borrower_Term_Sheet_Signature_Date__c.date();
      activity.daysAgo = activity.activityDate.daysBetween(system.today());
      activity.label = 'You signed the Term Sheet for ' + dealDoc.deal__r.Name;
      activity.activityDateTime = dealDoc.Borrower_Term_Sheet_Signature_Date__c;
      activities.add(activity);
    }

    return activities;
  }

  public static List<Activity> getRecentFundingsRequests() {
    List<Activity> activities = new List<Activity>();
    Set<Id> dealIds = new Set<Id>();

    for (Deal_Contact__c c : [
      SELECT Id, Deal__c
      FROM Deal_Contact__c
      WHERE
        (Contact__r.Alchemy_Portal_Id__c = :portalUserId
        AND Entity_Type__c = 'Portal Access')
        OR Deal__r.Contact__r.Alchemy_Portal_Id__c = :portalUserId
    ]) {
      dealIds.add(c.Deal__c);
    }

    for (Property__c property : [
      SELECT Id, Name, CreatedDate
      FROM Property__c
      WHERE
        (CreatedBy.Name = 'Integrations User'
        OR CreatedBy.Name = 'MK Partners')
        AND Deal__c IN :dealIds
      ORDER BY CreatedDate DESC
    ]) {
      Activity activity = new Activity();
      activity.activityType = 'fundingRequest';
      activity.activityDate = property.CreatedDate.date();
      activity.daysAgo = activity.activityDate.daysBetween(system.today());
      activity.label = 'You submitted a Funding Request for ' + property.Name;
      activity.activityDateTime = property.CreatedDate;

      activities.add(activity);
    }

    return activities;
  }
}