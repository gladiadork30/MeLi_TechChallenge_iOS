#!/usr/bin/env python3
"""
Genera products.json para el mock de Proxyman.

Escribe `products.json` en el mismo directorio que este script.

Reglas (specs/spec.md §9 + tasks.md T-140):
- 100+ productos.
- Cada producto: 0..20 reviews, rating ∈ 1..5.
- Strings en español.
- Mix intencional para cubrir boundaries:
    · ≥ 1 producto con 0 reviews (RF-03 unrated, RF-05 botón oculto)
    · ≥ 1 producto con 5 reviews (boundary inferior, botón disabled)
    · ≥ 1 producto con 6 reviews (boundary habilitación)
    · ≥ 1 producto con 20 reviews (boundary superior)
    · Distribución variada en el medio.

Determinista (seed fijo) para que el JSON sea estable entre commits.
"""
from __future__ import annotations
import json
import random
from pathlib import Path

RNG_SEED = 20260507

PRODUCT_TITLES = [
    "Auriculares Bluetooth XS-200", "Smartwatch Pulse Pro", "Cámara Compacta UltraZoom",
    "Mochila urbana 25L", "Termo de acero inoxidable 1L", "Mouse inalámbrico ergonómico",
    "Teclado mecánico retroiluminado", "Soporte ergonómico para notebook",
    "Lámpara de escritorio LED", "Botella deportiva con sorbete", "Parlante portátil resistente al agua",
    "Cargador rápido USB-C 65W", "Hub USB-C 7-en-1", "Cable HDMI 4K 2m",
    "Adaptador de viaje universal", "Funda silicona para celular", "Vidrio templado pantalla",
    "Powerbank 20000mAh", "Auriculares con cancelación de ruido", "Smart TV 50 pulgadas 4K",
    "Tablet 10 pulgadas Wi-Fi", "Lector de e-books", "Disco externo SSD 1TB",
    "Pen drive 128GB USB 3.2", "Memoria microSD 256GB", "Router Wi-Fi 6 doble banda",
    "Repetidor Wi-Fi mesh", "Webcam Full HD con micrófono", "Aro de luz para streaming",
    "Trípode flexible para celular", "Estabilizador gimbal de mano", "Drone con cámara 4K",
    "Patines en línea adultos", "Skate completo doble curva", "Pelota de fútbol talla 5",
    "Mancuernas ajustables 20kg", "Banda elástica de resistencia", "Colchoneta de yoga antideslizante",
    "Botiquín portátil de viaje", "Cuchillo multiusos plegable", "Set de herramientas 32 piezas",
    "Taladro inalámbrico 18V", "Pistola de calor 2000W", "Manguera extensible de jardín",
    "Aspersor giratorio para riego", "Cortacésped eléctrico 1600W", "Sopladora de hojas a batería",
    "Hidrolavadora 1800W", "Aspiradora robot inteligente", "Aspiradora de mano sin cable",
    "Plancha de pelo iónica", "Secador de pelo 2200W", "Afeitadora eléctrica 4 cabezales",
    "Cepillo dental eléctrico recargable", "Báscula corporal Bluetooth", "Tensiómetro digital de brazo",
    "Termómetro infrarrojo sin contacto", "Humidificador ultrasónico 3L", "Difusor de aceites esenciales",
    "Cafetera de cápsulas automática", "Cafetera moka italiana 6 tazas", "Tetera eléctrica 1.7L",
    "Tostadora 4 ranuras", "Microondas 25L digital", "Horno eléctrico 36L",
    "Freidora de aire XL 6L", "Licuadora de vaso 1.5L 1000W", "Procesador de alimentos multifunción",
    "Batidora de mano 800W", "Olla a presión eléctrica 6L", "Sartén antiadherente 28cm",
    "Set de cuchillos 6 piezas", "Tabla de picar de bambú", "Vajilla 16 piezas porcelana",
    "Set de copas de vino cristal", "Cubiertos de acero inox 24 pzs", "Recipientes herméticos x10",
    "Reloj despertador digital", "Reloj pared minimalista", "Lámpara de pie LED regulable",
    "Cuadro decorativo abstracto", "Espejo de pared circular", "Estantería modular 5 niveles",
    "Mesa auxiliar plegable", "Silla de oficina ergonómica", "Sillón puff impermeable",
    "Almohada viscoelástica memoria", "Sábanas king size 100% algodón", "Manta polar tamaño matrimonial",
    "Toallón de baño 90x150 cm", "Cortinas blackout 2 paños", "Alfombra antideslizante baño",
    "Cesto de ropa plegable", "Plancha de ropa con vapor 2400W", "Mesa de planchar con perchero",
    "Aspirador de polvo a batería", "Trapeador con balde escurridor", "Set de limpieza microfibra",
    "Bolsa hermética para viaje", "Maleta cabina rígida 4 ruedas", "Riñonera deportiva impermeable",
    "Cartera de cuero unisex", "Gorra ajustable algodón", "Anteojos de sol polarizados",
    "Reloj deportivo con GPS", "Pulsera de actividad inteligente", "Auriculares deportivos in-ear",
    "Bicicleta plegable urbana", "Casco para bici certificado", "Luz LED recargable para bici",
    "Candado bicicleta nivel 9", "Bomba de aire portátil", "Mochila hidratación trail 6L",
    "Termo café para auto 500ml", "Cargador inalámbrico para auto", "Soporte celular auto magnético",
    "Cubierta para auto impermeable", "Aspiradora portátil 12V auto", "Kit de emergencia para auto",
    "Linterna táctica recargable", "Carpa para 4 personas impermeable", "Bolsa de dormir -5°C",
    "Aislante térmico inflable", "Cocina de camping a gas", "Set de utensilios camping",
    "Hamaca paraguaya doble", "Silla plegable para camping",
]

