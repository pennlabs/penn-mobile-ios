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
