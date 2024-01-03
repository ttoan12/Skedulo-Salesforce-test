public class CounterController {
  public String searchString { get; set; }
  public List<SearchResult> searchResults { get; set; }
  public Boolean showResults { get; set; }

  public class SearchResult {
    public Id RecordId { get; set; }
    public String RecordName { get; set; }
    public String RecordType { get; set; }
    public Integer Counter { get; set; }
  }

  public CounterController() {
    searchResults = new List<SearchResult>();
    showResults = false;
    searchString = '';
  }

  @RemoteAction
  public static Integer increaseCounter(Id id, String type) {
    if (type == 'Account') {
      Account accToUpdate = [SELECT Id, Counter__c FROM Account WHERE Id = :id LIMIT 1];
      
      if (accToUpdate.Counter__c == null) accToUpdate.Counter__c = 0;

      accToUpdate.Counter__c++;
      
      update accToUpdate;

      return accToUpdate.Counter__c.intValue();
    }
    else {
      Contact contactToUpdate = [SELECT Id, Counter__c FROM Contact WHERE Id = :id LIMIT 1];
      
      if (contactToUpdate.Counter__c == null) contactToUpdate.Counter__c = 0;
      
      contactToUpdate.Counter__c++;
      
      update contactToUpdate;
      
      return contactToUpdate.Counter__c.intValue();
    }
  }

  public void performSearch() {
    searchResults.clear();

    // Search for Accounts
    for (Account acc : [SELECT Id, Name, Counter__c FROM Account WHERE Name LIKE : '%' + searchString + '%']) {
      SearchResult result = new SearchResult();
      result.RecordId = acc.Id;
      result.RecordName = acc.Name;
      result.RecordType = 'Account';
      result.Counter = acc.Counter__c != null ? acc.Counter__c.intValue() : 0;
      searchResults.add(result);
    }

    // Search for Contacts
    for (Contact contact : [SELECT Id, Name, Counter__c FROM Contact WHERE Name LIKE : '%' + searchString + '%']) {
      SearchResult result = new SearchResult();
      result.RecordId = contact.Id;
      result.RecordName = contact.Name;
      result.RecordType = 'Contact';
      result.Counter = contact.Counter__c != null ? contact.Counter__c.intValue() : 0;
      searchResults.add(result);
    }

    showResults = true;
  }
}