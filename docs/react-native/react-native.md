# React Native
- [Set Up Your Environment](https://reactnative.dev/docs/set-up-your-environment)

# brew
- [Homebrew](https://brew.sh/)
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
brew install watchman
```

# Xcode
[download xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

# CocoaPods
- [CocoaPods](https://cocoapods.org/)
- [Getting Started](https://guides.cocoapods.org/using/getting-started.html)

```
sudo gem install cocoapods
```
```
pod --version
```

# NVM
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

```
nvm -v
```

```
nvm ls
```

```
nvm use 21.4.0
```

The following gets added to .zshrc
```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```

# Yarn 1
```
brew install yarn
```

```
brew install yarn@1.22.22
```

```
yarn -v
```

# watchman
```
brew install watchman
```

# Node
Node can also be installed using brew
```
brew install node
```
```
node -v
```

# Check Environment

```
    ./check-env.sh
```