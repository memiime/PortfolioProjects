-- COVID DEATHS --
Select * 
from CovidDeaths

-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths;

-- Looking at Total case vs Total deaths
-- Show likelihood of dying if you contract covid in your contry
Select Location, date, total_cases, total_deaths, CAST(total_deaths as float)/CAST(total_cases as float)*100 as PercentageDeaths
from CovidDeaths
where location like '%Viet%'

-- Looking at Total cases vs Population
-- Show what percentage of population got Covid
Select Location, date, total_cases, population, CAST(total_cases as float)/CAST(population as float)*100 as PercentageOfPopulationgetInfected
from CovidDeaths
where location like '%China%'

-- Looking at country with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
    MAX(CAST(total_cases as float)/CAST(population as float))*100 as PercentPopulationInfected
from CovidDeaths
group by Location, population
order by PercentPopulationInfected DESC

-- Show Countries with highest death count per population
Select Location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by Location
order by TotalDeathCount DESC

-- Break thing down by continents
Select continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC

-- This shows a lot more accurate number
Select location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is NULL
group by location
order by TotalDeathCount DESC


-- Global numbers

-- show the number day by day
Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
    CAST(SUM(new_deaths) as float)/CAST(SUM(new_cases) as float)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL
group by date

-- show total number 
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,
    CAST(SUM(new_deaths) as float)/CAST(SUM(new_cases) as float)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = dea.date
where dea.continent is not null
--    and dea.location like '%Canada%'

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
-- New vaccination per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(bigint,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
Select *, CONVERT(float,RollingPeopleVaccinated)/Convert(int,Population)*100
from PopvsVac

-- TEMP table
Drop Table if EXISTS #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC, 
RollingPeopleVaccinated NUMERIC
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(bigint,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

Select *, CONVERT(float,RollingPeopleVaccinated)/Convert(int,Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(bigint,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

Select * 
from PercentPopulationVaccinated
