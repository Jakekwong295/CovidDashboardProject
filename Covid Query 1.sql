/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we are going to be using
select * from CovidDeaths
where continent is not null
and location not in ('European Union', 'High income', 'Low income', 'Lower middle income', 'Upper middle income')
order by 3,4

-- Querying the list of countries
select distinct iso_code, continent, location
from CovidDeaths


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
Where continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as Infected_pop_percentage
from CovidDeaths
Where continent is not null
order by 1, 2

-- Country with highest infection rate compared to Population
Select Location, MAX(total_cases) as Highest_Infection_count, population, Max((total_cases/population))*100 as Infected_pop_percentage
from CovidDeaths
where continent is not null
group by Location, population
order by Infected_pop_percentage desc

-- Let's break things down by continent
-- Showing the continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as Total_death_count
from CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc

-- Showing Country with highest death count per population in descending order
Select Location, MAX(cast(total_deaths as int)) as Total_death_count
from CovidDeaths
where continent is not null
group by Location
order by Total_death_count desc


-- Global Numbers of total cases, total deaths and death percenatge (total deaths/ total cases)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100  as Death_Percentage
from CovidDeaths
Where continent is not null
order by 1, 2

-- Vaccination table
select * from [dbo].[CovidVaccinations]
order by 3,4

-- Joining CovidDeaths and CovidVaccinations Tables
select * 
from [dbo].[CovidDeaths] dea 
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rolling_vaccinated_count
from [dbo].[CovidDeaths] dea 
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_vaccinated_count)
as 
(
select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rolling_vaccinated_count
from [dbo].[CovidDeaths] dea 
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_vaccinated_count/Population)*100
from PopvsVac


-- Creating View to store data for analyzing percentage of vaccinated people for each country

Create View Percent_Population_Vaccinated as
select dea.continent, dea.location, cast(dea.date as date) as date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as rolling_vaccinated_count
from [dbo].[CovidDeaths] dea 
join [dbo].[CovidVaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- To recall the view created above

select * from Percent_Population_Vaccinated

-- Checking Columns for both tables
SELECT *
FROM sys.columns
WHERE object_id = OBJECT_ID('CovidDeaths')

SELECT *
FROM sys.columns
WHERE object_id = OBJECT_ID('CovidVaccinations')

-- Selecting main tables for Power BI project

select * from CovidDeaths
WHERE continent is not null
order by 3,4

select * from CovidVaccinations 
WHERE continent is not null
order by 3,4

-- Extracting Population Table from CovidDeaths
select continent, location, avg(population) as pop
from CovidDeaths
where continent is not null
group by continent, location
order by location asc

-- Extracting median_age, aged_65_older, gdp_per_capita, life_expectancy, human_development_index from CovidVacchinations
-- Comparing Country Data with Covid Vaccinations and Deaths 
select location, Avg(median_age) as median_age, avg(aged_65_older) as age_65_above, avg(convert(bigint,gdp_per_capita)) as gdp_per_capita , avg(life_expectancy) as life_expectancy, avg(human_development_index) as hdi
from [dbo].[CovidVaccinations]
where continent is not null 
group by location
order by location asc


