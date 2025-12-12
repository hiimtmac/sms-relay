extension String {
    func numbers() throws -> [Self] {
        self
            .ranges(of: /\+[0-9]{11}/)
            .map { self[$0] }
            .map(String.init)
    }
}
