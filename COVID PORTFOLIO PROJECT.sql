select * 
from Covid_deaths$
where continent is not null
order by 3,4
--select * 
--from Covid_vacinations$


--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from Covid_deaths$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths.

select location ,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Covid_deaths$
where continent is not null
order by 1,2

--Shows the likelihood of death as a result of contracting covid-19 in Kenya
select location ,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Covid_deaths$
where location like '%kenya%' and continent is not null
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage population has Covid
select location ,date, population,total_cases,(total_cases/population)*100 as Percentege_population
from Covid_deaths$
where continent is not null
--where location like '%kenya%'
order by 1,2

--Country with the highest infection rate
select location , population,MAX(total_cases)as Highest_infection_count,MAX((total_cases/population))*100 as Percentege_population
from Covid_deaths$
where continent is not null
--where location like '%kenya%'
Group by location,population
order by Highest_infection_count desc


--Breakdown by Continent
select continent ,max(cast(total_deaths as int))as Highest_death_count
from Covid_deaths$
where continent is not null
--where location like '%kenya%'
Group by continent
order by Highest_death_count desc


--Countries with the highest death rate per population
select location ,max(cast(total_deaths as int))as Highest_death_count
from Covid_deaths$
where continent is not null
--where location like '%kenya%'
Group by location
order by Highest_death_count desc

--Continents with the highest death count per population
select continent ,max(cast(total_deaths as int))as Highest_death_count
from Covid_deaths$
where continent is not null
--where location like '%kenya%'
Group by continent
order by Highest_death_count desc

--GLOBAL NUMBERS
select date,sum(new_cases) as Total_New_Cases, sum(cast(new_deaths as int))as Total_New_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 
--total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Covid_deaths$
--where location like '%kenya%' 
where continent is not null
group by date
order by 1,2

--GLOBAL TOTALS
select sum(new_cases) as Total_New_Cases, sum(cast(new_deaths as int))as Total_New_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 
--total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Covid_deaths$
--where location like '%kenya%' 
where continent is not null

order by 1,2

--Population vs vaccination outlook
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location ,
 dea.date) as Rolling_vaccinations
 from Covid_deaths$ dea
 join Covid_vacinations$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popvsvac(continent,location,date,population,new_vaccinations,Rolling_vaccinations)
as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location ,
 dea.date) as Rolling_vaccinations
 from Covid_deaths$ dea
 join Covid_vacinations$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(Rolling_vaccinations/population)*100
from popvsvac

--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_vaccinations numeric)
Insert into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location ,
 dea.date) as Rolling_vaccinations
 from Covid_deaths$ dea
 join Covid_vacinations$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *,(Rolling_vaccinations/population)*100
from #PercentPopulationVaccinated


--Creating Views for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location ,
 dea.date) as Rolling_vaccinations
 from Covid_deaths$ dea
 join Covid_vacinations$ vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated