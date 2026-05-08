# Plan de Tareas — AI Review Summarizer (iOS)

**Versión:** 1.1
**Fecha:** 2026-05-08
**Documentos base:** `spec.md` v1.2, `plan.md` v1.1
**Convención:** Cada tarea es atómica (≤ 30 min), con criterio de _hecho_ verificable y dependencias explícitas. Las referencias `RF-xx`, `RNF-xx`, `RN-xx`, `CA-xx`, `S-xx` apuntan al `spec.md`. Las referencias `§x.x` apuntan al `plan.md`.

## Estado de ejecución (actualizado 2026-05-08, post-rebase v1.1)

| Fase | Estado | Notas |
|---|---|---|
| Fase 0 — Setup | ✅ completa | T-001..T-006 |
| Fase 1 — Core / Config | 🔄 reabierta T-011 | T-010, T-012..T-014 ✅. T-011 `[REABRIR]` por RF-17. |
| Fase 2 — Dominio | ✅ completa | T-020..T-032 (sin impacto v1.1) |
| Fase 3 — Data Networking | ✅ completa | T-040..T-046 (sin impacto v1.1) |
| Fase 4 — Data Persistencia | ✅ completa | T-050..T-053 |
| Fase 5 — Data AI on-device | ✅ completa | T-060..T-069 |
| Fase 6 — Composition Root | ✅ completa | T-070, T-071 |
| Fase 7 — Componentes comunes | ✅ completa | T-072..T-074 |
| Fase 8 — Lista de productos | 🔄 reabierta T-084 | T-080..T-083, T-085..T-086 ✅. T-084 `[REABRIR]` por RF-17. |
| Fase 9 — Detalle de producto | 🔄 reabierta T-094 | T-090..T-093, T-095..T-098 ✅. T-094 `[REABRIR]` por RF-17. |
| Fase 10 — i18n + a11y | ✅ completa | T-100..T-102 |
| Fase 11 — Tests dominio | ✅ completa | T-110..T-115 (16 tests) |
| Fase 12 — Tests data | ✅ completa | T-120..T-123 (18 tests) |
| Fase 13 — Tests presentation | ✅ completa | T-130..T-134 (14 tests) |
| Fase 14 — Mock + QA | 🔄 reabierta T-140 + ampliada | T-140 `[REABRIR]` por RF-17. T-141..T-147 pendientes. **T-148 nueva**. |
| Fase 15 — Entregables | ⏳ pendiente | T-150 `[REVISAR]` por RF-17. T-151..T-153 sin cambios. |

**Tests pasando:** 51 / 51 (Swift Testing). El rebase a v1.1 **no afecta la suite de tests**: ningún cambio toca dominio, data ni viewmodels (la capa de presentación afectada solo modifica el render del control `AsyncImage`, que no está cubierto por tests). **Build target:** iPhone 17 / iOS 26.4.

**Convenciones de IDs:**
- `T-00x`: Setup
- `T-01x`: Core / Configuración
- `T-02x`: Dominio
- `T-03x`: Data — Networking
- `T-04x`: Data — Persistencia
- `T-05x`: Data — AI
- `T-06x`: Composition Root
- `T-07x`: Presentation — Componentes comunes
- `T-08x`: Presentation — Lista de productos
- `T-09x`: Presentation — Detalle de producto
- `T-10x`: Localización y accesibilidad
- `T-11x`: Tests de dominio
- `T-12x`: Tests de data
- `T-13x`: Tests de presentation
- `T-14x`: Mocks y QA
- `T-15x`: README y demo

**Marcas de revisión:**
- `[REVISAR]`: la tarea aún no estaba completa. Su acción/criterio cambia con los specs nuevos. Releer el bloque "🔧 Ajuste v1.1" antes de ejecutarla.
- `[REABRIR]`: la tarea estaba marcada como completa pero el cambio de spec exige rehacer (o al menos verificar contra) el artefacto producido. Se desmarca a `[ ]` y se documenta el delta concreto.
- `[NUEVA v1.1]`: tarea agregada en este rebase.

---

## Changelog v1.1

Sincronización con `spec.md` v1.2 (RF-17, S-13, RNF-02 actualizados) y `plan.md` v1.1 (§6.2, §6.5, §10.5, §11). El cambio de fondo es uno solo:

> Las imágenes de productos provienen de un **repositorio público externo HTTPS** (Picsum). El backend mock **no aloja binarios** — solo entrega URLs. La app descarga las imágenes contra el host externo. Si una URL falla, placeholder y la lista sigue funcional.

**Tareas reabiertas (`[REABRIR]` — implementación previa puede requerir cambio):**

| ID    | Por qué reabrir |
|-------|-----------------|
| T-011 | Verificar que la excepción ATS quedó acotada **solo** a `localhost`. Picsum es HTTPS y no debe figurar en `NSExceptionDomains`. Si el dev original solo configuró `localhost`, este reabrir se cierra con una verificación de `Info.plist`. Si por alguna razón se agregó otro host, hay que revertir. |
| T-084 | El `AsyncImage` actual usa el inicializador con `placeholder` genérico, que **no maneja explícitamente `.failure`**. RF-17 / CA-RF-02 exige placeholder ante URL rota. Migrar a la variante `phase`-based con `AsyncImagePhase`. |
| T-094 | Mismo cambio que T-084 aplicado al header del detalle. |
| T-140 | El `products.json` actual se generó cuando el spec aún no fijaba origen externo. Hay que asegurar que las `imageUrl` apuntan a `https://picsum.photos/seed/{id}/400/400` (HTTPS, seed determinista) y sembrar 1 URL deliberadamente rota para validar fallback en T-148. Si ya estaba apuntando a Picsum, el reabrir se cierra agregando solo la URL rota. |

**Tareas afectadas pendientes (`[REVISAR]` — todavía no ejecutadas):**

| ID    | Por qué revisar |
|-------|-----------------|
| T-142 | Smoke test de la lista debe verificar carga de imágenes desde Picsum y caso de placeholder ante URL inválida (CA-RF-02 ampliado). |
| T-144 | Separar dos canales de tráfico: durante generación AI = cero tráfico externo; durante carga de lista = sí hay GETs HTTPS anónimos a `picsum.photos` (sin PII ni texto de reviews). RNF-02 reformulado. |
| T-150 | README debe documentar RF-17, el origen externo de imágenes, el riesgo de caída de Picsum durante la demo y la decisión de §10.2 del spec. |

**Tareas nuevas (`[NUEVA v1.1]`):** T-148 (verificación de fallback de imagen).

