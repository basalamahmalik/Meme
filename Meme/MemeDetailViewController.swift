//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by Malik Basalamah on 13/03/1440 AH.
//  Copyright © 1440 Malik Basalamah. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController:UIViewController{
    
    var memes:Meme!
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.image = memes.memedImage
    }
    
    
}
