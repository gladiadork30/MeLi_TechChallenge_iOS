# Especificación Funcional — AI Review Summarizer

**Versión:** 1.2
**Fecha:** 2026-05-06
**Estado:** Aprobado — preguntas abiertas resueltas por PL/PO; ajuste de origen de imágenes incorporado durante implementación
**Fuente:** Challenge Técnico — AI Review Summarizer (PDF adjunto)
**Cambios v1.2:** añadido **RF-17** (origen de imágenes desde repositorio público externo). Actualizados S-13 y RNF-02. Añadida subsección §10.2 con la decisión y su justificación.
**Cambios v1.1:** resoluciones de PL aplicadas a S-01, S-02, S-04, S-05, S-06, S-14, S-15. Añadido RNF-12 (límites del modelo). Actualizados RNF-06 y RN-09. Reestructurada §10 como "Resoluciones de PL/PO".

---

## 1. Objetivo del Sistema

Construir una aplicación iOS nativa para un marketplace que permita a los usuarios consultar productos con sus reviews y obtener un **resumen inteligente de las opiniones generado mediante AI on-device**, sin envío de datos a servicios cloud, garantizando privacidad y latencia local.

El sistema debe:

- Listar productos con metadatos relevantes (imagen, título, rating promedio, cantidad de reviews).
- Generar bajo demanda un resumen estructurado de las reviews de un producto cuando este supere un umbral mínimo de opiniones.
- Persistir los resúmenes generados para evitar reprocesamiento, ofreciendo regeneración explícita.
- Funcionar contra un backend mockeado en localhost (Proxyman) con base URL configurable.

### 1.1 Métricas de éxito (MVP)

- Tiempo a primer render de la lista < 1.5 s con 100 productos en localhost.
- Tasa de éxito de generación de resúmenes en dispositivos compatibles ≥ 95 %.
- 0 datos de reviews enviados fuera del dispositivo (verificable con Proxyman).

### 1.2 Fuera de alcance (MVP)

- Autenticación de usuario.
- Compra, checkout, carrito, wishlist.
- Sincronización de resúmenes entre dispositivos.
- Edición o creación de reviews por parte del usuario.
- Push notifications.
- Internacionalización completa (más allá del español, idioma único del MVP).
- Búsqueda, filtros u ordenamiento.

### 1.3 Actores

- **Usuario final:** navega productos y solicita resúmenes.
- **Sistema AI on-device:** motor de generación de texto que opera localmente.
- **Servidor mock:** API REST local que sirve el catálogo y las reviews.

---

## 2. Requisitos Funcionales

### RF-01 — Configuración de URL base
La URL base del backend mock debe ser configurable sin recompilar la app, mediante un mecanismo de configuración (ej. build setting, archivo de configuración o argumento de lanzamiento). Solo se permite HTTP cuando el host es `localhost`.

### RF-02 — Listado de productos
Al iniciar, la app consume el endpoint de productos y muestra la lista con: imagen miniatura, título, cantidad de reviews y rating promedio (1 decimal).

### RF-03 — Cálculo de rating promedio
El rating promedio se calcula como media aritmética de los ratings de todas las reviews del producto. Si el producto no tiene reviews, no se muestra valor numérico; en su lugar se indica explícitamente "Sin calificación".

### RF-04 — Visualización de detalle de producto
El usuario puede abrir el detalle de un producto desde la lista. El detalle muestra: imagen, título, rating promedio, cantidad total de reviews, lista completa de reviews (autor, rating, texto) y, cuando aplique, el resumen AI.

> Confirmado por PL: el detalle se implementa como **pantalla separada** (ver S-01).

### RF-05 — Habilitación del botón de generación
El botón de generación de resumen está disponible **únicamente cuando el producto tiene más de 5 reviews** (es decir, ≥ 6). Para productos con 5 reviews o menos, el botón no es invocable y la UI comunica visualmente la razón.