**Tareas NO afectadas (intencional):**
- Toda la capa de Dominio (T-020..T-032) y Data (T-040..T-069) queda intacta. La regla de dependencia (`Presentation → Domain ← Data`) garantiza que un cambio de origen de imágenes solo se sienta en presentación + mock + QA + docs.
- Toda la suite de tests (T-110..T-134) queda intacta. 51/51 sigue verde.

---

## Fase 0 — Setup del proyecto

- [x] **T-001 — Crear proyecto Xcode**
  - **Acción:** Nuevo proyecto iOS App, nombre `ReviewSummarizer`, interfaz SwiftUI, lenguaje Swift, iOS Deployment Target = 26.0, organización de carpetas como en §8.
  - **Hecho:** El proyecto compila vacío en simulador iOS 26.
  - **Depende de:** —

- [x] **T-002 — Activar Swift 6 strict concurrency**
  - **Acción:** Build Settings → `Swift Language Version = 6.0`, `Strict Concurrency Checking = Complete`.
  - **Hecho:** El proyecto compila sin warnings de concurrencia con un `@main App` mínimo.
  - **Depende de:** T-001

- [x] **T-003 — Crear estructura de carpetas top-level**
  - **Acción:** Crear los grupos `App/`, `Presentation/`, `Domain/`, `Data/`, `Core/`, `Resources/` (groups que sí mapean a folder en disco).
  - **Hecho:** El árbol coincide con §8 a nivel de carpetas raíz.
  - **Depende de:** T-001

- [x] **T-004 — Linkear Foundation Models Framework**
  - **Acción:** Target → Frameworks → `+ FoundationModels.framework`. Verificar `import FoundationModels` en un archivo dummy.
  - **Hecho:** Compila con `import FoundationModels`.
  - **Depende de:** T-001

- [x] **T-005 — Linkear SwiftData**
  - **Acción:** Verificar que `import SwiftData` compila en un archivo dummy.
  - **Hecho:** Compila con `import SwiftData`.
  - **Depende de:** T-001

- [x] **T-006 — Crear target de tests con Swift Testing**
  - **Acción:** Añadir target `ReviewSummarizerTests`, verificar que un `@Test func smoke()` corre verde.
  - **Hecho:** `Cmd+U` ejecuta y pasa el test smoke.
  - **Depende de:** T-001

---

## Fase 1 — Core y configuración (RF-01, RNF-03, RNF-07, RNF-11)

- [x] **T-010 — Crear xcconfig para `BACKEND_BASE_URL`**
  - **Acción:** Añadir `Config/Debug.xcconfig` con `BACKEND_BASE_URL = http:/$()/localhost:9090`. Asignar al scheme.
  - **Hecho:** Build setting `BACKEND_BASE_URL` aparece resuelto en Build Settings.
  - **Depende de:** T-001

- [ ] **T-011 — Configurar `Info.plist` con `BackendBaseURL` y ATS** `[REABRIR]`
  - **Acción:** Añadir clave `BackendBaseURL = $(BACKEND_BASE_URL)` y bloque `NSAppTransportSecurity > NSExceptionDomains > localhost > NSExceptionAllowsInsecureHTTPLoads = YES` (RNF-03).
  - **Hecho:** Lectura `Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL")` devuelve la URL en runtime.
  - **Depende de:** T-010
  - **🔧 Ajuste v1.1 (RF-17 / §6.5):** abrir `Info.plist` actual y verificar:
    1. `NSExceptionDomains` contiene **únicamente** la entrada `localhost` (no `picsum.photos`, no ningún otro host).
    2. No hay `NSAllowsArbitraryLoads = true` ni `NSAllowsArbitraryLoadsForMedia = true`.

    Picsum se sirve por HTTPS estándar y no necesita ninguna excepción. Mantener cualquier intento futuro de servir imágenes desde un host HTTP no-localhost rechazado por ATS es **el comportamiento deseado**. **Cierre del reabrir:** si ambos puntos ya se cumplen (lo más probable, dado que el spec original ya prohibía HTTP a hosts distintos de localhost), basta marcar `[x]` nuevamente. Si hay excepciones de más, eliminarlas. Validar con un smoke test: GET a `https://picsum.photos/seed/test/200/200` debe funcionar sin tocar `Info.plist`.

- [x] **T-012 — Implementar `AppConfiguration.load()`**
  - **Acción:** Crear `App/AppConfiguration.swift` con override por `ProcessInfo.environment["BACKEND_BASE_URL"]` y fallback a `Info.plist` (§6.5).
  - **Hecho:** Función pura que devuelve `AppConfiguration` o falla con `preconditionFailure` si no hay URL.
  - **Depende de:** T-011

- [x] **T-013 — Crear `Logger+Categories`**
  - **Acción:** `Core/Logging/Logger+Categories.swift` con categorías `network`, `persistence`, `ai`, `ui` usando `os.Logger` (RNF-11, §10.12).
  - **Hecho:** Compila y se puede invocar `Logger.network.info("…")` desde cualquier capa.
  - **Depende de:** T-001

- [x] **T-014 — Extension `URL+Append`**
  - **Acción:** `Core/Extensions/URL+Append.swift` con helper `appending(path:)` consistente para iOS 26.
  - **Hecho:** Test de smoke unit-tested en T-122.
  - **Depende de:** T-001

---

## Fase 2 — Dominio (RF-02, RF-03, RF-05, RF-07, RF-08, RF-09, RN-01..RN-09)

- [x] **T-020 — Definir `Review` entity**
  - **Acción:** `Domain/Entities/Review.swift` (§4.1). `struct Review: Hashable, Sendable` con `author: String`, `rating: Int`, `text: String`.
  - **Hecho:** Compila; sin imports más allá de `Foundation`.
  - **Depende de:** T-002

- [x] **T-021 — Definir `Product` entity**
  - **Acción:** `Domain/Entities/Product.swift`. `struct Product: Identifiable, Hashable, Sendable` con `id: String`, `title: String`, `imageURL: URL?`, `reviews: [Review]` (S-12, S-13).
  - **Hecho:** Compila; ninguna dependencia fuera de `Foundation`.
  - **Depende de:** T-020

- [x] **T-022 — Definir `Sentiment` enum**
  - **Acción:** `Domain/Entities/ReviewSummary.swift` parcial: `enum Sentiment: String, Sendable, CaseIterable { case positive, neutral, negative }`.
  - **Hecho:** Compila.
  - **Depende de:** T-002

- [x] **T-023 — Definir `ReviewSummary` entity**
  - **Acción:** `struct ReviewSummary: Hashable, Sendable` con `productId`, `sentiment`, `strengths`, `weaknesses`, `tagline`, `generatedAt` (RF-07).
  - **Hecho:** Compila.
  - **Depende de:** T-022

