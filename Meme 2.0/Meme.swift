//
//  Meme.swift
//  Image Picker
//
//  Created by Michael Kroth on 10/1/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation
import UIKit


    struct Meme {
        
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memeImage: UIImage
        
        init (topText: String, bottomText: String, originalImage: UIImage, memeImage: UIImage) {
            self.topText = topText
            self.bottomText = bottomText
            self.originalImage = originalImage
            self.memeImage = memeImage            
        }

    }

