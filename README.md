# Analog Clock Reader

**Automatic Analog Clock Reading Using Classical Computer Vision in MATLAB**

A computer vision pipeline designed to automatically detect, analyze, and read analog clocks from images. The system combines frequency-domain filtering, color segmentation, Hough transforms, and geometric reasoning to estimate clock-hand positions, extract timestamps, and validate the chronological consistency of multiple clock readings.

The project was developed as part of the *Basic Image Processing Algorithms* course in the Erasmus Mundus Master's Programme in Artificial Intelligence for Image Processing and Computer Vision (IPCVAI).

## Project Overview

Reading analog clocks from images presents several image-processing challenges, including image degradation, varying illumination, clock localization, hand detection, and geometric interpretation.

This project addresses these challenges through a modular pipeline built using classical image processing techniques rather than deep learning.

The main objectives are:

- Detect and localize analog clocks in input images.
- Reduce image degradation and enhance relevant visual features.
- Identify clock hands and estimate their angular positions.
- Convert hand orientations into time readings.
- Evaluate temporal consistency across a sequence of images.
- Arrange the extracted timestamps in chronological order.

## Visual Demonstration

The figure below illustrates the complete image processing pipeline, from an image degraded by periodic noise to automatic clock-hand detection and time estimation.

<img width="1517" height="922" alt="SampleOutput" src="https://github.com/user-attachments/assets/978bbc53-5f4c-48cc-8b4b-e2d4fa454e05" />

The pipeline includes frequency-domain noise removal, image enhancement, HSV-based color segmentation, Hough transform analysis, and geometric reconstruction of the clock hands. The final visualization displays the estimated time and the clock's consistency classification.

## Methodology

The processing pipeline consists of several stages.

### 1. Image Preprocessing

Input images are processed to reduce noise and improve the visibility of clock components.

Techniques include:

- Fourier-domain analysis and filtering of periodic noise.
- Contrast enhancement.
- Image normalization and preprocessing for subsequent detection stages.

### 2. Clock Localization

A circular Hough transform is used to identify the clock face.

Detecting the circular boundary provides a geometric reference for subsequent operations, including determining the clock center and analyzing hand orientations.

### 3. Color Segmentation

HSV color-space segmentation isolates relevant clock components.

Separating hue, saturation, and brightness enables more effective identification of specific visual features than relying exclusively on RGB intensities.

### 4. Clock-Hand Detection

A line-based Hough transform and geometric analysis are used to identify clock-hand candidates.

The detected line orientations are analyzed relative to the clock center to distinguish relevant hands and estimate their angular positions.

### 5. Time Estimation

The detected hand orientations are converted into time values using the geometric relationship between angular position and clock time.

The interpretation accounts for the circular nature of the clock and the different rotational speeds of its hands.

### 6. Temporal Consistency Analysis

After extracting timestamps from the input images, the system evaluates their temporal consistency and arranges the readings chronologically.

This stage provides an additional validation mechanism for the estimated times.

## Technologies and Algorithms

**Language:** MATLAB

**Core techniques:**

- Discrete Fourier Transform (DFT)
- Frequency-domain filtering
- Contrast enhancement
- HSV color segmentation
- Circular Hough Transform
- Linear Hough Transform
- Geometric feature analysis
- Angular estimation
- Temporal consistency validation

## Project Structure

The implementation is organized around a main MATLAB script and a dedicated clock-reading function.

```text
Analog-Clock-Reader/
├── a01_H48IOP.m
├── read_clock.m
├── functions/
│   └── Additional processing functions
├── input/
│   └── Clock images
└── README.md
```

## Usage

1. Clone or download the repository.
2. Open the project directory in MATLAB.
3. Place the input clock images inside the `input/` directory.
4. Run the main script:

```matlab
run('a01_H48IOP.m')
```

The program processes the input images, estimates their corresponding times, performs consistency checks, and reports the results.

## Results

The pipeline produces estimated timestamps for the clock images, along with consistency indicators and chronological ordering.

An example of the output format is:

```text
Image       Estimated Time    Consistent
01.png      01:53:36          Yes
02.png      02:31:27          Yes
03.png      02:18:11          Yes
04.png      02:41:19          No
```

These are example readings from the development dataset, not a quantitative accuracy benchmark.

## Challenges and Limitations

The project illustrates several important challenges in classical computer vision:

- Detecting clock hands in degraded or noisy images.
- Distinguishing overlapping or closely aligned hands.
- Resolving angular ambiguities.
- Maintaining reliable time estimates under varying image conditions.
- Balancing noise suppression with preservation of geometric features.

The pipeline is designed around the visual and geometric properties of analog clocks. Its performance may depend on image quality, clock appearance, and the reliability of individual detection stages.

## Learning Outcomes

This project provided practical experience in combining fundamental image processing algorithms into an integrated computer vision system.

Particular emphasis was placed on frequency-domain processing, feature detection, geometric reasoning, and the interpretation of visual information through mathematical models.