- [x] **T-024 — Definir `DomainError`**
  - **Acción:** `Domain/Errors/DomainError.swift`. Casos: `network(underlying)`, `persistence(underlying)`, `summarizer(SummarizerError)`, `notFound`.
  - **Hecho:** `enum DomainError: Error, Sendable` compila.
  - **Depende de:** T-002

- [x] **T-025 — Definir `ProductRepository` protocol**
  - **Acción:** `Domain/Repositories/ProductRepository.swift`. `func fetchProducts() async throws -> [Product]`.
  - **Hecho:** `protocol ProductRepository: Sendable` compila.
  - **Depende de:** T-021

- [x] **T-026 — Definir `SummaryRepository` protocol**
  - **Acción:** `Domain/Repositories/SummaryRepository.swift`. Métodos `fetch(productId:)`, `fetchAllProductIds()`, `upsert(_:)`, `delete(productId:)` (§7.2).
  - **Hecho:** Compila como `protocol … : Sendable`.
  - **Depende de:** T-023

- [x] **T-027 — Definir `SummarizerService` protocol y disponibilidad**
  - **Acción:** `Domain/Services/SummarizerService.swift` con `availability: SummarizerAvailability { get async }`, `summarize(reviews:productId:) async throws -> ReviewSummary`, y los enums `SummarizerAvailability` y `UnavailabilityReason` (§5.2). Añadir `enum SummarizerError: Error { case noReviews, generationFailed, contextOverflow, cancelled }`.
  - **Hecho:** Compila con todos los tipos `Sendable`.
  - **Depende de:** T-020, T-023

- [x] **T-028 — `ComputeAverageRatingUseCase`**
  - **Acción:** `Domain/UseCases/ComputeAverageRatingUseCase.swift`. Devuelve `enum AverageRating { case value(Double); case unrated }`. Cálculo: media aritmética redondeada a 1 decimal (RF-03, RN-04).
  - **Hecho:** Compila; signatura pura, sin side effects.
  - **Depende de:** T-020

- [x] **T-029 — `CanGenerateSummaryUseCase`**
  - **Acción:** `Domain/UseCases/CanGenerateSummaryUseCase.swift`. `func execute(reviewCount: Int) -> Bool { reviewCount > 5 }` (RF-05, RN-01, S-03).
  - **Hecho:** Compila; tests en T-111.
  - **Depende de:** T-002

- [x] **T-030 — `FetchProductsUseCase`**
  - **Acción:** `Domain/UseCases/FetchProductsUseCase.swift`. Orquesta `ProductRepository.fetchProducts()`. Inyección por inicializador.
  - **Hecho:** Compila; struct `Sendable`.
  - **Depende de:** T-025

- [x] **T-031 — `GetCachedSummaryUseCase`**
  - **Acción:** `Domain/UseCases/GetCachedSummaryUseCase.swift`. Delega en `SummaryRepository.fetch(productId:)`.
  - **Hecho:** Compila.
  - **Depende de:** T-026

- [x] **T-032 — `GenerateSummaryUseCase`**
  - **Acción:** `Domain/UseCases/GenerateSummaryUseCase.swift`. Coordina `SummarizerService.summarize` + `SummaryRepository.upsert`. **No persiste si la inferencia lanza** (RF-09, CA-RF-09, §5.6).
  - **Hecho:** Compila; el upsert solo ocurre tras éxito de `summarize`.
  - **Depende de:** T-026, T-027

---

## Fase 3 — Data: Networking (RF-01, RF-02, RF-13, S-06)

- [x] **T-040 — Crear `ReviewDTO`**
  - **Acción:** `Data/Network/DTOs/ReviewDTO.swift`. `struct ReviewDTO: Decodable` con `author`, `rating`, `text`.
  - **Hecho:** Compila.
  - **Depende de:** T-002

- [x] **T-041 — Crear `ProductDTO`**
  - **Acción:** `Data/Network/DTOs/ProductDTO.swift`. `struct ProductDTO: Decodable` con `id`, `title`, `imageUrl: String?`, `reviews: [ReviewDTO]?`.
  - **Hecho:** Compila.
  - **Depende de:** T-040

- [x] **T-042 — Mappers DTO → entidad**
  - **Acción:** `Data/Network/Mappers/ProductDTO+Mapping.swift`. `ReviewDTO.toDomain()` filtra rating fuera de `1...5`. `ProductDTO.toDomain()` mapea `imageUrl` a `URL?` con `flatMap(URL.init(string:))` (§4.2).
  - **Hecho:** Compila; cubierto por T-120.
  - **Depende de:** T-021, T-041

- [x] **T-043 — Definir `NetworkError`**
  - **Acción:** `Data/Network/NetworkError.swift`. Casos `invalidResponse`, `httpStatus(Int)`, `decoding(Error)`, `transport(Error)` con conformancia `Equatable` por igualdad de casos (§6.4).
  - **Hecho:** Compila.
  - **Depende de:** T-002

- [x] **T-044 — Definir `HTTPClient` protocol**
  - **Acción:** `Data/Network/HTTPClient.swift`. `protocol HTTPClient: Sendable { func get<T: Decodable>(_ path: String) async throws -> T }`.
  - **Hecho:** Compila.
  - **Depende de:** T-002

- [x] **T-045 — Implementar `URLSessionHTTPClient`**
  - **Acción:** `Data/Network/URLSessionHTTPClient.swift` como `actor` (§6.4). Construye URL con `baseURL.appending(path:)`, valida `2xx`, decodifica, mapea errores a `NetworkError`.
  - **Hecho:** Compila; pasa un test manual contra `http://localhost:9090/products` con un JSON sample.
  - **Depende de:** T-014, T-043, T-044

- [x] **T-046 — Implementar `HTTPProductRepository`**
  - **Acción:** `Data/Network/HTTPProductRepository.swift`. `actor` que recibe `HTTPClient`, llama `GET /products`, decodifica `[ProductDTO]`, mapea a `[Product]`.
  - **Hecho:** Compila; conforma `ProductRepository`.
  - **Depende de:** T-025, T-042, T-045

---

## Fase 4 — Data: Persistencia (RF-08, RF-09, RF-10, RN-02, RN-03)

- [x] **T-050 — Crear `PersistedSummary` `@Model`**
  - **Acción:** `Data/Persistence/Models/PersistedSummary.swift`. `@Attribute(.unique) var productId` + campos del §4.3.
  - **Hecho:** Compila bajo Swift 6 strict concurrency.
  - **Depende de:** T-005

