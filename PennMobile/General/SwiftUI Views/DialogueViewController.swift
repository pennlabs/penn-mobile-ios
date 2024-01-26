//
//  DialogueViewController.swift
//  PennMobile
//
//  Created by Christina Qiu on 1/26/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import UIKit

class DialogueViewController: UIViewController {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBAction func Button1(_ sender: UIButton) {
            hide()
    }
    @IBAction func Button2(_ sender: UIButton) {
    }
    
    init(){
        super.init(nibName: "DialogueViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
    }


    func configView(){
        self.view.backgroundColor = .clear
        self.backView.backgroundColor = .black.withAlphaComponent(0.6)
        self.backView.alpha = 0
        self.contentView.alpha = 0
        self.contentView.layer.cornerRadius=10
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated:false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 1, delay: 0.1) {
            self.backView.alpha = 1
            self.contentView.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut) {
            self.backView.alpha = 0
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
}
