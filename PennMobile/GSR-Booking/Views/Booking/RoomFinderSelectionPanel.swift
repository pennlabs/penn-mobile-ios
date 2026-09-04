//
//  RoomFinderSelectionPanel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 4/7/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct RoomFinderSelectionPanel: View {
    @ObservedObject var vm: GSRViewModel
    @StateObject var quickBook: GSRQuickBook
    @Binding var status: QuickBookStatus
    @Binding var scrollMode: GSRScrollMode
    @State var expectedWidth: CGFloat?
    @State var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    @Environment(\.gsrUnderlyingVerticalProxy) var vertProxy: ScrollProxyWrapper?
    @Environment(\.gsrUnderlyingHorizontalProxy) var horizProxy: ScrollProxyWrapper?
    
    @Namespace var namespace
    
    @Environment(\.colorScheme) var colorScheme
            
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
    
    init(vm: GSRViewModel, status: Binding<QuickBookStatus>, scrollMode: Binding<GSRScrollMode>) {
        _quickBook = StateObject(wrappedValue: GSRQuickBook(vm: vm, configuration: .init(defaultValueFor: vm.selectedLocation, with: vm.roomsAtSelectedLocation)))
        self._vm = ObservedObject(initialValue: vm)
        self._status = status
        self._scrollMode = scrollMode
    }
    
    var body: some View {
        let startBinding = Binding {
            quickBook.configuration.startTime.timeIntervalSince1970
        } set: { new in
            quickBook.configuration.startTime = Date(timeIntervalSince1970: new)
        }
        let endBinding = Binding {
            quickBook.configuration.endTime.timeIntervalSince1970
        } set: { new in
            quickBook.configuration.endTime = Date(timeIntervalSince1970: new)
        }
        
        VStack {
            Spacer()
            Group {
                switch status {
                case .search:
                    VStack {
                        RangeSlider(lowerValue: startBinding, upperValue: endBinding,
                                    bounds: quickBook.configuration.timeLower.timeIntervalSince1970...quickBook.configuration.timeUpper.timeIntervalSince1970, step: (30 * 60), minimumSpan: (30 * 60)) { time in
                            let str = formatter.string(from: Date(timeIntervalSince1970: time))
                            Text(str)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.primary)
                                .padding(4)
                                .background {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(.background)
                                            .shadow(radius: 2)
                                        RoundedRectangle(cornerRadius: 4)
                                            .foregroundStyle(Color("gsrAvailable"))
                                    }
                                }
                                .padding(.bottom, 8)
                        }
                            .tint(Color("gsrBlue"))
                            .padding(.horizontal)
                        Divider()
                            .padding()
                        VStack {
                            let rectangles: Int = vm.selectedLocation?.kind.maxConsecutiveBookings ?? 3
                            HStack {
                                ForEach(0..<rectangles, id: \.self) { rect in
                                    let minutes = (rect + 1) * 30
                                    let enabled = quickBook.configuration.durationsAllowed.contains(minutes)
                                    let durationStr = {
                                        let hours = minutes / 60
                                        let remainder = minutes % 60
                                        switch (hours, remainder) {
                                            case (0, let m): return "\(m) min"
                                            case (let h, 0): return "\(h) hr"
                                            case (_, _): return "\(String(format: "%.1f", (Double(minutes) / 60.0))) hr"
                                        }
                                    }()
                                    Text(durationStr)
                                        .foregroundStyle(enabled ? .white : .primary)
                                        .padding(16)
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundStyle(enabled ? Color("gsrBlue") : Color("gsrAvailable"))
                                        }
                                        .onTapGesture {
                                            withAnimation(.snappy(duration: 0.2)) {
                                                if enabled {
                                                    quickBook.configuration.durationsAllowed.removeAll(where: { $0 == minutes })
                                                } else {
                                                    quickBook.configuration.durationsAllowed.append(minutes)
                                                }
                                            }
                                        }
                                }
                            }
                            .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.8), trigger: quickBook.configuration.durationsAllowed)
                        }
                    }
                    .padding()
                    .background {
                        Group {
                            if colorScheme == .dark {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.thickMaterial)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                                    .shadow(radius: 2)
                            }
                        }
                        .matchedGeometryEffect(id: "background-rect", in: namespace)
                    }
                case .explore:
                    VStack {
                        Group {
                            Text("asdf")
                                .background {
                                    Group {
                                        if colorScheme == .dark {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.thickMaterial)
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.white)
                                                .shadow(radius: 2)
                                        }
                                    }
                                    .matchedGeometryEffect(id: "background-rect", in: namespace)
                                }
                        }
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.2)) {
                                status = .search
                            }
                        }
                            
                    }
                default:
                    EmptyView()
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
            Button {
                var new: QuickBookStatus {
                    switch status {
                    case .closed:
                        return .search
                    case .search:
                        return .explore
                    case .explore:
                        return .explore
                    }
                }
                if new == .explore {
                    let room = vm.roomsAtSelectedLocation.first!
                    let roomTimeslot = RoomTimeslot(room: room, timeslot: room.availability.first!)
                    self.scrollMode = .vertical
                    vertProxy?.proxy.scrollTo(room, anchor: .topLeading)
                    self.scrollMode = .horizontal
                    vertProxy?.proxy.scrollTo(roomTimeslot, anchor: .center)
                    
                    //horizProxy?.proxy.scrollTo(roomTimeslot, anchor: .center)
                }
                
                withAnimation(.snappy(duration: 0.2)) {
                    status = new
                }
            } label: {
                Group {
                    switch status {
                    case .closed:
                        Label("Find me a room", systemImage: "wand.and.sparkles")
                            .foregroundStyle(Color.black)
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color.white)
                                    .shadow(radius: 2)
                            }
                    case .search:
                        if quickBook.numberOfOptions == 0 {
                            Label("No results", systemImage: "xmark")
                                .foregroundStyle(.primary)
                                .padding(12)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color("gsrBlue"))
                                        .shadow(radius: 2)
                                }
                        } else {
                            Label("Show \(quickBook.numberOfOptions.formatted()) result\(quickBook.numberOfOptions > 1 ? "s" : "")", systemImage: "magnifyingglass")
                                .contentTransition(.numericText())
                                .foregroundStyle(Color.white)
                                .padding(12)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color("gsrBlue"))
                                        .shadow(radius: 2)
                                }
                        }
                    case .explore:
                        Label("Book now", systemImage: "wand.and.sparkles")
                            .foregroundStyle(Color.white)
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(Color("gsrBlue"))
                                    .shadow(radius: 2)
                            }
                            
                    }
                }
            }
            .disabled(status == .search && quickBook.numberOfOptions == 0)
        }
    }
}

