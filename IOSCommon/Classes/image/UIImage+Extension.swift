//
//  UIImage+Extension.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/11.
//

import Foundation

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .size

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() } // 延迟

        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.rotate(by: radians)
            context.scaleBy(x: 1.0, y: -1.0)

            let drawRect = CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height)
            context.draw(self.cgImage!, in: drawRect)

            return UIGraphicsGetImageFromCurrentImageContext()
        }

        return nil
    }
}