- [x] **T-051 — Mapping `PersistedSummary` ↔ `ReviewSummary`**
  - **Acción:** `Data/Persistence/Mappers/PersistedSummary+Mapping.swift`. `init(from: ReviewSummary)` y `toDomain() -> ReviewSummary` (con guard de `Sentiment(rawValue:)`, fallback `.neutral` con log).
  - **Hecho:** Compila.
  - **Depende de:** T-023, T-050

- [x] **T-052 — Implementar `SwiftDataSummaryRepository`**
  - **Acción:** `Data/Persistence/SwiftDataSummaryRepository.swift` como `actor` con `ModelContainer`. Implementa `fetch`, `fetchAllProductIds`, `upsert` (busca y reemplaza por `productId` o inserta), `delete` (§7.2).
  - **Hecho:** Compila; conforma `SummaryRepository`.
  - **Depende de:** T-026, T-050, T-051

- [x] **T-053 — Helper para `ModelContainer`**
  - **Acción:** En `App/CompositionRoot.swift` (placeholder por ahora) factory `makeModelContainer()` que crea contenedor persistente para el schema `[PersistedSummary.self]`. Variante `inMemory: true` para tests.
  - **Hecho:** Compila; función pura que devuelve `ModelContainer`.
  - **Depende de:** T-052

---

## Fase 5 — Data: AI on-device (RF-06, RF-07, RF-11, RF-12, RNF-02, RNF-12)

- [x] **T-060 — Definir `SummaryDraft` con `@Generable`**
  - **Acción:** `Data/AI/Prompt/SummaryDraft.swift`. Aplica `@Generable` y `@Guide` con descripciones y `.count(0...5)` para listas; `tagline` con tope de 140 caracteres (§5.3).
  - **Hecho:** Compila bajo `import FoundationModels`.
  - **Depende de:** T-004

- [x] **T-061 — `SentimentChoice` `@Generable`**
  - **Acción:** En el mismo archivo, `@Generable enum SentimentChoice: String { case positive, neutral, negative }`.
  - **Hecho:** Compila.
  - **Depende de:** T-060

- [x] **T-062 — Mapping `SummaryDraft → ReviewSummary`**
  - **Acción:** Extension en `SummaryDraft` con `func toDomain(productId:) -> ReviewSummary`. Trunca `tagline` defensivamente a 140 chars; cap de listas a 5 ítems.
  - **Hecho:** Compila.
  - **Depende de:** T-023, T-060

- [x] **T-063 — `PromptBuilder.systemInstructions`**
  - **Acción:** Constante con las reglas del §5.3 en español neutro. Sin datos del producto en el system prompt.
  - **Hecho:** Constante estática `String`.
  - **Depende de:** T-002

- [x] **T-064 — `PromptBuilder.userPrompt(productTitle:reviews:)`**
  - **Acción:** `Data/AI/Prompt/PromptBuilder.swift`. Construye el prompt enumerando reviews `[i] ⭐rating — autor: "texto"` (§5.3, RN-09).
  - **Hecho:** Función pura testeable.
  - **Depende de:** T-020

- [x] **T-065 — Helper de truncado para reviews largas**
  - **Acción:** En `PromptBuilder`, función `truncated(_ reviews: [Review], maxCharsPerReview: Int) -> [Review]` que recorta `text` preservando el inicio (§5.4 nivel 2).
  - **Hecho:** Función pura, testeable.
  - **Depende de:** T-020

- [x] **T-066 — `FoundationModelsSummarizerService.availability`**
  - **Acción:** `Data/AI/FoundationModelsSummarizerService.swift` como `actor`, conforma `SummarizerService`. Implementa solo `availability` mapeando `SystemLanguageModel.default.availability` a `SummarizerAvailability` (§5.2).
  - **Hecho:** Compila; en simulador eligible reporta `.available` o el `.unavailable(reason:)` correspondiente.
  - **Depende de:** T-027

- [x] **T-067 — `FoundationModelsSummarizerService.summarize` (camino feliz)**
  - **Acción:** Crear `LanguageModelSession(instructions:)`, llamar `respond(to:generating: SummaryDraft.self)` y convertir a `ReviewSummary`. Lanzar `SummarizerError.noReviews` si lista vacía (§5.3).
  - **Hecho:** Devuelve resumen estructurado con 4 secciones para una lista de 6 reviews fixture, en device/simulator con AI disponible.
  - **Depende de:** T-062, T-064, T-066

- [x] **T-068 — Cancelación cooperativa**
  - **Acción:** Tras la respuesta, `try Task.checkCancellation()`. Mapear `CancellationError` y propagarlo sin envolver (§5.5, RF-15).
  - **Hecho:** Cancelar el `Task` durante la inferencia produce `CancellationError` y **no** hay efectos posteriores.
  - **Depende de:** T-067

- [x] **T-069 — Estrategia de context overflow (niveles 1 y 2)**
  - **Acción:** Try-catch sobre la primera llamada; ante error de contexto, reintentar con `PromptBuilder.truncated(reviews, maxCharsPerReview: 600)`. Si aún falla, lanzar `SummarizerError.contextOverflow` (§5.4, RNF-12). Documentar map-reduce como TODO con marcador `// TODO(RNF-12): map-reduce`.
  - **Hecho:** Path de retry implementado y compila; cubierto por test mockeable en T-113.
  - **Depende de:** T-065, T-067

---

## Fase 6 — Composition Root y entry point

- [x] **T-070 — `CompositionRoot` con factories**
  - **Acción:** `App/CompositionRoot.swift`. Métodos `makeProductListViewModel()` y `makeProductDetailViewModel(product:)` que arman dependencias (HTTPClient → ProductRepo → UseCase, ModelContainer → SummaryRepo, SummarizerService).
  - **Hecho:** Compila; sin singletons; todo cableado por inicializador.
  - **Depende de:** T-012, T-046, T-052, T-053, T-066

- [x] **T-071 — `ReviewSummarizerApp` `@main`**
  - **Acción:** `App/ReviewSummarizerApp.swift`. Carga `AppConfiguration`, instancia `CompositionRoot`, lanza `ProductListView(viewModel:)`.
  - **Hecho:** La app compila y arranca al simulador mostrando estado loading.
  - **Depende de:** T-070, T-080

---

## Fase 7 — Presentation: componentes comunes (RF-13, RF-14)

- [x] **T-072 — `LoadingView`**
  - **Acción:** `Presentation/Common/LoadingView.swift`. `ProgressView` centrada con etiqueta opcional.
  - **Hecho:** Renderiza en preview.
  - **Depende de:** T-001

- [x] **T-073 — `ErrorView`**
  - **Acción:** `Presentation/Common/ErrorView.swift`. Recibe `message: String` y `retry: () -> Void`. Botón "Reintentar".
  - **Hecho:** Preview con tap funcional.
  - **Depende de:** T-001

