# LinkChecker

LinkChecker is a powerful and user-friendly shell script designed to search and verify URLs in files in a given directory. The script recursively scans all files in the given directory, extracts URLs and checks their accessibility. It ensures the integrity of your connections by detecting and reporting broken connections, inaccessible servers or SSL certificate issues.

### Attention
- Refund codes and site reactions may vary. Therefore, this tool does not offer you a 100% guarantee. It was written to help you start from somewhere and save you time.
- The process of parsing the links performed in this script is of course simple. It may not find all links correctly. In this case, you can contribute to improve the parse mechanics or add code specific to your situation.
- Do not run it in a project directory you do not know. As a result, you will communicate via curl by sending a network packet to the connections!

### Main Features
- Recursively scans directories for URLs in files.
- Verifies the accessibility and status of each URL.
- Identifies broken connections and SSL certificate errors.

### Use
- Just specify the directory you want to scan and LinkChecker will do the rest.
- Ideal for web developers, content managers, and anyone who needs to ensure the reliability of their links.
- Here you can view your site, project, etc. to browse and check links. It must be present in your local environment. It does not scan to a site on the Internet!

### Required
- The "curl" package is required to run the process. When you run the script, it will be checked and permission will be asked for installation. If you do not want to install it this way, you can install it yourself and use the script.

``` bash
sudo apt-get install curl
```

### Starting
Start by cloning the repository and running the script in your terminal.

``` bash
git clone https://github.com/KaganCanSit/LinkChecker.git
cd LinkChecker
./link_checker.sh /path/pathOfDirectory/directory
```

### Contributions

We are always open to participation and contributions. You can make suggestions and send pull requests to further improve this script. 

I would be very happy if friends, especially those who are interested in regex, say that it is the job of parsers, and have good network knowledge, can help with the project.

Before sending your content, please review it using "shellcheck". Please do not leave any errors or warning messages.

``` bash
sudo apt-get install shellcheck
shellcheck linkChecker.sh
``` 

### Licence:
The entire project is licensed under the [MIT license](https://github.com/KaganCanSit/LinkChecker/blob/main/LICENSE).
