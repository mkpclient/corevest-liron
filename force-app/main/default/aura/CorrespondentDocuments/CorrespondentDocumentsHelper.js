({
	queryFiles : function(component){
    	var queryString = 'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink ';
    	queryString += ' WHERE LinkedEntityId = \'' + component.get('v.recordId') + '\'';
    	component.find('util').query(queryString, function(data){
    		
    		if(!$A.util.isEmpty(data)){
    			var idSet = '(';
    			data.forEach(function(doc){
    				idSet += '\'' + doc.ContentDocument.LatestPublishedVersionId + '\', ';
    			});

    			idSet = idSet.substring(0, idSet.lastIndexOf(','));

    			idSet += ')';

    			var docQueryString = 'SELECT Id, Type__c, Folder__c, Title, CreatedBy.Name, CreatedDate, ContentDocumentId FROM ContentVersion WHERE Id IN ' + idSet;
    			if(!$A.util.isEmpty(component.get('v.whereClause')) ){
    				docQueryString += ' AND ('+component.get('v.whereClause') + ')';
    			}

    			component.find('util').query(docQueryString, function(versionData){
    				//console.log(versionData);
    				console.log(versionData);
    				component.set('v.documents', versionData);
    			})
    		}

    	})
    }
})