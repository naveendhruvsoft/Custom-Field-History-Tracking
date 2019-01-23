public class fieldHistoryTrackingHandler {
    
    public static void trackme(map<Id,sObject>oldMap,map<Id,sObject>newMap){
        list<string> TrackingFieldsList = new list<string>();
        String LookupfieldtoFTH = 'Naveen Test Lookup';
        list<Field_History_Tracking__c> fhTrackingList= new list<Field_History_Tracking__c>();
        
        Schema.SObjectType sObjectType = newMap.getSObjectType();
        map<string,list<string>> TrackingFieldsMap = fieldHistoryTrackingHandler.fetchTrackingFieldsMap(sObjectType);
        
        if(!TrackingFieldsMap.isEmpty() ) {
            
            for(string lookupfield:TrackingFieldsMap.keyset()){
                LookupfieldtoFTH = lookupfield;
                TrackingFieldsList = TrackingFieldsMap.get(lookupfield);
            }
            
            for(Id recordId: newMap.keyset()){
                system.debug('New Rec'+newMap.get(recordId));
                if(oldMap.containsKey(recordId)){
                    system.debug('Old Rec'+oldMap.get(recordId));
                    for(String sObjectField: TrackingFieldsList){
                        
                        String newValue = newMap.get(recordId).get(sObjectField)!=NULL?string.valueOf(newMap.get(recordId).get(sObjectField)):NULL;
                        String oldValue = oldMap.get(recordId).get(sObjectField)!=NULL?string.valueOf(oldMap.get(recordId).get(sObjectField)):NULL;
                        
                        system.debug('----newValue----'+newValue);
                        system.debug('----oldValue----'+oldValue);
                        system.debug('----if(oldValue != newValue)----'+(oldValue != newValue));
                        
                        if(oldValue != newValue){
                            
                            String sObjectFieldLabel = sObjectType.getDescribe().fields.getMap().get(sObjectField).getDescribe().getLabel();
                            system.debug(userinfo.getName()+' changed '+sObjectFieldLabel+' value from '+oldMap.get(recordId).get(sObjectField)+' to '+newMap.get(recordId).get(sObjectField));
                            
                            Field_History_Tracking__c fhtRecord= new Field_History_Tracking__c(New_Value__c=newValue, Old_Value__c=oldValue, Updated_Field__c=sObjectFieldLabel );
                            fhtRecord.put(LookupfieldtoFTH,recordId);
                            fhTrackingList.add(fhtRecord);
                            
                        } 
                    }          
                }
                
            }
            
            if(!fhTrackingList.isEmpty()) insert fhTrackingList;
        }
        else{
            system.debug('Mapping is not found to Tracking field History!!');
        }
    }
    
    public static map<string,list<string>> fetchTrackingFieldsMap(Schema.SObjectType sObjectAPI){
        String sObjectStr=string.valueOf(sObjectAPI);
        map<string,list<string>> sObjectTrackingFieldsMap = new map<string,list<string>>();
        Field_History_Tracking_Config__mdt trackingConfig = new Field_History_Tracking_Config__mdt();
        try{
            
            trackingConfig=[SELECT DeveloperName,Lookup_Field__c,Tracking_Fields__c FROM Field_History_Tracking_Config__mdt where DeveloperName=:sObjectStr LIMIT 1];
            sObjectTrackingFieldsMap = validateSobjectFields(sObjectStr,trackingConfig.Lookup_Field__c, trackingConfig.Tracking_Fields__c.split(','));
        }
        catch(exception e){
            system.debug('exception occured---------'+e);
        }
        
        return sObjectTrackingFieldsMap;
    }
    
    public static map<string,list<string>> validateSobjectFields(String sObjectAPI, String lookupField, list<string>trackingfieldsList){
        system.debug('------sObjectAPI----'+sObjectAPI+'----lookupField---------'+lookupField+'--------trackingfieldsList---------'+trackingfieldsList);
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectAPI).getDescribe().fields.getMap();
        map<string,list<string>> sObjectTrackingFieldsMapTemp = new map<string,list<string>>();
        system.debug('------fieldMapkes----'+fieldMap.keyset());
        
        lookupField=lookupField.toLowerCase();
        Map<String, Schema.SObjectField> fhtObjectfieldMap = Schema.SObjectType.Field_History_Tracking__c.fields.getMap();
        if(fhtObjectfieldMap.containskey(lookupField)){
            
            sObjectTrackingFieldsMapTemp.put(lookupField,new list<string>());
            
            for(String fieldStr : trackingfieldsList){
                String fieldStrtoLowerCase = fieldStr.toLowerCase();
                if(fieldMap.containskey(fieldStrtoLowerCase) ){
                    sObjectTrackingFieldsMapTemp.get(lookupField).add(fieldStrtoLowerCase);
                }
                else{
                    system.debug(sObjectAPI+' does not have the '+fieldStrtoLowerCase+' to track the field History.');
                }
                
            }
        }
        else{
            system.debug('Field History Tracking object does not have the Lookup field'+lookupField+'. So please create a lookup field on Field History Tracking to track the history.');
        }
        
        system.debug('----sObjectTrackingFieldsMapTemp-----'+sObjectTrackingFieldsMapTemp);
        
        return sObjectTrackingFieldsMapTemp;
    }
    
}