### RF-06 — Generación de resumen AI on-device
Al accionar el botón, el sistema genera un resumen estructurado a partir del conjunto de reviews del producto, ejecutado **íntegramente en el dispositivo**, sin tránsito de datos a servicios externos.

### RF-07 — Estructura del resumen
El resumen contiene cuatro secciones claramente diferenciadas:

1. **Sentimiento general** (positivo / neutral / negativo, con grado o descripción breve).
2. **Puntos fuertes** (lista de aspectos positivos recurrentes).
3. **Puntos débiles** (lista de aspectos negativos recurrentes).
4. **Frase resumen** (una sola línea, ≤ 140 caracteres).

### RF-08 — Persistencia de resúmenes
Cada resumen generado se persiste localmente, asociado al `id` del producto. Al volver a abrir el producto, el resumen previamente generado se muestra sin reprocesamiento.

### RF-09 — Regeneración de resumen
El sistema ofrece una opción explícita para regenerar el resumen del producto. La regeneración **reemplaza** el resumen previamente persistido (no acumula).

### RF-10 — Indicador de "resumen disponible"
La UI indica visualmente cuándo un producto ya tiene un resumen previamente generado, para que el usuario distinga el contenido cacheado.

### RF-11 — Estado de generación
Durante la generación, el sistema presenta un estado de progreso (loading) y permite que el usuario abandone la pantalla sin dejar el motor en estado inconsistente. La tarea se cancela correctamente al salir.

### RF-12 — Fallback cuando AI no está disponible
Si el dispositivo no soporta AI on-device (modelo no disponible, hardware no compatible, modelo no descargado, etc.), la app:

- Deshabilita el botón de generación con un mensaje informativo claro.
- No bloquea ni degrada el resto de la funcionalidad (lista, detalle, reviews).

### RF-13 — Manejo de errores de red
Ante errores al consumir el listado, la app muestra un estado de error con opción de reintento, sin crashear ni dejar la UI en blanco.

### RF-14 — Estados de la UI
Cada pantalla contempla los estados: `loading`, `success`, `empty`, `error`.

### RF-15 — Cancelación de tareas
Toda tarea de red y toda generación AI debe cancelarse correctamente al abandonar la pantalla asociada o al cerrar la app.

### RF-16 — Pull-to-refresh en lista
La lista de productos soporta refresco manual (pull-to-refresh) para volver a consultar el endpoint.

### RF-17 — Origen de las imágenes de productos
Las imágenes referenciadas en el catálogo se obtienen desde un **repositorio público externo vía HTTPS** (referencia: Picsum, `https://picsum.photos`). El backend mock **no aloja imágenes binarias**: solo provee las URLs en la respuesta del endpoint. La descarga la realiza la app directamente contra el repositorio externo. Si una URL falla (404, timeout, ATS rechazo, sin conectividad), la celda muestra un placeholder y no rompe el render del resto de la lista.

---

## 3. Requisitos No Funcionales

### RNF-01 — Plataforma
iOS 26+ (mínimo soportado por Foundation Models Framework). Swift 6 con concurrencia estricta.

### RNF-02 — Privacidad
- Ningún dato textual de productos, reviews ni resúmenes generados por la app abandona el dispositivo. Toda la inferencia AI es on-device.
- Las imágenes de productos se obtienen vía GET HTTPS desde un repositorio público externo (ver **RF-17**). Estas requests son anónimas y no transportan PII, contenido de reviews ni resultados de la AI.

### RNF-03 — Seguridad
- HTTP solo permitido contra `localhost` (App Transport Security configurado en consecuencia).
- Sin API keys ni secretos hardcodeados.
- Sin almacenamiento de datos sensibles en texto plano (en este MVP no hay PII; aplica como regla preventiva).

### RNF-04 — Performance
- Render inicial de la lista < 1.5 s sobre localhost.
- Scroll fluido (sin frame drops perceptibles) con 100+ productos.
- Generación de resumen AI: tiempo objetivo bajo 10 s en dispositivos compatibles para 20 reviews; el tiempo concreto depende del modelo on-device.

