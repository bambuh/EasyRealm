//
//  ER_Save.swift
//  Pods
//
//  Created by Allan Vialatte on 23/11/16.
//
//

import UIKit
import RealmSwift

extension EasyRealm where T:Object {
  
  public func save(update:Bool = false) throws {
    let _ = try self.saved(update: update)
  }
  
  public func saved(update:Bool = false) throws -> T {
    return (self.isManaged) ? try managed_save(update: update) : try unmanaged_save(update: update)
  }
  
  public func update() throws {
    let _ = (self.isManaged) ? try managed_save(update: true) : try unmanaged_save(update: true)
  }
  
}

fileprivate extension EasyRealm where T: Object {
  
  fileprivate func managed_save(update:Bool) throws -> T {
    let ref = ThreadSafeReference(to: self.base)
    guard let rq = EasyRealmQueue() else {
      throw EasyRealmError.RealmQueueCantBeCreate
    }
    return try rq.queue.sync {
      guard let object = rq.realm.resolve(ref) else { throw EasyRealmError.ObjectCantBeResolved }
      if !rq.realm.isInWriteTransaction {
        rq.realm.beginWrite()
      }
      let ret = rq.realm.create(T.self, value: object, update: update)
      if !rq.realm.isInWriteTransaction {
        try rq.realm.commitWrite()
      }
      return ret
    }
  }
  
  fileprivate func unmanaged_save(update:Bool) throws -> T {
    let realm = try Realm()
    if !realm.isInWriteTransaction {
      realm.beginWrite()
    }
    let ret = realm.create(T.self, value: self.base, update: update)
    if !realm.isInWriteTransaction {
      try realm.commitWrite()
    }
    return ret
  }
  
}
