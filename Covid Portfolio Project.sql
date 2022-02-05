--Select Data That we are going to be using

SELECT * 
from Portfolio.dbo.CovidDeaths

Select location,date,new_cases,total_cases,total_deaths
from Portfolio.dbo.CovidDeaths
WHERE continent is not null

--Death Percentage of your country

Select location,date,total_cases,
total_deaths,(total_deaths/total_cases) * 100 AS Death_percentage
From Portfolio.dbo.CovidDeaths
WHERE location = 'INDIA' and continent is not null
ORDER BY 1,2

-- Total cases vs total deaths in your country
Select location,date,SUM(total_cases) as total_num_cases,SUM(cast(total_deaths as int)) as total_num_deaths
From Portfolio.dbo.CovidDeaths
WHERE location = 'INDIA'
GROUP BY location,date
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate

Select location,Max(total_cases) as Highest_Infection_Rate
From Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Infection_Rate DESC

-- Showing Countries with Highest Death Count

Select location,Max(cast(total_deaths as int)) as Highest_Death_Rate
From Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Death_Rate DESC


-- Break down things into continent

Select continent,Max(cast(total_deaths as int)) as Highest_Death_Rate
From Portfolio.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Death_Rate DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_new_cases,Sum(cast(new_deaths as int))as total_new_deaths,SUM(cast(new_deaths as int))/Sum(new_cases) as Death_Percentage
From Portfolio.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- Looking at Total Vaccinations
Select dea.continent,dea.location,dea.date,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From Portfolio.dbo.CovidDeaths dea
Join Portfolio.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  And dea.date = vac.date
 WHERE dea.continent is not null
Order by 2,3


--Temp Table
DROP TABLE IF EXISTS #Total_people_vaccinated
CREATE TABLE #Total_people_vaccinated
(Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric)
INSERT INTO #Total_people_vaccinated

Select dea.continent,dea.location,dea.date,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From Portfolio.dbo.CovidDeaths dea
Join Portfolio.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  And dea.date = vac.date
 --WHERE dea.continent is not null
Order by 2,3


-- Creating Views for later visualization

Create View Total_people_vaccination as
Select dea.continent,dea.location,dea.date,vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From Portfolio.dbo.CovidDeaths dea
Join Portfolio.dbo.CovidVaccinations vac
  ON dea.location = vac.location
  And dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select * from Total_people_vaccinated