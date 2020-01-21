//
//  ViewController.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
      
  private var imageObjects = [ImageObject]()
    
    private let imagePickerController = UIImagePickerController()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
  }
    
    @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
        // present an action sheet to the user
        // actions: camera, photo library, cancel
        
        //1. create an alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //2. create actions/ buttons for the alert controller
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: false)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        //3. check if camera is accessable/ available for app use
        //   if the camera is not available the app will crash
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        //4. add the other actions to alert controller
        alertController.addAction(photoLibrary)
        alertController.addAction(cancel)
        
        //5. animated alert controller
        present(alertController, animated: true)
    }
    
    private func showImageController(isCameraSelected: Bool) {
        // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        
        present(imagePickerController, animated: true)
    }
    
    
}



// MARK: - UICollectionViewDataSource
extension ImagesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
      fatalError("could not downcast to an ImageCell")
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxWidth: CGFloat = UIScreen.main.bounds.size.width
    let itemWidth: CGFloat = maxWidth * 0.80
    return CGSize(width: itemWidth, height: itemWidth)  }
}

// more here: https://nshipster.com/image-resizing/
// MARK: - UIImage extension
extension UIImage {
  func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
    let size = CGSize(width: width, height: height)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
      self.draw(in: CGRect(origin: .zero, size: size))
    }
  }
}

