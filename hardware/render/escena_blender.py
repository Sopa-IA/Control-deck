"""ORBIT TERMINAL · escena fotorrealista en Blender/Cycles a partir del CAD.

Uso:
  blender -b -P escena_blender.py -- --stl /tmp/orbit-render/stl --pi /tmp/orbit-render/pi_parts \
      --ui ../../assets/screenshots/inicio_1920x1080.png --out /tmp/orbit-render/raw --vistas hero,lateral

Geometría: las piezas impresas, el monitor (envolvente), mandos, cables y reservas salen del CAD
(partes_render.scad, mismas cotas que ensamblaje.scad). La placa del HP, el HDD 3,5", el Arduino
Micro y los pulsadores/potenciómetros se modelan aquí de forma paramétrica (ver CREDITOS-MODELOS.md).
La Raspberry Pi 4 viene del modelo STEP CC0 de Innerscene (descargar_modelos.sh).
"""
import bpy, bmesh, sys, os, math, json, random, argparse
from mathutils import Vector, Matrix
from bpy_extras.object_utils import world_to_camera_view

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ap = argparse.ArgumentParser()
ap.add_argument("--stl", default="/tmp/orbit-render/stl")
ap.add_argument("--pi", default="/tmp/orbit-render/pi_parts")
ap.add_argument("--ui", default=os.path.join(os.path.dirname(__file__), "../../assets/screenshots/inicio_1920x1080.png"))
ap.add_argument("--label", default="/tmp/orbit-render/etiqueta_hdd.png")
ap.add_argument("--out", default="/tmp/orbit-render/raw")
ap.add_argument("--vistas", default="hero,lateral,trasera,explosionado,interior,detalle")
ap.add_argument("--res", default="1920x1080")
ap.add_argument("--samples", type=int, default=160)
ap.add_argument("--pct", type=int, default=100)
A = ap.parse_args(argv)
os.makedirs(A.out, exist_ok=True)

# ---------------------------------------------------------------- parámetros del CAD
P = {}
for line in open(os.path.join(A.stl, "params.echo")):
    s = line.strip().replace('ECHO: ', '').strip('"')
    if s.startswith("P;"):
        _, k, v = s.split(";"); P[k] = float(v)
MM = 0.001
INC = math.radians(P["inclinacion"])
NRM = Vector((0, -math.sin(INC), math.cos(INC)))

def pend_a_mundo(x, v, n):  # coordenadas de la pendiente (mm) -> mundo (mm)
    return Vector((x, P["y_pend0"] + v*math.cos(INC) - n*math.sin(INC), P["alto_frontal"] + v*math.sin(INC) + n*math.cos(INC)))

# ---------------------------------------------------------------- escena limpia
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.unit_settings.system = 'METRIC'
GRUPOS = {}   # nombre de grupo -> lista de objetos (para el explosionado y la vista interior)
def grupo(o, g):
    GRUPOS.setdefault(g, []).append(o); o["grupo"] = g; return o

# ---------------------------------------------------------------- materiales
def nodos(m):
    m.use_nodes = True; nt = m.node_tree; nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial"); return nt, out
def principled(nombre, color, rough=0.5, metal=0.0, spec=0.5, coat=0.0, bevel=0.0, alpha=1.0, emis=None, emis_str=0.0, transm=0.0):
    m = bpy.data.materials.new(nombre); nt, out = nodos(m)
    b = nt.nodes.new("ShaderNodeBsdfPrincipled")
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough; b.inputs["Metallic"].default_value = metal
    b.inputs["Specular IOR Level"].default_value = spec; b.inputs["Coat Weight"].default_value = coat
    b.inputs["Alpha"].default_value = alpha; b.inputs["Transmission Weight"].default_value = transm
    if emis: b.inputs["Emission Color"].default_value = (*emis, 1); b.inputs["Emission Strength"].default_value = emis_str
    if bevel > 0:
        bv = nt.nodes.new("ShaderNodeBevel"); bv.inputs["Radius"].default_value = bevel; bv.samples = 6
        nt.links.new(bv.outputs["Normal"], b.inputs["Normal"])
    nt.links.new(b.outputs[0], out.inputs[0])
    if alpha < 1: m.blend_method = 'BLEND' if hasattr(m, "blend_method") else None
    return m, nt, b

