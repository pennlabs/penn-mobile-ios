# Penn Mobile Standardized Development Guidelines
(Updated 11/04/2026 by @jonathanmelitski)

## Introduction / Tour des Codebase

Penn Mobile has three deployment targets: PennMobile, Widget, and PennMobileShared. This is by necessity. Since much of the models and networking logic must be shared between the PennMobile app target and the Widget target, it is more sensible to place those objects in the PennMobileShared framework as opposed to duplicating that logic in both places.

This codebase is designed to provide a very high degree of separation between networking logic and view logic. That is, with respect to MVVM (Model-View-ViewModel) approaches to development, M- exists strictly in PennMobileShared, and -VVM are the responsibility of PennMobile (or the widget target, though that logic is different).

Put more plainly, the Penn Mobile target should only be responsible for views, displaying data and handling user interaction. Network calls, error handling (surfacing errors at the appropriate time), authentication, caching, etc. are \*intentionally\* abstracted away from the Penn Mobile target to lead to a better development experience.

### PennMobileShared
PennMobileShared consists of an Applications folder, which contains subfolders for all the individual features ("applications") of Penn Mobile. Each is defines as an extension of `PennMobileApplication`, which is defined in `ApplicationRoot.swift`. Each subfolder consists of a "Models" folder and a "Routes" folder, as well as the file `<name>Application.swift`, which defines the extension to `PennMobileApplication`, as well as any high-level shared logic that belongs there (see `PollsApplication.swift` for an example of this shared logic).

This means that models belonging to a specific application should be in that applications /Models folder. As a development guideline, the Routes that we define for that application should also reference almost exclusively models that are defined in the adjacent Models folder.

#### "Routes"

##### Motivation
In the previous versions of Penn Mobile, network calls were not standardized across the application, leading to a very difficult development experience, as well as strange UI/UX bugs with respect to error handling. We've designed this new version to define, in a standard way, all the ways in which outbound network calls can be made. By building a standard protocol (see `Utilities/Networking/PennMobileEndpoint.swift`) for network calls, error handling as well as the general semantics are common across the application, leading to a more stable UX and a more intuitive DX.

##### Getting Started with Routes
A route is simply an API call, and one of the easiest ways to get started is to look through, and seek to understand the Utilities/Networking folder of PennMobileShared. Further, look at an example application for reference and guidance on how to use routes and why defining them in this way leads to a better development experience.

#### Extensions
There's a bunch of extensions to standard library in the Extensions folder of PennMobileShared, where an extension to the `String` class will be called `String+Extensions.swift`. Defining extensions here leads to a standardized place for standard library extensions, since this logic was spread out in the old codebase. Not all of them (probably very few of them) are actually used in production, but I couldn't justify getting rid of them, since they're likely still good logic.

### Penn Mobile
There's a lot of setup and other high-level/root-of-the-app logic in the Penn Mobile folder, but the day-to-day will likely take place in the Applications folder, which is designed to be, loosely, a mirror of the PennMobileShared Applications folder. Generally every Application in Penn Mobile should have a "Views" folder which contains SwiftUI views that pertain to that application. They should also likely define a root ViewModel with the same name as the application (`GSRViewModel.swift`, for example). See more rules about those guidelines below.

### Widget
TODO
## Development Guidelines

To assist a consistent development experience (and user experience), there's a few rules that we've come up with that should be adhered to throughout development.

1. No static singletons for view models in the Applications folder.
   1. There are some singletons in `NotificationDeviceTokenManager`, `PennMobileAuthManager`, etc., but these are exceptions since they service the entire application.
2. To that end, the root view for each application (say the main view for GSR) should own the core view model using `@State` (see `HomeView` for an example).
   1. This only works if the view model is `@Observable`. If you're still on `ObservableObject`, you'd need `@StateObject` instead, which is just another reason to move over (see rule 6). `GSRViewModel` is still on the old way and should get migrated at some point.
   2. **Child views generally shouldn't get handed the whole view model**. Pass them the data they actually need, plus closures or bindings for anything they need to do (`GSRMapToggleButton(isMapView: $vm.isMapView)` is a good example). This keeps child views dumb and reusable, and makes it obvious what each one actually depends on.
   3. Keep the view model's `init` cheap. SwiftUI holds on to the instance in `@State`, but it still runs the `init` every time the parent view gets rebuilt and just throws the extra copy away. So don't kick off network calls or anything heavy in there. Do your loading in a `.task { }` on the root view instead (see rule 3).
3. Tasks should originate from views and call async functions on view models. View models should not spawn unstructured tasks (`Task { }`) for business logic.
   1. Business logic is something like calling a PennMobileShared endpoint, calculating data, etc. This is as opposed to UI logic, which would be something like setting a variable that directly redraws a view.
   2. *Why this rule?* A `Task { }` is unstructured: nothing owns it. It isn't cancelled when the view goes away, the caller can't `await` it or know when it finished, and its errors and ordering relative to other work are lost. This makes concurrency bugs hard to reason about and the code hard to test. Instead, expose the logic as an `async` function on the view model and let the view decide how to run it:
      1. Prefer the `.task { }` view modifier for work tied to a view's lifetime (initial loads, etc.), since SwiftUI cancels it automatically when the view disappears.
      2. Use `Task { }` in the view for work triggered by user interaction (e.g. a button action).
   3. Structured concurrency *inside* an async function is fine and encouraged. `async let` and `withTaskGroup` keep child tasks scoped to the function that created them (see `HomeViewModel.refresh()` for an example).
   4. Optimistic UI does not need a separate task: update the state first, then `await` the network call in the same async function (see `HomeViewModel.respondToPoll(questionId:optionId:)` for an example).
4. Toasts should only be displayed as the direct result of a user interaction, or when the user would reasonably expect that some operation was going on that resulted in the toast.
   1. `PennMobileEndpoint` shows a toast on failure **by default**. Any call that is not the direct result of a user interaction must use `.execute(shouldSilentlyFail: true)`.
   2. Examples of calls that must fail silently:
      1. Fetching incidents on a timer, since those fetches take place in the background.
      2. Analytics. The user should never see failures for an automated analytics push.
      3. Registering the notification device token (see `NotificationDeviceTokenManager` for an example).
5. As a general rule: Penn Mobile is not a complicated app. It is not doing anything markedly difficult, and this should be reflected in our code.
6. Start building classes using `@Observable` when possible, since `@ObservableObject` will likely be deprecated in the next 5 years.
7. All network calls go through `PennMobileEndpoint`. No raw `URLSession` (or anything like it) in the Penn Mobile target, ever.
   1. If the endpoint you need doesn't exist yet, add a Route for it in the matching PennMobileShared application folder. It's a few lines, and you get error handling, toasts, auth and caching for free.
   2. *Why this rule?* This is the whole point of the Routes setup (see "Routes" above). The old codebase made network calls however it felt like, which is exactly how we ended up with weird, inconsistent error handling.
8. Anything fetched from the network should be stored as a `BackendFetchedResult` (`.pending`, `.success`, `.failure`), not as a separate `data`, `error`, etc.
   1. Storing those separately lets you end up in states that make no sense (say, having both data and an error at the same time). With `BackendFetchedResult` the view just switches on it and handles all three cases (see `HomeViewModel.polls` for an example).
   2. An `isLoading` flag next to it is fine for refreshes, where you want to keep showing the old data while the new stuff loads. `@BackendFetched` does exactly this.
   3. **If a view just needs to fetch one endpoint and show it, you probably don't need a view model at all.** Use the `@BackendFetched` property wrapper right in the view (see its doc comment for an example).
