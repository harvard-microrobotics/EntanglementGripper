# Processed X-ray CT data and image genearating code

## Trimmed data from raw X-ray CT data for visualization

Raw x-ray CT data were processed using the commercial software Amira to segment the object and each filament and reconstruct centerlines of each filament. Afterwards, we use MATLAB for further postprocessing to obtain visualization results. Number of filaments and entanglement in spherical domains were computed first by dissecting the entire domain into local bounding spheres and by counting the number of filaments or computing pairwise Average Crossing Number in each sphere. For each scan, preprocessed information is stored in "All-in-One.mat", which includes the following five matlab variables:

| Variable name | Type                | Description                                                                             |
| ------------- | ------------------- | --------------------------------------------------------------------------------------- |
| `output`      | struct              | Structured array containing number (`n`) and entanglement (`e`) fields                  |
| `r_list`      | 12x1 cell array     | Centerline positions of each filament                                                   |
| `vox_all`     | 500x500x500 logical | 3D binary image stack                                                                   |
| `vox_list`    | 12x1 cell array     | 3D binary image stack of each filament                                                  |
| `vox_obj`     | 500x500x500 logical | 3D binary image stack of the object. The **No object** case doesn't have this variable. |

## Image genearating code

`AllVisualization.m` generates all the visualization images in Figure 2. One can also generate the images in Supplementary Figure 1 using the data uploaded here. The following dependency might be required to run the script.

MATLAB Version: 9.11.0.1769968 (R2021b)
Operating System: Microsoft Windows 10 Enterprise Version 10.0 (Build 19042)
Java Version: Java 1.8.0_202-b08 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
Image Processing Toolbox                              Version 11.4        (R2021b)