### RNF-05 — Accesibilidad
- Soporte de Dynamic Type.
- VoiceOver: imágenes con etiquetas descriptivas, botones con `accessibilityLabel` significativo.
- Contraste cumpliendo WCAG AA.

### RNF-06 — Internacionalización
- Idioma único del MVP: **español**.
- Strings expuestos vía `Localizable.strings` para facilitar futura i18n.

### RNF-07 — Configurabilidad
La URL base se cambia sin recompilar el binario.

### RNF-08 — Mantenibilidad
- Capas separadas en carpetas (no módulos).
- Convenciones consistentes con Apple Swift API Design Guidelines.
- Cobertura mínima de unit tests en capa de dominio.

### RNF-09 — Resiliencia
- Cancelación correcta de tareas async ante navegación o cierre de pantallas.
- Sin leaks de tareas o de estado AI tras cancelación.

### RNF-10 — Compatibilidad de dispositivo
La app corre en cualquier iPhone con iOS 26+. La feature AI puede degradarse a "no disponible" en dispositivos donde el modelo no esté presente o soportado, sin romper el resto.

### RNF-11 — Observabilidad mínima
Logs locales (no remotos) para diagnóstico de errores de red y AI; nivel y categoría usables con `os.Logger`.

### RNF-12 — Límites del modelo on-device
La generación de resúmenes está acotada por la **capacidad de Apple Foundation Models** (context window y tamaño de salida). Producto no impone límites propios adicionales. Si el volumen total de reviews de un producto excede el contexto efectivo del modelo, el spec técnico define la estrategia de adaptación (ej. truncado, recorte por longitud o map-reduce) sin pérdida funcional sustantiva para el usuario.

---

## 4. Supuestos y Ambigüedades

> Tras la ronda de resoluciones del PL (v1.1), todos los supuestos quedan **confirmados**. Se mantiene el listado con sus IDs originales para preservar trazabilidad con el resto del documento y con el spec técnico.

### S-01 — Pantalla de detalle (confirmado por PL)
El detalle se implementa como **pantalla separada**. Aloja la lista completa de reviews, el botón de generar/regenerar resumen y la presentación del resumen mismo.

### S-02 — Idioma de los reviews y del resumen (confirmado por PL)
Tanto los reviews mock como el resumen generado se entregan en **español**. Es el idioma único del MVP. El sistema no traduce reviews ni soporta otros idiomas en esta versión.

### S-03 — Umbral del botón (resuelto)
El enunciado dice "más de 5 reviews": se interpreta como **estrictamente > 5** (mínimo 6). Se documenta para evitar ambigüedad off-by-one.

### S-04 — Invalidación del resumen (confirmado por PL)
El resumen persistido **no se invalida automáticamente** ante cambios en las reviews del producto. La actualización es responsabilidad explícita del usuario mediante el botón "Regenerar". Esto simplifica el modelo de datos y elimina la necesidad de hashear/comparar conjuntos de reviews entre cargas.

### S-05 — Cantidad de reviews enviadas al modelo (confirmado por PL)
Producto **no impone un límite propio**: la generación queda acotada a la **capacidad de Apple Foundation Models**. El intento por defecto es enviar todas las reviews del producto (máximo 20). Si el volumen excede el contexto efectivo del modelo, el spec técnico define la estrategia de adaptación. Ver **RNF-12**.

### S-06 — Paginación (confirmado por PL)
El endpoint devuelve los 100+ productos en una **sola respuesta**. **No hay paginación** ni lazy loading en el MVP.

### S-07 — Tecnología de persistencia (delegado al spec técnico)
Funcionalmente, el resumen debe sobrevivir al cierre de la app y a reinicios. La elección concreta se aborda en el spec técnico.

### S-08 — Pull-to-refresh y reintento (asumido)
La lista soporta pull-to-refresh. Errores de red exponen botón Reintentar.

### S-09 — Búsqueda / filtros / ordenamiento (fuera de alcance)
No requeridos por el PDF. No se implementan en MVP.

