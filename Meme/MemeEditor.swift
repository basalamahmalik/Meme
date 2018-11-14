//
//  ViewController.swift
//  Meme
//
//  Created by Malik Basalamah on 06/03/1440 AH.
//  Copyright © 1440 Malik Basalamah. All rights reserved.
//

import UIKit

class MemeEditor: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    // define buttons, image , .. etc
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // define proparties
    var memedImage: UIImage?
    var memeGetImage: Meme?
    
    // set the text attributes in textfields
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeColor: UIColor.black,
        .strokeWidth: -1 // Change here
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        
        topTextField.delegate = self;
        bottomTextField.delegate = self;
        
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.center
        topTextField.adjustsFontSizeToFitWidth = true
        topTextField.isUserInteractionEnabled = false

        
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.center
        bottomTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.isUserInteractionEnabled = false

        // Disable the Cancel Button
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        imageViewer.image = nil

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable the Camera button if the camera is not available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        
        //
        self.subscribeToKeyboardNotifications()
        
        // Disable the sharebutton if the image viewer dosn't have a picture
        if imageViewer?.image == nil{
            self.shareButton.isEnabled = false
        }else {
            self.shareButton.isEnabled = true
        }
        
        // assign the from the struct while in viewWillAppear
        if let meme = memeGetImage {
            self.topTextField.text = meme.topTextField
            self.bottomTextField.text = meme.bottomTextField
            self.imageViewer?.image = meme.originalImage
            self.memeGetImage = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //
        unsubscribeFromKeyboardNotifications()
    }
    
    // # MARK : Actions For Buttons
    
    @IBAction func openCamera(_ sender: Any) {
        imagePicker(sourceType: .camera)
    }
    
    @IBAction func openAlbum(_ sender: Any) {
        imagePicker(sourceType: .photoLibrary)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("User Cancelled...!")
            }
            // User completed activity
            self.memedImage = self.generateMemedImage()
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        viewDidLoad()
    }
    
    
    // Picker Controller to save the choosing image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewer.contentMode = .scaleAspectFit
            imageViewer.image = image
            save()
        }
        dismiss(animated: true,completion: nil)
        topTextField.isUserInteractionEnabled = true
        bottomTextField.isUserInteractionEnabled = true
    }
    
    // 
    func imagePicker (sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        cancelButton.isEnabled = true
    }
    
    // #MARK Following code dealing with the Image
    
    // This func is to Save the image.
    func save() {
        // Create the meme
        let meme = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, originalImage: imageViewer.image!, memedImage: memedImage)
    }
    
    
    // This func is to modify the image
    func generateMemedImage() -> UIImage {
        //  Hide toolbar and navbar
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        return memedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //# MARK: following are textFields Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField {
            topTextField.text = ""
        }else {
            bottomTextField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
            view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // #MARK:  Notifications Subscribtions
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
}