- [x] **T-074 — `EmptyStateView`**
  - **Acción:** `Presentation/Common/EmptyStateView.swift`. Recibe `title`, `message`, opcional `action`.
  - **Hecho:** Preview con y sin CTA.
  - **Depende de:** T-001

---

## Fase 8 — Presentation: Lista de productos (RF-02, RF-03, RF-10, RF-13, RF-14, RF-16, RF-17)

- [x] **T-080 — `ProductListItemUIModel`**
  - **Acción:** `Presentation/ProductList/UIModels/ProductListItemUIModel.swift` con `RatingDisplay` enum (§4.4).
  - **Hecho:** Compila como `Sendable, Hashable`.
  - **Depende de:** T-002

- [x] **T-081 — Mapper `Product → ProductListItemUIModel`**
  - **Acción:** Función pura en el mismo archivo o en `Presentation/ProductList/Mappers/`. Recibe `Product`, `cachedSummaryIds: Set<String>`, `averageRating: AverageRating`. Formatea `RatingDisplay.value("4.0")` o `.unrated`.
  - **Hecho:** Compila; cubierto por test en T-130.
  - **Depende de:** T-021, T-028, T-080

- [x] **T-082 — `ProductListViewModel`**
  - **Acción:** `Presentation/ProductList/ProductListViewModel.swift`. `@MainActor @Observable final class`. Estados `loading | success([UIModel]) | empty | error`. Método `load()` que invoca `FetchProductsUseCase` + `SummaryRepository.fetchAllProductIds()` y mapea a UI models. Método `refresh()` para pull-to-refresh.
  - **Hecho:** Compila; método `cancel()` invalida tarea en curso (RF-15).
  - **Depende de:** T-026, T-030, T-081

- [x] **T-083 — `RatingBadgeView`**
  - **Acción:** `Presentation/ProductList/Components/RatingBadgeView.swift`. Renderiza `RatingDisplay` (estrella + número, o "Sin calificación").
  - **Hecho:** Preview cubre ambos casos.
  - **Depende de:** T-080

- [ ] **T-084 — `ProductRowView`** `[REABRIR]`
  - **Acción:** `Presentation/ProductList/Components/ProductRowView.swift`. Imagen (`AsyncImage` con placeholder), título, rating badge, cantidad de reviews, indicador "tiene resumen" (badge/ícono — S-14).
  - **Hecho:** Preview con `hasCachedSummary = true` y `false`.
  - **Depende de:** T-080, T-083
  - **🔧 Ajuste v1.1 (RF-17 / §10.5):** la implementación actual del `AsyncImage` probablemente usa el inicializador con `placeholder` genérico, que **no diferencia entre `.empty` y `.failure`** y por lo tanto no cubre el criterio "Si la imagen falla, se muestra placeholder" (CA-RF-02). Migrar a la variante `phase`-based:
    ```swift
    AsyncImage(url: model.imageURL) { phase in
        switch phase {
        case .empty:           PlaceholderView()
        case .success(let img): img.resizable().scaledToFill()
        case .failure:         PlaceholderView()
        @unknown default:      PlaceholderView()
        }
    }
    ```
    Render concreto:
    - `.empty` → placeholder (color sólido + icono o spinner discreto).
    - `.success(let image)` → `image.resizable().scaledToFill()` con clipping al tamaño de celda.
    - `.failure` → mismo placeholder que `.empty` (no mostrar texto de error en celda; la lista no se rompe).

    Nada de Nuke/Kingfisher. La caché es la `URLCache` por defecto de `URLSession.shared`. **Hecho actualizado:** preview cubre los tres casos forzando una URL válida de Picsum, una URL inválida (ej. `URL(string: "https://picsum.photos/this-fails")`) y una URL `nil`. Tras el fix, marcar `[x]`.

- [x] **T-085 — `ProductListView`**
  - **Acción:** `Presentation/ProductList/ProductListView.swift`. `NavigationStack` con `List`/`ScrollView`. Soporta `.refreshable` (RF-16). Maneja los 4 estados con los componentes comunes.
  - **Hecho:** En simulador con mock corriendo, lista 100 productos.
  - **Depende de:** T-072, T-073, T-074, T-082, T-084

- [x] **T-086 — Navegación a detalle desde la lista**
  - **Acción:** `NavigationLink(value: product)` y `.navigationDestination(for: Product.self)` que construye `ProductDetailView` vía `CompositionRoot.makeProductDetailViewModel(product:)`.
  - **Hecho:** Tap en celda navega al detalle.
  - **Depende de:** T-070, T-085, T-094

---

## Fase 9 — Presentation: Detalle de producto (RF-04..RF-12, RF-15, RF-17)

- [x] **T-090 — `SummaryUIState` enum**
  - **Acción:** `Presentation/ProductDetail/UIModels/SummaryUIState.swift` con los 7 casos del §4.4.
  - **Hecho:** Compila como `Equatable`.
  - **Depende de:** T-023

- [x] **T-091 — `ProductDetailViewModel` (carga inicial)**
  - **Acción:** `Presentation/ProductDetail/ProductDetailViewModel.swift`. `@MainActor @Observable`. En `onAppear()`: consulta `availability` del summarizer, `GetCachedSummaryUseCase`, decide estado inicial (`available`, `none`, `unsupported`, `disabledByThreshold`).
  - **Hecho:** Compila; matriz de estado coincide con spec §6.2.
  - **Depende de:** T-027, T-029, T-031, T-090

- [x] **T-092 — `ProductDetailViewModel.generateSummary()`**
  - **Acción:** Lanza `Task` que setea `.generating`, llama `GenerateSummaryUseCase`, mapea éxito → `.available`, error → `.error`, `CancellationError` → silencio (§5.5).
  - **Hecho:** Compila; `generationTask?.cancel()` en `onDisappear()` (RF-11, RF-15).
  - **Depende de:** T-032, T-091

- [x] **T-093 — `ProductDetailViewModel.regenerateSummary()`**
  - **Acción:** Igual que `generateSummary()` pero conserva `lastKnownSummary` para no perderlo en error (CA-RF-09).
  - **Hecho:** En error, `summaryState == .error`; `lastKnownSummary` intacto.
  - **Depende de:** T-092

