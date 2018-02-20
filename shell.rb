require 'json'

#! SET App name 
$app_name = ARGV[0]

if ($app_name == "" or $app_name == "\n")
	puts 'Usage: ruby shell.rb "AppName"'
	exit()
end	

$ios = "-P 2222 root@127.0.0.1"
$ssh = "ssh root@127.0.0.1 -p 2222"
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


clutch_bin = `echo "clutch -b #{$bundle}" | #{$ssh}`
puts "Decrypt binary via Clutch from iOS: #{$?.success?}"
if (clutch_bin.split("\n")[-2].include? "Finished dumping")
	clutch_bin_path = clutch_bin.split("\n")[-2].split(" to ")[1]
	c =  "scp -r #{$ios}:#{clutch_bin_path} ./#{$bundle}_clutch"	
	clutch_cmd1 = `#{c}`
	puts clutch_cmd1
	puts "[!] Use it manually to copy from iOS device: \n#{c}"
	puts "Copying Clutch bin from iOS: #{$?.success?}"
else
	puts "Clutch binary decrypt – fucked up, sorry. Have a nice day!"
end

clutch_ipa = `echo "clutch -d #{$bundle}" | #{$ssh}`
puts "Decrypt .ipa via Clutch from iOS: #{$?.success?}"
if (clutch_ipa.split("\n")[-2].include? "DONE")
	clutch_ipa_path = clutch_ipa.split("\n")[-2].split("DONE: ")[1]
	c = "scp #{$ios}:\"'#{clutch_ipa_path}'\" ./#{$bundle}_clutch.ipa"
	clutch_cmd2 = `#{c}`
	puts clutch_cmd2
	puts "Use it manually to copy from iOS device: \n#{clutch_cmd2}"
	puts "Copying Clutch .ipa from iOS: #{$?.success?}"
	puts "[!] Use it manually to copy from iOS device: \n#{c}"
else
	puts "Clutch .ipa decrypt – fucked up, sorry. Have a nice day!"	
end
