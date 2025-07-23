//
//  HydraTests.swift
//  Cachew
//
//  Created by Lucas Barros on 22/07/25.
//

import Testing
@testable import Cachew

struct HydraTests {
    private typealias Sut = Hydra<String, SomeStorable>
    @Test
    func example() async {
        let sut = Sut()
        
        let someStorable1 = SomeStorable(id: 1, name: "1")
        let someStorable2 = SomeStorable(id: 2, name: "2")
        let someStorable3 = SomeStorable(id: 3, name: "3")
        
        await sut.setValue(someStorable1, forKey: someStorable1.name)
        await sut.setValue(someStorable2, forKey: someStorable2.name)
        await sut.setValue(someStorable2, forKey: someStorable2.name)
    }
}
