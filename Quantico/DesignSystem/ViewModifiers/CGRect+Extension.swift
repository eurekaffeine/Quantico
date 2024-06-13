//
//  CGRect+Extension.swift
//  
//
//  Created by 李天培 on 2024/2/18.
//

import Foundation

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
