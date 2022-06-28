
import SwiftUI
import UserNotifications

struct RemidersView: View {
    
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @AppStorage("weekdays") var choosenWeekday = Set<String>()
    
    @State var notifyTime = Date()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    ForEach(weekdays, id:
                                \.self) { weekday in
                        Text(weekday)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(choosenWeekday.contains(weekday) ? .red : .gray)
                            )
                            .onTapGesture {
                                if choosenWeekday.contains(weekday) {
                                    choosenWeekday.remove(weekday)
                                    removeNotification(weekday)
                                } else {
                                    addNotification(weekday)
                                    choosenWeekday.insert(weekday)
                                }
                            }
                        
                    }
                }
                .padding()
                DatePicker("", selection: $notifyTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func addNotification(_ weekday: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Time to get up"
        notificationContent.body = "It's time to run"
        notificationContent.badge = NSNumber(value: 1)
        notificationContent.sound = .default
        
        var datComp = DateComponents()
        datComp.hour = Calendar.current.component(.hour, from: notifyTime)
        datComp.minute = Calendar.current.component(.minute, from: notifyTime)
        datComp.weekday = (weekdays.firstIndex(of: weekday) ?? 0) + 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
        let request = UNNotificationRequest(identifier: "\(weekday)", content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
    }
    
    func removeNotification(_ weekday: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weekday])
    }
}

struct RemidersView_Previews: PreviewProvider {
    static var previews: some View {
        RemidersView()
    }
}
