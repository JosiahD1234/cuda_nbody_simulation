# CUDA N-Body Simulation
This project implements an N-body simulation in CUDA to demonstrate how this problem can be accelerated
with a GPU. A video demonstration can be generated to view the simulation, and a CPU version has been
implemented for comparison purposes.

## How to build

1. From the project root directory, run `make`
2. This creates the executable `build/nbody`
3. To clean build files, run `make clean`

## How to run

### Base command
```bash
./build/nbody
```

### Flags
- `--cpu` - Use the CPU implementation
- `--gpu` - Use the GPU implementation
- `--n [number]` - Number of bodies
- `--steps [number]` - Number of simulation steps
- `--random` - Use a random seed for starting positions
- `--visualize` - Create a simulation video
    - Videos are saved to `cpu_output.avi` or `gpu_output.avi`
    - This should **not** be used for benchmarking
- `--render-interval [number]` - Number of simulation steps between each output frame

### Example commands
```bash
./build/nbody --gpu --n 100 --steps 1000 --random
```
```bash
./build/nbody --cpu --n 100 --steps 1000 --visualize --render-interval 10
```

## Required packages / dependencies
- CUDA / NVCC
- C++17 compiler
- OpenCV
- Make

## Required hardware / software environment
This project requires an NVIDIA GPU to run. This project was developed and tested on NCSA Delta. If you are using this same environment, you may need to run `module load opencv`.

## Locations and methods
- The main **CUDA kernel** is located in src/nbody_gpu.cu
- **Benchmarking** is done by running the same commands but changing `--cpu` and `--gpu`
    - The program outputs simulation time for each run
    - `--visualize`, `--render-interval` and `--random` are not used during this
- The **demo** is generated in video format as `cpu_output.avi` and `gpu_output.avi`