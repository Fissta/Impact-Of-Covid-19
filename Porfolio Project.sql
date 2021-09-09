select * from PotfolioProject..CovidDeaths$ 
where continent is not null
order by 3,4

--select * from PotfolioProject..CovidVacinations$ order by 3,4

select location, date,total_cases,new_cases,total_deaths,population
from PotfolioProject..CovidDeaths$ order by 1,2

-- Total Case vs Total Deaths
-- Show the likelihood of Death
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PotfolioProject..CovidDeaths$
where location like '%China%'
order by 1,2 desc


-- Total Cases VS Population
-- Shows what % of Population Affected
select location, date,population,total_cases, (total_cases/population)*100 as Pop_Infected
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
order by 1,2


-- Coutries with Highest Infection Rate in Relation To Population
select location,population,Max(total_cases) as Highest_Affected, Max((total_cases/population)*100) as Pop_Infected
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
Group by location,population
order by Pop_Infected desc


-- Countries With Highest Death Count By Population
select location,Max(cast(total_deaths as int)) as Total_Death_Count
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
where continent is not null
Group by location
order by Total_Death_Count desc

--This is the correct one
-- Continent With Highest Death Count By Population
select location,Max(cast(total_deaths as int)) as Total_Death_Count
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
where continent is null
Group by location
order by Total_Death_Count desc


--Using this for Data Rep
-- Continent With Highest Death Count By Population
select continent,Max(cast(total_deaths as int)) as Total_Death_Count
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
where continent is not null
Group by continent
order by Total_Death_Count desc

-- Global Numbers By Date
select date,SUM(new_cases)as total_case,SUM(cast(new_deaths as int)) as total_dead, 
(SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as Death_Percentage
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
where continent is not null 
group by date
order by 1,2


--Global Numbers
select SUM(new_cases)as total_case,SUM(cast(new_deaths as int)) as total_dead, 
(SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as Death_Percentage
from PotfolioProject..CovidDeaths$
--where location like '%Ghana%'
where continent is not null 
--group by date
order by 1,2


-- Join Tables
select * from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date

-- Total Population VS Vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Rolling Point
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PepoleVaccinatedByDate
from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Rolling Point With CTE
with PopVSVac (Continent, Location, Date, Population, New_Vaccinations, PepoleVaccinatedByDate) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PepoleVaccinatedByDate
from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

select * , (PepoleVaccinatedByDate/Population) * 100 as Percentage_Vaccinated
from PopVSVac


-- Alternatively Use Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated (
	continent nvarchar (225),
	Location nvarchar (225),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	PepoleVaccinatedByDate numeric

)
insert into #PercentagePopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PepoleVaccinatedByDate
from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select * , (PepoleVaccinatedByDate/Population) * 100 as Percentage_Vaccinated
from #PercentagePopulationVaccinated


-- Creating Views to Store Data For Later Use

drop view PercentagePopulationVaccinated

Create View PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PepoleVaccinatedByDate
from	PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentagePopulationVaccinated
