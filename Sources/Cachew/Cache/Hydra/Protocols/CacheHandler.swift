//
//  CacheHandler.swift
//  Cachew
//
//  Created by Lucas Migge on 27/07/25.
//


protocol CacheHandler: AnyObject {
    func cacheWillRemoveObject(_ cacheName: String, _ object: StorableContainer)
}
