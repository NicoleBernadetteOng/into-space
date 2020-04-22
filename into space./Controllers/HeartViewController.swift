//
//  HeartViewController.swift
//  into space.
//
//  Created by Nicole Bernadette Ong on 21/4/20.
//  Copyright © 2020 Nicole Bernadette Ong. All rights reserved.
//

import UIKit

struct Words {
    var wordsText: String
}

class HeartCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var heartCellLabel: UITextView!
}


class HeartViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {


    // HEART DATA
    var heartList = [String]()
    var words = ""
    var releaseCount = [String]()
    
    @IBOutlet weak var heartCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heartCollectionView.delegate = self
        heartCollectionView.dataSource = self
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heartList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = heartCollectionView.dequeueReusableCell(withReuseIdentifier: "heartCell", for: indexPath) as! HeartCollectionViewCell
        cell.heartCellLabel?.text = heartList[indexPath.row]
        
        return cell
    }
    
    
    // When tap on the collection view cell, open a view controller to show what was in the note - can keep or delete
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = heartList[indexPath.row]
        print(message)
        
        let alertController = UIAlertController(title: "Are you over it?", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "I'm still salty", style: .default))
        alertController.addAction(UIAlertAction(title: "You know it", style: .default, handler: { action in
            // remove item from wordsArray
            self.heartList.remove(at: indexPath.row)
            UserDefaults.standard.set(self.heartList, forKey: "wordsArray")
            
            self.releaseCount.append("star2.png")
            UserDefaults.standard.set(self.releaseCount, forKey: "releaseCounter")
            
            self.performSegue(withIdentifier: "showSpace", sender: self)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpace" {
            let spaceVC = segue.destination as! SpaceViewController
            spaceVC.starList = releaseCount
        }
    }
    
}
