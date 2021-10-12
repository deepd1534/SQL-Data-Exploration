SELECT *
FROM PortfolioProject..covidDeaths#x$
ORDER BY 3,4 

--SELECT *
--FROM PortfolioProject..covidVaccinations$
--ORDER BY 3,4

--Selecting data that are going to be used(Location, Date, new cases, new deaths, Population)
SELECT location,date,new_cases,new_deaths, population
FROM PortfolioProject..covidDeaths#x$
ORDER BY 1,2 

-- New Cases VS New Deaths
SELECT location,date,new_cases,new_deaths
FROM PortfolioProject..covidDeaths#x$
ORDER BY 1,2

-- Death Percentage Per Million
SELECT location,date,total_cases_per_million,total_deaths_per_million, (total_deaths_per_million/total_cases_per_million)*100 AS death_percentage_per_million
FROM PortfolioProject..covidDeaths#x$
ORDER BY 1,2

-- Death Percentage Per Million in India
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..covidDeaths#x$
WHERE location LIKE 'India'
ORDER BY 1,2

--New Cases VS New Deaths In INDIA

SELECT location,date,new_cases,new_deaths
FROM PortfolioProject..covidDeaths#x$
WHERE location LIKE 'India'
ORDER BY 1,2

--What percentage of population has gotten infected of COVID?

SELECT location,date,total_deaths,population,(total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..covidDeaths#x$
WHERE location LIKE 'India'
ORDER BY 1,2

--Highest Infection rate compared to population. 
SELECT location,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..covidDeaths#x$
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC;


-- COuntries with highest death count
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths#x$
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Total Deaths By Continent.	
-- Showing the continents with the highest Death Count

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths#x$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Total cases, Total Deaths and Death percentage globally by date.

SELECT date,SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM covidDeaths#x$
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases, Total Deaths and Death percentage globally till date.

SELECT SUM(cast(new_cases as int)) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM covidDeaths#x$
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

--------------------------------------------------

SELECT * 
FROM PortfolioProject..covidVaccinations$

--Joining the two tables
SELECT *	
FROM PortfolioProject..covidDeaths#x$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at total population VS Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
FROM PortfolioProject..covidDeaths#x$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


-- USE CTE
with PopvsVac (Continent,location, Date, Population, new_vaccinations, PeopleVaccinatedCumSum)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedCumSum
--,(PeopleVaccinatedCumSum/population)*100
FROM PortfolioProject..covidDeaths#x$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

select *, (PeopleVaccinatedCumSum/population)*100  as VacPercentage
from PopvsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
PeopleVaccinatedCumSum  numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedCumSum
--,(PeopleVaccinatedCumSum/population)*100
FROM PortfolioProject..covidDeaths#x$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (PeopleVaccinatedCumSum/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view for visualization purposes

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as PeopleVaccinatedCumSum
--,(PeopleVaccinatedCumSum/population)*100
FROM PortfolioProject..covidDeaths#x$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
