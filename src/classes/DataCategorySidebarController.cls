public with sharing class DataCategorySidebarController {

	wrapper wrap;

	public DataCategorySidebarController() {
		wrap = new wrapper();
	}

	public String getSidebarData(){
	 getDescribeDataCategoryGroupStructureResults();
	 
	 //extract value of 'All' i.e. first child
	 return JSON.serialize(wrap.children[0].children); 
	}

	public List<DescribeDataCategoryGroupStructureResult> 
	getDescribeDataCategoryGroupStructureResults(){
	  List<DescribeDataCategoryGroupResult> describeCategoryResult;
	  List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
	  try {
	     //Making the call to the describeDataCategoryGroups to
	     //get the list of category groups associated
	     List<String> objType = new List<String>();
	     objType.add('KnowledgeArticleVersion');
	     describeCategoryResult = Schema.describeDataCategoryGroups(objType);
	     
	     //Creating a list of pair objects to use as a parameter
	     //for the describe call
	     List<DataCategoryGroupSobjectTypePair> pairs = 
	        new List<DataCategoryGroupSobjectTypePair>();
	     
	     //Looping throught the first describe result to create
	     //the list of pairs for the second describe call
	     for(DescribeDataCategoryGroupResult singleResult : 
	     describeCategoryResult){
	        DataCategoryGroupSobjectTypePair p =
	           new DataCategoryGroupSobjectTypePair();
	        p.setSobject(singleResult.getSobject());
	        p.setDataCategoryGroupName(singleResult.getName());
	        pairs.add(p);
	     }
	     
	     //describeDataCategoryGroupStructures()
	     describeCategoryStructureResult = 
	        Schema.describeDataCategoryGroupStructures(pairs, false);

	     //Getting data from the result
	     for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
	        //Get name of the associated Sobject
	        singleResult.getSobject();

	        //Get the name of the data category group
	        singleResult.getName();

	        //Get the name of the data category group
	        singleResult.getLabel();

	        //Get the description of the data category group
	        singleResult.getDescription();

	        //Get the top level categories
	        DataCategory [] toplevelCategories = 
	           singleResult.getTopCategories();
	        
	        //Recursively get all the categories
	        List<DataCategory> allCategories = 
	           getAllCategories(toplevelCategories);

	        //take out 'All' category from allcategories for better processing
	        List<DataCategory> categoryToIterate = new List<DataCategory>();

	        for(DataCategory category: allCategories){
	           if(category.getName().equalsIgnoreCase('All')){
	              categoryToIterate.add(category);
	           }
	        }
	        
	        displayCategories(categoryToIterate, '', new Node());

	        
	     }
	  } catch (Exception e){
	  }
	  return describeCategoryStructureResult;
	}

	private void displayCategories(List<DataCategory> allCategories, String parentName, Node node){
	 for(DataCategory category : allCategories) {
	   
	   Node nd = new Node();
	   nd.label = category.getLabel();
	   
	   if(node.label != null){
	     node.children.add(nd);
	   }else{
	     wrap.children.add(nd);
	   }

	   System.debug(category.getName() +' - '+ parentName);
	  
	   DataCategory[] childs = category.getChildCategories();
	   if(!childs.isEmpty()){
	     displayCategories(childs, category.getName(), nd);
	   }
	   
	 }
	}

	private DataCategory[] getAllCategories(DataCategory [] categories){
	  if(categories.isEmpty()){
	     return new DataCategory[]{};
	  } else {
	     DataCategory [] categoriesClone = categories.clone();
	     DataCategory category = categoriesClone[0];
	     DataCategory[] allCategories = new DataCategory[]{category};
	     categoriesClone.remove(0);
	     categoriesClone.addAll(category.getChildCategories());
	     allCategories.addAll(getAllCategories(categoriesClone));
	     return allCategories;
	  }
	}


	/************************************************************************************
	********************************* WRAPPERS *********************************************
	***************************************************************************************/
	public class wrapper{
        List<node> children;
        public wrapper(){
          children = new List<node>();
      }
    }
    
    
    public class node{
        String label;
        List<node> children;
        public node(){
          children = new List<node>();
        }
    }

}