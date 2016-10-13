//
//  MemeCollectionViewController.swift
//  Meme 2.0
//
//  Created by Michael Kroth on 10/6/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//
import UIKit

private let reuseIdentifier = "memeCell"

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    var screenSize: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustFlowLayoutSpacing()
    }
    
    // Invalidates the flowlayout upon screen rotaion so view is recalulated
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func adjustFlowLayoutSpacing() {
        screenSize = UIScreen.mainScreen().bounds
        let spacing : CGFloat = 3.0
        let leftRightInset: CGFloat = 3
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: leftRightInset, bottom: 20, right: leftRightInset)
        flowLayout.itemSize = CGSize(width: (screenSize.width - (spacing * 3) - 6) / 3, height: (screenSize.width  - (spacing * 3)) / 3)
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        cell.memeImage.image = meme.memeImage
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailMemeController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailMemeController.selectedMeme = memes[indexPath.row]
        self.navigationController?.pushViewController(detailMemeController, animated: true)
    }

}
