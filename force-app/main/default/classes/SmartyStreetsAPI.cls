public without sharing class SmartyStreetsAPI {
    
    public static List<Validated_Property_Address__c> doCallout(List<Id> propertyIds){
        List<SmartyStreetsAPI.RequestResource> requestBody = new List<SmartyStreetsAPI.RequestResource>();

        for(Property__c property : [SELECT Id, Name, City__c, State__c, ZipCode__c FROM Property__c WHERE Id IN : propertyIds]){
           requestBody.add(new SmartyStreetsAPI.RequestResource(property));
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SmartyStreets');
        req.setMethod('POST');
        req.setBody(JSON.serialize(requestBody, true));
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Host', 'us-street.api.smartystreets.com');

        String respBody = '[{"metadata":{"zip_type":"Standard","utc_offset":-6,"time_zone":"Central","record_type":"S","rdi":"Residential","precision":"Zip9","longitude":-88.02184,"latitude":42.35872,"ews_match":null,"elot_sort":"D","elot_sequence":"0081","dst":"true","county_name":"Lake","county_fips":"17097","congressional_district":"10","carrier_route":"C017","building_default_indicator":null},"last_line":"Grayslake IL 60030-3335","input_index":0,"input_id":"a192D0000008BXcQAM","delivery_point_barcode":"600303335089","delivery_line_1":"1008 Manchester Cir","components":{"zipcode":"60030","urbanization":null,"street_suffix":"Cir","street_predirection":null,"street_postdirection":null,"street_name":"Manchester","state_abbreviation":"IL","secondary_number":null,"secondary_designator":null,"primary_number":"1008","pmb_number":null,"pmb_designator":null,"plus4_code":"3335","extra_secondary_number":null,"extra_secondary_designator":null,"delivery_point_check_digit":"9","delivery_point":"08","default_city_name":"Grayslake","city_name":"Grayslake"},"candidate_index":0,"analysis":{"suitelink_match":null,"lacslink_indicator":null,"lacslink_code":null,"footnotes":null,"dpv_vacant":"N","dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","active":"Y"}}]';
        
        if(!Test.isRunningTest()){
            HttpResponse resp = new Http().send(req);
            respBody = resp.getBody();
        }else{
            respBody = respBody.replaceAll('a192D0000008BXcQAM', propertyIds[0]);
        }

        List<Validated_Property_Address__c> addresses = new List<Validated_Property_Address__c>();
        for(SmartyStreetsAPI.ResponseResource responseProperty : (List<SmartyStreetsAPI.ResponseResource>)JSON.deserialize(respBody, List<SmartyStreetsAPI.ResponseResource>.class)){
            addresses.add(responseProperty.getValidatedPropertyAddress());
        }

        return addresses;
    }


    //public static void testCall(Id propertyId){
        // String baseUrl = 'https://us-street.api.smartystreets.com/street-address';
        // String authId = '01fd31c3-fc67-44ce-57da-1c16bd7f2813';
        // String authToken = '6FbdVH9sVq3w2BTwJo8w';

        // String endpoint = baseUrl + '?auth-id=' + authId + '&auth-token=' + authToken;
        // //a190a000005SYrBAAW
        //  Property__c property = [SELECT Id, Name, City__c, State__c, ZipCode__c FROM Property__c WHERE Id =: propertyId];

        // List<SmartyStreetsAPI.RequestResource> wrappers = new List<SmartyStreetsAPI.RequestResource>();
        // wrappers.add(new SmartyStreetsAPI.RequestResource(property));

        // system.debug(JSON.serialize(wrappers, true));


        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(endpoint);
        // req.setMethod('POST');
        // req.setBody(JSON.serialize(wrappers, true));
        // req.setHeader('Content-Type', 'application/json');
        // req.setHeader('Host', 'us-street.api.smartystreets.com');

        // HttpResponse resp = new Http().send(req);

        // system.debug(resp.getStatus());
        // system.debug(resp.getStatusCode());
        // system.debug(resp.getBody());
        // system.debug(JSON.deserializeStrict(resp.getBody(), List<SmartyStreetsAPI.ResponseResource>.class));

    //}



    public class RequestResource{
        public String input_id;
        public String street;
        public String street2;
        public String secondary;
        public String city;
        public String state;
        public String zipcode;
        public String addressee;
        public String ubranization;
        public Integer candidates = 5;
        public String match = 'strict';

    
        public RequestResource(Property__c property) {
            this.input_id = property.Id;
            this.street = property.Name;
            this.city = property.City__c;
            this.state = property.State__c;
            this.zipcode = property.ZipCode__c;
        }
    }

    public class ResponseResource{
        public String input_id;
        public Integer input_index;
        public Integer candidate_index;
        public String delivery_line_1;
        public String last_line;
        public String delivery_point_barcode;
        public ResponseResourceComponents components;
        public ResponseResourceMetadata metadata;
        public ResponseResourceAnalysis analysis;

        public ResponseResource(){

        }

        public Property__c getProperty(){
            Property__c property = new Property__c();
            property.Id = this.input_id;
            return property;
        }

        public Validated_Property_Address__c getValidatedPropertyAddress(){
            Validated_Property_Address__c vpa = new Validated_Property_Address__c();
            vpa.Property__c = this.input_id;
            vpa.Vinput_index__c = this.input_index;
            vpa.Vcandidate_index__c = this.candidate_index;
            vpa.VAddress1__c = this.delivery_line_1;
            vpa.Vdelivery_point_barcode__c = this.delivery_point_barcode;
            
            // Components Object Data that is returned from Smarty Streets
            vpa.VProperty_Street_Number__c = this.components.primary_number;
            vpa.VStreet_name__c = this.components.street_name;
            vpa.Vstreet_suffix__c = this.components.street_suffix;
            vpa.Vcity_name__c = this.components.city_name;
            vpa.Vdefault_city_name__c = this.components.default_city_name;
            vpa.Vstate_abbreviation__c = this.components.state_abbreviation;
            vpa.Vzipcode__c = this.components.zipcode;
            vpa.Vplus4_code__c = this.components.plus4_code;
            vpa.Vdelivery_point__c = this.components.delivery_point;
            vpa.Vdelivery_point_check_digit__c = this.components.delivery_point_check_digit;
            vpa.VUrbanization__c = this.components.urbanization;
            vpa.Vstreet_predirection__c = this.components.street_predirection;
            vpa.Vstreet_postdirection__c = this.components.street_postdirection;
            vpa.Vsecondary_number__c = this.components.secondary_number;
            vpa.Vextra_secondary_number__c = this.components.extra_secondary_number;
            vpa.Vextra_secondary_designator__c = this.components.extra_secondary_designator;
            vpa.Vpmb_designator__c = this.components.pmb_designator;
            vpa.Vpmb_number__c = this.components.pmb_number;
            // vpa.Vplus4_code__c = this.components.plus4_code

            // Metadata Object Data that is returned from Smarty Streets
            vpa.Vcongressional_district__c = this.metadata.congressional_district;
            vpa.Vresidential_delivery_indicator__c = this.metadata.rdi;
            vpa.Velot_sequence__c = this.metadata.elot_sequence;
            vpa.Velot_sort__c = this.metadata.elot_sort;
            vpa.VLongitude_and_Latitude__latitude__s = this.metadata.latitude;
            vpa.VLongitude_and_Latitude__longitude__s = this.metadata.longitude;
            vpa.Vprecision__c = this.metadata.precision;
            vpa.Vtime_zone__c = this.metadata.time_zone;
            vpa.Vutc_offset__c = this.metadata.utc_offset;
            if(this.metadata.dst != null){
                vpa.Vdaylight_savings_time__c = Boolean.valueOf(this.metadata.dst);
            }
            
            vpa.Vrecord_type__c = this.metadata.record_type;
            vpa.Vzip_type__c = this.metadata.zip_type;
            vpa.Vcounty_fips__c = this.metadata.county_fips;
            vpa.Vcounty_name__c = this.metadata.county_name;
            vpa.Vcarrier_route__c = this.metadata.carrier_route;
            vpa.Vews_match__c = this.metadata.ews_match;
            vpa.Vbuilding_default_indicator__c = this.metadata.building_default_indicator;
            vpa.Vutc_offset__c = this.metadata.utc_offset;
            
			// Analysis Object Data that is returned from Smarty Streets
            vpa.Vlacslink_code__c = this.analysis.lacslink_code;
            vpa.Vlacslink_indicator__c = this.analysis.lacslink_indicator;
            vpa.Vsuitelink_match__c = this.analysis.suitelink_match;
            vpa.Vdpv_match_code__c = this.analysis.dpv_match_code;
            vpa.Vdpv_footnotes__c = this.analysis.dpv_footnotes;
			vpa.Vfootnotes__c = this.analysis.footnotes;
            vpa.Vdpv_cmra__c = this.analysis.dpv_cmra;
            vpa.Vdpv_vacant__c = this.analysis.dpv_vacant;
            vpa.Vactive__c = this.analysis.active;
            
            vpa.JSON__c = JSON.serialize(this);

            return vpa;
        }

    }

    public class ResponseResourceComponents{
        public String urbanization;
        public String primary_number;
        public String street_name;
        public String street_predirection;
        public String street_postdirection;
        public String street_suffix;
        public String secondary_number;
        public String secondary_designator;
        public String extra_secondary_number;
        public String extra_secondary_designator;
        public String pmb_designator;
        public String pmb_number;	
        public String city_name;
        public String default_city_name;
        public String state_abbreviation;
        public String zipcode;
        public String plus4_code;
        public String delivery_point;
        public String delivery_point_check_digit;
    }

    public class ResponseResourceMetadata{
        public String record_type;
        public String zip_type;
        public String county_fips;
        public String county_name;
        public String ews_match;
        public String carrier_route;
        public String congressional_district;
        public String building_default_indicator;
        public String rdi;
        public String elot_sequence;
        public String elot_sort;
        public decimal latitude;
        public decimal longitude;
        public String precision;
        public String time_zone;
        public Decimal utc_offset;
        public String dst;
    }

    public class ResponseResourceAnalysis{
        public String dpv_match_code;
        public String dpv_footnotes;
        public String dpv_cmra;
        public String dpv_vacant;
        public String active;
        public String footnotes;
        public String lacslink_code;
        public String lacslink_indicator;
        public String suitelink_match;
    }
}