//
//  CustomPicker.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 3/5/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//

import SwiftUI

public struct CustomPicker<ItemView: View>: View {
    let options: [String]
    @State private var geometry: [GeometryProxy?]
    @State var globalGeo: GeometryProxy?
    let item: (String) -> ItemView
    @ObservedObject var vm: CustomPickerViewModel
    
    public init(options: [String], selected: Binding<Int>, animateExternalState: Bool = false, @ViewBuilder _ itemView: @escaping (String) -> ItemView) {
        self.vm = CustomPickerViewModel(selected: selected, animateExternalState: animateExternalState)
        self.options = options
        self.item = itemView
        self.geometry = Array(repeating: nil, count: options.count)
    }
    
    public var body: some View {
        VStack {
                OptionsHStack(options: options, item: item, geometry: $geometry)
                    .background {
                        CapsuleView(selectedGeometry: geometry[vm.selected], globalGeo: globalGeo)
                    }
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    globalGeo = proxy
                                }
                        }
                    }
                .environmentObject(vm)
                .background(Color("componentBackground"))
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

struct CapsuleView: View {
    let selectedGeometry: GeometryProxy?
    let globalGeo: GeometryProxy?
    
    var body: some View {
        if selectedGeometry != nil && globalGeo != nil {
            Capsule()
                .foregroundStyle(Color("componentMiddleground"))
                .frame(minWidth: selectedGeometry!.size.width,
                       idealWidth: selectedGeometry!.size.width * 1.3,
                       maxWidth: selectedGeometry!.size.width * 1.5,
                       maxHeight: selectedGeometry!.size.height
                )
                .offset(x: selectedGeometry!.frame(in: .global).midX - globalGeo!.frame(in: .global).midX)
                .shadow(radius:2)
        }
            
    }
}

struct OptionsHStack<ItemView: View>: View {
    let options: [String]
    let item: (String) -> ItemView
    @EnvironmentObject var vm: CustomPickerViewModel
    @Binding var geometry: [GeometryProxy?]
    
    
    var body: some View {
        let zipped = Array(zip(options.indices, options))
        HStack(spacing: 0) {
            Spacer()
            ForEach(zipped, id: \.0) { (index, option) in
                Group {
                    item(option)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("componentForeground"))
                        .frame(minWidth: geometry[index]?.frame(in: .global).height)
                        .overlay {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        geometry[index] = proxy
                                    }
                            }
                        }
                }
                .onTapGesture {
                    vm.setSelected(index)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

class CustomPickerViewModel: ObservableObject {
    @Binding var externalSelection: Int
    @Published var selected: Int
    let animateExternalState: Bool
    
    init(selected: Binding<Int>, animateExternalState: Bool) {
        self._externalSelection = selected
        self.selected = selected.wrappedValue
        self.animateExternalState = animateExternalState
    }
    
    func setSelected(_ new: Int) {
        withAnimation(.snappy) {
            selected = new
        }
        
        if animateExternalState {
            withAnimation(.snappy) {
                externalSelection = new
            }
        } else {
            externalSelection = new
        }
        
    }
}
