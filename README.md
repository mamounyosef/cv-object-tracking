# Object Tracking System using MATLAB GUI

## Overview
The Object Tracking System is a MATLAB-based graphical application for computer
vision tasks. It provides an interactive GUI (`uifigure`) that lets the user
load a video, apply preprocessing, and run classical object-tracking algorithms
frame by frame.

The project was developed as a Computer Vision coursework group project and
extends a previously implemented image-processing GUI (Task 3) by adding an
"Object Tracking" category on top of its existing operations.

## Features
- Interactive MATLAB GUI (`uifigure`) with a scrollable control panel
- Video loading and frame-by-frame playback (Play / Pause / Step / Stop)
- Video position scrubber, time counter, and live FPS readout
- Two classical tracking operations (see below)
- Adjustable algorithm parameters via sliders, with a Reset-to-defaults button
- Preprocessing pipeline applied to every frame before tracking
- Save the current rendered frame to a PNG
- Modular code structure (tracking algorithms live in `trackers/`)

## Tracking Operations
The "Object Tracking" category provides two operations, selectable from the
Operation dropdown:

### 1. Scene Motion (LK)
Whole-frame dense optical flow — no ROI selection needed.
- Uses MATLAB's `opticalFlowLK` + `estimateFlow` (dense Lucas–Kanade) to compute
  a flow vector at every pixel.
- Pixels whose flow magnitude exceeds a threshold are marked as "moving".
- Moving pixels are grouped into objects via connected-component analysis
  (`bwareaopen` + optional dilation merge + `regionprops`), and each group gets a
  bounding box. This naturally supports **multiple moving objects** at once.
- The middle view shows the optical-flow quiver overlay (`plot(flow, ...)`),
  exactly as in the MATLAB documentation.
- Tunable sliders: LK Noise Threshold, Motion Threshold, Min Blob Area,
  Blob Merge Radius.

### 2. Mean-Shift
Single-object color-histogram tracking.
- The user draws an ROI around the target on the first frame.
- A Hue histogram of the ROI is built, then back-projected onto each new frame.
- Mean-shift iteration slides the box toward the densest region of matching color.
- The middle view shows the color back-projection; the main view shows the
  tracked bounding box.

## Preprocessing (applied to every frame)
Force Grayscale, Histogram Equalization, Box Filter, Gaussian Filter,
Sobel (H/V), and Gaussian Pyramid Reduce (downsampling). These can be toggled
live and affect both tracking operations.

## Technologies Used
- MATLAB
- Computer Vision Toolbox (`opticalFlowLK`, `estimateFlow`, `VideoReader`, ...)
- Image Processing Toolbox (`regionprops`, `bwareaopen`, `imdilate`,
  `rgb2hsv`, `impyramid`, ...)
- MATLAB App UI components (`uifigure`, `uipanel`, `uislider`, ...)

## Project Structure
```
cv-object-tracking/
├── tracking_app.m          # Main GUI + playback loop + all callbacks
├── trackers/
│   ├── sceneFlow.m         # Scene Motion (dense LK + clustering)
│   ├── meanShift.m         # Mean-shift color-histogram tracker
│   ├── trackerDummy.m      # Stub tracker (development placeholder)
│   └── TRACKER_CONTRACT.md # Interface contract for tracker modules
├── ui/
│   ├── videoSlider.m       # Video position slider logic (update / seek)
│   ├── saveButton.m        # Save-current-frame logic
│   └── computeFPS.m        # FPS string helper
├── test_videos/            # Sample videos (visiontraffic, singleball, ...)
├── cv_final_project_plan.md
├── README.md
└── LICENSE
```

## System Requirements
- MATLAB R2023a or later
- Computer Vision Toolbox
- Image Processing Toolbox

## How to Run
1. Open MATLAB and navigate to the project directory.
2. Run `tracking_app.m` (the app adds `trackers/` and `ui/` to the path
   automatically).
3. In the GUI:
   - Set Category to **Object Tracking**.
   - Choose an Operation: **Scene Motion (LK)** or **Mean-Shift**.
   - Click **Load Video** and pick a clip (e.g. from `test_videos/`).
   - For Mean-Shift, click **Select Object ROI** and drag a box around the target.
   - Press **Play** (or **Step**). Adjust the sliders as needed.

## GUI Workflow
1. Select Object Tracking → choose an operation.
2. Load a video.
3. (Mean-Shift only) Select the target ROI.
4. Play / Step through the video and watch the tracking output.
5. Optionally tune sliders, toggle preprocessing, or Save Frame.

## Example Applications
- Vehicle and pedestrian motion tracking
- Single colored-object tracking
- Educational computer-vision demonstrations of optical flow and mean-shift

## Future Improvements
- Occlusion handling / re-identification (e.g. Kalman prediction)
- CAMShift extension (scale-adaptive mean-shift)
- Live webcam input
- Export the full tracked video to a file
- Quantitative accuracy metrics (IoU vs. ground truth)

## Team Members
- Ma'mon Yousef
- Faisal Ghatasheh
- Majd Basheer
- Sarah Jazar
- Dana Elayyan

## Course Information
- Course: Computer Vision
- Project Type: Group Project
- Development Environment: MATLAB

## License
This project is developed for educational purposes only.

## Acknowledgments
- MATLAB Documentation and Computer Vision Toolbox resources
- Course instructor Dr. Omar AlQadi and the teaching assistants
