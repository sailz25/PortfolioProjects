select * from PortfolioProject..CovidData  
where continent is not null
order by 3,4
--select * from PortfolioProject..CovidVaccinations order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population 
From PortfolioProject..CovidData 
where continent is not null 
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location,date,total_cases,total_deaths, (CONVERT(FLOAT,total_deaths )/ NULLIF(CONVERT(FLOAT,total_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidData  
where location like '%Singapore%' and continent is not null
order by 1,2

--Looking at Total cases vs Population

Select Location,date,population,total_cases,  (CONVERT(FLOAT,total_cases)/population)*100 as PopulationInfectedPercent
From PortfolioProject..CovidData  
--where location like '%Singapore%' and continent is not null
order by 1,2
--Looking at Countries with Highest Infection Rate compared to Population

Select Location,population,MAX(total_cases) as HighestInfectionCount,  MAX( (total_cases/population))*100 as MaxPopulationInfectedPercent
From PortfolioProject..CovidData 
where continent is not null
Group By Location,Population
order by MaxPopulationInfectedPercent desc

--showing countries with highest death count per population

Select Location,MAX(CAST(Total_deaths as int)) as HighestDeathCount 
From PortfolioProject..CovidData  
where continent is not null
Group By Location 
order by HighestDeathCount desc
 
 --showing things by continent

 --showing continents with the highest death count per population

Select continent,MAX(CAST(Total_deaths as int)) as HighestDeathCount 
From PortfolioProject..CovidData  
where continent is not null
Group By continent
order by HighestDeathCount desc
 
--GLOBAL NUMBERS
--total death percentage per day in the world
Select date,SUM(new_cases) as total_cases,sum(CAST(new_deaths as int)) as total_deaths, (sum(CAST(new_deaths as int))/SUM(new_cases))*100 as deathPercentagePerDay
From PortfolioProject..CovidData  
where continent is not null
Group By date
order by 1,2

--Total deathPercentage till now
Select SUM(new_cases) as total_cases,sum(CAST(new_deaths as int)) as total_deaths, (sum(CAST(new_deaths as int))/SUM(new_cases))*100 as deathPercentagePerDay
From PortfolioProject..CovidData  
where continent is not null
order by 1,2

select * from CovidVaccinations
--Looking at Total Population vs Vaccinations

select deaths.continent ,deaths.location, deaths.date,deaths.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVacccinated
from PortfolioProject..CovidData  deaths
join PortfolioProject..CovidVaccinations  vac
  on deaths.location=vac.location
  and deaths.date=vac.date
where deaths.continent is not null
order by 2,3

--USE CTE

with PopvsVac(Continent,Location,DAte,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select deaths.continent ,deaths.location, deaths.date,deaths.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVacccinated
from PortfolioProject..CovidData  deaths
join PortfolioProject..CovidVaccinations  vac
  on deaths.location=vac.location
  and deaths.date=vac.date
where deaths.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 as percentageVaccinated from PopvsVac

--Temp Table
Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacccinated numeric
)
Insert into #PercentPopulationVaccinated
select deaths.continent ,deaths.location, deaths.date,deaths.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVacccinated
from PortfolioProject..CovidData  deaths
join PortfolioProject..CovidVaccinations  vac
  on deaths.location=vac.location
  and deaths.date=vac.date
--where deaths.continent is not null
--order by 2,3

select *,(RollingPeopleVacccinated/population)*100 as percentageVaccinated from #PercentPopulationVaccinated

--Create a VIEW to store data for visualizations

Create View PercentPopulationVaccinated as
select deaths.continent ,deaths.location, deaths.date,deaths.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVacccinated
from PortfolioProject..CovidData  deaths
join PortfolioProject..CovidVaccinations  vac
  on deaths.location=vac.location
  and deaths.date=vac.date
--where deaths.continent is not null
--order by 2,3

select *from PercentPopulationVaccinated





