//
//  ImageSelectionViewController.swift
//  Final Qualifying Work
//
//  Created by Vanüsha on 04.05.2022.
//

import UIKit
import PhotosUI

protocol SettingsViewControllerDelegate {
    func updateImageScale(newScale: Float)
}

class ImageSelectionViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var processButton: UIButton!
    
    var imageScale: Float = 1.0
    
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
            let alert = UIAlertController(title: "Select an Image",
                                          message: "You have to provide an image for algorithm to process",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(action)
            present(alert, animated: true)
            
            return
        }
        
        performSegue(withIdentifier: K.imageSelectionToResultSegue, sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        guard imageView.image != nil else {
            let alert = UIAlertController(title: "Select an Image",
                                          message: "You have to provide an image for algorithm to process",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(action)
            present(alert, animated: true)
            
            return
        }
        
        performSegue(withIdentifier: K.imageSelectionToSettingsSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.imageSelectionToResultSegue {
            let resultVC = segue.destination as! ResultViewController
            guard let originalImage = imageView.image else { return }
            guard let cgImage = originalImage.cgImage else { return }
            
            let width = Int(Float(cgImage.width) / imageScale)
            let height = Int(Float(cgImage.height) / imageScale)
            let space = CGColorSpaceCreateDeviceRGB()
            var bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue
            bitmapInfo |= CGBitmapInfo.byteOrder32Big.rawValue
            
            guard let cgContext = CGContext(data: nil,
                                            width: width,
                                            height: height,
                                            bitsPerComponent: 8,
                                            bytesPerRow: 0,
                                            space: space,
                                            bitmapInfo: bitmapInfo) else { return }
            
            let drawRectangle = CGRect(x: 0, y: 0, width: width, height: height)
            cgContext.draw(cgImage, in: drawRectangle)
            
            guard let resizedCGImage = cgContext.makeImage() else { return }
            resultVC.imageManager.imageDictionary[.original] = UIImage(cgImage: resizedCGImage,
                                                                       scale: 1.0,
                                                                       orientation: originalImage.imageOrientation)
            return
        }
        
        if segue.identifier == K.imageSelectionToSettingsSegue {
            let settingsVC = segue.destination as! SettingsViewController
            guard let image = imageView.image else { return }
            
            let imageHeight = Int(image.size.height)
            let imageWidth = Int(image.size.width)
            
            settingsVC.height = imageHeight
            settingsVC.width = imageWidth
            settingsVC.delegate = self
            settingsVC.startingScale = imageScale
            
            return
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
                    
                    if let safeImage = self.imageView.image {
                        let width = Int(safeImage.size.width)
                        let height = Int(safeImage.size.height)
                        
                        self.imageScale = min(width, height) > 256 ? Float(min(width, height)) / 256.0 : 1.0
                    }
                }
            }
        }
    }
}

extension ImageSelectionViewController: SettingsViewControllerDelegate {
    func updateImageScale(newScale: Float) {
        imageScale = newScale
    }
}
