NVCC := nvcc
CXX := g++

TARGET := build/nbody

INCLUDES := -Iinclude
CXXFLAGS := -O2 -std=c++17 $(INCLUDES)
NVCCFLAGS := -O2 -std=c++17 $(INCLUDES)

OPENCV_HOME := /sw/rh9.4/external/opencv/opencv-4.13.0
OPENCV_INC := -I$(OPENCV_HOME)/include/opencv4
OPENCV_LIBDIR := -L$(OPENCV_HOME)/lib64

# Since you are writing video frames and drawing images/text,
# these are the main OpenCV libraries you need.
OPENCV_LIBS := $(OPENCV_LIBDIR) -lopencv_core -lopencv_imgproc -lopencv_videoio

SRC_CPP := src/nbody_cpu.cpp src/renderer.cpp src/utils.cpp
SRC_CU  := src/main.cu src/nbody_gpu.cu

OBJ_CPP := build/nbody_cpu.o build/renderer.o build/utils.o
OBJ_CU  := build/main.o build/nbody_gpu.o
OBJS := $(OBJ_CPP) $(OBJ_CU)

all: $(TARGET)

build:
	mkdir -p build

build/%.o: src/%.cpp | build
	$(CXX) $(CXXFLAGS) $(OPENCV_INC) -c $< -o $@

build/%.o: src/%.cu | build
	$(NVCC) $(NVCCFLAGS) $(OPENCV_INC) -c $< -o $@

$(TARGET): $(OBJS) | build
	$(NVCC) $(NVCCFLAGS) -o $@ $(OBJS) $(OPENCV_LIBS)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf build/*.o $(TARGET)

distclean:
	rm -rf build

.PHONY: all run clean distclean