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
    migration_rate :: Float64
    industries :: Vector{Industry}
end

# no one migrates, no industries
Country() = Country(0,[])

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
    countries = [ Country(scale_rate(MIGR), []) for i=1:n ]
    for country in countries
        setup_industries!(num_industries, num_jobs, country, HIRER, FIRER)
    end
    countries
end

# trying to debug, there's something wront w/ setup_countries I think
setup_countries(5, 10, 50, MIGR, HIRER, FIRER)

# if we skip the `if rand() < p_contact` line,
# all connections will be in eachother connections list 
# we could try to make a country-level probability contact
# but it should be placed into the country struct then in the setup_coutry f'n
# like `p_contact = rand()` and then loop somehow through it
# would loop through the people and see if they are connected
function setup_pop(n, num_countries)
    pop = [ ComplexHuman() for i=1:n ]
    for i in eachindex(pop)
        for j in i+1:length(pop)
            if pop[i].origin == pop[j].origin
                push!(pop[i].contacts, pop[j])
                push!(pop[j].contacts, pop[i])
            end
        end
        for i in eachindex(pop)
        pop[i].residence == rand(num_countries)
        end
    end
    pop
end
setup_pop()= setup_pop(0,0) #no one exists, no countries. Basically Pangaea.
setup_pop(N) = setup_pop(0,0)

function  setup_sim(;commr, N, num_jobs, num_industries, num_countries, seed)
    # for reproducibility
    Random.seed!(seed)

    # create a population of agents
    pop = setup_pop(N)
    
    # create our countries
    # within each country a number of industries are created
    countries = setup_countries(num_countries, num_industries, num_jobs, MIGR, HIRER, FIRER)
    @assert countries != nothing
    
    # create a population of agents
    pop = setup_pop(N, countries) #should we change setup_pop coherently to work with countires..right?
#     pop = pop_to_countries(pop, countries)

    # create a simulation object with parameter values
    sim = Simulation(countries, commr, pop)

end

output = DataFrame(status = [], country = [],employed = [], industry=[])

function run_sim(sim, n_steps, verbose = true)
    # we keep track of the numbers
#     n_non_migrants = Int[]
#     n_migrants = Int[]
    # add dataframe for unemployed, employed, industry, etc.
    # could use an array of arrays, depends on what we want to plot
    # for the google
    # could also produce data files as outputs
    # arg = open(file_name, 'w')
    # println(arg, stuff-to-write)
    # within notebook, open file.jl
    # use f'n include(), which reads julia code and executes
    # run f'n w/ a couple args, get the data
    # use notebook for displaying results

    # simulation steps
    for t in 1:n_steps
        update_migrants!(sim)
#         push!(n_migrants, count(p -> p.migrant == true, sim.pop))
#         push!(n_non_migrants, count(p -> p.migrant == false, sim.pop))
        for p in pop
            push!(output, (pop[p].migrant, pop[p].residence,pop[p].employed, pop[p].industry))
        # a bit of output
        if verbose
            println(t, ", ", n_migrants[end], ", ", n_non_migrants[end])
            end
        end
    end
       
    # return the results (normalized by pop size)
    n = length(sim.pop)
    n_migrants./n, n_non_migrants./n
end

# setup_sim(;commr, N, num_jobs, num_industries, num_countries, seed)
# setup_pop(n, num_countries)


sim = setup_sim(commr=0.2, N=1000, num_jobs=800, num_industries=10, num_countries=5, seed=42)
migrants, non_migrants = run_sim(sim, 500)
CSV.write("C:/Users/panze/Desktop/output.csv", output)
# Plots.plot([migrants, non_migrants], labels = ["Migrants" "Non-Migrants"])