def petg(nombre, color, rough=0.62, capa=0.2, fuerza=0.6):
    """PETG negro mate con textura de capas (bandas en Z de 'capa' mm) + bevel de aristas."""
    m, nt, b = principled(nombre, color, rough=rough, spec=0.45)
    tc = nt.nodes.new("ShaderNodeTexCoord")
    wave = nt.nodes.new("ShaderNodeTexWave"); wave.wave_type = 'BANDS'; wave.bands_direction = 'Z'
    wave.inputs["Scale"].default_value = 2*math.pi/(10*capa*MM)   # periodo = capa
    wave.inputs["Distortion"].default_value = 0.0; wave.inputs["Detail"].default_value = 0.0
    noise = nt.nodes.new("ShaderNodeTexNoise"); noise.inputs["Scale"].default_value = 900; noise.inputs["Detail"].default_value = 4
    nt.links.new(tc.outputs["Object"], wave.inputs["Vector"]); nt.links.new(tc.outputs["Object"], noise.inputs["Vector"])
    mix = nt.nodes.new("ShaderNodeMath"); mix.operation = 'MULTIPLY_ADD'
    nt.links.new(noise.outputs["Fac"], mix.inputs[0]); mix.inputs[1].default_value = 0.25; nt.links.new(wave.outputs["Fac"], mix.inputs[2])
    bump = nt.nodes.new("ShaderNodeBump"); bump.inputs["Strength"].default_value = fuerza; bump.inputs["Distance"].default_value = 0.00006
    nt.links.new(mix.outputs[0], bump.inputs["Height"])
    bv = nt.nodes.new("ShaderNodeBevel"); bv.inputs["Radius"].default_value = 0.0007; bv.samples = 6
    nt.links.new(bv.outputs["Normal"], bump.inputs["Normal"]); nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    # ligera variación de rugosidad
    rr = nt.nodes.new("ShaderNodeMapRange"); rr.inputs["To Min"].default_value = rough - 0.06; rr.inputs["To Max"].default_value = rough + 0.06
    nt.links.new(noise.outputs["Fac"], rr.inputs["Value"]); nt.links.new(rr.outputs["Result"], b.inputs["Roughness"])
    return m

M = {}
M["petg"] = petg("PETG negro mate", (0.018, 0.018, 0.02))
M["petg_bisel"] = petg("PETG negro bisel", (0.012, 0.012, 0.013), rough=0.5)
M["petg_int"] = petg("PETG gris oscuro (piezas internas)", (0.035, 0.035, 0.038))
M["pomo"] = petg("PETG pomo", (0.02, 0.02, 0.022), rough=0.55, capa=0.16)
AMB = (1.0, 0.50, 0.08)
M["ambar_led"], _, _ = principled("Guía de luz ámbar (LED encendido)", (1.0, 0.6, 0.2), rough=0.35, emis=AMB, emis_str=14)
M["ambar_suave"], _, _ = principled("Ámbar suave", (1.0, 0.6, 0.2), rough=0.4, emis=AMB, emis_str=4)
M["aluminio"], _, _ = principled("Aluminio cepillado", (0.80, 0.80, 0.82), rough=0.32, metal=1.0, bevel=0.0003)
M["acero"], _, _ = principled("Acero niquelado", (0.75, 0.75, 0.76), rough=0.22, metal=1.0, bevel=0.0002)
M["oro"], _, _ = principled("Contactos dorados", (1.0, 0.78, 0.35), rough=0.25, metal=1.0)
M["laton"], _, _ = principled("Separador latón", (0.85, 0.65, 0.3), rough=0.3, metal=1.0)
M["plastico_negro"], _, _ = principled("Plástico negro conector", (0.012, 0.012, 0.012), rough=0.45, bevel=0.0002)
M["plastico_blanco"], _, _ = principled("Plástico blanco/crema", (0.85, 0.82, 0.74), rough=0.5)
M["plastico_azul"], _, _ = principled("Plástico azul VGA/DIMM", (0.03, 0.12, 0.55), rough=0.45)
M["chip"], _, _ = principled("Encapsulado de chip", (0.02, 0.02, 0.022), rough=0.4)
M["pcb_verde"], _, _ = principled("PCB verde (HP)", (0.03, 0.17, 0.06), rough=0.38, coat=0.3)
M["pcb_pi"], _, _ = principled("PCB verde (Pi)", (0.02, 0.25, 0.08), rough=0.35, coat=0.3)
M["pcb_ard"], _, _ = principled("PCB Arduino (azul verdoso)", (0.0, 0.25, 0.30), rough=0.35, coat=0.3)
M["goma"], _, _ = principled("Goma negra (cables, pies)", (0.01, 0.01, 0.01), rough=0.75)
M["monitor"], _, _ = principled("Carcasa del monitor", (0.05, 0.05, 0.055), rough=0.4, metal=0.0, bevel=0.0008)
M["hdd_base"], _, _ = principled("HDD fundición", (0.42, 0.43, 0.45), rough=0.45, metal=1.0, bevel=0.0004)
M["fan"], _, _ = principled("Ventilador negro", (0.02, 0.02, 0.022), rough=0.5)
M["reserva"], _, _ = principled("Reserva de espacio (translúcida)", (1.0, 0.6, 0.2), rough=0.2, alpha=0.18, emis=AMB, emis_str=0.4)
M["suelo"], _, _ = principled("Suelo estudio", (0.03, 0.03, 0.033), rough=0.5)
M["condensador"], _, _ = principled("Condensador", (0.12, 0.12, 0.14), rough=0.3, metal=0.6)
M["ferrita"], _, _ = principled("Bobina", (0.05, 0.05, 0.05), rough=0.6)

