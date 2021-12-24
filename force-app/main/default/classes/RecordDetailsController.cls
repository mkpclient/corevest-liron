public without sharing class RecordDetailsController {
	public static sObject record;
	public static Map<String, Schema.DescribeFieldResult> fieldDescribeMap;
	public static Map<String, String> labelMap;
	@AuraEnabled
	public static Layout getCommunityDetails(Id recordId){
		community_Controller.UserResource user = (community_Controller.UserResource)JSON.deserialize(community_Controller.getUser(), community_Controller.UserResource.class);


		String sobjectType = recordId.getSObjectType().getDescribe().getName();
		if(CommunityController.checkAccess(recordId)){
			fieldDescribeMap = util.getFieldDescribeMap(sobjectType);
			labelMap = compileLabels(sobjectType);
			record = util.getFullObjectById(sobjectType, recordId);

			String recordTypeName = [SELECT Id, DeveloperName FROM RecordType WHERE Id = : String.valueOf(record.get('RecordTypeId')) LIMIT 1].DeveloperName;

			if(recordTypeName == 'Bridge_Renovation' || recordTypeName == 'Ground_Up_Construction' ){
				recordTypeName = 'Bridge Reno';
			}else if(recordTypeName == 'Bridge_No_Renovation' || recordTypeName == 'LOC_Loan'){
				recordTypeName = 'Bridge';
			}else if(recordTypeName == 'Term_Loan'){
				recordTypeName = 'Term';
			}

			String pageLayoutName = sobjectType +'-Portal '+recordTypeName;
			if(user.userType == 'vendor'){
				pageLayoutName += ' Vendor';
			}else if(user.userType == 'borrower'){
                 // @ Description Change stage names in portal for borrower view
                // @ return Closed or In Underwriting
                // @ Author Trivikram    
                if(sobjectType == 'Opportunity' && record.get('StageName')=='Closed Won')
                    record.put('StageName','Closed');
                 else if(sobjectType == 'Opportunity' && (record.get('StageName')=='UW Hold' || record.get('StageName')=='Underwriting' ))
                    record.put('StageName','In Underwriting');
				pageLayoutName += ' Borrower';
			}

			if(sobjectType == 'Opportunity' && (record.get('StageName') == 'Closed Won' || 
												record.get('StageName') == 'Expired' ||
												record.get('StageName') == 'Matured' )
												){
				pageLayoutName += ' Closed Won';
			}
			system.debug(pageLayoutName);

			List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(
												Metadata.MetadataType.Layout, 
												new List<String>{pageLayoutName}
												);

			return new Layout((Metadata.Layout)layouts[0], null);

		}else{
			return null;
		}
	}
	

	public class Layout{
		@AuraEnabled public List<Section> sections;

		Layout(Metadata.Layout layoutMetadata, sObject record){
			this.sections = new List<Section>();

			for(Metadata.LayoutSection layoutSection : layoutMetadata.layoutSections){
				if(layoutSection.label != 'System Information' && layoutSection.label != 'Custom Links')
					this.sections.add(new Section(layoutSection));
			}
		}
	}

	public class Section{
		@AuraEnabled public List<Column> columns;
		@AuraEnabled public String style;
		@AuraEnabled public String label;

		Section(Metadata.LayoutSection layoutSection){
			this.columns = new List<Column>();
			this.label = layoutSection.label;
			//this.style = layoutSection.style;

			for(Metadata.LayoutColumn column : layoutSection.layoutColumns){
				this.columns.add(new Column(column));
			}
			//system.debug(JSON.serialize(layoutSection));
		}
	}

	public class Column{
		@AuraEnabled public List<Field> fields;

		Column(Metadata.LayoutColumn layoutColumn){
			this.fields = new List<Field>();

			if(layoutColumn.layoutItems != null){
				for(MetaData.LayoutItem item : layoutColumn.layoutItems){
					if(item.field != null){
						this.fields.add(new Field(item));
					}
				}
			}
		}
	}

	public class Field{
		@AuraEnabled public Object val;
		@AuraEnabled public String label;
		@AuraEnabled public String fieldName;
		@AuraEnabled public String fieldType;
		@AuraEnabled public String behavior;

		Field(MetaData.LayoutItem item){
			this.fieldName = item.field;
			system.debug(item);
			this.fieldType = String.valueOf(fieldDescribeMap.get(item.field).getType());

			this.label = String.valueOf(fieldDescribeMap.get(item.field).getLabel());
			if(labelMap.containsKey(item.field.toLowerCase())){
				this.label = labelMap.get(item.field.toLowerCase());
			}
			//if(this.fieldType != 'REFERENCE'){
				this.val = record.get(item.field);
			//}
			//this.behavior = (String)item.behavior;
		}
	}

	// public static Boolean hasAccess(String recordId, String sobjectType, community_Controller.UserResource user){
	// 	Boolean hasAccess = false;
	// 	system.debug('--hasAccess--');
	// 	system.debug(user);
	// 	system.debug(sobjectType);
	// 	if(user.userType == 'vendor'){
	// 		hasAccess = checkVendorAccess(recordId, sobjectType, user);
	// 	}else if(user.userType == 'borrower'){
	// 		hasAccess = checkBorrowerAccess(recordId, sobjectType, user);
	// 	}
	// 	return hasAccess;
	// }

	// public static Boolean checkVendorAccess(String recordId, String sobjectType, community_Controller.UserResource user){

	// 	if(sobjectType == 'Opportunity'){
	// 		Id vendorId = user.accountId;
	// 		return ([SELECT Id FROM Deal_Contact__c WHERE Deal__c =: recordId AND Account__c =: vendorId].size() > 0);
	// 	}else{
	// 		return true;
	// 	}
		
		 
	// }

	// public static Boolean checkBorrowerAccess(String recordId, String sobjectType, community_Controller.UserResource user){
	// 	//return false;

	// 	if(sobjectType == 'Opportunity'){
	// 		return [SELECT Id FROM Opportunity WHERE Contact__c =: user.ContactId AND Id =: recordId].size() > 0 
	// 			|| [SELECT Id FROM Deal_Contact__C WHERE Deal__c =: recordId AND Contact__c =: user.ContactId AND Entity_Type__c = 'Portal Access'].size() > 0;
	// 	}else{
	// 		return true;
	// 	}
	// }

	public static Map<String, String> compileLabels(String sobjectType){
		labelMap = new Map<String, String>();
		for(Portal_Label__mdt label : [SELECT Id, MasterLabel, Object__c, Field_API_Name__c 
										FROM Portal_Label__mdt
										WHERE Object__c = : sobjectType]){
			labelMap.put(label.Field_API_Name__c.toLowerCase(), label.MasterLabel);
		}
		return labelMap;
	}
}