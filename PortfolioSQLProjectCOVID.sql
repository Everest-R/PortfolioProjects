SELECT *

FROM CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--Showing death percentages

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2 

SELECT location, date, total_cases, new_cases, Population, (total_cases/population)*100 AS covid_rates
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopluationInfected
FROM CovidDeaths$
--WHERE location like '%states%'
GROUP BY population, location
ORDER BY PercentPopluationInfected DESC

--Grouping total deaths by country

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY population, location
ORDER BY TotalDeathCount DESC

--Grouping total deaths by continent 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage

FROM CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2 

--Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS integer)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated /population)*100  

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3 

-- use CTE 

WITH PopvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS integer)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100   

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPeopleVaccinated
CREATE Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPeopleVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS integer)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100   need a temptable 

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3 
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPeopleVaccinated

-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS integer)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated /population)*100   

FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated