# Tracker Contract

Every tracker file in this folder MUST follow this exact interface so
`tracking_app.m` can swap them interchangeably from the GUI dropdown.

## Function signature

Each tracker is a single MATLAB file `trackerXxx.m` exposing one function
that dispatches on its first argument:

```matlab
varargout = trackerXxx(mode, varargin)
```

Two modes are supported: `'init'` and `'update'`.

## Mode: `'init'`

Called once when the user draws the initial ROI on the first frame.

```matlab
state = trackerXxx('init', frame, bbox, params)
```

| Argument | Type | Description |
|---|---|---|
| `frame`  | `HxWx3 uint8` or `HxW uint8` | First video frame. |
| `bbox`   | `1x4 double` | Initial bounding box `[x y w h]` in pixels. |
| `params` | `struct` | Tracker-specific parameters from GUI sliders. May be empty `struct()`. |
| **returns `state`** | `struct` | Opaque tracker state. The app stores it and passes it back on every `update`. |

## Mode: `'update'`

Called once per video frame after `init`.

```matlab
[state, bboxOut, vis] = trackerXxx('update', frame, state, params)
```

| Argument | Type | Description |
|---|---|---|
| `frame`  | `HxWx3 uint8` or `HxW uint8` | New video frame. |
| `state`  | `struct` | State returned by the previous `init`/`update` call. |
| `params` | `struct` | Current parameter values (allows live tuning from GUI sliders). |
| **returns `state`**   | `struct`     | Updated tracker state. |
| **returns `bboxOut`** | `1x4 double` or `[]` | New bounding box `[x y w h]`, or `[]` if tracking is lost. |
| **returns `vis`**     | `HxWx3 uint8` or `[]` | Optional visualization to show on `axFilt` (e.g. tracked points, probability map). `[]` for none. |

## Rules

1. **Tracker is stateless across instances** — all per-track memory lives in `state`.
2. **Never mutate the input frame.** Always copy if you need to draw on it.
3. **Bounding box format is `[x y w h]`** with `x,y` being the top-left corner in pixels (1-indexed for MATLAB).
4. **Return `bboxOut = []` to signal "lost"** — don't return a stale bbox.
5. **Keep `update` fast.** Target ≥ 25 FPS on 720p video. No `imshow` calls inside the tracker.
6. **`params` may change between calls** — read it fresh each time, don't cache values from `init` unless they truly can't change live.

## Reference implementations in this folder

- `trackerDummy.m` — stub that does nothing. Use it to verify the app's frame loop works before real trackers exist.
- `trackerKLT.m` — Lucas-Kanade point tracker (primary).
- `trackerMeanShift.m` — Mean-Shift color histogram tracker (secondary).
