#include <cmath>
#include "nbody.h"

void cpu_step(NBodyState& s, const SimParams& p) {
    int n = s.n;

    float* ax = new float[n];
    float* ay = new float[n];

    for (int i = 0; i < n; i++) {
        float fx = 0.0f;
        float fy = 0.0f;

        for (int j = 0; j < n; j++) {
            if (i == j) {
                continue;
            }

            float dx = s.x[j] - s.x[i];
            float dy = s.y[j] - s.y[i];

            float dist2 = dx * dx + dy * dy + p.softening;
            float invDist = 1.0f / std::sqrt(dist2);
            float invDist3 = invDist * invDist * invDist;

            float scale = p.G * s.mass[j] * invDist3;
            fx += dx * scale;
            fy += dy * scale;
        }

        ax[i] = fx;
        ay[i] = fy;
    }

    for (int i = 0; i < n; i++) {
        s.vx[i] += ax[i] * p.dt;
        s.vy[i] += ay[i] * p.dt;

        s.x[i] += s.vx[i] * p.dt;
        s.y[i] += s.vy[i] * p.dt;
    }

    delete[] ax;
    delete[] ay;
}