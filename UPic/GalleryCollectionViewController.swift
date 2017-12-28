//
//  GalleryCollectionViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseStorage

class GalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CellTitled {
    
    // MARK: - Properties
    var titleForCell: String = ""
    let reuseIdentifier = "GalleryCell"
    var colView: UICollectionView!
    let ref = FIRDatabase.database().reference()
    var metaRef: FIRStorageReference!
    var imageURLs: [URL] = []
    var imagesToLoad = [UIImage]()
    var refArr: [FIRStorageReference] = []
    var category: GallerySections!
    var downloadURL = ""
    var imageName = ""
    var imageTitleArr: [String] = []
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        loadCollectionImages(category: category)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureConstraints()
        self.colView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup View Hierarchy & Constraints
    internal func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        colView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        colView.delegate = self
        colView.dataSource = self
        colView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "GalleryCell")
        colView.backgroundColor = ColorPalette.primaryColor
        
        
        self.navigationController?.navigationBar.tintColor = ColorPalette.accentColor
        self.title = titleForCell
        
        view.addSubview(colView)
    }
    
    internal func configureConstraints() {
        colView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Firebase Storage - Download Images
    func loadCollectionImages(category: GallerySections) {
        
        let userReference = FIRDatabase.database().reference().child("categories").child(category.rawValue)
        
        userReference.observe(.childAdded, with: { (snapshot) in
            
            self.imageTitleArr.append(snapshot.key)
            if snapshot.childrenCount != 0 {
                let downloadURL = snapshot.childSnapshot(forPath: "url").value as! String
                
                self.imageURLs.append(URL(string: downloadURL)!)
                let storageRef = FIRStorage.storage().reference(forURL: downloadURL)
                self.refArr.append(storageRef)
                //Check Cache for Image
                if let cachedImage = imageCache.object(forKey: downloadURL as AnyObject) as? UIImage {
                    
                    self.imagesToLoad.append(cachedImage)
                    
                    self.imageURLs.append(URL(string: downloadURL)!)
                    
                    DispatchQueue.main.async {
                        self.colView.reloadData()
                    }
                    return
                }
                
                // Download the data, assuming a max size of 1MB (you can change this as necessary)
                storageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    if let data = data {
                        let pic = UIImage(data: data)
                        
                        //If Image isn't in Cache, insert it for future use
                        DispatchQueue.main.async {
                            imageCache.setObject(pic!, forKey: downloadURL as AnyObject)
                            self.imagesToLoad.append(pic!)
                            self.colView.reloadData()
                        }
                    }
                }
            }
            
        })
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesToLoad.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        
        let ref = self.refArr[indexPath.row]
        
        ref.metadata { (metaData, error) in
            
            if let error = error {
                print("Error ----- \(error.localizedDescription)")
            }
                
            else {
                
                let upvotesMetadata = metaData?.customMetadata!["upvotes"]!
                let downvotesMetadata = metaData?.customMetadata!["downvotes"]!
                
                cell.upLabel.text = upvotesMetadata!
                cell.downLabel.text = downvotesMetadata!
            }
        }
        
        
        cell.imageView.image = nil
        
        cell.imageView.image = self.imagesToLoad[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let displayImageVC = DisplayImageViewController()
        let index = indexPath.row
        if FIRAuth.auth()?.currentUser?.isAnonymous == false {
            
            let userProfileImageReference: FIRDatabaseReference? = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
            
            userProfileImageReference?.child("username").observe(.value, with: { (snapshot) in
                
                displayImageVC.currentUserName = snapshot.value as? String
                displayImageVC.currentUserId = (userProfileImageReference?.key)!
            })
            
        }
        
        displayImageVC.image = self.imagesToLoad[index]
        displayImageVC.imageUrl = self.imageURLs[index]
        displayImageVC.ref = self.refArr[index]
        displayImageVC.category = self.category
        displayImageVC.imageTitle = self.imageTitleArr[index]
        
        self.navigationController?.pushViewController(displayImageVC, animated: false)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (self.view.frame.size.height) / 3.0
        let width = (self.view.frame.size.width) / 2.0
        return CGSize(width: width, height: height)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

