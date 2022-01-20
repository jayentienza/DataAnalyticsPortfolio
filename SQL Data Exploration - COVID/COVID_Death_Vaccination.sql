Select *
From Portfolio_Project_1..Covid_Table_1$
Where continent is null
Order by 3,4

Select *
From Portfolio_Project_1..covid_vaccination$
Order by 3,4

--Narrowing down our data
Select location,date,total_cases, new_cases, total_deaths, population
From Portfolio_Project_1..Covid_Table_1$
Order by 1,2 --Order by date and location

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you get infected COVID-19 in the Philippines
Select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project_1..Covid_Table_1$
Where location = 'Philippines'
Order by 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got COVID in the Philippines 
Select location,date,total_cases, population,(total_cases/population)*100 as CasesPercentage
From Portfolio_Project_1..Covid_Table_1$
Where location = 'Philippines'
Order by 1,2
-- So far, the results shows that the infection rate lowered from 2020

-- What countries have the Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
	-- MAx cases will narrow it, we only want to look at the highest
From Portfolio_Project_1..Covid_Table_1$
Group by Location, Population
Order by PercentPopulationInfected desc

-- Showing the countries with Highest Death Count per Population (note that this is count only and not rate)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project_1..Covid_Table_1$
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project_1..Covid_Table_1$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- We can insert here for every countries and every continent 

-- GLOBAL NUMBERS 
--WorldDeathPercentage 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldDeathPercentage
From Portfolio_Project_1..Covid_Table_1$
Where continent is not null
Order by 1,2


-- Joining back the two tables - Deaths and Vaccination
Select *
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3 --Group by date

SET ANSI_WARNINGS OFF
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinatedCount
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Looking at the total population and number of vaccination
--Use CTE 
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingVaccinatedCount)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinatedCount
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinatedCount/Population)*100
From PopvsVac

-- Using TEMP TABLE 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinatedCount
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingVaccinatedCount/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizaitons

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinatedCount
From Portfolio_Project_1..Covid_Table_1$ dea 
Join Portfolio_Project_1..covid_vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
