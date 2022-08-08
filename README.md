# Filterio
A simple macOS image processing application using filters built with metal shaders

<img width="1000" alt="Screen Shot 2022-08-07 at 11 05 06 PM" src="https://user-images.githubusercontent.com/28976325/183350143-dbefae72-05d6-420d-87ba-9634fda4319e.png">
<img width="1000" alt="Screen Shot 2022-08-07 at 11 01 57 PM" src="https://user-images.githubusercontent.com/28976325/183350029-b010d56e-8de8-4738-ab28-765325e4a180.png">

## Implemented Filters
- Brightness
- Contrast
- Gamma
- Vignette
- Saturation
- RGB to GBR
- Pixelate

Each filter is implemented as a compute kernel which performs parallel computations on a given image. Each thread of the gpu performs its shader's calculation on an individual point of the input image


## Todos
* Implement support for applying mulitiple filters at once
* Add ability to upload an image
* Add better support for rezing / resampling image as window size changes
