// query the name of the executable (process name) for a URL scheme
function bundleExecutableForScheme(scheme) {
    var apps = ObjC.classes.LSApplicationWorkspace.defaultWorkspace().applicationsAvailableForHandlingURLScheme_(scheme);
    // if there are multiple apps, punt
    if (apps.count() != 1) {
        return null;
    }

    var appProxy = apps.objectAtIndex_(0); // LSApplicationProxy    
    var bundleExecutable = appProxy.bundleExecutable();
    if (bundleExecutable !== null) {
        return bundleExecutable.toString();
    }

    return null;
}

// dump all registered URL schemes, organized by process name
function dumpSchemes() {
    var map = {};
    var schemes = ObjC.classes.LSApplicationWorkspace.defaultWorkspace().publicURLSchemes();
    for (var i = 0; i < schemes.count(); i++) {
        var name = bundleExecutableForScheme(schemes.objectAtIndex_(i));
        if (!(name in map)) {
            map[name] = [];
        }
        map[name].push(schemes.objectAtIndex_(i).toString());
    }
    return map;
}


/*
 *  Convenience functions to access app info.
 *  Dump key app paths and metadata:
 *      appInfo()
 *
 *  Print contents of Info.plist:
 *      infoDictionary()
 *
 *  Query Info.plist by key:
 *      infoLookup("NSAppTransportSecurity")
 *
 */

function dictFromNSDictionary(nsDict) {
    var jsDict = {};
    var keys = nsDict.allKeys();
    var count = keys.count();
    for (var i = 0; i < count; i++) {
        var key = keys.objectAtIndex_(i);
        var value = nsDict.objectForKey_(key);
        jsDict[key.toString()] = value.toString();
    }

    return jsDict;
}

function arrayFromNSArray(nsArray) {
    var jsArray = [];
    var count = nsArray.count();
    for (var i = 0; i < count; i++) {
        jsArray[i] = nsArray.objectAtIndex_(i).toString();
    }
    return jsArray;
}

function infoDictionary() {
    if (ObjC.available && "NSBundle" in ObjC.classes) {
        var info = ObjC.classes.NSBundle.mainBundle().infoDictionary();
        return dictFromNSDictionary(info);
    }
    return null;
}

function infoLookup(key) {
    if (ObjC.available && "NSBundle" in ObjC.classes) {
        var info = ObjC.classes.NSBundle.mainBundle().infoDictionary();
        var value = info.objectForKey_(key);
        if (value === null) {
            return value;
        } else if (value.class().toString() === "__NSCFArray") {
            return arrayFromNSArray(value);
        } else if (value.class().toString() === "__NSCFDictionary") {
            return dictFromNSDictionary(value);
        } else {
            return value.toString();
        }
    }
    return null;
}

function appInfo() {
    var output = {};
    output["Name"] = infoLookup("CFBundleName");
    output["Bundle ID"] = ObjC.classes.NSBundle.mainBundle().bundleIdentifier().toString();
    output["Version"] = infoLookup("CFBundleVersion");
    output["Bundle"] = ObjC.classes.NSBundle.mainBundle().bundlePath().toString();
    output["Data"] = ObjC.classes.NSProcessInfo.processInfo().environment().objectForKey_("HOME").toString();
    output["Binary"] = ObjC.classes.NSBundle.mainBundle().executablePath().toString();
    output["UriSchema"] = dumpSchemes()[infoLookup("CFBundleName")];
    return output;
}

function nsuserdafaults() {
	return ObjC.classes.NSUserDefaults.alloc().init().dictionaryRepresentation().toString()
}

function cookie() {
	var NSHTTPCookieStorage = ObjC.classes.NSHTTPCookieStorage;
	var cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage();
	var cookieJar = cookieStore.cookies();

	var cookies = [];

	if (cookieJar.count() > 0) {

	    for (var i = 0; i < cookieJar.count(); i++) {

	        // get the actual cookie from the jar
	        var cookie = cookieJar.objectAtIndex_(i);

	        // <NSHTTPCookie version:0 name:"__cfduid" value:"d2546c60b09a710a151d974e662f40c081498064665"
	        // expiresDate:2018-06-21 17:04:25 +0000 created:2017-06-21 17:04:26 +0000 sessionOnly:FALSE
	        // domain:".swapi.co" partition:"none" path:"/" isSecure:FALSE>
	        var cookie_data = {
	            version: cookie.version().toString(),
	            name: cookie.name().toString(),
	            value: cookie.value().toString(),
	            expiresDate: cookie.expiresDate() ? cookie.expiresDate().toString() : 'null',
	            // created: cookie.created().toString(),
	            // sessionOnly: cookie.sessionOnly(),
	            domain: cookie.domain().toString(),
	            // partition: cookie.partition().toString(),
	            path: cookie.path().toString(),
	            isSecure: cookie.isSecure().toString(),
	            isHTTPOnly: cookie.isHTTPOnly().toString()
	        };

	        cookies.push(cookie_data);
	    }
	}
	return cookies
}
