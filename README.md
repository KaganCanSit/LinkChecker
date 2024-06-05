# Link Checker

Link Checker is a powerful and user-friendly shell script designed to search and verify URLs in files within a given directory. The script recursively scans all files in the provided directory, extracts URLs, and checks their accessibility. It ensures the integrity of your connections by detecting and reporting broken links, inaccessible servers, or SSL certificate issues.

## Attention
- Refund codes and site reactions may vary. Therefore, this tool does not offer you a 100% guarantee. It was written to help you start from somewhere and save you time.
- The process of parsing the links performed in this script is, of course, simple. It may not find all links correctly. In this case, you can contribute to improving the parsing mechanics or add code specific to your situation.
- Do not run it in a project directory you are not familiar with. As a result, it will communicate via curl by sending network packets to the connections!

## Main Features
- Recursively scans directories for URLs in files.
- Checks the status of each link using parallel processing for faster execution.
- Provides detailed logs indicating the status of each link, including HTTP status codes and error messages.
- Automatically installs required packages (curl and parallel) if they are missing.
- Supports customizing the number of threads for scanning to optimize performance.
- If desired, certain connections can be removed from the scope of screening.
- Files containing links can be printed on the daily file optionally.
- Only at the error level content can be printed on the daily file.

## Required
The Link Checker requires the following packages to be installed:

* curl: Command-line tool for transferring data with URLs.
* parallel: Shell tool for executing commands in parallel.

If these packages are not installed on your system, the script will prompt you to install them. If you do not want to install them this way, you can install them yourself and use the script.

You can install them with the following options according to your package manager.

``` bash
    sudo apt-get install curl
```

``` bash
    sudo apt-get install parallel
```

## Usage

### Parameters

There are four parameters available for the use of the script. Information about these parameters is provided below.

    directory - Directory address where links will be scanned.
    error_only - Flag that ensures only ERROR logs will be written. (Default: false)
    links_with_file - Prints the files containing the link. (Default: false)
    thread_count - The number of threads to use for scanning. (Default: 10)

To use the script, follow these steps:

1. Clone the repository containing the script to your local machine.

``` bash
git clone https://github.com/KaganCanSit/LinkChecker.git
```

2. Change to the directory containing the script.

``` bash
cd LinkChecker
```

3. Run the script with the desired parameters.

``` bash
./link_checker.sh /path/pathOfDirectory/directory error_only(default=false) links_with_file(default=false) thread_num(default=10)
```
To get general information via shell;
``` bash
./link_checker.sh --help (or -h)
```
After execution, review the generated logs to identify any broken links and their status. 

## Exclude Desired Links From Scanning

There may be links you don't want checked during the scan. For example, you typed "hhtp://remote_repository_address.git" for a code sample or a site where login is required. You can write these links to the "disabled_control_links.txt" file that you will define in the same directory as the script.

``` bash
    cd LinkChecker
    touch disabled_control_links.txt
    echo "Adress" >> disabled_control_links.txt
```

## Contributions

We welcome participation and contributions. You can make suggestions and send pull requests to further improve this script.

We especially encourage contributions from those interested in regex, have good network knowledge, and can help with the project.

Before submitting your content, please review it using "shellcheck". Ensure there are no errors or warning messages.

``` bash
sudo apt-get install shellcheck
shellcheck linkChecker.sh
```

## Licence:
This project is licensed under the MIT License. See the [MIT license](https://github.com/KaganCanSit/LinkChecker/blob/main/LICENSE) file for details.
