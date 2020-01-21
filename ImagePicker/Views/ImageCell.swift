//
//  ImageCell.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

// Custom Delegate - 1.
protocol ImageCellDelegate: AnyObject { // AnyObject requires ImageCellDelegate == only works with Classes
    
    //list required functions, initializers, variables
    func didLongPress(_ imageCell: ImageCell)
}

class ImageCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!

    // Custom Delegate - 2. define optional delegate variable
    // needs to be weak or else the vc will have a strong ref to cell.
    weak var delegate: ImageCellDelegate?
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(longPressAction(gesture:)) )
        return gesture
    } ()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 20.0
    backgroundColor = .orange
    
    addGestureRecognizer(longPressGesture)
    
  }
    
    @objc
    private func longPressAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began { //if gesture is active
            gesture.state = .cancelled
            return
        }
        // Custom Delegate - 3. assign delegate
        // here is when we want to transfer information from cell to vc
        delegate?.didLongPress(self)
    }
    
    public func configureCell(image: ImageObject) {
        //converting data to UIImage
        guard let image = UIImage(data: image.imageData) else {
            return
        }
        imageView.image = image
    }
}
