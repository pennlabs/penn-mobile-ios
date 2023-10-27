//
//  DiningDiffusionView.swift
//  PennMobile
//
//  Created by Justin Sun on 10/6/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI
import Replicate

private let client = Replicate.Client(token: "r8_7Wb0b5u1FtwPWtSuM3zcetXc1aS2N1Y1wWTkx")

enum StableDiffusion: Predictable {
  static var modelID = "stability-ai/stable-diffusion"
  static let versionID = "ac732df83cea7fff18b8472768c88ad041fa750ff7682a21affe81863cbe77e4"

  struct Input: Codable {
      let prompt: String
  }

  typealias Output = [URL]
}

struct DiningDiffusionView: View {
    init(for venues: [DiningVenue]) {
        self.venues = venues
        self.predictions = [:]
    }

    private let venues: [DiningVenue]

    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @State private var predictions: [String: StableDiffusion.Prediction]
    @State private var generated = false

    func genPrompt(venue: DiningVenue) -> String {
        var prompt = "Cafeteria food with "
        let menus = diningVM.diningMenus[venue.id]
        if menus != nil && menus?.menus.count ?? 0 > 0 {
            let stations = menus?.menus[venue.currentMealIndex ?? 0].stations
            for station in stations ?? [] {
                print(station.name)
                if station.name != "coffee" &&
                    station.name != "Ice Cream" &&
                    station.name != "sweets & treats" &&
                    station.name != "fruit & yogurt" &&
                    station.name != "kettles" &&
                    station.name != "ice cream bar" &&
                    station.name != "beverages" &&
                    station.name != "cereal" &&
                    station.name != "condiments" &&
                    station.name != "breads and toast" &&
                    station.name != "salad bar" &&
                    station.name != "fruit plus" {
                    for item in station.items {
                        prompt += item.name + ", "
                    }
                }
            }
        }
        print(prompt)
        return prompt
    }

    func generate() async {
        for venue in venues {
            let prompt = genPrompt(venue: venue)
            if prompt != "Cafeteria food with " {
                do {
                    let predictionResult = try await StableDiffusion.predict(with: client, input: .init(prompt: genPrompt(venue: venue)), wait: true)
                    predictions[venue.name] = predictionResult
                } catch {
                    print("Error predicting: \(error)")
                }
            }
        }
        generated = true
    }

    func cancel() async throws {
        for var (_, prediction) in predictions {
            do {
                try await prediction.cancel(with: client)
            } catch {
                print("Error canceling: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            if !generated {
                VStack {
                    ProgressView("Generating...")
                        .padding(32)
                    Button("Cancel") {
                        Task { try await cancel() }
                    }.buttonStyle(.borderedProminent)
                }
                .padding()
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(Array(predictions.keys), id: \.self) { venue in
                    ZStack {
                        Color.clear
                            .aspectRatio(1.0, contentMode: .fit)
                        switch predictions[venue]?.status {
                        case .starting, .processing, .succeeded, .none:
                            if let url = predictions[venue]?.output?.first {
                                AsyncImage(url: url, scale: 1.0, content: { phase in
                                    phase.image?
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(16)
                                })
                                Text(venue)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .shadow(radius: 2)
                            }
                        case .failed:
                            Text(predictions[venue]?.error?.localizedDescription ?? "Unknown error")
                                .foregroundColor(.red)
                        case .canceled:
                            Text("The prediction was canceled")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                }
            }
        }
        .task {
            if !generated {
                await generate()
            }
        }
    }
}
