//
//  ScaleImage.swift
//  Oleh_SwiftUI_ImageEditor_Test
//
//  Created by OLEH POREMSKYY on 17.02.2021.
//
import SwiftUI
import PhotosUI


struct ImageMoveAndScaleSheet: View {
    @State var points: [CGPoint] = []
    
    @Binding var leftMenuItem:LeftMenuActiveButton
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingImagePicker = false
    
    @Binding var croppedImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var selectedImage: UIImage?
    @State private var inputW: CGFloat = 750.5556577
    @State private var inputH: CGFloat = 1336.5556577
    @State private var theAspectRatio: CGFloat = 0.0
    @State private var profileImage: Image?
    @State private var profileW: CGFloat = 0.0
    @State private var profileH: CGFloat = 0.0
    
    ///Zoom and Drag
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    @State private var currentAmountRec: CGFloat = 0
    @State private var finalAmountRec: CGFloat = 1
    
    @State private var currentPosition: CGSize = .zero
    @State private var inewPosition: CGSize = .zero
    
    @State private var horizontalOffset: CGFloat = 0.0
    @State private var verticalOffset: CGFloat = 0.0
    
    @State private var currentPositionRec: CGSize = .zero
    @State private var newPositionRec: CGSize = .zero
    @State private var cropRectangleW: CGFloat = 200.0
    @State private var cropRectangleH: CGFloat = 200.0
    @State private var parentRectRec: CGRect = .zero
    @State private var childRectRec: CGRect = .zero
    
    
    private func addNewPoint(_ value: DragGesture.Value) {
        points.append(value.location)
    }
    
    private func clearPoints() {
        points.removeAll()
    }
    
    struct DrawShape: Shape {
        var points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            guard let firstPoint = points.first else { return path }
            
