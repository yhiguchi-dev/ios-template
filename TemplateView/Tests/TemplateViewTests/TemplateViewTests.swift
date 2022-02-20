import Nimble
import Quick

@testable import TemplateView

final class TemplateViewTests: QuickSpec {
  override func spec() {
    describe(
      "test"
    ) {
      it("test") {
        expect(TemplateView.init().text).to(equal("Hello, World!"))
      }
    }
  }
}
