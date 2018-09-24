

#*********************************************************
# SQL QUERY TO PULL LOS DATA IN SPECIFIED UNIT
#*********************************************************

library("here")
library("magrittr")
library("stringr")
library("sqldf")
library("RODBC")

# rm(list = ls())

# 0) specify parameters: ----------------
cnx <- odbcConnect("cnx_SPDBSCSTA001") # ODBC connection
nursing.unit <- "ICU"
site = "Lions Gate Hospital"
admit.fiscal.year <- "2018"
transfer.date.after <- "2017-04-01"  # todo: rewrite query to automatically select right transfer date start point


# 1) copy query in from SQL Server: ------------
# note: 
# > first remove comments 
# > be careful about spaces being removed in cleanup: eg. "Select x from y" may become "Select xfrom y" 


# > LOS query: ------------
sqlstring <- paste0("Select [ADTCMart].[ADTC].[vwAdmissionDischargeFact].ContinuumID 
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
Where (AdmissionFacilityLongName = '", 
site, 
"' ) 
and (AdmissionFiscalYear = '",
admit.fiscal.year, 
"' ) 
and (AdmissionNursingUnitCode in ('", 
nursing.unit, 
"') 
or [ADTCMart].[ADTC].[vwTransferFact].ToNursingUnitCode = '",
nursing.unit, 
"') 
and [ADTCMart].[ADTC].[vwTransferFact].TransferDate >= '", 
transfer.date.after,   
"' order by AdmissionNursingUnitCode
, [AdjustedAdmissionDate]
, [AdjustedAdmissionTime]
, [ADTCMart].[ADTC].[vwTransferFact].TransferDate
, [ADTCMart].[ADTC].[vwTransferFact].TransferTime;")

# sqlstring

# 2) Cleanup whitespaces: --------------
sqlstring <- gsub("\\t", "", sqlstring)  # remove tabs 
sqlstring <- gsub("\\n", "", sqlstring)  # remove carriage returns 

sqlstring

# 3) Pull data: ---------------
df1.losdata <- data.frame(sqlQuery(cnx, sqlstring))

head(df1.losdata)
