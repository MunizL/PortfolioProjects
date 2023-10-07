select * 
from dbo.CovidDeaths
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

-- Total Cases vs. Total Deaths

-- Shows likelihood of dying if one contracts Covid by country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as "Percent Deaths"
from dbo.CovidDeaths
Where location like '%state%'
order by 1,2

-- Total Cases vs Population
--Percentage of population contracted covid
Select Location, date, total_cases, population,(total_cases/Population)*100 as "Percent Cases"
from dbo.CovidDeaths
Where location like '%state%'
order by 1,2

--Countries with highest infection rate compared to population
Select  Location, population, max(total_Cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as "Percent Cases"
from dbo.CovidDeaths
Group By Location, population
Order by [Percent Cases] desc

-- Countries with the highest Death Rates per population
Select  Location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as "Percentdeaths"
from dbo.CovidDeaths
Where continent is not null
Group By Location, population
Order by [TotalDeathCount] desc

-- Break down by continent (correct version) 

Select location, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as "Percentdeaths"
from dbo.CovidDeaths
Where continent is null
Group By location
Order by [TotalDeathCount] desc

-- Break down by continent (for project purposes)

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as "Percent Deaths"
from dbo.CovidDeaths
--Where location like '%state%'
Where continent is not null
--group By date
order by 1,2

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


-- Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3