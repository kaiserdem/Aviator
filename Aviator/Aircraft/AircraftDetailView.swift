import SwiftUI

struct AircraftDetailView: View {
    let detail: AircraftDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Main Image
                if let url = detail.imageURL {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Title and Description
                Text(detail.title)
                    .font(.title)
                    .bold()
                Text(detail.extract)
                    .foregroundStyle(.secondary)
                
                // Technical Specifications
                if let specs = detail.technicalSpecs {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Technical Specifications")
                            .font(.headline)
                            .bold()
                        
                        if let speed = specs.cruiseSpeed {
                            LabeledContent("Cruise Speed", value: "\(speed) km/h")
                        }
                        if let range = specs.range {
                            LabeledContent("Range", value: "\(range) km")
                        }
                        if let capacity = specs.passengerCapacity {
                            LabeledContent("Passenger Capacity", value: "\(capacity)")
                        }
                        if let wingspan = specs.wingspan {
                            LabeledContent("Wingspan", value: "\(wingspan) m")
                        }
                        if let length = specs.length {
                            LabeledContent("Length", value: "\(length) m")
                        }
                    }
                    .padding()
                    .background(Theme.Palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // History
                if let history = detail.history {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("History")
                            .font(.headline)
                            .bold()
                        
                        if let firstFlight = history.firstFlight {
                            LabeledContent("First Flight", value: firstFlight)
                        }
                        if let manufacturer = history.manufacturer {
                            LabeledContent("Manufacturer", value: manufacturer)
                        }
                        if let unitsBuilt = history.unitsBuilt {
                            LabeledContent("Units Built", value: unitsBuilt)
                        }
                    }
                    .padding()
                    .background(Theme.Palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Gallery
                if !detail.gallery.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gallery")
                            .font(.headline)
                            .bold()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(detail.gallery, id: \.self) { url in
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 120, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Links
                if let links = detail.links {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Links")
                            .font(.headline)
                            .bold()
                        
                        if let wikiURL = links.wikipedia {
                            Link("Wikipedia", destination: wikiURL)
                        }
                        if let manufacturerURL = links.manufacturer {
                            Link("Manufacturer", destination: manufacturerURL)
                        }
                    }
                    .padding()
                    .background(Theme.Palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle(detail.title)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Theme.Palette.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Theme.Gradient.background)
    }
}


