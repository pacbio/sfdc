public class AnswerThreadNotificationTest
{
    static testMethod void testQuestionInsertAndUpdate()
    {
    

Community cmty = [select id from Community limit 1];
     Question testQuestion = new Question(title='Test Question',CommunityId=cmty.ID);
     insert testQuestion;
       
     testQuestion.body='Test Question Body';
     update testQuestion;

     // Verify that the billingState field was updated in the database.
     Question updatedQuestion = [SELECT body FROM Question WHERE Id = :testQuestion.Id];
     System.assertEquals('Test Question Body', updatedQuestion.body);
    }
}