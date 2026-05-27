public class ProjectTaskController {

    public static String sayHello(String name) {
        return 'Hello, ' + name;
    }
    
    public List<ProjectTask__c> getAllTaskDetails(){
	List<ProjectTask__c> tasksList = new List<ProjectTask__c>();
	tasksList = [Select ID, Name From ProjectTask__c];
        
        for(ProjectTask__c task:tasksList){
            system.debug(task.name);
        }
        
        return tasksList;        
    }

}