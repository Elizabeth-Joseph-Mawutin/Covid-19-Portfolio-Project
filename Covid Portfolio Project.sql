Select *
From Portfolio_Project..CovidDeaths
where continent is not null
ORDER BY 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (CAST(total_deaths as int) / CAST(total_cases as int))*100 as DeathPercentage 
from Portfolio_Project..CovidDeaths
where location like '%nada%'
and continent is not  null
order by 1,2



--Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
from Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

--Countries with highest infection rate vs population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent, Population
order by PercentPopulationInfected desc


--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases) * 100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not  null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population) * 100
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


--Looking at Total Population vs Vaccinations

with PopVsVac (continent, location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated

