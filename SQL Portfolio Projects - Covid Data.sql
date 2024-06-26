Select *
From [Portfolio Projects]..CovidDeaths
Where continent is not null
order by 3,  4

--Select *
--From [Portfolio Projects]..CovidVaccinations$
--order by 3,  4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Projects]..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Projects]..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, Population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/population))*100 as PercentPopulationInfected
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Group by location, Population 
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the continents with the highest date count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated, 
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projects]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
--order by TotalDeathCount desc


