global with sharing class PennySchedule Implements Schedulable 
{
    //System.schedule('Penny Cache Refresh', '0 0 * * * ?', new PennySchedule());

    global void execute(SchedulableContext sc)
    {
        PennyHelper.UpsertCache();
    }
}