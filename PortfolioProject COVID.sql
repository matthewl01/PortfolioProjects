SELECT *
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Data is from 2020 to 2024. Using older excel spreadsheet from ourworldindata covid 19 sheet as the new spreadsheets from the website do not have all the information we want. 
--Data may not fully be 100% accurate as a result 

-- Looking at Total Cases vs Total Deaths
--Shows liklihood of death from COVID-19 based off Country 

Select Location, date, total_cases, total_deaths, (total_deaths/NULLIF (total_cases, 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of the population got COVID-19

Select Location, date, total_cases, Population, (total_cases/NULLIF (Population, 0)) * 100 as PopulationPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%states'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCt, MAX((total_cases)/NULLIF (Population, 0)) * 100 as 
          PopulationPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%states'
Group by location, population 
Order by PopulationPercentage DESC

--Showing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states'
Where continent IS NOT NULL 
Group by location
Order by TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT for Death Count per Population
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states'
Where continent IS NULL 
Group by location
Order by TotalDeathCount DESC

--Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states'
Where continent IS NOT NULL 
Group by continent
Order by TotalDeathCount DESC

--Global Numbers

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,  SUM(new_deaths) / NULLIF (SUM(new_cases), 0) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Order by 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccination as Vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL  and vac.new_vaccinations IS NOT NULL
order by 1,2,3

--Use CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccnations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccination as Vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL  and vac.new_vaccinations IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
From PopVsVac

--Temp Table

--Remember that if we are creating a table or temp table multiple times for whatever reason, we have to drop the table first or else it will give an error that the table already exists 
DROP Table If Exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccination as Vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL  and vac.new_vaccinations IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated 

--Creating View to store data for later visualizations

USE PortfolioProject
GO 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER  (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVaccination as Vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL  and vac.new_vaccinations IS NOT NULL

Select *
From PercentPopulationVaccinated