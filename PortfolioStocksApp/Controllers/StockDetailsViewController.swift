//
//  StockDetailsViewController.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 24/01/2022.
//

import SafariServices
import UIKit

class StockDetailsViewController: UIViewController {
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    private var stories: [NewsStory] = []
    private var metric: Metrics?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        tableView.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return tableView
    }()
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setupNavigationView()
        setupTableView()
        fetchFinancialData()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func setupNavigationView() {
        title = companyName
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissViewController))
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: (view.width * 0.7) + 100)
        )
    }
    
    func fetchFinancialData() {
        let group = DispatchGroup()
        
        if candleStickData.isEmpty {
            group.enter()
            
            APICaller.shared.marketData(symbol: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(_):
                    break
                }
            }
        }
        
        group.enter()
        APICaller.shared.financialMetrics(symbol: symbol) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metric = response.metric
                self?.metric = metric
            case .failure(_):
                break
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
        
        var viewModels: [MetricCollectionViewCellViewModel] = []
        if let metrics = metric {
            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
        }
        let changePercentage = getChangePercentage(for: candleStickData)
        headerView.configure(chartViewModel: StockChartViewViewModel(
            data: candleStickData.reversed().map { $0.close },
            showLegend: true,
            showAxis: true,
            fillColor: changePercentage > 0 ? .systemGreen : .systemRed
        ), metricViewModels: viewModels)
        
        tableView.tableHeaderView = headerView
    }
    
    func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(_):
                break
            }
        }
    }
    
    func getChangePercentage(for data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: { !Calendar.current.isDate( $0.date, inSameDayAs: latestDate)})?.close else  {
                  return 0.0
              }
              
        return 1 - (priorClose / latestClose)
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
}

extension StockDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: NewsStoryViewModel(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        header.delegate = self
        header.configure(with: NewsHeaderView.ViewModel(title: symbol.uppercased(), showsButton: !PersistenseManager.shared.watchlistContains(symbol: symbol)))
        return header
    }
}

extension StockDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let story = stories[indexPath.row]
        guard let url = story.url else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewsHeaderView.preferedHeight
    }
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDelegateDidTapButton(_ newsHeaderView: NewsHeaderView) {
        newsHeaderView.button.isHidden = true
        PersistenseManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        
        let alertViewController = UIAlertController(title: "Added to watchlist", message: "\(companyName) has been added to your watchlist", preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }
}
