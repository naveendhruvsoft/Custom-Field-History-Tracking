trigger AccountTrigger on Account (after update) {
   
   // This is an example trigger to use this feature
   
   fieldHistoryTrackingHandler.trackme(trigger.oldMap,trigger.newMap);
}
