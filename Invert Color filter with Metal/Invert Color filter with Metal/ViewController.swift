//
//  ViewController.swift
//  Invert Color filter with Metal
//
//  Created by Mac mini on 31/1/21.
//

import UIKit
import Metal
import MetalKit

class ViewController: UIViewController {

    @IBOutlet weak var normalImage: UIImageView!
    @IBOutlet weak var invertedImage: UIImageView!
    
    let imageFilter = MetalImageFilter()
    var number = Int(1)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            DispatchQueue.main.async {
                let image = UIImage(named: String(self.number))
                self.normalImage.image = image
                self.invertedImage.image = self.imageFilter!.imageInvertColors(of: image!)
                self.number += 1
                if (self.number > 17 )
                {
                    self.number = 1
                }
            }
        }
    }
}

