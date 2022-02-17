import Foundation
import Combine

class SessionListViewModel: ObservableObject {
  @Published var sessionViewModels: [SessionViewModel] = []
  private var cancellables: Set<AnyCancellable> = []

  @Published var sessionRepository = SessionRepository()

  init() {
      sessionRepository.$sessions.map { sessions in
          sessions.map(SessionViewModel.init)
    }
    .assign(to: \.sessionViewModels, on: self)
    .store(in: &cancellables)
  }

  func add(_ session: Session) {
    sessionRepository.add(session)
  }
}
