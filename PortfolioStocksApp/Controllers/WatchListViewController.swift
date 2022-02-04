//
//  ViewController.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 24/01/2022.
//

import FloatingPanel
import UIKit

class WatchListViewController: UIViewController {
    
    var panel: FloatingPanelController?
    
    private var watchlistMap = [String : [CandleStick]]()
    
    private var viewModels = [WatchlistViewModel]()
    
    static var maxChangeWidth: CGFloat = 0
    
    var observer: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchlistTableViewCell.self, forCellReuseIdentifier: WatchlistTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupTitleView()
        setupWatchlistData()
        setupTableView()
        setupFloatingPanel()
        setupObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupSearchBar() {
        let searchResultViewController = SearchResultsViewController()
        let searchViewController = UISearchController(searchResultsController: searchResultViewController)
        searchViewController.searchResultsUpdater = self
        searchResultViewController.delegate = self
        navigationItem.searchController = searchViewController
    }
    
    private func setupTitleView() {
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100
            )
        )
        
        let title = UILabel(
            frame: CGRect(
                x: 10,
                y: 0,
                width: titleView.width - 20,
                height: titleView.height
            )
        )
        
        title.text = "Stocks"
        title.font = .systemFont(ofSize: 25, weight: .medium)
        titleView.addSubview(title)
        
        navigationItem.titleView = titleView
    }
    
    private func setupTableView() {
        view.addSubviews(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupWatchlistData() {
        let symbols = PersistenseManager.shared.watchlist
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            APICaller.shared.marketData(symbol: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(_):
                    break
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    func setupFloatingPanel() {
        let topStoriesViewController = NewsViewController(type: .topStories)
        panel = FloatingPanelController(delegate: self)
//        panel?.surfaceView.backgroundColor = .secondarySystemBackground
        panel?.set(contentViewController: topStoriesViewController)
        panel?.addPanel(toParent: self)
        panel?.track(scrollView: topStoriesViewController.tableView)
    }
    
    func setupObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchlist,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.viewModels.removeAll()
                self?.setupWatchlistData()
            })
    }
    
    func createViewModels() {
        var viewModels = [WatchlistViewModel]()
        for (symbol, candleStick) in watchlistMap {
            let changePercentage = getChangePercentage(for: candleStick)
            viewModels.append(
                WatchlistViewModel(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleStick),
                    changeColor: changePercentage > 0 ? .systemGreen : .systemRed,
                    changePercentage: String.percentage(from: changePercentage),
                    viewModel: StockChartViewViewModel(
                        data: candleStick.reversed().map({ $0.close }),
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage > 0 ? .systemGreen : .systemRed
                    )
                )
            )
        }
        
        self.viewModels = viewModels
    }
    
    func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return String.formatted(from: closingPrice)
    }
    
    func getChangePercentage(for data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: { !Calendar.current.isDate( $0.date, inSameDayAs: latestDate)})?.close else  {
                  return 0.0
              }
              
        return 1 - (priorClose / latestClose)
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let searchViewController = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        APICaller.shared.search(query: query) { result in
            switch result {
            case .success(let response):
                searchViewController.update(with: response.result)
            case .failure(_):
                searchViewController.update(with: [])
            }
        }
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        let stockDetailViewController = StockDetailsViewController(
            symbol: searchResult.symbol,
            companyName: searchResult.description
        )
        let stockDetailNavigationController = UINavigationController(rootViewController: stockDetailViewController)
        stockDetailViewController.title = searchResult.description
        present(stockDetailNavigationController, animated: true, completion: nil)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistTableViewCell.identifier, for: indexPath) as? WatchlistTableViewCell else {
            return UITableViewCell()
        }
        
        let viewModel = viewModels[indexPath.row]
        cell.delegate = self
        cell.configure(with: viewModel)
        return cell
    }
}

extension WatchListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewModel = viewModels[indexPath.row]
        let stockDetailViewController = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let stockDetailNavigationController = UINavigationController(rootViewController: stockDetailViewController)
        present(stockDetailNavigationController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        WatchlistTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            PersistenseManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension WatchListViewController: WatchlistTableViewDelegate {
    func didUpdateMaxWidth() {
        tableView.reloadData()
    }
}
