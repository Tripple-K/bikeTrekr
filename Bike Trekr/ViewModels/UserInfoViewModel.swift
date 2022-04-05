import Foundation
import Combine

class UserInfoViewModel: ObservableObject, Identifiable {
  private let userRepository = UserRepository()
  @Published var userInfo: UserInfo
  private var cancellables: Set<AnyCancellable> = []
  var id = ""

  init(userInfo: UserInfo) {
    self.userInfo = userInfo
    $userInfo
      .compactMap { $0.id }
      .assign(to: \.id, on: self)
      .store(in: &cancellables)
  }

  func update(userInfo: UserInfo) {
      userRepository.update(userInfo)
  }

  func remove() {
      userRepository.remove(userInfo)
  }
}
