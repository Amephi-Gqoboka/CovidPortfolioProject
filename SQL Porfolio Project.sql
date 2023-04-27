--- COVID 19 DATA EXPLORATION

-- Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


Select *
From CovidVaccines
where continent is not null
Order by 3,4


--Selecting Data we are going to be using

Select Location,Date, Total_cases, New_cases, Total_deaths, Population
From CovidDeaths
Where continent is not null
Order by 3,4


-- Looking at Total Cases vs Total Deaths in South Africa
-- Shows the liklihood of dying if you contract Covid in South Africa

Select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as percentage_deaths
From CovidDeaths
where location like '%South Africa%'
and continent is not null
Order by 2


-- Looking at the Total Cases vs Population
-- Shows the percentage of the population infected with covid in  


Select location, date, population, total_cases, (total_cases/population)*100 as Percentage_Population_Infected
From CovidDeaths
where location = 'South Africa'

-- Countries with Highest Infection rate Compared to Population


Select Location, Population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage_population_Infected
From CovidDeaths
Where continent is not null
Group by Location, Population
Order by Percentage_population_Infected desc


--Looking at Countries with the Highest Death Count per Population


Select Location, max(Total_deaths) as Total_Death_Count
From CovidDeaths
Where continent is not null
Group by Location
Order by Total_Death_Count desc


-- Breaking things down by Continent
--Showing the Continents with the highest Death Rate per Population


Select Location, max(Total_deaths) as Total_Death_Count
From CovidDeaths
Where continent is null and location not in ('High income','Upper middle income', 'Lower middle income', 'Low income', 'European Union')
Group by Location
Order by Total_Death_Count desc


-- GLOBAL NUMBERS BY DATE

Create View 
Select Date, sum(new_cases) as Total_Cases, sum (new_deaths) as Total_Deaths,
Case 
when sum(new_cases) = 0 Then NULL
Else sum(new_deaths)/sum(new_cases)*100
End as Death_Percentage
From CovidDeaths
where continent is not  null
Group by date
Order by 1



-- Looking at the Total Population vs Vaccinations
-- Shows the Percentage of Population that has recieved at Least one Vaccine


Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location 
	and dea.Date = vac.Date
where dea.continent is not null


-- Using CTE

With PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS

(Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location 
	and dea.Date = vac.Date
where dea.continent is not null)

Select*, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From PercentPopulationVaccinated


-- Using a Temp Table


DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location 
	and dea.Date = vac.Date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From #PercentagePopulationVaccinated



-- Creating Views To use in Later Visualisations

Create View RollingPeopleVaccinated 
AS
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location 
	and dea.Date = vac.Date
where dea.continent is not null


Create View PercentagePopulationVaccinated
AS
With PercentPopulationVaccinated (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS

(Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
ON dea.location = vac.location 
	and dea.Date = vac.Date
where dea.continent is not null)

Select*, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
From PercentPopulationVaccinated







