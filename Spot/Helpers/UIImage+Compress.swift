//
//  UIImage+Compress.swift
//  Spot
//
//  Created by Jin Kim on 11/17/21.
//

import UIKit

// https://designcode.io/swiftui-advanced-handbook-compress-a-uiimage
func compressImage(image: UIImage) -> UIImage {
    let resizedImage = image.aspectFittedToHeight(600)
    resizedImage.jpegData(compressionQuality: 0.5) // Compresses the actual image
    return resizedImage
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
