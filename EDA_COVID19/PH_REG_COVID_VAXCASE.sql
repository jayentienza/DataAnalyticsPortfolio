--TOTAL CASES, TOTAL DEATHS, TOTAL VACCINATION PER REGION

--OVERVIEW OF VACCINATION DATA PER REGION
SELECT *
FROM [SQL_Projects].[dbo].[PHregion_vaccine]

--VACCINE SUPPLY DISTRIBUTION AMONG REGIONS

--got the sum of the total supplies of the whole country
SELECT SUM(totalvaccines)as TotalVaxSupplies
FROM [SQL_Projects].[dbo].[PHregion_vaccine]

--percentage of vaccine supply of region to the whole supply
SELECT REGION,
	totalvaccines,
	(totalvaccines/108299859)*100 as VaxSupplies_Percentage
FROM [SQL_Projects].[dbo].[PHregion_vaccine]
WHERE REGION!='NO REGION'
ORDER BY VaxSupplies_Percentage DESC
--ANALYSIS:
--Based here, we can see that the vaccine rollout is in line with the ranking of total population per region

--percentage of VACCINE SUPPLY per region accounting for the unclear 'NO REGION' record
SELECT REGION,
	totalvaccines,
	(totalvaccines/108299859)*100 as VaxSupplies_Percentage
FROM [SQL_Projects].[dbo].[PHregion_vaccine]
ORDER BY VaxSupplies_Percentage DESC
---ANALYSIS:
-- this is crucial because some of the vaccines distributed were not accounted per region, what does this mean? 
-- it's a huge number because it is 5% of the whole vaccine supply of the country 

--percentage of vaccine supply vs completed vaccines and boosters - data for immunity 
SELECT Region,
		totalvaccines,
		[COMPLETE DOSE],
		[BOOSTER DOSE],
		([COMPLETE DOSE]/totalvaccines)*100 AS CompleteDose_Percentage,
		([BOOSTER DOSE]/totalvaccines)*100 AS Booster_Percentage
FROM [SQL_Projects].[dbo].[PHregion_vaccine]
WHERE REGION!='NO REGION'
ORDER BY CompleteDose_Percentage DESC
-- the highest among the regions in terms of completed dose is only at 45% in NCR and CAR
-- least percent of completed dose is 36% in BARMM 

------------------CASES PER REGION SINCE VACCINATION STARTED---------------------
---RETRIEVING FROM MARCH 3 2021 FOR THE VACCINATED AND CASES COMPARISON PER REGION

--Table0 filtered
SELECT CaseCode,
		DateRepConf,
		RegionRes,
		ProvRes,
		HealthStatus
INTO SQL_Projects.dbo.Table1_Filtered
FROM [SQL_Projects].[dbo].[DOH_COVID_DATADROP_0$]
WHERE DateRepConf BETWEEN '2021-03-21' AND '2022-01-09'

--Table1filtered
SELECT CaseCode,
		DateRepConf,
		RegionRes,
		ProvRes,
		HealthStatus
INTO SQL_Projects.dbo.Table2_Filtered
  FROM [SQL_Projects].[dbo].[DOH_COVID_DATADROP_1$]
WHERE DateRepConf BETWEEN '2021-03-21' AND '2022-01-09'

SELECT CaseCode,
		DateRepConf,
		RegionRes,
		ProvRes,
	    HealthStatus
INTO SQL_Projects.dbo.Table3_Filtered
FROM [SQL_Projects].[dbo].['DOH COVID Data Drop_ 20220110 -$']
WHERE DateRepConf BETWEEN '2021-03-21' AND '2022-01-09'

--Checking each new table
SELECT *
FROM [SQL_Projects].dbo.Table1_Filtered

SELECT *
FROM [SQL_Projects].dbo.Table2_Filtered

SELECT *
FROM [SQL_Projects].dbo.Table3_Filtered