def mat_pantalla():
    m = bpy.data.materials.new("Pantalla MSI con la interfaz Orbit"); nt, out = nodos(m)
    b = nt.nodes.new("ShaderNodeBsdfPrincipled")
    b.inputs["Base Color"].default_value = (0.0, 0.0, 0.0, 1); b.inputs["Roughness"].default_value = 0.06
    b.inputs["Specular IOR Level"].default_value = 0.5
    tex = nt.nodes.new("ShaderNodeTexImage"); tex.image = bpy.data.images.load(os.path.abspath(A.ui)); tex.interpolation = 'Cubic'
    tc = nt.nodes.new("ShaderNodeTexCoord"); nt.links.new(tc.outputs["UV"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], b.inputs["Emission Color"]); b.inputs["Emission Strength"].default_value = 2.2
    nt.links.new(b.outputs[0], out.inputs[0]); return m
M["pantalla"] = mat_pantalla()

def mat_imagen(nombre, ruta, rough=0.5):
    m = bpy.data.materials.new(nombre); nt, out = nodos(m)
    b = nt.nodes.new("ShaderNodeBsdfPrincipled"); b.inputs["Roughness"].default_value = rough
    tex = nt.nodes.new("ShaderNodeTexImage"); tex.image = bpy.data.images.load(os.path.abspath(ruta))
    tc = nt.nodes.new("ShaderNodeTexCoord"); nt.links.new(tc.outputs["UV"], tex.inputs["Vector"])
    nt.links.new(tex.outputs["Color"], b.inputs["Base Color"]); nt.links.new(b.outputs[0], out.inputs[0]); return m
if os.path.exists(A.label): M["etiqueta"] = mat_imagen("Etiqueta HDD genérica", A.label, 0.45)

# ---------------------------------------------------------------- utilidades de geometría
def suavizar(o, ang=32):
    me = o.data
    for p in me.polygons: p.use_smooth = True
    try: me.set_sharp_from_angle(angle=math.radians(ang))
    except Exception: pass
def importar_stl(ruta, mat, g, nombre=None, ang=32):
    if not os.path.exists(ruta) or os.path.getsize(ruta) < 200: return None
    bpy.ops.wm.stl_import(filepath=ruta, global_scale=MM)
    o = bpy.context.selected_objects[0]; o.name = nombre or os.path.basename(ruta)[:-4]
    o.data.materials.clear(); o.data.materials.append(mat); suavizar(o, ang)
    return grupo(o, g)
def caja(nombre, p, s, mat, g, bisel=0.0):
    """Caja en mm: p = esquina mínima, s = tamaño."""
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.active_object; o.name = nombre
    o.scale = (s[0]*MM, s[1]*MM, s[2]*MM); o.location = ((p[0] + s[0]/2)*MM, (p[1] + s[1]/2)*MM, (p[2] + s[2]/2)*MM)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bisel > 0:
        md = o.modifiers.new("bisel", 'BEVEL'); md.width = bisel*MM; md.segments = 2
    o.data.materials.append(mat); return grupo(o, g)
def cilindro(nombre, c, d, h, mat, g, eje='Z', n=48):
    bpy.ops.mesh.primitive_cylinder_add(vertices=n, radius=d/2*MM, depth=h*MM)
    o = bpy.context.active_object; o.name = nombre
    if eje == 'X': o.rotation_euler = (0, math.pi/2, 0)
    if eje == 'Y': o.rotation_euler = (math.pi/2, 0, 0)
    o.location = (c[0]*MM, c[1]*MM, c[2]*MM)
    o.data.materials.append(mat); suavizar(o, 40); return grupo(o, g)