- [ ] **T-094 — `ProductDetailView` (esqueleto)** `[REABRIR]`
  - **Acción:** `Presentation/ProductDetail/ProductDetailView.swift`. Header con imagen, título, rating, total de reviews. Lista de reviews **en el orden del servicio** (S-15).
  - **Hecho:** Preview con `Product.fixture()`.
  - **Depende de:** T-091
  - **🔧 Ajuste v1.1 (RF-17 / §10.5):** la imagen del header sigue la misma política que en T-084. Si se reusó un componente compartido para `AsyncImage` (recomendado), corregirlo en un solo lugar y este reabrir se cierra automáticamente. Si no se reusó, aplicar el mismo cambio acá: `AsyncImage` `phase`-based con placeholder en `.empty` y `.failure`. El detalle no debe romperse si la imagen externa no carga — el resto del contenido (título, rating, reviews, sección de resumen) renderiza igual. **Hecho actualizado:** preview cubre fixture con URL Picsum válida y fixture con `imageURL = nil`. Tras el fix, marcar `[x]`.

- [x] **T-095 — `ReviewRowView`**
  - **Acción:** `Presentation/ProductDetail/Components/ReviewRowView.swift`. Muestra autor, rating (estrellas), texto.
  - **Hecho:** Preview con review fixture.
  - **Depende de:** T-020

- [x] **T-096 — `GenerateSummaryButton`**
  - **Acción:** `Presentation/ProductDetail/Components/GenerateSummaryButton.swift`. Recibe `SummaryUIState` y dos closures (`generate`, `regenerate`). Resuelve título y `disabled` según estado. Muestra mensajes informativos para `.unsupported` y `.disabledByThreshold` (RF-05, RF-12).
  - **Hecho:** Preview con los 7 estados.
  - **Depende de:** T-090

- [x] **T-097 — `SummarySectionView`**
  - **Acción:** `Presentation/ProductDetail/Components/SummarySectionView.swift`. Renderiza las 4 secciones (sentimiento, fuertes, débiles, tagline) con jerarquía tipográfica clara (RF-07).
  - **Hecho:** Preview con `ReviewSummary.fixture()`.
  - **Depende de:** T-023

- [x] **T-098 — Cablear detalle completo**
  - **Acción:** En `ProductDetailView`, integrar `GenerateSummaryButton`, `SummarySectionView` (cuando `.available`), `LoadingView` inline cuando `.generating`, `ErrorView` cuando `.error`. Wire `onAppear/onDisappear` al ViewModel.
  - **Hecho:** Flujo completo: cargar → generar → ver resumen → regenerar funciona en simulador con AI disponible.
  - **Depende de:** T-072, T-073, T-094, T-095, T-096, T-097

---

## Fase 10 — Localización y accesibilidad (RNF-05, RNF-06)

- [x] **T-100 — `Localizable.strings` en español**
  - **Acción:** `Resources/Localizable.strings` (es). Incluir copys: títulos, "Sin calificación", "Generar resumen", "Regenerar", "AI no disponible en este dispositivo", "Necesita más de 5 reviews para generar un resumen", errores.
  - **Hecho:** Compila; reemplaza todos los strings hardcodeados de las views.
  - **Depende de:** T-085, T-098

- [x] **T-101 — Sustituir literales por `String(localized:)`**
  - **Acción:** Recorrer Views/ViewModels y reemplazar literales por `String(localized: "key")`.
  - **Hecho:** Búsqueda de literales en `Presentation/` no encuentra strings de UI.
  - **Depende de:** T-100

- [x] **T-102 — Accesibilidad mínima**
  - **Acción:** `accessibilityLabel` significativo en imágenes de producto, botón de generar, indicador de resumen disponible. Soporte de Dynamic Type vía `.font(.body)` y similares (RNF-05).
  - **Hecho:** VoiceOver lee elementos con etiquetas claras; texto escala con Dynamic Type largest.
  - **Depende de:** T-098

---

## Fase 11 — Tests de dominio (RNF-08, §9.2)

- [x] **T-110 — Tests `ComputeAverageRatingUseCase`**
  - **Acción:** Casos `[5,4,3] → .value(4.0)`, `[] → .unrated`, `[4] → .value(4.0)`, redondeo a 1 decimal `[5,4] → .value(4.5)`, `[4,4,3] → .value(3.7)` (CA-RF-03).
  - **Hecho:** Suite verde con ≥ 5 casos.
  - **Depende de:** T-006, T-028

- [x] **T-111 — Tests `CanGenerateSummaryUseCase`**
  - **Acción:** Casos 0, 1, 5, 6, 20 → false/false/false/true/true (CA-RF-05).
  - **Hecho:** 5 `@Test` verdes.
  - **Depende de:** T-006, T-029

- [x] **T-112 — `SummaryRepositorySpy` y `SummarizerServiceMock`**
  - **Acción:** `ReviewSummarizerTests/Doubles/`. Spy registra `upsert` (parámetro y count). Mock con `func summarize` configurable (success/failure/cancellation/delay).
  - **Hecho:** Compila; usables desde tests.
  - **Depende de:** T-026, T-027

- [x] **T-113 — Tests `GenerateSummaryUseCase`**
  - **Acción:** (a) éxito → `upsert` invocado 1 vez con el resumen correcto; (b) error → `upsert` no se llama; (c) cancelación durante summarize → `upsert` no se llama y propaga `CancellationError` (CA-RF-09, CA-RF-15).
  - **Hecho:** 3 `@Test` verdes.
  - **Depende de:** T-032, T-112

- [x] **T-114 — Tests `FetchProductsUseCase`**
  - **Acción:** Stub `ProductRepository`. Casos: lista vacía, lista válida, error de red propagado. Verifica que `imageURL` se mantiene como vino del repo (no responsabilidad del use case).
  - **Hecho:** 3 `@Test` verdes.
  - **Depende de:** T-030

- [x] **T-115 — Tests `Sentiment` y `ReviewSummary` (smoke)**
  - **Acción:** `Sentiment(rawValue:)` sobre los 3 valores; tagline ≤ 140 chars en fixture.
  - **Hecho:** Suite verde.
  - **Depende de:** T-023

---

## Fase 12 — Tests de data (§9.3)

- [x] **T-120 — Tests `ProductDTO+Mapping`**
  - **Acción:** Casos: `imageUrl = nil` → `imageURL = nil`; `imageUrl = "not a url with spaces"` → `nil`; `rating = 0` o `6` → review filtrada; `reviews = nil` → `[]`.
  - **Hecho:** ≥ 5 `@Test` verdes.
  - **Depende de:** T-006, T-042

- [x] **T-121 — Tests `SwiftDataSummaryRepository` con container in-memory**
  - **Acción:** `ModelContainer(for: PersistedSummary.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))`. Casos: insert + fetch; upsert reemplaza (mismo `productId`); `fetchAllProductIds` devuelve set correcto; `delete` elimina.
  - **Hecho:** 4 `@Test` verdes (RN-02, RN-03, CA-RF-08, CA-RF-09).
  - **Depende de:** T-006, T-052

