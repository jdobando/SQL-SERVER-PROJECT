SELECT * FROM
JDOP_DB..CovidDeaths
ORDER BY 3,4

SELECT  * FROM
JDOP_DB..CovidVaccinations
ORDER BY 3,4


SELECT date,location,total_cases,total_deaths,(total_deaths / total_cases )* 100 AS PercentDeaths
FROM
JDOP_DB..CovidDeaths
where location = 'Australia' 
ORDER BY 1 desc

-- higest infection rates

SELECT location,population,max(total_cases) as InfectionCount,max(( total_cases / population))* 100 AS PercentPopulation
FROM
JDOP_DB..CovidDeaths
where location like '%Colombia%'
group by location,population
ORDER BY PercentPopulation desc

-- max number of deaths
--
SELECT continent,sum(cast(total_deaths as int)) as deathsCount
FROM
JDOP_DB..CovidDeaths
where continent is not null
--where location like '%Colombia%'
group by continent
ORDER BY deathsCount desc

-- GENERAL JOIN QUERY

select * from 
JDOP_DB..CovidDeaths DEA
JOIN 
JDOP_DB..CovidVaccinations VAC
ON
DEA.date = VAC.date and
DEA.location = VAC.location
where DEA.continent IS NOT NULL

-- POPULATION VR VACINATION

select DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(convert(int,VAC.new_vaccinations)) over (partition by DEA.location order by DEA.location,DEA.date) as RollingVaccination
from 
JDOP_DB..CovidDeaths DEA
JOIN 
JDOP_DB..CovidVaccinations VAC
ON
DEA.date = VAC.date and
DEA.location = VAC.location
where DEA.continent IS NOT NULL
ORDER BY 2,3

--ver with 

with PopvrVac (continent,location,date,population,new_vaccinations, RollingVaccination)
as (
select DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(convert(int,VAC.new_vaccinations)) over (partition by DEA.location order by DEA.location,DEA.date) as RollingVaccination
from 
JDOP_DB..CovidDeaths DEA
JOIN 
JDOP_DB..CovidVaccinations VAC
ON
DEA.date = VAC.date and
DEA.location = VAC.location
where DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccination / population )*100 as PCT_VACINATION
FROM PopvrVac


--- TABLE CREATION

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(convert(int,VAC.new_vaccinations)) over (partition by DEA.location order by DEA.location,DEA.date) as RollingVaccination
from 
JDOP_DB..CovidDeaths DEA
JOIN 
JDOP_DB..CovidVaccinations VAC
ON
DEA.date = VAC.date and
DEA.location = VAC.location
where DEA.continent IS NOT NULL

select *,(RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- view

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
select DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(convert(int,VAC.new_vaccinations)) over (partition by DEA.location order by DEA.location,DEA.date) as RollingVaccination
from 
JDOP_DB..CovidDeaths DEA
JOIN 
JDOP_DB..CovidVaccinations VAC
ON
DEA.date = VAC.date and
DEA.location = VAC.location
where DEA.continent IS NOT NULL
--ORDER BY 2,3



SELECT * FROM PercentPopulationVaccinated

