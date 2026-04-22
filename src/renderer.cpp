#include "renderer.h"

#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

static cv::VideoWriter g_writer;
static bool g_initialized = false;

bool render_particles(const NBodyState& s, int width, int height, int step)
{
    cv::Mat frame(height, width, CV_8UC3, cv::Scalar(0, 0, 0));

    for (int i = 0; i < s.n; i++)
    {
        int px = static_cast<int>((s.x[i] + 1.0f) * 0.5f * width);
        int py = static_cast<int>((s.y[i] + 1.0f) * 0.5f * height);

        py = height - py;

        if (px >= 0 && px < width && py >= 0 && py < height)
        {
            cv::circle(frame, cv::Point(px, py), 2, cv::Scalar(255, 255, 255), -1);
        }
    }

    std::string label = "Step: " + std::to_string(step) +
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
        const std::string filename = "output.avi";
        int fourcc = cv::VideoWriter::fourcc('M', 'J', 'P', 'G');

        bool ok = g_writer.open(filename, fourcc, 30, cv::Size(width, height));

        if (!ok)
        {
            std::cerr << "Error: could not open " << filename << " for writing.\n";
            std::cerr << "Try checking codec support or write permissions.\n";
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
    }
}