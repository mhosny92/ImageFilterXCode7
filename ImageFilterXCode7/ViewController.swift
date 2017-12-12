//
//  ViewController.swift
//  ImageFilter
//
//  Created by Mahmoud Hosny on 11/26/17.
//  Copyright © 2017 Mahmoud Hosny. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var filteredImage : UIImage?
    
    var originalImage  = UIImage(named: "nature")
    
    
    @IBOutlet var originalLabelView: UIView!
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            let handler = #selector(self.reactToLongPress(byReactingTo:))
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: handler)
            imageView.addGestureRecognizer(longPressRecognizer)
        }
    }
    @IBOutlet weak var newPhotoButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        originalLabelView.translatesAutoresizingMaskIntoConstraints = false
        originalLabelView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        imageView.image = self.originalImage!
        ImageProcessor.shared.prepareImageForProcessing(self.originalImage!)
        compareButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reactToLongPress(byReactingTo longPressRecognizer: UILongPressGestureRecognizer){
        switch longPressRecognizer.state {
        case .Began:
            imageView.image = self.originalImage
            imageView.setNeedsDisplay()
        case .Ended,.Cancelled:
            if let _ = self.filteredImage{
                imageView.image = self.filteredImage
                imageView.setNeedsDisplay()
            }
        default:
            break
        }
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected){
            hideSecondaryMenu()
            sender.selected = false
        }else {
            showSecondaryMenu()
            sender.selected = true
        }
    }
    @IBAction func onCompare(sender: UIButton) {
        if let _ = filteredImage{
            if sender.selected{
                showFilteredImage()
                sender.selected = false
            }else {
                showOriginalImage()
                sender.selected = true
            }
        }
    }
    
    func showOriginalImage(){
        imageView.image = self.originalImage
        imageView.setNeedsDisplay()
        showOriginalLabelView()
    }
    func showFilteredImage(){
        imageView.image = self.filteredImage
        imageView.setNeedsDisplay()
        hideOriginalLabelView()
        self.compareButton.enabled = true
        
    }
    
    @IBAction func onRedish(sender: UIButton) {
        self.compareButton.selected = false
        filteredImage = ImageProcessor.shared.modifyRedishValue()
        showFilteredImage()
    }
    @IBAction func onGray(sender: UIButton) {
        self.compareButton.selected = false
        filteredImage = ImageProcessor.shared.turnToGrayColor()
        showFilteredImage()
    }
    @IBAction func onGhosty(sender: UIButton) {
        self.compareButton.selected = false
        filteredImage = ImageProcessor.shared.addGhostyToImage()
        showFilteredImage()
    }
    @IBAction func onContrast(sender: UIButton) {
        self.compareButton.selected = false
        filteredImage = ImageProcessor.shared.adjustContrast()
        showFilteredImage()
    }
    @IBAction func onBrightness(sender: UIButton) {
        self.compareButton.selected = false
        filteredImage = ImageProcessor.shared.adjustBrightness()
        showFilteredImage()
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
            originalImage = image
            filteredImage = nil
            compareButton.enabled = false
            ImageProcessor.shared.prepareImageForProcessing(originalImage!)
            showOriginalImage()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {action in self.showCamera()}))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {action in self.showAlbum()}))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: false, completion: nil)
    }
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        
        presentViewController(activityController, animated: false, completion: nil)
    }
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        presentViewController(cameraPicker, animated: false, completion: nil)
    }
    
    func showAlbum(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        presentViewController(cameraPicker, animated: false, completion: nil)
    }
    func showOriginalLabelView(){
        view.addSubview(originalLabelView)
        let bottomConstraint = originalLabelView.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = originalLabelView.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstriant = originalLabelView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstriant = originalLabelView.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstriant, heightConstriant])
        view.layoutIfNeeded()
        originalLabelView.alpha=0
        UIView.animateWithDuration(0.4, animations: { self.originalLabelView.alpha = 1 })
    }
    func hideOriginalLabelView(){
        originalLabelView.removeFromSuperview()
    }
    func showSecondaryMenu(){
        view.addSubview(secondaryMenu)
        let bottomConstriant = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstriant = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraints = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraints = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        NSLayoutConstraint.activateConstraints([bottomConstriant, leftConstriant, rightConstraints, heightConstraints])
        view.layoutIfNeeded()
        
        secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4, animations: { self.secondaryMenu.alpha = 1 })
    }
    func hideSecondaryMenu(){
        
        UIView.animateWithDuration(0.4, animations: {self.secondaryMenu.alpha = 0}, completion: { completed in
            if completed == true {
                self.secondaryMenu.removeFromSuperview()}
        })
    }
}

