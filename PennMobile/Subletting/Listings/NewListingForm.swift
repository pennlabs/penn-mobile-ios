//
//  NewListingForm.swift
//  PennMobile
//
//  Created by Anthony Li on 2/4/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI
import PennForms
import PennMobileShared
import OrderedCollections

struct URLValidator: Validator {
    let message: String? = "Enter a valid URL"
    
    func isValid(_ input: String?) -> Bool {
        guard let input, !input.isEmpty else { return true }
        guard let url = URL(string: input) else { return false }
        guard let scheme = url.scheme else { return true }
        
        return scheme.wholeMatch(of: /https?/.ignoresCase()) != nil
    }
}

struct NewListingForm: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var sublettingViewModel: SublettingViewModel
    @EnvironmentObject var popupManager: PopupManager
    var isNew: Bool = true
    var draftID: UUID?
    var originalSublet: Sublet?
    @State var subletData = SubletData()
    @State var negotiable: Bool?
    @State var price: Int?
    @State var startDate: Date?
    @State var endDate: Date?
    @State var selectedAmenities = OrderedSet<String>()
    @State var images: [UIImage] = []
    @State var existingImages: [String] = []
    @State var progress: Double?
    @State var showValidationErrors = false
    
    init() {
        self.isNew = true
        self._subletData = State(initialValue: SubletData())
        self._selectedAmenities = State(initialValue: OrderedSet<String>())
        self._images = State(initialValue: [])
        self._existingImages = State(initialValue: [])
    }
    
    init(subletDraft: SubletDraft) {
        self.isNew = true
        self.draftID = subletDraft.id
        self._subletData = State(initialValue: subletDraft.data)
        self._negotiable = State(initialValue: subletDraft.negotiable)
        self._price = State(initialValue: subletDraft.price)
        self._startDate = State(initialValue: subletDraft.startDate.date)
        self._endDate = State(initialValue: subletDraft.endDate.date)
        self._selectedAmenities = State(initialValue: OrderedSet(subletDraft.amenities))
        self._images = State(initialValue: subletDraft.images)
        self._existingImages = State(initialValue: [])
        
        self.showValidationErrors = true
    }
    
    init(sublet: Sublet) {
        self.isNew = false
        self.originalSublet = sublet
        self._subletData = State(initialValue: sublet.data)
        self._negotiable = State(initialValue: sublet.negotiable)
        self._price = State(initialValue: sublet.price)
        self._startDate = State(initialValue: sublet.startDate.date)
        self._endDate = State(initialValue: sublet.endDate.date)
        self._selectedAmenities = State(initialValue: OrderedSet(sublet.amenities))
        self._images = State(initialValue: [])
        self._existingImages = State(initialValue: sublet.images.map { $0.imageUrl })
        
        self.showValidationErrors = true
    }
    
    var body: some View {
        ScrollView {
            LabsForm { formState in
                TextLineField($subletData.title, title: "Listing Name")
                    .validator(.required)
                
                ImagePicker($images, existingImages: $existingImages, maxSelectionCount: 6)
                    .validator(AtLeastValidator(value: 1, { "Must select at least \($0) image\($0 == 1 ? "" : "s")" }))
                
                PairFields {
                    NumericField($price, format: .currency(code: "USD").presentation(.narrow), title: "Price/month")
                        .validator(.required)
                    OptionField($negotiable, options: [false, true], toString: { option in
                            option ? "Yes" : "No"
                        }, title: "Negotiable?"
                    )
                    .validator(.required)
                }
                
                TextLineField($subletData.address, placeholder: "Street address", title: "Location")
                
                DateRangeField(lowerDate: $startDate, upperDate: $endDate, title: "Start & End Date")
                    .validator(.required)
                
                PairFields {
                    NumericField($subletData.beds, title: "# Bed")
                    NumericField($subletData.baths, title: "# Bath")
                }
                
                ComponentWrapper {
                    TextLineField($subletData.externalLink, placeholder: "e.g. https://lauder.house.upenn.edu", title: "External Link")
                        .validator(URLValidator())
                        .keyboardType(.URL)
                }
                
                DateField(date: $subletData.expiresAt, title: "Listing Expiry Date")
                    .validator(.required)
                
                TagSelector(selection: $selectedAmenities, tags: $sublettingViewModel.amenities, title: "Amenities")
                
                TextAreaField($subletData.description, characterCount: 300, title: "Description (optional)")
                
                ComponentWrapper {
                    HStack {
                        Button(action: {
                            if isNew {
                                var data = subletData
                                if let price {
                                    data.price = price
                                }
                                if let negotiable {
                                    data.negotiable = negotiable
                                }
                                if let startDate {
                                    data.startDate = Day(date: startDate)
                                }
                                if let endDate {
                                    data.endDate = Day(date: endDate)
                                }
                                data.amenities = Array(selectedAmenities)
                                
                                if let draftID {
                                    sublettingViewModel.drafts.removeAll(where: { $0.id == draftID })
                                }
                                sublettingViewModel.drafts.append(SubletDraft(data: data, images: images))
                                
                                popupManager.set(
                                    title: "Draft Saved!",
                                    message: "Your draft has been saved. You can edit it further on the drafts tab.",
                                    button1: "See My Drafts",
                                    action1: {
                                        navigationManager.path.removeLast(2)
                                        navigationManager.path.append(SublettingPage.myListings(.drafts))
                                    }
                                )
                                popupManager.show()
                            } else {
                                navigationManager.path.removeLast()
                            }
                        }) {
                            Text(isNew ? "Save Draft": "Cancel")
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
                            guard formState.isValid, images.count + existingImages.count > 0 else {
                                showValidationErrors = true
                                return
                            }
                            
                            guard let negotiable, let price, let startDate, let endDate else {
                                showValidationErrors = true
                                return
                            }
                            
                            var data = subletData
                            data.price = price
                            data.negotiable = negotiable
                            data.startDate = Day(date: startDate)
                            data.endDate = Day(date: endDate)
                            data.amenities = Array(selectedAmenities)
                            
                            if let link = data.externalLink, let url = URL(string: link) {
                                if url.scheme == nil {
                                    let newUrl = "https://\(link)"
                                    if URL(string: newUrl) != nil {
                                        data.externalLink = newUrl
                                    }
                                }
                            }
                            
                            Task {
                                var sublet = originalSublet

                                // Remove old images
                                if !isNew && sublet != nil {
                                    let imagesToDelete = sublet!.images.filter { image in
                                        !existingImages.contains(image.imageUrl)
                                    }

                                    if !imagesToDelete.isEmpty {
                                        do {
                                            try await SublettingAPI.instance.deleteSubletImages(images: imagesToDelete)
                                            sublet!.images = sublet!.images.filter { image in
                                                existingImages.contains(image.imageUrl)
                                            }
                                            sublet!.lastUpdated = Date()
                                            sublettingViewModel.updateSublet(sublet: sublet!)
                                        } catch let error {
                                            print("Error deleting sublet images: \(error)")
                                        }
                                    }
                                }
                                
                                // Upload new data (except images)
                                do {
                                    if isNew {
                                        sublet = try await SublettingAPI.instance.createSublet(subletData: data)
                                        sublettingViewModel.addListing(sublet: sublet!)
                                        if let draftID {
                                            sublettingViewModel.drafts.removeAll(where: { $0.id == draftID })
                                        }
                                    } else if sublet != nil {
                                        sublet = try await SublettingAPI.instance.patchSublet(id: sublet!.subletID, data: data)
                                        sublettingViewModel.updateSublet(sublet: sublet!)
                                    }
                                } catch let error {
                                    print("Couldn't \(isNew ? "create" : "update") sublet: \(error)")
                                    popupManager.set(
                                        image: Image(systemName: "exclamationmark.2"),
                                        title: "Uh oh!",
                                        message: "Failed to \(isNew ? "create" : "update") the sublet.",
                                        button1: "Close"
                                    )
                                    popupManager.show()
                                    return
                                }
                                
                                // Upload new images
                                if sublet != nil {
                                    do {
                                        popupManager.disableBackground = true
                                        sublet!.images = try await SublettingAPI.instance.uploadSubletImages(images: images, id: sublet!.subletID) { progress in
                                            withAnimation {
                                                self.progress = progress
                                            }
                                        }
                                        sublet!.lastUpdated = Date()
                                        sublettingViewModel.updateSublet(sublet: sublet!)
                                    } catch let error {
                                        print("Error uploading sublet images: \(error)")
                                    }
                                    self.progress = nil
                                    popupManager.disableBackground = false
                                }
                                    
                                popupManager.set(
                                    title: "Listing \(isNew ? "Posted" : "Updated")!",
                                    message: "\(isNew ? "Your listing is now on the marketplace. " : "")You'll be notified when candidates are interested in subletting!",
                                    button1: "\(isNew ? "See My Listings" : "See Sublet Details")",
                                    action1: {
                                        if isNew {
                                            navigationManager.path.removeLast(2)
                                            navigationManager.path.append(SublettingPage.myListings(.posted))
                                        } else {
                                            navigationManager.path.removeLast(1)
                                        }
                                    }
                                )
                                popupManager.show()
                            }
                        }) {
                            Text(isNew ? "Post" : "Save")
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
                        .disabled(showValidationErrors && !formState.isValid)
                    }
                }
            }
        }
        .navigationTitle(isNew ? "New Listing" : "Edit Listing")
        .toolbar {
            if draftID != nil || originalSublet != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        popupManager.set(
                            image: Image(systemName: "trash.fill"),
                            title: "Delete \(isNew ? "Draft" : "Listing")?",
                            message: "Are you sure you want to delete your \(isNew ? "draft" : "listing")?",
                            button1: "Confirm",
                            action1: {
                                Task {
                                    if isNew, let draftID {
                                        sublettingViewModel.drafts.removeAll(where: { $0.id == draftID })
                                    } else if let originalSublet {
                                        do {
                                            try await SublettingAPI.instance.deleteSublet(id: originalSublet.subletID)
                                            sublettingViewModel.deleteListing(sublet: originalSublet)
                                        } catch {
                                            popupManager.set(
                                                image: Image(systemName: "exclamationmark.2"),
                                                title: "Uh oh!",
                                                message: "Failed to delete listing.",
                                                button1: "Close"
                                            )
                                            return
                                        }
                                    }
                                    popupManager.set(
                                        title: "\(isNew ? "Draft" : "Listing") Deleted!",
                                        message: "Your \(isNew ? "draft" : "listing") has been deleted.",
                                        button1: isNew ? "See My Drafts" : (navigationManager.path.contains(SublettingPage.myListings(.posted)) ? "See My Listings" : "See Marketplace"),
                                        action1: {
                                            navigationManager.path.removeLast(2)
                                            if isNew {
                                                navigationManager.path.append(SublettingPage.myListings(.drafts))
                                            }
                                        }
                                    )
                                }
                            },
                            button2: "Cancel",
                            action2: { popupManager.hide() },
                            autoHide: false
                        )
                        popupManager.show()
                    }) {
                        Text("Delete")
                    }
                }
            }
        }
        .overlay {
            if let progress = progress {
                UploadingOverlay(progress: progress, title: "Uploading...", message: "Your listing is being uploaded to the marketplace. Please wait a moment.")
            }
        }
        .environment(\.showValidationErrors, showValidationErrors)
    }
}

struct UploadingOverlay: View {
    let progress: Double
    let title: String
    let message: String
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 18) {
                MeterView(current: progress, maximum: 1.0, style: Color.blue, lineWidth: 5)
                    .frame(width: 100, height: 100)
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: 280)
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .background(Color("uiCardBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 3)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    NewListingForm()
}
