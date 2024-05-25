# LinkChecker

LinkChecker is a powerful and user-friendly shell script designed to search for and validate URLs in files within a specified directory. The script recursively scans all files in the given directory, extracts URLs, and checks their accessibility. It identifies and reports any broken links, unreachable servers, or SSL certificate issues, ensuring the integrity of your links.

Key Features:
- Recursively scans directories for URLs in files.
- Validates the accessibility and status of each URL.
- Identifies broken links and SSL certificate errors.
- Provides clear and detailed output for each link checked.

Usage:
- Simply specify the directory you want to scan, and LinkChecker will do the rest.
- Ideal for web developers, content managers, and anyone who needs to ensure the reliability of their links.

Required:
- The "curl" package is required to run the process. When you run the script, it will be checked and asked for permission to install. You can install it first.

```
sudo apt-get install curl
```

Get started by cloning the repository and running the script in your terminal.

```bash
git clone https://github.com/yourusername/LinkChecker.git
cd LinkChecker
./link_checker.sh /path/to/your/directory
```

The entire project is licensed under the [MIT license](https://github.com/KaganCanSit/LinkChecker/blob/main/LICENSE). But it has special conditions. The developer is not responsible for any damage that may occur due to malware, damage, misuse or other reasons.
