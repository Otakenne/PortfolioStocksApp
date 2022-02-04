//
//  MetricCollectionViewCell.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 03/02/2022.
//

import UIKit

struct MetricCollectionViewCellViewModel {
    let name: String
    let value: String
}

class MetricCollectionViewCell: UICollectionViewCell {
    static let identifier = "MetricCollectionViewCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews(nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        valueLabel.sizeToFit()
        
        nameLabel.frame = CGRect(x: 13, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 10, y: 0, width: valueLabel.width, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    func configure(with viewModel: MetricCollectionViewCellViewModel) {
        nameLabel.text = "\(viewModel.name): "
        valueLabel.text = viewModel.value
    }
}