---CREATING TABLE WHERE TO MERGE DATA
CREATE TABLE SQL_PROJECTS.DBO.VAX_CASES (
			CaseCode nvarchar(255),
			DateRepConf datetime,
			RegionRes nvarchar(255),
			ProvRes nvarchar(255),
			HealthStatus nvarchar(255))


INSERT INTO SQL_Projects.dbo.VAX_CASES
SELECT 
	TABLE1.CaseCode,
	TABLE1.DateRepConf,
	TABLE1.RegionRes,
	TABLE1.ProvRes,
	TABLE1.HealthStatus
FROM [SQL_Projects].dbo.Table1_Filtered TABLE1
UNION
	SELECT
	TABLE2.CaseCode,
	TABLE2.DateRepConf,
	TABLE2.RegionRes,
	TABLE2.ProvRes,
	TABLE2.HealthStatus
FROM [SQL_Projects].dbo.Table2_Filtered TABLE2
UNION
	SELECT
	TABLE3.CaseCode,
	TABLE3.DateRepConf,
	TABLE3.RegionRes,
	TABLE3.ProvRes,
	TABLE3.HealthStatus
FROM [SQL_Projects].dbo.Table3_Filtered AS TABLE3
WHERE RegionRes is not null AND ProvRes is not null

SELECT *
FROM SQL_Projects.dbo.Vax_cases

------------CASES COUNT FROM MARCH 3 BY REGION---------------------
SELECT RegionRes,
		COUNT(RegionRes) as CaseCount_Region
FROM SQL_Projects.dbo.VAX_CASES
WHERE RegionRes is not null
GROUP BY RegionRes
ORDER BY CaseCount_Region DESC 

----severity of cases from march 3 by region
SELECT RegionRes,
		HealthStatus,
		COUNT(HealthStatus) as Severity_Count
FROM SQL_Projects.dbo.VAX_CASES
WHERE RegionRes is not null 
GROUP BY RegionRes, HealthStatus
ORDER BY RegionRes, HEALTHSTATUS

---DEATH CASES---- 
SELECT
	   RegionRes,
	   COUNT(HealthStatus) as Died_Count
FROM SQL_Projects.dbo.VAX_CASES
WHERE RegionRes is not null AND
	HealthStatus = 'Died'
GROUP BY RegionRes
ORDER BY Died_Count DESC

----SEVERE--------
SELECT
	   RegionRes,
	   COUNT(HealthStatus) as Died_Count
FROM SQL_Projects.dbo.VAX_CASES
WHERE RegionRes is not null AND
	HealthStatus = 'Severe'
GROUP BY RegionRes
ORDER BY Died_Count DESC


----MILD CASES----
SELECT
	   RegionRes,
	   COUNT(HealthStatus) as Died_Count
FROM SQL_Projects.dbo.VAX_CASES
WHERE RegionRes is not null AND
	HealthStatus = 'Mild'
GROUP BY RegionRes
ORDER BY Died_Count DESC

-------------------MERGE TABLES OF CASES PER REGION AND VACCINES PER REGION-----------
SELECT 
*
INTO SQL_Projects.dbo.RegionCasesVax_
FROM SQL_Projects.dbo.PHregion_vaccine vax_rate
INNER JOIN SQL_Projects.dbo.VAX_CASES cases_
ON cases_.RegionRes = vax_rate.REGION

SELECT 
*
INTO SQL_Projects.dbo.RightJoin_
FROM SQL_Projects.dbo.PHregion_vaccine vax_rate
RIGHT JOIN SQL_Projects.dbo.VAX_CASES cases_
ON cases_.RegionRes = vax_rate.REGION

SELECT 

SELECT *
FROM SQL_Projects.dbo.RegionCasesVax_
ORDER BY RegionRes
---note: region-vaccine;regionres-cases
---CASES AND COMPLETE DOSES-----
SELECT Region,
		Count(RegionRes) as Cases_Region,
		[COMPLETE DOSE],
		ISNULL((Count(RegionRes)/[COMPLETE DOSE]),0)*100 as Case_Vax_Percent --might not needed
