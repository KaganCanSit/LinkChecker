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
- Allows excluding specific links from the scan.
- Optionally prints files containing links to a daily log file.
- Can log content only at the error level.

## Required
The Link Checker requires the following packages to be installed:

* curl: Command-line tool for transferring data with URLs.
* parallel: Shell tool for executing commands in parallel.

If these packages are not installed on your system, the script will prompt you to install them. You can also install them manually:

``` bash
    # For Debian-based systems
    sudo apt-get install curl parallel

    # For Red Hat-based systems
    sudo yum install curl parallel

    # For Arch-based systems
    sudo pacman -S curl parallel
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
./link_checker.sh /path/to/directory [error_only] [links_with_file] [thread_count]
```
To get general information via shell;
``` bash
./link_checker.sh --help
```
After execution, review the generated logs to identify any broken links and their status. 

## Exclude Desired Links From Scanning

There may be links you don't want checked during the scan. For example, you might have a "http://remote_repository_address.git" link for a code sample or a site where login is required. You can write these links to the disabled_control_links.txt file in the same directory as the script.

``` bash
    cd LinkChecker
    touch disabled_control_links.txt
    echo "Adress" >> disabled_control_links.txt
```

## Contributions

We welcome participation and contributions. You can make suggestions and send pull requests to further improve this script.

We especially encourage contributions from those interested in regex, have good network knowledge, and can help with the project.

We have prepared a guide for your [guidance](https://github.com/KaganCanSit/LinkChecker/blob/main/CODE_OF_CONDUCT.md), please take a look.

## Licence:
This project is licensed under the MIT License. See the [MIT license](https://github.com/KaganCanSit/LinkChecker/blob/main/LICENSE) file for details.