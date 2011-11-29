trigger AnswerThreadNotification on Question (after insert) 
{      
    //do a deeper query of all question objects in the trigger array
    Map<ID, Question> mQuestion = new Map<ID,Question>([
        select
            ID,
            CreatedById, 
            LastReplyId,
            LastModifiedById,
            CommunityId,
            NumReplies,
            BestReplyId,
            Body, 
            Title  
        from 
            Question 
        where 
            Id IN :Trigger.newMap.keySet()]);
   
    //loop through the questions        
    for(Question qstn: mQuestion.values())
    {
        String body;
        String title = qstn.Title;
        
        if(qstn.Title.length() > 100)
        {
            title = title.substring(0,100);
        } 
        
        //using map here to automatically purge any dupes
        Map<ID,User> mUser = new Map<ID,User>();
        List<String>addressToList = new List<String>();
    
        // ensure the entry creator and modifier ids are on the
        // user id list used to find email addresses for notification 
        if(qstn.CreatedById != null)
        {
            mUser.put(qstn.CreatedById,null);
        }
        if(qstn.LastModifiedById != null && qstn.LastModifiedById != qstn.CreatedById)
        {
            mUser.put(qstn.LastModifiedById,null);
        }
              
        body = 'Your new discussion topic was posted in PacBio Discussions:'
        +'\n\nOriginal Post Title:'
        +'\n'
        +title           
        +'\n\nYou will receive an email if someone else comments.'
        +'\n\nView or Reply to the Original Post at this web address: ' 
        +'\n\nhttps://login.salesforce.com/answers/viewQuestion.apexp?id='+qstn.ID;
       // +'\n\nrefid:'
       // +qstn.ID           
       // +':refid:';

        title = 'PacBio Discussion: ' + title;
        

        mUser = new Map<Id, User>([SELECT ID, FirstName, LastName,Email FROM User WHERE ID in:mUser.keySet()]);                                  

        if(mUser.size() < 1)
        {
            System.debug('AnswerThreadNotification: mUser map was empty after querying User table with this set of ids: ');
            for(ID uid : mUser.keySet())
            {
                System.debug('AnswerThreadNotification: user id: ' + uid);
            }
            continue;
        }
        
        System.debug('AnswerThreadNotification: query of reply userids count: ' + mUser.size());
         
        for(User quser: mUser.values())
        {
            if(quser.email == null)
            {
                System.debug('AnswerThreadParticipantNotification: user email was null for user id: ' + quser.id);
                continue;
            }
            addressToList.add(quser.email);
        }
        
        if(addressToList.size() < 1)
        {
            System.debug('AnswerThreadParticipantNotification: email address list was empty so skipping mail');
            continue;
        }
        
        //send one email only to all creators or modififiers
        //of the given Question in this loop iteration
        EmailHandler eh = new EmailHandler(); 
        User uReply = mUser.get(qstn.CreatedById);   
        eh.sendMail(addressToList,'no-reply@pacificbiosciences.com',title,body);                                         
    }
}