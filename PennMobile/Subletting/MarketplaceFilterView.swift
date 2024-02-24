//
//  MarketplaceFilterView.swift
//  PennMobile
//
//  Created by Jordan H on 2/9/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms

struct MarketplaceFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var sublettingViewModel: SublettingViewModel
    @State private var filterData: MarketplaceFilterData

    init(sublettingViewModel: SublettingViewModel) {
        self.sublettingViewModel = sublettingViewModel
        self._filterData = State(initialValue: sublettingViewModel.filterData)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LabsForm { formState in
                    PairFields {
                        NumericField($filterData.minPrice, format: .currency(code: "USD").presentation(.narrow), title: "Min Price/month")
                        NumericField($filterData.maxPrice, format: .currency(code: "USD").presentation(.narrow), title: "Max Price/month")
                    }
                    
                    TextLineField($filterData.location, placeholder: "Search", title: "Desired location")
                    
                    DateRangeField(lowerDate: $filterData.startDate, upperDate: $filterData.endDate, title: "Start & End Date")
                    
                    PairFields {
                        NumericField($filterData.beds, title: "# Bed")
                        NumericField($filterData.baths, title: "# Bath")
                    }
                    
                    //                    TagSelector(selection: $filterData.selectedAmenities, tags: $filterData.amenities)
                    
                    ComponentWrapper {
                        HStack {
                            Button(action: {
                                sublettingViewModel.filterData = MarketplaceFilterData()
                                filterData = MarketplaceFilterData()
                            }) {
                                Text("Reset")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(
                                        Capsule()
                                            .fill(Color.uiCardBackground)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.primary, lineWidth: 2)
                                    )
                            }
                            .padding(.top, 30)
                            
                            Button(action: {
                                sublettingViewModel.filterData = filterData
                                dismiss()
                            }) {
                                Text("Save")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(
                                        Capsule()
                                            .fill(formState.isValid ? Color.baseLabsBlue : .gray)
                                    )
                            }
                            .padding(.top, 30)
                            .disabled(!formState.isValid)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Filter by"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
            }, trailing: Button(action: {
                sublettingViewModel.filterData = filterData
                dismiss()
            }) {
                Text("Save")
            })
        }
    }
}

#Preview {
    MarketplaceFilterView(sublettingViewModel: SublettingViewModel())
}
