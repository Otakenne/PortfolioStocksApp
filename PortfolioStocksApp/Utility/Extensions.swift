//
//  Extensions.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 25/01/2022.
//

import Foundation
import UIKit
import FloatingPanel

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach{
            addSubview($0)
        }
    }
}

extension UIView {
    var width: CGFloat {
        self.frame.size.width
    }
    
    var height: CGFloat {
        self.frame.size.height
    }
    
    var top: CGFloat {
        self.frame.origin.y
    }
    
    var bottom: CGFloat {
        self.top + self.height
    }
    
    var left: CGFloat {
        self.frame.origin.x
    }
    
    var right: CGFloat {
        self.left + width
    }
}

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.dateFormatter.string(from: date)
    }
    
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatted(from number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

extension UIImageView {
    func setImage(from url: URL?) {
        guard let url = url else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else  {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
}

extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Notification.Name {
    static let didAddToWatchlist = Notification.Name("didAddToWatchlist")
}
