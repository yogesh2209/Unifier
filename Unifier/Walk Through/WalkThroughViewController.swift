//
//  WalkThroughViewController.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/25/20.
//  Copyright © 2020. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController {
    
    @IBOutlet weak var getStartedButton: UIButton! {
        didSet {
            getStartedButton.layer.cornerRadius = 5
            getStartedButton.layer.borderColor = UIColor.white.cgColor
            getStartedButton.layer.borderWidth = 1
            getStartedButton.titleLabel?.textColor = .white
        }
    }
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isPagingEnabled = true
            scrollView.isUserInteractionEnabled = true
        }
    }
    
    /// scroll view size
    var scrollViewSize: CGSize = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        scrollViewSize = scrollView.frame.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        UserDefaults.standard.didPresentWalkThrouh = true
        
        /// push main view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    private func setupViews() {
        
        view.backgroundColor = .black
        
        /// set scrollview size
        scrollViewSize = scrollView.frame.size
        
        /// Create slides and add them
        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        for index in 0..<DataSource.allCases.count {
            let dataSourceType = DataSource.allCases[index]
            
            frame.origin.x = scrollViewSize.width * CGFloat(index)
            frame.size = scrollViewSize
            
            /// slide to add
            let slide = UIView(frame: frame)
            
            /// subviews
            let imageView = UIImageView(image: UIImage(named: dataSourceType.image))
            imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            imageView.contentMode = .scaleAspectFit
            imageView.center = CGPoint(x: view.frame.size.width/2, y: scrollViewSize.height/2 - 50)
            
            
            var titleHeight: CGFloat = 35
            var titleFontSize: CGFloat = 22
            var subTitleHeight: CGFloat = 50
            var subTitleFontSize: CGFloat = 15
            if UIDevice.isIPad {
                titleHeight = 55
                titleFontSize = 35
                subTitleHeight = 75
                subTitleFontSize = 25
            }
            
            /// title
            let title = UILabel(frame: CGRect(x: 32, y: imageView.frame.maxY + 30, width: view.frame.size.width - 64, height: titleHeight))
            title.textAlignment = .center
            
            
            title.font = UIFont.boldSystemFont(ofSize: titleFontSize)
            title.text = dataSourceType.title
            title.textColor = .white
            
            /// subtitle
            let subTitle = UILabel(frame: CGRect(x: 32, y: title.frame.maxY + 0, width: view.frame.size.width - 64, height: subTitleHeight))
            subTitle.textAlignment = .center
            subTitle.numberOfLines = 0
            subTitle.lineBreakMode = .byTruncatingTail
            subTitle.font = UIFont.systemFont(ofSize: subTitleFontSize)
            subTitle.text = dataSourceType.subTitle
            subTitle.textColor = .lightGray
            
            /// add all the views
            slide.addSubview(imageView)
            slide.addSubview(title)
            slide.addSubview(subTitle)
            scrollView.addSubview(slide)
        }
        
        /// Settings width of scrollview to take all the slides
        scrollView.contentSize = CGSize(width: scrollViewSize.width * CGFloat(DataSource.allCases.count), height: scrollViewSize.height)
        
        /// Disable vertical scroll/bounce
        scrollView.contentSize.height = 1.0
        
        /// Set properties of page control
        pageControl.numberOfPages = DataSource.allCases.count
        pageControl.currentPage = 0
    }
    
    @IBAction func pageValueChanged(_ sender: Any) {
        let rect = CGRect(x: scrollViewSize.width * CGFloat(pageControl.currentPage), y: 0, width: scrollViewSize.width, height: scrollViewSize.height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension WalkThroughViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateUIForCurrentPage()
    }
    
    func updateUIForCurrentPage() {
        if scrollViewSize.width != 0 {
            let pageNumber = (scrollView.contentOffset.x) / scrollViewSize.width
            pageControl.currentPage = Int(pageNumber)
        } else {
            pageControl.currentPage = 0
        }
    }
    
}

// MARK: - DataSource
extension WalkThroughViewController {
    
    enum DataSource: CaseIterable {
        case slide1
        case slide2
        case slide3
        
        var title: String {
            switch self {
            case .slide1:
                return "TAKE PHOTO"
            case .slide2:
                return "SELECT UNICORN HORN"
            case .slide3:
                return "ENJOY & SAVE PHOTO"
            }
        }
        
        var subTitle: String {
            switch self {
            case .slide1:
                return "Take your photo or pick it from your library"
            case .slide2:
                return "Select from available options"
            case .slide3:
                return "Save Unified photo to your library"
            }
        }
        
        var image: String {
            switch self {
            case .slide1:
                return "slide1"
            case .slide2:
                return "u4"
            case .slide3:
                return "slide3"
            }
        }
    }
}
