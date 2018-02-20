# Frinfo

Non-rocket-science-tool for auto app dump

Usage:

```ruby shell.rb "AppName"```

Each dump include:

- Keychain items
- NSUserDefaults
- HTTPCookie 
- App files
- App data folder
- Decrypted .ipa file
- Decrypted bin/.dylib files (scp command)

Requred:

- Frida 
- Ruby 
- Jailbroaken iOS device (iOS 10.2 tested)

JS files include functions from 
[https://codeshare.frida.re/](https://codeshare.frida.re/)
 and 
[https://github.com/sensepost/objection](https://github.com/sensepost/objection)


The utility is made to reduce manual labor when analyzing multiple applications

Author: [@ansjdnakjdnajkd](https://twitter.com/ansjdnakjdnajkd)

Do you want to add or fix? - Write to me or pull request!