# ---------------------------------------------------------------- piezas del CAD (STL)
S = lambda n: os.path.join(A.stl, n + ".stl")
importar_stl(S("carcasa"), M["petg"], "carcasa")
importar_stl(S("base"), M["petg"], "base")
importar_stl(S("bisel"), M["petg_bisel"], "bisel")
importar_stl(S("monitor"), M["monitor"], "monitor")
importar_stl(S("bandeja"), M["petg_int"], "bandeja")
importar_stl(S("sop_ard"), M["petg_int"], "sop_ard")
importar_stl(S("sop_disco"), M["petg_int"], "sop_disco")
importar_stl(S("guias"), M["ambar_led"], "guias")
importar_stl(S("tira_led"), M["ambar_led"], "comp")
importar_stl(S("pomos"), M["pomo"], "mandos", ang=20)
importar_stl(S("marca_pomo"), M["ambar_led"], "mandos")
importar_stl(S("anillos"), M["ambar_led"], "mandos")
importar_stl(S("boton_brida"), M["aluminio"], "mandos")
importar_stl(S("boton_cuerpo"), M["plastico_negro"], "mandos")
importar_stl(S("boton_tapa"), M["ambar_suave"], "mandos")
importar_stl(S("mandos_int"), M["acero"], "comp")
importar_stl(S("separadores"), M["laton"], "comp")
importar_stl(S("io_frontal"), M["plastico_negro"], "comp", "I/O frontal HP")
importar_stl(S("boton_hp"), M["aluminio"], "comp", "Pulsador HP")
importar_stl(S("cables"), M["goma"], "comp", "Cables", ang=60)
importar_stl(S("pies"), M["goma"], "pies")
importar_stl(S("captura_cuerpo"), M["monitor"], "comp", "Capturadora")
importar_stl(S("captura_clavija"), M["plastico_negro"], "comp", "Clavija HDMI capturadora")
res = importar_stl(S("captura_reserva"), M["reserva"], "reserva", "Reserva capturadora")

# pantalla: área activa del MSI en el sistema de la pendiente (UV = imagen completa)
def pantalla():
    x0, y0, z = P["act_x0"], P["act_y0"], P["act_z"]; w, h = P["act_w"], P["act_h"]
    vs = [pend_a_mundo(x0, y0, z), pend_a_mundo(x0 + w, y0, z), pend_a_mundo(x0 + w, y0 + h, z), pend_a_mundo(x0, y0 + h, z)]
    me = bpy.data.meshes.new("pantalla"); me.from_pydata([v*MM for v in vs], [], [(0, 1, 2, 3)])
    uv = me.uv_layers.new(); 
    for i, c in enumerate([(0, 0), (1, 0), (1, 1), (0, 1)]): uv.data[i].uv = c
    o = bpy.data.objects.new("Pantalla (interfaz Orbit)", me); sc.collection.objects.link(o)
    o.data.materials.append(M["pantalla"]); return grupo(o, "monitor")
pantalla()

# ---------------------------------------------------------------- placa HP (mini-ITX 170 x 170)
# Coordenadas locales de la placa: u = X (0..170, u alto = extremo del jack DC), v = Y (0..170, v = 170 = borde I/O trasero).
# Disposición según las fotos de Miguel [FOTO, posiciones aproximadas, NO medidas].
HX, HY, HZ = P["hp_x"], P["hp_y"], P["hp_pcb_z"]; TP = HZ + P["hp_pcb"]
def hb(n, u, v, du, dv, h, mat, z0=None, bisel=0.0):
    return caja("HP " + n, (HX + u, HY + v, TP if z0 is None else z0), (du, dv, h), mat, "comp", bisel)
def hc(n, u, v, d, h, mat, z0=None):
    return cilindro("HP " + n, (HX + u, HY + v, (TP if z0 is None else z0) + h/2), d, h, mat, "comp")
caja("HP PCB", (HX, HY, HZ), (170, 170, P["hp_pcb"]), M["pcb_verde"], "comp")
random.seed(7)
# componentes SMD dispersos (ilustrativos)
for i in range(140):
    u, v = random.uniform(6, 164), random.uniform(6, 140)
    if 55 < u < 132 and 60 < v < 126: continue      # bajo el disipador
    if 8 < u < 162 and 22 < v < 46: continue        # zócalos DIMM
    s = random.choice([(1.6, 0.8), (2, 1.25), (3.2, 1.6), (5, 5), (7, 7)])
    hb("smd", u, v, s[0], s[1], 0.6 if s[0] < 4 else 1.2, M["chip"])
# 2 zócalos DDR3L + módulos (paralelos al borde delantero, frente al I/O)
for i, v in enumerate([26.0, 35.0]):
    hb("zócalo DIMM %d" % (i+1), 10, v, 150, 6.5, 6.5, M["plastico_azul"] if i == 0 else M["plastico_negro"], bisel=0.3)
    for u in (8, 158): hb("pestillo DIMM", u, v - 0.5, 4, 7.5, 9, M["plastico_blanco"])
    caja("HP módulo DDR3L %d" % (i+1), (HX + 18, HY + v + 2.6, TP + 4), (133.35, 1.2, 30.0), M["pcb_verde"], "comp")
    for k in range(8):
        for side in (-1, 1):
            caja("HP chip RAM", (HX + 24 + k*15.5, HY + v + 2.6 + (1.2 if side > 0 else -1.0), TP + 10), (10, 1.0, 11), M["chip"], "comp")
    caja("HP contactos DIMM", (HX + 18, HY + v + 2.55, TP + 4), (133.35, 1.3, 3), M["oro"], "comp")
