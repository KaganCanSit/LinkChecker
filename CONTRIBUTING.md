# Contributing to Link Checker

First off, thank you for considering contributing to Link Checker! It's people like you that make this project possible. We welcome any kind of contribution, whether it's reporting issues, submitting enhancements, or improving documentation

## How to Contribute

### Reporting Issue

If you encounter any issues or bugs while using Link Checker, please report them by opening an issue on the [GitHub issues](https://github.com/KaganCanSit/LinkChecker/issues) page. When reporting an issue, please include:

- A clear and descriptive title.
- A detailed description of the problem, including steps to reproduce the issue.
- Any error messages or logs.
- Your operating system and version.

### Suggesting Enhancements

If you have ideas to improve Link Checker, we'd love to hear them! You can suggest enhancements by opening an issue on the [GitHub issues](https://github.com/KaganCanSit/LinkChecker/issues) page. When suggesting an enhancement, please include:

- A clear and descriptive title.
- A detailed description of the enhancement.
- Any relevant examples or screenshots.

### Pull Requests

1. Fork the repository on Github.
2. Clone your fork to your local machine:
``` bash
git clone https://github.com/KaganCanSit/LinkChecker.git
cd LinkChecker
```
3. Create new branch for your changes:
``` bash
git checkout -b feature-branch
```
4. Make your changes to the code.
5. Test your changes thoroughly to ensure they work as expected.
6. Commit your changes:
``` bash
git commit -m "Description of the changes"
```
7. Push your changes to your fork:
``` bash
git push origin feature-branch
```
8. Create a pull request to the main repository. Please include a detailed description of your changes and any relevant issue numbers.

### Code Style and Standards

To maintain consistency and quality in the codebase, please follow these guidelines:

- Shell Script Standards: Use [ShellCheck](https://www.shellcheck.net/) to check your shell scripts for errors and warnings.

``` bash
sudo apt-get install shellcheck
shellcheck link_checker.sh
```

- Comments: Add comments to your code where necessary to explain functionality.
- Readability: Write clear and readable code. Avoid complex and nested logic when possible.

### Testing
Before submitting your pull request, make sure to:

- Test your changes thoroughly.
- Run the script to ensure there are no errors.
- Check for regressions to avoid breaking existing functionality.

### Documentation
Help us improve the documentation:

- Update the README.md if you make changes to the user interface or functionality.
- Ensure the CONTRIBUTING.md is up to date with your changes.

### Getting Help
If you need help or have questions, contact the maintainers.

### Code of Conduct
Please note that this project is released with a [Contributor Code of Conduct](https://github.com/KaganCanSit/LinkChecker/blob/main/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Thank you for your contributions!