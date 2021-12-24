@RestResource(urlMapping='/portal/checklist/*')
global without sharing class PortalAPIChecklist {
  public static Id recordId;
  public static Opportunity deal;
  @HttpGet
  global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = Restcontext.response;

    List<String> params = Restcontext.request.requestURI.split('/');

    if (params[3] == 'milestones') {
      recordId = params[4];
      deal = [
        SELECT Id, Owner.Name, Underwriter__r.Name, Closer__r.Name, Type
        FROM Opportunity
        WHERE Id = :recordId
      ];

      Checklist checklist = new Checklist();

      if (deal.Type == 'Term Loan') {
        checklist.milestones = createTermMilestone();
      } else {
        checklist.milestones = createBridgeMilestone();
      }

      res.addHeader('Content-Type', 'application/json');
      res.responseBody = Blob.valueOf(JSON.serialize(checklist));
    }
  }

  public static List<Milestone> createTermMilestone() {
    List<Milestone> milestones = new List<Milestone>();
    milestones.add(
      new Milestone(
        'Initial Screening and Diligence',
        deal.Owner.Name,
        system.today(),
        true
      )
    );
    milestones.add(
      new Milestone(
        'Term Sheet Signed/Deposit Collected',
        deal.Owner.Name,
        null,
        false
      )
    );
    milestones.add(
      new Milestone(
        'Submission to Underwriting',
        deal.Owner.Name,
        system.today(),
        true
      )
    );
    milestones.add(
      new Milestone('Kick-Off', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Due Diligence', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Underwriting', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Closing', deal.Closer__r.Name, null, false)
    );
    milestones.add(
      new Milestone('Wire Scheduled', deal.Closer__r.Name, null, false)
    );
    milestones.add(
      new Milestone('Loan Funded/Closed Loan', deal.Closer__r.Name, null, false)
    );

    return milestones;
  }

  public static List<Milestone> createBridgeMilestone() {
    List<Milestone> milestones = new List<Milestone>();
    milestones.add(
      new Milestone(
        'Initial Screening and Diligence',
        deal.Owner.Name,
        system.today(),
        true
      )
    );
    milestones.add(
      new Milestone(
        'Term Sheet Signed/Deposit Collected',
        deal.Owner.Name,
        null,
        false
      )
    );
    milestones.add(
      new Milestone('Submission to Underwriting', deal.Owner.Name, null, false)
    );
    milestones.add(
      new Milestone('Kick-Off', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Due Diligence', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Underwriting', deal.Underwriter__r.Name, null, false)
    );
    milestones.add(
      new Milestone('In Closing', deal.Closer__r.Name, null, false)
    );
    milestones.add(
      new Milestone('Loan Funded/Closed Loan', deal.Closer__r.Name, null, false)
    );

    return milestones;
  }

  public class Checklist {
    List<Milestone> milestones;

    Checklist() {
      milestones = new List<Milestone>();
    }
  }

  public class Milestone {
    String milestone;
    String teamMember;
    Date completedDate;
    Boolean completed;

    Milestone(
      String milestone,
      String teamMember,
      Date completedDate,
      Boolean completed
    ) {
      this.milestone = milestone;
      this.teamMember = teamMember;
      this.completedDate = completedDate;
      this.completed = completed;
    }
  }
}