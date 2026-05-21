# Group Project Plan — Object Tracking (extends Task 3 GUI)

## Context

The individual Task 3 produced a polished MATLAB `uifigure` app (`third_programming_task.m`)
with a Controls panel, image axes, kernel visualization, and 14 CV categories wired through
one orchestrator (`applyProc`). The course project (5-student group, 5-minute demo) requires
a MATLAB GUI for **Object Tracking** using classical techniques. We will extend Task 3's
GUI rather than rebuild it — this maximises reuse (preprocessing pipeline, file I/O, axes,
styling, Harris corner detection which underpins KLT) and showcases that the team built on a
substantial existing system. Grading hits five axes (Functionality, Performance, UI,
Robustness, Documentation), so the plan is balanced across all of them, not just "make
tracking work."

Confirmed decisions:
- **Foundation:** extend Task 3 GUI (new category + video pipeline + new axes mode).
- **Trackers:** Lucas–Kanade (KLT) — primary, directly maps to course slides; Mean-Shift
  (color-histogram) — secondary, satisfies project brief and gives a comparison story.
- **Input:** video files only (for presentation).
- **Targets:** single object (one ROI).and not Multi-object.

Optional add-ons if time allows: Farneback dense flow visualization (already a 1-liner in
MATLAB), and a simple Kalman filter wrapper around KLT for occlusion robustness.

---

## High-Level Architecture

A new top-level category **"Object Tracking"** added to the existing `ddCat` dropdown in
`third_programming_task.m:74`. When selected:

1. **`btnLoad`** behavior switches from `imread` to `VideoReader` (detect by file extension).
2. A new **Video Playback Panel** appears below `axProc`: Play/Pause/Stop/Step buttons,
   frame slider, FPS readout.
3. **`btnTemplate`** is repurposed as **"Select ROI"** — uses `drawrectangle` on the first
   frame's axes to get the initial bounding box.
4. **`ddOp`** items for the category: `{'Lucas-Kanade (KLT)','Mean-Shift','Farneback Flow','Kalman + KLT'}`.
5. New parameter sliders shown via `configSlider`/`configVisibility` per tracker.
6. A new orchestrator function `doTracking(frame, state, op, params)` is called from a
   timer-driven frame loop (or `while` loop with `drawnow limitrate`).
7. Reuses the existing preprocessing pipeline (`preProcess` at line 892) on each frame, so
   the team can demo "tracking with Gaussian smoothing on" vs off — directly using Task 3
   work.
8. A **Metrics overlay** on `axProc`: per-frame processing time (ms), FPS, current bbox
   coords, # tracked points (for KLT). For Robustness/Performance marks.

---

## File Layout

Keep everything compatible with the single-file convention of Task 3, but split tracking
logic into helper files to enable parallel work without merge conflicts:

```
Task 4 (Group Project)/
├── tracking_app.m                  # Main entry (copy of third_programming_task.m +
│                                   # extensions). Video loader and ROI selector live
│                                   # here as local functions — no need to split them out.
├── trackers/
│   ├── trackerKLT.m                # init / update API
│   ├── trackerMeanShift.m          # init / update API
│   ├── trackerFarneback.m          # optional / stretch
│   └── trackerKalmanKLT.m          # optional / stretch
├── ui/
│   ├── videoPanel.m                # builds Play/Pause/Slider controls
│   └── metricsOverlay.m            # draws bbox, points, FPS text on axes
├── utils/
│   └── evalMetrics.m               # IoU, center-error, FPS (for report)
├── test_videos/                    # sample clips for development
├── docs/
│   ├── README.md                   # how to run, controls, limitations
│   └── user_guide.pdf              # 2-3 page printed guide for grader
└── report/
    └── group_report.pdf            # design, results, who-did-what
```
Each tracker exposes a **uniform contract** so the orchestrator stays clean:

```matlab
state = trackerXxx('init',  frame, bbox, params)
[state, bboxOut, vis] = trackerXxx('update', frame, state, params)
```

`vis` is an optional middle-axes visualization (KLT points, Mean-Shift back-projection,
flow field). This drops cleanly into the existing 3-axes layout (`axOrig | axFilt | axProc`).

---

## Tracker Details (technical sketch)

### Lucas–Kanade (KLT) — primary
- On `init`: convert frame to gray, detect Harris (or Shi-Tomasi) corners inside the ROI
  using `detectMinEigenFeatures`, store them, build a `vision.PointTracker` (pyramidal LK).
- On `update`: `step(tracker, newFrame)` → keep only `isFound` points; estimate geometric
  transform (`estgeotform2d` with `similarity`) from old→new inlier points; transform the
  bbox corners by that transform; re-detect points if count drops below a threshold (e.g.,
  < 10) to recover from drift.
