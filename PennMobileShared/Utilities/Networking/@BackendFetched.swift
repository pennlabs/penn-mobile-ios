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
///             if case .success(let venuesArr) = venues {
///                 List(venuesArr) { venue in
///                     Text(venue.name)
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

    @State private var response: BackendFetchedResult<Endpoint.Response, Error>
    @State public private(set) var isLoading = false
    @State private var hasFetched = false

    public init(_ endpoint: Endpoint) {
        self.endpoint = endpoint
        self.response = .pending
    }

    public var wrappedValue: BackendFetchedResult<Endpoint.Response, Error> {
        response
    }

    public var projectedValue: Self {
        self
    }

    @MainActor
    public func refresh() async {
        isLoading = true
        do {
            response = .success(try await PennMobileBackend.executeEndpoint(endpoint))
        } catch {
            response = .failure(error)
        }
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
