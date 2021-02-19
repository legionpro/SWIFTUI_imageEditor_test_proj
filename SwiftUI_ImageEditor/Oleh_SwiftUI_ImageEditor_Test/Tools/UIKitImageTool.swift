//
//  UIKitImageTool.swift
//  Oleh_SwiftUI_ImageEditor_Test
//
//  Created by OLEH POREMSKYY on 19.02.2021.
//


import UIKit

func imageWithImage(image: UIImage, croppedTo rect: CGRect) -> UIImage {
    
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y,
                          width: image.size.width, height: image.size.height)
    
    context?.clip(to: CGRect(x: 0, y: 0,
                             width: rect.size.width, height: rect.size.height))
    
    image.draw(in: drawRect)
    
    let subImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return subImage!
}
