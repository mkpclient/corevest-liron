public class Approval_TestDataFactory {
  // public static ProcessInstanceStep createProcessInstanceStep(ProcessInstance pi){
  //     ProcessInstanceStep pis = new ProcessInstanceStep(
  //         Comments='TestComments'
  //         , ActorId = UserInfo.getUserId()
  //         , StepStatus = 'Pending'
  //         , ProcessInstanceId = pi.Id
  //         , OriginalActorId = UserInfo.getUserId()
  //         // , RemindersSent = 0
  //     );
  //     insert pis;
  //     return pis;
  // }
  //
  // public static ProcessInstance createProcessInstance(Opportunity o, String status){
  //     ProcessInstance pi = new ProcessInstance(
  //         Status = status
  //         , TargetObjectId = o.Id
  //     );
  //     insert pi;
  //     return pi;
  // }

  public static UserRole createUserRole(String s) {
    String devName = s.replace(' ', '_');
    UserRole ur = new UserRole(DeveloperName = devName, Name = s);
    insert ur;
    return ur;
  }

  public static Opportunity createDeal(
    Id capMarketId,
    Id acceptableId,
    String approvalStatus
  ) {
    Account a = new Account(
      Name = 'Approval Test Account',
      BillingStreet = 'Test',
      BillingCountry = 'United States',
      BillingState = 'California',
      BillingPostalCode = '92627'
    );
    insert a;
    Contact c = new Contact(
      FirstName = 'Alpha',
      LastName = 'Omega',
      MailingStreet = 'Gamma',
      MailingCountry = 'United States',
      MailingState = 'California',
      MailingPostalCode = '92927',
      accountId = a.Id
    );
    insert c;
    Opportunity o = new Opportunity(
      AccountId = a.Id,
      Contact__c = c.Id,
      CloseDate = System.today(),
      Name = 'TestName',
      StageName = Opportunity.StageName.getDescribe().getPicklistValues()[1]
        .getValue(),
      Deal_Lost_Reason__c = Opportunity.Deal_Lost_Reason__c.getDescribe()
          .getPicklistValues()[0]
        .getValue(),
      Approved_by_Capital_Markets__c = capMarketId,
      Approved_by_Underwriter__c = acceptableId,
      Approval_Status__c = approvalStatus,
      Deal_Intro_Source__c = 'Email',
      Deal_Intro_Sub_Source__c = 'Email'
    );
    o.Apex_Context__c = true;
    o.Property_Management__c = 'Third Party';
    insert o;
    o.Apex_Context__c = true;
    return o;
  }

  public static Profile findProfile() {
    Profile p = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ];
    return p;
  }

  public static User createUser(Integer i, Id urId, Id pId) {
    User u = new User(
      Alias = 'Alias' + String.valueOf(i),
      UserRoleId = urId,
      Username = 'cho32789@test.com',
      LastName = 'Test',
      Email = 'test@test.com',
      CommunityNickname = 'Test',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'utf-8',
      ProfileId = pId
    );
    insert u;
    return u;
  }

  public static Approval_History__c createApprovalHistory(Id piwId, Id pisId) {
    Approval_History__c ahc = new Approval_History__c(
      Process_Id__c = piwId,
      Process_Instance_Id__c = pisId
    );
    insert ahc;
    return ahc;
  }

  public static Attachment createAttachment(Id parentId) {
    Attachment a = new Attachment(
      Body = Blob.valueOf('hello'),
      Description = 'TestDescription',
      Name = 'TestName',
      ParentId = parentId
    );
    insert a;
    return a;
  }

  public static ContentVersion createCv() {
    ContentVersion cv = new ContentVersion(
      PathOnClient = 'TestClient',
      Title = 'TestTitle',
      VersionData = Blob.valueOf('hello')
    );
    insert cv;
    ContentVersion queryCv = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ];
    return queryCv;
  }

  public static ContentDocumentLink createCdl(Id cdId, Id parentId) {
    ContentDocumentLink cdl = new ContentDocumentLink(
      ContentDocumentId = cdId,
      LinkedEntityId = parentId,
      ShareType = 'V'
    );
    insert cdl;
    return cdl;
  }

  public static Email__c createEmail(Id aId, Id cvId, Id oId) {
    Email__c e = new Email__c(
      AttachmentId__c = aId,
      ContentVersionId__c = cvId,
      Deal__c = oId
    );
    insert e;
    return e;
  }
}