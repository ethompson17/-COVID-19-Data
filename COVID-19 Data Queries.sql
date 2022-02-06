select *
from CovidDeaths
order by 3,4;

select * 
from CovidVaccinations
order by 3,4

select location, date,total_cases, new_cases,total_deaths, population
from CovidDeaths
order by 1,2




--Looking at total cases vs total deaths

--Shows likelyhood of dying if you contract covid in your country

select location, date,total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1.dbo.CovidDeaths
where location like 'United States'
order by 1,2





--Looking at total cases vs population

--shows what percentage of population got covid

select location, date,Population,total_cases, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioProject1.dbo.CovidDeaths
--where location like 'United States'
order by 1,2




--Looking at countries with Highest Infection Rate compared to Population

select location,Population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProject1.dbo.CovidDeaths
--where location like 'United States'
group by location,population, date
order by PercentOfPopulationInfected desc




--Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1.dbo.CovidDeaths
--where location like 'United States'
where continent is not null
group by location
order by TotalDeathCount desc



--BREAKING THINGS DOWN BY CONTINENT

--Showing Continents with the Highest Death Count per Population

select continent, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as WorldDeathPercentage
from PortfolioProject1.dbo.CovidDeaths
--where location like 'United States'
where continent is not null
--group by date
order by 1,2






--COVID VACCINATIONS


--Looking at Total Population vs Vaccinations (Need CTE or Temp Table

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join portfolioproject1.dbo.CovidVaccinations vac
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join portfolioproject1.dbo.CovidVaccinations vac
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join portfolioproject1.dbo.CovidVaccinations vac
on dea.location =vac.location and dea.date =vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




--Creating View to store data for later visualizations

-- View of the Percent of the Population Vaccinated

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join portfolioproject1.dbo.CovidVaccinations vac
on dea.location =vac.location and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
order by 2,3


-- View of the Highest Death Counts among Countries

Create view HighestDeathCountPerCountry as
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is not null
group by location
--order by TotalDeathCount desc


select *
from HighestDeathCountPerCountry
order by TotalDeathCount desc


-- View of Percent Of the Population Infected with COVID-19

Create view PercentOfPopulationInfected as
select location,Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProject1.dbo.CovidDeaths
group by location,population
--order by PercentOfPopulationInfected desc


select *
from PercentOfPopulationInfected
order by PercentOfPopulationInfected desc


-- View of Total Death Count among World Continents

Create view ContinentDeathCount as
select continent, MAX(CONVERT(INT, total_deaths)) as TotalDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is not null 
group by continent
--order by TotalDeathCount desc


select *
from ContinentDeathCount
order by TotalDeathCount desc
