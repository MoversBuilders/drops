module drops::helpers {
    use std::string::String;

    // Base URL for all collection-related links
    const BASE_URL: vector<u8> = b"https://drops.movers.builders/";

        /// Helper function to append the base URL to a suffix
    public(package) fun with_base_url(suffix: String): String {
        let mut base = std::string::utf8(BASE_URL);
        std::string::append(&mut base, suffix);
        base
    }

    public(package) fun get_base_url(): String {
        std::string::utf8(BASE_URL)
    }
}