public class DuplicateDealsEmailController {
  public String recId { get; set; }
  public Set<String> dupeIds { get; set; }


  public static final List<String> PROP_FIELDS = new List<String>{
    'Id',
    'Name',
    'Deal__c',
    'Deal__r.Name',
    'Deal__r.StageName',
    'CreatedDate',
    'Deal__r.Owner.Name',
    'Deal__r.OwnerId',
    'Deal__r.CloseDate',
    'Deal__r.CAF_Analyst__r.Name'
  };

  public List<Property__c> properties {
    get {
      if (recId != null) {
        System.debug('Getting properites for ' + recId);
        List<Map<String, String>> dupeList = DuplicateCheckJobHelper.getDupeListFromDeal(
          recId
        );
        Set<String> idSet = new Set<string>();
        for (Map<String, String> d : dupeList) {
          idSet.add(String.valueOf(d.get('sourceId')));
          idSet.add(String.valueOf(d.get('matchId')));
        }

        dupeIds = idSet;
        Set<String> idsForQuery = new Set<String>();
        if(idSet.size() > 1000) {
          for(Integer i = 0; i < 1000; i++) {
            idsForQuery.add(new List<String>(idSet)[i]);
          }
        } else {
          idsForQuery.addAll(idSet);
        }



        String queryString =
          'SELECT ' +
          String.join(PROP_FIELDS, ',') +
          ' FROM Property__c WHERE Id IN :idsForQuery';
        List<Property__c> dupePropertes = Database.query(queryString);

        return dupePropertes;
      } else {
        return new List<Property__c>();
      }
    }
    private set;
  }

  public String baseUrl {
    get {
      return URL.getOrgDomainUrl().toExternalForm() + '/';
    }
    private set;
  }

  public Boolean hasDuplicates {
    get {
      return properties.size() > 0;
    }
    private set;
  }

  public Integer numDuplicates {
    get {
      return dupeIds != null ? dupeIds.size() : 0;
    }
    private set;
  }

  public Integer dupesDisplayed {
    get {
      return properties.size();
    }
    private set;
  }
}