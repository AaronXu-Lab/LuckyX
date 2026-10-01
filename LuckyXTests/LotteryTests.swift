import XCTest
import RealmSwift
@testable import LuckyX

@MainActor
final class LotteryTests: XCTestCase {
    private var previousConfiguration: Realm.Configuration!
    private var realm: Realm!

    override func setUp() async throws {
        previousConfiguration = Realm.Configuration.defaultConfiguration
        Realm.Configuration.defaultConfiguration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        realm = try await Realm()
    }

    override func tearDown() async throws {
        realm = nil
        Realm.Configuration.defaultConfiguration = previousConfiguration
    }

    private func addPeople() throws {
        try realm.write {
            for number in 1...3 {
                let person = Person()
                person.number = number
                person.name = "测试人员\(number)"
                person.color = number == 3 ? "蓝" : "红"
                person.isAvailable = number != 2
                realm.add(person)
            }
        }
    }

    func testInsufficientPeopleReturnsOnlyRealAvailablePeopleWithoutChangingDatabase() throws {
        try addPeople()
        let controller = ViewController()
        let people = controller.newGetSomeLuckyBitchs(number: 88)
        XCTAssertEqual(Set(people.map(\.number)), [1, 3])
        XCTAssertEqual(people.count, 2)
        XCTAssertEqual(realm.objects(Person.self).filter("isAvailable = true").count, 2)
    }

    func testColorFilterExcludesWinnersAndDoesNotCreatePlaceholderPeople() throws {
        try addPeople()
        let controller = ViewController()
        XCTAssertEqual(controller.newGetSomeLuckyBitchsByColor(number: 3, color: "红").map(\.number), [1])
        XCTAssertTrue(controller.newGetSomeLuckyBitchsByColor(number: 3, color: "紫").isEmpty)
        XCTAssertEqual(controller.newGetSomeLuckyBitchsByColor(number: 3, color: "全").count, 2)
    }

    func testRepeatedRevealRecordsOnePrizeAndIgnoresPlaceholderPeople() throws {
        try addPeople()
        let controller = ViewController()
        let person = realm.object(ofType: Person.self, forPrimaryKey: 1)!
        XCTAssertTrue(try controller.recordWinner(person, prizeName: "测试奖品"))
        XCTAssertFalse(try controller.recordWinner(person, prizeName: "测试奖品"))
        XCTAssertFalse(try controller.recordWinner(Person(), prizeName: "测试奖品"))
        XCTAssertEqual(realm.objects(Prize.self).count, 1)
        XCTAssertFalse(person.isAvailable)
    }

    func testEmptyListReturnsNoPeople() {
        XCTAssertTrue(ViewController().newGetSomeLuckyBitchs(number: 88).isEmpty)
    }

    func testSunshineDrawWithFewerThanElevenPeopleDoesNotOverrunOrDuplicateAwards() throws {
        try addPeople()
        let controller = ViewController()
        controller.current🎁 = "测试奖品"
        controller.personForNow = controller.newGetSomeLuckyBitchs(number: 88)
        let button = UIButton()
        controller.sunshineBtnAction(button)
        XCTAssertTrue(controller.personForNow.isEmpty)
        XCTAssertEqual(realm.objects(Prize.self).count, 2)
        XCTAssertEqual(realm.objects(Person.self).filter("isAvailable = true").count, 0)
        controller.sunshineBtnAction(button)
        XCTAssertEqual(realm.objects(Prize.self).count, 2)
        XCTAssertEqual(button.title(for: .normal), "抽完了")
    }
}