FROM SQL_Projects.dbo.RegionCasesVAX_
GROUP BY Region, [COMPLETE DOSE]
ORDER BY [COMPLETE DOSE] DESC


----VAX, CASES, AND DEATH
SELECT Regionres,
	totalvaccines,
	COUNT(RegionRes) as Cases_Region
FROM SQL_Projects.dbo.RegionCasesVAX_
GROUP BY RegionRes, totalvaccines
ORDER BY Cases_Region DESC 

--DIED vs. COMPLETE DOSE-------
SELECT Region,
		[COMPLETE DOSE],
		COUNT(HealthStatus) as Death_Region
FROM SQL_Projects.dbo.RegionCasesVAX_
WHERE HealthStatus = 'Died'
GROUP BY Region, HealthStatus, [COMPLETE DOSE]
ORDER BY [COMPLETE DOSE] DESC

---TOTAL CASES PER PROVINCE SINCE MARCH 3 2021 ----- 
SELECT RegionRes,
		ProvRes,
		Count(ProvRes) as Cases_Province
FROM SQL_Projects.dbo.RegionCasesVAX_
Where ProvRes is not null
GROUP BY RegionRes, ProvRes
ORDER BY RegionRes

---------COMPARING WITH CASES, NO VACCCINE ROLLOUT YET

--Table0 filtered PRE-VAX
SELECT CaseCode,
		DateRepConf,
		RegionRes,
		ProvRes,
		HealthStatus
INTO SQL_Projects.dbo.PREVAX_Table1
FROM [SQL_Projects].[dbo].[DOH_COVID_DATADROP_0$]
WHERE DateRepConf BETWEEN '2020-01-30' AND '2021-03-20'

SELECT *
FROM SQL_Projects.DBO.PREVAX_TABLE1
ORDER BY DateRepConf DESC

SELECT RegionRes,
	COUNT(RegionRes) as Prevax_Cases_Region
FROM SQL_Projects.DBO.PREVAX_TABLE1
WHERE RegionRes is not null
GROUP BY RegionRes
ORDER BY Prevax_Cases_Region DESC 

SELECT RegionRes,
	COUNT(HealthStatus) as Prevax_DeathCases_Region
FROM SQL_Projects.DBO.PREVAX_TABLE1
WHERE RegionRes is not null AND HealthStatus = 'Died'
GROUP BY RegionRes

----Combining Data for Overall Monthly Case Trend per Region---
SELECT *
FROM SQL_Projects.dbo.Vax_cases

SELECT *
FROM SQL_Projects.DBO.PREVAX_TABLE1
ORDER BY DateRepConf DESC


SELECT *
FROM SQL_Projects.DBO.PREVAX_TABLE1 P
JOIN SQL_Projects.dbo.Vax_cases PO
ON P.RegionRes 


--merged cases table---
CREATE TABLE SQL_Projects.dbo.CovidCasesMerged (
	CaseCode nvarchar(255),
	DateRepConf datetime,
	RegionRes nvarchar(255),
	HealthStatus nvarchar(255))  
	
INSERT INTO SQL_Projects.dbo.CovidCasesMerged
SELECT 
	P.CaseCode,
    P.DateRepConf,
	P.RegionRes,
	P.HealthStatus
FROM SQL_Projects.DBO.PREVAX_TABLE1 P
UNION
	SELECT
	PO.CaseCode,
	PO.DateRepConf,
	PO.RegionRes,
	PO.HealthStatus
FROM SQL_Projects.dbo.Vax_cases PO

SELECT *
FROM SQL_Projects.dbo.CovidCasesMerged

SELECT RegionRes,
	   COUNT(RegionRes) as CaseCount
FROM SQL_Projects.dbo.CovidCasesMerged
GROUP BY RegionRes
