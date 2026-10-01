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

    func testSampleParticipantsCoverAllModesAndAreOnlyInstalledOnce() throws {
        let suite = "LuckyXTests." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        try SampleParticipants.installIfNeeded(in: realm, defaults: defaults)
        let people = realm.objects(Person.self)
        XCTAssertEqual(people.count, 180)
        XCTAssertEqual(Set(people.map(\.number)).count, 180)
        for color in ["红", "绿", "黄", "蓝", "紫", "粉"] {
            XCTAssertEqual(people.filter("color = %@ AND isAvailable = true", color).count, 30)
        }
        XCTAssertEqual(people.filter("wish != '未填写心愿'").count, 150)
        XCTAssertEqual(defaults.string(forKey: "UserDefaultEditPerson")?.split(separator: "\n").count, 180)
        try SampleParticipants.installIfNeeded(in: realm, defaults: defaults)
        XCTAssertEqual(people.count, 180)
        try realm.write { realm.delete(people) }
        try SampleParticipants.installIfNeeded(in: realm, defaults: defaults)
        XCTAssertTrue(people.isEmpty)
    }

    func testSampleParticipantsPreserveExistingPeopleAndEditorContents() throws {
        try addPeople()
        let suite = "LuckyXTests." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("已有名单", forKey: "UserDefaultEditPerson")
        try SampleParticipants.installIfNeeded(in: realm, defaults: defaults)
        XCTAssertEqual(realm.objects(Person.self).count, 3)
        XCTAssertEqual(defaults.string(forKey: "UserDefaultEditPerson"), "已有名单")
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
