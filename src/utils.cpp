#include <cstdlib>
#include <ctime>
#include <iostream>
#include <string>
#include "nbody.h"
#include "utils.h"

void allocate_host_state(NBodyState& s, int n) {
    s.n = n;
    s.x = new float[n];
    s.y = new float[n];
    s.vx = new float[n];
    s.vy = new float[n];
    s.mass = new float[n];
}

void free_host_state(NBodyState& s) {
    delete[] s.x;
    delete[] s.y;
    delete[] s.vx;
    delete[] s.vy;
    delete[] s.mass;

    s.x = nullptr;
    s.y = nullptr;
    s.vx = nullptr;
    s.vy = nullptr;
    s.mass = nullptr;
    s.n = 0;
}

static float rand_float(float a, float b) {
    return a + (b - a) * (static_cast<float>(std::rand()) / static_cast<float>(RAND_MAX));
}

void initialize_particles(NBodyState& s, float world_size) {
    std::srand(static_cast<unsigned>(std::time(nullptr)));

    for (int i = 0; i < s.n; i++) {
        s.x[i] = rand_float(-world_size, world_size);
        s.y[i] = rand_float(-world_size, world_size);

        s.vx[i] = rand_float(-0.005f, 0.005f);
        s.vy[i] = rand_float(-0.005f, 0.005f);

        s.mass[i] = rand_float(0.5f, 2.0f);
    }
}

void print_state_sample(const NBodyState& s, int count) {
    int limit = (count < s.n) ? count : s.n;

    for (int i = 0; i < limit; i++) {
        std::cout
            << "Particle " << i
            << "  pos=(" << s.x[i] << ", " << s.y[i] << ")"
            << "  vel=(" << s.vx[i] << ", " << s.vy[i] << ")"
            << "  mass=" << s.mass[i]
            << '\n';
    }
}

ProgramOptions parse_args(int argc, char** argv) {
    ProgramOptions opts;

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];

        if (arg == "--cpu") {
            opts.use_gpu = false;
        } else if (arg == "--gpu") {
            opts.use_gpu = true;
        } else if (arg == "--visualize") {
            opts.visualize = true;
        } else if (arg == "--n" && i + 1 < argc) {
            opts.n = std::stoi(argv[++i]);
        } else if (arg == "--steps" && i + 1 < argc) {
            opts.steps = std::stoi(argv[++i]);
        } else if (arg == "--render-interval" && i + 1 < argc) {
            opts.render_interval = std::stoi(argv[++i]);
        }
    }

    return opts;
}