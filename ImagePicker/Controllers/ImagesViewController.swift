//
//  ViewController.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageObjects = [ImageObject]()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private let imagePickerController = UIImagePickerController()
    
    private var selectedImage: UIImage? {
        didSet{
            // gets called when new image is selected
            // no dispatch main cuz we are not doing a network call
            appendNewPhoto()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePickerController.delegate = self
    }
    
    private func loadData() {
        do {
            imageObjects = try dataPersistance.loadEvents()
        } catch {
            print("load objects error: \(error)")
        }
    }
    
    private func appendNewPhoto() {
        //1. need to set image to data
        guard let image = selectedImage else {
            print("image is nil")
            return
        }
        //resize image:
        let size = UIScreen.main.bounds.size
        // maintain aspect ratio (orientation) of the image ==> need to import AVFoundation, use AVMakeRect()
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        //1a. jpegData will also change the size of the image.
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        print("image size: \(resizeImage.size)")
        
        //2. create an image object
        let imageObject = ImageObject(imageData: resizedImageData, date: Date())
        
        //3. insert to object to imageObjects
        imageObjects.insert(imageObject, at: 0)
        
        //4. create an indexPath for collection view
        let indexPath = IndexPath(row: 0, section: 0)
        
        //5. insert new cell to collection view
        collectionView.insertItems(at: [indexPath])
        
        //6. Persist image object to Documents Directory
        //try? dataPersistance.create(event: imageObject)
        do {
            try dataPersistance.create(event: imageObject)
        } catch {
            print("error saving \(error)")
        }
    }
    
    @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
        // present an action sheet to the user
        // actions: camera, photo library, cancel
        
        //1. create an alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //2. create actions/ buttons for the alert controller
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: true)
        }
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
        return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Custom Delegate - 4. must have an instance of object/ cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            fatalError("could not downcast to an ImageCell")
        }
        let imageObj = imageObjects[indexPath.row]
        cell.configureCell(image: imageObj)
        
        //Custom Delegate - 5. set delegate object
        cell.delegate = self
        
        return cell
    }
}
//Custom Delegate - 6. conform to delegate
extension ImagesViewController: ImageCellDelegate {
    func didLongPress(_ imageCell: ImageCell) {
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        
        //present an action sheet : delete, cancel
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deleteImage(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    //allow user to delete cell
    private func deleteImage(indexPath: IndexPath) {
        
        do {
            //1. delete image object from documents directory
            try dataPersistance.delete(event: indexPath.row)
            //2. delete imageObject from imageObjects
            imageObjects.remove(at: indexPath.row)
            //3. delete cell from collection view
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("error deleting cell")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)  }
}

extension ImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //need to access the "UIImagePickerController.InfoKey.originalImage" key to get the UIImage that was selected.
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selection not found")
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
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


