# At the start of the simulation, we have some "stock" of immigrants in the destination country
# they have some characteristics (job sector, nationality, etc.).
# As time progresses, agents decide whether or not to migrate based on:
# - the job market
# - number of other immigrants they know in the destination country
# Possible emergent outcomes:
# - maybe people migrate regardless of the job, just because of the network
# - or maybe people migrate *only* if there is a job
# - or maybe you need both network & a job?


# used a list of EU countries
@enum Nationality Austria Italy Belgium Latvia Bulgaria Lithuania Croatia Luxembourg Cyprus Malta Czechia Netherlands Denmark Poland Estonia Portugal Finland Romania France Slovakia Germany Slovenia Greece Spain Hungary Sweden

# Industry of employment (took the top 10 from LinkedIn)
@enum Industry Information_Technology Hospital_HealthCare Construction Education_Management Retail Financial Accounting Computer_Software Automotive Higher_Education

# our agents
mutable struct ComplexHuman
    migrant :: Bool
    # whether they are employed
    employed :: Bool
    industry :: Industry
    # which country are they from
    nationality :: Nationality
    # number of people in their "network"
    contacts :: Vector{ComplexHuman}
end

# Swedish immigrants, employed, working on cars, with no network
migrant = ComplexHuman(true, true, Automotive, Sweden, [])
# German natives, working in Hospital/Health Care
native = ComplexHuman(false, true, Hospital_HealthCare, Germany,[])

#TO DO -- ASK MARTIN
#write some function to assign randomly agents according to a distribution to different job sectors and different employment status.

# this should change to something like a dictionary in python
# not sure the best way to think about it in julia?
# job_market = {Automotive: 50, Accounting: 100, ...}
mutable struct JobMarket
    available_jobs :: Int
    industry :: Industry
end

# and the job market ????
# still a bit confused how these interact w/ each other

mutable struct Simulation{AGENT}
    # model parameters:
    # migration rate
    mr :: Float64
    # employment rate
    er :: Float64
    # and this is our population of agents
    pop :: Vector{AGENT}
end

# set up a mixed population
# p_contact is the probability that two agents are connected
function setup_mixed(n, p_contact)
    pop = [ Person() for i=1:n ] #Person = Migrant or native
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


#allow/code some random element that permits immigrant agents to be employed in different sectors than the ones in wihich the majority of network is currently employed
