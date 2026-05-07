#pragma once

#include "nbody.h"

void print_state_sample(const NBodyState& s, int count);

struct ProgramOptions {
    int n = 1000;
    int steps = 1000;
    bool use_gpu = true;
    bool visualize = false;
    int render_interval = 10;
    bool use_random = false;
};

ProgramOptions parse_args(int argc, char** argv);