### S-10 — Compartir resumen (fuera de alcance)
No requerido. Si se sumara más adelante, sería trivial vía `ShareLink`.

### S-11 — Modo offline (parcial)
Tras una primera carga, los resúmenes ya generados son accesibles offline. La **lista** requiere conectividad al mock local.

### S-12 — Identificador de producto (asumido)
Se asume que el endpoint provee un `id` único y estable por producto. El resumen se persiste indexado por ese `id`.

### S-13 — Imágenes (confirmado durante implementación)
Las URLs de imagen apuntan a un **repositorio público externo** servido por **HTTPS** (referencia: Picsum). El mock local **no sirve binarios de imágenes**, solo provee las URLs. Si una URL falla por cualquier motivo (404, timeout, sin conectividad, rechazo ATS si fuera HTTP no-localhost), se muestra un placeholder. Ver **RF-17** y §10.2.

### S-14 — Indicador "resumen disponible" (confirmado por PL)
Producto **no define un patrón visual específico**. Queda a criterio del implementador resolverlo de forma discreta y consistente con el resto del diseño (badge, ícono, marca tipográfica u otro). El requisito es que el indicador sea perceptible sin saturar la celda.

### S-15 — Orden de reviews en el detalle (confirmado por PL)
Las reviews se muestran **en el orden en que las entrega el servicio**, sin reordenamiento por rating ni fecha en cliente.

---

## 5. Reglas de Negocio

| ID    | Regla                                                                                              |
|-------|----------------------------------------------------------------------------------------------------|
| RN-01 | El botón de generar resumen está habilitado **solo si** `reviews.count > 5` (es decir, ≥ 6).       |
| RN-02 | El resumen persistido se asocia a un único producto por `id`.                                      |
| RN-03 | La regeneración **reemplaza** el resumen anterior; no acumula versiones.                           |
| RN-04 | El rating promedio se calcula como media aritmética. Producto sin reviews → "Sin calificación".    |
| RN-05 | Si AI no está disponible, el botón se deshabilita con mensaje informativo.                         |
| RN-06 | Toda llamada de red se cancela al abandonar la pantalla.                                           |
| RN-07 | Toda generación AI se cancela si el usuario sale del detalle.                                      |
| RN-08 | Sin reviews no se muestra botón ni se calcula rating.                                              |
| RN-09 | El resumen se genera en **español** (idioma único del MVP). El sistema no traduce reviews ni ofrece resúmenes en otros idiomas. |

---

## 6. Estados de la UI

### 6.1 Pantalla "Lista de Productos"
| Estado    | Descripción                                                                |
|-----------|----------------------------------------------------------------------------|
| Loading   | Skeleton o spinner mientras se carga el endpoint.                          |
| Success   | Lista renderizada con sus celdas.                                          |
| Empty     | "No hay productos disponibles" con CTA Reintentar.                         |
| Error     | Mensaje de error + botón Reintentar.                                       |

### 6.2 Pantalla "Detalle de Producto"
| Estado            | Descripción                                                                            |
|-------------------|----------------------------------------------------------------------------------------|
| Success           | Datos del producto, lista de reviews, sección de resumen.                              |
| Resumen `none`    | Sin resumen aún. Botón "Generar resumen" si aplica.                                    |
| Resumen `generating` | Indicador de progreso. Resto de la pantalla disponible.                            |
| Resumen `available` | Resumen visible (4 secciones) + botón "Regenerar".                                  |
| Resumen `error`   | Mensaje de error + botón "Reintentar". No destruye resumen previo si existía.          |
| Resumen `unsupported` | Botón deshabilitado + mensaje "AI no disponible en este dispositivo".              |
| Resumen `disabled` (umbral) | Mensaje "Necesita más de 5 reviews para generar un resumen".                 |

---

## 7. Criterios de Aceptación

### CA — RF-01 (URL base configurable)
- ✅ Cambiar la URL base por el mecanismo definido y relanzar la app hace que las requests apunten al nuevo host.
- ✅ La app rechaza HTTP a hosts distintos de `localhost`.