- [x] **T-122 — Test `URL+Append`**
  - **Acción:** Casos: base con/sin trailing slash + path con/sin leading slash → URL concatenada correcta.
  - **Hecho:** 4 `@Test` verdes.
  - **Depende de:** T-006, T-014

- [x] **T-123 — Test `PromptBuilder.truncated`**
  - **Acción:** Review con texto de 1000 chars truncada a 600 mantiene los primeros 600. Texto corto no se modifica.
  - **Hecho:** 2 `@Test` verdes.
  - **Depende de:** T-006, T-065

---

## Fase 13 — Tests de presentation (§9.4)

- [x] **T-130 — Test mapper `Product → ProductListItemUIModel`**
  - **Acción:** Producto con reviews `[5,4,3]` → `ratingDisplay == .value("4.0")`. Producto sin reviews → `.unrated`. `cachedSummaryIds` contiene el id → `hasCachedSummary == true`.
  - **Hecho:** 3 `@Test` verdes (RF-03, RF-10).
  - **Depende de:** T-006, T-081

- [x] **T-131 — Tests `ProductListViewModel`**
  - **Acción:** Stub repo + summary repo. Casos: éxito con productos → estado `.success`; respuesta vacía → `.empty`; error → `.error`; `refresh()` re-dispara la carga.
  - **Hecho:** 4 `@Test` verdes (CA-RF-13, CA-RF-14, CA-RF-16).
  - **Depende de:** T-006, T-082, T-112

- [x] **T-132 — Tests `ProductDetailViewModel` — disponibilidad y estado inicial**
  - **Acción:** Mock summarizer con `availability = .unavailable(.deviceNotEligible)` → estado `.unsupported`. Producto con 5 reviews → `.disabledByThreshold(needed: 6)`. Producto con resumen cacheado → `.available(summary)`.
  - **Hecho:** 3 `@Test` verdes (RF-05, RF-12, RF-08).
  - **Depende de:** T-006, T-091, T-112

- [x] **T-133 — Tests `ProductDetailViewModel.generateSummary`**
  - **Acción:** Éxito → `.available` y spy.upsertCount == 1. Error → `.error` y spy.upsertCount == 0. Cancelación → estado no cambia a `.error` y spy.upsertCount == 0.
  - **Hecho:** 3 `@Test` verdes (CA-RF-09, CA-RF-15).
  - **Depende de:** T-006, T-092, T-112

- [x] **T-134 — Test `regenerateSummary` preserva resumen previo en error**
  - **Acción:** ViewModel inicializado con `lastKnownSummary` no-nil. Mock devuelve error. Verifica `summaryState == .error` y `lastKnownSummary` igual al anterior.
  - **Hecho:** 1 `@Test` verde (CA-RF-09).
  - **Depende de:** T-006, T-093

---

## Fase 14 — Mock y verificación QA

- [ ] **T-140 — JSON mock con 100+ productos** `[REABRIR]`
  - **Acción:** `Resources/Mocks/products.json` con 100+ productos, cada uno con 0–20 reviews, `rating ∈ 1...5`, autores, textos en español. Mezcla intencional: algunos con 0, 5, 6, 20 reviews para cubrir umbrales.
  - **Hecho:** JSON válido; al menos 5 productos con > 5 reviews.
  - **Depende de:** —
  - **🔧 Ajuste v1.1 (RF-17 / §6.2):** abrir el `products.json` actual y verificar/corregir los `imageUrl`. Deben apuntar a Picsum con seed determinista por producto:
    ```
    "imageUrl": "https://picsum.photos/seed/{id}/400/400"
    ```
    El mock **no aloja binarios** — solo entrega URLs como strings. Garantizar que: (a) todas son HTTPS, (b) el seed deriva del `id` para que sean estables entre relaunches y útiles para el caché de `URLSession.shared`, (c) **al menos 1 producto** del mock incluye una `imageUrl` deliberadamente rota (ej. ruta inexistente bajo el dominio Picsum, como `https://picsum.photos/notfound/{id}`) para validar fallback en T-148. Si el script generador del mock está versionado, ajustarlo y regenerar; si no, edición manual. **Hecho actualizado:** JSON válido, 100+ productos, ≥ 5 productos con > 5 reviews, `imageUrl` apuntando a Picsum, ≥ 1 producto con `imageUrl` rota para QA. Tras el fix, marcar `[x]`.

- [ ] **T-141 — Configurar Proxyman**
  - **Acción:** Crear regla en Proxyman que sirva `products.json` para `GET http://localhost:9090/products`. Documentar puerto y archivo.
  - **Hecho:** `curl http://localhost:9090/products` devuelve el JSON.
  - **Depende de:** T-140

- [ ] **T-142 — Smoke test end-to-end manual: lista** `[REVISAR]`
  - **Acción:** Con Proxyman corriendo, lanzar la app en simulador. Verificar: 100+ productos visibles, ratings con 1 decimal, "Sin calificación" en productos vacíos, pull-to-refresh recarga.
  - **Hecho:** Checklist de CA-RF-02, CA-RF-03, CA-RF-16 marcado a mano.
  - **Depende de:** T-085, T-141
  - **🔧 Ajuste v1.1 (RF-17 / CA-RF-02 ampliado):** agregar al checklist visual:
    - Las imágenes cargan desde `picsum.photos` (no se ven todas como placeholder).
    - Scroll a través de 100+ celdas no rompe layout cuando algunas imágenes tardan más que otras.
    - El producto con `imageUrl` rota (sembrado en T-140) muestra placeholder y la celda renderiza igual el título, rating y conteo de reviews (CA-RF-02 actualizado).

- [ ] **T-143 — Smoke test manual: generación de resumen**
  - **Acción:** En device real con Apple Intelligence on, abrir producto con > 5 reviews, generar resumen. Verificar las 4 secciones, persistencia tras kill+relaunch, regeneración reemplaza, modo avión también funciona (RF-06, RF-08, RF-09, CA-RF-06, CA-RF-08).
  - **Hecho:** Checklist verificado y capturado en demo.
  - **Depende de:** T-098, T-141

