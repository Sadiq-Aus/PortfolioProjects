Select * from dbo.['Covid Deaths$']
Where continent is  not null
order by 3,4

Select * from dbo.['Covid Vaccinations$']
order by 3,4

----Portfolio Project Select data

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Projects].dbo.['Covid Deaths$']
order by 1,2

-----Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from [Portfolio Projects].dbo.['Covid Deaths$']
Where location like '%State%'
Order by 1,2

--------Looking at Total cases Vs Population
-----Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as CasesPopPercentage
from [Portfolio Projects].dbo.['Covid Deaths$']
Where location like 'Australia'
Order by 1,2

------------------------Looking at Countries with Highest Infection rate compared to Population

Select location, population, max(total_cases) as HightestInfectionCount, max((total_cases/population))*100 as PercenPopulationInfected
from [Portfolio Projects].dbo.['Covid Deaths$']
---Where location like '%States%'
Group by Location, Population
Order by PercenPopulationInfected DESC

-----Showing countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects].dbo.['Covid Deaths$']
---Where location like '%States%'
Where continent is  not null
Group by Location
Order by TotalDeathCount DESC


------------Lets breakt things down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects].dbo.['Covid Deaths$']
---Where location like '%States%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--------------Showing continents with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Projects].dbo.['Covid Deaths$']
---Where location like '%States%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

-------Global Numbers
Select date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from [Portfolio Projects].dbo.['Covid Deaths$']
----Where location like '%State%'
Where continent is not null
Order by 1,2

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Projects].dbo.['Covid Deaths$']
----Where location like '%State%'
Where continent is not null
Group by date
Order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Projects].dbo.['Covid Deaths$']
----Where location like '%State%'
Where continent is not null
---Group by date
Order by 1,2


------------Covid Vaccinations table
select * from [Portfolio Projects].dbo.['Covid Vaccinations$']

-----looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Projects].dbo.['Covid Deaths$'] dea
join [Portfolio Projects].dbo.['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

----
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Projects].dbo.['Covid Deaths$'] dea
join [Portfolio Projects].dbo.['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

---Use CTE
with PopVsVac (Continent,location,date,population, new_vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Projects].dbo.['Covid Deaths$'] dea
join [Portfolio Projects].dbo.['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3
)
select * 
from PopVsVac

run dbcc

---Temp table

Create table #percentpopulationvaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Projects].dbo.['Covid Deaths$'] dea
join [Portfolio Projects].dbo.['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-----Creating View for visualisations
Create view PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Projects].dbo.['Covid Deaths$'] dea
join [Portfolio Projects].dbo.['Covid Vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
---order by 2,3