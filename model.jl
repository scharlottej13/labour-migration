using Random
using Plots
using DataFrames
using CSV
using StatsPlots

mutable struct Industry
    # number of jobs available
    num_jobs :: Float64 #Int
    # job hire rate
    hirer :: Float64
    # rate of job loss
    firer :: Float64
end

# no jobs, no one is hired, no one loses their job
Industry() = Industry(0,0,0)

mutable struct Country
    name :: Int
    migration_rate :: Float64
    industries :: Vector{Industry}
end

Country() = Country(0, 0, [])

mutable struct ComplexHuman
    migrant :: Bool
    employed :: Bool
    industry :: Int
    origin :: Country
    residence :: Country
    contacts :: Vector{ComplexHuman}
end

ComplexHuman() = ComplexHuman(false, true, 1, Country(), Country(), [])
ComplexHuman(country) = ComplexHuman(false, true, 1, country, country, [])

mutable struct Simulation
    countries :: Vector{Country}
    # communication rate between agents
    commr :: Float64
    # and this is our population of agents
    pop :: Vector{ComplexHuman}
end

function update_migrant_status!(person, sim)
    # for simplicity, we are not considering return migration
    # you can only go from non-migrant to migrant status
    if person.migrant == true
        return
    else
        # check all of the non-migrants contacts
        for contact in person.contacts
            # if the contact is a migrant & employed & they communicate more than random
            # then the person can become a migrant
            if contact.migrant == true && contact.employed == true && rand() < sim.commr
                person.migrant == true
                # in a more complex version, could do this:
                # person.residence == contact.residence
                # for now, settle for random
                person.residence == rand(person.contacts).residence
            end
        end
    end
end


function update_migrant_employment!(person, sim)
    # for simplicity, only change employment status of migrants
    if person.migrant == false
        return
    else
        if person.employed == true
            # random, for simplicity, but could be empirically determined
            if rand() < industry.firer
                person.employed == false
        else
            for contact in person.contacts
                if contact.migrant == true && contact.employed == true
                    if rand() < industry.hirer
                        person.employed == true
                        # a person would be in the same industry as their contact
                        # person.industry = contact.industry
                        # but for simplicity:
                        person.industry == rand(person.contacts).industry
                    end
                end
            end
        end
    end
end
end


function update!(agent, sim)
    update_migrant_status!(agent, sim)
    update_migrant_employment!(agent, sim)
end


function update_migrants!(sim)
    # we need to change the order, otherwise agents at the beginning of the 
    # pop array will behave differently from those further in the back
    order = shuffle(sim.pop)
    for p in order
        update!(p, sim)
    end
end

# job acquisition rate
const HIRER = 0.8
# job loss rate
const FIRER = 0.06
# ^^ should these sum to 1?
# migration rate
const MIGR = 0.035

# to scale the rate *slightly* to improve stability
scale_rate(rate, SCALAR::Float64 = 0.2) = rate + rand() * SCALAR - rand() * SCALAR

function setup_industries!(n, num_jobs, country, HIRER, FIRER)
    country.industries = [ 
        Industry(floor(Int, rand() * num_jobs), scale_rate(HIRER), scale_rate(FIRER))
        for i=1:n ]
end

function setup_countries(n, num_industries, num_jobs, MIGR, HIRER, FIRER)
    countries = [ Country(i, scale_rate(MIGR), []) for i=1:n ]
    for country in countries
        setup_industries!(num_industries, num_jobs, country, HIRER, FIRER)
    end
    countries
end

# if we skip the `if rand() < p_contact` line,
# all connections will be in eachother connections list 
# we could try to make a country-level probability contact
# but it should be placed into the country struct then in the setup_coutry f'n
# like `p_contact = rand()` and then loop somehow through it
# would loop through the people and see if they are connected
function setup_pop(n, countries, num_industries)
    pop = [ ComplexHuman() for i=1:n ]
    industries = [ i for i=1:num_industries ]

    for i in eachindex(pop)
        for j in i+1:length(pop)
            if pop[i].origin == pop[j].origin
                push!(pop[i].contacts, pop[j])
                push!(pop[j].contacts, pop[i])
            end
        end
        for i in eachindex(pop)
            pop[i].residence = rand(countries) #there is a much easier way to accomplish what you want to do, by picking directly from the list of countries instead of first picking a random index
            pop[i].industry = rand(industries)
        end
    end
    pop
end


function  setup_sim(;commr, N, num_jobs, num_industries, num_countries, seed)
    println("Starting simulation with ", N, " people.")
    println("There are ", num_countries, " countries")
    println(num_industries, " industries and ", num_jobs, " jobs.")

    # for reproducibility
    Random.seed!(seed)
    
    # create our countries
    # within each country a number of industries are created
    countries = setup_countries(num_countries, num_industries, num_jobs, MIGR, HIRER, FIRER)
    @assert countries != nothing
    
    # create a population of agents
    pop = setup_pop(N, countries, num_industries)

    # create a simulation object with parameter values
    sim = Simulation(countries, commr, pop)

end


function run_sim(sim, n_steps, verbose = false)
    # we keep track of the numbers
    output = DataFrame(status = [], country = [], employed = [], industry=[])
    # simulation steps
    for t in 1:n_steps
        update_migrants!(sim)
        for p in sim.pop
            push!(output, (p.migrant, p.residence, p.employed, p.industry))
            # a bit of output
            if verbose
                println(output)
            end
        end
    end
    output
end


sim = setup_sim(commr=0.2, N=1000, num_jobs=800, num_industries=10, num_countries=5, seed=42)
output = run_sim(sim, 10)
CSV.write("C:/Users/panze/Desktop/output.csv", output)
# CSV.write("/Users/scharlottej13/Desktop/output.csv", output)
# Plots.plot([migrants, non_migrants], labels = ["Migrants" "Non-Migrants"])
