"""Gera o PNG da logo da Glicare (gota + check) para o splash nativo.

Renderiza em alta resolução com supersampling e reduz com LANCZOS para
bordas suaves. A gota é branca e o check é verde-água claro, pensados para
ficar sobre o fundo azul (#005F9C) do splash.
"""
import math
import os

from PIL import Image, ImageDraw

# Cores (alinhadas ao AppColors / GlicareLoading onPrimary)
WHITE = (255, 255, 255, 255)
TEAL = (0x78, 0xF7, 0xE9, 255)  # secondaryContainer

FINAL = 1152          # tamanho final recomendado p/ Android 12
SS = 4                # supersampling
W = FINAL * SS

img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

cx = W / 2
# Gota: círculo na base + ápice apontando pra cima (tangentes ao círculo).
r = W * 0.155
cy = W * 0.545               # centro do círculo, um pouco abaixo do meio
apex_y = cy - 2.7 * r        # ponta superior
dist = cy - apex_y           # distância ápice -> centro
beta = math.acos(r / dist)   # ângulo entre eixo e ponto de tangência

# Direção do centro para o ápice = (0, -1). Rotaciona ±beta p/ achar tangências.
def rot(vx, vy, ang):
    return (vx * math.cos(ang) - vy * math.sin(ang),
            vx * math.sin(ang) + vy * math.cos(ang))

ux, uy = 0.0, -1.0
t1 = rot(ux, uy, beta)
t2 = rot(ux, uy, -beta)
T1 = (cx + r * t1[0], cy + r * t1[1])
T2 = (cx + r * t2[0], cy + r * t2[1])

a1 = math.atan2(T1[1] - cy, T1[0] - cx)
a2 = math.atan2(T2[1] - cy, T2[0] - cx)

# Arco maior passando pela base (parte de baixo do círculo).
pts = [(cx, apex_y)]
steps = 220
# Varre de a1 até a2 pelo caminho de baixo (somando ângulo).
if a2 < a1:
    a2 += 2 * math.pi
for i in range(steps + 1):
    ang = a1 + (a2 - a1) * i / steps
    pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
d.polygon(pts, fill=WHITE)

# Check verde-água, posicionado na metade inferior da gota.
lw = int(W * 0.038)
chk_cx = cx
chk_cy = cy + r * 0.18
s = r * 0.62
p_a = (chk_cx - s * 0.55, chk_cy + s * 0.02)
p_b = (chk_cx - s * 0.12, chk_cy + s * 0.42)
p_c = (chk_cx + s * 0.62, chk_cy - s * 0.42)
d.line([p_a, p_b, p_c], fill=TEAL, width=lw, joint="curve")
# Arredonda as pontas do check.
for p in (p_a, p_c):
    d.ellipse([p[0] - lw / 2, p[1] - lw / 2, p[0] + lw / 2, p[1] + lw / 2], fill=TEAL)

out = Image.alpha_composite(Image.new("RGBA", (W, W), (0, 0, 0, 0)), img)
out = out.resize((FINAL, FINAL), Image.LANCZOS)

os.makedirs("assets/splash", exist_ok=True)
out.save("assets/splash/glicare_logo.png")
print("OK -> assets/splash/glicare_logo.png")

# Variante Android 12: o sistema recorta o ícone num círculo, então a gota
# precisa caber numa área central menor (com folga nas bordas).
pad = Image.new("RGBA", (FINAL, FINAL), (0, 0, 0, 0))
scaled = out.resize((int(FINAL * 0.56), int(FINAL * 0.56)), Image.LANCZOS)
off = (FINAL - scaled.width) // 2
pad.paste(scaled, (off, off), scaled)
pad.save("assets/splash/glicare_logo_android12.png")
print("OK -> assets/splash/glicare_logo_android12.png")
