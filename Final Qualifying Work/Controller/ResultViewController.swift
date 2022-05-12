//
//  ResultViewController.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 09.05.2022.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var imageManager = ImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageManager.createGrayscaleImage()
        
        pickerView(pickerView, didSelectRow: 0, inComponent: 0)
        pickerView.dataSource = self
        pickerView.delegate = self
    }
}

// MARK: Picker view data source and delegate methods

extension ResultViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Filter.allCases.count
    }
}

extension ResultViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Filter.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedFilter = Filter.allCases[row]
        imageView.image = imageManager.getImage(for: selectedFilter)
    }
}
