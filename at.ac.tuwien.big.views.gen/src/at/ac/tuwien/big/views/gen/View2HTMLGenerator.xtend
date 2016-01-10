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
import at.ac.tuwien.big.views.PropertyElement
import at.ac.tuwien.big.views.ViewElement
import at.ac.tuwien.big.views.Text
import at.ac.tuwien.big.views.ClassOperationView
import at.ac.tuwien.big.views.Selection
import at.ac.tuwien.big.views.DateTimePicker
import at.ac.tuwien.big.views.impl.DateTimePickerImpl
import at.ac.tuwien.big.views.EnumerationLiteralItem
import javax.swing.LayoutStyle
import at.ac.tuwien.big.views.List
import at.ac.tuwien.big.views.Table
import at.ac.tuwien.big.views.DomainModelElement
import at.ac.tuwien.big.views.LinkableElement
import at.ac.tuwien.big.views.AssociationElement

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
					<li><a href="" class="viewgroup" target="«(current.views.findFirst[it.startView == true].name.replace(" ", "")).toFirstUpper»">«(current.name).toFirstUpper»</a></li>
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
		view.addWelcomePage('Create«(getWelcomeGroup(viewModel)).name.toFirstUpper»');
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
			 		   «getIndexLinks(view)»
			 		   	</ul>
			    		 </div>
				'''
			ReadView:
				'''<div class="modal fade" id="modal«removeWhitespaces(view.name)»">
			  	    <div class="modal-dialog">
			         <div class="modal-content">
			          <div class="modal-header">
			           <h4 class="modal-title">«view.header»</h4>
			          </div>
			          <div class="modal-body">
				       <p>«view.description»</p>
				       <h5>«view.name»</h5>
		       	«FOR currentElementGroup:(view as ReadView).elementGroups»
		       		«FOR currentViewElement:currentElementGroup.viewElements.filter(PropertyElement)»
				       <p>«currentViewElement.label»: {{ «view.class_.name.toFirstLower».«(currentViewElement as PropertyElement).property.name.toFirstLower» }}</p>
			       «ENDFOR»
				«ENDFOR»
			          </div>
			          <div class="modal-footer">
			           <button class="btn btn-default" data-dismiss="modal" data-ng-click="deleteCourse(course.id)">Delete</button>
			           	                        <button class="btn btn-default" data-dismiss="modal">Cancel</button>
			          </div>
			         </div>
			  	    </div>
				   </div> 
			   '''
			DeleteView:
				'''
					<div class="modal fade" id="modal«removeWhitespaces(view.name)»">
							  	    <div class="modal-dialog">
							         <div class="modal-content">
							          <div class="modal-header">
							           <h4 class="modal-title">«view.header»</h4>
							          </div>
							          <div class="modal-body">
								       <p>«view.description»</p>
								       <h5>«view.name»</h5>
						       	«FOR currentElementGroup:(view as DeleteView).elementGroups»
						       		«FOR currentViewElement:currentElementGroup.viewElements.filter(PropertyElement)»
								       <p>«currentViewElement.label»: {{ «view.class_.name.toFirstLower».«(currentViewElement as PropertyElement).property.name.toFirstLower» }}</p>
							       «ENDFOR»
								«ENDFOR»
							          </div>
							          <div class="modal-footer">
							           <button class="btn btn-default" data-dismiss="modal" data-ng-click="deleteCourse(course.id)">Delete</button>
							           	                        <button class="btn btn-default" data-dismiss="modal">Cancel</button>
							          </div>
							         </div>
							  	    </div>
								   </div> 
		   		'''
			CreateView:
				'''
 								<div class="container" id="«removeWhitespaces(view.name)»">
					  			<h2>«view.header»</h2>
					  		  	<form name="«removeWhitespaces(view.name)»Form" novalidate>
								 <p>«view.description»</p>
					 			 <div class="panel-group">
					 			 «IF view.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
					 			 <div class="row">
					 			 «ENDIF»
					 			 «FOR currentElementGroup : (view as CreateView).elementGroups»
					 		 	 	«IF view.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.VERTICAL)»
					 		 	  	<div class="elementgroup" «getConditions()»>
					 		 	  	«ELSE»
					 		 	  	<div class="elementgroup col-sm-6" «getConditions()»>
									«ENDIF»
										<h4>«currentElementGroup.header»</h4>
					 		 	  		   <div class="panel-body">
			 		 	  		   	«IF currentElementGroup.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
					 		 	  	<div class="form-inline" role="form">
				 		 	  		«ENDIF»
				 		 	  		«FOR currentViewElement:currentElementGroup.viewElements»
					 		 	  		   <div class="form-group">
				 		 	  				«generateViewElementCode(view, currentViewElement)»
				 		 	  				</div>
				 		 	  		«ENDFOR» 
					 		 	  		    </div>
					 		 	  		   </div>
					 		 	  		   «ENDFOR»
					 		 	  		   </div>
					             </div>
								</form>
								</div>
							'''
			UpdateView:
				''' '''
			default:
				'''Whoops. Class not found.'''
		}
	}

	def generateViewElementCode(ClassOperationView view, ViewElement viewElement){
		switch viewElement {
			Text:
				'''
	 		 	  		      <label for="«viewElement.elementID»">«viewElement.label»:«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>	
	 	  		        	   <«IF viewElement.long»textarea«ELSE»input type="text"«ENDIF» class="form-control" id="«viewElement.elementID»" name="«viewElement.property.name.toFirstLower»" data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toFirstLower»" 
	  		        	   		«IF viewElement.isMandatory» required «ENDIF»«IF !((viewElement as Text).format.isNullOrEmpty)»data-ng-pattern="/«(viewElement as Text).format»/"«ENDIF» />
	  		        	   		«getErrorSpanTags(view, viewElement)»
				'''
			Selection:
			'''
			<label for="«viewElement.elementID»">«viewElement.label»:«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>
			<select data-ng-option class="form-control" id="«viewElement.elementID»"
			data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toFirstLower»" «IF viewElement.isMandatory» required «ENDIF» «getConditions()» >
			<option value="" disabled selected>Select your option</option>
			«FOR item:(viewElement as Selection).selectionItems»
			«IF (item instanceof EnumerationLiteralItem)»<option value="«(item as EnumerationLiteralItem).enumerationLiteral.value»">«(item as EnumerationLiteralItem).value»</option>«ELSE»<option value="«item.value»">«item.value»</option>«ENDIF»
			«ENDFOR»
			</select>
			«getErrorSpanTags(view, viewElement)»
			'''
			DateTimePicker:
			'''
			<div class="row">
				<div class="col-xs-6 col-sm-12">
					<div class="form-group">
						<label for="«viewElement.elementID»">«viewElement.label»:«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>
						//pickers for properties with datatype "Date":
							<div «IF viewElement.isMandatory» required «ENDIF» class="input-group date" id="picker«viewElement.elementID»" style="calendar">
								<div class='input-group date' id='picker«viewElement.elementID»' style='«IF viewElement.property.type.name.equals("Time")»time«ELSE»calendar«ENDIF»'>
									<input type="text" class="form-control" id="«viewElement.elementID»" name="date"
									data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toFirstLower»" data-ng-pattern="«(viewElement as DateTimePicker).format»"
									«getConditions()» />
							<span class="input-group-addon">
								<span class="glyphicon glyphicon-«IF viewElement.property.type.name.equals("Time")»time«ELSE»calendar«ENDIF»"></span>
							</span>
						</div>
					</div>
				</div>
			</div>
			«getErrorSpanTags(view, viewElement)»
			'''
			List:
			'''
			<div «getConditions()»/>
			<h5>«viewElement.label»</h5>
			<ul id="«viewElement.elementID»">
			<li data-ng-repeat="«viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces» in «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces»s">
			{{ «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces».«(viewElement.association.navigableEnd.type as at.ac.tuwien.big.views.Class).id.name.removeWhitespaces.toFirstLower » }}
			«getLinks(viewElement)»
			</li>
			</ul>
			«getAddButtons(view)»
			</div>
			'''
			Table:
			'''
			<div «getConditions()»>
				<h5>«viewElement.label»</h5>
				<table class="table table-striped" id="«viewElement.elementID»">
				<thead>
				<tr>
				«FOR col:(viewElement as Table).columns»
				<th>«col.label»</th>
				«ENDFOR»
				<th></th>
				</tr>
				</thead>
				<tbody>
				<tr data-ng-repeat="«viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces» in «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces»s">
				«FOR col:(viewElement as Table).columns»
				<td> {{ «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces».«col.property.name.toFirstLower» }} </td>
				«ENDFOR»
				<td>
				«getLinks(viewElement)»
				</tr>
				</tbody>
				</table>
				«getAddButtons(view)»
			</div>
			'''
			default: ''''''
		}
	}
	
	def getIndexLinks(View view) {
		if(view instanceof ClassIndexView){
			'''
			«FOR link:(view as ClassIndexView).link» 
				//link to read view
				<a href="" data-toggle="modal" data-target="#modalShowCourse"
				data-ng-click="getCourse(course.id)">show</a>
				13
				//link to delete view
				<a href="" data-toggle="modal" data-target="#modalDeleteCourse"
				data-ng-click="getCourse(course.id)">delete</a></td>
				//link to update view <a href="" data-ng-click="navigationProfessor('UpdateProfessor');
				updateProfessor(professor.id)">udpate</a>
			«ENDFOR»
			'''
		}
	}
	
	def getLinks(ViewElement viewElement) {
		switch viewElement  {
			Table:
			'''
			«FOR link:(viewElement as Table).link» 
				«IF(link.label.equalsIgnoreCase("update"))»
					<a href="" data-ng-click="navigation«link.targetView.class_.name»('«link.targetView.name.removeWhitespaces»');
					update«link.targetView.class_.name»(«link.targetView.class_.name.toFirstLower».id)">udpate</a>
				«ENDIF»
				«IF(link.label.equalsIgnoreCase("show"))»
					<a href="" data-toggle="modal" data-target="#modal«link.targetView.name.removeWhitespaces»" data-ng-click="get«link.targetView.class_.name»(«link.targetView.class_.name.toFirstLower».id)">show</a>
				«ENDIF»
				«IF(link.label.equalsIgnoreCase("show"))»
					<a href="" data-toggle="modal" data-target="#modalDeleteCourse"	data-ng-click="getCourse(course.id)">delete</a></td>
				«ENDIF»
			«ENDFOR»
			'''
			List:
			'''
			«FOR link:(viewElement as Table).link» 
				//link to read view
				<a href="" data-toggle="modal" data-target="#modalShowCourse"
				data-ng-click="getCourse(course.id)">show</a>
				13
				//link to delete view
				<a href="" data-toggle="modal" data-target="#modalDeleteCourse"
				data-ng-click="getCourse(course.id)">delete</a></td>
				//link to update view <a href="" data-ng-click="navigationProfessor('UpdateProfessor');
				updateProfessor(professor.id)">udpate</a>
			«ENDFOR»
			'''
		}
	}
	
	def getAddButtons(View targetView) {
		'''
		<button value="«targetView.name.removeWhitespaces»" class="btn btn-primary btn-sm">Add</button>
		'''
	}
	
	def getSaveButtons(View view, ViewGroup welcomeViewGroup) {
		'''
		«IF !(view.isStartView == true && welcomeViewGroup.views.contains(view) && welcomeViewGroup.welcomeViewGroup == true)»
		<button value="«welcomeViewGroup.views.findFirst[it.startView].name.removeWhitespaces»" class="btn btn-primary btn-sm"
			data-ng-disabled="«view.name.removeWhitespaces»Form.$invalid"
			data-ng-click="save«view.class_.name.removeWhitespaces»">
			Save
		</button>
		«ENDIF»
		'''
	}
	
	def getModalButtons(View view) {
		'''
		switch
		//modal buttons for read view
		<button class="btn btn-default" data-dismiss="modal">Close</button>
		//modal buttons for delete view
		<button class="btn btn-default" data-dismiss="modal"
		data-ng-click="delete«view.class_.name.toFirstUpper»(«view.class_.name.toFirstLower».id)">Delete</button>
		<button class="btn btn-default" data-dismiss="modal">Cancel</button>
		'''
	}
	
	def getConditions() {
		
	}
	
	def getErrorSpanTags(ClassOperationView view, PropertyElement viewElement) {
		switch viewElement {
			Text:
			'''<span class="CreateInstituteSpan" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
	    	«IF !((viewElement as Text).format.isNullOrEmpty)»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower».$error.pattern">Input doesn't match expected pattern.</span>«ENDIF»
	  	</span>'''
	  		DateTimePicker:
	  		'''<span class="CreateInstituteSpan" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
	    	«IF !((viewElement as DateTimePicker).format.isNullOrEmpty)»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$error.pattern">Input doesn't match expected pattern.</span>«ENDIF»
	  	</span>'''
	  		Selection:
	  		'''<span class="CreateInstituteSpan" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.label.toFirstLower.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
	  	</span>'''
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
	
	def isMandatory(PropertyElement element){
		if(element.property.lowerBound==1 && element.property.upperBound==1){
			return true;
		}else{
			return false;
		}
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