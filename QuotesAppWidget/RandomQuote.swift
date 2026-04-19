//
//  RandomQuote.swift
//  QuotesAppWidget
//
//  Created by Keagan Rodrigues on 2026-04-04.
//

import Foundation

struct RandomQuote: Identifiable, Codable, Hashable {
    let id: Int
    
    let quote: String
}
