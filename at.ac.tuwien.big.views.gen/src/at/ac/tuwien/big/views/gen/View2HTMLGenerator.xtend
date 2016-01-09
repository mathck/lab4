package at.ac.tuwien.big.views.gen

import java.io.File
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import at.ac.tuwien.big.views.ViewModel
import at.ac.tuwien.big.views.ViewGroup
import at.ac.tuwien.big.views.View
import at.ac.tuwien.big.views.ClassIndexView
import at.ac.tuwien.big.views.DeleteView
import at.ac.tuwien.big.views.CreateView
import at.ac.tuwien.big.views.ReadView
import at.ac.tuwien.big.views.UpdateView

class View2HTMLGenerator implements IGenerator {
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		if (resource.contents.get(0) instanceof ViewModel) {
			var viewModel = resource.contents.get(0) as ViewModel		
			val htmlFileName = new File(getWelcomeGroup(viewModel).toLowerCase+".html");
			fsa.generateFile(
				htmlFileName.toString,'''
					<!DOCTYPE html>
					«var welcomegroup_name = getWelcomeGroup(viewModel).name»
					<html lang="en" data-ng-app="«welcomegroup_name»App">
					«generateHead(viewModel)»
					<body data-ng-controller="«welcomegroup_name»Controller">

					<nav class="navbar navbar-default">
					<div class="container-fluid">
							<div>
								<ul class="nav navbar-nav">
					«FOR current: viewModel.viewGroups»
					<li><a href="" class="viewgroup" target="Create«(current.name).toFirstUpper»">«(current.name).toFirstUpper»</a></li>
					«ENDFOR»
								</ul>
							</div>
						</div>
					</nav>
					«FOR currentViewGroup: viewModel.viewGroups»
						«FOR currentView: currentViewGroup.views»
							«generateViewCode(currentView)»
						«ENDFOR»
					«ENDFOR»
					</div>
	 	  		    </body>
					</html>'''
				)
		}
	}
	
	def generateHead(ViewModel viewModel) { '''
		<head>
			<title>Views</title>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
			<script src="../assets/moment-with-locales.js"></script>
			<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
			<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.0.7/angular.min.js"></script>
			<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.37/js/bootstrap-datetimepicker.min.js"></script>
			<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.37/css/bootstrap-datetimepicker.min.css">
			<script src="../assets/datetimepickerDirective.js"></script>
			<script src="../assets/views.js"></script>
			<script src="«getWelcomeGroup(viewModel).name».js"></script>
			<script type="text/javascript">
					$(document).ready(
						function(){	
		view.addWelcomePage('Create«getWelcomeGroup(viewModel).name.toFirstUpper»');
						  view.init();
					});
			</script>
		</head>'''
	}

	def generateViewCode(View view){
		switch view{
			ClassIndexView: 
				'''
					<div class="container" id="«removeWhitespaces(view.name)»">
			 		 <h2>«view.header»</h2>
			 		 <h3>«view.description»</h3>
			    		  <ul>
			 		   <li data-ng-repeat="«view.class_.name.toFirstLower» in «view.class_.name.toFirstLower»s">{{ «view.class_.name.toFirstLower».«view.class_.id.name.toFirstLower» }}
			 			 <a href="" data-toggle="modal" data-target="#modalShow«view.class_.name»" data-ng-click="getCourse(«view.class_.name.toFirstLower».id)">show</a>
			 		   </li>
			 		  </ul>
			    		 </div>
				'''
			ReadView:
				''' '''
			DeleteView:
				''' '''
			CreateView:
				''' '''
			UpdateView:
				''' '''
			default:
				'''Whoops. Class not found.'''
		}
	}

	def getWelcomeGroup(ViewModel model) {
		for(group : model.viewGroups)
			if(group.isWelcomeViewGroup)
				return group.name.replaceAll("\\W", "")
	}
	
	def getName(String st){
		return st.toLowerCase.replaceAll("\\W", "")
	}

	def removeWhitespaces(String text){
		return text.replaceAll("\\s+","");
	}
	
	def toCreateView(View view){
		return view 
	}

}

