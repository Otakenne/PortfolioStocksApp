//
//  NewsStoryTableViewCell.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 27/01/2022.
//

import UIKit

struct NewsStoryViewModel {
    let source: String
    let headline: String
    let dateString: String
    let imageURL: URL?
    
    init(model: NewsStory) {
        self.source = model.source
        self.headline = model.headline
        self.dateString = .string(from: model.datetime)
        self.imageURL = URL(string: model.image)
    }
}

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = "NewsStoryTableViewCell"
    
    static let preferredHeight: CGFloat = 120
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height - 20
        storyImageView.frame = CGRect(
            x: contentView.width - imageSize - 10,
            y: 10,
            width: imageSize,
            height: imageSize
        )
        
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 20
        dateLabel.frame = CGRect(
            x: separatorInset.left,
            y: contentView.height - 30,
            width: availableWidth,
            height: 20
        )
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(
            x: separatorInset.left,
            y: 10,
            width: availableWidth,
            height: 20
        )
        
        headlineLabel.sizeToFit()
        headlineLabel.frame = CGRect(
            x: separatorInset.left,
            y: sourceLabel.bottom,
            width: availableWidth,
            height: contentView.height - sourceLabel.bottom - dateLabel.height - 20
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    func configure(with viewModel: NewsStoryViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.setImage(from: viewModel.imageURL)
    }
}
