public class SearchController {
  public String searchString { get; set; }
  public List<SearchResult> searchResults { get; set; }
  public Boolean showResults { get; set; }

  public class SearchResult {
    public String RecordName { get; set; }
    public String RecordType { get; set; }
    public String RecordLink { get; set; }
  }

  public void performSearch() {
    showResults = true;
    searchResults = new List<SearchResult>();

    // Search for Accounts
    for (Account acc : [SELECT Id, Name FROM Account WHERE Name LIKE : '%' + searchString + '%']) {
      SearchResult result = new SearchResult();
      result.RecordName = acc.Name;
      result.RecordType = 'Account';
      result.RecordLink = URL.getOrgDomainURL().toExternalForm() + '/' + acc.Id;
      searchResults.add(result);
    }

    // Search for Contacts
    for (Contact con : [SELECT Id, Name FROM Contact WHERE Name LIKE : '%' + searchString + '%']) {
      SearchResult result = new SearchResult();
      result.RecordName = con.Name;
      result.RecordType = 'Contact';
      result.RecordLink = URL.getOrgDomainURL().toExternalForm() + '/' + con.Id;
      searchResults.add(result);
    }
  }
}