- [ ] **T-144 — Verificación de privacidad con Proxyman** `[REVISAR]`
  - **Acción:** Durante generación de resumen, observar tráfico en Proxyman. Confirmar 0 requests salientes (RNF-02, CA-RF-06).
  - **Hecho:** Captura limpia de Proxyman durante la inferencia.
  - **Depende de:** T-143
  - **🔧 Ajuste v1.1 (RNF-02 reformulado / §10.5):** la verificación ahora distingue **dos canales** y debe documentar ambos:
    - **Canal mock (`localhost`)**: GET inicial al endpoint `/products`. Después de cargada la lista, no debería haber más tráfico aquí (salvo pull-to-refresh).
    - **Canal Picsum (`picsum.photos`)**: GETs HTTPS anónimos durante la carga inicial y al revelar nuevas celdas en el scroll. **Inspeccionar URL y headers**: solo GET, sin Authorization, sin cookies persistentes, sin texto de reviews ni resultado de la AI en el path o query.
    - **Durante la generación de resumen**: 0 tráfico en ambos canales (la AI no necesita red). Esta es la verificación clásica de RNF-02.

    **Hecho actualizado:** dos capturas de Proxyman:
    1. Carga de lista — solo `localhost/products` + GETs anónimos a `picsum.photos`.
    2. Inferencia AI — silencio total en ambos canales.

- [ ] **T-145 — Verificación de fallback de AI**
  - **Acción:** Con device sin soporte (o desactivando Apple Intelligence), confirmar mensaje "AI no disponible en este dispositivo" y que el resto de la app funciona (RF-12, CA-RF-12).
  - **Hecho:** Captura del estado `.unsupported`.
  - **Depende de:** T-098

- [ ] **T-146 — Verificación de cancelación**
  - **Acción:** Iniciar generación, salir del detalle inmediatamente. Confirmar (vía logs) que `Task` se canceló y no hubo `upsert`. Repetir con kill de la app durante generación.
  - **Hecho:** Logs `os.Logger` muestran `cancellation`; sin escrituras posteriores (CA-RF-15).
  - **Depende de:** T-098

- [ ] **T-147 — Verificación de cambio de URL base**
  - **Acción:** Cambiar `BACKEND_BASE_URL` en xcconfig a otro puerto, relanzar. Confirmar que la app pega al nuevo host. Probar también override por launch argument (CA-RF-01).
  - **Hecho:** Ambos mecanismos funcionan.
  - **Depende de:** T-012, T-085

- [ ] **T-148 — Verificación de fallback de imagen** `[NUEVA v1.1]`
  - **Acción:** Cubrir RF-17 / CA-RF-02 actualizado. Tres escenarios manuales:
    1. **URL rota sembrada en mock** (de T-140): la celda muestra placeholder y todo el resto de la información (título, rating, conteo, indicador de resumen) renderiza correcto.
    2. **Sin conectividad a Picsum** (deshabilitar red en simulador después de cargar la lista, o bloquear `picsum.photos` en Proxyman/firewall): nuevas celdas que aparecen en scroll muestran placeholder; las ya cacheadas siguen visibles.
    3. **Apertura del detalle** del producto con imagen rota: el header de detalle también muestra placeholder y permite reviewing/generación de resumen normal.
  - **Hecho:** Tres capturas de pantalla cubriendo los tres escenarios; la app no crashea, no muestra estado de error global y mantiene navegación.
  - **Depende de:** T-084, T-094, T-141 (todas previamente cerradas)

---

## Fase 15 — Entregables finales

- [ ] **T-150 — README de proyecto** `[REVISAR]`
  - **Acción:** Crear `README.md` con: descripción, requisitos (Xcode, iOS, device con Apple Intelligence), pasos de build, configuración de Proxyman, cómo cambiar `BACKEND_BASE_URL`, cómo correr tests, limitaciones conocidas (map-reduce no implementado), trazabilidad a `spec.md` y `plan.md`.
  - **Hecho:** README presente en raíz; alguien externo podría correr la app siguiéndolo.
  - **Depende de:** T-141, T-142, T-143
  - **🔧 Ajuste v1.1 (RF-17 / spec §10.2 / plan §10.5, §11):** el README debe incluir además:
    - **Sección "Origen de imágenes"**: las imágenes vienen de Picsum (`https://picsum.photos`), el mock no aloja binarios, fallback es placeholder nativo de `AsyncImage`.
    - **Sección "Privacidad" / "Tráfico de red"**: explicar los dos canales (localhost para datos / Picsum para imágenes). Aclarar que la AI sigue 100 % on-device y que las requests a Picsum son anónimas y no transportan texto de reviews ni resultados de la AI.
    - **Sección "Riesgos conocidos"**: caída o latencia alta de Picsum durante demo (mitigación: pre-warmear caché navegando una vez antes de grabar el video — plan §11).
    - **Trazabilidad ampliada**: agregar fila para RF-17 en la tabla de cobertura.

- [ ] **T-151 — Commits limpios y push final**
  - **Acción:** Revisar historial git (rebase si hay ruido), tags por fase si conviene. Push a repositorio.
  - **Hecho:** `git log` legible; commits agrupan cambios coherentes.
  - **Depende de:** T-150

- [ ] **T-152 — Video demo (1–2 min)**
  - **Acción:** Grabar pantalla mostrando: lista, detalle, generación de resumen con las 4 secciones, regeneración, persistencia tras relaunch, fallback de AI (si es posible).
  - **Hecho:** Video adjunto al entregable.
  - **Depende de:** T-143, T-145

- [ ] **T-153 — Revisión final de trazabilidad**
  - **Acción:** Recorrer la tabla §12 del `plan.md` y la lista de criterios de aceptación del `spec.md` §7. Marcar cada uno con tarea concreta cumplida. Levantar issues si algo quedó parcial.
  - **Hecho:** Tabla de trazabilidad sin huecos.
  - **Depende de:** T-150, T-151, T-152

---

## Notas de ejecución

- **Camino crítico restante:** T-011 (cierre rápido, ~5 min de verificación) → T-084 + T-094 (cambio de `AsyncImage`, ~20 min combinados si hay componente compartido) → T-140 (regeneración o edición de mock, ~15 min) → T-141 → T-142 → T-148 → T-143..T-147 → fase 15.
- **Esfuerzo estimado del rebase:** ≈ 1 h de implementación (T-011 + T-084 + T-094 + T-140) + ≈ 30 min adicionales de QA por T-148. Total: **~1.5 h** sumadas al backlog ya planificado de fase 14 + 15.
- **Dependencias externas:** T-141 requiere Proxyman instalado y corriendo. T-143/T-145 idealmente en device físico con Apple Intelligence habilitado. T-148 requiere conectividad a `picsum.photos` para los escenarios 1 y 3, y capacidad de bloquearla para el escenario 2.
- **Suite de tests:** sigue intacta. No hay tests reabiertos. Si después del cambio en T-084/T-094 se decide cubrir el switch de `AsyncImagePhase` (con una vista testeable separable), sería un test nuevo opcional que no estaba en el plan v1.0 — no se agrega tarea por defecto porque el plan §9.1 explícitamente excluye tests de UI.