# Wi-Fi M.2 (con chapa) junto a los DIMM, extremo del jack DC
hb("Wi-Fi M.2", 120, 4, 30, 22, 2.5, M["pcb_verde"]); hb("chapa Wi-Fi", 124, 8, 18, 14, 3.4, M["acero"])
for k in range(2): hc("conector antena", 127 + k*7, 22, 2.2, 4, M["oro"])
# disipador de aletas + ventilador (altura total = hp_comp_h MEDIDO 35 mm)
CH = P["hp_comp_h"]
hb("base disipador", 62, 63, 64, 60, 4, M["aluminio"])
for k in range(24): hb("aleta", 62 + k*2.7, 63, 1.0, 60, CH - 11, M["aluminio"], z0=TP + 4)
hb("marco ventilador", 66, 66, 56, 54, 9, M["fan"], z0=TP + CH - 9, bisel=1.0)
hc("buje ventilador", 94, 93, 22, 0.8, M["fan"], z0=TP + CH - 0.8)
for k in range(7):
    a = k*2*math.pi/7
    o = caja("HP aspa", (HX + 94 - 10, HY + 93 - 2, TP + CH - 6), (20, 4, 1.2), M["fan"], "comp")
    o.rotation_euler = (math.radians(12), 0, a)
    o.location = ((HX + 94 + 14*math.cos(a))*MM, (HY + 93 + 14*math.sin(a))*MM, (TP + CH - 5)*MM)
