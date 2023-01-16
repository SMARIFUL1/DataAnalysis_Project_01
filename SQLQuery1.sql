select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccine
--order by 3,4

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
order by 1,2


select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
order by 1,2

select location, population, max(total_cases) as HighestInfection, max(total_cases/population)*100 as InfectedPopulationpercent
From PortfolioProject..CovidDeaths
group by location, population
order by InfectedPopulationpercent desc

--for death count

select location, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathscount desc

--To see Continent rate

select continent, MAX(cast(total_deaths as int)) as totaldeathscount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathscount desc

select sum(new_cases) as TotalCasesInWorld, sum(cast(new_deaths as int)) as TotalDeathsInWorld, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1



select  dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as bigint)) --Here bigint used because int can't handle the big integer
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidVaccine vac
join PortfolioProject..CovidDeaths dea
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 3


--for use CTE

with PopvsVac (continent, date, location, population, new_vaccinations, RollingPeopleVaccinations)
as
(
select  dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as bigint)) --Here bigint used because int can't handle the big integer
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidVaccine vac
join PortfolioProject..CovidDeaths dea
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
)
select *, (RollingPeopleVaccinations/population)*100 as VaccinePercentage
from PopvsVac




--for TEMP table

drop table if exists  #PercentPopVac
Create table #PercentPopVac
(
continent nvarchar(255),
date Datetime,
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinations numeric,
)
Insert into  #PercentPopVac
select  dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as bigint)) --Here bigint used because int can't handle the big integer
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidVaccine vac
join PortfolioProject..CovidDeaths dea
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null

select *, (RollingPeopleVaccinations/population)*100 as VaccinePercentage
from  #PercentPopVac




--Creat view for later use in visualization

Create View  PercentPopVac as
select  dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as bigint)) --Here bigint used because int can't handle the big integer
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidVaccine vac
join PortfolioProject..CovidDeaths dea
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
