//
//  ContentView.swift
//  BucketList
//
//  Created by Олексій Якимчук on 17.08.2023.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                            
                            Text(location.name)
                                .fixedSize()
                        }
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                    }
                }
                .ignoresSafeArea()
                
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.addLocation()
                        } label: {
                            Image(systemName: "plus")
                                .padding()
                                .background(.black.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.title)
                                .clipShape(Circle())
                                .padding(.trailing)
                        }
                    }
                }
            }
            .sheet(item: $viewModel.selectedPlace) { place in
                EditView(location: place) { newLocation in
                    viewModel.updateLocation(location: newLocation)
                }
            }
        } else {
            Button("Unlock places") {
                viewModel.authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            // authentication failure
            .alert("Authentication Error", isPresented: $viewModel.isErrorAlertActive) {
                Button("Try again") {
                    viewModel.authenticate()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You didn't pass the authentication!")
            }
            
            // no biometrics
            .alert("Biometrics Error", isPresented: $viewModel.isBiometricsAlertActive) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your device doesn't have TouchID or FaceID")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
