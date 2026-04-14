# Godot 4.7 — Responsive Layout & CardSelectionScreen

**Date:** April 2026  
**Issue:** CardSelectionScreen grid was invisible despite buttons being created  
**Status:** ✅ Resolved

---

## The Problem

Card buttons were instantiated successfully (confirmed in logs: "20 buttons created"), but the grid never rendered. Investigation revealed:

```
CardGridScroll size: (0.0, 0.0)
CardGrid size: (271.0, 0.0)  ← width ok, height 0!
```

The grid had collapsed to zero height despite EXPAND_FILL flags.

---

## Root Causes

### 1. Broken Anchor Chain on Root Control

**The culprit:**
```tscn
[node name="CardSelectionScreen" type="Control"]
layout_mode = 3
anchors_preset = 0  ← ALL anchors default to 0
```

With `anchors_preset = 0`, the Control gets:
- `anchor_right = 0.0` (not 1.0!)
- `anchor_bottom = 0.0` (not 1.0!)

Result: Root VBoxContainer with `offset_right = -20` calculates right edge as `0 * viewport_width - 20 = -20px` → **negative width**.

### 2. Missing Dynamic `custom_minimum_size` on ScrollContainer

ScrollContainer inside a VBoxContainer with EXPAND_FILL needs an explicit height, or the layout engine has no minimum to propagate:

```gdscript
# CardGridScroll had custom_minimum_size = (0, 0) in .tscn
# VBoxContainer EXPAND_FILL tries to fill this child
# But 0 + expand_fill = still 0
```

### 3. Unnecessary Container Nesting

```
VBoxContainer (root)
  ├─ TopBar
  ├─ CardContainer (VBoxContainer)  ← redundant!
  │   ├─ TitleLabel
  │   └─ CardGridScroll
  └─ BottomBar
```

VBoxContainer expands children horizontally, but nesting another VBoxContainer can suppress this propagation without explicit size_flags.

---

## Solution

### Step 1: Fix Anchor Chain
```tscn
[node name="CardSelectionScreen" type="Control"]
layout_mode = 1
anchors_left = 0.0
anchors_top = 0.0
anchors_right = 1.0  ← KEY
anchors_bottom = 1.0  ← KEY
```

### Step 2: Eliminate Unnecessary Nesting
```
VBoxContainer (root)
  ├─ TopBar (80px min)
  ├─ TitleLabel (30px min)
  ├─ CardGridScroll (EXPAND_FILL entire free space)
  └─ BottomBar (50px min)
```

### Step 3: Calculate Dimensions Dynamically

In `_ready()`, **after scene tree is ready**, calculate available space and set ScrollContainer size:

```gdscript
func _ready() -> void:
    var viewport_size := get_viewport_rect().size
    
    # Calculate reserved space (fixed-height elements)
    var reserved_height := 80.0 + 30.0 + 50.0  # TopBar + Title + Bottom
    var margins := 40.0  # 20px left + 20px right
    
    var available_height := viewport_size.y - reserved_height - 40.0
    var available_width := viewport_size.x - margins
    
    # Set ScrollContainer minimum size BEFORE layout pass
    var scroll_container = _card_grid.get_parent()
    scroll_container.custom_minimum_size = Vector2(available_width, available_height)
    
    DebugLogger.log_system("Viewport: %s, Scroll min_size: %.0fx%.0f" % [
        viewport_size, available_width, available_height
    ])
```

---

## Why This Works

1. **Root anchors full-width/full-height** → VBoxContainer inherits full viewport dimensions
2. **No nesting** → horizontal expansion propagates cleanly
3. **Dynamic min_size** → ensures ScrollContainer has explicit dimensions when layout pass runs
4. **Responsive** → adapts to any window size; calculated fresh on scene load

---

## Godot Layout Principles to Remember

### Container Expansion Rules

| Flag | Effect |
|------|--------|
| `size_flags_horizontal = 2` | FILL — expands to parent width, minimum size = 0 |
| `size_flags_horizontal = 3` | EXPAND_FILL — expands + takes share of extra space |
| `size_flags_vertical = 2` | FILL — expands to parent height, minimum size = 0 |
| `size_flags_vertical = 3` | EXPAND_FILL — expands + takes share of extra space |

**Key insight:** FILL/EXPAND_FILL with `custom_minimum_size = 0` still collapses to 0. You must set a minimum size (either statically or dynamically) for the flag to have something to expand from.

### Anchor Mode vs Container Mode

- **`layout_mode = 1` (Anchor mode):** Position/size using anchors and offsets. Use for root Controls.
- **`layout_mode = 2` (Container mode):** Position/size controlled by parent Container. Use for children of VBox/HBox/GridContainer.

**Mistake:** Using `layout_mode = 1` on children of a VBoxContainer breaks the Container's layout management.

### When to Use `custom_minimum_size`

- **Static size:** Set in .tscn for fixed-height TopBar, etc.
- **Dynamic size:** Calculate in `_ready()` for containers that must adapt to viewport
- **GridContainer wrapping:** Set width to parent available width so columns wrap correctly

---

## Files Modified

- `scenes/screens/card_selection_screen.tscn`
  - Fixed `CardSelectionScreen` anchors (0,0,1,1)
  - Removed `CardContainer` VBoxContainer (unnecessary nesting)
  - Removed hardcoded `custom_minimum_size` from CardGridScroll

- `scripts/screens/card_selection_screen.gd`
  - Added dynamic `custom_minimum_size` calculation in `_ready()`
  - Removed .tscn path to CardContainer (now direct child)

---

## Testing & Verification

✅ Grid now renders at any window size  
✅ 20 card buttons visible  
✅ ScrollContainer handles overflow correctly  
✅ Responsive: resizing window updates layout  

---

## References

- Godot 4.7 Layout Documentation: https://docs.godotengine.org/en/stable/gui/containers/index.html
- Container Control Nodes: https://docs.godotengine.org/en/stable/gui/containers/control_node_container.html
