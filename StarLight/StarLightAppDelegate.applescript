--
--  StarLightAppDelegate.applescript
--  StarLight
--
--  Created by goodtime on 4/11/11.
--  Copyright 2011 NiceMac. All rights reserved.
--

-- Global Properties sit outside the script
property parent : class "NSObject"

--NSURLRequest/Connection Delegates
property theLoginDelegate : class "login" of current application
property theChannelsDelegate : class "channels" of current application
property self : class "StarLightAppDelegate" of current application

-- StarMenu Classes
property NSMenu : class "NSMenu" of current application
property NSMenuItem : class "NSMenuItem" of current application
property NSImage : class "NSImage" of current application

-- URL Request Encoding
property myProtocol : "https://"
property siriusDomain : "www.siriusxm.com/userservices"
property loginPath : "/authentication/en-us/xml/user/login"

property myEncoding : NSUTF8StringEncoding of current application --code for UTF8
property shouldLoadChannels : true
property loginInfo : {}
property postMethod : "POST"  -- use POST for the Login Method
property getMethod : "GET"  -- use GET for any other Requests

property allowAdultContent : true
property shouldPlay : true
property sleepTight : false
property deviceID : ""

-- Master Channel List stored In Memory
-- theList can change with Stars (Favorites)
property bigChannelList : {}

-- this list is recorded whenever a new channel list is requested
property starsList : missing value

--property channelTimer : missing value
--property tempChannelList : {}
property myPlayr : missing value
property chKey : ""
property chName : ""
property loginUser : ""
property loginPass : ""
property playrData : ""
property startVolume : "25"
property loadInProgress : false
property myConnection : ""
property rtmp : "rtmpte://"
property streamTimeOut : "10"

-- remote control for mplayer
property readHandle : missing value
property writeHandle : missing value
property outputpipe : missing value
property inputpipe : missing value

property starLightDir : "~/Application Support/StarLight/"
property logoDir : "~/Application Support/StarLight/Logos"
property chDataPlist : "~/Application Support/StarLight/channelData.plist"

property starsMenu : missing value


