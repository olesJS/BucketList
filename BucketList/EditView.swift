//
//  EditView.swift
//  BucketList
//
//  Created by Олексій Якимчук on 19.08.2023.
//

import SwiftUI

struct EditView: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    var onSave: (Location) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Place description", text: $viewModel.description)
                }
                
                Section("Nearby") {
                    switch viewModel.loadingState {
                    case .loading:
                        HStack {
                            Text("Loading ")
                            ProgressView()
                        }
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ")
                            + Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later!")
                    }
                }
            }
            .navigationTitle("Place details")
            .task {
                await viewModel.fetchNearbyPlaces()
            }
            .toolbar {
                Button("Save") {
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.onSave = onSave
        
        _viewModel = StateObject(wrappedValue: ViewModel(location: location))
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { _ in }
    }
}
