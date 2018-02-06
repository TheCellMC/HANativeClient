//
//  ViewController.swift
//  associate
//
//  Created by Roey Benamotz on 1/16/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit


class IdentifiedButton: UIButton {
    var buttonIdentifier = ""
}

class ViewController: UIViewController {
    @IBOutlet weak var pageController: UIPageControl!
    var buttonList : ButtonsListController?
    
    @IBAction func editModeToggled(_ sender: UISwitch) {
        buttonList!.setButtonEditMode(editMode: sender.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonList =  self.childViewControllers.first as? ButtonsListController
        self.buttonList?.pageControl = pageController
        _ = HomeAssistantDao.shared
        
    }
    @IBAction func pageNumberChanged(_ sender: UIPageControl) {
        buttonList?.scrollToPage(pageNumber: sender.currentPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let ha = HomeAssistantDao.shared
        if (!ha.isConnectionDetailsValid) {
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "settings_view_controller") as! SettingsViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

