
----------------------------------------
-- 2018-09-24_lgh_high-acuity-unit-data-analysis
----------------------------------------

----------------------------------------
--TODO: 
-- > parametrize start and end dates 
----------------------------------------

if object_id('tempdb.dbo.#unitresults') IS NOT NULL drop table #unitresults; 

-- Pull all admits to specified Nursing Unit: ----------------------------------------
-- Set desired Nursing Unit: 
Declare @nursingunit as varchar(3) = 'NCCU'; 


Select a.ContinuumID as [a.ContinuumID]
	, tr.ContinuumID as [tr.ContinuumID]
	, a.AccountNumber as [AccountNumber]
	, tr.AccountNum
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
	, case when ToBed = FromBed then '1' 
		else 0 
		end as CheckTransferCols 
into #unitresults
From [ADTCMart].[ADTC].[vwAdmissionDischargeFact] a 
	full outer join [ADTCMart].[ADTC].[vwTransferFact] tr
		on a.ContinuumId = tr.ContinuumId
			--and a.AccountNumber = tr.AccountNum  -- this doesn't seem to change anything 
Where (AdmissionFacilityLongName = 'Lions Gate Hospital' ) 
	and (AdmissionFiscalYear = '2018' ) 
	--and AdjustedAdmissionDate > '2017-01-01'		-- just for testing 
	and (AdmissionNursingUnitCode in (@nursingunit)
		or tr.ToNursingUnitCode = @nursingunit)
	and tr.TransferDate >= '2017-04-01'  --(FY 14/15) 
order by AdmissionNursingUnitCode
	, [AdjustedAdmissionDate]
	, [AdjustedAdmissionTime]
	, tr.TransferDate
	, tr.TransferTime; 


-- display results: 
select * from #unitresults 
order by AdmissionNursingUnitCode
	, [AdjustedAdmissionDate]
	, [AdjustedAdmissionTime]
	, TransferDate
	, TransferTime; 


--Select count(distinct [aContinuumID]) from #unitresults
----------------------------------------
/*
-- Pull overall LOS for these same patients: 
select distinct ad.ContinuumID 
	, ad.AccountNumber
	, ad.AdmissionFacilityLongName
	, ad.AdmissionNursingUnitCode
	, @nursingunit as [unit specified] 
	, ad.AdjustedAdmissionDate
	, ad.AdmissionFiscalYear 
	, r.aContinuumID
	, r.aAccountNumber
	, LOSDays 
from [ADTCMart].[ADTC].[vwAdmissionDischargeFact] ad 
right join #unitresults r
	on ad.ContinuumID = r.[aContinuumID]
		and ad.AccountNumber = r.aAccountNumber 
--where (ad.AdmissionFacilityLongName = 'Lions Gate Hospital' ) 
	--and (ad.AdmissionFiscalYear >= '2015' ) 
	--and (ad.AdmissionNursingUnitCode in (@nursingunit))		-- no need for a where clause because all conditions were set in the #results query
order by ad.AdmissionNursingUnitCode
	, ad.AdjustedAdmissionDate; 

*/