#   Copyright (C) 2020 Martin Hinsch <hinsch.martin@gmail.com>

### include library code
using Random
using SimpleAgentEvents
using SimpleAgentEvents.Scheduler

### declare agent type(s)
mutable struct ComplexHuman
    migrant :: update_migrant_status!()
    employed :: Bool
    industry :: Industry
    nationality :: Nationality # TO DO replace this with another struct that was created in setup f'n
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

Person(x, y) = Person(susceptible, [], x, y)
Person(state, x, y) = Person(state, [], x, y)



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

function update_migrant_status!()
    # is the agent in the origin or destination country?
end

function update_job_market!()
    # needs to be like hey no more jobs
    # you can't get these jobs they're gone
    # or something
end