            path.move(to: firstPoint)
            for pointIndex in 1..<points.count {
                path.addLine(to: points[pointIndex])
                
            }
            return path
        }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                if leftMenuItem  == .line {
                    ZStack {
                        Color.black.opacity(0.8)
                        if profileImage != nil {
                            profileImage?
                                .resizable()
                                .scaleEffect(finalAmount + currentAmount)
                                .scaledToFill()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                            DrawShape(points: points)
                                .stroke(lineWidth: 5) // here you put width of lines
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .gesture(DragGesture().onChanged( { value in
                        self.addNewPoint(value)
                    })
                    .onEnded( { value in
                    }))
                }
                else {
                    ZStack {
                        Color.black.opacity(0.8)
                        if profileImage != nil {
                            profileImage?
                                .resizable()
                                .scaleEffect(finalAmount + currentAmount)
                                .scaledToFill()
                                .aspectRatio(contentMode: .fit)
                                .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { amount in
                                switch leftMenuItem {
                                case .line : break
                                case .text : break
                                case .pinch : self.currentAmount = amount - 1
                                case .crop : self.currentAmountRec = amount - 1
                                default : break
                                }
                            }
                            .onEnded { amount in
                                switch leftMenuItem {
                                case .line : break
                                case .text : break
                                case .pinch :
                                    self.finalAmount += self.currentAmount
                                    self.currentAmount = 0
                                    repositionImage(metrix:geometry)
                                    
                                case .crop :
                                    self.finalAmountRec += self.currentAmountRec
                                    self.currentAmountRec = 0
                                    resetCropRect()
                                default : break
                                }
                            }
                        
                    )
                }
                if leftMenuItem  == .crop {
                    Rectangle()
                        .frame(width: cropRectangleW, height: cropRectangleH)
                        .foregroundColor(Color.blue)
                        .border(Color.white, width: 4)
                        .opacity(0.4)
                        .offset(x: self.currentPositionRec.width, y: self.currentPositionRec.height)
                        .scaleEffect(finalAmountRec + currentAmountRec)
                        .scaledToFill()
                        .opacity(0.3)
                }
                VStack {
                    Text((profileImage != nil) ? titleScreenText() : "Select a Photo by tapping the icon below")
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    Spacer()
                    HStack(spacing: 40) {
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.custom("system", size: 45))
                                .opacity(0.9)
                                .foregroundColor(.white)
                            Image(systemName: "photo.on.rectangle")
                                .imageScale(.medium)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    isShowingImagePicker = true
                                    leftMenuItem = .notSelected
                                }
                        }
                        .padding(.bottom, 5)
                        Button(
                            action: {
                                switch leftMenuItem {
                                case .line :
                                    self.clearPoints()
                                case .text : break
                                case .pinch :
                                    self.save(metrix:geometry)
                                case .crop :
                                    self.cropRecSave(metrix:geometry)
                                default : break
                                }
                                
                                presentationMode.wrappedValue.dismiss()
                                
                            })
                            { Text(leftMenuItem == .line ? "Clear": "Crop") }
                            .disabled(cropButtonDisableflag())
                            .foregroundColor(cropButtonColor())
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        switch leftMenuItem {
                        case .line : break
                        case .text : break
                        case .pinch :
                            self.currentPosition = CGSize(width: value.translation.width + self.inewPosition.width, height: value.translation.height + self.inewPosition.height)
                            
                        case .crop :
                            self.currentPositionRec = CGSize(width: value.translation.width + self.newPositionRec.width, height: value.translation.height + self.newPositionRec.height)
                            print(" currentPosision  \(self.currentPositionRec.width)  , \(self.currentPositionRec.height)")
                        default : break
                        }
                        
                    }
                    .onEnded { value in
                        switch leftMenuItem {
                        case .line : break
                        case .text : break
                        case .pinch :
                            self.currentPosition = CGSize(width: value.translation.width + self.inewPosition.width, height: value.translation.height + self.inewPosition.height)
                            self.inewPosition = self.currentPosition
                            repositionImage(metrix:geometry)
                        case .crop :
                            self.currentPositionRec = CGSize(width: value.translation.width + self.newPositionRec.width, height: value.translation.height + self.newPositionRec.height)
                            self.newPositionRec = self.currentPositionRec
                        
                        default : break
                        }
                    }
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded({
                        resetImageOriginAndScale(metrix:geometry)
                    })
            )
            .sheet(isPresented: $isShowingImagePicker, onDismiss: {
                loadImageFromPicker(metrix: geometry)
                
            }) {
                CustomPhotoPickerView(image: self.$inputImage)
                    .accentColor(Color.systemRed)
            }
            
        }
        
    }
    
    //MARK: - functions
    
    private func titleScreenText() -> String {
        var result : String
        
        switch leftMenuItem {
        case .line :
            result = "Draw on the image"
        case .text :
            result = "Tup text on the image"
        case .pinch :
            result = "Move, Scale and Crop"
        case .crop :
            result = "Move and Scale The CropRect and Crop"
        default :
            result = "Select Action by the buttons or the right"
        }
        return result
    }
    
    
    private func cropButtonColor() -> Color {
        return cropButtonDisableflag() ? .gray : .white
    }
    
    private func cropButtonDisableflag() -> Bool {
        var result = false
        switch leftMenuItem {
        case .line :
            result = false
        case .text :
            result = true
        case .pinch , .crop :
            result = false
        default :
            result = true
        }
        return result
    }

    
    /// get picker selected image  to creen
    private func loadImageFromPicker(metrix:GeometryProxy) {
        guard let inputImage = inputImage else { return }
        let w = inputImage.size.width
        let h = inputImage.size.height
        profileImage = Image(uiImage: inputImage)
        
        inputW = w
        inputH = h
        theAspectRatio = w / h
        
        resetImageOriginAndScale(metrix:metrix)
    }
    
    
    /// just to reset image
    private func resetImageOriginAndScale(metrix:GeometryProxy) {
        withAnimation(.easeInOut){
            if theAspectRatio >= screenAspect {
                profileW = metrix.size.width
                profileH = profileW / theAspectRatio
            } else {
                profileH = metrix.size.height
                profileW = profileH * theAspectRatio
            }
            currentAmount = 0
            finalAmount = 1
            currentPosition = .zero
            inewPosition = .zero
        }
    }
    
    
    /// just to reset crop rectagle
    private func resetCropRect() {
        cropRectangleH = cropRectangleH * finalAmountRec
        cropRectangleW = cropRectangleW * finalAmountRec
    }
    
    
    
    /// reposition image according to gesture
    private func repositionImage(metrix:GeometryProxy) {
        
        let w = metrix.size.width
        
        if theAspectRatio > screenAspect {
            profileW = metrix.size.width * finalAmount
            profileH = profileW / theAspectRatio
        } else {
            profileH = metrix.size.height * finalAmount
            profileW = profileH * theAspectRatio
        }
        
        horizontalOffset = (profileW - w ) / 2
        verticalOffset = ( profileH - w ) / 2
        
        if finalAmount > 4.0 {
            withAnimation{
                finalAmount = 4.0
            }
        }
        
        if profileW >= metrix.size.width {
            
            if inewPosition.width > horizontalOffset {
                withAnimation(.easeInOut) {
                    inewPosition = CGSize(width: horizontalOffset + inset, height: inewPosition.height)
                    currentPosition = CGSize(width: horizontalOffset + inset, height: currentPosition.height)
                }
            }
            
            if inewPosition.width < ( horizontalOffset * -1) {
                withAnimation(.easeInOut){
                    inewPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: inewPosition.height)
                    currentPosition = CGSize(width: ( horizontalOffset * -1 - inset), height: currentPosition.height)
                }
            }
        } else {
            
            withAnimation(.easeInOut) {
                inewPosition = CGSize(width: 0, height: inewPosition.height)
                currentPosition = CGSize(width: 0, height: inewPosition.height)
            }
        }
        
        if profileH >= UIScreen.main.bounds.width {
            
            if inewPosition.height > verticalOffset {
                withAnimation(.easeInOut){
                    inewPosition = CGSize(width: inewPosition.width, height: verticalOffset + inset)
                    currentPosition = CGSize(width: inewPosition.width, height: verticalOffset + inset)
                }
            }
            
            if inewPosition.height < ( verticalOffset * -1) {
                withAnimation(.easeInOut){
                    inewPosition = CGSize(width: inewPosition.width, height: ( verticalOffset * -1) - inset)
                    currentPosition = CGSize(width: inewPosition.width, height: ( verticalOffset * -1) - inset)
                }
            }
        } else {
            
            withAnimation (.easeInOut){
                inewPosition = CGSize(width: inewPosition.width, height: 0)
                currentPosition = CGSize(width: inewPosition.width, height: 0)
            }
        }
        
        if profileW <= metrix.size.width && theAspectRatio > screenAspect {
            resetImageOriginAndScale(metrix:metrix)
        }
        if profileH <= metrix.size.height && theAspectRatio < screenAspect {
            resetImageOriginAndScale(metrix:metrix)
        }
    }
    /// crop  image according to crop rectagle
    private func cropRecSave(metrix:GeometryProxy) {
        guard let input = inputImage else {return}
        let scale = (input.size.width) / profileW
        let xPos:CGFloat = (((profileW - cropRectangleW) / 2 ) + currentPositionRec.width) * scale
        let yPos:CGFloat = (((profileH - cropRectangleH) / 2 ) + currentPositionRec.height) * scale
        let rectW = cropRectangleW * scale
        let rectH = cropRectangleH  * scale
        croppedImage = imageWithImage(image: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: rectW, height: rectH))
        
        let w = croppedImage!.size.width
        let h = croppedImage!.size.height
        inputImage = croppedImage!
        profileImage = Image(uiImage: croppedImage!)
        
        inputW = w
        inputH = h
        theAspectRatio = w / h
                
    }
    
    /// crop  image according to visible frame
    private func save(metrix:GeometryProxy) {
        guard let input = inputImage else {return}
        let scale = (input.size.width) / profileW
        let xPos = ( ( ( profileW - metrix.size.width ) / 2 ) + inset + ( currentPosition.width * -1 ) ) * scale
        let yPos = ( ( ( profileH - metrix.size.width ) / 2 ) + inset + ( currentPosition.height * -1 ) ) * scale
        let size = ( metrix.size.width - inset * 2 ) * scale
        croppedImage = imageWithImage(image: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: size, height: size))
        
        let w = croppedImage!.size.width
        let h = croppedImage!.size.height
        inputImage = croppedImage!
        profileImage = Image(uiImage: croppedImage!)
        
        inputW = w
        inputH = h
        theAspectRatio = w / h
        resetImageOriginAndScale(metrix:metrix)
        
    }
    
    let inset: CGFloat = 15
    let screenAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
}


