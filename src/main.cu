#include <iostream>
#include <chrono>

#include <cuda_runtime.h>

#include "nbody.h"
#include "utils.h"
#include "renderer.h"

int main(int argc, char** argv) {
    ProgramOptions opts = parse_args(argc, argv);

    const char *mode_label = opts.use_gpu ? "GPU" : "CPU";
    const char *output_file = opts.use_gpu ? "gpu_output.avi" : "cpu_output.avi";

    NBodyState host{};
    NBodyState device{};
    SimParams params{};

    params.dt = 0.001f;
    params.G = 1.0f;
    params.softening = 0.01f;
    params.steps = opts.steps;

    const int width = 800;
    const int height = 800;

    allocate_host_state(host, opts.n);
    initialize_particles(host, 0.5f);

    std::cout << "Mode: " << (opts.use_gpu ? "GPU" : "CPU") << "\n";
    std::cout << "Particles: " << opts.n << "\n";
    std::cout << "Steps: " << opts.steps << "\n";
    std::cout << "Visualization: " << (opts.visualize ? "on" : "off") << "\n";
    if (opts.visualize) {
        std::cout << "Output video: " << output_file << "\n";
    }

    auto cpu_start = std::chrono::high_resolution_clock::now();

    if (opts.use_gpu) {
        allocate_device_state(device, opts.n);
        copy_host_to_device(host, device);

        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        cudaEventRecord(start);

        for (int step = 0; step < params.steps; step++) {
            gpu_step(device, params);

            if (opts.visualize && step % opts.render_interval == 0) {
                copy_positions_to_host(device, host);
                render_particles(host, width, height, step, output_file, mode_label);
            }
        }

        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float gpu_ms = 0.0f;
        cudaEventElapsedTime(&gpu_ms, start, stop);

        copy_device_to_host(device, host);

        cudaEventDestroy(start);
        cudaEventDestroy(stop);
        free_device_state(device);

        std::cout << "GPU simulation time: " << gpu_ms << " ms\n";
        std::cout << "GPU simulation time: " << gpu_ms / 1000.0f << " seconds\n";
    } else {
        auto start = std::chrono::high_resolution_clock::now();

        for (int step = 0; step < params.steps; step++) {
            cpu_step(host, params);

            if (opts.visualize && step % opts.render_interval == 0) {
                render_particles(host, width, height, step, output_file, mode_label);
            }
        }

        auto stop = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double, std::milli> elapsed = stop - start;

        std::cout << "CPU simulation time: " << elapsed.count() << " ms\n";
        std::cout << "CPU simulation time: " << elapsed.count() / 1000.0 << " seconds\n";
    }

    auto cpu_stop = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> total_elapsed = cpu_stop - cpu_start;

    std::cout << "End-to-end program time: " << total_elapsed.count() << " ms\n";

    std::cout << "\nFinal sample:\n";
    print_state_sample(host, 5);

    close_renderer();
    free_host_state(host);

    return 0;
}