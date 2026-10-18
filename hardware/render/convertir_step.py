# FreeCAD (freecadcmd): STEP -> un STL por sólido, nombrado con la etiqueta del STEP (para asignar materiales).
# Uso: freecadcmd convertir_step.py entrada.step carpeta_salida
import sys, os, FreeCAD, Import, MeshPart
args = [a for a in sys.argv if a.endswith((".step", ".stp"))]
src = args[0]; out = sys.argv[sys.argv.index(src) + 1]
os.makedirs(out, exist_ok=True)
doc = FreeCAD.newDocument("m"); Import.insert(src, "m")
n = 0
for o in doc.Objects:
    if o.TypeId == "Part::Feature" and o.Shape.Solids:
        m = MeshPart.meshFromShape(Shape=o.Shape, LinearDeflection=0.05, AngularDeflection=0.3)
        m.write(os.path.join(out, "%03d_%s.stl" % (n, "".join(c if c.isalnum() else "_" for c in o.Label)))); n += 1
print("PIEZAS", n)
