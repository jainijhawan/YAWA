//
//  FirebaseManager.swift
//  YAWA
//
//  Created by Jai Nijhawan on 05/09/23.
//  Copyright © 2023 Jai Nijhawan. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

struct FirebaseManager {
    private static var remoteConfig: RemoteConfig = {
        var remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
#if DEBUG
        settings.minimumFetchInterval = 0
#else
        settings.minimumFetchInterval = 3600
#endif
        remoteConfig.configSettings = settings
        return remoteConfig
    }()
    
    static func setupFirebaseDefaultValues() {
        remoteConfig.setDefaults(["OPENWEATHERAPIKEY": "" as NSObject])
        remoteConfig.setDefaults(["AQIAPIKEY" : "" as NSObject])
    }
    
    static func fetchAndActivate(completeion: @escaping () -> Void) {
        var interval = 0
#if DEBUG
        interval = 0
#else
        interval = 3600
#endif
        remoteConfig.fetch(withExpirationDuration: TimeInterval(interval)) { staus, error in
            RemoteConfig.remoteConfig().activate()
            completeion()
        }
    }
    
    static func getVlaueFor(key: String) -> String? {
        return remoteConfig.configValue(forKey: key).stringValue
    }
}
