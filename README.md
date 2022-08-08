# Filterio
A simple macOS image processing application using filters built with metal shaders

## Implemented Filters
- Brightness
- Contrast
- Gamma
- Vignette
- Saturation
- RGB to GBR
- Pixelate

Each filter is implemented as a compute kernel which performs parallel computations on a given image. Each thread of the gpu performs its shader's calculation on an individual point of the input image
