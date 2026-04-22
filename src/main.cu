#include <iostream>
#include "nbody.h"
#include "utils.h"
#include "renderer.h"

int main() {
    NBodyState state{};
    SimParams params{};

    int n = 100;
    params.dt = 0.001f;
    params.G = 1.0f;
    params.softening = 0.01f;
    params.steps = 5000;

    const int width = 800;
    const int height = 800;
    const bool visualize = true;
    const int render_interval = 10;

    allocate_host_state(state, n);
    initialize_particles(state, 1.0f);

    std::cout << "Initial state:\n";
    print_state_sample(state, 5);

    for (int step = 0; step < params.steps; step++) {
        cpu_step(state, params);

        if (visualize && step % render_interval == 0) {
            if (!render_particles(state, width, height, step)) {
                break;
            }
        }
    }

    std::cout << "\nFinal state:\n";
    print_state_sample(state, 5);

    close_renderer();
    free_host_state(state);
    return 0;
}