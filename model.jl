#   Copyright (C) 2020 Martin Hinsch <hinsch.martin@gmail.com>

### include library code
using Random
using SimpleAgentEvents
using SimpleAgentEvents.Scheduler


### declare agent type(s)
mutable struct ComplexHuman
    migrant :: update_migrant_status!()
    employed :: Bool
    industry :: Industry()
    nationality :: Nationality
    # like this ^ ?
    # or this:
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


function update_migrant_status!()
    # is the agent in the origin or destination country?
end


function update_job_market!()
    # needs to be like hey no more jobs
    # you can't get these jobs they're gone
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
function setup_migrants(n, p_contact)
    pop = [ ComplexHuman() for i=1:n ]
    # go through all combinations of agents and
    # check if they are connected
    # TO DO this should be only people of the same nationality
    # TO DO only those who are employed get to have an industry
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


