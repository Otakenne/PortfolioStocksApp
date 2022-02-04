//
//  APICaller.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 24/01/2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    private enum EndPoint: String {
        case search
        case topSories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
    }
    
    public func search(query: String, comletion: @escaping (Result<SearchResponse, Error>) -> ()) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = url(for: .search, queryParams: ["q": safeQuery]
              ) else {
                  return
              }
        
        request(url: url, expecting: SearchResponse.self, completion: comletion)
    }
    
    public func news(for type: `Type`, comletion: @escaping (Result<[NewsStory], Error>) -> ()) {
        switch type {
        case .topStories:
            guard let url = url(for: .topSories, queryParams: ["category": "general"]) else {
                return
            }
            request(url: url, expecting: [NewsStory].self, completion: comletion)
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(3600 * 24 * 7))
            guard let url = url(
                for: .companyNews,
                queryParams: [
                    "symbol" : symbol,
                    "from" : DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                    "to" : DateFormatter.newsDateFormatter.string(from: today)
                ]
            ) else {
                return
            }
                    
            request(url: url, expecting: [NewsStory].self, completion: comletion)
        }
    }
    
    public func marketData(symbol: String, numberOfDays: TimeInterval = 7, comletion: @escaping (Result<MarketDataResponse, Error>) -> ()) {
        let today = Date().addingTimeInterval(-(3600 * 24))
        let daysBack = today.addingTimeInterval(-(3600 * 24 * numberOfDays))
        guard let url = url(
            for: .marketData,
            queryParams: [
                "symbol" : symbol,
                "resolution" : "1",
                "from" : "\(Int(daysBack.timeIntervalSince1970))",
                "to" : "\(Int(today.timeIntervalSince1970))"
            ]
        ) else {
            return
        }
                
        request(url: url, expecting: MarketDataResponse.self, completion: comletion)
    }
    
    public func financialMetrics(symbol: String, comletion: @escaping (Result<FinancialMetricResponse, Error>) -> ()) {
        guard let url = url(
            for: .financials,
            queryParams: [
                "symbol" : symbol,
                "metric" : "all"
            ]
        ) else {
            return
        }
                
        request(url: url, expecting: FinancialMetricResponse.self, completion: comletion)
    }
    
    private func url(
        for endpoint: EndPoint,
        queryParams: [String : String]
    ) -> URL? {
        var urlString = "\(Constants.baseURL)\(endpoint.rawValue)"
        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        queryItems.append(URLQueryItem(name: "token", value: Constants.apiKey))
        let queryString = queryItems.map{ "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        urlString += "?" + queryString
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>
    ) -> Void) {
        
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result0 = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
