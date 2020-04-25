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
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var saveImageButton: UIButton! {
        didSet {
            saveImageButton.setImage(UIImage(named: "saveImage"), for: .normal)
            saveImageButton.tintColor = .white
            saveImageButton.isHidden = false
            saveImageButton.isEnabled = false
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
    
    @IBOutlet weak var infoButton: UIButton! {
        didSet {
            infoButton.backgroundColor = .clear
            infoButton.alpha = 1
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
    
    @IBOutlet weak var unicornSelectionImageView: UIImageView! {
        didSet {
            unicornSelectionImageView.layer.cornerRadius = 5
            unicornSelectionImageView.layer.borderColor = UIColor.white.cgColor
            unicornSelectionImageView.layer.borderWidth = 2
            unicornSelectionImageView.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    /// edited Image
    var editedImage: UIImage?
    
    /// original image picked
    var originalImage: UIImage?
    
    /// AVCaptureSession
    let captureSession = AVCaptureSession()
    
    /// FaceLandmarksDetector
    var faceDetector: FaceLandmarksDetector?
    
    /// boolean to avoid updating image again and again at same time
    var isUpdatingImage: Bool = false
    
    ///  Boolean to avoid label animation again and again
    var isLabelAnimating: Bool = false
    
    /// Should Save Image - gets true when image gets edited properly
    var shouldSaveImage: Bool = false {
        didSet {
            saveImageButton.isEnabled = shouldSaveImage
        }
    }
    
    /// default unicorn image
    static var defaultUnicornImage: String = "uinicorn_horn_default"
    
    /// selected unicorn  image
    var selectedUnicornImage: String? = nil
    
    /// Is FaceLines Shown bool
    var isFaceLinesShown: Bool = false
    
    /// fade animator
    var messageLabelFadeAnimator: UIViewPropertyAnimator? = nil
    
    static var compressionPercentage: CGFloat = 0.35
    
    override func viewDidLoad() {
        super.viewDidLoad()
        faceDetector = FaceLandmarksDetector()
        setImage(image: ViewController.defaultUnicornImage)
        addGesture()
        activityIndicator(false)
        animateMessageLabel(text: "Please Upload/Take a picture of your face", delay: 3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
    
    private func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(unicornImageViewTapped))
        unicornSelectionImageView.addGestureRecognizer(tap)
    }
    
    @objc func unicornImageViewTapped() {
        let storyboard = UIStoryboard(name: "UnicornSelectionListViewController", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UnicornSelectionListViewController") as! UnicornSelectionListViewController
        viewController.view.backgroundColor = .clear
        viewController.delegate = self
        viewController.selectedImage = selectedUnicornImage
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true, completion: nil)
    }
    
    func setImage(image: String) {
        selectedUnicornImage = image
        DispatchQueue.main.async { [weak self] in
            self?.unicornSelectionImageView.image = UIImage(named: image)
            self?.imageView.image = self?.originalImage
            self?.shouldSaveImage = false
        }
    }
}

//MARK: - UnicornSelectionDelegateProtocol
extension ViewController: UnicornSelectionDelegateProtocol {
    func didSelect(image: String) {
        setImage(image: image)
        /// we have an original image - process it
        if let _ = originalImage {
            self.editedImage = nil
            self.processImage()
        } else {
            animateMessageLabel(text: "Please Upload/Take a picture of your face")
        }
    }
}

// MARK: - UIButton & Actions

extension ViewController {
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let infoAlert = UIAlertController.noActionPrompt(title: "About UniFier", message: "This app is designed for Unicorn lovers, People that love unicorn horn. It Uni-Fies you for the rest of your life by adding a unicorn horn on your forehead.") {
            // do nothing
        }
        
        infoAlert.configurePopOver(for: self.infoButton)
        self.present(infoAlert, animated: true, completion: nil)
    }
    
    @IBAction func openCameraButtonPressed(_ sender: Any) {
        openCameraButtonPressedAction()
    }
    
    @IBAction func saveImageButtonPressed(_ sender: Any) {
        if shouldSaveImage, let image = editedImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            animateMessageLabel(text: "No new photo to save")
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
        
        if var editedImage = info[.editedImage] as? UIImage {
            
            if let compressedImage = editedImage.resized(withPercentage: ViewController.compressionPercentage) {
                editedImage = compressedImage
            }
            
            originalImage = editedImage
            imageView.image = editedImage
            
            picker.dismiss(animated: true, completion: { [weak self] in
                self?.processImage()
            })
        } else if var image = info[.originalImage] as? UIImage {
            
            if let compressedImage = image.resized(withPercentage: ViewController.compressionPercentage) {
                image = compressedImage
            }
            
            originalImage = image
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
        guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty, let imageToSend = originalImage else {
            animateMessageLabel(text: "No Face detected")
            activityIndicator(false)
            return
        }
        
        activityIndicator(true)
        let finalImage = faceDetector?.addFaceLandmarksToImage(observations, sourceImage: imageToSend, isFaceLinesShown: isFaceLinesShown, selectedUnicornImage: selectedUnicornImage)
        shouldSaveImage =  true
        
        //// Image updated
        if let i = finalImage, let _ = i.cgImage {
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator(false)
                self?.imageView.image = i
                self?.editedImage = i
                self?.shouldSaveImage = true
            }
        } else {
            animateMessageLabel(text: "Image did not update")
            self.activityIndicator(false)
        }
        
        /// set isupdating image to false
        isUpdatingImage = false
    }
    
    func processImage() {
        guard let image = originalImage, !isUpdatingImage else {
            return
        }
        
        isUpdatingImage = true
        
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
    
    private func animateMessageLabel(text: String, delay: Double = 1, completion: (()->Void)? = nil) {
        
        guard !isLabelAnimating else {
            completion?()
            return
        }
        
        isLabelAnimating = true
        
        messageLabel.text = text
        messageLabel.sizeToFit()
        
        messageLabelFadeAnimator?.stopAnimation(true)
        messageLabelFadeAnimator = nil
        
        messageLabelFadeAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: { [weak self] in
            
            self?.messageContainerView.alpha = 1.0
            
        }) { [weak self] (pos) in
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: delay, options: [.beginFromCurrentState], animations: {  [weak self] in
                
                self?.messageContainerView.alpha = 0.0
                
            }) { [weak self] (pos) in
                self?.isLabelAnimating = false
                completion?()
            }
        }
        
        messageLabelFadeAnimator?.startAnimation()
    }
    
}
