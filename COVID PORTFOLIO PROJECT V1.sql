SELECT *
FROM portfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM portfolioProject..CovidVaccinations$

--SELECT DATA TO USE
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioProject..CovidDeaths$
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATH
--SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
FROM portfolioProject..CovidDeaths$
WHERE location like '%nigeria%'
ORDER BY 1,2


--TOTAL CASES VS POPULATION
--SHOWS THE PERCENT OF THE POPULATION THAT HAD COVID
SELECT location,date,new_cases,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM portfolioProject..CovidDeaths$
WHERE location like '%nigeria%'
ORDER BY 1,2 


--COUNTRIES WITH THE HIGHEST INFECTION COMPARED TO POPULATION
SELECT location,population,MAX(total_cases) as Highestinfectioncount,MAX(total_cases/population)*100 as PercentPopulationInfected
FROM portfolioProject..CovidDeaths$
--WHERE location like '%nigeria%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(CAST( total_deaths as INT)) as TotalDeathCount
FROM portfolioProject..CovidDeaths$
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount  desc


---------------------BY CONTINENT-------------
---CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION---
SELECT continent,MAX(CAST( total_deaths as INT)) as TotalDeathCount
FROM portfolioProject..CovidDeaths$
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount  desc


-------GLOBAL NUMBER----
SELECT SUM(new_cases)AS total_cases,SUM(CAST (new_deaths as int))as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
FROM portfolioProject..CovidDeaths$
--WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
ORDER BY 1,2


 

--TOTAL POPULATION VS VACCINATIONS
--USE CTE---
WITH Popvsvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*
FROM portfolioProject..CovidVaccinations$ vac
JOIN portfolioProject..CovidDeaths$ dea
 ON vac.location = dea . location
 AND vac.date = dea . date
 WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *,(Rollingpeoplevaccinated/population)*100
FROM Popvsvac


---TEMP TABLE-----
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABlE #percentpopulationvaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO  #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*
FROM portfolioProject..CovidVaccinations$ vac
JOIN portfolioProject..CovidDeaths$ dea
 ON vac.location = dea . location
 AND vac.date = dea . date
 --WHERE dea.continent is not null
-- ORDER BY 2,3


SELECT *,(Rollingpeoplevaccinated/population)*100
FROM  #percentpopulationvaccinated


---CREATING VIEW FOR DATA STORAGE---

CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(Rollingpeoplevaccinated/population)*
FROM portfolioProject..CovidVaccinations$ vac
JOIN portfolioProject..CovidDeaths$ dea
 ON vac.location = dea . location
 AND vac.date = dea . date
 WHERE dea.continent is not null
-- ORDER BY 2,3


SELECT *
FROM  percentpopulationvaccinated