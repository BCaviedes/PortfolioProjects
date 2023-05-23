-- Select data that we are going to be using

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracted covid in Ecuador
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ecuador' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Show percentage of population got covid in Ecuador

SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS percentage_infected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ecuador'
ORDER BY 1,2

-- Looking at countries with highest infection rate

SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Countries with highest death count per pop.

SELECT 
	location,
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- JOIN both tables death and vaccinations
-- Total Pop vs Total Vaccinations

--USE CTE

WITH PopvsVac (
	continent, location, date, population, new_vaccinations, People_Vaccinated_byDay
)
AS
(

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS People_Vaccinated_byDay
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

)

SELECT *, (People_Vaccinated_byDay/population)*100 AS Percentage_Pop_Vac
FROM PopvsVac


