# Test Content

This folder contains tests for the project.

For more information about testing within Platform DXC, and the guidelines we try to align to, see the [testing repository](https://github.dxc.com/Platform-DXC/testing).

## Manual Testing

Our primary testing mechanism at the moment is manual testing, though we intend to improve this through our [DevOps Test Automation Theme](../docs/DevOpsThemes/ImprovementTheme-TestAutomation.md).

To enable a user to be able to test, they must first have a User ID created on the JIRA PenTest System with their DXC _short name_.  JIRA acts as an authentication source for Confluence.

In addition, the user must then be granted access to Confluence (`confluence-users` group). In most cases for our team this will be to the administrators group (`confluence-administrators`).

## Manual Unit Testing



* Display login screen
    - Access your given URL. See [archtiecture](../docs/architecture.md) for a list of URLs.
* Login with User ID and Password
* Logout - this is not technically testable on a working instance the way the SSO redirect works
* View Confluence Spaces
* Search Confluence Space
    - Click the search box at the top right
    - Search for the word "Newcastle"
    - You should see two results, "Newcastle DevOps Home" and "Newcastle DTC Home"
    - At the bottom of the search popup, click the `:mag: Search for 'newcastle'` line
    - Search results should appear in a refreshed window, showing at least 9 results
* View Add-Ons


## Unit Testing

Please describe the tools used and how you are managing unit test generation and execution, linting, syntax checking, spell checking documentation, and variations of this for the languages in scope.


## Integration Testing

Please describe the tools used and how you are managing integration test generation and execution

* Login with SAML Single Sign-On (DXC GlobalPass)
* Integration with JIRA?

## Functional Testing

Please describe your functional tests and how they are being traced to insure requirements are met, any test-driven / behavior-driven development approaches

### Build

Was the build successful, If successful, did it work or respond?

### Deployment

Describe how the deployment is validated

## Regression Testing

Regression testing has several meanings.  When addressing backwards compatibility we expect that is handled in functional testing and that the regression testing is focused on avoiding re-entry of prior bugs by forcing the testing against prior bugs.  Please describe the methods used by the team to address this testing practice.

## Load / Performance Testing

Please describe how your team is addressing load testing and what the expected loads will look like and any performance profiles related.
