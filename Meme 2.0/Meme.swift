//
//  Meme.swift
//  Image Picker
//
//  Created by Michael Kroth on 10/1/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation
import UIKit

extension MemeCreationViewController {
    
    struct Meme {
        
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memeImage: UIImage

    }
    
    func saveMeme(memeImage: UIImage) {
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memeImage)
        // I'm guessing well do somthing with this in the next lesson
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbars so they don't appear in meme
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage: UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // unhide toolbars
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }
}
