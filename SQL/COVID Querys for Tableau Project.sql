/*

Queries used for Tableau Project

Database last updated on 02/07/2023

*/
--1. Showing total cases, total deaths and death percentage per case worldwide

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM DataExploration..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--2. Showing total deaths per country in descending order (European Union is part of Europe and we are not interested in deaths per income)

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM DataExploration..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

--3. Showing total cases and percentage of population infected

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
FROM DataExploration..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected desc

--4. Showing total cases and percentage of population infected by date

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
FROM DataExploration..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopInfected desc
