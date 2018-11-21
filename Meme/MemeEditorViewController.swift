//
//  MemeEditorViewController.swift
//
//
//  Created by Malik Basalamah on 06/03/1440 AH.
//  Copyright © 1440 Malik Basalamah. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {

    // define buttons, image , .. etc
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
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

        defaultConfiguration()
    
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
    
    func save() {
        // Create the meme
        let meme = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, originalImage: imageViewer.image!, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)

    }
    
    @IBAction func shareAction(_ sender: Any) {
        memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            // User completed activity
            if completed{
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(controller, animated: true, completion: nil)

    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Picker Controller to save the choosing image

    
    // 
    func imagePicker (sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func configureTextFields(_ textField: UITextField, with defaultText: String) {
        // TODO:- code to configure the textField
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self;
        textField.text = defaultText
        textField.textAlignment = NSTextAlignment.center
        textField.adjustsFontSizeToFitWidth = true
        textField.isUserInteractionEnabled = false
        }
    
    func toolbarState(hiddenBar:Bool){
        toolBar.isHidden = hiddenBar
        navigationBar.isHidden = hiddenBar
    }
    
    func defaultConfiguration(){
        configureTextFields(topTextField,with: "TOP")
        configureTextFields(bottomTextField, with: "BOTTOM")
        
        // Disable the Cancel Button
        shareButton.isEnabled = false
        imageViewer.image = nil
    }
    
    // #MARK Following code dealing with the Image
    
    // This func is to Save the image.

    
    // This func is to modify the image
    func generateMemedImage() -> UIImage {
        //  Hide toolbar and navbar
        toolbarState(hiddenBar: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        toolbarState(hiddenBar: false)


        return memedImage
    }

    //# MARK: following are textFields Delegates
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }

        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
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

extension MemeEditorViewController: UITextFieldDelegate {
    
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
}

extension MemeEditorViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewer.contentMode = .scaleAspectFit
            imageViewer.image = image
        }
       dismiss(animated: true,completion: nil)
        topTextField.isUserInteractionEnabled = true
        bottomTextField.isUserInteractionEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
