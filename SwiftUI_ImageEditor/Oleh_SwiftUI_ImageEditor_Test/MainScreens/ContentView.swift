//
//  ContentView.swift
//  Oleh_SwiftUI_ImageEditor_Test
//
//  Created by OLEH POREMSKYY on 16.02.2021.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins


/// MARK - left menu buttons
enum LeftMenuActiveButton {
    case notSelected
    case crop
    case pinch
    case text
    case line
}




/// MARK main screen
struct ContentView: View {

    @State var leftMenuButton: LeftMenuActiveButton = .notSelected
    @State private var showSheet = false
    
    @State var image: UIImage?
    
    @State private var isShowingPhotoSelectionSheet = false
    
    @State private var finalImage: UIImage?
    @State private var inputImage: UIImage?
    
    init() {
        UINavigationBar.appearance().backgroundColor = .black
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(alignment: .center, spacing: 20) {
                                Spacer()
                                VStack(alignment: .center, spacing: 3) {
                                    Button(action: { leftMenuButton = .line}, label: { Image(systemName: "scribble").foregroundColor(.white)})
                                    if leftMenuButton == .line {
                                        Image(systemName: "circle.fill").foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "circle.fill").foregroundColor(.clear)
                                    }
                                }
                                VStack(alignment: .center, spacing: 3) {
                                    Button(action: { leftMenuButton = .text}, label: { Image(systemName: "textbox").foregroundColor(.white)})
                                    if leftMenuButton == .text {
                                        Image(systemName: "circle.fill").foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "circle.fill").foregroundColor(.clear)
                                    }}
                                VStack(alignment: .center, spacing: 3) {
                                    Button(action: { leftMenuButton = .pinch}, label: { Image(systemName: "arrow.up.right").foregroundColor(.white)})
                                    if leftMenuButton == .pinch {
                                        Image(systemName: "circle.fill").foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "circle.fill").foregroundColor(.clear)
                                    }}
                                VStack(alignment: .center, spacing: 3) {
                                    Button(action: { leftMenuButton = .crop}, label: { Image(systemName: "crop.rotate").foregroundColor(.white)})
                                    if leftMenuButton == .crop {
                                        Image(systemName: "circle.fill").foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "circle.fill").foregroundColor(.clear)
                                    }}
                                Spacer()
                            }.frame(width: geometry.size.width * 0.10, height: geometry.size.height * 0.9)
                            .background(Color.black)
                            VStack(){
                                ImageMoveAndScaleSheet(leftMenuItem: $leftMenuButton ,croppedImage: $finalImage)
                            }
                            .frame(width: geometry.size.width * 0.80, height: geometry.size.height * 0.9)
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                            .background(Color.gray)

                            VStack(alignment: .center, spacing: 20) {
                                Spacer()
                                Image(systemName: "rotate.right").foregroundColor(.white)
                                Button("ORIGINAL"){}.foregroundColor(.white).font(.custom("system", size: 14))
                                Button("Squaer"){}.foregroundColor(.white).font(.custom("system", size: 14))
                                Button("16 : 9"){}.foregroundColor(.white).font(.custom("system", size: 14))
                                Button("4 : 3"){}.foregroundColor(.white).font(.custom("system", size: 14))
                                Spacer()
                            }.frame(width: geometry.size.width * 0.10, height: geometry.size.height * 0.9)
                            .background(Color.black)
                        }
                        HStack(spacing: 50) {
                            Spacer()
                            Button(action: { }, label: { Image(systemName: "checkmark.rectangle.portrait").foregroundColor(.white)})
                            Button(action: { }, label: { Image(systemName: "rectangle.portrait").foregroundColor(.white)})
                            Spacer()
                        }.frame(width: geometry.size.width, height: geometry.size.height * 0.1)
                        .background(Color.black)
                    }
                    
                }
            }
            .background(Color.black)
            .padding(.all, 10)
            .navigationBarItems(
                leading:
                    HStack(spacing: 50 ) {
                        Button(action: { }, label: { Text("Cancel").foregroundColor(.white)
                        })},
                trailing:
                    HStack(spacing: 10 ) {
                        Button(action: { showSheet = true}, label: { Image(systemName: "square.and.arrow.up").foregroundColor(.white)})
                        Button(action: { self.isShowingPhotoSelectionSheet = true}, label: { Image(systemName: "trash").foregroundColor(.white)})
                        Button(action: { /*showSheet = true*/}, label: { Text("Save").foregroundColor(.yellow)})
                    }
            ).background(Color.black)
        }.navigationViewStyle(StackNavigationViewStyle())
        .background(Color.black)
    }

}






