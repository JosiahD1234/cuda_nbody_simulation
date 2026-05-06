#include "renderer.h"

#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

static cv::VideoWriter g_writer;
static bool g_initialized = false;
static std::string g_current_file;

bool render_particles(
    const NBodyState& s,
    int width,
    int height,
    int step,
    const char* output_file,
    const char* mode_label
)
{
    cv::Mat frame(height, width, CV_8UC3, cv::Scalar(0, 0, 0));

    float world_radius = 5.0f;

    for (int i = 0; i < s.n; i++)
    {
        int px = static_cast<int>(((s.x[i] + world_radius) / (2.0f * world_radius)) * width);
        int py = static_cast<int>(((s.y[i] + world_radius) / (2.0f * world_radius)) * height);

        py = height - py;

        if (px >= 0 && px < width && py >= 0 && py < height)
        {
            cv::circle(frame, cv::Point(px, py), 2, cv::Scalar(255, 255, 255), -1);
        }
    }

    std::string label = std::string("Mode: ") + mode_label +
                        "   Step: " + std::to_string(step) +
                        "   Particles: " + std::to_string(s.n);

    cv::putText(frame,
                label,
                cv::Point(20, 30),
                cv::FONT_HERSHEY_SIMPLEX,
                0.6,
                cv::Scalar(0, 255, 0),
                2);

    if (!g_initialized)
    {
        g_current_file = output_file;

        bool ok = g_writer.open(
            output_file,
            cv::VideoWriter::fourcc('M', 'J', 'P', 'G'),
            30,
            cv::Size(width, height)
        );

        if (!ok)
        {
            std::cerr << "Error: could not open " << output_file << " for writing.\n";
            return false;
        }

        g_initialized = true;
    }

    g_writer.write(frame);
    return true;
}

void close_renderer()
{
    if (g_initialized)
    {
        g_writer.release();
        g_initialized = false;
        g_current_file.clear();
    }
}