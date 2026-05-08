# Plan de QA manual — Fase 14

Procedimiento para verificar los criterios de aceptación que requieren un humano frente a un device/simulador con Proxyman corriendo.

Las tareas T-140 (mock JSON) y la documentación de los pasos manuales (T-141..T-147) están en este directorio. Las verificaciones reales (capturas, checklists tildados) se realizan al ejecutar la fase.

---

## T-140 — Mock JSON ✅ generado (v1.1: imágenes Picsum + URL rota)

`products.json` (120 productos) generado por `generate_products.py` con seed determinista. Cubre boundaries:

| Caso | Cantidad de productos |
|---|---|
| 0 reviews (RF-03 unrated) | 2 |
| 5 reviews (CA-RF-05 disabled) | 5 |
| 6 reviews (CA-RF-05 habilitado) | 5 |
| 20 reviews (tope superior) | 14 |
| `> 5` reviews totales | 93 |

**Imágenes (RF-17 v1.1)**:
- 119 productos con `imageUrl` → `https://picsum.photos/seed/{id}/400/400` (HTTPS, seed determinista por id).
- **1 producto deliberadamente con URL rota: `p_008`** → `https://picsum.photos/notfound/p_008`. Se usa para validar el fallback en T-148 (la celda debe mostrar placeholder y mantener el resto del contenido visible — `p_008` tiene 7 reviews, así que también verifica que el botón "Generar resumen" sigue habilitable).
- 0 imágenes con HTTP (todas HTTPS, sin tocar ATS — RNF-03 + RF-17).

Para regenerar con otro seed o agregar productos: editar `RNG_SEED` o `PRODUCT_TITLES` y correr `python3 generate_products.py`.

---

## T-141 — Configurar Proxyman

1. Instalar Proxyman: <https://proxyman.com>.
2. Tools → Local Mock Server → New Mock Server.
3. Crear ruta: `GET /products` → Response Body → seleccionar `products.json` (este directorio).
4. Configurar puerto en `9090` (matchea `Config/Debug.xcconfig` `BACKEND_BASE_URL = http://localhost:9090`).
5. Iniciar el mock server.

**Verificación**:
```bash
curl http://localhost:9090/products | python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
# Debe imprimir 120.
```

> **Imágenes (RF-17 v1.1)**: las `imageUrl` apuntan a Picsum (`https://picsum.photos/seed/...`), un repositorio público externo HTTPS. **El mock NO sirve binarios de imágenes** — solo provee URLs como strings. La app descarga las imágenes directamente contra Picsum. Para Proxyman alcanza con la regla `GET /products`. Si querés inspeccionar el tráfico de imágenes (T-144), agregá `picsum.photos` a la lista de hosts capturados — son GETs HTTPS anónimos sin PII.

---

## T-142 — Smoke E2E manual: Lista (CA-RF-02, CA-RF-03, CA-RF-13, CA-RF-14, CA-RF-16)

**Pre**: Proxyman corriendo, app instalada en simulador.

| Paso | Esperado | ✓ |
|---|---|---|
| 1. Lanzar la app | Estado `loading` → `success` con 120 productos visibles |  |
| 2. Scrollear la lista | Sin frame drops, scroll fluido |  |
| 3. Producto sin reviews (`p_001`) | Celda muestra "Sin calificación", sin badge sparkles |  |
| 4. Producto con reviews | Rating con 1 decimal (ej. "4.0"), "%lld reseñas" |  |
| 5. Pull-to-refresh | Spinner aparece, lista se vuelve a renderizar |  |
| 6. Detener Proxyman | (siguiente paso) |  |
| 7. Pull-to-refresh con mock caído | Banner overlay "No se pudo actualizar..." aparece, lista anterior se mantiene |  |
| 8. Volver a iniciar Proxyman, pull-to-refresh | Banner desaparece, lista actualiza |  |
| 9. Cerrar app, detener Proxyman, relanzar | Estado `error` con CTA "Reintentar". Reiniciar Proxyman + tap Reintentar → carga OK |  |

---

## T-143 — Smoke manual: generación de resumen (CA-RF-06, CA-RF-08, CA-RF-09)

**Pre**: device físico con Apple Intelligence habilitado (Foundation Models on-device requiere hardware/SO compatible). En simulador puede no estar disponible — caer a T-145 si es el caso.

| Paso | Esperado | ✓ |
|---|---|---|
| 1. Tap en producto con > 5 reviews (ej. `p_004`, 20 reviews) | Navega al detalle. Botón "Generar resumen" visible y habilitado |  |
| 2. Tap "Generar resumen" | Botón muestra spinner + "Generando resumen…", botón disabled |  |
| 3. Esperar resultado | Aparece bloque con 4 secciones: sentimiento (con icono coloreado), tagline cursiva, "Puntos fuertes", "Puntos débiles". Botón cambia a "Regenerar" |  |
| 4. Volver a la lista | Celda del producto ahora tiene icono `sparkles` (RF-10) |  |
| 5. Volver al detalle | Resumen aparece de inmediato sin reprocesar (RF-08) |  |
| 6. Kill app + relanzar + abrir mismo detalle | Resumen persiste tras relaunch (CA-RF-08) |  |
| 7. Tap "Regenerar" | Spinner → nuevo resumen reemplaza el anterior (no acumula) |  |
| 8. Activar modo avión (sin red), tap "Regenerar" | Genera resumen sin red (la inferencia es 100% on-device, RF-06) |  |

