//
//  PostViewController.swift
//  Wandr
//
//  Created by Ana Ma on 2/28/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import TwicketSegmentedControl

class PostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellow

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func setupViewHierarchy() {
        self.view.addSubview(segmentedControl)
        
        //Drag Up Container View
        //        self.view.addSubview(self.dragUpOrDownContainerView)
        //        self.dragUpOrDownContainerView.addSubview(segmentedControlContainerView)
        //        self.segmentedControlContainerView.addSubview(segmentedControl)
        //        self.dragUpOrDownContainerView.addSubview(postContainerView)
        //        self.dragUpOrDownContainerView.addSubview(cheveronButton)
        
    }
    
    // MARK: - Layout
    private func configureConstraints() {
        
        //        segmentedControl.snp.makeConstraints { (control) in
        //            control.top.equalTo(self.topLayoutGuide.snp.bottom).offset(8)
        //        }
        //
        //        //Drag Up Container View
        //        dragUpOrDownContainerView.snp.makeConstraints { (view) in
        //            view.leading.equalToSuperview()
        //            view.trailing.equalToSuperview()
        //            view.height.equalToSuperview().multipliedBy(0.5)
        //            view.width.equalToSuperview()
        //        }
        //
        //        cheveronButton.snp.makeConstraints { (button) in
        //            button.top.equalToSuperview()
        //            button.trailing.equalToSuperview().inset(16)
        //        }
        //
        //        segmentedControlContainerView.snp.makeConstraints { (view) in
        //            view.top.equalTo(self.cheveronButton.snp.centerY)
        //            view.leading.trailing.equalToSuperview()
        //            view.height.equalToSuperview().multipliedBy(0.175)
        //            view.bottom.equalTo(self.bottomLayoutGuide.snp.top)
        //        }
        //
        //        segmentedControl.snp.makeConstraints { (control) in
        //            control.top.leading.bottom.trailing.equalToSuperview()
        //        }
        //        
        //        postContainerView.snp.makeConstraints { (view) in
        //            view.top.equalTo(segmentedControlContainerView.snp.bottom)
        //            view.leading.trailing.bottom.equalToSuperview()
        //        }
    }

    
    lazy var dragUpOrDownContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var cheveronButton: UIButton = {
        let button = UIButton()
        button.setTitle("Up", for: .normal)
        button.tintColor = UIColor.yellow
        button.backgroundColor = UIColor.orange
        //        button.addTarget(self, action: #selector(animatePostView), for: .touchDragInside)
        return button
    }()
    
    lazy var segmentedControlContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var segmentedControl: TwicketSegmentedControl = {
        let control = TwicketSegmentedControl()
        return control
    }()
    
    lazy var postContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        return view
    }()
    
}