script StarLightAppDelegate
    
    -- init variables
    property channelData : null
    property swfURL : ""
    property theIndexSet : class "NSIndexSet" of current application
    
    -- Login variables
    property theCurrency :"840" --from SiriusXM
    property consumerType : "ump" --from SiriusXM
    
	-- Application Outlets
    -- Text Fields
    property userField : missing value
    property passField : missing value
    property artistField : missing value
    property songField : missing value
    property channelField : missing value
    
    -- Other IBOutlets
    property logoView : missing value
    property outletVolume : missing value
    property mainWindow : missing value
    property starsButton : missing value
    property starsColumn : missing value
    property favButton : missing value
    property mySpinner : missing value
    
    -- Preferences
    property timeOutMenu : missing value
    property tunnelHTTP : missing value
    
    -- Drawers
    property loginDrawer : missing value
    
    -- bindings (don't remove or rename)
    property myTable : missing value
    property channelArray : missing value
    property theList : missing value
    
    -- Audio Output Device Stuff
    property audioTable : missing value
    property audioArray : missing value
    property audioList : missing value
    
    -- StarMenu defaults
    property defaultsRegistered : false
    
    -- StarMenu Objects
    property standardUserDefaults : missing value
    property statusMenu : missing value
    property statusItemController : missing value
    
    on showWindow_(self)
        activate
        mainWindow's makeKeyAndOrderFront_(self)
    end
    
    on getStars()
        return starsList
    end getStars
    
    on updateStarsMenu()
        -- update Menu            
        -- statusItemController's updateAnimation_(3)
        
        tell class "NSPredicate" of current application
            set myPred to predicateWithFormat_("stars == 1")
        end
        
        tell class "NSMutableArray" of current application
            set starsList to arrayWithArray_(bigChannelList)
            starsList's filterUsingPredicate_(myPred)
        end
        
        
        starsMenu's removeAllItems()
        set item_count to (count of starsList)
        if (item_count = 0) then
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("You have No Stars")
            menuItem's setEnabled_(false)
            starsMenu's addItem_(menuItem)
            menuItem's release()
            else
            repeat with i from 1 to item_count
                set getObject to starsList's objectAtIndex_(i - 1)
                set menuItem to (my NSMenuItem's alloc)'s init
                set sn to getObject's valueForKey_("sirNo") as string
                set cn to getObject's valueForKey_("chName") as string
                menuItem's setTag_(i)
                menuItem's setTitle_((sn & " " & cn) as string)
                menuItem's setTarget_(me)
                menuItem's setAction_("playStarMenu:")
                if i < 10 then 
                    menuItem's setKeyEquivalent_(i as string)
                    else if i = 10 then
                    menuItem's setKeyEquivalent_("0")
                end
                
                
                menuItem's setEnabled_(true)
                starsMenu's addItem_(menuItem)
                menuItem's release()
            end repeat
            --repeat with i from 1 to item_count
            
            --set menuItem to (my NSMenuItem's alloc)'s init
            --menuItem's setEnabled_(false)
            --starsMenu's addItem_(menuItem)
            --menuItem's release()
            --set the_action to ((dynamicMenuActionPopUpButton's titleOfSelectedItem) as Unicode text) & ":"
            --set current_date to (current date)'s time string
            --
            --end repeat
        end if
        --statusItemController's updateAnimation_(1)
    end
    
    on starSearch()
        if bigChannelList ≠ missing value and my theList ≠ missing value then
            set x to starsButton's state as integer
            --display dialog x as string 
            updateStarsMenu()
            if x = 1 then
                set bigChannelList to theList
                -- get's the all the Stars using NSPredicate and filterUsingPredicate
                --set the star button Image
                set starOn to current application's NSImage's imageNamed_("starOn")            
                starsButton's setImage_(starOn)
                
                tell class "NSMutableArray" of current application
                    set my theList to arrayWithArray_(starsList)
                end
                else
                
                --set the star button Image
                set starOff to current application's NSImage's imageNamed_("starOff")            
                starsButton's setImage_(starOff)
                tell class "NSMutableArray" of current application
                    set my theList to arrayWithArray_(bigChannelList)
                end
            end if
            
            -- save the stars
            bigChannelList's writeToFile_atomically_(chDataPlist, true)    
        end
    end
    
    on showStars_(sender)
        --log bigChannelList
        if bigChannelList ≠ missing value then
            starSearch()
            else
            set sender's state to 0
        end
    end showStars_
    
    on heyMan_(sender)
        -- do nothing for now
        --display dialog "HEY"
        updateStarsMenu()
    end
    
    on donate_(sender)
        open location "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6JU4G9W2XJNSS"
    end donate_
    
    on nicemac_(sender)
        open location "http://nicemac.com"
    end nicemac_
    
    on starplayr_(sender)
        open location "http://starplayr.com"
    end starplayr_
    
    on macupdate_(sender)
        open location "http://macupdate.com"
    end nicemac_
    
    on pgURL_(myURL, myBody, myMethod, myDelegate)
        -- String to NSURL
        tell class "NSURL" of current application
            set myURL to URLWithString_(myURL)
        end tell
        
        -- String 
        tell class "NSString" of current application
            set myBody to stringWithString_(myBody)
        end
        
        set myBody to myBody's dataUsingEncoding_(myEncoding)
        
        -- tell class "NSString" of current application
        --set myMethod to myMethod
        -- end
        
        tell NSMutableURLRequest of current application
            set myRequest to requestWithURL_(myURL)
        end
        
        tell myRequest
            setHTTPMethod_(myMethod)
        end
        
        --addValue:forHTTPHeaderField:
        -- add the Message Body when sending a POST Method
        if myMethod = "POST" then
            tell myRequest
                setHTTPBody_(myBody)
            end
        end
        -- form the connection
        set myConnection to (((current application's class "NSURLConnection")'s alloc)'s initWithRequest_delegate_(myRequest, myDelegate))
    end
    
    on runPlayr_(loginInfo)
        set shouldPlay to true
        set mySessionID to mySessionID of loginInfo
        
        set channelRequestURL to ("https://www.siriusxm.com/userservices/token/en-us/xml/ump/token/" & chKey & "?cdn=sirius&sessionId=" & mySessionID)
        
        --log channelRequestURL
        
        pgURL_(channelRequestURL, "", getMethod, self)
        --display alert "HELLOWORLD."
    end
    
    --- load Channel URL
    on connection_didReceiveResponse_(myConnection, response) 
        set playrData to missing value
        
        -- setup NSMutableData 
        set playrData to current application's class "NSMutableData"'s (alloc()'s init())'s autorelease()
        
        -- set the length to zero
        playrData's setLength_(0)
        
        tell class "NSHTTPURLResponse" of current application
            set statusText to (localizedStringForStatusCode_(statusCode of response)) as text
            set statusCode to (statusCode of response) as string
        end
        
        -- if it fails to do anything, show what it didn't do here (the error)
        if statustext = "no error" then
            else
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:("HTTP Error: " & statusCode),artist:("Err: " & statusText & "."),song:""})
            end
            --display alert "HTTP Error: " & statusCode & return &   
        end
    end
    
    on connection_didReceiveData_(myConnection,myData)
        playrData's appendData_(myData)
    end
    
    on connection_didFailWithError_(myConnection,trpErr)
        -- display alert trpErr as string    
        set EM to ""
        try
            set newError to (NSLocalizedDescription of userInfo of (trpErr)) as string
            on error EM
            set EM to "More info: " & EM
            -- if AppleScript can't do this, so what else is wrong
        end
        
        -- display the error
        if newerror contains "offline" then
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:("Network Error:"),artist:"This computer's internet connection",song:"appears to be offline."})
            end
            else
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:("Network Error:"),artist:newError,song:EM})
            end
        end
        
        --display alert newError & return & return & EM
    end
    
    
    on connectionDidFinishLoading_(myConnection)
        set playrMsg to (((current application's class "NSString")'s alloc)'s initWithData_encoding_(playrData, current application's NSUTF8StringEncoding))'s autorelease() as string
        set playrData to missing value
        
        if playrMsg contains "Successful request" then
            --log loginMsg
            
            tell class "XMLReader" of current application
                -- + (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
                set myToken_data to dictionaryForXMLString_error_(playrMsg as string, missing value)
            end
            
            set theStatus to value of status of tokenResponse of myToken_data
            set aifp to value of aifp of tokenResponse of myToken_data
            set customParam to value of customParam of tokenResponse of myToken_data
            set myHostName to value of hostname of tokenResponse of myToken_data
            set myStreamName to value of streamName of tokenResponse of myToken_data
            set myToken to value of token of tokenResponse of myToken_data
            
            if rtmp = missing value then
                log "RTMP missing value setting it default."
                set rtmp to "rtmpe://"
            end
            
            --log "RTMP = " & rtmp
            
            if streamTimeOut = missing value then
                set streamTimeOut to "16"
            end
            
            -- log "streamTimeOut = " & streamTimeOut
            
            -- if swfinfo does not exist, then let's make a new one
            try
                do shell script "/bin/ls ~/.swfinfo"
                on error errMsg number errNum
                --display dialog errMsg
                try
                    set swfURL to loadSWF()
                    on error EM
                    log EM
                end
            end try
        
            -- incase the swfURL is blank
            if swfURL = "" then
                set swfURL to loadSWF()
            end if
                
             set arraylist to {"ffmpeg://" & rtmp & myHostName & "/" & myStreamName & "?auth=" & myToken & "&aifp=" & aifp & " swfUrl=https://www.siriusxm.com/player/" & swfURL & " timeout=" & streamTimeOut & " swfVfy=1 swfAge=1 live=1 -buffer 65536", "-V", "-volume", startVolume, "-slave","-quiet", "-ao", "coreaudio:device_id=" & deviceID, "-vo", "null", "-afm", "ffmpeg", "-prefer-ipv4"} 
            
            --log rtmp & myHostName & "/" & myStreamName & "?auth=" & myToken & "&aifp=" & aifp
     
            
            if theStatus as integer = 1 then
                --log arraylist
                
                set outputpipe to current application's NSPipe's pipe()
                set inputpipe to current application's NSPipe's pipe()
                set readHandle to outputpipe's fileHandleForReading()
                set writeHandle to inputpipe's fileHandleForWriting()
                
               -- set myEnvSource to current application's NSMutableArray's alloc()'s init()
                
               -- set attrsDict to current application's NSDictionary's dictionaryWithObjects_forKeys_({myFont, someColor}, {current application's NSFontAttributeName,
                --current application's NSForegroundColorAttributeName})
               
                --set defaultEnvironment to ((current application's NSProcessInfo's processInfo)'s environment)
              
        
              -- tell defaultEnvironment
               --    setObject_forKey_("http://localhost:8080/","http_proxy")
               --    setObject_forKey_("https://localhost:8080/","https_proxy")
               --    setObject_forKey_("NO","NSUnbufferedIO")
               --    setObject_forKey_("http://127.0.0.1:8080/","HTTP_PROXY")
              -- end
                
                
               -- log "*****************"
               -- log defaultEnvironment
               -- log "*****************"

                
               -- NSDictionary *defaultEnvironment = [[NSProcessInfo processInfo] environment];
                --NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithDictionary:defaultEnvironment];
               -- [environment setObject:@"YES" forKey:@"NSUnbufferedIO"];
                --[task setEnvironment:environment];

                
                set myPlayr to current application's NSTask's alloc's init()'s autorelease()
                tell myPlayr
                    setStandardInput_(inputpipe)
                    setStandardOutput_(outputpipe)
                    setStandardError_(outputpipe)
                    --setEnvironment_(defaultEnvironment)
                    set myPath to (current application's NSBundle's mainBundle()'s pathForResource_ofType_("mplayer", "exec") as string)
                    setLaunchPath_(myPath as string)
                    setArguments_(arraylist)
                    --log myPath
                    |launch|()
                end tell
                
                set loadinProgress to false
                -- tell progSpinner to stopAnimation_(me)
                
                tell current application's NSNotificationCenter's defaultCenter()
                    removeObserver_(me)
                    removeObserver_name_object_(me, "NSFileHandleReadCompletionNotification", readHandle)
                    removeObserver_name_object_(me, "NSTaskDidTerminateNotification", myPlayr)
                    addObserver_selector_name_object_(me, "readPipe:", "NSFileHandleReadCompletionNotification", readHandle)
                    addObserver_selector_name_object_(me, "endPipe:", "NSTaskDidTerminateNotification", myPlayr)
                end tell
                
                -- let the main thread know that we are done getting the stream
                
                if readHandle ≠ missing value then
                    tell readHandle
                        readInBackgroundAndNotify()
                    end tell
                end if
            end if 
        end
    end
    
    on getLogin()
        --tell mySpinner to startAnimation_(me)
        
       -- log "get login called."
        
        set loginUser to userField's stringValue() as string
        set loginPass to passField's stringValue() as string
        --log "made it here"
        if loginPass ends with " kids" then
            set siriusLoginPass to text 1 thru - 6 of loginPass
            set allowAdultContent to false
            else
            set allowAdultContent to true
            set siriusLoginPass to loginPass
        end if
        
        if loginUser ≠ "" and loginPass ≠ "" then
            
            -- record the Stars, incase a channel list is needed
            tell class "NSPredicate" of current application
                set myPred to predicateWithFormat_("stars == 1")
            end
            
            set starState to starsButton's state as boolean
            
            if not starState then
                tell class "NSMutableArray" of current application
                    set starsList to arrayWithArray_(theList)
                    starsList's filterUsingPredicate_(myPred)
                end
                else
                tell class "NSMutableArray" of current application
                    set starsList to arrayWithArray_(bigChannelList)
                    starsList's filterUsingPredicate_(myPred)
                end
            end
            
            --attempt Login
            set loginURL to (myProtocol & siriusDomain & loginPath) as string
            
            -- set the Body for the POST text
            set loginBody to "<authenticationRequest><login>" & loginUser & "</login><consumerType>" & consumerType & "</consumerType><currency>" & theCurrency & "</currency><password>" & siriusLoginPass & "</password><subscriberType></subscriberType></authenticationRequest>"
            
            -- run the request in the background
            pgURL_(loginURL, loginBody, postMethod, theLoginDelegate)
            else
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:"SiriusXM Login is at the bottom.",artist:"Your username or password is blank.",song:""})
            end
            openDrawer()
        end if
    end getLogin
    
    -- Six Getters AdultContent, chDataPlist, loginInfo, loginUser
    on getShouldPlay()
        return shouldPLay
    end
    
    on getShouldLoadChannels()
        return shouldLoadChannels
    end
    
    on getAdultContent()
        return allowAdultContent
    end
    
    on getChDataPlist()
        return chDataPlist
    end
    
    on getLoginInfo()
        return loginInfo
    end
    
    on getLoginUser()
        return {loginUser,loginPass}
    end
    
    on loadChannels_(info)
        set loginInfo to info -- return the data back from the login.delegate
        set channelURL to (myProtocol & siriusDomain & "/cl/en-us/xml/lineup/" & channelLineupId of loginInfo & "/client/UMP") as string
        pgURL_(channelURL, "", getMethod, theChannelsDelegate)
    end
    
    on startChannelTimer()
        set channelTimer to current application's NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(5, me,"channelLoop:", "channelTimer", false)
    end
    
    on channelLoop_(channelTimer)
        log "channelLoop Called."
        if not sleepTight then
            shouldReconnect()
        end if
    end channelLoop_
    
    -- activates main window clicking on dock icon (if it is not already visible) 
    on applicationShouldHandleReopen_hasVisibleWindows_(mySelf,myVisible)
        --log properties of me
        if mainWindow's isVisible then
            --mainWindow's performClose_(me)
            return true
            else
            -- mainWindow is a IBOutlet linked to the mainWindow
            mainWindow's makeKeyAndOrderFront_(me)
            return false
        end
    end
    
    on loadSWF()
        -- try placing this later
        try
            set myHTML to do shell script "curl --connect-timeout 5 --max-time 5 https://www.siriusxm.com/player/ | grep '.swf'"
            set AppleScript's text item delimiters to "\""
            set textItems to text items of myHTML
            set AppleScript's text item delimiters to ""
            set swfURL to item 6 of textItems
            return swfURL
            --log swfURL -- get the URL for the SWF File
            on error errMsg
                log "SWF Error: " & errMsg
        end try
    end
    
    on createStarMenu()
        try
            set statusMenu to (my NSMenu's alloc)'s initWithTitle_("StarMenu")
            
            tell class "NSPredicate" of current application
                set myPred to predicateWithFormat_("stars == 1")
            end
            
            tell class "NSMutableArray" of current application
                set starsList to arrayWithArray_(bigChannelList)
                starsList's filterUsingPredicate_(myPred)
            end
            
            --add the dynamic menu
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("Dynamic Stars Menu")
            menuItem's setEnabled_(false)
            starsMenu's addItem_(menuItem)
            menuItem's release()
            
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("Stars")
            menuItem's setSubmenu_(starsMenu)
            statusMenu's addItem_(menuItem)
            menuItem's release()
            starsMenu's release()
            
            updateStarsMenu()
            
            statusMenu's addItem_(my NSMenuItem's separatorItem)
            
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("Play")
            menuItem's setTarget_(me)
            menuItem's setAction_("playButton:")
            menuItem's setKeyEquivalent_("p")
            
            menuItem's setEnabled_(true)
            statusMenu's addItem_(menuItem)
            menuItem's release()
            
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("Stop")
            menuItem's setTarget_(me)
            menuItem's setAction_("setStop:")
            menuItem's setKeyEquivalent_("e")
            menuItem's setEnabled_(true)
            statusMenu's addItem_(menuItem)
            menuItem's release()
            
            set menuItem to (my NSMenuItem's alloc)'s init
            menuItem's setTitle_("Player Window")
            menuItem's setTarget_(me)
            menuItem's setAction_("showWindow:")
            menuItem's setKeyEquivalent_("w")
            menuItem's setEnabled_(true)
            statusMenu's addItem_(menuItem)
            menuItem's release()
            
            statusMenu's addItem_(my NSMenuItem's separatorItem)
            
            set gen to {"Pop","Rock",  "Dance","Country","Christian","Jazz","Classical", "Family", "Sports","Comedy","Howard","Entertain", "News", "Politics"}
            
            repeat with x from 1 to count of gen
                tell class "NSPredicate" of current application
                    set myPred to predicateWithFormat_("gen contains[cd] '" & item x of gen & "'")
                end
                
                tell class "NSMutableArray" of current application
                    set genreList to arrayWithArray_(bigChannelList)
                    genreList's filterUsingPredicate_(myPred)
                end
                
                if count of genreList ≠ 0 then
                    set genresMenu to (my NSMenu's alloc)'s initWithTitle_("my" & item 1 of gen)
                    repeat with i from 1 to (count of genreList)
                        set getObject to genreList's objectAtIndex_(i -1)
                        set menuItem to (my NSMenuItem's alloc)'s init
                        set sirNo to getObject's valueForKey_("sirNo") as string
                        set chName to getObject's valueForKey_("chName") as string
                        
                        menuItem's setTag_(i)
                        menuItem's setTitle_((sirNo & " " & chName) as string)
                        menuItem's setTarget_(me)
                        menuItem's setAction_("playStarMenu:")
                        menuItem's setEnabled_(true)
                        genresMenu's addItem_(menuItem)
                        menuItem's release()
                    end repeat
                    set menuItem to (my NSMenuItem's alloc)'s init
                    menuItem's setTitle_(item x of gen )
                    menuItem's setSubmenu_(genresMenu)
                    statusMenu's addItem_(menuItem)
                    menuItem's release()
                    genresMenu's release()
                end
            end
            
            --let's add something useful:
            --set menuItem to (my NSMenuItem's alloc)'s init
            --menuItem's setTitle_("Get Definition…")
            --menuItem's setTarget_(me)
            --menuItem's setAction_("getDefinition:")
            --menuItem's setEnabled_(true)
            --statusMenu's addItem_(menuItem)
            --menuItem's release()
            --statusMenu's addItem_(my NSMenuItem's separatorItem)
            
            --set menuItem to (my NSMenuItem's alloc)'s init
            --menuItem's setTitle_("Quit MenuApp")
            --menuItem's setTarget_(me)
            --menuItem's setAction_("quit:")
            --menuItem's setKeyEquivalent_("q")
            --menuItem's setEnabled_(true)
            --statusMenu's addItem_(menuItem)
            --menuItem's release()
            --display dialog "HEY"
            
            set statusItemController to (current application's class "JNS_StatusItemController"'s alloc)'s init
            statusItemController's createStatusItemWithMenu_(statusMenu)
            statusMenu's release()
            on error EM
            log "menuError: " & EM
        end try 
    end createStarMenu
    
    on registerDefaults()
        set standardUserDefaults to current application's class "NSUserDefaults"'s standardUserDefaults
        set iconPath to (current application's NSBundle's mainBundle()'s pathForResource_ofType_("starBaroff", "psd") as string)
        set iconAlt to (current application's NSBundle's mainBundle()'s pathForResource_ofType_("starBaron", "psd") as string)
        set defaults to {title_display:2, menu_title:"StarMenu", icon_path:iconPath, icon_altpath:iconalt}
        standardUserDefaults's registerDefaults_(defaults)
    end registerDefaults
    
    on playStarMenu_(sender)
        set myTitle to title of sender as text
        set playNo to (word 1 of myTitle) as string
        repeat with myIndex from 0 to (count of bigChannelList)
            set getObject to bigChannelList's objectAtIndex_(myIndex)
            set sirNo to getObject's valueForKey_("sirNo") as string
            if playNo = sirNo then
                set chKey to getObject's valueForKey_("chKey") as string
                set chName to getObject's valueForKey_("chName") as string
                set chName to sirNo & " " & chName
                playStation(chKey,chName)
                log "SuperStars: MATCH FOUND"
                exit repeat
            end
        end
    end
    
    on didReceiveHotkeyCommand_(aNotification)
        set myID to  (|identifier| of |object| of  aNotification) as string
        
        if myID = "mySecondHotkey" then
            statusItemController's showMenu()
        end if
        
        if myID = "myFirstHotkey" then
            statusItemController's showMenu()
        end if
    end
    
    on awakeFromNib()        
            tell current application's NSNotificationCenter's defaultCenter()
                addObserver_selector_name_object_(me, "didReceiveHotkeyCommand:", "PWHotkeyNotification", missing value)
            end tell
            
            -- two global hotkeys are defined
            -- modifier keys are defined in CocoaHotKeys.m
            
            -- to help Find keycodes, see:
            -- http://manytricks.com/keycodes/
            
            -- Keycodes are defined in ASOC:
            
            -- first global hot key uses: Cmd-Opt-s
            -- l = 32
        
            tell class "CocoaHotkeys" of current application
                HotKey2_(28)
            end
            
        
        
            set starsMenu to (my NSMenu's alloc)'s initWithTitle_("theStars")
            
            
            tell class "ChannelXML" of current application
                set my audioList to loadOutputDevices()
            end
            
            tell current application's class "NSUserDefaults"
                set defaults to standardUserDefaults()
            end tell
            --log "OK"
            try
                tell defaults
                    try
                        set deviceName to valueForKey_("deviceName") as string
                        on error
                        set deviceName to "Default Audio"
                    end
                end
            end
            --log "OK2"
            
            set grabbedInd to false
            repeat with myIndex from 0 to (count of audioList - 1)
                set getObject to audioList's objectAtIndex_(myIndex)
                set matchChKey to getObject's valueForKey_("deviceName") as string
                --log "OK3"
                
                if matchChKey = deviceName then
                    set grabIndex to theIndexSet's indexSetWithIndex_(myIndex)
                    audioTable's selectRowIndexes_byExtendingSelection_(grabIndex, false) 
                    set grabbedInd to true
                    exit repeat
                end
            end
            
            --log "OK4"
            
            if not grabbedInd then
                set grabIndex to theIndexSet's indexSetWithIndex_(0)
                audioTable's selectRowIndexes_byExtendingSelection_(grabIndex, false) 
            end
            
            
            -- log audioList
            
            -- remember window size and position
            mainWindow's setFrameAutosaveName_("mainSizePos")
            
            set starLightDir to POSIX path of ((path to application support from user domain)) & ("StarLight/")
            set logoDir to POSIX path of ((path to application support from user domain)) & ("StarLight/Logos")
            set chDataPlist to POSIX path of ((path to application support from user domain)) & ("StarLight/channelData.plist")
            
            -- Insert code here to initialize your application before any files are opened 
            try
                do shell script "mkdir " & quoted form of starLightDir
            end try
            
            log starLightDir
            
            try
                do shell script "mkdir " & quoted form of logoDir
            end try
            
           
            
            tell current application's NSNotificationCenter's defaultCenter()
                addObserver_selector_name_object_(me, "handleNotification:", "loginNote", missing value)
                addObserver_selector_name_object_(me, "songUpdate:", "songUpdate", missing value)
                addObserver_selector_name_object_(me, "updateTheList:", "setChannels", missing value)
            end tell
            
            --property pNSWorkspace : current application's NSWorkspace's
            
            -- awake from sleep calls
            tell (current application's NSWorkspace's sharedWorkspace())'s notificationCenter()
                --addObserver_selector_name_object_(me, "screenDidWake", "NSWorkspaceScreensDidWakeNotification", missing value)
                addObserver_selector_name_object_(me, "computerDidWake", "NSWorkspaceDidWakeNotification", missing value)
                addObserver_selector_name_object_(me, "computerWillSleep", "NSWorkspaceWillSleepNotification", missing value)
                --addObserver_selector_name_object_(me, "screenDidSleep", "NSWorkspaceScreensDidSleepNotification", missing value)
            end tell
            
            --set tempChannelList to {}
            
            
            --try to login, also does autoplay in another thread / process
            getlogin()
            
            try
                set bigChannelList to (current application's class "NSMutableArray"'s alloc()'s initWithContentsOfFile_(chDataPlist))
                
                set my theList to bigChannelList
            end
            
            tell current application's class "NSUserDefaults" to set defaults to standardUserDefaults()
            
            if bigChannelList = missing value then
                tell defaults to setObject_forKey_("no MD5","channelMD5")
                log "no MD5"
                
                else
                
                set sB to 0
                
                tell defaults
                    set sB to valueForKey_("showStars")
                end tell
                
                --set sB to missing value
                -- used for debugging Purposes
                
                if sB ≠ missing value then
                    set state of starsButton to sB
                    else
                    set sB to 0
                    set state of starsButton to sB
                end if
                
                log "starsButton state = " & sB
                
                if sB ≠ missing value or sB = null then
                    if sB then
                        set starOn to current application's NSImage's imageNamed_("starOn")            
                        starsButton's setImage_(starOn)  
                        else
                        set starOff to current application's NSImage's imageNamed_("starOff")            
                        starsButton's setImage_(starOff)
                    end if
                    starSearch()
                end if
            end if
            
            
            -- set loginUser to "artdog90" as string
            -- set loginPass to "tincan" as string
            
            --log {loginUser, loginPass}
            
            --if loginUser ≠ "" or loginPass ≠ "" then
            --"attempt Login"
            
            --set loginURL to myProtocol & siriusDomain & loginPath
            
            -- set the Body for the POST text
            -- set loginBody to "<authenticationRequest><login>" & loginUser & "</login><consumerType>" & consumerType & "</consumerType><currency>" & theCurrency & "</currency><password>" & loginPass & "</password><subscriberType></subscriberType></authenticationRequest>"
            
            -- log "got to here"
            
            --pgURL_(loginURL, loginBody, postMethod, theLoginDelegate)
            
            
            --startChannelTimer()
            --set my theList to {{sirNo:"siriushits1", desc:"", displayName:"Loading Channels...", isAvailable:true, isMature:false, chName:"Please Wait", siriusChannelNo:"", xmChannelNo:""}}
            
            -- log "got to here2"
            
            myTable's setDoubleAction_("DoubleClickedAction")
            -- select table
            mainWindow's makeFirstResponder_(myTable)
            
            
            registerDefaults()
            createStarMenu()
            
            --statusMenu's removeAllItems()
            
            --  myTable's setAction_("ClickedAction")
        
        -- clear swfinfo cache
        try
            do shell script "rm ~/.swfinfo"
        end
        end awakeFromNib
        
        -- if there is a login error, show the drawer
        on openDrawer()
            loginDrawer's open_(me)
        end
        
        -- if successful, close the drawer
        on closeDrawer()
            loginDrawer's close_(me)
        end
        
        -- play button pressed
        on playButton_(sender)
            grabChannel()
        end
        
        -- shows and hides the login drawer
        on isLoginVisible_(sender)
            set x to loginDrawer's state as integer
            if x = 0 then
                loginDrawer's open_(me)
                else
                loginDrawer's close_(me)
            end
        end isLoginVisible_
        
        on stopMplayer()
            repeat 3 times
                try
                    myConnection's cancel()
                end
                
                try
                    tell myPlayr to terminate()
                end try
                
                tell class "ChannelLogos" of current application
                    set uslept to 25000
                    (usleep_(uslept)) --as string & " for " & uslept & " microseconds" --usleep
                end
            end
            
            if not shouldPlay and not loadInProgress then
                tell current application's NSNotificationCenter's defaultCenter()
                    postNotificationName_object_("songUpdate",{currentName:chName,artist:"Stopped.",song:"Stream Ended."})
                end
            end
            
        end
        
        on letsPlay_(chKey,chName)
            -- update Audio Device IDs
            tell class "ChannelXML" of current application
                set my audioList to loadOutputDevices()
            end
            
            -- Grab Audio Device Selection
            set audioSelection to my audioArray's selectedObjects
            set deviceID to deviceID of audioSelection as string
            set deviceName to deviceName of audioSelection as string
            
            tell current application's class "NSUserDefaults"
                set defaults to standardUserDefaults()
            end tell
            
            -- record last channel played
            try 
                tell defaults
                    setObject_forKey_(deviceName,"deviceName")
                    setObject_forKey_(chName,"lastChName")
                    setObject_forKey_(chKey,"lastChKey")
                end tell
            end try
            
            set downloadPath to POSIX path of ((path to application support from user domain)) & ("StarLight/Logos/" & chKey & ".png")
            
            tell current application's NSImage to set myLogoImage to (alloc()'s initByReferencingFile_(downloadPath))'s autorelease()
            
            logoView's setImage_(myLogoImage)
            
            --display dialog chName as string
            
            --display dialog myChannelKey as string
            --set my mySong to "TEST" as string
            
            if shouldPlay and loadInProgress then
                tell current application's NSNotificationCenter's defaultCenter()
                    postNotificationName_object_("songUpdate",{currentName:chname,artist:"Loading...",song:""})
                end tell
            end 
            
            set usePortEighty to tunnelHTTP's state as boolean
            
            log "usePortEighty = " & usePortEighty
            
            if usePortEighty ≠ missing value then 
                if usePortEighty then
                    set rtmp to "rtmpte://" as string
                    else
                    set rtmp to "rtmpe://" as string
                end if
                else
                set rtmp to "rtmpe://" as string
            end if
            
            if timeOutMenu ≠ missing value then
                set streamTimeOut to title of timeOutMenu 
            end
            
            set startVolume to outletVolume's floatValue() as real as string
        end letsPlay_
        
        -- get the channel info that is embeded in the Table data
        on grabChannel()
            if not loadInProgress and not sleepTight then
                set MyRow to (myTable's selectedRow as integer)
                if MyRow ≠ -1 then
                    set loadInProgress to true
                    -- tell progSpinner to startAnimation_(me)
                    set shouldPlay to false
                    -- try cancelling last call to the SXM
                    stopMplayer()
                    set mySelection to my channelArray's selectedObjects
                    set chKey to chKey of mySelection as string
                    set chName to chName of mySelection as string
                    --set shortDesc to shortDesc of mySelection as string
                    set sirNo to sirNo of mySelection as string
                    set chName to (sirNo & " " & chName)
                    
                    else
                    if chName = missing value or chKey = missing value then
                        tell current application's NSNotificationCenter's defaultCenter()
                            postNotificationName_object_("songUpdate",{currentName:"Channel is Blank",artist:"Wanna Play?",song:"Try selecting a channel 1st."})
                        end tell
                        set loadInProgress to false
                        return false
                        -- tell progSpinner to stopAnimation_(me)
                    end if
                end if
                
                -- if you made it this far, play
                set shouldPlay to true
                set shouldLoadChannels to false
                
                
                letsPlay_(chKey,chName)
                try
                    -- runPlayr_(loginInfo)
                    -- logins automatically then tries to get the channel URL
                    getLogin()
                    on error EM
                    set loadInProgress to false
                    log EM
                end try
            end if     
        end grabChannel
        
        
        on showStarMenu_(sender)
            statusItemController's showMenu()
        end
        
        on DoubleClickedAction()
            --log starsList
            
            tell mySpinner to startAnimation_(me)
            statusItemController's updateAnimation_(3)
            
            set myCol to (myTable's clickedColumn as integer)
            set myRow to (myTable's clickedRow as integer)
            
            if myCol ≠ -1 and myRow ≠ -1 then
                -- check if blanks Stars was double clicked
                if state of starsButton as integer = 1 and (count of starsList = 0) then
                    return
                end
                
                if bigChannelList ≠ missing value then
                    set myCol to (myTable's clickedColumn as integer)
                    set myRow to (myTable's clickedRow as integer)
                    
                    -- check and make sure the stars Column was not double clicked
                    -- if it was, then simply ignore it
                    
                    set clickedID to (identifier of item (myCol +1) of myTable's tableColumns) as text 
                    set starsID to (identifier of starsColumn) as text
                    
                    -- log "clickedID:" & clickedID
                    -- log "starsID:" & starsID
                    
                    --error number -128
                    if (clickedID ≠ starsID) then
                        -- get's SWF's filename
                        grabChannel()
                    end if
                end if
            end
        end DoubleClickedAction
        
        on setVol_(sender)
            set myVol to floatValue() of sender
            if myPlayr ≠ missing value then
                set userinput to ("set volume ") & (myVol as real as string) & linefeed
                set userinput to current application's class "NSString"'s stringWithString_(userinput)
                set myData to userinput's dataUsingEncoding_allowLossyConversion_(current application's NSMacOSRomanStringEncoding, true)
                writeHandle's writeData_(myData)
            end if
        end setVol_
        
        on setStop_(sender)
            set loadInProgress to false
            --tell progSpinner to stopAnimation_(me)
            set shouldPlay to false
            stopMplayer()
        end setStop_
        
        --on textDidEndEditing_(aNotification)
        --    log aNotification 
        --    display alert "helloworld"
        --end
        
        on siriusLogin_(sender)
            set shouldLoadChannels to true
            
            if not sleepTight then
                getLogin()
            end
        end
        
        on updateTheList_(pNotification)
            -- as list makes it mutable (otherwise it is immutable (readonly))
            
            set bigChannelList to (object of pNotification)
            
            --set bigChannelList to (current application's class "NSMutableArray"'s alloc()'s initWithContentsOfFile_(chDataPlist))
            
            tell class "NSMutableArray" of current application
                set my theList to arrayWithArray_(bigChannelList)
            end
            
        end updateTheList_
        
        on songUpdate_(pNotification)
            tell channelField 
                setStringValue_(currentName of object of pNotification as text)
                --display()
            end
            
            tell artistField 
                setStringValue_(artist of object of pNotification as text)
                --display()
            end
            
            tell songField 
                setStringValue_(song of object of pNotification as text)
                --display()
            end
            
            --tell mainWindow
            --    display()
            --end
            
            if (artist of object of pNotification) as string starts with "Playing..." or (artist of object of pNotification) as string starts with "Stopped." then
                tell mySpinner to stopAnimation_(me)
                statusItemController's updateAnimation_(1)
            end
            --tell mySpinner to stopAnimation_(me)
            set pNotification to missing value
        end
        
        on playStation(chKey,chName)
            if chKey ≠ "missing value" and chName ≠ "missing value" then
                set loadInProgress to true
                -- tell progSpinner to startAnimation_(me)
                set shouldPlay to false
                -- try cancelling last call to the SXM
                stopMplayer()
                set shouldPlay to true
                set shouldLoadChannels to false
                
                tell mySpinner to startAnimation_(me)
                statusItemController's updateAnimation_(3)
                
                set grabbedInd to false
                repeat with myIndex from 0 to (count of theList - 1)
                    set getObject to theList's objectAtIndex_(myIndex)
                    set matchChKey to getObject's valueForKey_("chKey") as string
                    if matchChKey = chKey then
                        set grabIndex to theIndexSet's indexSetWithIndex_(myIndex)
                        myTable's selectRowIndexes_byExtendingSelection_(grabIndex, false) 
                        set grabbedInd to true
                        exit repeat
                    end
                end
                
                if not grabbedInd then
                    myTable's deselectAll_(me)
                    -- if nothing is selected, select the first station
                    --set grabIndex to theIndexSet's indexSetWithIndex_(0)
                    --myTable's selectRowIndexes_byExtendingSelection_(grabIndex, false) 
                end
                
                --autoplay
                letsPlay_(chKey,chName)
                
                try
                    -- runPlayr_(loginInfo)
                    -- logins automatically then tries to get the channel URL
                    getLogin()
                    on error EM
                    set loadInProgress to false
                    log EM
                end
                -- else
                --tell mySpinner to stopAnimation_(me)
            end if
        end playStation_
        
        on handleNotification_(pNotification)
            --this will block the thread, so what we do is let the app do stuff then show delay
            if (channel of object of pNotification) as string starts with "Channel" then
                tell current application's class "NSUserDefaults"
                    set defaults to standardUserDefaults()
                end tell
                
                try
                    tell defaults
                        set chKey to valueForKey_("lastChKey") as string
                        set chName to valueForKey_("lastChName") as string
                    end tell
                end try
                
                playStation(chKey,chName)
                
                --else
                --tell mySpinner to stopAnimation_(me)
                
                -- theList is an NSMutableArray.  It is easier to leave it in this form
                -- if we convert it to a list, it can cause overflow errors in AppleScript
                -- this may be converted to ObjectiveC to reduce overhead
                --set loadInProgress to false
            end
            
            if (channel of object of pNotification) as string contains "Channels updated" then
                set state of starsButton to 0
                set starOff to current application's NSImage's imageNamed_("starOff")            
                starsButton's setImage_(starOff)
            end
            
            if (channel of object of pNotification) as string contains "Error" then
                set loadInProgress to false
                -- tell progSpinner to stopAnimation_(me)
                
            end
            
            if (channel of object of pNotification) as string starts with "Login Error" then
                openDrawer()
            end
            
            if (channel of object of pNotification) as string starts with "Success" then
                closeDrawer()
            end
            
            --if (artist of object of pNotification) as string does not start with "Loading..." then
            tell channelField 
                setStringValue_(channel of object of pNotification)
                display()
            end
            --end
            
            tell artistField 
                setStringValue_(artist of object of pNotification)
                display()
            end
            
            tell songField 
                setStringValue_(song of object of pNotification)
                display()
            end
            
            if (channel of object of pNotification) as string starts with "Reconnecting..." or (channel of object of pNotification) as string starts with "Network Error:"   then
                startChannelTimer()
            end
            
        end
        
        on shouldReconnect()
            --display alert "autoPlay activated."
            -- reconnect to stream if it lost connection
            if not sleepTight then
                tell current application's class "NSUserDefaults" to set defaults to standardUserDefaults()
                
                try
                    tell defaults
                        set chKey to valueForKey_("lastChKey") as string
                        set chName to valueForKey_("lastChName") as string
                    end tell
                end try
                
                if chKey ≠ missing value and chName ≠ missing value then
                    letsPlay_(chKey,chName)
                    set shouldLoadChannels to false
                    getLogin()
                end if
            end if
        end
        
        on readPipe_(aNotification)
            --log "Pipe In"
            
            if myPlayr ≠ missing value then
                
                set newstring to ((current application's class "NSString")'s alloc)'s initWithData_encoding_(aNotification's userInfo's valueForKey_("NSFileHandleNotificationDataItem"), myEncoding) as text as string
                
                --set newstring to newstring as string
                
                if newstring contains "xml" then
                    set streamTitle to offset of "TTL=" in newstring
                    set streamArtist to offset of "ART=" in newstring
                    set streamAlbum to offset of "ALB=" in newstring
                    --log myTitle
                    set textArtist to text (streamArtist + 5) thru (streamAlbum - 3) of newstring
                    set textTitle to text (streamTitle + 5) thru (streamArtist - 3) of newstring
                    
                    -- update UI with artist and song info
                    tell current application's NSNotificationCenter's defaultCenter()
                        postNotificationName_object_("songUpdate",{currentName:chName,artist:textArtist,song:textTitle})
                    end
                    else  if newstring contains "STREAM: Comment:" then
                    -- set loadInProgress to false
                    tell current application's NSNotificationCenter's defaultCenter()
                        postNotificationName_object_("loginNote",{channel:chName,artist:"Buffering...",song:""})
                    end
                    set loadInProgress to false
                    else  if newstring contains "Starting Playback" then
                    -- set loadInProgress to false
                    tell current application's NSNotificationCenter's defaultCenter()
                        postNotificationName_object_("songUpdate",{currentName:chName,artist:"Playing...",song:""})
                    end
                    set loadInProgress to false
                    else if newstring contains "RTMP_ReadPacket, failed to read RTMP packet header" then --or newstring contains "Cannot seek backward in linear streams!" then 
                    log "involfailed: " & newstring
                    stopMplayer()
                    set aNotification to missing value
                    set newstring to missing value
                    return
                    else if newstring contains "error" then
                    log "involerror: " & newstring
                    
                    -- clear swf cache
                    try
                        do shell script "rm ~/.swfinfo"
                    end
                    else if newstring contains "quit" then
                    log "involquit: " & newstring
                    else if newstring contains "exit" then
                    log "involexit: " & newstring
                    else if newstring contains "cancel" then
                    log "involcancel: " & newstring
                    stopMplayer()
                    set aNotification to missing value
                    set newstring to missing value
                    return
                    else if newstring contains "delete" then 
                    log newstring
                    --stopMplayer()
                    --else if newstring contains "FLV" then
                    
                     --322222else
                     --log newstring
                end if
                
                -- had to add another read-in-background, to get the next message, then the next message...
                if readHandle ≠ missing value then
                    tell readHandle
                        readInBackgroundAndNotify()
                    end tell
                end if
                
                set aNotification to missing value
                set newstring to missing value
                --NotifyField's setString_(newstring)
            end if
            
        end readPipe_
        
        on endPipe_(aNotification)
            log "pipe ended."
            if not loadInProgress then
                tell current application's NSNotificationCenter's defaultCenter()
                    postNotificationName_object_("songUpdate",{currentName:chName,artist:"Stopped.",song:"Stream Ended."})
                    --tell mySpinner to stopAnimation_(me)
                end
            end
            set myPlayr to missing value
            
            if not sleepTight then
                if not loadinProgress and shouldPlay then
                    --display alert "autoPlay activated."
                    
                    tell current application's class "NSUserDefaults" to set defaults to standardUserDefaults()
                    
                    try
                        tell defaults
                            set chKey to valueForKey_("lastChKey") as string
                            set chName to valueForKey_("lastChName") as string
                        end tell
                    end try
                    
                    if chKey ≠ missing value and chName ≠ missing value then
                        tell current application's NSNotificationCenter's defaultCenter()
                            postNotificationName_object_("loginNote",{channel:"Reconnecting...",artist:"",song:""})
                        end tell
                    end if
                end if
            end if
            
        end endPipe_
        
        on applicationWillFinishLaunching_(aNotification)
            mainWindow's makeKeyAndOrderFront_(mainWindow)
        end applicationWillFinishLaunching_
        
        on applicationShouldTerminate_(sender)
            
            set starState to starsButton's state as boolean
            
            if not starState then
                my theList's writeToFile_atomically_(chDataPlist, true)
                else
                bigChannelList's writeToFile_atomically_(chDataPlist, true)
            end
            
            set loadInProgress to false
            
            set shouldPlay to false
            stopMplayer()
            
            if myPlayr ≠ missing value then
                tell myPlayr to terminate()
            end
            
            set sB to state of starsButton as integer
            
            tell current application's class "NSUserDefaults"
                set defaults to standardUserDefaults()
            end tell
            
            tell defaults to setObject_forKey_(sB as boolean,"showStars")
            
            -- Insert code here to do any housekeeping before your application quits 
            return current application's NSTerminateNow
        end applicationShouldTerminate_
        
        on screenDidWake()
            --display alert "The screen has awoken."
        end screenDidWake
        
        on computerDidWake()
            --tell class "ChannelLogos" of current application
            --    set uslept to 1000000
            --    (usleep_(uslept)) --as string & " for " & uslept & " microseconds" --usleep
            --end
            
            set sleepTight to false
            
            if shouldPlay and not loadInProgress then
                shouldReconnect()
            end
            
            --display alert "The computer has awoken."
        end computerDidWake
        
        on computerWillSleep()
            
            set sleepTight to true
            --set shouldPlay to false
            stopMplayer()
            --display alert "The computer will sleep."
        end computerWillSleep
        
        on screenDidSleep()
            --display alert "The screen did sleep."
        end screenDidSleep
    end script