ACCESSORY_HINTS = [
    "auriculares", "reloj", "cámara", "mochila", "termo", "mouse", "teclado", "soporte",
    "lámpara", "botella", "parlante", "cargador", "hub", "cable", "adaptador", "funda",
    "vidrio", "powerbank", "tv", "tablet", "lector", "disco", "memoria", "router",
    "repetidor", "webcam", "trípode", "drone", "patines", "skate", "pelota", "mancuernas",
    "banda", "colchoneta", "botiquín", "cuchillo", "herramientas", "taladro", "pistola",
    "manguera", "aspersor", "cortacésped", "sopladora", "hidrolavadora", "aspiradora",
    "plancha", "secador", "afeitadora", "cepillo", "báscula", "tensiómetro", "termómetro",
    "humidificador", "difusor", "cafetera", "tetera", "tostadora", "microondas", "horno",
    "freidora", "licuadora", "procesador", "batidora", "olla", "sartén", "cuchillos",
    "tabla", "vajilla", "copas", "cubiertos", "recipientes", "reloj", "lámpara", "cuadro",
    "espejo", "estantería", "mesa", "silla", "sillón", "almohada", "sábanas", "manta",
    "toallón", "cortinas", "alfombra", "cesto", "trapeador", "bolsa", "maleta", "riñonera",
    "cartera", "gorra", "anteojos", "pulsera", "bicicleta", "casco", "candado", "linterna",
    "carpa", "hamaca",
]

POSITIVE_PHRASES = [
    "Excelente calidad, lo recomiendo sin dudar.",
    "Cumple con todo lo prometido y más.",
    "Muy buena relación calidad-precio.",
    "Llegó antes de lo esperado y funciona perfecto.",
    "Lo uso todos los días, súper práctico.",
    "El acabado es impecable, se siente premium.",
    "Material de primera, se nota la diferencia.",
    "Funciona tal como dice la descripción.",
    "Estoy muy contento con la compra.",
    "Re cómodo, ideal para uso diario.",
    "Buena duración de batería para el tamaño.",
    "Sonido nítido, sin distorsión.",
    "Diseño elegante y compacto.",
    "Súper fácil de usar y configurar.",
    "Perfecto para regalar.",
    "Mucho mejor que otras marcas que probé.",
    "Resistente y bien construido.",
    "Liviano y fácil de transportar.",
    "Muy buena terminación, sin defectos.",
    "Excelente atención post-venta también.",
]

