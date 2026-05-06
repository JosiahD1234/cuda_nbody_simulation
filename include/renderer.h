#pragma once

#include "nbody.h"

bool render_particles(
    const NBodyState& s,
    int width,
    int height,
    int step,
    const char* output_file,
    const char* mode_label
);

void close_renderer();