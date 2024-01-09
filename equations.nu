#!/bin/env nu 
# Equations

# Calculate angular FOV in degrees
export def afov [
  f: float # Focal length (mm)
  H: float # Sensor size (mm)
] -> float {
  2 * (($H / (2 * $f)) | math arctan --degrees)
}
