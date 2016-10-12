//
//  MemeDetailViewController.swift
//  Meme 2.0
//
//  Created by Michael Kroth on 10/9/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var memeImage: UIImageView!
    
    var selectedMeme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeImage.image = selectedMeme.memeImage
        tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
    }

    @IBAction func editMeme(sender: AnyObject) {
        let editController = self.storyboard?.instantiateViewControllerWithIdentifier("MemeCreationViewController") as! MemeCreationViewController
        editController.meme = selectedMeme
        editController.editingMeme = true
        navigationController?.presentViewController(editController, animated: true, completion: nil)
    }

}
