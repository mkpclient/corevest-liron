public class HouseCanaryResponseModel {
  public class Property_value_analysis_check {
    public String recommended_approach;
    public hc_avm_value_analysis hc_avm_value_analysis;
  }

  public class hc_avm_value_analysis {
    public Integer avm_value;
    public String avm_confidence;
    public String warning;
    public Double avm_fsd;
    public neighborhood_analysis neighborhood_analysis;
    public comp_based_analysis comp_based_analysis;
  }

  public class neighborhood_analysis {
    public integer avm_value_sqft;
    double fifth_percentile_value_per_sqft;
    double ninthfifth_percentile_value_per_sqft;
    public Boolean within_neighborhood_norms;
  }

  public class comp_based_analysis {
    public double comp_fsd;
    public Integer number_of_comps;
    double fifth_percentile_adjusted_comp_value;
    double ninthFifth_percentile_adjusted_comp_value;
    public Double avm_value_percentile_in_adjusted_comp_values;
    public Boolean within_adjusted_comp_values;
  }
  //////////////////////////////////////
  public class Property_RentalValue {
    public String Api_Code_Description;
    public Integer Api_Code;
    public Result_RetalValue Result_RetalValue = new Result_RetalValue();
  }
  public class Result_RetalValue {
    public Integer price_upr;
    public Integer price_lwr;
    public Integer price_mean;
    public Double fsd;
  }
  //////////////////////////////////////
  public class Property_Rental_Value_Forecast {
    public String Api_Code_Description;
    public Integer Api_Code;
    public Result_Retal_Value Result_Retal_Value = new Result_Retal_Value();
    public Address_Info Address_Info;
  }

  public class Result_Retal_Value {
    public month_03 month_03 = new month_03();
    public month_06 month_06 = new month_06();
    public month_12 month_12 = new month_12();
  }

  public class month_03 {
    public Integer value;
  }

  public class month_06 {
    public Integer value;
  }

  public class month_12 {
    public Integer value;
  }

  //////////////////////////////////////
  public class propert_details {
    public String Api_Code_Description;
    public Integer Api_Code;
    public Result_Detail Result_Detail = new Result_Detail();
    public Address_Info Address_Info;
  }

  public class Result_Detail {
    public propert_detail propert_detail = new propert_detail();
    public assessment assessment = new assessment();
  }

  public class propert_detail {
    public Integer no_of_buildings;
    public boolean attic;
    public Double total_bath_count;
    public Integer full_bath_count;
    public Double partial_bath_count;
    public Integer total_number_of_rooms;
    public String heating;
    public String heating_fuel_type;
    public String style;
    public Integer garage_parking_of_cars;
    public Double site_area_acres;
    public Integer number_of_units;
    public Integer building_area_sq_ft;
    public String garage_type_parking;
    public String basement;
    public String air_conditioning;
    public Boolean fireplace;
    public Boolean pool;
    public Integer no_of_stories;
    public String water;
    public Integer year_built;
    public String exterior_walls;
    public Integer number_of_bedrooms;
    public String sewer;
    public String property_type;
    public String subdivision;
    public Integer building_quality_score;
    public Integer building_condition_score;
    public String construction_type;
    public String roof_cover;
    public String roof_type;
    public String zoning;
  }
  public class assessment {
    public String apn;
    public String assessment_year;
    public Double tax_amount;
    public Double total_assessed_value;
    public String tax_year;
  }
  /////////////////////////////////////////////////
  public class Address_Info {
    public String City;
    public String County_Fips;
    public String Geo_Precision;
    public String Zipcode;
    public String Address_Full;
    public String Slug;
    public String Block_id;
    public String Blockgroup_id;
    public String State;
    public String Zipcode_Plus4;
    public String Address;
    public String Lat;
    public String Lng;
    public String Unit;
    public String Msa;
    public String Metrodiv;
    public status Status;
    public requested_item Requested_Item;
  }

  public class Status {
    public Boolean Match;
    public List<String> Details;
    public List<String> Errors;
    public List<String> Changes;
  }

  public class Requested_item {
    public String Address;
    public String Zipcode;
    public String Address_Id;
  } //
  /////////////////////////////////////////////////
  public class property_sales_history {
    public String api_code_description;
    public Integer api_code;
    public List<result_sales_history> result_sales_history = new List<result_sales_history>();
    //Address_Info Address_Info;
  }

  public class result_sales_history {
    public String event_type;
    public String grantee_1;
    public String grantee_1_forenames;
    public String grantee_2;
    public String grantee_2_forenames;
    public String record_page;
    public Decimal amount;
    public String grantor_1;
    public String grantor_1_forenames;
    public String grantor_2;
    public String apn;
    public String record_date;
    public String fips;
    public String record_doc;
    public String record_book;
  }
  ////////////////////////////////////////////////
  public class property_mortgage_lien_all {
    public String Api_Code_Description;
    public Integer Api_Code;
    public List<result_mortgage_liens_all> result_mortgage_lien_all = new List<result_mortgage_liens_all>();
    //public Address_Info Address_Info;
  }

  public class result_mortgage_liens_all {
    public String fips;
    public String apn;
    public Double amount;
    public String due_date;
    public String event_type;
    public String grantee_1;
    public String grantee_1_forenames;
    public String grantee_2;
    public String grantee_2_forenames;
    public String grantor_1;
    public String grantor_2;
    public Double interest_rate;
    public String record_book;
    public String record_date;
    public String record_doc;
    public String record_page;
    public Integer mortgage_years;
    public Double thirty_yr;
    public Double fifteen_yr;
    public Double hc_interest_rate;
    public String lien_type;
    public Boolean heloc;
    public Boolean stand_alone_refi;
    public String lender_type;
    public String arm_index;
  }
  ////////////////////////////////////////////////
  public class property_flood {
    public String Api_Code_Description;
    public Integer Api_Code;
    public result_flood result_flood = new result_flood();
    // public Address_Info Address_Info;
  }

  public class result_flood {
    public String effective_date;
    public String zone;
    public String flood_risk;
    public String panel_number;
  }
  ////////////////////////////////////////////////
  public class property_block_crime {
    public String Api_Code_Description;
    public Integer Api_Code;
    public result_block_crime result_block_crime = new result_block_crime();
    public Address_Info Address_Info;
  }

  public class result_block_crime {
    public block_crime_dtls all = new block_crime_dtls();
    public block_crime_dtls property = new block_crime_dtls();
    public block_crime_dtls violent = new block_crime_dtls();
    public block_crime_dtls other = new block_crime_dtls();
  }

  public class block_crime_dtls {
    public Integer incidents;
    public Integer county_percentile;
    public Integer nation_percentile;
  }
  ////////////////////////////////////////////////
  public class property_tax_history {
    public String Api_Code_Description;
    public Integer Api_Code;
    public List<result_tax_history> result_tax_history = new List<result_tax_history>();
    //public Address_Info Address_Info;
  }

  public class result_tax_history {
    public String apn;
    public String assessment_year;
    public String tax_year;
    public Integer total_assessed_value;
    public Integer tax_amount;
  }
  //////////////////////////////////////
  public class Property_ValueReport {
    public String Api_Code_Description;
    public Integer Api_Code;
    public Result_ValueReport Result_ValueReport = new Result_ValueReport();
  }
  public class Result_ValueReport {
    public String link;
  }
}