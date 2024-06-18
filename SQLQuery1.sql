SELECT Location,date,total_cases,new_cases,total_deaths,Population
FROM dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of dying per country
SELECT location,date,total_cases,(total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths 
WHERE location like '%nigeria%'
ORDER BY 1,2

--Total Cases vs Population
--Show Percentage of Population that got Covid
SELECT location,date,Population,total_cases,(total_cases/population)*100 as CasesPercentagePerPopulation
FROM dbo.CovidDeaths 
--WHERE location like '%nigeria%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM dbo.CovidDeaths 
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location,MAX(cast(total_cases as INT)) as TotalDeathCount
FROM dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break down by continent

SELECT location,MAX(cast(total_cases as INT)) as TotalDeathCount
FROM dbo.CovidDeaths 
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with Highest Death counts
SELECT continent,MAX(cast(total_cases as INT)) as TotalDeathCount
FROM dbo.CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Cases
SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as INT)) as TotalDeaths, SUM(new_cases)/SUM(cast(new_deaths as INT)) *100 as DeathPercentage
FROM dbo.CovidDeaths 
--WHERE location like '%nigeria%'
Where continent is not null
--GROUP BY date
ORDER BY 1,2

--JOining Covid and Vacccination Table
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM (CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
		
FROM dbo.CovidDeaths dea
JOIN dbo.Covidvaccinations vac
	ON dea.continent=vac.continent
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--With CTE

WITH PopVsVac (continent,location,date,population,new_vaccinations,PeopleVaccinated)
as 
	(SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM (CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated
		
FROM dbo.CovidDeaths dea
JOIN dbo.Covidvaccinations vac
	ON dea.continent=vac.continent
	and dea.date=vac.date
WHERE dea.continent is not null
	)
SELECT *, (PeopleVaccinated/Population) *100 as PercentageVaccinatedPerPopulation
FROM PopVsVac



--Create VIEW for PercentageVaccinatedPerPopulation
CREATE VIEW PercentageVaccinatedPerPopulation as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
	SUM (CONVERT(INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as PeopleVaccinated		
FROM dbo.CovidDeaths dea
JOIN dbo.Covidvaccinations vac
	ON dea.continent=vac.continent
	and dea.date=vac.date
WHERE dea.continent is not null
