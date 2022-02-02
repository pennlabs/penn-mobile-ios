//
//  ViewController.swift
//  audible
//
//  Created by Josh Doman on 11/23/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

protocol OnboardingDelegate: AnyObject {
    func handleFinishedOnboarding()
}

class OnboardingController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, Trackable {

    weak var delegate: OnboardingDelegate?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //makes cells swipe horizontally
        layout.minimumLineSpacing = 0 //decreases gap between cells
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true //makes the cells snap (paging behavior)
        return cv
    }()

    let cellId = "cellId"
    let selectionCellId = "selectionCell"

    let pages: [OnboardingPage] = {
        var firstPage = OnboardingPage(title: "Laundry is back!", message: "And it's better than ever. Now you can see what machines are open. Anytime, anywhere.", imageName: "Onboard 1", showConfetti: true, isFullScreen: true)

        let secondPage = OnboardingPage(title: "Take the pain out of doing laundry", message: "Check real time usage data without having to leave your room. Swipe to see all machines.", imageName: "Onboard 2", showConfetti: false, isFullScreen: false)

        let thirdPage = OnboardingPage(title: "Choose up to three rooms", message: "We'll remember them! You can always edit your selection later.", imageName: "Onboard 3", showConfetti: false, isFullScreen: true)

       return [firstPage, secondPage, thirdPage]
    }() //creates empty array (don't have to use optionals)

    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = UIColor.grey3
        pc.currentPageIndicatorTintColor = UIColor.navigation
        pc.numberOfPages = self.pages.count + 1
        return pc
    }()

    lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.navigation, for: .normal)
        button.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        return button
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.navigation, for: .normal)
        button.addTarget(self, action: #selector(handleNextPage), for: .touchUpInside)
        return button
    }()

    @objc func handleNextPage() {
        if pageControl.currentPage == pages.count {
            return
        }

        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1

        moveOffscreen(pageNumber: pageControl.currentPage)
    }

    @objc func handleSkip() {
        terminateOnboarding()
    }

    func terminateOnboarding() {
        delegate?.handleFinishedOnboarding()
        dismiss(animated: true, completion: nil)
    }

    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)

        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

        pageControlBottomAnchor = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)[1] //full width, dots center to middle //[1] -> accesses second anchor (bottom anchor)

        skipButtonTopAnchor = skipButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first

        nextButtonTopAnchor = nextButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50).first

        registerCells()

        trackScreen("Onboarding")
    }

    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(SelectionCell.self, forCellWithReuseIdentifier: selectionCellId)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true) //whenever you scroll collection view, keyboard goes away
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width) //tells you x-value of collection view
        pageControl.currentPage = pageNumber //change the dots

        //print(pageNumber) //use x-value to determine which page you are on
        moveOffscreen(pageNumber: pageNumber)
    }

    fileprivate func moveOffscreen(pageNumber: Int) {
        //we are on the last page
        if pageNumber == pages.count {
            pageControlBottomAnchor?.constant = 40 //off the screen
            nextButtonTopAnchor?.constant = -40
            skipButtonTopAnchor?.constant = -40
        } else {
            pageControlBottomAnchor?.constant = 0
            nextButtonTopAnchor?.constant = 16
            skipButtonTopAnchor?.constant = 16
        }

        //accelerating animation (looks native)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded() //need to call if want to animate constraint change

        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == pages.count {
            let selectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: selectionCellId, for: indexPath) as! SelectionCell
            selectionCell.delegate = self
            return selectionCell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell

        let page = pages[indexPath.row]
        cell.page = page

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height) //makes cell size of frame
    }
}

extension OnboardingController: SelectionCellDelegate {
    func saveSelection(for rooms: [LaundryRoom]) {
        LaundryRoom.setPreferences(for: rooms)
        terminateOnboarding()
        UserDBManager.shared.saveLaundryPreferences(for: rooms)
    }

    func handleCancel() {
        terminateOnboarding()
    }
}
