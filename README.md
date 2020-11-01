# ExploreInfotonOpt

This code base is using the Julia Language and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> ExploreInfotonOpt

#### Install
To (locally) reproduce this project, do the following:

0. Create a project directory where you will check out multiple repos. There:
1. `git clone https://github.com/Circo-dev/CircoCore.jl`
1. `cd CircoCore.jl`
1. `julia --project -e 'using Pkg; Pkg.instantiate()'`
1. `cd ..`
1. `git clone https://github.com/Circo-dev/Circo`
1. `cd Circo`
1. `julia --project -e 'using Pkg; Pkg.add(path="../CircoCore.jl"); Pkg.instantiate()'`
1. `cd ..`
1. `git clone https://github.com/Circo-dev/Circo.js`
1. `cd Circo.js`
1. `npm install`
1. `cd ..`
1. `git clone https://github.com/Circo-dev/ExploreInfotonOpt`
1. `cd ExploreInfotonOpt`
1. `julia --project -e 'using Pkg; Pkg.instantiate()'`

#### Run simulations

From your `project_dir/ExploreInfotonOpt`
   ```
   $ julia --project

   julia> include("scripts/treesim.jl")
   ```
You will get back the prompt in the REPL where you can ask for stats, plot graph, etc. (Logs will be written to the screen, press Enter if you do not see the prompt.).

#### Start the Camera Diserta monitoring tool

In another terminal, from your `project_dir/Circo.js`
   ```
   $ npm run serve
   ```


Check `scripts/` and `src/` for details.

You will also need to read the [Circo docs](https://circo-dev.github.io/Circo-docs/dev/).