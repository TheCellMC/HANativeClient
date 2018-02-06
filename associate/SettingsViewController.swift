//
//  SettingsViewController.swift
//  associate
//
//  Created by Roey Benamotz on 1/29/18.
//  Copyright © 2018 Roey Benamotz. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var passswordTextField: UITextField!
    @IBOutlet weak var btnSaveConnectionDetails: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let u = UserConfig.shared
        urlTextField.text = u.url
        passswordTextField.text = u.haAccessPassword

        let ha = HomeAssistantDao.shared
        ha.events.listenTo(eventName: HomeAssistantDao.conectionDetailsUpdatedSuccess, action: self.conectionDetailsUpdatedSuccess)
        ha.events.listenTo(eventName: HomeAssistantDao.conectionDetailsUpdatedFail, action: self.conectionDetailsUpdatedFail)
        doneButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        urlTextField.resignFirstResponder()
        passswordTextField.resignFirstResponder()
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        let u = UserConfig.shared
        u.url = urlTextField.text!
        u.haAccessPassword = passswordTextField.text
        do {
            try u.saveToDefaults()
        } catch {
            self.errorMessageLabel.text = error.localizedDescription
            return
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveConnectionDetails(_ sender: UIButton) {
        errorMessageLabel.text = "Checking..."
        let url = urlTextField.text
        let passw = passswordTextField.text
        HomeAssistantDao.shared.updateConnectionDetails(newBaseUrl: url! , password: passw)
        
    }
    
    private func conectionDetailsUpdatedSuccess() {
        DispatchQueue.main.async {
            self.errorMessageLabel.text = "Configuration verified and saved"
            self.doneButton.isEnabled = true
        }
    }
    private func conectionDetailsUpdatedFail(errorMessage: Any?) {
        DispatchQueue.main.async {
            self.errorMessageLabel.text = String.init(format: "Error: %@", errorMessage as! String)
        }
    }
}

