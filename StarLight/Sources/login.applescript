script login
    property loginData : null
    
	on connection_didReceiveResponse_(myConnection, response) 
        -- setup the data
        -- log "HELLO"
        
        -- prevent data overflow
        set loginData to missing value
        
        -- setup NSMutableData 
        set loginData to current application's class "NSMutableData"'s (alloc()'s init())'s autorelease()
        
        -- set the length to zero
        loginData's setLength_(0)
        
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
        -- appendData as data
        loginData's appendData_(myData) 
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
        -- log loginData
        set loginMsg to (((current application's class "NSString")'s alloc)'s initWithData_encoding_(loginData, current application's NSUTF8StringEncoding))'s autorelease() as string
        
        set loginData to missing value
        
        if loginMsg contains "authenticationResponse" then
            --log loginMsg
            
            tell class "XMLReader" of current application
                -- + (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
                set myXML to dictionaryForXMLString_error_(loginMsg as string, missing value)
            end
            
            set theResponse to (value of code of messages of authenticationResponse of myXML) as integer
            log theResponse
            
            if theResponse = 100 then
                tell class "StarLightAppDelegate" of current application
                    try
                        set shouldLoadChannels to getShouldLoadChannels()
                        on error
                        set shouldLoadChannels to true
                    end
                    
                    try
                        set shouldPlay to getShouldPlay() as boolean
                        on error
                        set shouldPlay to false
                    end
                end
                
                log "shouldLoadChannels = " & shouldLoadChannels
                log "shouldPlay = " & shouldPlay
                
                --set loginNote to {"Login Success!", "Checking Channels...", "", 1}
                --set tempChannelList to {}
                
                set loginInfo to setLoginInfo_(loginMsg,myXML)
                
                tell current application's NSNotificationCenter's defaultCenter()
                    if shouldLoadChannels then
                        postNotificationName_object_("loginNote",{channel:"Success!",artist:"",song:""})
                        else if shouldPlay then
                        
                        tell current application's class "NSUserDefaults" to set defaults to standardUserDefaults()
                        
                        try
                            tell defaults
                                set chName to objectForKey_("lastChName")
                            end tell
                        end try
            
                        postNotificationName_object_("loginNote",{channel:chName,artist:"Loading...",song:""})
                    end
                end
                
                --log loginInfo
                
                tell class "StarLightAppDelegate" of current application
                    if shouldLoadChannels as boolean then
                        loadChannels_(loginInfo)
                        else if shouldPlay then
                        runPlayr_(loginInfo)
                    end
                end
                
                else if theResponse = 300 then
                --set tempChannelList to {}

                tell current application's NSNotificationCenter's defaultCenter()
                    postNotificationName_object_("loginNote",{channel:"Login Error:",artist:"username or password",song:"is incorrect. Please try again."})
                end
                
                else if loginMsg contains "faultResponse" then
                -- <?xml version="1.0" encoding="UTF-8" standalone="yes"?><faultResponse><messages><code>401</code><message>Unauthorized</message></messages><status>0</status></faultResponse>
            end
        end
    end
    
    on setLoginInfo_(loginMsg, myXML)
        -- log myXML
        
        set authResponse to (value of code of  messages of  authenticationResponse of myXML) as integer
        set theStatus to (value of status of  authenticationResponse of myXML) as integer
        set myMessages to (value of message of messages of authenticationResponse of myXML) as string
        set mySessionID to (value of sessionId of authenticationResponse of myXML) as string
        set myTimeStamp to (value of timestamp of authenticationResponse of myXML) as string
        --set myPresets to value of presets of userInfo of authenticationResponse of myXML
        set myStatus to (value of status of userInfo of authenticationResponse of myXML) as string
        set channelLineupId to (value of channelLineupId of account of userInfo of  authenticationResponse of myXML) as integer
        
        try
            
            set subscriberType to (value of subscriberType of account of userInfo of authenticationResponse of myXML) as string
            on error
            set subscriberType to "SIRIUS_SUBSCRIBER"
        end
        
        tell me            -- Create a simple list for the login info
            set loginInfo to {authResponse: authResponse, theStatus: theStatus, myMessages: myMessages, mySessionID: mySessionID, myTimeStamp: myTimeStamp, myStatus: myStatus, channelLineupId: channelLineupId, subscriberType: subscriberType} as record
            
            --log loginInfo
            --set loginNote to {"Login Success!", "Loaded Info...", "", 2}
            log "login done."
            
            return loginInfo
        end 
    end
end script