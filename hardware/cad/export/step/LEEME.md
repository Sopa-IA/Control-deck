# STEP · ORBIT TERMINAL

**No regenerados en v1.** Los STEP facetados de v0 (generados desde los STL con FreeCAD) ya no corresponden a la geometría actual. Además, 3 trozos de carcasa no pasaban la validación de OpenCASCADE. Por tamaño (~42 MB) no se suben al repositorio (`.gitignore`).

Para regenerarlos desde los STL de v1: `freecadcmd hardware/cad/stl_a_step_freecad.py`. Sigue siendo una malla facetada, no un B-rep paramétrico. **La referencia de geometría son el código OpenSCAD y los STL.** **NO APTOS PARA FABRICACIÓN.**
