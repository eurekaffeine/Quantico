//
//  Item.swift
//  Quantico
//
//  Created by Yaochen Liu on 2024/6/5.
//

import SwiftUI

struct Item: Identifiable {
    var id: UUID = .init()
    var color: Color
}

var items: [Item] = [
    .init(color: .red),
    .init(color: .blue),
    .init(color: .green),
    .init(color: .yellow),
    .init(color: .pink),
    .init(color: .purple),
]


extension [Item] {
    func zIndex(_ item: Item) -> CGFloat {
        if let index = firstIndex(where: {$0.id == item.id}) {
            return CGFloat(count) - CGFloat(index)
        }
        
        return .zero
    }
}