### CA — RF-02 (Listado)
- ✅ Al iniciar la app se realiza una sola request al endpoint de productos.
- ✅ Se renderizan ≥ 100 productos.
- ✅ Cada celda muestra imagen, título, cantidad de reviews y rating promedio.
- ✅ Si la imagen falla, se muestra placeholder.

### CA — RF-03 (Rating promedio)
- ✅ Producto con reviews `[5, 4, 3]` → muestra `4.0`.
- ✅ Producto sin reviews → muestra "Sin calificación" (no `0.0`, no `NaN`).
- ✅ Producto con un único rating `4` → muestra `4.0`.

### CA — RF-04 (Detalle)
- ✅ Tap en celda navega al detalle correspondiente.
- ✅ El detalle muestra todas las reviews con autor, rating y texto.
- ✅ Botón "Volver" disponible.

### CA — RF-05 (Habilitación del botón)
- ✅ Producto con 0 reviews → botón oculto o deshabilitado con mensaje.
- ✅ Producto con 5 reviews → botón deshabilitado.
- ✅ Producto con 6 reviews → botón habilitado.
- ✅ Producto con 20 reviews → botón habilitado.

### CA — RF-06 (Generación on-device)
- ✅ Durante la generación no se observa tráfico saliente al exterior (verificable con Proxyman).
- ✅ La generación funciona en modo avión (no requiere red para inferir).

### CA — RF-07 (Estructura del resumen)
- ✅ El resumen presenta las cuatro secciones: sentimiento, puntos fuertes, puntos débiles, frase resumen.
- ✅ La frase resumen ocupa una sola línea (≤ 140 caracteres).
- ✅ Las listas de puntos fuertes y débiles son legibles y razonablemente acotadas (sugerido ≤ 5 ítems cada una).

### CA — RF-08 (Persistencia)
- ✅ Tras generar un resumen y cerrar/relanzar la app, el resumen sigue mostrándose sin volver a generarse.
- ✅ El resumen se asocia al `id` del producto.

### CA — RF-09 (Regeneración)
- ✅ "Regenerar" visible cuando ya existe un resumen.
- ✅ Tras regenerar, el resumen anterior queda reemplazado.
- ✅ Si la regeneración falla, se conserva el resumen previo.

### CA — RF-10 (Indicador en lista)
- ✅ La celda de un producto con resumen previamente generado presenta un indicador visual diferenciador.

### CA — RF-11 (Estado de generación)
- ✅ Durante la generación se muestra indicador de progreso.
- ✅ Si el usuario abandona el detalle durante la generación, no hay crash, ni leak, ni resultado escrito en disco a posteriori.

### CA — RF-12 (Fallback de AI)
- ✅ En un dispositivo sin soporte de AI, el botón aparece deshabilitado con el mensaje "AI no disponible en este dispositivo".
- ✅ El resto de la app funciona normalmente.

### CA — RF-13 (Errores de red)
- ✅ Sin conexión al mock, la app muestra estado de error con botón Reintentar.
- ✅ Tras restaurar la conexión y tocar Reintentar, la lista carga.

### CA — RF-14 (Estados de UI)
- ✅ Cada pantalla cubre los cuatro estados (loading/success/empty/error) sin estados intermedios inconsistentes.

### CA — RF-15 (Cancelación)
- ✅ Salir del detalle durante una generación no produce escrituras posteriores en persistencia.
- ✅ Salir de la lista durante la carga inicial cancela la request.

### CA — RF-16 (Pull-to-refresh)
- ✅ Gesto pull-to-refresh dispara una nueva carga del endpoint.
- ✅ El indicador de refresco desaparece al completarse la carga (éxito o error).

---

## 8. Casos de Uso Principales

### UC-01 — Listar productos al inicio
**Actor:** Usuario.
**Precondición:** Mock corriendo en localhost; URL base configurada.

