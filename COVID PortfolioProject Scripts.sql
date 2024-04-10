 use PortfolioProject;

-- looking at total cases vs total deaths country wise
select location, date, total_cases, new_cases,total_deaths
,cast(total_deaths as float)  / cast(total_cases as float) * 100 as Deathpercentage    
from CovidDeaths WHere location like '%indi%' and continent is not null 
order by 1,2;
-- looking at total cases vs population
select location, date, total_cases, population
,(cast(total_cases as float)  / cast(population as float)) * 100 as infectedpercentage    
from CovidDeaths WHere location like '%states%'  and continent is not null
order by 1,2;


-- looking at country with highest infection rate compared to population

select location,population, MAX(total_cases) as Highest_infected_count
,max((cast(total_cases as float)  / cast(population as float)) * 100) as PercentPopulation_infected
from CovidDeaths 
group by  location, population
order by PercentPopulation_infected desc;

-- Showing countries with highest death count per location
select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths where continent is not null
Group by Location
order by TotalDeathCount desc;

-- breaking things down by continent
-- showing continents with highest death count

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths where continent is  not null
group by continent
order by TotalDeathCount desc;

--Global number of new cases
select date, SUM(New_cases) as total_NewCases
from CovidDeaths
where continent is not null
group by date
order by 1 desc,2;

-- New cases and new death Across the World Per day..

select date, SUM(new_cases)as Total_NewCases, SUM(new_deaths) as Total_Death
from CovidDeaths 
where continent is not null
group by date
order by 1 desc,2;

-- global Numbers

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths,
SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2;



-- New cases and new death Across the World Per day along with Deathpercentage

select date, SUM(new_cases)as Total_NewCases, SUM(new_deaths ) as Total_Death, 
sum(new_cases) / SUM(new_deaths) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1 desc,2;


-- joining both the table base on Location and Date.
select * from CovidVaccinations;
select * from CovidDeaths;

select *
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date;

-- looking at Total populations vs vacinnations per day

select dea.continent, dea.location, dea.date, dea.population,new_vaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Rolling count using window function and partition by location and order by date
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) as Rolling_People_vaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Rolling count using window function and partition by location and order by date and % people got vaccinated

select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/ population) * 100
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--we will get error as we cannot use a column which is created now. for this we can use CTE Method or Temp table.

-- using CTE
With popVSvac(continent,location, date,Population, new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated / Population) * 100 as Percentage_got_vaccinated
from popVSvac;

-- using Temp table(its quite hard comapre to CTE... better to use CTE instead

drop table if exists #Percentpopulationvaccinated
create table #PercentpopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated Numeric
)
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
select * ,(RollingPeopleVaccinated /Population) * 100 as Percentage_got_vaccinated
from #PercentpopulationVaccinated;

--creating view for visualisations
--A
create view PercentPopulationvaccinated AS
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) as Rolling_People_vaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
;

select * from PercentPopulationvaccinated;

--B

Create view PopulationVSVaccination as
With popVSvac(continent,location, date,Population, new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
SUM(convert(float, new_vaccinations  )) over(partition by dea.location Order by dea.date) 
as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated / Population) * 100 as Percentage_got_vaccinated
from popVSvac;

select * from PopulationVSVaccination;
  


