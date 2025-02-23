import JavaScriptKit


func main() {
    guard
    case .object(let div) = JSObject.global.document.createElement("div")
    else
    {
        print("Could not create elements")
        fatalError("Could not create elements")
    }

    div.innerHTML = .string("Hello there!")

    _ = JSObject.global.document.body.appendChild(div)
}
main()