#   Copyright (C) 2020 Martin Hinsch <hinsch.martin@gmail.com>

### include library code
using Random


### declare agent type(s)
mutable struct ComplexHuman
    migrant :: update_migrant_status!()
    employed :: Bool
    industry :: Industry()
    origin :: OriginCountry()
    dest :: DestinationCountry()
    contacts :: Vector{ComplexHuman}
end


mutable struct OriginCountry
    job_market :: JobMarketFunction{some_input}
end


mutable struct DestinationCountry
    job_market :: JobMarketFunction{some_input}
end


mutable struct Industry
    num_jobs :: num_jobs
end


function update_job_market!()
    # needs to be like hey no more jobs
    # you can't get these jobs they're gone
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


function update_migrant_status!(person, sim)
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
                push!(pop[i].contacts, pop[j])
                push!(pop[j].contacts, pop[i])
            end
        end
    end
    pop
end


