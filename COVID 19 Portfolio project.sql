/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM PortfolioProjets..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with
SELECT location,date,total_cases,new_cases, population
FROM PortfolioProjets..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjets..CovidDeaths
WHERE continent IS NOT NULL and location like '%India%'
ORDER BY 1,2

-- Shows what percentage of population infected with Covid
SELECT location, date, total_cases, population,(total_deaths/NULLIF(population,0))*100 AS PercentPopulationInfected
FROM PortfolioProjets..CovidDeaths
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount ,MAx(total_cases/NULLIF(population,0))*100 AS  PercentPopulationInfected
FROM PortfolioProjets..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT location,population,MAX(cast(total_deaths as int)) AS TotalDeathCount ,MAx(total_deaths/NULLIF(population,0))*100 AS  PercentPopulationDead
FROM PortfolioProjets..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDead DESC


-- Showing contintents with the highest death count per population
SELECT location,population,MAX(cast(total_deaths as int)) AS TotalDeathCount ,MAx(total_deaths/NULLIF(population,0))*100 AS  PercentPopulationDead
FROM PortfolioProjets..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDead DESC

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjets..CovidDeaths
where continent is not null 
order by 1,2

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT (cv.new_vaccinations/NULLIF (cd.population,0))*100 AS PopulationVaccinated
FROM PortfolioProjets..CovidDeaths AS cd
JOIN PortfolioProjets..CovidVaccinations AS cv 
ON cd.location=cv.location

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
FROM PortfolioProjets..CovidDeaths AS cd
JOIN PortfolioProjets..CovidVaccinations AS cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
FROM PortfolioProjets..CovidDeaths AS cd
JOIN PortfolioProjets..CovidVaccinations AS cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)
select*,(RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjets..CovidDeaths AS cd
JOIN PortfolioProjets..CovidVaccinations AS cv 
	On cd.location = cv.location
	and cd.date = cv.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
GO
CREATE VIEW PercentPopulationVaccinateD as 
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjets..CovidDeaths AS cd
JOIN PortfolioProjets..CovidVaccinations AS cv 
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
