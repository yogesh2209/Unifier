//
//  ViewController.swift
//  Unifier
//
//  Created by Kohli, Yogesh on 4/11/20.
//  Copyright © 2020 CBS. All rights reserved.
//

import UIKit
import CoreMedia
import Vision
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.setImage(UIImage(named: "saveImage"), for: .normal)
            saveImageButton.tintColor = .white
            saveImageButton.isHidden = true
        }
    }
    
    @IBOutlet weak var openCameraButton: UIButton! {
        didSet {
            openCameraButton.setImage(UIImage(named: "camera"), for: .normal)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var messageContainerView: UIView! {
        didSet {
            messageContainerView.alpha = 0
            messageContainerView.layer.cornerRadius = 5
            messageContainerView.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1)
        }
    }
    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.backgroundColor = .clear
            messageLabel.textColor = .white
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = .byTruncatingTail
        }
    }
    
    /// Selected Image
    var selectedImage: UIImage?
    
    /// AVCaptureSession
    let captureSession = AVCaptureSession()
    
    /// FaceLandmarksDetector
    let faceDetector = FaceLandmarksDetector()
    
    /// Should Save Image - gets true when image gets edited properly
    var shouldSaveImage: Bool = false {
        didSet {
            saveImageButton.isEnabled = shouldSaveImage
            saveImageButton.isHidden = !shouldSaveImage
        }
    }
    
    /// Is FaceLines Shown bool
    var isFaceLinesShown: Bool = false
    
    var messageLabelFadeAnimator: UIViewPropertyAnimator? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator(false)
    }
    
    /// Activity Indicator
    private func activityIndicator(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }  else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: - UIButton & Actions

extension ViewController {
    @IBAction func openCameraButtonPressed(_ sender: Any) {
        openCameraButtonPressedAction()
    }
    
    @IBAction func saveImageButtonPressed(_ sender: Any) {
        if shouldSaveImage, let image = selectedImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func openCameraButtonPressedAction() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let openCameraAlert = UIAlertController.openCameraPrompt(openCameraAction: { [weak self] in
            
            guard let self = self else {
                return
            }
            
            /// open camera
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // present no camera alert
                let noCameraAlert = UIAlertController.noActionPrompt(title: "No Camera Available", cancelAction: {
                    // do nothing for now
                })
                
                noCameraAlert.configurePopOver(for: self.openCameraButton)
                self.present(noCameraAlert, animated: true, completion: nil)
            }
            }, openGalleryAction: { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                /// open gallery
                imagePicker.sourceType = .photoLibrary
                imagePicker.configurePopOver(for: self.openCameraButton)
                self.present(imagePicker, animated: true, completion: nil)
            }, cancelAction: {
                /// cancel - do nothing
        })
        
        /// Present Alert
        openCameraAlert.configurePopOver(for: openCameraButton)
        present(openCameraAlert, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            imageView.image = editedImage
            picker.dismiss(animated: true, completion: { [weak self] in
                self?.processImage()
            })
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            imageView.image = originalImage
            picker.dismiss(animated: true, completion: {
                DispatchQueue.main.async { [weak self] in
                    self?.processImage()
                }
            })
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            animateMessageLabel(text: "Error Saving Image")
        } else {
            animateMessageLabel(text: "Photo Saved")
        }
    }
}

// MARK: - Processing Image
extension ViewController {
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation], let imageToSend = selectedImage else {
            return
        }
        
        activityIndicator(true)
        let finalImage = faceDetector.addFaceLandmarksToImage(observations, sourceImage: imageToSend, isFaceLinesShown: isFaceLinesShown)
        shouldSaveImage =  true
        //// Image updated
        if let i = finalImage, let _ = i.cgImage {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator(false)
                self?.imageView.image = i
                self?.selectedImage = i
                self?.shouldSaveImage = true
            }
        } else {
            animateMessageLabel(text: "Image did not update")
            self.activityIndicator(false)
        }
    }
    
    func processImage() {
        guard let image = selectedImage else {
            return
        }
        
        var orientation: CGImagePropertyOrientation
        
        /// Detects Image Orientation
        switch image.imageOrientation {
        case .up:
            orientation = .up
        case .right:
            orientation = .right
        case .down:
            orientation = .down
        case .left:
            orientation = .left
        default:
            orientation = .up
        }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: orientation, options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }
}

//MARK: - MessageLabel Animation
extension ViewController {
    
    private func animateMessageLabel(text: String, completion: (()->Void)? = nil) {
        
        guard !(messageLabelFadeAnimator?.isRunning ?? false) else {
            completion?()
            return
        }
        
        messageLabel.text = text
        messageLabel.sizeToFit()
        
        messageLabelFadeAnimator?.stopAnimation(true)
        messageLabelFadeAnimator = nil
        
        messageLabelFadeAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            
            self?.messageContainerView.alpha = 1.0
            
        }) { [weak self] (pos) in
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.5, options: [.beginFromCurrentState], animations: {
                
                self?.messageContainerView.alpha = 0.0
                
            }) { (pos) in
                completion?()
            }
        }
        
        messageLabelFadeAnimator?.startAnimation()
    }
    
}
