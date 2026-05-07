# CUDA N-Body Simulation

## How to build

1. From the project root directory, run:
    ```bash
    make
2. This creates the executable
    ```bash
    build/nbody
3. To clean build files, run
    ```bash
    make clean

## How to run

### Base command

    ```bash
    ./build/nbody

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

## Required packages / dependencies
- CUDA / NVCC
- C++17 compiler
- OpenCV
- Make

## Required hardware / software environment
This project requires an NVIDIA GPU to run. This project was developed and tested on NCSA Delta. If you are using this same environment, you may need to run `module load opencv`.