- Middle axes: original frame with tracked points overlaid (green = inlier, red = lost).
- Maps directly to slides on Lucas-Kanade (the 5×5 numerical example is in your slides at
  ~line 3801) and Harris (already in your Task 3 at category "Corner Detection").

### Mean-Shift — secondary
- On `init`: convert ROI to HSV, compute Hue histogram (e.g., 16 bins), masked by S/V
  range to ignore low-saturation pixels.
- On `update`: back-project the histogram onto the new frame's Hue channel to get a
  probability image (this can be the middle-axes visualization), iterate mean-shift
  (centroid of weighted window) until convergence. Add CAMShift extension (window scales
  with zeroth moment) as a small bonus for handling scale changes.
- Robustness story: works when KLT loses texture (e.g., a uniformly-colored ball).

### Farneback dense flow — optional visualization
- One call: `opticFlow = opticalFlowFarneback; flow = estimateFlow(opticFlow, gray)`.
- Use as the middle-axes visualization (quiver plot) — pure demo eye-candy that maps to
  the slide deck's "dense flow" discussion.

### Kalman + KLT — optional robustness
- Wrap KLT's bbox centroid in a constant-velocity Kalman filter; during frames with
  too few KLT points, predict from the filter instead of reporting "lost." Use
  `vision.KalmanFilter` or `configureKalmanFilter`.

---

## Work Split for 5 People

Each member owns one grading criterion and the files needed to deliver it.

### Member A — Integration Lead (Functionality)
- **Writes:** `tracking_app.m`.
- **Does:** add "Object Tracking" category to the GUI, video loading, ROI selection,
  the frame loop, and dispatch to the right tracker.
- Sole writer of the main file. Merges everyone else's work.

### Member B — KLT Tracker (Performance)
- **Writes:** `trackers/trackerKLT.m`.
- **Does:** implement Lucas-Kanade tracking with two functions, `init` and `update`.
  Reuse Task 3's Harris corners as the detector. Tune for fast frame rates.

### Member C — Mean-Shift Tracker (Robustness)
- **Writes:** `trackers/trackerMeanShift.m`.
- **Does:** implement Mean-Shift (HSV histogram + back-projection) with the same
  `init` / `update` shape as KLT. Test on clips with occlusion, scale change, and
  fast motion; document where each tracker fails.

### Member D — UI (User Interface)
- **Writes:** `ui/videoPanel.m`, `ui/metricsOverlay.m`.
- **Does:** build the Play/Pause/Stop/Slider/FPS controls and the on-frame overlay
  (bounding box, tracked points, FPS text). Match Task 3's dark styling.

### Member E — Evaluation & Docs (Documentation)
- **Writes:** `utils/evalMetrics.m`, `docs/README.md`, `docs/user_guide.pdf`,
  `report/group_report.pdf`, the presentation slides.
- **Does:** annotate ground-truth bboxes for 2 clips (MATLAB Video Labeler app),
  compute IoU / center-error / FPS, write all documentation, prepare the 5-minute
  demo script and a backup screen recording.

---

## Verification Plan

End-to-end checks before the presentation:

1. **Smoke test:** `tracking_app` → load a test `.mp4` → "Object Tracking" → "Lucas-Kanade
   (KLT)" → draw ROI → Play. Bbox follows the object for at least 200 frames.
2. **Pipeline reuse:** enable "Gaussian Filter" preprocessing checkbox while tracking runs;
   verify the tracker still works on the smoothed frames (proves Task 3 reuse).
3. **Tracker swap:** switch the `ddOp` dropdown from KLT to Mean-Shift mid-video (or after
   pause) and confirm tracking resumes from the current bbox without crashing.
4. **Metrics:** run `utils/evalMetrics.m` against the annotated clips → produces IoU plot
   and FPS number → both numbers go into the report and onto a presentation slide.
5. **Robustness suite:** Member C's clip set runs without crashing the app; "lost" states
   show a clear visual indicator instead of a stale bbox.
6. **Cold-start rehearsal:** close MATLAB, reopen, run `tracking_app`, do the full demo
   blind. Twice. The day before.

---

## Critical Files To Read Before Coding

- `Task 3/third_programming_task.m:74` — `ddCat` Items (add "Object Tracking" here).
- `Task 3/third_programming_task.m:279` — `cb_Load` (extend to detect video extensions).
- `Task 3/third_programming_task.m:297` — `cb_CatChanged` (add `ddOp` items for tracking).
- `Task 3/third_programming_task.m:427` — `configSlider` (add cases for tracker params).
- `Task 3/third_programming_task.m:487` — `configVisibility` (show/hide video panel).
- `Task 3/third_programming_task.m:638` — `applyProc` (the orchestrator — add `case
  'Object Tracking'` that dispatches to `doTracking`).
- `Task 3/third_programming_task.m:892` — `preProcess` (reuse verbatim per frame).
- Task 3 "Corner Detection" branch — Member B reuses its Harris call directly.
