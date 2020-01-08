/* Read data from original dataset (h1b_original) and create a new cleaned dataset (h1b_clean)
   which only include 14 variables (variables in uppercase are original variables from the dataset, 
   variables in lowercase are new variables that are generated based on original 
   variables. */
DATA zrlib.h1b_clean 
	(keep = CASE_STATUS 
			VISA_CLASS 
			EMPLOYER_COUNTRY 
			SECONDARY_ENTITY
			AGENT_REPRESENTING_EMPLOYER 
			FULL_TIME_POSITION 
			H1B_DEPENDENT 
			decision_days           /*DECISION_DATE - CASE_SUBMITTED*/
			case_submitted_month    /*Extraction of month from CASE_SUBMITTED*/
			employment_len_y        /*(EMPLOYMENT_END_DATE - EMPLOYMENT_START_DATE)/365*/
			job_cate                /*Classified based on SOC_CODE*/
			ind_cate                /*Classified based on NAICS_CODE*/
			state_cate_4            /*Classified based on 4 regions*/
			wage_cate               /*Classified based on distribution of WAGE_RATE_OF_PAY_FROM*/
		replace=yes);
	set zrlib.h1b_original;
	
	/* Set up the length for new-built categorical variables */
	length wage_cate $30 job_cate $50 ind_cate $100 state_cate_4 $10;
	
	/* Delete the "WITHDRAWN" values in CASE_STATUS;
	   Only select wages based on "Year". */
	where CASE_STATUS in ("DENIED", "CERTIFIED", "CERTIFIED-WITHDRAWN") 
		  and WAGE_UNIT_OF_PAY = "Year";
		
    /* Convert "CERTIFIED-WITHDRAWN" to "CERTIFIED" */
	if case_status = "CERTIFIED-WITHDRAWN" then case_status="CERTIFIED";
	
	/* Generate new variables */
	decision_days = DECISION_DATE - CASE_SUBMITTED;
	case_submitted_month = month(CASE_SUBMITTED);
	employment_len_y = (EMPLOYMENT_END_DATE - EMPLOYMENT_START_DATE)/365;	
	format employment_len_y 4.2;
	job_cate = substr(SOC_CODE, 1, 2);      /*Extract the first two characters*/
	ind_cate = substr(NAICS_CODE, 1, 2);    /*Extract the first two characters*/
	
	/* Classify the jobs into 23 categoried based on SOC_CODE and SOC system,
	   and switch the code to job category names. */
	if job_cate='11' then job_cate="Management";
	else if job_cate = '13' then job_cate = "Business and Financial Operations";
	else if job_cate = '15' then job_cate = "Computer and Mathematical";
	else if job_cate = '17' then job_cate = "Architecture and Engineering";
	else if job_cate = '19' then job_cate = "Life, Physical, and Social Science";
	else if job_cate = '21' then job_cate = "Community and Social Service";
	else if job_cate = '23' then job_cate = "Legal";
	else if job_cate = '25' then job_cate = "Educational Instruction and Library";
	else if job_cate = '27' then job_cate = "Arts, Design, Entertainment, Sports, and Media";
	else if job_cate = '29' then job_cate = "Healthcare Practitioners and Technical";
	else if job_cate = '31' then job_cate = "Healthcare Support";
	else if job_cate = '33' then job_cate = "Protective Service";
	else if job_cate = '35' then job_cate = "Food Preparation and Serving Related";
	else if job_cate = '39' then job_cate = "Personal Care and Service";
	else if job_cate = '37' then job_cate = "Building and Grounds Cleaning and Maintenance";
	else if job_cate = '41' then job_cate = "Sales and Related";
	else if job_cate = '43' then job_cate = "Office and Administrative Support";
	else if job_cate = '45' then job_cate = "Farming, Fishing, and Forestry";
	else if job_cate = '47' then job_cate = "Construction and Extraction";
	else if job_cate = '49' then job_cate = "Installation, Maintenance, and Repair";
	else if job_cate = '51' then job_cate = "Production";
	else if job_cate = '53' then job_cate = "Transportation and Material Moving";
	else if job_cate = '55' then job_cate = "Military Specific";
	else delete;
	
	/* Classify the industries into 20 categoried based on NAICS_CODE and 
	   North American Industry Classification System, and switch the code to 
	   industry category names. */
	if ind_cate = '11' then ind_cate = "Agriculture, Forestry, Fishing and Hunting";
	else if ind_cate = '21' then ind_cate = "Mining";
	else if ind_cate = '22' then ind_cate = "Unilities";
	else if ind_cate = '23' then ind_cate = "Construction";
	else if ind_cate in ('31', '32', '33') then ind_cate = "Manufacturing";
	else if ind_cate = '42' then ind_cate = "Wholesale Trade";
	else if ind_cate in ('44', '45') then ind_cate = "Retail Trade";
	else if ind_cate in ('48', '49') then ind_cate = "Transportation and Warehousing";
	else if ind_cate = '51' then ind_cate = "Information";
	else if ind_cate = '52' then ind_cate = "Finance and Insurance";
	else if ind_cate = '53' then ind_cate = "Real Estate Rental and Leasing";
	else if ind_cate = '54' then ind_cate = "Professional, Scientific, and Technical Services";
	else if ind_cate = '55' then ind_cate = "Management of Companies and Enterprises";
	else if ind_cate = '56' then 
		ind_cate = "Administrative and Support and Waste Management and Remediation Services";
	else if ind_cate = '61' then ind_cate = "Educational Services";
	else if ind_cate = '62' then ind_cate = "Health Care and Social Assistance";
	else if ind_cate = '71' then ind_cate = "Arts, Entertainment, and Recreation";
	else if ind_cate = '72' then ind_cate = "Accommodation and Food Services";
	else if ind_cate = '81' then ind_cate = "Other Services (except Public Administration)";
	else if ind_cate = '92' then ind_cate = "Public Administration";
	else delete;

	/* Classify the states that the employees work at into 4 categories
	   based on "Census Bureau-designated regions and divisions" from Wiki. */
	if WORKSITE_STATE in ('CT', 'ME', 'MA', 'NH', 'RI', 'VT', 'NJ', 'NY', 'PA') 
		then state_cate_4 = 'Northeast';
	else if WORKSITE_STATE in ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MO', 
		'NE', 'MN', 'ND', 'SD') 
		then state_cate_4 = 'Midwest';
	else if WORKSITE_STATE in ('AZ', 'CA', 'HI', 'NV', 'CO', 'ID', 'MT', 'NM', 
		'UT', 'WY', 'AK', 'OR', 'WA') 
		then state_cate_4 = 'West';
	else if WORKSITE_STATE in ('DE', 'MD', 'VA', 'WV', 'DC', 'AL', 'FL', 'GA', 
		'KY', 'MS', 'NC', 'SC', 'TN', 'AR', 'LA', 'OK', 'TX') 
		then state_cate_4 = 'South';
	else delete;

	/* Group the WAGE_RATE_OF_PAY_FROM based on quantiles. 
	   Q1 = 76518;
	   Q3 = 115606. */
	if WAGE_RATE_OF_PAY_FROM < 76518 then
		wage_cate = "Below $76.5K";
	else if 76502 <= WAGE_RATE_OF_PAY_FROM < 115606 then
		wage_cate = "Between $76.5K and $115.6K";
	else
		wage_cate = "Above $115.6K";	

RUN;


