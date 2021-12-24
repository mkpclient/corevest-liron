global class PropertyCustomSortCls{
        
        
        
        static List<property__c> propertyList;
        
        /***
         * @ param  list of properties as input 
         * Description sort Propery by street number
         * @return Sorted list of property by street number 
         * * Author : Trivikram
         ***/
         
        public static List<Property__c> getProperty(List<Property__c> lps){
        list<PropertyCustomSort> result = new list<PropertyCustomSort>();
        List<property__c> alphaCharacters = new list<property__c>();
        propertyList = lps;
        for(Integer i=0;i<=lps.size()-1;i++){
            Integer PropStreetNumber =0;
            String PropStreetAddress='';
            List<String> stNo= propertyList[i].Name.split(' ');
            if(stNo.size()>0 && stNo[0]!=null)
            {
                String val ='';
                if(stNo[0].contains('-'))
                {
                List<String> str = stNo[0].split('-');
                for(Integer m=0;m<=str.size()-1;m++){
                    val =str[0] ;
                }
                }
                else{                   
                val =stNo[0].replaceAll(' ','');
                }     
                if(val.length()>0 && val.isNumeric())
                {
                PropStreetNumber  = Integer.valueof(val);
                }
                else if(val.isAlphanumeric()&& val.trim().length()>0)
                {
                String finalval='';
                List<String> stringCharacters = val.split('');
                for(Integer j=0;j<=stringCharacters.Size()-1;j++) {
                if(stringCharacters[j].isNumeric()){
                //numericCharacters.add(stringCharacters[j]);
                finalval = finalval+stringCharacters[j];
                }
                }
                System.debug(finalval);
                if(finalval.length()>0)
                try{
                    PropStreetNumber = Integer.valueof(finalval);
                }catch(Exception e){
                    PropStreetNumber = 0;
                }
                
                else{
                    alphaCharacters.add(propertyList[i]); 
                    continue;
                }
                }
                
                PropStreetAddress =  propertyList[i].name.removeStart(stNo[0]).trim();
                
            }else{
                if(propertyList[i].Name.isAlphanumeric()){alphaCharacters.add(propertyList[i]);continue;
                }
                else  PropStreetNumber = Integer.valueof(((propertyList[i].Name).replaceALL('-','')));
                
             }    
             PropertyCustomSort propObj= new PropertyCustomSort( propertyList[i],PropStreetAddress,PropStreetNumber);
            result.add(propObj);   
        } 
        system.debug(result);
        result.sort();
        List<Property__c> sortList = new List<Property__c>();
        for(Integer i=0;i<=result.size()-1;i++){
            sortList.add(result[i].p);
        }
        sortList.addAll(alphaCharacters);
        return sortList;
        }
        
    
        public class PropertyCustomSort implements Comparable {
            public Property__c p;
            public Integer streetNumber;
            public String address;
            
            public PropertyCustomSort (Property__c pp,String ad, Integer sn){
                address= ad;
                streetNumber= sn;
                p = pp;
            }
            
            public Integer compareTo(Object ObjToCompare) {
            
                PropertyCustomSort obj = (PropertyCustomSort) ObjToCompare; 
                //system.debug(obj);
                if( streetNumber>0 && String.isNotBlank(address)){
                 Integer resObj =address.compareTo(obj.address);
                 //system.debug(resObj);// && (address.compareTo(obj.address))>1
                 Integer val1 =  streetNumber-obj.streetNumber;
                 Integer val2 = address.compareTo(obj.address);

                 return val1;

                }
                else{
                    return 1;
                }
    
            }
        
        }
        }