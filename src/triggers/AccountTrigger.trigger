trigger AccountTrigger on Account (after update) {

   fieldHistoryTrackingHandler.trackme(trigger.oldMap,trigger.newMap);
}