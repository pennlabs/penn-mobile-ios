//
//  DiningVenueDetailView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 6/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import KingfisherSwiftUI
#endif

@available(iOS 14, *)
struct DiningVenueDetailView: View {
    
    let safeFrameHeight: CGFloat
    let customNavBarHeight: CGFloat

    init(for venue: DiningVenue) {
        self.venue = venue
        
        let window = UIApplication.shared.windows[0]
        safeFrameHeight = window.safeAreaLayoutGuide.layoutFrame.minY
        customNavBarHeight = 44 + safeFrameHeight
    }
    
    private let venue: DiningVenue
    private let sectionTitle = ["Menu", "Hours", "Location"]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var diningVM: DiningViewModelSwiftUI
    @State private var pickerIndex = 0

    @State private var headerImageHeight: CGFloat = 300
        
    var body: some View {
        GeometryReader { fullGeo in
            ScrollView {
                image
                    .zIndex(2)
                
                Group {
                    Picker("Section", selection: self.$pickerIndex) {
                        ForEach(0 ..< self.sectionTitle.count) {
                            Text(self.sectionTitle[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 5)
                    
                    Divider()
                        .padding(.vertical, 5)
                    
                    VStack {
                        if self.pickerIndex == 0 {
                            DiningVenueDetailMenuView(menus: diningVM.diningMenus[venue.id]?.document.menuDocument.menus ?? [])
                        } else if self.pickerIndex == 1 {
                            DiningVenueDetailHoursView(for: venue)
                        } else {
                            DiningVenueDetailLocationView(for: venue, screenHeight: fullGeo.size.width)
                        }
                        
                        Spacer()
                    }.frame(minHeight: fullGeo.size.height - 80)
                }.padding(.horizontal)

            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarHidden(true)
            .onAppear(perform: {
                diningVM.refreshMenu(for: venue.id)
                headerImageHeight = fullGeo.frame(in: .global).height * 4/9
            })
        }
    }
    
    var image : some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                KFImage(self.venue.imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: getHeightForHeaderImage(geometry))
                    .offset(x: 0, y: getParallaxOffset(geometry))
                    .clipped()
                    .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom))
                    .allowsHitTesting(false)
                
                VStack(alignment: .leading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .light))
                    }
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().opacity(0.8).foregroundColor(.black))
                    .opacity(getOpacity(geometry))
                    .position(x: 40, y: customNavBarHeight - 20)
                    .offset(x: 0, y: getBackButtonYOffset(geometry))

                    Spacer()

                    Text(venue.name)
                        .padding()
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .opacity(getOpacity(geometry))
                        
                }
                
                DefaultNavigationBar(presentationMode: _presentationMode, height: customNavBarHeight, width: geometry.size.width, title: venue.name)
                        .offset(x:0, y:getOffsetForNavBar(geometry))
                        .opacity(getOpacityForNavBar(geometry))
            }
            .offset(x: 0, y: getOffsetForHeaderImage(geometry))
        }
        .frame(height: headerImageHeight)
    }
}


// MARK: - Calculations for offsets + opacity
extension DiningVenueDetailView {
    
    private func getBackButtonYOffset(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getOffset(geometry)
        
        return offset < 0 ? -offset : 0
    }
    
    private func getOffset(_ geometry: GeometryProxy) -> CGFloat {
        return geometry.frame(in: .global).minY
    }
    
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getOffset(geometry)
        
        return offset > 0 ? -offset : 0
    }
    
    private func getParallaxOffset(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getOffset(geometry)
        
        return offset < 0 ? -offset/1.3 : 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getOffset(geometry)
        
        return offset > 0 ? headerImageHeight + offset : headerImageHeight
    }
    
    private func getOpacity(_ geometry: GeometryProxy) -> Double {
        let offset = getOffset(geometry)
        
        return offset > 0 ? Double(1 - offset/headerImageHeight * 4) : 1.0
    }
    
    private func getOffsetForNavBar(_ geometry: GeometryProxy) -> CGFloat {
        return -getOffset(geometry) - headerImageHeight + customNavBarHeight
    }
    
    private func getOpacityForNavBar(_ geometry: GeometryProxy) -> Double {
        let offset = getOffset(geometry)
        
        if -offset > 0.6 * headerImageHeight {
            return Double((-offset/headerImageHeight - 0.6) * 8)
        }
        
        return 0.0
    }
}

@available(iOS 14.0, *)
struct DefaultNavigationBar: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var height: CGFloat
    var width: CGFloat
    var title: String
   
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                
                HStack {
                    Button("Back") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                }.padding([.leading, .bottom])
                
                HStack {
                    Spacer()
                    Text(title)
                    Spacer()
                }.padding(.bottom)
            }.frame(width: width, height: height)
        }
    }
}

@available(iOS 14, *)
struct DiningVenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "sample-dining-venue", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let diningVenues = try! decoder.decode(DiningAPIResponse.self, from: data)

        return
            NavigationView {
                DiningVenueDetailView(for: diningVenues.document.venues[0])
            .preferredColorScheme(.dark)
            .environmentObject(DiningViewModelSwiftUI())
            }
    }
}

// Hack to enable swipe from left while disabling navigation title
// TODO: find a more natural fix in future releases
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
