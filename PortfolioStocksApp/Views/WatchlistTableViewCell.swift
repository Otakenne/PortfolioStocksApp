//
//  WatchlistTableViewCell.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 31/01/2022.
//

import UIKit

struct WatchlistViewModel {
    let symbol: String
    let companyName: String
    let price: String
    let changeColor: UIColor
    let changePercentage: String
    let viewModel: StockChartViewViewModel
}

protocol WatchlistTableViewDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchlistTableViewCell: UITableViewCell {
    static let identifier = "WatchlistTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    weak var delegate: WatchlistTableViewDelegate?
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.clipsToBounds = true
        chart.isUserInteractionEnabled = false
        return chart
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(symbolLabel, nameLabel, miniChartView, priceLabel, changeLabel)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height) / 2
        symbolLabel.frame = CGRect(x: separatorInset.left, y: yStart, width: symbolLabel.width, height: symbolLabel.height)
        nameLabel.frame = CGRect(x: separatorInset.left, y: symbolLabel.bottom, width: nameLabel.width, height: nameLabel.height)
        
        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
        )
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: yStart,
            width: currentWidth,
            height: priceLabel.height
        )
        
        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )
        
        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width / 3) - 5,
            y: 6,
            width: contentView.width / 3,
            height: contentView.height - 12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: WatchlistViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.viewModel)
    }
}
