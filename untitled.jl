# At the start of the simulation, we have some "stock" of immigrants in the destination country
# they have some characteristics (job sector, nationality, etc.).
# As time progresses, agents decide whether or not to migrate based on:
# - the job market
# - number of other immigrants they know in the destination country
# Possible emergent outcomes:
# - maybe people migrate regardless of the job, just because of the network
# - or maybe people migrate *only* if there is a job
# - or maybe you need both network & a job?

# macro strategy (next steps):
# get simple version to run as command line
# print as it goes
# once that works, then:
# do a simple viz (look at draw template)
# eg split 2D space into origin and destination and have stripes by migrant/employment

# note from Martin:
# easier way to do this is to ignore country names, just have x number of abstract countries
# same for industries (can have properties that differ, however, only important if in-simulation meaning)
# keep same for now, but think about this for future

# used a list of EU countries
@enum Nationality Austria Italy Belgium Latvia Bulgaria Lithuania Croatia Luxembourg Cyprus Malta Czechia Netherlands Denmark Poland Estonia Portugal Finland Romania France Slovakia Germany Slovenia Greece Spain Hungary Sweden
# Industry of employment (took the top 10 from LinkedIn)
@enum Industry Information_Technology Hospital_HealthCare Construction Education_Management Retail Financial Accounting Computer_Software Automotive Higher_Education

# need struct for country_dest, country_orig, and industry
# what attributes are needed to distinguish these
# then, write a setup function that generates number of countries & industries
# if we want to compare different destination countries, create a struct and then
# have industries within them
# modeling question-- what do we think differs between countries of origin

# our agents
mutable struct ComplexHuman
    migrant :: Bool # can replace this w/ a function that compares residence & nationality
    # whether they are employed
    employed :: Bool
    industry :: Industry
    # which country are they from
    nationality :: Nationality # can replace this with another struct that was created in setup f'n
    # number of people in their "network"
    contacts :: Vector{ComplexHuman}
end

# Swedish immigrants, employed, working on cars, with no network
migrant = ComplexHuman(true, true, Automotive, Sweden, [])
# German natives, working in Hospital/Health Care
native = ComplexHuman(false, true, Hospital_HealthCare, Germany,[])

#TO DO -- ASK MARTIN
#write some function to assign randomly agents according to a distribution to different job sectors and different employment status.
# two sources of randomness:
# setup
# what happens in simulation

## NOTES ON JOB MARKET
# countries, which have job markets, and within those job markets we have a number of jobs available per industry
# will need an engine that simulates change of open jobs over time
# it's a trap!
# maybe it's better to have a probability for someone to get a job under some conditions
# then you can avoid the problem of creating a job market simulation
# depends on the scale-- for a city, number of jobs makes a differnence, but for a country not how this really works
# implementation:
# update function that updates structure of job market
# mostly time-dependent, but also simluated people added (need to think about how important this is)
# very simple-- assume fixed probability, by industry/nationality
# people disappear from job market b/c after a certain time they'd all be able to get a job
# and can build complexity from there
# need employment rate per agent (same as infection rate), needs to be calculated based on some factors
# event would be finding a job/getting employed
# could also have an event of losing your job (easier to keep this rate constant at beginning)

# population1 - immigrants in destination country being hired/fired
# population2 - still in country of origin and events are a bit different
# migrating, finding a  job, etc.
# need to think about communication between prospective migrants & migrants
# information transfer:
# decide on fix rate of communication (like rate of infection)
# pick random contacts to start (of same nationality)


# this should change to something like a dictionary in python
# not sure the best way to think about it in julia?
# job_market = {Automotive: 50, Accounting: 100, ...}
mutable struct JobMarket
    available_jobs :: Int
    industry :: Industry
end

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