**Flujo principal:**
1. Usuario abre la app.
2. La app muestra estado de loading.
3. La app solicita el listado al backend mock.
4. La app recibe los datos y los renderiza en la lista.
5. Cada celda muestra imagen, título, cantidad de reviews y rating promedio.

**Flujos alternos:**
- 3a. La request falla → la app muestra estado de error con CTA Reintentar.
- 4a. La respuesta es vacía → la app muestra estado empty.

**Postcondición:** Lista visible y navegable.

---

### UC-02 — Generar resumen AI por primera vez
**Actor:** Usuario.
**Precondición:** Producto con > 5 reviews; AI disponible; sin resumen previo.

**Flujo principal:**
1. Usuario selecciona un producto desde la lista.
2. La app navega al detalle y muestra reviews.
3. Usuario presiona "Generar resumen".
4. La app envía las reviews al motor on-device.
5. La app muestra estado de generación (progreso).
6. El motor devuelve el resumen estructurado.
7. La app renderiza el resumen con sus 4 secciones y lo persiste.

**Flujos alternos:**
- 3a. AI no disponible → botón deshabilitado, mensaje informativo (no se llega a este paso).
- 4a. Producto con ≤ 5 reviews → botón no invocable (no se llega a este paso).
- 6a. Generación falla → estado error, botón Reintentar.
- 6b. Usuario cancela / abandona el detalle → tarea cancelada, sin estado huérfano.

**Postcondición:** Resumen disponible y persistido para futuras consultas.

---

### UC-03 — Consultar resumen previamente generado
**Actor:** Usuario.
**Precondición:** Existe un resumen persistido para el producto.

**Flujo principal:**
1. Usuario abre el detalle de un producto.
2. La app detecta resumen persistido y lo muestra de inmediato.
3. La app expone el botón "Regenerar".

**Postcondición:** Resumen mostrado sin reprocesamiento.

---

### UC-04 — Regenerar resumen
**Actor:** Usuario.
**Precondición:** Existe un resumen persistido; AI disponible.

**Flujo principal:**
1. Usuario abre el detalle.
2. Usuario presiona "Regenerar".
3. La app muestra estado de generación.
4. La app reemplaza el resumen anterior con el nuevo y lo persiste.

**Flujos alternos:**
- 3a. Falla la generación → se conserva el resumen previo y se muestra error.
- 3b. Usuario cancela / sale del detalle → tarea cancelada, resumen previo intacto.

**Postcondición:** Resumen actualizado y persistido.

---

### UC-05 — Producto en dispositivo sin AI disponible
**Actor:** Usuario.
**Precondición:** Dispositivo sin soporte para Foundation Models o modelo no descargado.

**Flujo principal:**
1. Usuario abre el detalle de un producto.
2. La app detecta que AI no está disponible.
3. La app muestra mensaje "Resumen AI no disponible en este dispositivo" y deshabilita el botón.

**Postcondición:** El resto de la app funciona normalmente.

---

### UC-06 — Manejo de error de red en lista
**Actor:** Usuario.
**Precondición:** Mock no responde.

**Flujo principal:**
1. Usuario abre la app.
2. La app intenta consumir el endpoint y falla.
3. La app muestra estado de error con botón Reintentar.
4. Usuario corrige el mock y presiona Reintentar.
5. La app vuelve a intentar y muestra la lista.

**Postcondición:** Usuario puede recuperar la sesión sin reiniciar la app.

---

### UC-07 — Cambio de URL base del mock
**Actor:** Desarrollador / QA.
**Precondición:** Se desea apuntar la app a otro entorno mock.

**Flujo principal:**
1. Se modifica el valor de la URL base en el mecanismo de configuración.
2. Se relanza la app.
3. La app consume el nuevo endpoint.

**Postcondición:** App apuntando al nuevo entorno sin recompilar el binario.

---

### UC-08 — Refresco manual de la lista
**Actor:** Usuario.
**Precondición:** Lista cargada con éxito.

**Flujo principal:**
1. Usuario realiza pull-to-refresh.
2. La app re-solicita el endpoint.
3. La app actualiza la lista al recibir respuesta.