---

## T-144 — Verificación de privacidad con Proxyman (RNF-02, CA-RF-06)

**Pre**: Proxyman en modo "Capture" (proxy SSL configurado en simulador/device).

| Paso | Esperado | ✓ |
|---|---|---|
| 1. Limpiar el log de Proxyman | — |  |
| 2. Disparar "Generar resumen" en el detalle | — |  |
| 3. Inspeccionar tráfico durante la inferencia | **0 requests salientes** mientras el botón muestra "Generando…". Solo aparece el `GET /products` del bootstrap. Adjuntar captura limpia |  |

> Si aparece tráfico hacia `*.apple.com` durante la generación, se trata de telemetría/diagnóstico de Apple, NO de los datos del producto. Verificar el body de la request: nunca debe contener reviews del producto.

---

## T-145 — Fallback de AI (CA-RF-12)

**Pre**: device sin soporte (ej. modelo viejo), o simulador donde Foundation Models no está disponible, **o** Apple Intelligence apagado en Settings.

| Paso | Esperado | ✓ |
|---|---|---|
| 1. Abrir detalle de cualquier producto con > 5 reviews | Botón "Generar resumen" disabled |  |
| 2. Mensaje informativo bajo el botón | "Resumen AI no disponible en este dispositivo." |  |
| 3. Resto de la app | Lista, navegación, scroll de reviews funcionan normalmente |  |

---

## T-146 — Cancelación (CA-RF-15, RF-11, RF-15)

**Pre**: device con AI disponible.

| Paso | Esperado | ✓ |
|---|---|---|
| 1. Tap "Generar resumen" en producto con muchas reviews | Comienza generación (botón "Generando…") |  |
| 2. Tap atrás antes de que termine | Vuelve a la lista; sin crash |  |
| 3. Volver al mismo producto | Estado debe ser `.none` (no hay resumen persistido — el upsert NO se llamó) |  |
| 4. Generar de nuevo y, mientras genera, kill -9 la app desde el switcher | App muere; al relanzar el producto sigue sin resumen (no hubo escritura post-cancel) |  |
| 5. Logs `os.Logger.ai` | Inspeccionar Console.app filtrando subsystem `com.jpromero.ReviewSummarizer` y categoría `ai`: NO aparece `upsert` tras cancellation |  |

---

## T-148 — Fallback de imagen (RF-17 / CA-RF-02 v1.1) `[NUEVA v1.1]`

**Pre**: app instalada, lista cargada con 120 productos.

| Escenario | Esperado | ✓ |
|---|---|---|
| 1. Encontrar el producto `p_008` (URL rota sembrada en T-140) en la lista | Celda muestra placeholder de imagen (icono `photo`), pero título, rating, conteo de reviews y, si aplica, indicador de resumen, se ven correctos |  |
| 2. Tap en `p_008` | Header del detalle muestra placeholder de imagen (más grande), el resto del detalle renderiza normal. Botón "Generar resumen" disponible (`p_008` tiene 7 reviews) |  |
| 3. **Sin conectividad a Picsum**: tras cargar la lista, deshabilitar red en simulador (Hardware → Network Link Conditioner = 100% Loss) o bloquear `picsum.photos` en Proxyman | Celdas ya cacheadas siguen mostrando imagen; celdas nuevas (al scrollear) muestran placeholder. La app no muestra estado de error global ni crashea |  |

**Capturas**: adjuntar screenshot de cada escenario.

---

## T-147 — Cambio de URL base (CA-RF-01)

**Vía xcconfig** (relanzar app):
1. Editar `Config/Debug.xcconfig` → `BACKEND_BASE_URL = http:/$()/localhost:9091`.
2. Cerrar app, relanzar desde Xcode (Cmd+R).
3. Verificar que la lista falla con `error` (puerto inexistente).
4. Restaurar a `9090` y relanzar.

**Vía launch argument** (override por env, útil para tests):
1. Xcode → Edit Scheme → Run → Arguments → Environment Variables → `BACKEND_BASE_URL = http://localhost:9091`.
2. Cmd+R. Misma verificación.
3. Quitar la env var.

| Paso | Esperado | ✓ |
|---|---|---|
| 1. xcconfig con puerto inexistente | App carga con `.error` |  |
| 2. xcconfig vuelto a `9090` | App carga lista OK |  |
| 3. Env var override en Scheme | App pega al puerto del env var |  |
| 4. Quitar env var | App vuelve a usar el del xcconfig |  |

---

## Verificación final

Marcar este checklist al final de la fase:

- [ ] T-141: Proxyman corriendo, `curl /products` devuelve 120 productos
- [ ] T-142: Smoke E2E lista — todos los pasos verdes
- [ ] T-143: Smoke E2E generación — todos los pasos verdes (en device físico)
- [ ] T-144: Captura de Proxyman sin tráfico de reviews durante inferencia
- [ ] T-145: Captura del fallback con copy correcto
- [ ] T-146: Logs `os.Logger.ai` sin upsert post-cancellation
- [ ] T-147: xcconfig + launch argument funcionan independientemente
- [ ] T-148: 3 capturas de fallback de imagen (URL rota, sin red, detalle con placeholder)
