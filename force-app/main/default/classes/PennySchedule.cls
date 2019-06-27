global class PennySchedule Implements Schedulable 
{
    //System.schedule('Penny Cache Refresh', '0 0 * * * ?', new PennySchedule());
    
    /*
System.schedule('Penny AutoActivate 0', '0 0 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 5', '0 5 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 10', '0 10 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 15', '0 15 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 20', '0 20 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 25', '0 25 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 30', '0 30 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 35', '0 35 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 40', '0 40 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 45', '0 45 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 50', '0 50 * * * ?', new PennySchedule());
System.schedule('Penny AutoActivate 55', '0 55 * * * ?', new PennySchedule());
*/
    
    global void execute(SchedulableContext sc)
    {
        //PennyHelper.UpsertCache();
        PennyHelper.AutoActivate();
    }
}