# Cuda N-Body Simulation

## How to build

1. From the project root directory, run
    `make`
2. This creates the executible
    `build/nbody`
3. To clean build files, run
    `make clean`

## How to run

### Base command
`./build/nbody`

### Flags
- `--cpu` - Use the CPU implementation
- `--gpu` - Use the GPU implementation
- `--n [number]` - Number of bodies
- `--steps [number]` - Number of simulation steps
- `--random` - Use a random seed for starting positions
- `--visualize` - Create a simulation video
- `--render-interval` - Number of simulation steps between each output frame

## Required packages / dependencies