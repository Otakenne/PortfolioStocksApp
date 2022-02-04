//
//  NewsStory.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 27/01/2022.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: URL?
}
