# ORBIT TERMINAL · convierte los STL a STEP con FreeCAD (freecadcmd).
# OJO: el STEP resultante es una MALLA FACETADA convertida a sólido (caras
# triangulares planas), NO un B-rep paramétrico. Útil para visualizar o
# posicionar en otro CAD, no para editar cotas. PROVISIONAL.
import glob, os, Mesh, Part
d = os.path.dirname(os.path.abspath(__file__)) if "__file__" in dir() else os.getcwd()
src = os.path.join(d, "export", "stl"); dst = os.path.join(d, "export", "step")
os.makedirs(dst, exist_ok=True)
for p in sorted(glob.glob(os.path.join(src, "*.stl"))):
    m = Mesh.Mesh(p)
    m.harmonizeNormals()
    so = None
    for tol in (0.05, 0.01, 0.1):
        sh = Part.Shape(); sh.makeShapeFromMesh(m.Topology, tol)
        sh.sewShape()
        try:
            cand = Part.makeSolid(sh)
        except Exception:
            cand = sh
        if so is None or cand.isValid():
            so = cand
        if so.isValid():
            break
        try:
            fx = so.copy(); fx.fix(tol, tol, tol)
            if fx.isValid(): so = fx; break
        except Exception:
            pass
    out = os.path.join(dst, os.path.basename(p)[:-4] + ".step")
    so.exportStep(out)
    print("STEP", os.path.basename(out), "valido" if so.isValid() else "NO-valido", so.ShapeType, len(m.Facets), "facetas")
