//
//  SpaceViewController.swift
//  into space.
//
//  Created by Nicole Bernadette Ong on 21/4/20.
//  Copyright © 2020 Nicole Bernadette Ong. All rights reserved.
//

import UIKit

class StarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}


class SpaceViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var starList = [String]()

    @IBOutlet weak var starCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        starCollectionView.delegate = self
        starCollectionView.dataSource = self
        
        // multiple columns
        let flowLayout = UICollectionViewFlowLayout()
        let size = (starCollectionView.frame.size.width - CGFloat(40)) / CGFloat(4)
        flowLayout.itemSize = CGSize(width: size, height: size)
        starCollectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = starCollectionView.dequeueReusableCell(withReuseIdentifier: "starCell", for: indexPath) as! StarCollectionViewCell
        
        cell.imageView.image = UIImage(named: starList[indexPath.row])
        
        return cell
    }
    
}


