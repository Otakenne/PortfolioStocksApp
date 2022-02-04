//
//  NewsHeaderView.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 26/01/2022.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDelegateDidTapButton(_ newsHeaderView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let preferedHeight: CGFloat = 60
    
    weak var delegate: NewsHeaderViewDelegate?

    struct ViewModel {
        let title: String
        let showsButton: Bool
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews(label, button)
        backgroundColor = .red
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width - 28, height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 16,
            y: (contentView.height - button.height) / 2,
            width: button.width + 10,
            height: button.height
        )
    }
    
    @objc func didTapButton() {
        delegate?.newsHeaderViewDelegateDidTapButton(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.showsButton
    }
}
