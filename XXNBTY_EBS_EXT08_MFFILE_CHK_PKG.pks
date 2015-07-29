CREATE OR REPLACE PACKAGE       XXNBTY_EBSEXT08_MFFILE_CHK_PKG


----------------------------------------------------------------------------------------------
/*
Package Name: XXNBTY_EXT08_VCP_FILE_VAL_PKG
Author's Name: Erwin Ramos
Date written: 04-May-2015
RICEFW Object: N/A
Description: Package will execute the . 
             This output file will be sent to identified recipient(s) using UNIX program.
Program Style: 

Maintenance History: 

Date			Issue#		Name					Remarks	
-----------		------		-----------				------------------------------------------------
04-May-2015				 	Erwin Ramos				Initial Development


*/
--------------------------------------------------------------------------------------------
AS 

  --main procedure that will call another concurrent program to execute the checking. 
  PROCEDURE exec_request_set (x_errbuf 		OUT VARCHAR2
							,x_retcode     OUT VARCHAR2
                        	,P_INCOMING		VARCHAR2
							,P_ARCHIVED	VARCHAR2
                            ,P_OBJECT_NAME 		VARCHAR2
							 );  
							 
							 

END XXNBTY_EBSEXT08_MFFILE_CHK_PKG; 
/

show errors;



