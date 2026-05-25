# Scene Motion Contract (Whole-Frame Lucas-Kanade)

This project tracks **scene motion**, not user-selected objects. There is no
ROI. The algorithm follows the textbook Lucas-Kanade flow described in the
course slides:

1. Detect Harris corners over the **entire frame**.
2. Run pyramidal Lucas-Kanade between consecutive frames on every tracked
   point.
3. Each point's frame-to-frame displacement is its optical-flow vector.
4. Points whose flow magnitude exceeds a threshold are "moving."
5. Moving points are clustered spatially. Each cluster's axis-aligned
   bounding box marks an "object in motion."

There is no "tracker identity": if an object is occluded, its points are
lost and no cluster is drawn for it. When it reappears, periodic
re-detection picks up new corners on it and a fresh cluster emerges.

## Function: `sceneFlow.m`

A single file under `trackers/` exposing one function with mode dispatch:

```matlab
varargout = sceneFlow(mode, varargin)
```

### Mode: `'init'`

Called once when the video is loaded.

```matlab
state = sceneFlow('init', frame, params)
```

| Arg | Type | Description |
|---|---|---|
| `frame`  | `HxWx3 uint8` / `HxW uint8` | The first frame. |
| `params` | `struct` | Tunable parameters from the GUI. |
| **returns `state`** | `struct` | Tracker state: a `vision.PointTracker`, the current point set, and the re-detect counter. |

### Mode: `'update'`

Called once per video frame after `init`.

```matlab
[state, bboxes, flow] = sceneFlow('update', frame, state, params)
```

| Arg / Return | Type | Description |
|---|---|---|
| `frame`   | `HxWx3 uint8` / `HxW uint8` | New frame. |
| `state`   | `struct`  | Returned from the previous `init`/`update`. |
| `params`  | `struct`  | Live GUI parameters (re-read each call). |
| `bboxes`  | cell of `1x4` | One `[x y w h]` per detected motion cluster, possibly empty. |
| `flow`    | `Nx4` matrix  | `[oldX oldY newX newY]` per tracked point this frame; used for the quiver overlay. |

## Parameters (struct fields)

| Field | Meaning | Typical range |
|---|---|---|
| `motionThresh`  | min displacement (px/frame) to count as "moving" | 0.5–10 |
| `minClusterPts` | min moving points to form a cluster | 3–30 |
| `clusterRadius` | max distance (px) between two points in the same cluster (DBSCAN epsilon) | 10–100 |
| `pyrLevels`     | `vision.PointTracker.NumPyramidLevels` | 1–5 |

All parameters have defaults inside `sceneFlow.m`; the GUI may omit fields it does not control.
