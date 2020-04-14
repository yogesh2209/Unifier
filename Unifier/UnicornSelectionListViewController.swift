//
//  UnicornSelectionListViewController.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/13/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit

protocol UnicornSelectionDelegateProtocol: NSObjectProtocol {
    func didSelect(image: String)
}

class UnicornSelectionListViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [String] = [ViewController.defaultUnicornImage, "a", "b", "c", "d"]
    
    var selectedImage: String? = nil
    
    weak var delegate: UnicornSelectionDelegateProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addBlur()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
               layout.scrollDirection = .vertical
               collectionView.setCollectionViewLayout(layout, animated: true)
               collectionView.reloadData()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectButtonPressed(_ sender: Any) {
        delegate?.didSelect(image: (selectedImage ?? ViewController.defaultUnicornImage))
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDataSource
extension UnicornSelectionListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unicornCell", for: indexPath) as? UnicornSelectionCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var image = ""
        if images.indices.contains(indexPath.row) {
            image = images[indexPath.row]
            cell.imageView.image = UIImage(named: image)
        }
        
        if let selected = selectedImage, image == selected {
            cell.imageView.layer.borderColor = UIColor.white.cgColor
            cell.imageView.layer.borderWidth = 2
            cell.imageView.layer.cornerRadius = 2
        } else {
            cell.imageView.layer.borderColor = UIColor.clear.cgColor
            cell.imageView.layer.borderWidth = 0
            cell.imageView.layer.cornerRadius = 0
        }
            
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension UnicornSelectionListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images.indices.contains(indexPath.row) {
            selectedImage = images[indexPath.row]
        }
        
        self.collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UnicornSelectionListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalWidth = collectionView.frame.width
        let cellWidth = totalWidth / 3
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
