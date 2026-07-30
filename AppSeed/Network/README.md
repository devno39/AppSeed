# Network

Two layers live here: the **Supabase domain service layer** (first-class, protocol-oriented,
what ViewModels consume for app data) and the **HTTP + AI shelf** (a generic Alamofire
request manager feeding the GPT / DALLE / Replicate / Fal.ai services). The shelf is
optional infrastructure — kept, wired only when an app needs generative features.

## Layout

```
Network/
├── Protocols/           # RequestProtocols, RequestObjectProtocol, RequestArrayProtocol, QueryParameters
├── RequestsManager/     # RequestManager (+Error, +Image), BaseUrl — the generic HTTP core
├── Responses/           # ResponseError, ResponseErrorGPT
└── Services/
    ├── Gpt/             # RequestGPT + ResponseGPT
    ├── Dalle/           # RequestDALLE + ResponseDALLE
    ├── Replicate/       # RequestReplicate + ResponseReplicate
    ├── Falai/           # RequestFalaiQueue/Requests + ResponseFalai(+Queue/Status), FalaiStatus
    ├── Models/          # GPTModels
    ├── Services/        # GptService (concrete AI service)
    └── Supabase/        # ACTIVE domain layer
        ├── Protocols/   # UserServiceProtocol, ItemServiceProtocol, ListenerHandle
        ├── Models/      # User, ItemModel (Codable, snake_case CodingKeys)
        ├── User/        # SupabaseUserService  — single-row listener
        └── Item/        # SupabaseItemService  — collection listener
```

## Supabase domain services (`Services/Supabase/`)

ViewModels depend on protocols, not concrete types — swapping backend = swapping the
implementation. The seed ships two domains, one per listener shape: **User** (a single row)
and **Item** (a collection).

- `UserServiceProtocol` — user CRUD + the row listener.
- `ItemServiceProtocol` — collection CRUD + the list listener. Copy this pair for a new table.
- `SupabaseRealtimeDecoder` (in `Helpers/Supabase/Database/`) — decodes a change event's
  record so a single-row listener can skip the REST round trip. Postgres sends microsecond
  fractions that `ISO8601DateFormatter` cannot read, which is the whole reason it exists.
- `ListenerHandle` — backend-agnostic listener wrapper; the owner stores the handle and cancels on teardown.
- `SupabaseUserService` — the active implementation, injected in each feature's Builder:

```swift
final class ProfileBuilder: BaseBuilder {
    func build() -> UIViewController {
        let viewModel = ProfileViewModel(userService: SupabaseUserService())
        // router → viewModel → viewController → return
    }
}
```

New feature = add a `{X}ServiceProtocol` under `Supabase/Protocols/` and a
`Supabase{X}Service` under `Supabase/`. RPCs live in their owning service — no generic
rpc helper.

## HTTP + AI shelf (`RequestsManager/`, `Services/Gpt|Dalle|Replicate|Falai/`)

`RequestManager` is a generic Alamofire wrapper: a request conforms to
`RequestObjectProtocol` / `RequestArrayProtocol` (endpoint, method, params, `showLoading`),
and the manager decodes into a `Codable` response or a `ResponseError`. The AI services
(`GptService` and the DALLE/Replicate/Fal.ai request+response pairs) are built on it. Wire
them only for generative features; otherwise they sit unused as a shelf.

## Conventions

1. All response models are `Codable` with **optional** fields — treat the backend as untrusted.
2. ViewModels accept the protocol, not the concrete type — Builders inject the implementation.
3. Reads distinguish failure from absence — a transient error must never render as "data gone".
4. Realtime listeners are wrapped by `ListenerHandle`; store the handle on the owner and cancel on teardown.
5. Adding a service → update this README in the same commit.
