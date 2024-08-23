
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3, 4

Select *
From PortfolioProject..CovidVaccination
Order By 3, 4

--Selecting data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in your Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%India%'
Order By 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
Order By 1,2 

--Looking at Countries with highest Infection rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%India%'
Group By Location, Population
Order By PercentPopulationInfected desc

--Showing Countries with highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%India%'
Group By Location
Order By TotalDeathCount desc

--LET'S BREAK THINGS BY CONTINENT

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
--Where location like '%India%'
Group By Location
Order By TotalDeathCount desc

--GLOBAL NUMBERS

Select Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int)) / Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%India%'
--Group By date
Order By 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

--USE CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as Bigint)) Over (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as Bigint)) Over (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3




