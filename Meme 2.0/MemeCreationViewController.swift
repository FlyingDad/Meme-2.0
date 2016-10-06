//
//  ViewController.swift
//  Image Picker
//
//  Created by Michael Kroth on 9/29/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class MemeCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBarActionButton: UIBarButtonItem!
    @IBOutlet weak var albumPickButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
   
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields(topTextField)
        setupTextFields(bottomTextField)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Enable the camera button if phone has camera and user has authorized its use
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotofocations()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Hide the phone status bar in this app
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupTextFields(textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.clearsOnBeginEditing = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // textfields will no longer clear on edit after the first time edited
        textField.clearsOnBeginEditing = false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotofocations() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreationViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreationViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Shift view up when editin bottom text field so it's not hidden keyboard
    func keyboardWillShow(notification: NSNotification ) {
        if bottomTextField.editing {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    // Reset the view after keyboard is dismissed
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.editing {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func saveMeme(memeImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memeImage)
        //print(meme)
        // Add meme to the memes array in the App Delegate file
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate =  object as! AppDelegate
//        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbars so they don't appear in meme
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // unhide toolbars
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }

    @IBAction func cancelMeme(sender: AnyObject) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        // Disable Action button on top toolbar
        topToolBarActionButton.enabled = false
    }
    
    @IBAction func pickImageForMeme(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        if sender == albumPickButton {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        }
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
        topToolBarActionButton.enabled = true
    }

    @IBAction func shareMeme(sender: AnyObject) {
        let meme = generateMemedImage()
        let nextController = UIActivityViewController.init(activityItems: [meme], applicationActivities: nil)
        presentViewController(nextController, animated: true, completion: nil)
        nextController.completionWithItemsHandler = {
            (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.saveMeme(meme)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

