
-- Global death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDataExploration..CovidDeaths
where continent is not null 
order by 1,2


-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
From CovidDataExploration..CovidDeaths
Where location like 'Poland'
order by 1,2


-- Infection percenge
Select location, population,  date, MAX(total_cases) as infection_count, MAX((total_cases / population))*100 as percent_population_infected
From CovidDataExploration..CovidDeaths
Group by location, population, date
order by 5 desc


-- Countries with highest infection rate
Select location, population, MAX(total_cases) as total_infection_count, (MAX(total_cases/population))*100 as cases_percentage
From CovidDataExploration..CovidDeaths
where continent is not null
Group by location, population
order by 4 DESC


-- Countries with highest death rate
Select location, population, MAX(total_deaths) as total_deaths_count, (MAX(total_deaths/population))*100 as deaths_percentage
From CovidDataExploration..CovidDeaths
where continent is not null
Group by location, population
order by 4 DESC


-- Countries with highest death count
Select location, MAX(cast(total_deaths as int)) as total_deaths_count
From CovidDataExploration..CovidDeaths
where continent is not null
Group by location
order by 2 DESC


-- Continents with highest death count
Select location, SUM(cast(new_deaths as int)) as total_deaths_count
From CovidDataExploration..CovidDeaths
where continent is null and location not in ('World', 'European Union', 'International')
Group by location
order by 2 DESC


-- Death percentage each day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
From CovidDataExploration..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Total populaiton vs Vaccinations
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as rolling_people_vaccinated
From CovidDataExploration..CovidDeaths as dea
Join CovidDataExploration..CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
Select *, (rolling_people_vaccinated/population)*100 as vaccination_percentage
From pop_vs_vac
order by 2,3


-- Creating View to store data
Create View PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as rolling_people_vaccinated
From CovidDataExploration..CovidDeaths as dea
Join CovidDataExploration..CovidVaccinations as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null


Select * From PercentagePeopleVaccinated