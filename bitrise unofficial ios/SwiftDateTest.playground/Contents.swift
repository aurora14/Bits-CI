import UIKit
import SwiftDate

// Adding Cocoapods to the playground:
// 1. File -> New -> Playground
// 2. Name it whatever you want.
// 3. Make sure that you check 'add to projects' and select the project you're working with.
// 4. Before writing the 'import' statement for any pods, make sure you build the project
//    using Command + B
// 5. Also make sure that you've selected 'Simulator' as the build device.
// 6. Once the project is built, you should be able to import pods and use them as in normal
//    code files


var str = "Hello, playground"

let currentDate = Date()

print(currentDate.date)

let formatter = DateFormatter()
formatter.dateFormat = "yyyy/MM/dd HH:mm"
let someDateTime = formatter.date(from: "2018/12/20 14:22")

let oldDate = Date(year: 2018,
                   month: 12,
                   day: 20,
                   hour: 14,
                   minute: 0,
                   second: 0,
                   nanosecond: 0,
                   region: Region.current)


print(currentDate - oldDate)

let difference = currentDate - oldDate //returns a set of DateComponents
let hours = difference.hour
var minutes = difference.minute

if hours != nil && minutes != nil && hours! != 0 {
  minutes! += (hours! * 60)
}


if someDateTime != nil {
  print(currentDate - someDateTime!)
}

