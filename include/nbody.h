#pragma once

struct NBodyState {
    int n;
    float* x;
    float* y;
    float* vx;
    float* vy;
    float* mass;
};

struct SimParams {
    float dt;
    float G;
    float softening;
    int steps;
};

void allocate_host_state(NBodyState& s, int n);
void free_host_state(NBodyState& s);
void initialize_particles(NBodyState& s, float world_size);

void cpu_step(NBodyState& s, const SimParams& p);