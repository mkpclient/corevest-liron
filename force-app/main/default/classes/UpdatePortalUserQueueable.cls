public without sharing class UpdatePortalUserQueueable implements Queueable, Database.AllowsCallouts {
  public List<String> ids;
  public String updateType;
  public UpdatePortalUserQueueable(List<String> ids) {
    this.ids = ids;
  }

  public UpdatePortalUserQueueable(List<String> ids, String updateType) {
    this.ids = ids;
    this.updateType = updateType;
  }

  public void execute(QueueableContext context) {
    String recordId = this.ids.remove(0);

    if (updateType != null && updateType == 'delete') {
      AlchemyAPI.deleteUser(recordId);
    } else if (updateType == 'createOperationsUser') {
      AlchemyAPI.createOperationsUser(recordId);
    } else if (updateType == 'invitePropertyManager') {
      AlchemyAPI.invitePropertyManager(recordId);
    } else {
      AlchemyAPI.updateUser(recordId);
    }

    if (this.ids.size() > 0) {
      system.enqueueJob(new UpdatePortalUserQueueable(this.ids));
    }
  }
}