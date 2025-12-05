//
//  CategorieModel.swift
//

import Foundation

public struct Category: Hashable {
    let name: String
    let imagePath: String
}

public struct Food: Hashable {
    let name: String
    let category: String
    let subtiltle: String
    let price: Double
    let imagePath: String
    let description: String
}

/// Item stored in the shopping cart
public struct CartItem: Identifiable, Hashable {
    public let id = UUID()
    let food: Food
    var quantity: Int
}

