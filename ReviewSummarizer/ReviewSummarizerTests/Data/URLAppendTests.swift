import Testing
import Foundation
@testable import ReviewSummarizer

@Suite("URL+Append")
struct URLAppendTests {

    @Test("base con trailing slash + path con leading slash")
    func bothSlashes() {
        let base = URL(string: "http://h/")!
        let result = base.appendingPathComponentSafe("/foo")
        #expect(result.absoluteString == "http://h/foo")
    }

    @Test("base sin trailing slash + path sin leading slash")
    func noSlashes() {
        let base = URL(string: "http://h")!
        let result = base.appendingPathComponentSafe("foo")
        #expect(result.absoluteString == "http://h/foo")
    }

    @Test("base con trailing slash + path sin leading slash")
    func baseSlashOnly() {
        let base = URL(string: "http://h/")!
        let result = base.appendingPathComponentSafe("foo")
        #expect(result.absoluteString == "http://h/foo")
    }

    @Test("base sin trailing slash + path con leading slash")
    func pathSlashOnly() {
        let base = URL(string: "http://h")!
        let result = base.appendingPathComponentSafe("/foo")
        #expect(result.absoluteString == "http://h/foo")
    }
}
