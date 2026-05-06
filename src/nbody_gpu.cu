#include "nbody.h"

#include <cuda_runtime.h>
#include <iostream>
#include <cstdlib>

#define CUDA_CHECK(call)                                                   \
    do {                                                                   \
        cudaError_t err = call;                                            \
        if (err != cudaSuccess) {                                          \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__   \
                      << " - " << cudaGetErrorString(err) << std::endl;    \
            std::exit(EXIT_FAILURE);                                       \
        }                                                                  \
    } while (0)

void allocate_device_state(NBodyState& d, int n) {
    d.n = n;
    CUDA_CHECK(cudaMalloc(&d.x, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d.y, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d.vx, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d.vy, n * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d.mass, n * sizeof(float)));
}

void free_device_state(NBodyState& d) {
    CUDA_CHECK(cudaFree(d.x));
    CUDA_CHECK(cudaFree(d.y));
    CUDA_CHECK(cudaFree(d.vx));
    CUDA_CHECK(cudaFree(d.vy));
    CUDA_CHECK(cudaFree(d.mass));

    d.x = nullptr;
    d.y = nullptr;
    d.vx = nullptr;
    d.vy = nullptr;
    d.mass = nullptr;
    d.n = 0;
}

void copy_host_to_device(const NBodyState& h, NBodyState& d) {
    CUDA_CHECK(cudaMemcpy(d.x, h.x, h.n * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d.y, h.y, h.n * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d.vx, h.vx, h.n * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d.vy, h.vy, h.n * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d.mass, h.mass, h.n * sizeof(float), cudaMemcpyHostToDevice));
}

void copy_device_to_host(const NBodyState& d, NBodyState& h) {
    CUDA_CHECK(cudaMemcpy(h.x, d.x, d.n * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h.y, d.y, d.n * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h.vx, d.vx, d.n * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h.vy, d.vy, d.n * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h.mass, d.mass, d.n * sizeof(float), cudaMemcpyDeviceToHost));
}

void copy_positions_to_host(const NBodyState& d, NBodyState& h) {
    CUDA_CHECK(cudaMemcpy(h.x, d.x, d.n * sizeof(float), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h.y, d.y, d.n * sizeof(float), cudaMemcpyDeviceToHost));
}

__global__ void nbody_tiled_kernel(
    int n,
    float* x,
    float* y,
    float* vx,
    float* vy,
    const float* mass,
    float dt,
    float G,
    float softening)
{
    extern __shared__ float shared[];

    float* sh_x = shared;
    float* sh_y = &shared[blockDim.x];
    float* sh_m = &shared[2 * blockDim.x];

    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i >= n) {
        return;
    }

    float xi = x[i];
    float yi = y[i];

    float ax = 0.0f;
    float ay = 0.0f;

    for (int tile = 0; tile < n; tile += blockDim.x) {
        int j = tile + threadIdx.x;

        if (j < n) {
            sh_x[threadIdx.x] = x[j];
            sh_y[threadIdx.x] = y[j];
            sh_m[threadIdx.x] = mass[j];
        } else {
            sh_x[threadIdx.x] = 0.0f;
            sh_y[threadIdx.x] = 0.0f;
            sh_m[threadIdx.x] = 0.0f;
        }

        __syncthreads();

        int tile_size = min(blockDim.x, n - tile);

        for (int k = 0; k < tile_size; k++) {
            int j_global = tile + k;

            if (j_global == i) {
                continue;
            }

            float dx = sh_x[k] - xi;
            float dy = sh_y[k] - yi;

            float dist2 = dx * dx + dy * dy + softening;
            float invDist = rsqrtf(dist2);
            float invDist3 = invDist * invDist * invDist;

            float scale = G * sh_m[k] * invDist3;

            ax += dx * scale;
            ay += dy * scale;
        }

        __syncthreads();
    }

    vx[i] += ax * dt;
    vy[i] += ay * dt;

    x[i] += vx[i] * dt;
    y[i] += vy[i] * dt;
}

void gpu_step(NBodyState& d, const SimParams& p) {
    int threads = 256;
    int blocks = (d.n + threads - 1) / threads;

    size_t shared_bytes = 3 * threads * sizeof(float);

    nbody_tiled_kernel<<<blocks, threads, shared_bytes>>>(
        d.n,
        d.x,
        d.y,
        d.vx,
        d.vy,
        d.mass,
        p.dt,
        p.G,
        p.softening
    );

    CUDA_CHECK(cudaGetLastError());
}