class Chat {
//    var iconImage: Image
    var title: String?
    var time: String?
    var preview: String?
    var chatId: String?
    
    init(title: String, time: String, preview: String, chatId: String) {
        self.title = title
        self.time = time
        self.preview = preview
        self.chatId = chatId
    }
}