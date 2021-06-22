//
//  SceneDelegate.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var cancellables =  Set<AnyCancellable>()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        
        showInitializeAppView(in: window) {
            let contentView = DashboardView(
                viewModel: AppContext.resolver.resolve(DashboardViewModel.self)!
            ).environmentObject(AppContext.resolver.resolve(NavigationHelper.self)!)

            window.rootViewController = UIHostingController(rootView: contentView)
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AppContext.didEnterForeground.send()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    
    func showInitializeAppView(
        in window: UIWindow,
        _ initializeDidFinish: @escaping () -> Void
    ) {
        let viewModel = AppContext.resolver.resolve(InitializeAppViewModel.self)!
        let contentView = InitializeAppView(viewModel: viewModel)
        
        window.rootViewController = HostingController(rootView: contentView)
        
        viewModel.initializeDidFinish.sink {
            initializeDidFinish()
        }.store(in: &cancellables)
    }
}

