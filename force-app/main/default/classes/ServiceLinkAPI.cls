public without sharing class ServiceLinkAPI {
  public static QuoteRequest performQuoteRequest(QuoteRequest qr) {
    String url = '';
    HttpRequest req = new HttpRequest();
    req.setBody(JSON.serialize(new Map<String, QuoteRequest>{'QuoteRequest' => qr}, true));
    req.setEndpoint(url);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
    req.setTimeout(120000);

    Integer statusCode = 200;
    String body = '';

    HttpResponse res = new Http().send(req);
    system.debug(res.getBody());
    system.debug(res.getStatus());
    system.debug(res.getStatusCode());
    body = res.getBody();
    Map<String, QuoteRequest> parsedBody = (Map<String, QuoteRequest>) JSON.deserialize(body, Map<String, QuoteRequest>.class);
    return parsedBody.values()[0];
  }

  public class TitleDocument {
    public String DocumentType { get; set; }
    public String DocumentName { get; set; }
    public String Format { get; set; }
    public Long Size { get; set; }
    public String Base64FileData { get; set; }
  }
  public class QuoteRequest {
    public String SourcePartyID { get; set; }
    public String DestinationPartyID { get; set; }
    public String QuoteID { get; set; } // CV unique ID for quote request
    public String LoanNumber { get; set; } // CV Loan Number
    public String LoanPortfolioName { get; set; } // CV Loan Portfolio Name
    public Decimal LoanAmount { get; set; }
    public String Comments { get; set; }
    public String BulkProjectOrderNum { get; set; }
    public TitleDocument Document { get; set; } // type is QUOTEREQUEST and send XLSX format. "Data Tape" of properties for the quote request

    public void generateRequest(
      Opportunity deal,
      Deal_Document__c doc,
      ContentVersion cv
    ) {
      this.SourcePartyID = 'COREVEST-SFR';
      this.DestinationPartyID = 'COREVEST-QUOTE';
      this.QuoteID = deal.id;
      this.LoanNumber = deal.Deal_Loan_Number__c;
      this.LoanAmount = deal.Current_Loan_Amount__c;
      this.LoanPortfolioName = deal.Name;
      this.Comments = '';
      this.Document.DocumentType = 'QUOTEREQUEST';
      this.Document.DocumentName = doc.File_Name__c;
      this.Document.Format = 'XLSX';
      this.Document.Size = cv.ContentSize;
      this.Document.Base64FileData = EncodingUtil.base64Encode(cv.VersionData);
    }
  }
}
