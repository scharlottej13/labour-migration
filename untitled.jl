# At the start of the simulation, our we have some "stock" of immigrants in the destination country
# as time progresses, agents decide whether or not to move based on the job market,
# and the number of other immigrants they know in the destination country

# OR
# at the start, this is a world without migration
# people decide to migrate based on the job market (if their skills match the jobs available)
# then, once there are immigrants, others deciding whether to migrate
# can rely on the migrant network and/or job market
# maybe people go regardless of work, just because of the network
# or maybe people go *only* if there is a job
# or maybe you need both?

# used a list of EU countries
@enum Nationality Austria Italy Belgium Latvia Bulgaria Lithuania Croatia Luxembourg Cyprus Malta Czechia Netherlands Denmark Poland Estonia Portugal Finland Romania France Slovakia Germany Slovenia Greece Spain Hungary Sweden

# Industry of employment (took the top 10 from LinkedIn)
@enum Industry Information_Technology Hospital_HealthCare Construction Education_Management Retail Financial Accounting Computer_Software Automotive Higher_Education

# our agents
mutable struct ComplexHuman
    migrant :: Bool
    # whether they are employed
    employed :: Bool
    # TO DO need function that sets industry to NA if employed is false
    industry :: Industry
    # which country are they from
    nationality :: Nationality
    # number of people in their "network"
    contacts :: Vector{Person}
end

# the first people are Swedish immigrants, employed, working on cars, with no network
migrant = ComplexHuman(true, true, Automotive, Sweden, [])

# this should change to something like a dictionary in python
# not sure the best way to think about it in julia?
# job_market = {Automotive: 50, Accounting: 100, ...}
mutable struct JobMarket
    available_jobs :: Int
    industry :: Industry
end

# and the job market ????
# still a bit confused how these interact w/ each other
high_tech = JobMarket(100000, Computer_Software)

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
    pop = [ Person() for i=1:n ]
    # go through all combinations of agents and 
    # check if they are connected
    # TO DO this should be only people of the same nationality
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