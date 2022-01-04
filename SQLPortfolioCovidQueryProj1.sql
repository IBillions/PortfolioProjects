select *
from [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4


--select *
--from [Portfolio Project]..CovidVacinations
--order by 3,4

--Select Data that we are going to be using


select Location, date, total_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

-- Look at Total Cases vs Total Deaths
--shows the likelihood of dying if one contracts covid in one's country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--Where location like '%states%' 
Where continent is not null
order by 1,2

--Look at Total Case vs Population
--shows what percentage of the population got covid

select Location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2


--What countries has the highest infection rates per population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--What countries have the highest death count perpopulation
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--ANALIZE BY CONTINENT

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--Where location like '%states%' 
Where continent is not null
group by date
order by 1,2

--TOTAL GLOBAL NUMBERS

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--Where location like '%states%' 
Where continent is not null
order by 1,2


--Looking at Total Population Vs. Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null
order by 2,3

---Looking at Rolling Total of Population vs. Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations, SUM(CONVERT(int, Vac.new_vaccinations)) 
OVER(partition by dea.Location order by dea.location, Dea.Date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null
order by 2,3

--USE TEMP TABLE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations, SUM(CONVERT(int, Vac.new_vaccinations)) 
OVER(partition by dea.Location order by dea.location, Dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) 
OVER(partition by dea.Location order by dea.location, Dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
--Where Dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--CREATE VIEW TO STORE DATE FOR LATER VISUALS

--DROP view if exists PercentPopulationVaccinated

USE [Portfolio Project]
GO
Create View PercentPopulationVaccinated as 
Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) 
OVER(partition by dea.Location order by dea.location, Dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null

select * from PercentPopulationVaccinated


--
Create View LikelihoodOfDeathbyCovid as
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--Where location like '%states%' 
Where continent is not null

 use [Portfolio Project]
 select*from PercentPopulationVaccinated

 -------------------------------------------

 --Look at Total Case vs Population
--shows what percentage of the population got covid

Create View TotalCasesPerPopulation as
select Location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
Where location like '%states%'

select * from TotalCasesPerPopulation


--What countries has the highest infection rates per population

Create View HighestInfectionRatesPerPopulation as
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
Select*from HighestInfectionRatesPerPopulation

--What countries have the highest death count perpopulation

Create View HighestDeathCountPerPopulation as
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Select*from HighestDeathCountPerPopulation

--ANALIZE BY CONTINENT
Create View ContinentCovidDeathCounts as
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Select*from ContinentCovidDeathCounts
order by TotalDeathCount desc

--GLOBAL NUMBERS

Create View GlobalCovidNumbers as
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--Where location like '%states%' 
Where continent is not null
group by date
select*from GlobalCovidNumbers
order by 1,2

--TOTAL GLOBAL NUMBERS

DROP view if exists TotalGlobalNumbers

Create View TotalGlobalNumbers as

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
Where continent is not null

Select*from TotalGlobalNumbers
order by 1,2


--Looking at Total Population Vs. Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null
order by 2,3

---Looking at Rolling Total of Population vs. Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.Population, Vac.new_vaccinations, SUM(CONVERT(int, Vac.new_vaccinations)) 
OVER(partition by dea.Location order by dea.location, Dea.Date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths Dea
Join [Portfolio Project]..CovidVacinations Vac
     On Dea.location = Vac.location
	 and Dea.date = Vac.date
Where Dea.continent is not null
order by 2,3 