NEGATIVE_PHRASES = [
    "La batería dura menos de lo esperado.",
    "El plástico se siente un poco endeble.",
    "Tarda demasiado en cargar.",
    "El manual viene en inglés solamente.",
    "El cable es más corto de lo que muestra la foto.",
    "Hace ruido cuando se usa a máxima potencia.",
    "El botón se traba a veces.",
    "Llegó con un raspón en la caja.",
    "La aplicación móvil es lenta y poco intuitiva.",
    "Por el precio esperaba mejor calidad de imagen.",
    "Se calienta más de la cuenta.",
    "El diseño no es tan moderno como en las fotos.",
    "Los accesorios incluidos son básicos.",
    "El soporte no fija bien al escritorio.",
    "Pesa más de lo que pensaba.",
]

NEUTRAL_PHRASES = [
    "Cumple su función básica.",
    "Está bien por el precio.",
    "Nada destacable, pero tampoco fallas graves.",
    "Es lo que se ve, ni más ni menos.",
    "Lo recomendaría con reservas.",
    "Funciona ok, no es lo mejor del mercado.",
    "Para el uso ocasional cumple.",
]

AUTHORS = [
    "Juan", "Ana", "Pedro", "María", "Lucía", "Diego", "Sofía", "Martín", "Camila",
    "Federico", "Valentina", "Tomás", "Florencia", "Bruno", "Agustina", "Nicolás",
    "Julieta", "Mateo", "Catalina", "Ignacio", "Renata", "Lautaro", "Mía", "Joaquín",
    "Emma", "Benjamín", "Olivia", "Santino", "Isabella", "Felipe",
]

def make_review(rng: random.Random) -> dict:
    """Genera una review con sentimiento correlacionado al rating."""
    rating = rng.choices([1, 2, 3, 4, 5], weights=[5, 10, 20, 35, 30])[0]
    if rating >= 4:
        text = rng.choice(POSITIVE_PHRASES)
        if rng.random() < 0.3:
            text = text + " " + rng.choice(NEGATIVE_PHRASES)
    elif rating == 3:
        text = rng.choice(NEUTRAL_PHRASES)
    else:
        text = rng.choice(NEGATIVE_PHRASES)
    return {
        "author": rng.choice(AUTHORS),
        "rating": rating,
        "text": text,
    }


def review_count_for_index(idx: int, rng: random.Random) -> int:
    """Distribución intencional para cubrir boundaries."""
    # Boundaries explícitos al inicio del catálogo (fáciles de testear).
    boundary_map = {
        0: 0,    # sin reviews → unrated, sin botón
        1: 5,    # boundary disabled
        2: 6,    # boundary habilitado
        3: 20,   # tope superior
    }
    if idx in boundary_map:
        return boundary_map[idx]
    # Resto: distribución plausible 0..20.
    return rng.choices(
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 15, 18, 20],
        weights=[2, 3, 4, 5, 6, 6, 8, 8, 10, 12, 12, 10, 8, 6],
    )[0]


def main() -> None:
    rng = random.Random(RNG_SEED)
    titles = list(PRODUCT_TITLES)
    rng.shuffle(titles)
    titles = titles[:120]  # 120 productos cubre el ≥ 100 con margen

    products = []
    for idx, title in enumerate(titles):
        pid = f"p_{idx + 1:03d}"
        # Imagen mock servida por el mismo Proxyman (evita HTTP a hosts no-localhost).
        image_url = f"http://localhost:9090/images/{pid}.jpg"
        review_count = review_count_for_index(idx, rng)
        reviews = [make_review(rng) for _ in range(review_count)]
        products.append({
            "id": pid,
            "title": title,
            "imageUrl": image_url,
            "reviews": reviews,
        })

    out_path = Path(__file__).parent / "products.json"
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(products, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(products)} products to {out_path}")


if __name__ == "__main__":
    main()
