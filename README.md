# ExploreInfotonOpt

An environment for Infoton Optimization research.

To reproduce the CITDS 2020 paper, check oput the [CITDSv1](https://github.com/Circo-dev/ExploreInfotonOpt/tree/CITDSv1) tag

#### Prerequisites

- Julia 1.4 or higher for the actor system and infoton optimization
- Node.js 12.6 or higher for visualization.

#### Install
To (locally) reproduce this project, do the following:

0. Create a project directory where you will check out two repos. There:
1. `git clone https://github.com/Circo-dev/ExploreInfotonOpt`
2. `cd ExploreInfotonOpt`
3. `julia --project -e 'using Pkg; Pkg.instantiate()'`
4. `cd ..`
5. `git clone https://github.com/Circo-dev/Circo.js`
6. `cd Circo.js`
7. `npm install`

#### Run simulations

From your `project_dir/ExploreInfotonOpt`
   ```
   $ julia --project

   julia> include("scripts/sim.jl")
   ```
You will get back the prompt in the REPL where you can ask for stats, plot graph, etc. (Logs will be written to the screen, press Enter if you do not see the prompt.).

#### Start the Camera Diserta monitoring tool

In another terminal, from your `project_dir/Circo.js`
   ```
   $ npm run serve
   ```


Check `scripts/` and `src/` for details.

You will also need to read the [Circo docs](https://circo-dev.github.io/Circo-docs/dev/).