**Flujos alternos:**
- 2a. La request falla → la lista anterior se mantiene y se muestra un mensaje de error transitorio (toast/banner).

**Postcondición:** Lista actualizada (o estado anterior preservado en caso de error).

---

## 9. Contrato de API (visión funcional)

> El detalle técnico (paths, headers, códigos exactos, esquemas DTO) se aborda en el spec técnico.

A nivel funcional, el backend mock debe exponer:

- **Listado de productos** → colección de productos. Cada producto contiene: `id`, `title`, `imageUrl` (URL absoluta a repositorio público externo, ver **RF-17**), `reviews[]`.
- **Review** → contiene: `author`, `rating` (entero 1–5), `text`.

**Restricciones funcionales:**
- El listado retorna 100+ productos.
- Cada producto tiene entre 0 y 20 reviews.
- El `id` es único y estable por producto.

**Errores esperados a manejar en UI:**
- 4xx (request inválido, recurso no encontrado).
- 5xx (error del servidor mock).
- Timeout.
- Sin conectividad.

Todos resultan en estado de error con opción de reintento.

---

## 10. Resoluciones de PL/PO

### 10.1 Resoluciones iniciales (2026-05-06)

> Las preguntas abiertas planteadas en la v1.0 fueron resueltas por el PL el 2026-05-06. Esta tabla deja la trazabilidad pregunta → decisión → puntos del spec donde se aplica.

| #  | Pregunta original                                              | Resolución                                                                  | Trazabilidad           |
|----|----------------------------------------------------------------|-----------------------------------------------------------------------------|------------------------|
| 1  | Idioma de los reviews y del resumen                            | **Español**, fijo en el MVP                                                 | S-02, RN-09, RNF-06    |
| 2  | Invalidación automática del resumen al cambiar reviews         | **No**: el usuario regenera manualmente                                     | S-04, RN-03, RF-09     |
| 3  | Límite de longitud impuesto por producto                       | **Ninguno propio**; acotado por la capacidad de Apple Foundation Models    | S-05, RNF-12           |
| 4  | Pantalla de detalle separada o embebida                        | **Pantalla de detalle separada**                                            | S-01, RF-04            |
| 5  | Patrón visual específico para "producto con resumen generado"  | **No hay patrón impuesto**; queda a criterio del implementador              | S-14, RF-10            |
| 6  | Paginación del endpoint de productos                           | **No hay paginación**                                                       | S-06                   |
| 7  | Orden de reviews en el detalle                                 | **Tal como entrega el servicio**                                            | S-15                   |

### 10.2 Decisiones tomadas durante implementación

> Cambios sobre el alcance original detectados o consensuados mientras se materializaba la solución. Se documentan acá para que producto, QA y futuros mantenedores tengan visibilidad de por qué la implementación diverge del primer borrador.

| Fecha       | Decisión                                                                                | Justificación                                                                                                                                         | Trazabilidad   |
|-------------|-----------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|
| 2026-05-06  | Las imágenes de productos se obtienen desde un **repositorio público externo** (Picsum) | No se cuentan con todas las imágenes en local; además, es práctica común descargar imágenes desde un repositorio externo en lugar de servirlas desde el mock | RF-17, S-13, RNF-02 |

---

## 11. Glosario

| Término         | Definición                                                                                  |
|-----------------|---------------------------------------------------------------------------------------------|
| AI on-device    | Inferencia de modelos de lenguaje ejecutada localmente, sin envío de datos a la nube.       |
| Resumen         | Texto estructurado en 4 secciones generado a partir de las reviews de un producto.          |
| Mock            | Backend local servido por Proxyman que simula la API real.                                  |
| Producto        | Ítem del catálogo con `id`, título, imagen y un conjunto de reviews.                        |
| Review          | Opinión individual con autor, rating (1–5) y texto.                                         |
| Rating promedio | Media aritmética de los ratings de las reviews de un producto.                              |
