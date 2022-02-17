import Foundation
import Combine

class SessionViewModel: ObservableObject, Identifiable {
  private let sessionRepository = SessionRepository()
  @Published var session: Session
  private var cancellables: Set<AnyCancellable> = []
  var id = ""

  init(session: Session) {
    self.session = session
    $session
      .compactMap { $0.id }
      .assign(to: \.id, on: self)
      .store(in: &cancellables)
  }

  func update(session: Session) {
    sessionRepository.update(session)
  }

  func remove() {
    sessionRepository.remove(session)
  }
}
