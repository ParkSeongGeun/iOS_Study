//
//  ViewController.swift
//  DynamicStackView
//
//  Created by 박성근 on 12/29/24.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: - UIComponents
  private let mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 10
    return stackView
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return refreshControl
  }()
  
  // MARK: - Filter Contents
  private let filterContents: [[String: Int]] = [["음식": 80], ["실내": 20], ["실외": 17], ["메뉴 * 정보": 18], ["주차": 3], ["전체": 10], ["이걸 왜 넣어": 999]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setLayout()
    createFilterContentView()
  }
  
  // FilterContentView 생성
  private func createFilterContentView() {
    let filterContents = requestFilterContents()
    
    let maxWidth = UIApplication.screenWidth - 32 // margin
    var currentRow: UIStackView = createHorizontalStack()
    var currentWidth: CGFloat = 0
    
    for content in filterContents {
      let button = createRectangleButton(params: content)
      
      // 버튼 크기 계산
      let buttonSize = button.sizeThatFits(CGSize(width: maxWidth, height: 30))
      let buttonWidth = buttonSize.width
      
      // 이 버튼을 추가했을 때 최대 너비를 초과하는지 확인
      if currentWidth + buttonWidth > maxWidth {
        // 현재 행을 mainStackView에 추가하고 새로운 행 생성
        mainStackView.addArrangedSubview(currentRow)
        currentRow = createHorizontalStack()
        currentWidth = 0
      }
      
      // 현재 행에 버튼 추가
      currentRow.addArrangedSubview(button)
      currentWidth += buttonWidth + currentRow.spacing
    }
    
    // 마지막 행에 버튼이 있다면 추가
    if currentRow.arrangedSubviews.count > 0 {
      mainStackView.addArrangedSubview(currentRow)
    }
  }
  
  private func requestFilterContents() -> [[String: Int]] {
    let randomCount = Int.random(in: 3...filterContents.count)
    
    let randomResults = filterContents.shuffled().prefix(randomCount)
    
    return Array(randomResults)
  }
}

// MARK: - Setup
extension ViewController {
  private func setLayout() {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.refreshControl = refreshControl
    
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(scrollView)
    scrollView.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      // ScrollView Constraints
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // MainStackView Constraints
      mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
      mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
    ])
  }
}

// MARK: - UI Create Logic / Action
extension ViewController {
  private func createHorizontalStack() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.alignment = .leading
    stackView.distribution = .fillProportionally
    return stackView
  }
  
  private func createRectangleButton(params: [String: Int]) -> UIButton {
    var configuration = UIButton.Configuration.filled()
    
    configuration.cornerStyle = .capsule
    configuration.baseBackgroundColor = .systemBlue
    
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
    
    if let key = params.keys.first, let value = params.values.first {
      var container = AttributeContainer()
      container.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      configuration.attributedTitle = AttributedString("\(key)(\(value))", attributes: container)
    }
    
    let button = UIButton(configuration: configuration)
    button.configuration?.buttonSize = .large
    return button
  }
  
  @objc private func handleRefresh() {
    mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    createFilterContentView()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.refreshControl.endRefreshing()
    }
  }
}

extension UIApplication {
  static var screenSize: CGSize {
    guard let windowScene = shared.connectedScenes.first as? UIWindowScene else {
      return UIScreen.main.bounds.size
    }
    return windowScene.screen.bounds.size
  }
  
  static let screenHeight: CGFloat = screenSize.height
  static let screenWidth: CGFloat = screenSize.width
  static let isMinimumSizeDevice: Bool = screenSize.height <= 667
}
