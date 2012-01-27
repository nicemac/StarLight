script channels
    property channelData : missing value
    
    on connection_didReceiveResponse_(myConnection, response)
        log "OK"
        -- reset values for the data
        -- clear out any previous data stored to prevent overflow
        
        -- set it up to accept NSMutableData
        set tempChannelList to {}
        set channelData to current application's class "NSMutableData"'s (alloc()'s init)'s autorelease()
        
        -- set the length to zero
        channelData's setLength_(0)
        
        tell class "NSHTTPURLResponse" of current application
            set statusText to (localizedStringForStatusCode_(statusCode of response)) as text
            set statusCode to (statusCode of response) as string
        end
        
        -- if it fails to do anything, show what it didn't do here (the error)
        if statustext = "no error" then
            else
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:("HTTP Error: "),artist:("Err: " & statusText & "."),song:""})
            end
        end
    end
    
    on connection_didReceiveData_(myConnection, myLocalData)
        channelData's appendData_(myLocalData)
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
    end
    
    on connectionDidFinishLoading_(myConnection)
        tell current application's class "NSUserDefaults" to set defaults to standardUserDefaults()
        
        try
            tell defaults to set oldMD5 to objectForKey_("channelMD5")
            on error EM
            set oldMD5 to "prevMD5"
            log EM
        end try
        
        --log "oldMD5: " & oldMD5
        
        tell class "StarLightAppDelegate" of current application
            set myUserInfo to getLoginUser()
            set myUserInfo to myUserInfo as list
            set loginUser to item 1 of myUserInfo
            set loginPass to item 2 of myUserInfo
        end
        
        -- the MD5 file that is used contains the username, password and channel data
        -- if a user logins in with another username, it will update the channel list
        -- if the user adds " kids" to the password it will update the list and omit adult channels
        set md5text to loginUser & loginPass & (((current application's class "NSString")'s alloc)'s initWithData_encoding_(channelData, NSUTF8StringEncoding of current application))'s autorelease() as string
        
        set md5text to current application's class "NSString"'s stringWithString_(md5text)
        
        set md5data to md5text's dataUsingEncoding_(NSUTF8StringEncoding of current application)
        
        try
            tell class "HashValue" of current application
                set newMD5 to description of md5HashWithData_(md5data)
            end
            on error 
            set newMD5 to "newMD5"
        end
        
        -- clear temp variables
        set md5text to null
        set md5data to null
        
        -- log myText
        
        --try
        --    set newMD5 to (do shell script "/sbin/md5 -qs StarLight" & quoted form of myText)
        --    on error
        --    set newMD5 to "newMD5"
        -- end try
        
        tell defaults to setObject_forKey_(newMD5,"channelMD5")
        --log "newMD5: " & newMD5
        
        -- convert Data returned to String (Don't ever forget how to do this, it is a pain when do forget)
        -- set channelMsg to (((current application's class "NSString")'s alloc)'s initWithData_encoding_(channelData, current application's NSUTF8StringEncoding)) as string
        
        --[[NSXMLDocument alloc] initWithData:responseData options:NSXMLDocumentTidyHTML error:&error];
        
        -- for testing
        -- set oldMD5 to "2"
        -- set newMD5 to "1"
        
        log "oldmd5 = " & oldMD5
        log "newMD5 = " & newmd5
        
        tell class "StarLightAppDelegate" of current application
            try
            set loginInfo to getLoginInfo()
            on error errMsg
                log errMsg
                set loginInfo to {subscriberType:"SIRIUS_SUBSCRIBER"}
            end
            
            try
            set allowAdultContent to getAdultContent()
            on error errMsg
                log errMsg
                set allowAdultContent to true
            end
            
            try
            set chDataPlist to getChDataPlist()
                on error errMsg
                log errMsg
                set chDataPlist to POSIX path of ((path to application support from user domain)) & ("StarLight/channelData.plist")
            end
        end
        
        if oldMD5 as string ≠ newMD5 as string then             
            if subscriberType of loginInfo as string = "SIRIUS_SUBSCRIBER" then
                set sirSub to true
                else
                set sirSub to false
            end
            
            log subscriberType of loginInfo
            log allowAdultContent
            
            log "Parsing new channel list."
            
            set myStars to {}
            
            tell class "StarLightAppDelegate" of current application
                set myStars to getStars()
            end
                        
            tell class "ChannelXML" of current application
                set tempChannelList to channelXML_starsList_subscriber_adult_(channelData, myStars, sirSub, allowAdultContent)
            end
            
            --download channel Logos
            log "Updating Channel Logos."
            
            set appSupport to POSIX path of ((path to application support from user domain))
            tell class "ChannelLogos" of current application
                getLogos_appSupport_(tempChannelList,appSupport)
                log "Downloading logos now."
            end
            
            --log myList
            tempChannelList's writeToFile_atomically_(chDataPlist, true)
            
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("setChannels",tempchannelList)
            end
            log "channels have been updated."
            
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:"Channels updated.",artist:"",song:""})
            end
            else
            log "no channel update needed."
            tell current application's NSNotificationCenter's defaultCenter()
                postNotificationName_object_("loginNote",{channel:"Channels are up-to-date.",artist:"",song:""})
            end
            
            --set tempChannelList to {}
        end if
    end connectionDidFinishLoading_
    
end script