/*
 * 							«IF currentView.eClass.name=="ClassIndexView"»
								<div class="container" id="«removeWhitespaces(currentView.name)»">
								 		 <h2>«currentView.header»</h2>
								 		 <h3>«currentView.description»</h3>
								    		  <ul>
								 		   <li data-ng-repeat="«getStringToFirstLower(currentView.class_.name)» in «getStringToFirstLower(currentView.class_.name)»s">{{ «getStringToFirstLower(currentView.class_.name)».«getStringToFirstLower(currentView.class_.id.name)» }}
								 			 <a href="" data-toggle="modal" data-target="#modalShow«currentView.class_.name»" data-ng-click="getCourse(«getStringToFirstLower(currentView.class_.name)».id)">show</a>
								 		   </li>
								 		  </ul>
								    		 </div>
 							«ENDIF»
 							«IF currentView.eClass.name=="DeleteView"»
	 							<div class="modal fade" id="modal«removeWhitespaces(currentView.name)»">
							  	    <div class="modal-dialog">
							         <div class="modal-content">
							          <div class="modal-header">
							           <h4 class="modal-title">«currentView.header»</h4>
							          </div>
							          <div class="modal-body">
								       <p>«currentView.description»</p>
								       <h5>«currentView.name»</h5>
						       	«FOR currentProperty: currentView.class_.properties»
								       <p>«currentProperty.name»: {{ «currentView.class_.name».«currentProperty.name» }}TODO!</p>
								«ENDFOR»
							          </div>
							          <div class="modal-footer">
							           <button class="btn btn-default" data-dismiss="modal" data-ng-click="deleteCourse(course.id)">Delete</button>
							           	                        <button class="btn btn-default" data-dismiss="modal">Cancel</button>
							          </div>
							         </div>
							  	    </div>
								   </div>
 							«ENDIF»
 							«IF currentView.eClass.name=="CreateView"»
 								<div class="container" id="«removeWhitespaces(currentView.name)»">
					  			<h2>«currentView.header»</h2>
					  		  	<form name="«removeWhitespaces(currentView.name)»Form" novalidate>
								 <p>«currentView.description»</p>
					 			 <div class="panel-group">
					 			 	«IF »
					 		 	  <div class="elementgroup" ><h4>Institute Details</h4>
					 		 	  		   <div class="panel-body"><div class="form-group">
					 		 	  		     <label for="01">Number<span>*</span>:</label>	
					 		 	  		        	   <input type="text" class="form-control" id="01" name="number" data-ng-model="newinstitute.number" required data-ng-pattern="/^[0-9]+$/" />  		   <span class="CreateInstituteSpan" style="color:red" data-ng-show="CreateInstituteForm.number.$dirty && CreateInstituteForm.number.$invalid">
					 		 	  		    		   <span data-ng-show="CreateInstituteForm.number.$error.required">Input is mandatory.</span>
					 		 	  		    		   <span data-ng-show="CreateInstituteForm.number.$error.pattern">Input doesn't match expected pattern.</span>		
					 		 	  		    		  </span>
					 		 	  		    </div>
					 		 	  		   <div class="form-group">
					 		 	  		     <label for="02">Name<span>*</span>:</label>	
					 		 	  		        	   <input type="text" class="form-control" id="02" name="name" data-ng-model="newinstitute.name" required data-ng-pattern="/^[a-zA-Z -]+$/" />  		   <span class="CreateInstituteSpan" style="color:red" data-ng-show="CreateInstituteForm.name.$dirty && CreateInstituteForm.name.$invalid">
					 		 	  		    		   <span data-ng-show="CreateInstituteForm.name.$error.required">Input is mandatory.</span>
					 		 	  		    		   <span data-ng-show="CreateInstituteForm.name.$error.pattern">Input doesn't match expected pattern.</span>		
					 		 	  		    		  </span>
					 		 	  		    </div>
					 		 	  		   <div class="form-group">
					 		 	  		    			<div >
					 		 	  		    			<h5>Professors</h5>
					 		 	  		    			<ul id="03"><li data-ng-repeat="professor in professors">	
					 		 	  		    			  {{professor.email }}	
					 		 	  		      			  <a href="" data-ng-click="navigationProfessor('UpdateProfessor'); updateProfessor(professor.id)">udpate</a>
					 		 	  		    			</li></ul>
					 		 	  		    			<button value="CreateProfessor" class="btn btn-primary btn-sm">Add</button>
					 		 	  		    			</div> 
					 		 	  		    </div>
					 		 	  		   <div class="form-group">
					 		 	  		    		   <div >
					 		 	  		    		   <h5>Courses</h5>
					 		 	  		    		   <table class="table table-striped" id="04">
					 		 	  		     		 	<thead><tr>
					 		 	  		    	   		  <th>Type</th>
					 		 	  		    	   		  <th>Title</th>
					 		 	  		    	   		  <th>Credits</th>
					 		 	  		    	   		  <th></th>
					 		 	  		    	    	 </tr></thead>
					 		 	  		     		 	 <tbody><tr data-ng-repeat="course in courses">
					 		 	  		    			  <td>{{ course.type }}</td>
					 		 	  		    			  <td>{{ course.title }}</td>
					 		 	  		    			  <td>{{ course.credits }}</td>
					 		 	  		         		   <td><a href="" data-toggle="modal" data-target="#modalDeleteCourse" data-ng-click="getCourse(course.id)">delete</a></td>
					 		 	  		        		 </tr></tbody>
					 		 	  		    		   </table>
					 		 	  		    		   <button value="CreateCourse" class="btn btn-primary btn-sm">Add</button>
					 		 	  		    		 </div> 
					 		 	  		    </div>
					 		 	  		   </div></div>
					             </div>
								</form>
								</div>
 							«ENDIF»
	 	  		    	«ENDFOR»
	 	  		    «ENDFOR»
 * 
 */