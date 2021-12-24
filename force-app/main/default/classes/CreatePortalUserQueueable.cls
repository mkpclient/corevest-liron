public without sharing class CreatePortalUserQueueable implements Queueable, Database.AllowsCallouts {
  public List<Id> leadIds;
  public CreatePortalUserQueueable(List<Id> leadIds) {
    this.leadIds = leadIds;
  }

  public void execute(QueueableContext context) {
    Id leadId = leadIds.remove(0);
    AlchemyAPI.createUserFromLead(leadId);

    if (this.leadIds.size() > 0) {
      system.enqueueJob(new CreatePortalUserQueueable(leadIds));
    }
  }
}