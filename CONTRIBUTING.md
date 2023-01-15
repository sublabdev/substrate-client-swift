# Contributing to Sublab's Substrate Client repository for Swift

## Intro

We, at Sublab, would love to have more mobile developers coming into Substrate ecosystem development. And while we're trying to produce as much as possible reliable and stable codebase, we still cannot cover all potential issues Substrate developers would need to solve, and we might have some bugs 🐞

So we encourage you to help us on this long journey by opening yet unknown issues or by contributing with your ideas in pull requests.

## Primary designation of this repository

This is a main Swift repository of our organization which uses all of other repositories and combines them to provide tools to connect to Substrate based blockchain networks.

Currently, only primary (relaychain) networks are fully tested, but this repository is subject to change when we add more networks support, including parachains and separate independent networks.

## Reporting issues

If you have encountered malfunctioning behavior of our produced codebase, please feel free to open an Issue under [Issues section](https://github.com/sublabdev/substrate-client-swift/issues) with Bug Report template type on this GitHub repository.

To ensure that we can reproduce your issue, please consider providing us with next information of your Issue:

- Version of library you're using, or if you include our library with your own fork, please provide the link to your public GitHub repository with either hash of the commit, or actual branch where you do your changes.
- Environment where do you use our library: iOS, macOS, or any other Apple OS application, or even Linux/Windows.
- Version of your environment:  iOS version, iPadOS version, etc.
- OS of your development machine: macOS/Linux/Windows version.
- Type of your device if it's iPhone or iPad: model number or name
- IDE that you use for development, like Xcode or AppCode
- What method did you use to use our library: CocoaPods, Carthage, Swift Package Manage, or added it as sub-repository.
- As many as possible: logs, crash stack traces, screenshots, and whatnot.
- If you have a sample application to reproduce the issue, please include the link to your sample app (preferably GitHub public repo).
- If this issue significantly affects your application and/or business, or blocks you from future development, please mention this so we can properly align our piorities to assist you with that.

Furthermore, we encourage you to report your created issue in our Telegram channel: [t.me/sublabsupport](http://t.me/sublabsupport) so we could assist you in the real time.

## New functionality

If you find our library very useful, which we would love to see, but still miss some functionality, please feel free to open an Issue under [Issues section](https://github.com/sublabdev/substrate-client-swift/issues) with Feature Request template type on this GitHub repository. 

To better understand your feature, please don't mind to provide next information:

- What platform do you seek to have this functionality for: we haven't tested our library on every possible platform, and maybe this is not yet compatible.
- If there is a reference from other application or a library, please provide the link to it.
- Don't hesitate to explain your feature detailed. The longer is it, the easier it will be for us to understand the whole idea.
- If you have an experience in Swift or Objective-C development and would like to assist us, but not sure about architectural solution, please mention this, we might  support your feature implementation by extensively reviewing your code and suggesting new implementation ideas.

Same as for bugs, feel free to contact us via Telegram at [t.me/sublabsupport](http://t.me/sublabsupport) to discuss your ideas in chat.

## Submitting your code

We have limited resources, therefore we would appreciate this if anybody could help us by developing some small or not so small features to our library. 

If you have developed a feature, please post this under [Pull Requests section](https://github.com/sublabdev/substrate-client-swift/pulls) of our GitHub repository, and don't forget about some rules:

- If there is an Issue on our Issues section, please provide link to it, and don't forget to mention its number on your branch.
- However, if your feature is big enough and you don't have an Issue on our public GitHub repository, this would take significant amount of time and effort for us to discover your code and understand its designation. So to avoid long conversations and delaying your feature release, please look into making a feature Issue prior to actual development.
- Don't forget to provide voluminous description so that we can skip part where we would've spent extra time trying to understand your work.
- Every contribution should be provided as a pull request from fork of our library on your own personal account or bussiness account if you're a company.
- Please ensure that your code aligns with our current license which is Apache 2.0, and you agree with its terms for the code your develop for this library.
- Even though we do not have coding guidelines or standards yet, we still would love to see your Pull Request to match our existing coding standard with the same padding, line break rules, and so on. Please note, that we do make only Swift based code in this repository, so this is a strict requirement with some exceptions (like when C/C++ or Rust code is to be interop-ed).
- Be ready for our team to ask for clarifications of some parts of your code or to request making changes to match our code style or to optimize the code.
- We do not guarantee that your pull request will be merged, and same we don't guarantee that in case of rejection we won't reuse your code base eventually if we find it useful. At that time we might have complicated changes inside our codebase and your pull request might be slightly outdated. But we could contact you later to assist on migration if we find this useful.
- Every pull request should have unit tests that cover whole written functionality and its stability of execution. Please use our commonly shared *testsCount* number to highly load your unit tests, but if it does some huge computing job inside, feel free to lower the number by either providing separate constant or lowering it inside your test class. For high computing jobs we consider single test execution time under 5-10 minutes as a top bar. If tests do not pass, we won't approve changes unless it's fixed.
- If your feature is time sensitive and affects your current application and/or business, please mention this, so we can prioritize your pull request respectively.

## Contacting us

If neither of above solves your current problem, please feel free to contact us via our Telegram chat or by writing us via e-mail. We honor every incoming request and it's our duty to help to relax your Substrate development routine.

Our contacts:

- Telegram support chat: [t.me/sublabsupport](http://t.me/sublabsupport)
- E-mail: [info@sublab.dev](mailto:info@sublab.dev)
- Our Twitter, yes you can tweet us: https://twitter.com/sublabdev
