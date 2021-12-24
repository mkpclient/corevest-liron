global class servicer_Schedulable implements Schedulable {

	global void execute(SchedulableContext SC){
        startProcess();
	}

    @future(callout = true)
    public static void startProcess(){
        String token = generateAuthToken();

        for(Box_Setting__mdt setting : [select id, servicer__c, box_folder_id__c, File_Split_By__c from box_setting__mdt where servicer__c != null]){
            getFileAndParse(setting.Box_Folder_Id__c, setting.Servicer__c, setting.File_Split_By__c.replaceAll('"', ''), token);
        }
    }


	//@future(callout = true)
	public static void getFileAndParse(String folderId, String servicer, String splitOn, String authToken){
		string FOLDER_ENDPOINT = 'https://api.box.com/2.0/folders/' + folderId + '/items';
        system.debug(folder_endpoint);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(FOLDER_ENDPOINT);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + authToken);

        Integer statusCode = 200;
        String folderRespBody = '{"total_count":6,"entries":[{"type":"folder","id":"11493206465","sequence_id":"2","etag":"2","name":"Search Folder - Metadata Template"},{"type":"folder","id":"11457072438","sequence_id":"5","etag":"5","name":"Search Folder - Sample Files"},{"type":"folder","id":"11642995651","sequence_id":"0","etag":"0","name":"User Starter Files"},{"type":"file","id":"226229281131","file_version":{"type":"file_version","id":"238888480107","sha1":"bd550bec9641113b393559025940d1849e54d548"},"sequence_id":"0","etag":"0","sha1":"bd550bec9641113b393559025940d1849e54d548","name":"Box Developer Experience.pptx"},{"type":"file","id":"226229162711","file_version":{"type":"file_version","id":"238888366295","sha1":"aef4655664e624d785f5158e45170302917387bf"},"sequence_id":"0","etag":"0","sha1":"aef4655664e624d785f5158e45170302917387bf","name":"Press Release.docx"},{"type":"file","id":"226228995539","file_version":{"type":"file_version","id":"238888201939","sha1":"14673e790b8210fec2459c66a85583dcf7e4cc22"},"sequence_id":"0","etag":"0","sha1":"14673e790b8210fec2459c66a85583dcf7e4cc22","name":"Supplies Order.pdf"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}';

        Httpresponse resp = new HttpResponse();
        if(!Test.isRunningTest()){
            resp = new Http().send(req);
            statusCode = resp.getStatusCode();
            folderRespBody = resp.getBody();
        }
		
        

		Map<String, Object> folderResp = (Map<String, Object>)JSON.deserializeUntyped(folderRespBody);

		String fileId = '';

		if((Decimal)folderResp.get('total_count') > 0){
			List<Object> files = (List<Object>)folderResp.get('entries');
			for(Object o : files){
				Map<String, Object> file = (Map<String, Object>)o;
				String name = (String)file.get('name');
				if(name.contains('.csv') ){
					fileId = (String)file.get('id');
				}

			}

			//system.debug(fileId);

		}

		string FILE_ENDPOINT = 'https://api.box.com/2.0/files/' + fileId + '/content';


		req = new HttpRequest();
		req.setEndpoint(FILE_ENDPOINT);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + authToken);

        if(!test.isRunningTest()){
            resp = new Http().send(req);
        }else{
            resp.setStatusCode(302);
            //resp.setHeader('https://api.box.com');
        }
		

		if(resp.getStatusCode() == 302){
            String loc = 'https://api.box.com';
            if(!Test.isRunningTest()){
                loc = resp.getHeader('Location');
            }
			
            

			req = new HttpRequest();
			req.setEndpoint(loc);
			req.setMethod('GET');

            String fileBody = 'ServicerLnID,SysStatusCd,SysStatus,LoanDisposedDate,LoanPurpose,PayoffTransferServicingDate,PayoffTransferServicingEndUPB,ProcessControlStatus,Portfolio,InvestorLnID,ServicerCommitmentLnID,InvestorCommitmentLnID,PrimaryBorrower,BorrowerStateProv,PrimaryCollateralID,FullPropertyStreet,PropertyCity,PropertyStateProvCd,PropertyPostal,OriginalLoanBalance,OriginationDate,FirstPmtDate,OriginalLoanTerm,UnpaidPrincipalBalance,InterestPaidToDate,NextPmtDueDate,MaturityDate,PaymentStatus,InterestRate,InterestTypeCd,InterestType,CurrentPIPmt,LastPmtAmt,LastPmtDate,UnappliedBalance,SuspenseBalance,UnappliedSuspenseBalance,UnappliedSuspensePctofUPB,MiscFeeBalance,TaxEscBalance,InsurEscBalance,ReserveEscBalance\n330157189,D,Disposed,1/26/2017 12:00:00 AM,Acquisition,1/27/2017 1:09:14 PM,44087.9900,Paid in Full,COREVEST (CAF BRIDGE & CAF LENDING-NOMURA REPO),31201500005,990000323,31201500005,RRCAP-SFR I LLC,NC,30206,12501 Lantana Avenue,New Port Richey,FL,34654,44087.9900,4/28/2016 12:00:00 AM,5/1/2016 12:00:00 AM,15,0.0000,1/26/2017 12:00:00 AM,2/1/2017 12:00:00 AM,6/8/2017 12:00:00 AM,10 - Matured,7.5000000000,F,Fixed Rate,284.7300,284.7300,1/10/2017 12:00:00 AM,0.0000,0.0000,0.0000,0.000,0.0000,0.0000,0.0000,0.0000';
            if(!Test.isRunningTest()){
                resp = new http().send(req);
                fileBody = resp.getBody();
            }
			


			List<String> rows = safeSplit(fileBody, '\n');

			List<List<String>> parsedRows = new List<List<String>>();
			for(Integer i = rows.size() - 1; i >= 0; i--){

			    if(String.isNotBlank(rows[i])){
			        parsedRows.add( safeSplit(rows[i], ',') );
			    }
			    rows.remove(i);

			}

			updateRecords(parsedRows, servicer);

		}


	}

	public static List<String> safeSplit(String inStr, String delim)
    {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        
        List<String> output = new List<String>();
        
        Matcher m = Pattern.compile(delim).matcher(inStr);
        
        Integer lastEnd = 0;

        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {   
                if(m.find())
                {   

                    if( lastEnd != m.end() && inStr.substring(lastEnd, lastEnd+1) == '"' && inStr.subString(m.start()-1, m.start()) != '"'){
                        Boolean keepSearching = true;

                        while(keepSearching && m.find() ){
                            if(lastEnd != m.end() && inStr.substring(lastEnd, lastEnd+1) == '"' && inStr.subString(m.start()-1, m.start()) == '"'){
                                keepSearching = false;
                            }
                        }
                    }
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                }
                else
                {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                
                regexFindCount++;
            }

            // Note: Using region() to advance instead of substring() saves 
            // drastically on heap size. Nonetheless, we still must reset the 
            // (unmodified) input sequence to avoid a 'Regex too complicated' 
            // error.
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            
            regexFindCount = 0;
        }
        
        return output;
    }


	public static void updateRecords(List<List<String>> parsedCSV, String servicerFIle){
        List<Import_Configuration__mdt> mappings = [SELECT Id, sObject__c, Column_Name__c, Field_Name__c, Key__c
                                                    FROM Import_Configuration__mdt WHERE Servicer_FIle__c = : servicerFile];


        if(mappings.size() > 0){
            String externalKey = 'Id';
            for(Import_Configuration__mdt mapping: mappings){
                if(mapping.Key__c){
                    externalKey = mapping.Field_Name__c;
                }
            }


            String sobjectType = mappings[0].sobject__c;


            List<String> headers = parsedCSV.remove(parsedCSV.size()-1);

            List<parseCSV_Queueable.mapWrapper> mapping = compileMap(headers, mappings);

            Map<String, sObject> records = new Map<String, sObject>();

            System.enqueueJob(new parseCSV_Queueable( records, parsedCSV, mapping, 1000, externalKey ));

        }

    }

	public static List<parseCSV_Queueable.mapWrapper> compileMap(List<String> columns, List<Import_Configuration__mdt> mappings){
        List<parseCSV_Queueable.mapWrapper> wrappers = new List<parseCSV_Queueable.mapWrapper>();
        system.debug(LoggingLevel.WARN, columns );
        system.debug(LOGGINGLEVEL.WARN, JSON.serialize(mappings));
        for(Import_Configuration__mdt mapping : mappings){

            for(Integer i = 0; i < columns.size(); i++){
            	system.debug(LOGGINGLEVEL.WARN, mapping.Column_Name__c.toLowerCase().trim() + ' - ' + columns[i].toLowerCase().trim());
            	//system.debug(LOGGINGLEVEL.WARN, ((String)mapping.Column_Name__c).toLowerCase().trim() == ((String)columns[i]).toLowerCase().trim());
                if(mapping.Column_Name__c.toLowerCase().trim() == columns[i].toLowerCase().trim()){
                    //columnMap.put(columns[i], new mapWrapper(mapping, i));
                    wrappers.add(new parseCSV_Queueable.mapWrapper(mapping, i));
                    break;
                }

                if(i == columns.size() - 1 && mapping.Column_Name__c == 'ServicerLnId'){
                	system.debug(LOGGINGLEVEL.WARN, 'doing something stupid');
                	wrappers.add(new parseCSV_Queueable.mapWrapper(mapping, 0));
                }

            }
        }



        return wrappers;

    }

    public static String generateAuthToken(){
        Box_Setting__mdt auth_settings = [SELECT Id, Public_Key__c, Private_Key__c, Client_Id__c, Secret__c, Enterprise_Id__c, Sub_Type__c FROM Box_Setting__mdt WHERE DeveloperName = 'Auth_Setting' LIMIT 1];

        String jwtAssertion = constructJwtAssertion(auth_settings);

        String urlParameters = String.format('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer'
                                                   + '&client_id={0}&client_secret={1}&assertion={2}',
                    new String[] {auth_settings.Client_Id__c, auth_settings.Secret__c, jwtAssertion});

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.box.com/oauth2/token');
        req.setBody(urlParameters);
        req.setHeader('User-Agent', 'SF');


        req.setHeader('Accept-Encoding', 'gzip');
        req.setHeader('Accept-Charset', 'utf-8');

        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String authToken = '123131';
        if(!Test.isRunningTest()){
            HttpResponse res = new http().send(req);
        
            Map<String, Object> respBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

            authToken = (String)respBody.get('access_token');
        }
        

        return authToken;
    }

    public static string constructJwtAssertion(Box_setting__mdt settings){
        String jwtHeader = constructJwtHeader(settings);
        String jwtClaims = constructJwtClaims(settings);
        String jwtSignature = constructJwtSignature(settings, jwtHeader, jwtClaims);
        return jwtHeader + '.' + jwtClaims + '.' + jwtSignature;
        //return null;
    }

    public static String constructJwtHeader(Box_Setting__mdt settings){
        Map<String, String> header = new Map<String, String>{ 'kid'=> settings.Public_Key__c, 'typ'=>'JWT', 'alg'=>'RS256'};
        system.debug('jwtHeader = ' + JSON.serialize(header));
        return base64UrlSafe(Blob.valueOf(JSON.serialize(header)));
    }

    public static String constructJwtClaims(Box_setting__mdt settings){
        Map<String, Object> claims = new Map<String, Object>();

        claims.put('exp', Integer.valueOf(String.valueOf((DateTime.now().getTime() / 1000) + 10)) );
        claims.put('jti', servicer_Schedulable.createJti());
        claims.put('aud', 'https://api.box.com/oauth2/token');
        claims.put('box_sub_type', settings.Sub_Type__c);
        claims.put('sub', settings.Enterprise_Id__c);
        claims.put('iss', settings.Client_Id__c);

        system.debug('jwtClaims = ' + JSON.serialize(claims));
        return base64UrlSafe(Blob.valueOf(JSON.serialize(claims)));
    }

    public static String constructJwtSignature(Box_Setting__mdt settings, String jwtHeader, String jwtClaims){
        String algorithmName = 'RSA-SHA256';
        Blob input = Blob.valueOf(jwtHeader + '.' + jwtClaims);

        String privateKey = settings.Private_Key__c;
        String modifiedPrivateKey = prepareStringForBase64Decoding(settings.Private_key__c);
        Blob privateKeyBlob = EncodingUtil.base64Decode(modifiedPrivateKey);

        Blob signed = Crypto.sign(algorithmName, input, privateKeyBlob);

       return base64UrlSafe(signed);
    }


    public static String createJti() {
        String validChars = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer len = validChars.length();
        String randomString = '';

        for(Integer i=0; i<32; i++) {
            Integer rInt = Integer.valueOf(Math.rint(Math.random()*(len-1)));
            randomString += validChars.substring(rInt, rInt+1);
        }
        return randomString;
    }

    public static String prepareStringForBase64Decoding(String stringToPrepare) {
        String last4Bytes = stringToPrepare.substring(stringToPrepare.length() - 4, stringToPrepare.length());
        if (last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0, 2) + '0K';
            stringToPrepare = stringToPrepare.substring(0, stringToPrepare.length() - 4) + last4Bytes;
        } else if (last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0, 3) + 'N';
            stringToPrepare = stringToPrepare.substring(0, stringToPrepare.length() - 4) + last4Bytes;
        }
        return stringToPrepare;
    }

    public static String base64UrlSafe(Blob b) {
        return EncodingUtil.base64Encode(b).replace('+', '-').replace('/', '_');
    }

}