-- Select Data that we are going to be using
-- Clause where continent is not null helps to take out continents from our locations query

Select Location, date, total_cases, new_cases, total_deaths, population
From DataExploration..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in Mexico

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentagePerCase
From DataExploration..CovidDeaths
Where continent is not null
and location = 'Mexico'
order by DeathPercentagePerCase desc


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopInfected
From DataExploration..CovidDeaths
Where continent is not null
order by PercentPopInfected desc


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From DataExploration..CovidDeaths
Where continent is not null
Group By Location, Population
order by PercentPopInfected desc


-- Looking at Countries with Highest Infection Rate compared to Population with Having Clause

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From DataExploration..CovidDeaths
Where continent is not null
Group By Location, Population
Having population > 100000000
order by PercentPopInfected desc


--Showing Countries with Highest Death Count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From DataExploration..CovidDeaths
Where continent is not null
Group By Location, Population
order by TotalDeathCount desc


--Showing Continents with Highest Death Count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From DataExploration..CovidDeaths
Where continent is not null
--and location not in('High Income','Upper middle income','Lower middle income','Low income')
Group By continent
order by TotalDeathCount desc


-- Showing percentage of people dying from getting COVID around the world per day

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From DataExploration..CovidDeaths
Where continent is not null
Group by date
order by 1 desc


-- Showing percentage of people dying from getting COVID around the world as today (2023-02-06)

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From DataExploration..CovidDeaths
Where continent is not null
--Group by date
order by 1, 2


-- Looking at Total Population vs Vaccinations and the adding up per date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From DataExploration..CovidDeaths dea
Join DataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- Use of CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From DataExploration..CovidDeaths dea
Join DataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopVacc
From PopVsVac


-- Use of Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From DataExploration..CovidDeaths dea
Join DataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopVacc
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Use DataExploration
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From DataExploration..CovidDeaths dea
Join DataExploration..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated
