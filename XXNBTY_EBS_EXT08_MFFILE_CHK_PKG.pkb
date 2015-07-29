CREATE OR REPLACE PACKAGE BODY       XXNBTY_EBSEXT08_MFFILE_CHK_PKG

----------------------------------------------------------------------------------------------
/*
Package Name: XXNBTY_EBSEXT08_MFFILE_CHK_PKG
Author's Name: Erwin Ramos
Date written: 04-May-2015
RICEFW Object: N/A
Description: This program will validate and load the EBS Interface program. 
             
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
27-May-2015				 	Erwin Ramos				Initial Development

*/
--------------------------------------------------------------------------------------------


IS
 PROCEDURE exec_request_set (x_errbuf 		OUT VARCHAR2
							,x_retcode     OUT VARCHAR2
							,P_INCOMING		VARCHAR2
							,P_ARCHIVED	VARCHAR2
                            ,P_OBJECT_NAME 		VARCHAR2
							) 
IS
						v_req_id 		NUMBER;
						v_dev_status 	VARCHAR2 (2000);
						v_dev_phase 	VARCHAR2 (2000);
						v_request_status  BOOLEAN;
						p_request_id 	number;
						v_layout BOOLEAN;
						--v_request_status BOOLEAN;
						v_phase VARCHAR2 (2000);
						v_wait_status VARCHAR2 (2000);
						--v_dev_phase VARCHAR2 (2000);
						v_message VARCHAR2 (2000);
						P_SERVER_INSTANCE_NAME                   VARCHAR2(100);
						P_FLAT_FILE_LOCATION                  VARCHAR2(30);
						P_mesg                    VARCHAR2(30)    := NULL;
						P_RICEFW_NAME                VARCHAR2(100);
						P_ALLOW_SEND_IF_NO_ERROR               VARCHAR2(100);
						success 	NUMBER;
						l_error_msg	VARCHAR2 (2000);
						le_ebs_validation 	EXCEPTION;
						v_program 	VARCHAR2(100);
						v_mess				VARCHAR2(1000);
						v_step				NUMBER;
						c_bom_yes	VARCHAR2(20)   :='1'; -- 'Yes'
						c_bom_no	VARCHAR2(20)   :='2'; -- 'No'
            v_org_id  mtl_parameters.organization_id%TYPE;
            c_interval NUMBER :=15;
            
            cursor c_org_id
            is
            select organization_id
            from mtl_parameters
            where organization_code = 'P19'; 
            
BEGIN
	---Execution of formula programs
   v_step := 1;
   IF UPPER(P_OBJECT_NAME) = 'FORMULA' 
	THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_FORMULA_CONSOLIDATE');
			v_req_id:=NULL;
			v_step := 2;
			v_program := 'XXNBTY_OPM_FORMULA_CONSOLIDATE';
			
		   v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_FORMULA_CONSOLIDATE'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING
                        ,argument2    => P_ARCHIVED
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 3;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_FORMULA_REQUEST_SET Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_FORMULA_REQUEST_SET Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 4;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			v_step := 5;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_FOMULA_ST_LOAD');
			v_program := 'XXNBTY_OPM_FOMULA_ST_LOAD';

			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_FOMULA_ST_LOAD'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING||'/XXNBTY_FORMULA.dat'
												);				
					
			FND_CONCURRENT.AF_COMMIT;	
	
			v_step := 6;	
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_FOMULA_ST_LOAD Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_FOMULA_ST_LOAD Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 7;
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 8;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_FORMULA_LOAD_BASE');
			v_program := 'XXNBTY_OPM_FORMULA_LOAD_BASE';
			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_FORMULA_LOAD_BASE'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												);				
					
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 9;
		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_FORMULA_REQUEST_SET Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_FORMULA_LOAD_BASE Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 10;

				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_FORMULA_REQUEST_SET Program Request Dev status' || '-'||  v_dev_status);
			v_step := 11;		
	END IF;	
	
	---Execution of BOM programs
	v_step := 12;	
	IF UPPER(P_OBJECT_NAME) = 'BOM' 
	THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_FILE_TRANSFORM');
			v_req_id:=NULL;
			v_step := 13;
			v_program := 'XXNBTY_BOM_INT_FILE_TRANSFORM';
			
		   v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_BOM_INT_FILE_TRANSFORM'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING
                        ,argument2   	=> P_ARCHIVED                        
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 14;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_BOM_INT_FILE_TRANSFORM Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_BOM_INT_FILE_TRANSFORM Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 15;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_BILLS_OF_MTL_REQUEST_SET Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_BILLS_OF_MTL_REQUEST_SET Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			v_step := 16;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_HEADER_LOAD');
			v_program := 'XXNBTY_BOM_INT_HEADER_LOAD';

			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_BOM_INT_HEADER_LOAD'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING||'/XXNBTY_BOM.dat'
												);				
					
			FND_CONCURRENT.AF_COMMIT;	

			v_step := 17;	
		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_BOM_INT_HEADER_LOAD Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_BOM_INT_HEADER_LOAD Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 18;
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_HEADER_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_HEADER_LOAD Program Request Dev status' || '-'||  v_dev_status);

			v_step := 19;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_COMPONENT_LOAD');			
			v_program := 'XXNBTY_BOM_INT_COMPONENT_LOAD';
			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_BOM_INT_COMPONENT_LOAD'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING||'/XXNBTY_BOM_COMPONENT.dat'
												);							
					
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 20;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_COMPONENT_LOAD');
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_BOM_INT_COMPONENT_LOAD Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_BOM_INT_COMPONENT_LOAD Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 21;

				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_COMPONENT_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_COMPONENT_LOAD Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 22;		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_HEADER');
			v_program := 'XXNBTY_BOM_INT_HEADER';
			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_BOM_INT_HEADER'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												);							
					
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 23;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_BOM_INT_HEADER Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_BOM_INT_HEADER Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 24;

				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_HEADER Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_HEADER Program Request Dev status' || '-'||  v_dev_status);
			v_step := 25;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_BOM_INT_COMPONENT');
			v_program := 'XXNBTY_BOM_INT_COMPONENT';
			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_BOM_INT_COMPONENT'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												);							
					
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 26;
		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_BOM_INT_COMPONENT Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_BOM_INT_COMPONENT Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 27;

				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_COMPONENT Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_BOM_INT_COMPONENT Program Request Dev status' || '-'||  v_dev_status);
		
      open c_org_id;
      fetch c_org_id into v_org_id;
      close c_org_id;
    
			v_step := 28;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of Bills of Material standard program');
			v_program := 'XXNBTY_BOM_INT_COMPONENT';
			v_req_id := FND_REQUEST.SUBMIT_REQUEST(application 	=> 'BOM'
												,program 		=> 'BMCOIN'
												,start_time   	=> NULL
												,sub_request  	=> FALSE
												,argument1   	=> v_org_id
												,argument2   	=> c_bom_yes
												,argument3		=> c_bom_no
												,argument4		=> c_bom_yes
												,argument5		=> c_bom_no
												,argument6		=> ''
												);							
					
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 29;
		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the Bills of Material standard Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the Bills of Material standard Program');
			 v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			v_step := 30;

				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
			
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Bills of Material standard Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Bills of Material standard Program Request Dev status' || '-'||  v_dev_status);
		
	END IF;
	
	---Execution of CUSTOMER programs
	v_step := 31;	
	IF UPPER(P_OBJECT_NAME) = 'CUSTOMER' 
	THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_AR_CUSTOMER_ARCHIVE');
			v_req_id:=NULL;
			v_step := 32;
			v_program := 'XXNBTY_AR_CUSTOMER_ARCHIVE';
			
		   v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_AR_CUSTOMER_ARCHIVE'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING
                        ,argument2   	=> P_ARCHIVED
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 34;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_AR_CUSTOMER_ARCHIVE Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_AR_CUSTOMER_ARCHIVE Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 35;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_ARCHIVE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_ARCHIVE Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_ARCHIVE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_ARCHIVE Program Request Dev status' || '-'||  v_dev_status);
		
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY Customer Data Load');
			v_program := 'XXNBTY Customer Data Load';
			
		   v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_AR_CUSTOMER_LOAD'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING||'/Customer.dat'
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 36;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_AR_CUSTOMER_LOAD Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_AR_CUSTOMER_LOAD Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 37;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_LOAD Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_LOAD Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 38;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_AR_CUSTOMER_VALIDATE');
			v_program := 'XXNBTY_AR_CUSTOMER_VALIDATE';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_AR_CUSTOMER_VALIDATE'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> 'No'
												,argument2		=> 'ASCP_PLANNER'
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 39;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_AR_CUSTOMER_VALIDATE Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_AR_CUSTOMER_VALIDATE Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 40;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_VALIDATE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_VALIDATE Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_VALIDATE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_VALIDATE Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 41;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of Customer Interface');
			v_program := 'RACUST';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'AR'
												,program 		=> 'RACUST'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> 'No'
												,argument2		=> NULL
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 42;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the Customer Interface Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the Customer Interface Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 43;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Customer Interface Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Customer Interface Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Customer Interface Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Customer Interface Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 44;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_AR_CUSTOMER_PARTY_UPDT');
			v_program := 'XXNBTY_AR_CUSTOMER_PARTY_UPDT';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_AR_CUSTOMER_PARTY_UPDT'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 45;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_AR_CUSTOMER_PARTY_UPDT Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_AR_CUSTOMER_PARTY_UPDT Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 46;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_PARTY_UPDT Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_PARTY_UPDT Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_PARTY_UPDT Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_AR_CUSTOMER_PARTY_UPDT Program Request Dev status' || '-'||  v_dev_status);
	END IF;
	
	---Execution of BATCH programs
	v_step := 47;	
	IF UPPER(P_OBJECT_NAME) = 'BATCH' 
	THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_BATCH_ARCHIVE');
			v_req_id:=NULL;
			v_step := 48;
			v_program := 'XXNBTY_OPM_BATCH_ARCHIVE';
			
		   v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_BATCH_ARCHIVE'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING
                        ,argument2    => P_ARCHIVED
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 49;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_BATCH_ARCHIVE Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_BATCH_ARCHIVE Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 50;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_ARCHIVE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_ARCHIVE Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_ARCHIVE Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_ARCHIVE Program Request Dev status' || '-'||  v_dev_status);
			
			v_step := 51;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_BATCH_LOAD');
			v_program := 'XXNBTY_OPM_BATCH_LOAD';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_BATCH_LOAD'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
												,argument1   	=> P_INCOMING||'/XXNBTY_BATCH.dat'
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 52;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_BATCH_LOAD Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_BATCH_LOAD Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 53;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_LOAD Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_LOAD Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_LOAD Program Request Dev status' || '-'||  v_dev_status);
			
			
			v_step := 54;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_BATCH_HEADER');
			v_program := 'XXNBTY_OPM_BATCH_HEADER';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_BATCH_HEADER'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 55;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_BATCH_HEADER Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_BATCH_HEADER Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 56;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_HEADER Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_HEADER Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_HEADER Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_HEADER Program Request Dev status' || '-'||  v_dev_status);
					
			v_step := 57;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  Starting of XXNBTY_OPM_BATCH_COMPONENT');
			v_program := 'XXNBTY_OPM_BATCH_COMPONENT';
			
			v_req_id := FND_REQUEST.SUBMIT_REQUEST( application 	=> 'XXNBTY'
												,program 		=> 'XXNBTY_OPM_BATCH_COMPONENT'
												,start_time   	=> TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS')
												,sub_request  	=> FALSE
											);			
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 58;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Submitted the XXNBTY_OPM_BATCH_COMPONENT Program' || '-'||  v_req_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'   Waiting for the XXNBTY_OPM_BATCH_COMPONENT Program');
			v_request_status:=fnd_concurrent.wait_for_request(request_id => v_req_id,
													INTERVAL => c_interval,
													max_wait => '',
													phase => v_phase,
													status => v_wait_status,
													dev_phase => v_dev_phase,
													dev_status => v_dev_status,
													MESSAGE => v_message);
			FND_CONCURRENT.AF_COMMIT;	
			
			v_step := 59;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_COMPONENT Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_COMPONENT Program Request Dev status' || '-'||  v_dev_status);					
		
				IF v_dev_status = 'ERROR'
				THEN
					RAISE le_ebs_validation;
				END IF;
				
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_COMPONENT Program Request Phase' || '-'||  v_dev_phase);
			FND_FILE.PUT_LINE(FND_FILE.LOG,'  XXNBTY_OPM_BATCH_COMPONENT Program Request Dev status' || '-'||  v_dev_status);
	END IF;	
	
EXCEPTION
	
	WHEN le_ebs_validation THEN 
		x_errbuf := 'Error on program ' || v_program ;
		x_retcode := 2;
		FND_FILE.PUT_LINE(FND_FILE.LOG, x_errbuf);
	WHEN OTHERS THEN
	    v_mess := 'At step ['||v_step||'] for exec_concurrent_main procedure - SQLCODE [' ||SQLCODE|| '] - ' ||substr(SQLERRM,1,100);
		x_errbuf := v_mess;
		x_retcode := 2;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Error message : ' || x_errbuf);	
	 
		 
END exec_request_set;		 
		 
END XXNBTY_EBSEXT08_MFFILE_CHK_PKG;
/

show errors;
