# AI Review Summarizer (iOS) — MeLi Tech Challenge

App iOS nativa que lista productos desde un mock REST en localhost y genera **resúmenes inteligentes de reseñas íntegramente on-device** con Apple Foundation Models. Sin envío de datos a la nube, sin dependencias externas (cero SPM packages), Swift 6 con concurrencia estricta.

---

## Tabla de contenidos

- [Demo](#demo)
- [Requisitos](#requisitos)
- [Setup y build](#setup-y-build)
- [Configurar el mock con Proxyman](#configurar-el-mock-con-proxyman)
- [Cambiar la URL base del backend](#cambiar-la-url-base-del-backend)
- [Correr los tests](#correr-los-tests)
- [Arquitectura](#arquitectura)
- [Origen de imágenes (RF-17)](#origen-de-imágenes-rf-17)
- [Privacidad y tráfico de red](#privacidad-y-tráfico-de-red)
- [Riesgos y limitaciones conocidas](#riesgos-y-limitaciones-conocidas)
- [Trazabilidad spec ↔ implementación](#trazabilidad-spec--implementación)

---

## Demo

Video corto (1–2 min) mostrando el flujo principal: lista → detalle → generar resumen → regenerar → persistencia tras relaunch → fallback cuando AI no está disponible.

> _(Adjuntar el archivo de video en el entregable o linkearlo aquí.)_

---

## Requisitos

| Componente | Versión |
|---|---|
| **Xcode** | 26.0+ |
| **iOS Deployment Target** | 26.0 |
| **Swift** | 6.0 (strict concurrency) |
| **Simulador** | iPhone 17 (recomendado) o cualquier iPhone con runtime iOS 26.4 |
| **Device físico** | Cualquier iPhone compatible con **Apple Intelligence** habilitado, para validar la generación AI on-device. En simuladores donde Foundation Models no esté disponible la app degrada con copy claro (RF-12). |
| **Proxyman** | Para servir el mock REST en `http://localhost:9090` |

Sin dependencias externas (SPM, CocoaPods, Carthage). Todo nativo: SwiftUI, SwiftData, Foundation Models, URLSession, `os.Logger`, Swift Testing.

---

## Setup y build

```bash
# 1. Clonar
git clone https://github.com/gladiadork30/MeLi_TechChallenge_iOS.git
cd MeLi_TechChallenge_iOS/ReviewSummarizer

# 2. Abrir en Xcode
open ReviewSummarizer.xcodeproj

# 3. Build desde CLI (opcional, para verificación)
xcodebuild -project ReviewSummarizer.xcodeproj \
           -scheme ReviewSummarizer \
           -destination 'platform=iOS Simulator,name=iPhone 17' \
           build
```

Para correr en device físico: en Xcode → Target → Signing → seleccionar tu Team ID. El proyecto ya tiene **automatic signing**.

---

## Configurar el mock con Proxyman

El backend se simula con un Local Mock Server de Proxyman.

1. Instalar Proxyman: <https://proxyman.com>
2. Tools → Local Mock Server → New Mock Server
3. Crear ruta `GET /products` → Response Body → seleccionar `ReviewSummarizer/Mocks/products.json` (120 productos generados deterministícamente; ver [`Mocks/README_QA.md`](ReviewSummarizer/Mocks/README_QA.md))
4. Configurar puerto **9090** (matchea `BACKEND_BASE_URL`)
5. Iniciar el mock server

**Verificación rápida**:

```bash
curl http://localhost:9090/products | python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
# Debe imprimir 120
```

Para regenerar el mock con otra distribución:

```bash
cd ReviewSummarizer/Mocks
python3 generate_products.py
```

---

## Cambiar la URL base del backend

Tres mecanismos, en orden de precedencia (RF-01 / RNF-07: configurable sin recompilar el binario):

### 1. Variable de entorno (override por scheme — recomendado para QA/tests)

Xcode → **Edit Scheme** → **Run** → **Arguments** → **Environment Variables** → agregar:

| Key | Value |
|---|---|
| `BACKEND_BASE_URL` | `http://localhost:9090` |

Cmd+R para correr. Esto sobreescribe el valor del `Info.plist` en runtime.

### 2. Edición del xcconfig (cambio persistente)

Editar `ReviewSummarizer/ReviewSummarizer/Config/Debug.xcconfig`:

```
BACKEND_BASE_URL = http:/$()/localhost:9090
```

> El `$()` es un escape para que el `//` no sea interpretado como comentario por el parser de xcconfig.

Relanzar la app. La nueva URL queda inyectada en `Info.plist → BackendBaseURL` en build time.

### 3. Restricciones (RNF-03)

ATS solo permite **HTTP** cuando el host es `localhost`. Cualquier otro host **debe** ser HTTPS o ser rechazado por el sistema. Esto es intencional. La app NO modifica `NSExceptionDomains` para nada que no sea `localhost`.

---

## Correr los tests

```bash
xcodebuild -project ReviewSummarizer.xcodeproj \
           -scheme ReviewSummarizer \
           -destination 'platform=iOS Simulator,name=iPhone 17' \
           test
```

Suite de **51 tests** Swift Testing en verde, organizada por capa:

| Carpeta | Cobertura |
|---|---|
| `ReviewSummarizerTests/Domain/` | 16 tests — use cases puros (rating, umbral, generación, fetch) |
| `ReviewSummarizerTests/Data/` | 18 tests — DTO mapping, SwiftData repo (in-memory), URL helpers, prompt builder |
| `ReviewSummarizerTests/Presentation/` | 14 tests — mappers, ViewModels (matriz de estados, cancelación) |
| `ReviewSummarizerTests/Doubles/` | Stubs/Spies/Mocks (`actor` para Sendable safety) |

Tests excluidos por decisión del plan §9.1: UI views, `URLSessionHTTPClient` directo, `FoundationModelsSummarizerService` real (no determinista).

---

## Arquitectura

**Clean Architecture liviana en 3 capas + MVVM** en presentación:

```
Presentation (SwiftUI + @Observable)
       ↓
   Domain (Sendable, sin imports)
       ↑
     Data (URLSession, SwiftData, FoundationModels)
```

Reglas de dependencia:
- `Domain` no conoce a nadie. Foundation puro.
- `Presentation` depende de `Domain`. Nunca de `Data`.
- `Data` depende de `Domain` (implementa sus protocols).
- Composición en `App/CompositionRoot.swift` (DI manual, sin frameworks).

ViewModels son `@MainActor`; repos y services son `actor`. Use cases son structs `Sendable`.

Estructura de carpetas en `ReviewSummarizer/ReviewSummarizer/`:

| Carpeta | Contenido |
|---|---|
| `App/` | `@main App`, `CompositionRoot`, `AppConfiguration` |
| `Presentation/` | Views SwiftUI, ViewModels `@Observable`, UI models |
| `Domain/` | Entities, Use Cases, Repository/Service protocols, errors |
| `Data/` | `Network/`, `Persistence/`, `AI/` (implementaciones) |
| `Core/` | `Logging/`, `Extensions/` (utilidades transversales) |
| `Resources/` | `Localizable.strings` (es), `Assets.xcassets` |
| `Config/` | xcconfig (Shared/Debug/Release) |
| `../Mocks/` | `products.json`, generador, `README_QA.md` (fuera del bundle) |

---

## Origen de imágenes (RF-17)

Las imágenes de productos se obtienen de un **repositorio público externo HTTPS**: [Picsum](https://picsum.photos/).

```
https://picsum.photos/seed/{productId}/400/400
```

- El backend mock **no aloja binarios** — solo entrega URLs en la respuesta.
- La app descarga las imágenes directamente contra `picsum.photos`.
- Si una URL falla (404, timeout, sin conectividad, ATS bloqueando), se muestra **placeholder nativo** (`AsyncImage` con `AsyncImagePhase.failure`) y la celda mantiene el resto del contenido visible (título, rating, conteo, indicador de resumen).
- La caché HTTP la maneja `URLSession.shared.URLCache` (sin configuración custom).

El componente compartido `Presentation/Common/ProductImageView.swift` centraliza este comportamiento. El mock incluye 1 producto (`p_008`) con `imageUrl` deliberadamente rota para verificar el fallback en QA (T-148).

---

## Privacidad y tráfico de red

La app realiza dos canales de tráfico claramente diferenciados (RNF-02):

| Canal | Hosts | Datos | Cuándo |
|---|---|---|---|
| **Datos del catálogo** | `localhost:9090` (mock) | `GET /products` con productos + reviews + URLs de imagen | Una vez al iniciar y en cada pull-to-refresh |
| **Imágenes externas** | `picsum.photos` (HTTPS) | `GET` anónimos, sin headers de auth, sin cookies | Al cargar/scrollear celdas que necesitan imagen |
| **AI on-device** | Ningún host | Inferencia local con Foundation Models | Al tap "Generar / Regenerar resumen" |

**Garantías**:
- La inferencia AI corre **100% on-device**. Verificable: la app genera resúmenes en modo avión.
- Las requests a Picsum son anónimas y **NO transportan** PII, contenido de reviews ni resultados de la AI.
- Sin telemetría custom de la app. Solo `os.Logger` con subsystem `com.jpromero.ReviewSummarizer` (visible en Console.app, local-only).

---

## Riesgos y limitaciones conocidas

### Riesgos operacionales

| Riesgo | Mitigación |
|---|---|
| **Caída/latencia de Picsum durante la demo** | Pre-warmear la caché navegando una vez por la lista antes de grabar el video. Las celdas ya cargadas siguen visibles incluso si el host cae después. |
| **Apple Intelligence no disponible en el simulador del evaluador** | La app degrada con `.unsupported` y copy claro ("Resumen AI no disponible en este dispositivo"). Resto de la app sigue funcional. Recomendado: probar en device físico con Apple Intelligence on. |
| **Cambios en API de Foundation Models entre seeds de iOS 26** | Aislado en `Data/AI/`. La detección de "context overflow" usa heurística sobre `String(describing:)` para no acoplar a cases marcados `@unknown` que podrían cambiar entre seeds. |

### Limitaciones conocidas (TODO)

- **Map-reduce para context overflow** (RNF-12): si el truncado a 600 chars/review no alcanza, lanza `SummarizerError.contextOverflow`. La estrategia map-reduce está documentada en `plan.md` §5.4 pero no implementada en MVP. Marcado como `// TODO(RNF-12)` en `FoundationModelsSummarizerService`.
- **No hay tests de UI views** (decisión del plan §9.1). Los previews `#Preview` cubren los casos visuales principales.
- **No hay caché disk-backed de imágenes**. Solo la `URLCache` por defecto. Suficiente para el MVP; si se necesitara prefetch on-scroll, evaluar Nuke/Kingfisher (no está en el alcance).

---

## Trazabilidad spec ↔ implementación

| Requisito | Cubierto por |
|---|---|
| **RF-01** URL base configurable | `Config/*.xcconfig`, `App/AppConfiguration.swift`, `Info.plist → BackendBaseURL` |
| **RF-02** Listado de productos | `ProductListView`, `ProductListViewModel`, `HTTPProductRepository` |
| **RF-03** Rating promedio (1 decimal) / "Sin calificación" | `ComputeAverageRatingUseCase`, `ProductListItemMapper`, `RatingBadgeView` |
| **RF-04** Detalle como pantalla separada | `ProductDetailView` con `NavigationStack + .navigationDestination` |
| **RF-05** Botón habilitable solo si > 5 reviews | `CanGenerateSummaryUseCase` (threshold = 5), `GenerateSummaryButton` |
| **RF-06** Generación AI on-device | `FoundationModelsSummarizerService` (`actor`, `import FoundationModels`) |
| **RF-07** Resumen estructurado (4 secciones) | `SummaryDraft @Generable`, `SummarySectionView` |
| **RF-08** Persistencia del resumen | `SwiftDataSummaryRepository` con `@Attribute(.unique) productId` |
| **RF-09** Regeneración reemplaza | `GenerateSummaryUseCase.execute` → `upsert` solo tras éxito |
| **RF-10** Indicador "tiene resumen" | `ProductListItemUIModel.hasCachedSummary` + `ProductRowView` (sparkles) |
| **RF-11** Estado de generación + cancelación al salir | `ProductDetailViewModel.runGeneration` + `onDisappear` |
| **RF-12** Fallback cuando AI no está disponible | `SummarizerService.availability` + estado `.unsupported` |
| **RF-13** Errores de red con reintento | `ErrorView` + `ProductListViewModel` con CTA `load()` |
| **RF-14** Estados loading/success/empty/error | `ProductListUIState`, `SummaryUIState` |
| **RF-15** Cancelación de tareas async | `Task` controlado en VMs + `Task.checkCancellation()` |
| **RF-16** Pull-to-refresh | `.refreshable { await viewModel.refresh() }` |
| **RF-17** Imágenes desde repositorio público externo | `ProductImageView` (AsyncImage phase-based) + `picsum.photos/seed/{id}/400/400` en `products.json` |
| **RNF-01** iOS 26+, Swift 6 strict | `Shared.xcconfig` (deployment target, swift version) |
| **RNF-02** Privacidad — AI on-device + imágenes anónimas | Sin tráfico de reviews fuera del device; imágenes anónimas via HTTPS |
| **RNF-03** HTTP solo a localhost | `Info.plist → NSExceptionDomains` con única entrada `localhost` |
| **RNF-04** Performance | `async/await` + actores; `async let` paralelo en `ProductListViewModel.performLoad` |
| **RNF-05** Accesibilidad — Dynamic Type, VoiceOver | Tipografías semánticas + `accessibilityLabel`/`accessibilityElement` en componentes clave |
| **RNF-06** Idioma único es | `Resources/es.lproj/Localizable.strings` (28 entries) + `DEVELOPMENT_LANGUAGE = es` |
| **RNF-08** Mantenibilidad | Capas + tests + Sendable + sin dependencias |
| **RNF-09** Resiliencia / cancelación | Mismo que RF-15 |
| **RNF-11** Logging local | `Core/Logging/Logger+Categories.swift` (4 categorías `os.Logger`) |
| **RNF-12** Límites del modelo on-device | Estrategia overflow 2-niveles en `FoundationModelsSummarizerService` |

Para detalle técnico ver `specs/spec.md` (v1.2), `specs/plan.md` (v1.1) y `specs/tasks.md` (v1.1).

---

## Notas para el evaluador

- **Sin dependencias externas**: la regla "frameworks nativos sobre terceros" se cumple estrictamente. Cero SPM packages, cero Pods, cero binarios.
- **51 tests passing** (Swift Testing). Cobertura concentrada en dominio (regla más alta de cobertura) según el plan §9.
- **Chequeo de privacidad reproducible**: con Proxyman corriendo, durante la inferencia AI no debe haber tráfico saliente. Verificable con captura limpia (T-144).
- **Plan de QA manual** detallado en [`ReviewSummarizer/Mocks/README_QA.md`](ReviewSummarizer/Mocks/README_QA.md): smoke E2E, fallback de imagen, fallback AI, cancelación, cambio de URL.
