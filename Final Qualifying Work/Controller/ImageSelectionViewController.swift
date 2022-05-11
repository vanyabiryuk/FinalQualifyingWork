//
//  ImageSelectionViewController.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 04.05.2022.
//

import UIKit
import PhotosUI

class ImageSelectionViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var processButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectImageButtonPressed(_ sender: UIButton) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func processButtonPressed(_ sender: UIButton) {
        guard imageView.image != nil else {
            let alert = UIAlertController(title: "Select an Image", message: "You have to provide an image for algorithm to process", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(action)
            present(alert, animated: true)
            
            return
        }
        
        performSegue(withIdentifier: K.imageSelectionToResultSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.imageSelectionToResultSegue {
            let resultVC = segue.destination as! ResultViewController
            resultVC.imageManager.imageDictionary[.original] = imageView.image
        }
    }
}

extension ImageSelectionViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard results.count != 0 else { return }
        
        let result = results[0]
        let itemProvider = result.itemProvider
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.imageView.image = image as? UIImage
                }
            }
        }
    }
}