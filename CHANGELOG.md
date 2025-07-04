# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# 1.0.0 (2025-07-04)


### Bug Fixes

* add package.json for semantic-release dependencies ([fd63ddd](https://github.com/caioariede/nvim-persist-window/commit/fd63ddd178e104149296b14b3bd8cf2b4954b819))
* add write permissions to release workflow ([165cc6b](https://github.com/caioariede/nvim-persist-window/commit/165cc6b9ca91dc3067fc623ba1b2c3beadc7c528))
* correct Basic Usage example in README ([dce5546](https://github.com/caioariede/nvim-persist-window/commit/dce5546a03a613ff9e2e4dca32d4c5febdbef384))
* correct repository URL in package.json ([d47ada8](https://github.com/caioariede/nvim-persist-window/commit/d47ada801f49b56783d11399e7c35f92cb1fd2c6))
* improve floating window creation example ([3a924cb](https://github.com/caioariede/nvim-persist-window/commit/3a924cbcf8210eacdc733f2f582aa9bfbdfa3f45))
* load plugin commands in integration tests ([f95649c](https://github.com/caioariede/nvim-persist-window/commit/f95649c40f9748b4d8587dfbe7b5b7c8f0a38a66))
* remove npm cache from release workflow ([15410c5](https://github.com/caioariede/nvim-persist-window/commit/15410c5644b67f2f0a9630f1ee76e591f667a789))
* upgrade actions/upload-artifact from v3 to v4 ([5cdb03a](https://github.com/caioariede/nvim-persist-window/commit/5cdb03a21f413bb2da316a358bb1844ba57ac99d))
* upgrade Node.js version to 20 for semantic-release ([945b45f](https://github.com/caioariede/nvim-persist-window/commit/945b45f2c37e949954f937c9a2805d910e7a65a0))


### Features

* initial release of persist-window.nvim ([d8ebf7a](https://github.com/caioariede/nvim-persist-window/commit/d8ebf7ae5f37efd1003ab843504ef4222291760e))

## [Unreleased]

### Added
- Initial release of persist-window.nvim
- Window persistence across tabs functionality
- Commands: `:ListWindows`, `:PersistWindow`, `:ToggleWindow`, `:PersistWindowInfo`
- Always-on-top mode with `:PersistWindowAlwaysOnTop`
- Comprehensive test suite with 41 passing tests
- Tab-agnostic window management
- Auto-hide functionality on tab switches
- Cross-tab window recreation and positioning
- Enhanced error handling and validation
- LuaCATS type annotations
- Development environment with isolated testing
- GitHub Actions CI/CD with semantic releases
