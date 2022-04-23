public class HouseCanaryResponseModel {
    
    public class Property_value_analysis_check
    {
            checks	checks;
            input_params input_params;
            String recommended_approach;
            hc_avm_value_analysis hc_avm_value_analysis;
            comp_based_analysis comp_based_analysis;
    }    
	public class checks {
        Boolean All_pre_analysis_checks_passed;
        Boolean Address_is_supported;
        Boolean Address_is_complete;
        Boolean Precise_geocode_is_available_for_address;
        Boolean Property_at_address_is_of_supported_type;
        Boolean Census_block_group_information_is_available;
        Boolean Enough_information_on_neighborhood_characteristics_is_available;
        Boolean Gross_living_area_of_property_is_available_or_provided_as_input;
        Boolean Comps_available_for_analysis;
    }   
	public class input_params {
        Boolean include_comp_based_analysis;
        String street_address;
        String zipcode;
        String product_type;
    }    

	public class hc_avm_value_analysis {
        String avm_value;
        String avm_confidence;
        Double avm_fsd;
	    neighborhood_analysis neighborhood_analysis;
		comp_based_analysis comp_based_analysis;
	}
    
	public class neighborhood_analysis {
            integer avm_value_sqft;
            double fifth_percentile_value_per_sqft;
            double ninthfifth_percentile_value_per_sqft;
            Boolean within_neighborhood_norms;
        }
    
	public class comp_based_analysis {
            double comp_fsd;
            Integer number_of_comps;
            Integer fifth_percentile_adjusted_comp_value;
            Integer ninthFifth_percentile_adjusted_comp_value;
            Double avm_value_percentile_in_adjusted_comp_values;
            Boolean within_adjusted_comp_values;
        }
//////////////////////////////////////    
    public class Property_Rental_Value_Forecast
    {
    String Api_Code_Description;
    Integer Api_Code;
    Result_Retal_Value Result_Retal_Value;
    Address_Info Address_Info;
    }
    
 	public class Result_Retal_Value
    {
    month_03 Month_03;
    month_06 Month_06;
    month_12 Month_12;
    }
         
    public class Month_03
    {
    Integer Value;
    }
    
    public class Month_06
    {
    Integer Value;
    }
    
    public class Month_12
    {
    Integer Value;
    }
    
    public class Address_Info
    {
    String City;
    String County_Fips;
    String Geo_Precision;
    String Zipcode;
    String Address_Full;
    String Slug;
    String Block_id;
    String Blockgroup_id;
    String State;
    String Zipcode_Plus4;
    String Address;
    String Lat;
    String Lng;
    String Unit;
    String Msa;
    String Metrodiv;
    status Status;
    requested_item Requested_Item;
    }
            
    public class Status 
    {
    Boolean Match;
    List<String> Details;
    List<String> Errors;
    List<String> Changes;
    }        
    
    public class Requested_item 
    {
    String Address;
    String Zipcode;
    String Address_Id;
    }            

//////////////////////////////////////
public class  propert_details {
String Api_Code_Description;
Integer Api_Code;
Result_Detail Result_Detail;
Address_Info Address_Info;
}

public class Result_Detail {
propert_detail propert_detail;
Assessment Assessment;
Address_Info Address_Info;
}

public class propert_detail {
Integer no_of_buildings;
String attic;
Integer total_bath_count;
Integer full_bath_count;
Integer partial_bath_count;
Integer total_number_of_rooms;
String heating;
String heating_fuel_type;
String style;
String garage_parking_of_cars;
Double site_area_acres;
Integer number_of_units;
Integer building_area_sq_ft;
String garage_type_parking;
String basement;
String air_conditioning;
String fireplace;
String pool;
Integer no_of_stories;
String water;
Integer year_built;
String exterior_walls;
Integer number_of_bedrooms;
String sewer;
String property_type;
String subdivision;
Integer building_quality_score;
Integer building_condition_score;
String construction_type;
String roof_cover;
String roof_type;
String zoning;
}
public class assessment {
String apn;
Integer assessment_year;
Double tax_amount;
Double total_assessed_value;
Integer tax_year;
}
////////////////////////////////////////////////
public class property_sales_history {
String Api_Code_Description;
Integer Api_Code;
List<result_sales_history> result_sales_history;
Address_Info Address_Info;
}

public class result_sales_history
{
String event_type;
String grantee_1;
String grantee_1_forenames;
String grantee_2;
String grantee_2_forenames;
String record_page;
Integer amount;
String grantor_1;
String grantor_1_forenames;
String apn;
String record_date;
String grantor_2;
String grantor_2_forenames;
String fips;
String record_doc;
String record_book;
}
////////////////////////////////////////////////    
public class property_mortgage_lien_all 
{
String Api_Code_Description;
Integer Api_Code;
result_mortgage_lien_all result_mortgage_lien_all;
Address_Info Address_Info;
}

public class result_mortgage_lien_all
{
String fips;
String apn;
String amount;
String due_date;
String event_type;
String grantee_1;
String grantee_1_forenames;
String grantee_2;
String grantee_2_forenames;
String grantor_1;
String grantor_2;
Double interest_rate;
String record_book;
String record_date;
String record_doc;
String record_page;
Integer mortgage_years;
Double thirty_yr;
Double fifteen_yr;
Double hc_interest_rate;
String lien_type;
Boolean heloc;
Boolean stand_alone_refi;
String lender_type;
String arm_index;
}
////////////////////////////////////////////////  
public class property_flood
{
String Api_Code_Description;
Integer Api_Code;
result_flood result_flood;
Address_Info Address_Info;
}

public class result_flood 
{
String effective_date;
String zone;
String flood_risk;
String panel_number;
}
////////////////////////////////////////////////  
public class property_block_crime 
{
String Api_Code_Description;
Integer Api_Code;
result_block_crime  result_block_crime ;
Address_Info Address_Info;
}

Public class result_block_crime
{
block_crime_dtls all;
block_crime_dtls property;
block_crime_dtls violent;
block_crime_dtls other; 
}

public class block_crime_dtls
{
Integer incidents;
Integer county_percentile;
Integer nation_percentile;
}
////////////////////////////////////////////////
public class property_tax_history
{
String Api_Code_Description;
Integer Api_Code;
result_tax_history  result_tax_history;
Address_Info Address_Info;
}
public class result_tax_history 
{
List<Tax_History_Dtls> Tax_History_Dtl;
}

Public Class Tax_History_Dtls
{
String apn;
Integer assessment_year;
Integer tax_year;
Integer total_assessed_value;
Integer tax_amount;
}
 
}