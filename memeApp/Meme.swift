//
//  Meme.swift
//  memeApp
//
//  Created by Shivam Dev on 11/05/18.
//  Copyright © 2018 Shivam Dev. All rights reserved.
//

import UIKit



class Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
