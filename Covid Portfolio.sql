Select *
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null
order by 3, 4

--Select *
--FROM PortfolioProject1.dbo.CovidVaccination
--order by 3, 4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null
order by 1, 2 

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CAST (total_deaths AS float)/ CAST (total_cases AS float))*100 AS DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
Where Location = 'United Kingdom' 
and continent is not null
order by 1, 2 

-- Looking at the Total Cases vs the Population
--Shows what percentage of the population got covid

Select Location, date, population, total_cases, (total_cases / population)*100 AS InfectedPercentage
From PortfolioProject1.dbo.CovidDeaths
Where Location = 'United Kingdom' 
order by 1, 2 

--Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 AS InfectedPercentage
From PortfolioProject1.dbo.CovidDeaths
--Where Location = 'United Kingdom' 
Group by Location, Population
order by InfectedPercentage desc

--Showing the countries with the highest death count per popuation

Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths
--Where Location = 'United Kingdom' 
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the continents with the highest death count per population

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths
--Where Location = 'United Kingdom' 
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/NULLIF (SUM(new_cases), 0) *100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
-- Where Location = 'United Kingdom' 
Where continent is not null
--Group by date
order by 1, 2 

--Looking at Total Poupulation vs Vaccinations

Select *
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccinations
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingVaccinations/Population)*100
From PopvsVac 


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated 

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject1.dbo.CovidDeaths dea
Join PortfolioProject1.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated