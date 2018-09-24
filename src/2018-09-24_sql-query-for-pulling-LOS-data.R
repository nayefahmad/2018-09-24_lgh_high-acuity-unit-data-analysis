

#*********************************************************
# SQL QUERY TO PULL LOS DATA IN SPECIFIED UNIT
#*********************************************************

library("here")
library("magrittr")
library("stringr")
library("sqldf")
library("RODBC")


# 0) specify ODBC connection: ----------------
cnx <- odbcConnect("cnx_SPDBSCSTA001") 


# 1) copy query in from SQL Server: ------------
# note: first remove comments 
sqlstring <- "Select [ADTCMart].[ADTC].[vwAdmissionDischargeFact].ContinuumID 
	, [ADTCMart].[ADTC].[vwTransferFact].ContinuumID 
, [ADTCMart].[ADTC].[vwAdmissionDischargeFact].AccountNumber 
, [ADTCMart].[ADTC].[vwTransferFact].AccountNum
, AdmissionNursingUnitCode
, AdmissionFiscalYear
, [AdjustedAdmissionDate]
, [AdjustedAdmissionTime]
, AdjustedDischargeDate
, AdjustedDischargeTime
, [TransferDate]
, TransferTime
, FromNursingUnitCode 
, FromBed
, [ToNursingUnitCode] 
, ToBed

From [ADTCMart].[ADTC].[vwAdmissionDischargeFact]  
full outer join [ADTCMart].[ADTC].[vwTransferFact] 
on [ADTCMart].[ADTC].[vwAdmissionDischargeFact].ContinuumId = [ADTCMart].[ADTC].[vwTransferFact].ContinuumId
Where (AdmissionFacilityLongName = 'Lions Gate Hospital' ) 
and (AdmissionFiscalYear = '2018' ) 
and (AdmissionNursingUnitCode in ('IPS')
or [ADTCMart].[ADTC].[vwTransferFact].ToNursingUnitCode = 'IPS')
and [ADTCMart].[ADTC].[vwTransferFact].TransferDate >= '2017-04-01'   
order by AdmissionNursingUnitCode
, [AdjustedAdmissionDate]
, [AdjustedAdmissionTime]
, [ADTCMart].[ADTC].[vwTransferFact].TransferDate
, [ADTCMart].[ADTC].[vwTransferFact].TransferTime;"


# 2) Cleanup whitespaces: --------------
sqlstring <- gsub("\\t", "", sqlstring)  # remove tabs 
sqlstring <- gsub("\\n", "", sqlstring)  # remove carriage returns 

sqlstring

# 3) Pull data: ---------------
df1.losdata <- data.frame(sqlQuery(cnx, sqlstring))

df1.losdata[1]

