//
//  SettingsViewController.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 20.05.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var imageSizeLabel: UILabel!
    @IBOutlet weak var imageScaleSlider: UISlider!
    @IBOutlet weak var imageScaleLabel: UILabel!
    @IBOutlet weak var scalingResultLabel: UILabel!
    
    var height = 256
    var width = 256
    
    var delegate: SettingsViewControllerDelegate?
    var startingScale: Float = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSizeLabel.text = "Your image is \(width)x\(height) pixels."
        
        imageScaleSlider.minimumValue = 1.0
        imageScaleSlider.maximumValue = min(width, height) > 256 ? Float(min(width, height)) / 256.0 : 1.0
        imageScaleSlider.value = startingScale
        
        scalingResultLabel.text = "After scaling your image will be \(Int(Float(width) / startingScale))x\(Int(Float(height) / startingScale)) pixels"
        imageScaleLabel.text = "x\(String(format: "%.2f", 1.0 / startingScale))"
    }
    
    @IBAction func scaleSliderValueChanged(_ sender: Any) {
        let scale = imageScaleSlider.value
        
        imageScaleLabel.text = "x\(String(format: "%.2f", 1.0 / scale))"
        scalingResultLabel.text = "After scaling your image will be \(Int(Float(width) / scale))x\(Int(Float(height) / scale)) pixels"
        delegate?.updateImageScale(newScale: scale)
    }
}
