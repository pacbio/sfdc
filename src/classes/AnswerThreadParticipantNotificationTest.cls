public class AnswerThreadParticipantNotificationTest
{

    static testMethod void testQuestionInsertAndUpdate()
    {
    

    Question qstn = [select id from Question limit 1];
     Reply testReply = new Reply(body='Test Reply',QuestionId=qstn.ID);
     insert testReply;
       
     testReply.body='Test Reply Body';
     update testReply;

     // Verify that the billingState field was updated in the database.
     Reply updatedReply = [SELECT body FROM Reply WHERE Id = :testReply.Id];
     System.assertEquals('Test Reply Body', updatedReply.body);
    }
}