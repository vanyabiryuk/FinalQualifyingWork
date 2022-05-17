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
    
    /// Shows a view where user can select an image to filter.
    @IBAction func selectImageButtonPressed(_ sender: UIButton) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .automatic
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    /// Checks if some image is selected.
    /// If not, shows an alert.
    /// If so, performs segue to the next screen.
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
    
    /// Prepares function to perform segue. Scales large images to increase computation speed and passes this image to the next ViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.imageSelectionToResultSegue {
            let resultVC = segue.destination as! ResultViewController
            guard let originalImage = imageView.image else { return }
            guard let cgImage = originalImage.cgImage else { return }
            
            // TODO: Make it user defined
            let scale = 10.0
            
            let width = Int(Double(cgImage.width) / scale)
            let height = Int(Double(cgImage.height) / scale)
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
        }
    }
}

extension ImageSelectionViewController: PHPickerViewControllerDelegate {
    
    /// Dissmissing image picker and trying to cast returned results as UIImage
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
