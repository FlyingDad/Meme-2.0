//
//  MemeCreationViewController.swift
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
    
    var meme: Meme!
    var editingMeme = false

    override func viewWillAppear(animated: Bool) {
        // Enable the camera button if phone has camera and user has authorized its use
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotofocations()
        setupTextFields(topTextField)
        setupTextFields(bottomTextField)
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
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.clearsOnBeginEditing = true
        if editingMeme {
            imagePickerView.image = meme.originalImage
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            topToolBarActionButton.enabled = true
            textField.clearsOnBeginEditing = false
        }
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
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
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
        let alert = UIAlertController(title: "Warning!", message: "Discard changes?", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Discard", style: .Destructive, handler: {
            action in self.dismissViewControllerAnimated(true, completion: nil)})
        alert.addAction(dismissAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion:nil)
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
                
                // Uncomment this to create 7 memes for quick testing
                /*
                for _ in 1...7 {
                    self.saveMeme(meme)
                }
                */
                self.saveMeme(meme)
                // If editing a Meme, alert that new meme is saved and pop to detail view, else dismiss current view without alert
                if self.editingMeme {
                    let alert = UIAlertController(title: "New Meme Saved", message: "", preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: {
                        action in self.dismissViewControllerAnimated(true, completion: nil)})
                    alert.addAction(dismissAction)
                    self.presentViewController(alert, animated: true, completion:nil)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            }
        }
    }
}

