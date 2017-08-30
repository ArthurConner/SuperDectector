//
//  OpeningViewController.swift
//  SuperDetector
//
//  Created by Arthur  on 8/7/17.
//  Copyright © 2017 Arthur . All rights reserved.
//

import UIKit

private let reuseIdentifier = "OpeningCell"

class OpeningViewController: UICollectionViewController {


    var hereos:[CharacterSpec] = []
    var dim:DimensionSetting?
    var pathSelected:IndexPath?
    
    func reload(){
        hereos.removeAll()
        var d = DimensionSetting()
        //d.scaleX = 0.25
        //d.scaleY = 0.25
        d.normalize()
        
        d.yOff = -25
        d.xOff = -35
        d.scaleX *= 2
        d.scaleY *= 2
       // d.xOff = -75
        //d.yTilt = -1
       
      
        for (_,builder) in  CharacterSpec.makeCast() {
          hereos.append(builder(nil,d))
        }
 
        
        self.dim = d
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
     
        reload()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let bb = UIBarButtonItem(title: "Picker", style: .plain, target: self, action: #selector(makePicker))
            self.navigationItem.rightBarButtonItem = bb
        }


        // Do any additional setup after loading the view.
    }

   @objc func makePicker(){
    
    let b = UIStoryboard(name: "Main", bundle: Bundle.main)
    let vc = b.instantiateViewController(withIdentifier: "GamePicker")
    
    if   let n = self.navigationController {
        n.pushViewController(vc, animated: true)
    }
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* FaceCamera
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return hereos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        
        let hero = hereos[indexPath.row]
        let im = hero.image()
        
        if let t = cell.contentView.viewWithTag(10) as? UIImageView {
            t.image = im
        } else {
            let t = UIImageView(image: im)
            t.tag = 10
            cell.contentView.addSubview(t)
        }
        
        //cell.contentView.backgroundColor = .orange
    
        return cell
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

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pathSelected = indexPath
        
        self.performSegue(withIdentifier: "FaceCamera", sender: self)
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if let d = segue.destination as? CameraViewController, let i = self.pathSelected {
            //d.hero = self.hereos[i.row]
            d.heroIndex = i.row
            //print("using \(String(describing: d.hero()))")
        }
    }
    
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

extension OpeningViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 200, height: 200)
    }
}
