require 'json'

#! SET App name 
$app_name = "SNGB"

$ios = "-P 2222 root@127.0.0.1"
$bundle = nil
$app = nil
$data = nil

inf = nil

frida_info = `frida -U -l show.js -n #{$app_name} -e "appInfo()" -q`
fridaArray = JSON.parse(frida_info)
puts "Grab info from iOS app: #{$?.success?}"
$bundle = fridaArray["Bundle ID"]
$app = fridaArray["Bundle"].split("/")[0..-2].join("/")+"/"
$data = fridaArray["Data"]+"/"

app_cmd = `scp -r #{$ios}:#{$app} ./#{$bundle}`
puts "Copying app folder from iOS: #{$?.success?}"

data_cmd = `scp -r #{$ios}:#{$data} ./#{$bundle}`
puts "Copying data folder from iOS: #{$?.success?}"


frida_nsuserdafaults = `frida -U -l show.js -n #{$app_name} -e "nsuserdafaults()" -q`
puts "Grab NSUserDefaults from iOS: #{$?.success?}"

frida_httpcookie = `frida -U -l show.js -n #{$app_name} -e "cookie()" -q`
puts "Grab HTTPCookie from iOS: #{$?.success?}"

frida_keychain_entry = `frida -U -l keychain.js -n #{$app_name} -e "keychain_entry" -q`
puts "Grab Keychain Entry from iOS: #{$?.success?}"

frida_keychain_items = `frida -U -l keychain.js -n #{$app_name} -e "keychain_items" -q`
puts "Grab Keychain Items from iOS: #{$?.success?}"


f = File.open("Data_#{$bundle}",'w');
f.write("INFO")
f.write(frida_info);
f.write("NSUserDefaults")
f.write(frida_nsuserdafaults);
f.write("HTTPCookie")
f.write(frida_httpcookie);
f.write("Keychain Entry")
f.write(frida_keychain_entry);
f.write("Keychain Items")
f.write(frida_keychain_items);
f.close