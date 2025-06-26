# AnAppleADay, also known as, Intrart

## Overview

This repository provides a powerful pipeline for generating and manipulating high-fidelity 3D models from medical CT scans. Leveraging the Visualization Toolkit (VTK) for volumetric rendering, this project integrates with Apple’s visionOS to deliver an immersive, interactive experience tailored for medical professionals. Clinicians and researchers can import DICOM files, generate 3D reconstructions, annotate, and explore anatomical structures in a mixed-reality environment.

### DISCLAIMER
Medical imaging 3D visualization powered by VTK and visionOS, that does not in ANY CASE permit usage in surgery rooms. Everything is a work of research held in the Apple Developer Academy, through the ARTE program.

Features
- DICOM Import & Parsing: Load medical CT scan data in DICOM format for processing.
- 3D Reconstruction: Convert volumetric CT data into polygonal meshes using VTK’s Marching Cubes algorithm.
- Interactive Manipulation: Rotate, scale, and slice 3D models in real time within visionOS.
- Annotation & Measurement: Add markers, measure distances, and export reports.
- Caching Options: Allows to cache the model inside the application, so that once the model has been generated the first time, it is possible to quickly reopen it by selecting the same files.

> [!NOTE] 
> *Additional Resources*
> To know more about the "SetMode" utility used in this project, refere to [this Medium article](https://medium.com/@davide.castaldi31/mastering-windows-immersive-spaces-cycle-management-in-visionos-d6d98877f71a) by Davide Castaldi. 
> For any information about how to compile/integrate the Visualization Toolkit framework, please refer to [Scripts/README.md](./Scripts/README.md)

### Prerequisites 
- Operating System: visionOS 2.0+
- Xcode: Version 16 or later

### DICOM Processing

Through the integration of VisualizationToolKit framework, thanks to the bridging done in ObjectiveC/ObjectiveC++, and the capabilities of statically linking all the libraries, it has been possible to make the project work.

### 3D Model Generation

Intrart allows to simply input the folder that holds all the DICOM files, and gives as an output the 3D model in high-fidelity. Many options are allowed such as model manipulation, through an intuitive UI
