//
//  @BackendFetched.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 9/12/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI

/// Fetches a `PennMobileEndpoint` the first time the view renders and exposes the decoded response. Requires handling of all three states: not-yet-fetched, failure, and success
///
///     struct MyView: View {
///         @BackendFetched(PennMobileApplication.Dining.GetVenues()) var venues: BackendFetchedResult<[DiningVenue], Error>
///
///         var body: some View {
///             Group {
///                 switch venues {
///                 case .success(let venuesArr):
///                     List(venuesArr) { venue in
///                         Text(venue.name)
///                     }
///                 case .failure(let error):
///                     Text(error.localizedDescription)
///                 case .pending:
///                     EmptyView()
///                 }
///             }
///             .overlay { if $venues.isLoading { ProgressView() } }
///             .refreshable { await $venues.refresh() }
///         }
///     }
@MainActor
@propertyWrapper
public struct BackendFetched<Endpoint: PennMobileEndpoint>: DynamicProperty {
    private let endpoint: Endpoint

    @State private var response: BackendFetchedResult<Endpoint.Response>
    @State public private(set) var isLoading = false
    @State private var hasFetched = false

    /// - Parameter useCacheIfAvailable: Starts with the endpoint's cached result, if any, while the first fetch loads. The endpoint must use `.get(cacheAge:)` with a non-nil age.
    public init(_ endpoint: Endpoint, useCacheIfAvailable: Bool = false) {
        self.endpoint = endpoint
        self.response = useCacheIfAvailable ? endpoint.loadFromCache() : .pending
    }

    public var wrappedValue: BackendFetchedResult<Endpoint.Response> {
        response
    }

    public var projectedValue: Self {
        self
    }

    @MainActor
    public func refresh() async {
        isLoading = true
        response = await endpoint.execute()
        isLoading = false
    }

    // SwiftUI always calls update() on the main thread, but DynamicProperty isn't annotated as such
    nonisolated public func update() {
        MainActor.assumeIsolated {
            guard !hasFetched else { return }
            // State written during update() isn't visible until the update finishes,
            // so check and set it afterwards to avoid kicking off duplicate fetches.
            Task { @MainActor in
                guard !hasFetched else { return }
                hasFetched = true
                await refresh()
            }
        }
    }
}
