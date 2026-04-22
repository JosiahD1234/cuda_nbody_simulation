#pragma once

#include "nbody.h"

bool render_particles(const NBodyState& s, int width, int height, int step);
void close_renderer();