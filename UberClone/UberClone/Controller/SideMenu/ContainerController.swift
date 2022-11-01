//
//  ContainerController.swift
//  UberClone
//
//  Created by RadCns_KIM_TAEWON on 2022/10/20.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    // MARK: - Properties
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80
    
    private var user: User? {
        didSet {
            guard let user = self.user else { return }
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Selectors
    
    @objc func didmissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginController()
        } else {
            configure()
        }
    }
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            presentLoginController()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    // MARK: - Helper Function
    
    func presentLoginController() {
        DispatchQueue.main.async {
            let nav = UINavigationController(rootViewController: LoginController())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func configure() {
        configureHomeController()
        fetchUserData()
    }
    
    func configureHomeController() {
        // 다른뷰 컨트롤러에 자식 컨트롤러를 추가 하는 방법
        addChild(homeController)
        homeController.didMove(toParent: self)
        homeController.delegate = self
        view.addSubview(homeController.view)
    }
    
    func configureMenuController(withUser user: User) {
        // 다른뷰 컨트롤러에 자식 컨트롤러를 추가 하는 방법
        menuController = MenuController(user: user)
        menuController.delegate = self
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        configureBlackView()
    }
    
    func configureBlackView() {
        self.blackView.frame = CGRect(x: xOrigin,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        blackView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didmissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)
            
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}

// MARK: - SettingControllerDelegate

extension ContainerController: SettingControllerDelegate {
    func updateUser(_ controller: SettingController) {
        self.user = controller.user
    }
}

// MARK: - HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

// MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                print("DEBUG: Click is your Trips")
                break
            case .settings:
                guard let user = self.user else { return }
                let controller = SettingController(user: user)
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "로그아웃 하시겠습니까?",
                                              preferredStyle: .actionSheet)
                let ok = UIAlertAction(title: "Log Out", style: .destructive) { _ in
                    self.signOut()
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                 
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true)
                
            }
        }
    }
}