for (u, v) in [(60, 61), (128, 61), (60, 125), (128, 125)]: hc("pasador blanco", u, v, 4, CH - 6, M["plastico_blanco"])
# VRM: bobinas y condensadores (lado del I/O, extremo DC)
for k in range(4): hb("bobina", 120 + (k % 2)*12, 128 + (k//2)*12, 9, 9, 6, M["ferrita"], bisel=0.6)
for k in range(5): hc("condensador", 108 + k*6, 150, 6, 9, M["condensador"])
hc("pila CMOS", 128, 140, 20, 3.2, M["acero"])
hb("cabezal ventilador", 140, 120, 8, 5, 6, M["plastico_blanco"])
# conectores SATA + cabezales del borde delantero-izquierdo (según la foto)
for k in range(2): hb("SATA %d" % (k+1), 4, 68 + k*10, 9, 6, 9, M["plastico_negro"])
for k, m in enumerate([M["plastico_blanco"], M["plastico_blanco"], M["plastico_blanco"]]): hb("cabezal", 2, 100 + k*16, 6, 12, 7, m)
hb("conector azul", 42, 80, 9, 11, 9, M["plastico_azul"])
hb("chipset", 32, 98, 16, 16, 1.5, M["chip"])
# I/O trasero (de u alto a u bajo: DC, VGA, HDMI, 2x USB, RJ45 + USB, audio) [FOTO: orden; posiciones no medidas]
EDGE = 170 + 1.5   # los conectores asoman ~1,5 mm sobre el borde
def io(n, u, du, prof, h, mat):
    return hb(n, u, EDGE - prof, du, prof, h, mat, bisel=0.4)
io("jack DC", 150, 10, 14, 11, M["plastico_negro"]); hc("pin DC", 155, EDGE + 0.01, 3, 0.1, M["acero"])
io("VGA", 119, 31, 12, 12.5, M["acero"]); hb("VGA azul", 124, EDGE - 0.5, 21, 0.8, 8, M["plastico_azul"], z0=TP + 2.2)
io("HDMI", 100, 15, 12, 6, M["acero"])
io("USB 2x (pila)", 78, 14.5, 15, 15.5, M["acero"])
for k in range(2): hb("lengüeta USB", 80, EDGE - 0.3, 10.5, 0.5, 1.8, M["plastico_azul"] if k == 0 else M["plastico_negro"], z0=TP + 3 + k*7.5)
io("RJ45 + 2x USB", 46, 21, 21, 31, M["acero"]); hb("boca RJ45", 48, EDGE - 0.4, 16, 0.6, 12, M["plastico_negro"], z0=TP + 17)
io("audio", 22, 14, 14, 24, M["plastico_negro"])
for k, c in enumerate([(0.2, 0.6, 1.0), (0.3, 0.9, 0.3), (1.0, 0.5, 0.7)]):
    m, _, _ = principled("audio %d" % k, c, 0.4); hc("jack audio", 29, EDGE + 0.05, 6.5, 0.1, m, z0=TP + 5 + k*7)

# ---------------------------------------------------------------- HDD 3,5" (SFF-8301: 101,6 x 147 x 26,1)
DX, DY, DZ = P["disco_x"], P["disco_y"], P["disco_z"]
caja("HDD cuerpo", (DX, DY, DZ + 3), (101.6, 147, 20.6), M["hdd_base"], "comp", bisel=1.5)
caja("HDD tapa", (DX + 2, DY + 2, DZ + 23.6), (97.6, 143, 1.5), M["aluminio"], "comp", bisel=0.8)
if "etiqueta" in M:
    o = caja("HDD etiqueta", (DX + 8, DY + 30, DZ + 25.1), (85.6, 105, 0.1), M["etiqueta"], "comp")
    # UV de la cara superior
    me = o.data; uvl = me.uv_layers.new() if not me.uv_layers else me.uv_layers[0]
    for poly in me.polygons:
        for li in poly.loop_indices:
            co = me.vertices[me.loops[li].vertex_index].co
            uvl.data[li].uv = ((co.x/(85.6*MM)) + 0.5, (co.y/(105*MM)) + 0.5)
caja("HDD PCB inferior", (DX + 6, DY + 4, DZ + 0.2), (89.6, 100, 2.8), M["pcb_verde"], "comp")
hb_ = None
caja("HDD SATA datos", (DX + 60, DY - 1, DZ + 3.5), (16, 6, 5), M["plastico_negro"], "comp")
caja("HDD SATA alim.", (DX + 25, DY - 1, DZ + 3.5), (24, 6, 5), M["plastico_negro"], "comp")
for z in (DZ + 9.0,):   # agujeros laterales 6-32 (posiciones SFF-8301: 28,5 / 41,6 / 101,6 mm aprox.)
    for y in (28.5, 70.1, 130.1):
        for x in (DX - 0.05, DX + 101.65):
            cilindro("HDD agujero", (x, DY + y, z), 3.5, 0.2, M["chip"], "comp", eje='X')
for (x, y) in [(DX + 10, DY + 10), (DX + 91.6, DY + 10), (DX + 10, DY + 137), (DX + 91.6, DY + 137), (DX + 50.8, DY + 75)]:
    cilindro("HDD tornillo tapa", (x, y, DZ + 25.15), 4, 0.3, M["acero"], "comp")

# ---------------------------------------------------------------- Raspberry Pi 4 (STEP CC0 Innerscene)
def mat_pi(nombre):
    n = nombre.lower()
    if n.startswith("pcb"): return M["pcb_pi"]
    if "passive" in n or "pmic" in n or "usb_controller" in n or "memory" in n or "processor" in n: return M["chip"] if "processor" not in n else M["aluminio"]
    if "gpio40_pin" in n or "contact" in n or "tongue" in n: return M["oro"]
    if "housing" in n or "ffc" in n or "insert" in n or "audio" in n: return M["plastico_negro"]
    return M["acero"]
pi_objs = []
if os.path.isdir(A.pi):
    for f in sorted(os.listdir(A.pi)):
        if not f.endswith(".stl"): continue
        nombre = f[4:-4]
        o = importar_stl(os.path.join(A.pi, f), mat_pi(nombre), "comp", "Pi " + nombre)
        if o: pi_objs.append(o)
    for o in pi_objs:
        o.location = (P["pi_x"]*MM, P["pi_y"]*MM, P["pi_z"]*MM)
else:
    caja("Pi PCB (marcador)", (P["pi_x"], P["pi_y"], P["pi_z"]), (85, 56, 1.6), M["pcb_pi"], "comp")
# (los separadores de la Pi forman parte de la bandeja de servicio impresa)

# ---------------------------------------------------------------- Arduino Micro (48 x 17,7 mm, dimensiones oficiales)
AX, AY, AZ = P["ard_x0"], P["ard_y"], P["ard_pcb_z"]; AL, AW = P["ard_l"], P["ard_w"]
caja("Arduino PCB", (AX, AY, AZ), (AW, AL, 1.6), M["pcb_ard"], "comp")
caja("Arduino ATmega32U4", (AX + AW/2 - 5, AY + 18, AZ + 1.6), (10, 10, 1.2), M["chip"], "comp")
caja("Arduino cristal", (AX + 3, AY + 31, AZ + 1.6), (3.2, 2.5, 0.9), M["acero"], "comp")
caja("Arduino reset", (AX + AW/2 - 3, AY + 36, AZ + 1.6), (6, 3.5, 2.5), M["plastico_negro"], "comp")
caja("Arduino regulador", (AX + 3, AY + 8, AZ + 1.6), (4, 3, 1.2), M["chip"], "comp")
caja("Arduino micro-USB", (AX + AW/2 - 3.9, AY + AL - 4.1, AZ + 1.6), (7.8, 5.6, 2.8), M["acero"], "comp")
for side in (AW/2 - 7.62, AW/2 + 7.62):
    for k in range(17):
        y = AY + 3.32 + k*2.54
        caja("Arduino pin", (AX + side - 0.32, y - 0.32, AZ - 8.5), (0.64, 0.64, 11.5), M["oro"], "comp")
    caja("Arduino separador pines", (AX + side - 1.27, AY + 2.05, AZ - 2.5), (2.54, 17*2.54, 2.5), M["plastico_negro"], "comp")
for k in range(4): caja("Arduino LED", (AX + 2 + k*3, AY + 42, AZ + 1.6), (1.6, 0.8, 0.5), M["ambar_suave"], "comp")

# ---------------------------------------------------------------- estudio: suelo, luces, mundo
bpy.ops.mesh.primitive_plane_add(size=60, location=(0.23, 0.15, -0.0045))
fl = bpy.context.active_object; fl.name = "Suelo"; fl.data.materials.append(M["suelo"])
def ciclorama():
    """Fondo curvo de estudio detrás de la pieza (solo para el perfil lateral, cámara mirando a +X)."""
    perfil = [(0.55, 0.0)] + [(1.3 + 0.9*math.sin(t*math.pi/2/16), 0.9 - 0.9*math.cos(t*math.pi/2/16)) for t in range(17)] + [(2.2, 3.0)]
    bm = bmesh.new(); filas = []
    for y in (-3.0, 3.3):
        filas.append([bm.verts.new((x, y, z - 0.0044)) for (x, z) in perfil])
    for i in range(len(perfil) - 1):
        bm.faces.new((filas[0][i], filas[0][i+1], filas[1][i+1], filas[1][i]))
    me = bpy.data.meshes.new("ciclorama"); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new("Ciclorama", me); sc.collection.objects.link(o); o.data.materials.append(M["suelo"])
    for p in o.data.polygons: p.use_smooth = True
    o.visible_shadow = False
    return grupo(o, "cove")
ciclorama()
w = bpy.data.worlds.new("Mundo"); sc.world = w; w.use_nodes = True
bg = w.node_tree.nodes["Background"]; bg.inputs["Color"].default_value = (0.012, 0.012, 0.014, 1); bg.inputs["Strength"].default_value = 1.0
def luz(n, tipo, loc, energia, tam=1.0, color=(1, 1, 1), mira=(0.23, 0.15, 0.06)):
    d = bpy.data.lights.new(n, tipo); d.energy = energia; d.color = color
    if tipo == 'AREA': d.size = tam; d.shape = 'DISK'
    o = bpy.data.objects.new(n, d); sc.collection.objects.link(o); o.location = loc
    dirv = Vector(mira) - Vector(loc); o.rotation_euler = dirv.to_track_quat('-Z', 'Y').to_euler(); return o
LUCES = [
    luz("Clave", 'AREA', (-0.9, -1.1, 1.3), 55, 1.4, (1.0, 0.97, 0.93)),
    luz("Relleno", 'AREA', (1.4, -0.6, 0.6), 12, 1.6, (0.85, 0.9, 1.0)),
    luz("Contra", 'AREA', (0.3, 1.6, 0.9), 60, 1.2, (1.0, 0.93, 0.85)),
    luz("Cenital", 'AREA', (0.23, 0.15, 1.6), 18, 2.0),
]

# ---------------------------------------------------------------- render
sc.render.engine = 'CYCLES'
cy = sc.cycles; cy.device = 'CPU'; cy.samples = A.samples; cy.use_adaptive_sampling = True; cy.adaptive_threshold = 0.02
cy.max_bounces = 8; cy.transparent_max_bounces = 8
try:
    cy.denoiser = "OPENIMAGEDENOISE"; cy.use_denoising = os.environ.get("ORBIT_OIDN", "1") == "1"
    for vl in sc.view_layers: vl.cycles.use_denoising = cy.use_denoising
except Exception as e:
    print("sin OIDN:", e)
rx, ry = [int(v) for v in A.res.split("x")]
sc.render.resolution_x, sc.render.resolution_y = rx, ry; sc.render.resolution_percentage = A.pct
sc.view_settings.view_transform = 'AgX'; sc.view_settings.look = 'AgX - Medium High Contrast'
sc.render.image_settings.file_format = 'PNG'; sc.render.image_settings.color_depth = '8'
sc.render.threads_mode = 'FIXED'; sc.render.threads = 7

cam_d = bpy.data.cameras.new("Cam"); cam = bpy.data.objects.new("Cam", cam_d); sc.collection.objects.link(cam); sc.camera = cam
def camara(loc, mira, lente=50, orto=None, dof=None):
    cam.location = Vector(loc)
    dv = Vector(mira) - Vector(loc)
    if abs(dv.x) < 1e-3 and abs(dv.y) < 0.02 and dv.z < 0: cam.rotation_euler = (0, 0, 0)   # cenital: frente abajo, izquierda a la izquierda
    else: cam.rotation_euler = dv.to_track_quat('-Z', 'Y').to_euler()
    cam_d.type = 'ORTHO' if orto else 'PERSP'
    if orto: cam_d.ortho_scale = orto
    cam_d.lens = lente; cam_d.sensor_width = 36; cam_d.clip_start = 0.01; cam_d.clip_end = 20
    cam_d.dof.use_dof = dof is not None
    if dof: cam_d.dof.focus_distance = (Vector(mira) - Vector(loc)).length; cam_d.dof.aperture_fstop = dof

E = P["expl"]*MM
def offsets_explosion():
    zc = Vector((0, 0, 2.3*E))
    return {"carcasa": zc, "monitor": zc + NRM*1.1*E, "bisel": zc + NRM*2.0*E, "mandos": zc + NRM*0.9*E,
            "base": Vector(), "bandeja": Vector((0, 0, -0.9*E)), "sop_ard": Vector((0, 0, -0.3*E)),
            "sop_disco": Vector((0, 0, 0.3*E)), "guias": Vector((0, -1.4*E, 0.15*E)), "comp": Vector((0, 0, 0.6*E)),
            "pies": Vector((0, 0, -0.4*E)), "reserva": Vector((0, 0, 0.6*E))}
BASE_LOC = {o.name: o.location.copy() for g in GRUPOS.values() for o in g}
def estado(explosion=False, ocultar=()):
    off = offsets_explosion()
    for g, objs in GRUPOS.items():
        for o in objs:
            o.location = BASE_LOC[o.name] + (off.get(g, Vector()) if explosion else Vector())
            oc = g in ocultar
            o.hide_render = oc; o.hide_viewport = oc

C = (0.228, 0.150, 0.075)
VISTAS = {
    "hero":        dict(cam=((-0.42, -0.86, 0.60), (0.235, 0.135, 0.06), 58), ocultar=("reserva",)),
    "lateral":     dict(cam=((-1.9, 0.15, 0.11), (0.228, 0.15, 0.075), 115), ocultar=("reserva",), cove=True),
    "trasera":     dict(cam=((-0.30, 0.90, 0.34), (0.17, 0.22, 0.06), 50), ocultar=("reserva",)),
    "explosionado":dict(cam=((-0.70, -1.22, 0.88), (0.228, 0.14, 0.15), 46), ocultar=("reserva",), explosion=True),
    "interior":    dict(cam=((0.228, 0.165, 1.25), (0.228, 0.164, 0.0), 50), ocultar=("carcasa", "monitor", "bisel", "mandos")),
    "detalle":     dict(cam=((0.62, -0.20, 0.40), (0.415, 0.10, 0.10), 85), ocultar=("reserva",), dof=4.0),
}
# Puntos para las etiquetas de la vista interior (mm, mundo)
ANCLAS = {
    "Placa del HP (mini-ITX 17 × 17 cm)": (P["hp_x"] + 22, P["hp_y"] + 120, P["hp_pcb_z"] + 2),
    "Disipador + ventilador (35 mm)": (P["hp_x"] + 94, P["hp_y"] + 93, P["hp_pcb_z"] + 36),
    "RAM DDR3L (2 módulos)": (P["hp_x"] + 60, P["hp_y"] + 37, P["hp_pcb_z"] + 34),
    "I/O trasero del HP": (P["hp_x"] + 60, P["hp_y"] + 168, P["hp_pcb_z"] + 30),
    "Disco Toshiba 3,5\"": (P["disco_x"] + 50, P["disco_y"] + 70, P["disco_z"] + 25),
    "Raspberry Pi 4": (P["pi_x"] + 30, P["pi_y"] + 28, P["pi_z"] + 4),
    "Capturadora HDMI→USB (hueco)": (P["cap_x"] + 40, P["cap_y"] + 15, P["cap_z"] + 18),
    "Arduino Micro": (P["ard_x0"] + 9, P["ard_y"] + 24, P["ard_pcb_z"] + 3),
    "Tira LED ámbar": (P["W"]*0.5, 6, 9),
    "Potenciómetros (2) y botones (2)": (P["pod_cx"], 120, 70),
}
for nombre in A.vistas.split(","):
    v = VISTAS[nombre]
    for l in LUCES: l.hide_render = bool(v.get("cove")) and l.name == "Relleno"   # su disco cortaría el fondo curvo
    estado(v.get("explosion", False), tuple(v.get("ocultar", ())) + (() if v.get("cove") else ("cove",)))
    loc, mira, lente = v["cam"]; camara(loc, mira, lente, dof=v.get("dof"))
    sc.render.filepath = os.path.join(A.out, nombre + ".png")
    bpy.ops.render.render(write_still=True)
    if nombre == "interior":
        d = {}
        for k, p in ANCLAS.items():
            co = world_to_camera_view(sc, cam, Vector(p)*MM); d[k] = [co.x, 1 - co.y]
        json.dump(d, open(os.path.join(A.out, "anclas_interior.json"), "w"), ensure_ascii=False, indent=1)
    print("RENDER_OK", nombre)
