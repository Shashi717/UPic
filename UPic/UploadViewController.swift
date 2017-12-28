//
//  UploadViewController.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

enum Catagory: String {
    case animals = "WOOFS & MEOWS"
    case nature = "NATURE"
    case architecture = "ARCHITECTURE"
}

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CellTitled {
    
    // MARK: - Properties
    let titleForCell: String = "UPLOAD"
    var dynamicAnimator: UIDynamicAnimator?
    
    var imagesCollectionView: UICollectionView!
    var topImagesCollectionView: UICollectionView!
    var catagories = ["WOOFS & MEOWS","NATURE", "ARCHITECTURE" ]
    var selectedSegment: Catagory = .animals
    
    var assetsArr: [PHAsset] = []
    var selectedIndex = 0
    var selectedImage: UIImage?
    
    let reuseIdentifier = "imagesCellIdentifier"
    let bottomCollectionViewItemSize = CGSize(width: 125, height: 175)
    let bottomCollectionViewNibName = "ImagesCollectionViewCell"
    let topCollectionViewIdentifier = "topImagesCellIdentifier"
    let topCollectionViewNibName = "TopCollectionViewCell"
    let topCollectionViewItemSize = CGSize(width: 300, height: 300)
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewHierarchy()
        configureConstraints()
        
        getMoments()
        progressContainerView.isHidden = true
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.titleTextField.text = ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleTextField.styled(placeholder: "title")
        
    }
    
    func setupViewHierarchy() {
        self.navigationItem.title = titleForCell
        navigationController?.navigationBar.backgroundColor = ColorPalette.darkPrimaryColor
        navigationController?.navigationBar.barTintColor = ColorPalette.darkPrimaryColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "up_arrow"), style: .plain, target: self, action: #selector(didTapUpload))
        navigationItem.rightBarButtonItem?.tintColor = ColorPalette.accentColor
        
        createBottomCollectionView()
        createTopCollectionView()
        self.view.addSubview(topContainerView)
        self.view.addSubview(imagesCollectionView)
        self.view.addSubview(topImagesCollectionView)
        self.view.addSubview(progressContainerView)
        
        self.topContainerView.addSubview(titleTextField)
        self.topContainerView.addSubview(scrollView)
        
        self.progressContainerView.addSubview(progressBar)
        self.progressContainerView.addSubview(progressLabel)
        
        categorySegmentedControl.addTarget(self, action: #selector(didSelectSegment(sender:)), for: .valueChanged)
        categorySegmentedControl.setDividerImage(imageWithColor(color: ColorPalette.primaryColor), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.scrollView.addSubview(categorySegmentedControl)
    }
    
    func configureConstraints() {
        
        topContainerView.snp.makeConstraints { (view) in
            view.leading.trailing.equalToSuperview()
            let targetHeight = self.navigationController?.navigationBar.frame.size.height
            view.top.equalToSuperview().offset(targetHeight!)
            view.height.equalTo(100.0)
        }
        
        imagesCollectionView.snp.makeConstraints { (view) in
            view.bottom.leading.trailing.equalToSuperview()
            view.height.equalTo(175.0)
        }
        
        topImagesCollectionView.snp.makeConstraints { (view) in
            view.top.equalTo(topContainerView.snp.bottom)
            view.leading.trailing.equalToSuperview()
            view.bottom.equalTo(imagesCollectionView.snp.top)
        }
        
        titleTextField.snp.makeConstraints { (view) in
            view.top.equalTo(topContainerView.snp.top).offset(40.0)
            view.leading.equalTo(topContainerView.snp.leading).offset(15.0)
            view.trailing.equalTo(topContainerView.snp.trailing).inset(15.0)
            view.height.equalTo(20.0)
        }
        
        scrollView.snp.makeConstraints { (view) in
            view.bottom.equalTo(topContainerView.snp.bottom).inset(8.0)
            view.trailing.leading.equalTo(topContainerView)
            view.height.equalTo(30.0)
            
        }
        
        categorySegmentedControl.snp.makeConstraints { (view) in
            view.leading.equalTo(scrollView).offset(8.0)
            view.trailing.equalTo(scrollView).inset(8.0)
            view.centerY.equalTo(scrollView)
            view.height.equalTo(20.0)
        }
        
        progressContainerView.snp.makeConstraints { (view) in
            view.trailing.equalTo(self.view.snp.leading).inset(20.0)
            view.centerY.equalTo(topImagesCollectionView).inset(40.0)
            view.height.equalTo(60.0)
            view.width.equalTo(200.0)
        }
        
        progressBar.snp.makeConstraints { (view) in
            view.leading.equalTo(progressContainerView).offset(15.0)
            view.trailing.equalTo(progressContainerView).inset(15.0)
            view.bottom.equalTo(progressContainerView).inset(15.0)
            view.height.equalTo(3.0)
        }
        
        progressLabel.snp.makeConstraints { (view) in
            view.top.equalTo(progressContainerView.snp.top).offset(10.0)
            view.leading.trailing.equalTo(progressContainerView)
            view.height.equalTo(15.0)
        }
        
    }
    
    // MARK: - Instantiate Top & Bottom Collection Views
    func createBottomCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = bottomCollectionViewItemSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        imagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        
        imagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let nib = UINib(nibName: bottomCollectionViewNibName, bundle:nil)
        imagesCollectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        imagesCollectionView.backgroundColor = .white
    }
    
    func createTopCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        topImagesCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        topImagesCollectionView.delegate = self
        topImagesCollectionView.dataSource = self
        
        topImagesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: topCollectionViewIdentifier)
        let nib = UINib(nibName: topCollectionViewNibName, bundle:nil)
        topImagesCollectionView.register(nib, forCellWithReuseIdentifier: topCollectionViewIdentifier)
        
        topImagesCollectionView.backgroundColor = .white
    }
    
    // MARK: - Actions
    internal func didSelectSegment(sender: UISegmentedControl) {
        selectedSegment = Catagory(rawValue: catagories[sender.selectedSegmentIndex])!
        
        print(selectedSegment)
        
    }
    
    internal func didTapUpload(sender: UIButton) {
        
        print("From upload, users UID \(FIRAuth.auth()?.currentUser?.uid)")
        print("From upload, users display name \(FIRAuth.auth()?.currentUser?.displayName)")
        let imageName = NSUUID().uuidString
        let user = FIRAuth.auth()?.currentUser
        
        guard user?.isAnonymous == false else {
            let alert = UIAlertController(title: "Error", message: "Please Register", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if user?.uid != nil {
            
            let storageRef = FIRStorage.storage().reference()
            let databaseRef = FIRDatabase.database().reference()
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let dict = [
                "upvotes": "0",
                "downvotes": "0"
            ]
            
            metaData.setValue(dict, forKey: "customMetadata")
            let imageRef = storageRef.child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.selectedImage!) {
                
                // Animating progress bar
                progressContainerView.isHidden = false
                self.progressContainerView.alpha = 1.0
                
                _ = self.dynamicAnimator?.behaviors.map {
                    if $0 is UISnapBehavior {
                        self.dynamicAnimator?.removeBehavior($0)
                    }
                }
                let snap = UISnapBehavior(item: progressContainerView, snapTo: CGPoint(x: self.view.frame.midX, y: self.view.frame.midY))
                dynamicAnimator?.addBehavior(snap)
                
                // Meta Data Task
                let task = imageRef.put(uploadData, metadata: metaData, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                    
                    let urlString = String(describing: metadata!.downloadURL()!)
                    let dict = ["url": urlString, "upvotes": [""], "downvotes": [""]] as [String : Any]
                    
                    databaseRef.child("users").child((user?.uid)!).child("uploads").updateChildValues([self.titleTextField.text! : String(describing: metadata!.downloadURL()!)])
                    
                    databaseRef.child("categories").child(self.categorySegmentedControl.titleForSegment(at: self.categorySegmentedControl.selectedSegmentIndex)!).child(self.titleTextField.text!).updateChildValues(dict)
                    
                    print((String(describing: metadata!.downloadURL()!)))
                    
                })
                
                
                let _ = task.observe(.progress) { (snapshot) in
                    
                    let progress = Float((snapshot.progress?.fractionCompleted)!)
                    if progress == 1.0 {
                        self.progressBar.isHidden = true
                        self.progressLabel.text = "SUCCESS!"
                        
                        UIView.animate(withDuration: 1.0, animations: {
                            self.progressContainerView.alpha = 0.0
                        }, completion: { finished in
                            
                            _ = self.dynamicAnimator?.behaviors.map {
                                if $0 is UISnapBehavior {
                                    self.dynamicAnimator?.removeBehavior($0)
                                }
                            }
                            
                            let snap = UISnapBehavior(item: self.progressContainerView, snapTo: CGPoint(x: self.view.frame.minX - 100.0, y: self.view.frame.midY - 100.0))
                            snap.damping = 0.9
                            self.dynamicAnimator?.addBehavior(snap)
                            self.progressLabel.text = "UPLOADING..."
                            self.progressBar.isHidden = false
                        })
                    }
                    
                    self.progressBar.progress = progress
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Log in to upload please", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - PHAsset & PHCollection
    func getAssets(collection: PHAssetCollection) -> [PHAsset] {
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        var returnAssets = [PHAsset]()
        for j in 0..<assets.count {
            if assets[j].mediaType == .image {
                returnAssets.append(assets[j])
                
            }
        }
        return returnAssets
    }
    
    func getMoments() {
        
        let options = PHFetchOptions()
        let sort = NSSortDescriptor(key: "startDate", ascending: false)
        options.sortDescriptors = [sort]
        //        let cutoffDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 30 * 12 * 2 * -1)
        //        let predicate = NSPredicate(format: "startDate > %@", cutoffDate)
        //        options.predicate = predicate
        
        let momentsLists = PHCollectionList.fetchMomentLists(with: .momentListCluster, options: nil)
        for i in (0..<momentsLists.count).reversed() {
            let moments = momentsLists[i]
            let collectionList = PHCollectionList.fetchCollections(in: moments, options:options)
            for j in 0..<collectionList.count {
                if let collection = collectionList[j] as? PHAssetCollection {
                    
                    assetsArr += getAssets(collection: collection)
                    
                    if assetsArr.count > 200 {
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard assetsArr.count > 0 else {
            return UICollectionViewCell()
        }
        
        let manager = PHImageManager.default()
        let asset = assetsArr[indexPath.row]
        
        if collectionView == self.imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImagesCollectionViewCell
            cell.collectionImageView.image = nil
            cell.collectionImageView.contentMode = .scaleAspectFill
            manager.requestImage(for: asset,targetSize: bottomCollectionViewItemSize,
                                 contentMode: .aspectFill,options: nil) { (result, _) in
                                    cell.collectionImageView.image = result
                                    self.selectedImage = result
                                    cell.setNeedsLayout()
                                    
            }
            return cell
        }
            
        else if collectionView == self.topImagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topCollectionViewIdentifier, for: indexPath) as! TopCollectionViewCell
            
            cell.frame.size = topImagesCollectionView.frame.size
            cell.imageView.image = nil
            cell.imageView.contentMode = .scaleAspectFill
            
            manager.requestImage(for: asset,targetSize: topCollectionViewItemSize,
                                 contentMode: .aspectFill,options: nil) { (result, _) in
                                    cell.imageView.image = result
                                    self.selectedImage = result
                                    cell.setNeedsLayout()
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        progressContainerView.isHidden = true
        
        if scrollView == imagesCollectionView {
            
            for _ in imagesCollectionView.visibleCells {
                let indexPath = self.imagesCollectionView.indexPathsForVisibleItems
                topImagesCollectionView.scrollToItem(at: indexPath[1], at: .centeredHorizontally, animated: false)
            }
        }
            
        else if scrollView == topImagesCollectionView {
            for _ in topImagesCollectionView.visibleCells {
                let indexPath = self.topImagesCollectionView.indexPathsForVisibleItems
                imagesCollectionView.scrollToItem(at: indexPath[0], at: .left, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == topImagesCollectionView {
            return collectionView.frame.size
        }
        else {
            let height = collectionView.frame.size.height
            let width = height.multiplied(by: 0.75)
            return CGSize(width: width, height: height)
        }
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 15.0, height: 20.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        topImagesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        progressContainerView.isHidden = true
        
    }
    
    // MARK: - Lazy Instantiations
    internal lazy var topContainerView: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var scrollView: UIScrollView! = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    internal lazy var progressContainerView: UIView! = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primaryColor
        return view
    }()
    
    internal lazy var progressBar: UIProgressView! = {
        let progressView = UIProgressView()
        progressView.tintColor = ColorPalette.accentColor
        return progressView
    }()
    
    internal lazy var progressLabel: UILabel! = {
        let label = UILabel()
        label.textColor = ColorPalette.accentColor
        label.text = "UPLOADING..."
        label.textAlignment = .center
        return label
    }()
    
    internal lazy var titleTextField: UITextField! = {
        let textField = UITextField()
        return textField
    }()
    
    internal lazy var categorySegmentedControl: UISegmentedControl! = {
        var segmentedControl = UISegmentedControl()
        segmentedControl = UISegmentedControl(items: self.catagories)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = ColorPalette.accentColor
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: ColorPalette.textIconColor], for: UIControlState.normal)
        
        for layer in segmentedControl.layer.sublayers! {
            layer.borderWidth = 1.0
            layer.borderColor = ColorPalette.textIconColor.cgColor
        }
        
        return segmentedControl
    }()
    
}
