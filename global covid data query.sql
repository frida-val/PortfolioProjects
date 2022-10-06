--Table 1 Covid Deaths
select*
from PortfolioProject..['Covid Deaths - Copy$']
where continent is not null
order by 3,4

--select*
--from PortfolioProject..['Covid Vaccinations - Copy$']
--order by 3,4

--select Data that I will be using

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..['Covid Deaths - Copy$']
where continent is not null
order by 1,2

--total cases vs total deaths
--shows the likelihood of covid deaths in Africa

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['Covid Deaths - Copy$']
where continent = 'Africa'
order by 1,2


--looking at total cases vs the population
-- shows what percent of the population for Covid

select location, date, population, total_cases,(total_cases/population)*100 as CasesPercentage
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa'
--where location like '%Africa%'
order by 1,2

--what country has highest infection rate relative to the population

select location, population, max(total_cases) as highestinfectioncount,max(total_cases/population)*100 as highestPercentage
from PortfolioProject..['Covid Deaths - Copy$']
where continent = 'Africa'
--where location like '%Africa%'
group by location,population 
order by highestPercentage desc

--shows countries with the highest deathcount per population

select location, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa' 
where continent is not null
group by location
order by TotaldeathCount desc


--TotalDeaths per location

select location, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa' 
where continent is null
group by location
order by TotaldeathCount desc


--Break things down by Continent


select continent, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa' 
where continent is not null
group by continent
order by TotaldeathCount desc

--showing the continent with the highest death counts

select continent, max(cast(total_deaths as int)) as TotaldeathCount
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa' 
where continent is not null
group by continent
order by TotaldeathCount desc

breaking global numbers

select date, sum (new_cases) as Totalnewcases,sum (cast(new_deaths as int))as Totalnewdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..['Covid Deaths - Copy$']
--where continent = 'Africa'
where continent is not null
group by date
order by 1,2

--Table2 Covid Vaccinations
--Looking at total population vs vaccination
-- convert data type of new_vaccinations or cast

select deaths.continent, deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
sum(convert(bigint,vaccine.new_vaccinations))
over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths - Copy$'] deaths
join PortfolioProject..['Covid Vaccinations - Copy$'] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null
order by 2,3


--Use CTE


With populationvsvaccine(continent, location,date,population,new_vaccinations, rollingpeoplevaccinated)
as
(
select deaths.continent, deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
sum(convert(bigint,vaccine.new_vaccinations))
over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVccinated
from PortfolioProject..['Covid Deaths - Copy$'] deaths
join PortfolioProject..['Covid Vaccinations - Copy$'] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from populationvsvaccine


--TEMP TABLE
--drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #PercentPopulationVaccinated

select deaths.continent, deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
sum(convert(bigint,vaccine.new_vaccinations))
over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVccinated
from PortfolioProject..['Covid Deaths - Copy$'] deaths
join PortfolioProject..['Covid Vaccinations - Copy$'] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- create view to store data for later visualisations

create view PercentPopulationVaccinated as
select deaths.continent, deaths.location,deaths.date,deaths.population,vaccine.new_vaccinations,
sum(convert(bigint,vaccine.new_vaccinations))
over (partition by deaths.location order by deaths.location, deaths.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths - Copy$'] deaths
join PortfolioProject..['Covid Vaccinations - Copy$'] vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
where deaths.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated
