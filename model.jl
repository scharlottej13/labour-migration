#   Copyright (C) 2020 Martin Hinsch <hinsch.martin@gmail.com>

### include library code
using Random


# Industry of employment (took the top 10 from LinkedIn)
@enum Industry Information_Technology Hospital_HealthCare Construction Education_Management Retail Financial Accounting Computer_Software Automotive Higher_Education

### declare agent type(s)
mutable struct ComplexHuman
    # var :: type
    migrant :: Bool
    employed :: Bool
    industry :: Int
    origin :: Country
    residence :: Country
    contacts :: Vector{ComplexHuman}
end


mutable struct Country
    # this rate w/ be used in migration decision
    migration_rate :: Float64
    job_market :: Int
end


mutable struct Industry
    num_jobs :: num_jobs
end


function update_job_market!()
    for i in length(pop):
        if pop[i].employed == false
            return
        end
        if pop[i].employed == true
        Industry.num_jobs += 1
        end 
    # needs to be like hey no more jobs
    # you can't get these jobs they're gone
end
end


# what are our agents *doing*
# they are migrating, being hired, being fired, and chatting w/ other migrants
# for our population that has already migrated, their migration rate will be 0
mutable struct Simulation{AGENT}
    # model parameters:
    # job hire rate
    hirer :: Float64
    # being fired
    firer :: Float64
    # communication rate
    commr :: Float64
    # and this is our population of agents
    pop :: Vector{AGENT}
end

# hire & fire should be part of job market
# define struct that is the job market that has rates
# which are hire and fire
# keep it simple, have one global job market
mutable struct JobMarket
    hire_rate :: Float64
    fire_rate :: Float64
end
end


function update_migrant_status!(person, sim)
     if person.migrant == true
        return
    end
    if person.migrant == false
        if person.contacts.migrant == true && person.contacts.employed >= "friends_employment_rate" && rand() < sim.commr
#             ...I'd like to check how many of contacts are employed. if greater then a certain amount THEN
            person.migrant == true
            person.residence == # lo stesso degli amichetti suoi
        end
    end
end



function update_migrant_employment!(person, sim)
    if person.employed == true
        return
    end
    if person.employed == false
        if person.contacts.migrant == true && person.contacts.employed == true && person.contacts.industry # are employed in a certain jobmarket with a rate higher than a certain amount THEN
            if rand()< industry.hire.rate #same industry of his friends
            person.employed == true
            person.industry == # lo stesso degli amichetti suoi
        end
    end
    function update_labour_market!()
end
# WE HAVE TO ADD SOME RANDOMNESS IN THIS FUNCTION THO!




    
    
function update_migrant_status!(person, sim)
    # CHANGE ALL OF THIS
    # now it will be more about residence
    # no more hiring/firing rate
    # needs to know about destination countries
    # how are destination countries selected (select as random to start)
    # ok, so what happens when a migrant migrates
    # migrant status
    # country of residence
    # anything else?
    # migration decision means two things:
    # change the state of the person
    # change the country
    # need to think about how to do this
    
    # exit out if they are a migrant
    if person.migrant == true
        return
    end
    # if you get a job then you move?
    if rand() < sim.hirer
        person.migrant = true
        # maybe you don't need the else clause if default is false
    else
        person.migrant = false
    # BUT if you also have contact w/ migrant, then you are more likely
    # to get a job (for example)
    if rand(person.contacts).migrant == true && rand() < sim.commr
        person.migrant = true
    end
end

# will need this eventually, however, right now this is not a priority
function update_labour_market!()
end



## it's easier to implement with  different function for each status
## wirte what will happen at each timestep and what the change is determined by

## build a population: a vector of population objects and fill with population randomly generated or identical (add to a vector through push!(vector,element).
## write an update function that modifies the agent a tiny bit in terms of properties -> loop it on all agents
## go through all agents and one another to a contact list  (something like: 
# for j in i+1:length(pop)
#             if rand() < p_contact
#                 push!(pop[i].contacts, pop[j])
#                 push!(pop[j].contacts, pop[i])
# end

# visually, picture red circles on the left as natives who can migrate
# and blue circles on the right as people who have already migrated
# these are our two starting populations
function setup_population(n, p_contact)
    pop = [ ComplexHuman() for i=1:n ]
    # go through all combinations of agents and
    # check if they are connected
    for i in eachindex(pop)
        for j in i+1:length(pop)
            if rand() < p_contact
                push!(pop[i].contacts, pop[j]) #this should turn into a for loop for each country
                push!(pop[j].contacts, pop[i])
            end
        end
    end
    pop
end

# need a setup
# create labour markets
# population
# all countries
# assign agents to countries
# assign properties to agents
# assign properties to countries
# add contacts to agents
# return the simulation object
# then the global update function (this will call all necessary updat f'ns)
# need run function, this will print interesting information (relevant output?)
# ignore spatial structure, create a mixed population
# take N (number) of random agents as contacts
