//
//  ViewController.swift
//  memeApp
//
//  Created by Shivam Dev on 08/05/18.
//  Copyright © 2018 Shivam Dev. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextFiel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveImageBtn: UIBarButtonItem!
    @IBOutlet weak var memedImageView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    
    
    //constraint
    @IBOutlet weak var topImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFielConstrain: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFielContrain: NSLayoutConstraint!
    
    var meme: Meme!
    
    
    let memeTextAttributes: [String: Any] = [
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
        //negative stroke width so that we get the foreground color
        NSAttributedStringKey.strokeWidth.rawValue: -5.0,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraBtn.isEnabled =  UIImagePickerController.isSourceTypeAvailable(.camera)
        topTextField.delegate = self
        bottomTextFiel.delegate = self
        
        topTextField.clearsOnBeginEditing = true
        bottomTextFiel.clearsOnBeginEditing = true
        
        shareBtn.isEnabled = true
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            subscribeToKeyboardNotification()
        }
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            unsubscribeFromKeyboardNotification()
        }
        //w=627 h=195
        //335--487
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            let orientation = UIDevice.current.orientation
            
            if orientation.isLandscape {
                topImageConstraint.constant = 20
                topTextFielConstrain.constant = 30
                bottomTextFielContrain.constant = 30
            } else {
                topImageConstraint.constant = 90
                topTextFielConstrain.constant = 80
                bottomTextFielContrain.constant = 80
            }
        }
    
    
        func subscribeToKeyboardNotification() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        }
    
        func unsubscribeFromKeyboardNotification() {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        }
    
        @objc func keyboardWillShow(_ notification: Notification) {
    //        view.frame.origin.y -= getKeyboardHeight(notification)
            
            
            var userInfo = notification.userInfo!
            var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset: UIEdgeInsets = self.scrollView.contentInset
    //        contentInset.bottom = keyboardFrame.size.height
            contentInset.bottom = getKeyboardHeight(notification)
            scrollView.contentInset = contentInset
            
        }
    
        func keyboardWillHide() {
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
        }
    
        func getKeyboardHeight(_ notification: Notification) -> CGFloat {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.cgRectValue.height
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            saveImageBtn.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        let memedImage = generateMemedImage()
        
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextFiel.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        //Render view to an image
        UIGraphicsBeginImageContext(self.memedImageView.frame.size)
        memedImageView.drawHierarchy(in: self.imagePickerView.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    
    @IBAction func shareBtnWasPressed(_ sender: Any) {
        if (meme) != nil {
            let imageShare = [ meme.memedImage ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "NO IMAGE FOUND", message: "Please edit an meme image then share.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    

    @IBAction func pickAnimage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveImageBtnPressed(_ sender: Any) {
        save()
        if (meme) != nil {
            UIImageWriteToSavedPhotosAlbum(meme.memedImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            saveImageBtn.isEnabled = false
            present(ac, animated: true)
        }
    }
    
    
}


extension ViewController: UITextFieldDelegate{

    func textFieldDidBeginEditing(_ textField: UITextField) {
        topTextField.textAlignment = NSTextAlignment.center
        bottomTextFiel.textAlignment = NSTextAlignment.center
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextFiel.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.center
        bottomTextFiel.textAlignment = NSTextAlignment.center
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextFiel.resignFirstResponder()
        keyboardWillHide()
        return true
    }

}





















