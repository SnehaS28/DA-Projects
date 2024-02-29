Select *
from [Portfolio-Project].dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--from [Portfolio-Project]..CovidDeaths

--Select *
--from [Portfolio-Project].dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population
From [Portfolio-Project].dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio-Project].dbo.CovidDeaths
where location like '%India%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what Percentage of population got covid
Select Location, date, total_cases, Population, (total_deaths/population)*100 as DeathPercentage
From [Portfolio-Project].dbo.CovidDeaths
--where location like '%India%'
where continent is not null
order by 1,2

-- Looking at countries with Highest infection rate compared to Population
Select Location, Max(total_cases) as HighestInfectionRate, Population, Max((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio-Project].dbo.CovidDeaths
--where location like '%India%'
--where location like '%states%'
where continent is not null
group by Location, population
order by PercentagePopulationInfected desc

-- Looking at countries with Highest death count per population
-- Total_deaths data type is varchar so we convert it into integer
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio-Project].dbo.CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


-- Breaking things down by continents
--Showing continent with highest deaths count
--with the continent table we were not getting data so we changed continents to location
Select location , max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio-Project].dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Select continent , max(cast(total_deaths as int)) as TotalDeathCount
--From [Portfolio-Project].dbo.CovidDeaths
--where continent is not null
--group by continent
--order by TotalDeathCount desc


--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio-Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Second table
Select *
from [Portfolio-Project].dbo.CovidVaccinations

--Joining tables
--Select *
--from [Portfolio-Project].dbo.CovidDeaths dea
--Join [Portfolio-Project].dbo.CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio-Project]..CovidDeaths dea
Join [Portfolio-Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
from PercentPopulationVaccinated