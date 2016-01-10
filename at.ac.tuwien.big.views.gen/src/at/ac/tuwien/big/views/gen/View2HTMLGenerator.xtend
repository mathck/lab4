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
import at.ac.tuwien.big.views.ComparisonCondition
import at.ac.tuwien.big.views.CompositeCondition
import at.ac.tuwien.big.views.ConditionalElement

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
							«generateViewCode(currentView, currentViewGroup)»
						«ENDFOR»
					«ENDFOR»
	 	  		    </body>
					</html>
					'''
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

	def generateViewCode(View view, ViewGroup viewGroup){
		switch view {
			ClassIndexView: 
				'''
				 <div class="container" id="«removeWhitespaces(view.name)»">
				 <h2>«view.header»</h2>
				 <h3>«view.description»</h3>
				 <ul>
				 <li data-ng-repeat="«view.class_.name.toFirstLower» in «view.class_.name.toFirstLower»s">{{ «view.class_.name.toFirstLower».«view.class_.id.name.toFirstLower» }}
				 «getLinks(view)»
				 </li>
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
						«getModalButtons(view)»
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
										«getModalButtons(view)»
							          </div>
							         </div>
							  	    </div>
								   </div> 
		   		'''
			CreateView:
				generateCreateOrUpdateView(view, viewGroup)
			UpdateView:
				generateCreateOrUpdateView(view, viewGroup)
			default:
				'''Whoops. Class not found.'''
		}
	}
	
	
	def generateCreateOrUpdateView(ClassOperationView view, ViewGroup viewGroup) {
		'''
		<div class="container" id="«removeWhitespaces(view.name)»">
			<h2>«view.header»</h2>
			<form name="«removeWhitespaces(view.name)»Form" novalidate>
			<p>«view.description»</p>
			<div class="panel-group">
				«IF view.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
				<div class="row">
				«ENDIF»
					«FOR currentElementGroup : view.elementGroups»
					«IF view.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.VERTICAL)»
					<div class="elementgroup" «getConditions(view, currentElementGroup)»>
					«ELSE»
					<div class="elementgroup col-sm-6" «getConditions(view, currentElementGroup)»>
					«ENDIF»
						<h4>«currentElementGroup.header»</h4>
						<div class="panel-body">
							«IF currentElementGroup.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
							<div class="form-inline" role="form">
							«ENDIF»
								«FOR currentViewElement:currentElementGroup.viewElements»
								<div class="form-group">
								«generateViewElementCode(view, currentViewElement)»
								</div> <!-- form-group -->
								«ENDFOR» 
							«IF currentElementGroup.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
							</div> <!-- form-inline -->
							«ENDIF»
						</div> <!-- panel-body -->
					</div> <!-- elementgroup -->
					«ENDFOR»
				«IF view.layout.alignment.equals(at.ac.tuwien.big.views.LayoutStyle.HORIZONTAL)»
				</div> <!-- ROW -->
				«ENDIF»
			</div> <!-- panel-group -->
			«getSaveButtons(view, viewGroup)»
			</form>
		</div> <!-- container-div -->
		'''
	}

	def generateViewElementCode(ClassOperationView view, ViewElement viewElement){
		switch viewElement {
			Text:
			'''
			<label for="«viewElement.elementID»">«viewElement.label»«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>	
			<«IF viewElement.long»textarea rows="4" «ELSE»input type="text"«ENDIF» class="form-control" id="«viewElement.elementID»" name="«viewElement.property.name.toLowerCase»" data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toLowerCase»"
			«IF viewElement.isMandatory» required «ENDIF»data-ng-pattern="/«IF !((viewElement as Text).format.isNullOrEmpty)»«(viewElement as Text).format»«ENDIF»/" «getConditions(view, viewElement)»  «IF viewElement.long»></textarea>«ELSE»/>«ENDIF»
			«getErrorSpanTags(view, viewElement)»
			'''
			Selection:
			'''
			<label for="«viewElement.elementID»">«viewElement.label»«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>
			<select data-ng-option class="form-control" id="«viewElement.elementID»"
			data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toLowerCase»" «IF viewElement.isMandatory» required «ENDIF» «getConditions(view, viewElement)» >
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
						<label for="«viewElement.elementID»">«viewElement.label»«IF viewElement.isMandatory»<span>*</span>«ENDIF»:</label>
						<div «IF viewElement.isMandatory» required «ENDIF» class="input-group date" id="picker«viewElement.elementID»" style="«IF viewElement.property.type.name.equals("Time")»time«ELSE»calendar«ENDIF»">
								<input type="text" class="form-control" id="«viewElement.elementID»" name="date"
								data-ng-model="new«view.class_.name.toFirstLower».«viewElement.property.name.toFirstLower»" data-ng-pattern="/«(viewElement as DateTimePicker).format»/"
								«getConditions(view, viewElement)» />
								<span class="input-group-addon">
									<span class="glyphicon glyphicon-«IF viewElement.property.type.name.equals("Time")»time«ELSE»calendar«ENDIF»"></span>
								</span>
						</div> <!--  id -->
					</div> <!-- form group -->
				</div> <!-- col -->
			</div> <!-- row -->
			«getErrorSpanTags(view, viewElement)»
			'''
			List:
			'''
			<div «getConditions(view, viewElement)»>
			<h5>«viewElement.label»</h5>
			<ul id="«viewElement.elementID»">
			<li data-ng-repeat="«viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces» in «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces»s">
			{{ «viewElement.association.navigableEnd.type.name.toLowerCase.removeWhitespaces».«(viewElement.association.navigableEnd.type as at.ac.tuwien.big.views.Class).id.name.removeWhitespaces.toFirstLower » }}
			«getLinks(viewElement)»
			</li>
			</ul>
			«getAddButtons(viewElement)»
			</div>
			'''
			Table:
			'''
			<div «getConditions(view, viewElement)»>
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
				</td>
				</tr>
				</tbody>
				</table>
				«getAddButtons(viewElement)»
			</div>
			'''
			default: ''''''
		}
	}
	
	def getLinks(LinkableElement element) {
		'''
		«FOR link:(element).link» 
			«IF(link.label.equalsIgnoreCase("update"))»
				<a href="" data-ng-click="navigation«link.targetView.class_.name»('«link.targetView.name.removeWhitespaces»');
				update«link.targetView.class_.name»(«link.targetView.class_.name.toFirstLower».id)">update</a>
			«ENDIF»
			«IF(link.label.equalsIgnoreCase("show"))»
				<a href="" data-toggle="modal" data-target="#modal«link.targetView.name.removeWhitespaces»" data-ng-click="get«link.targetView.class_.name»(«link.targetView.class_.name.toFirstLower».id)">show</a>
			«ENDIF»
			«IF(link.label.equalsIgnoreCase("delete"))»
				<a href="" data-toggle="modal" data-target="#modal«link.targetView.name.removeWhitespaces»"	data-ng-click="get«link.targetView.class_.name»(«link.targetView.class_.name.toFirstLower».id)">delete</a>
			«ENDIF»
		«ENDFOR»
		'''
	}
	
	def getAddButtons(LinkableElement viewElement) {
		'''
		«FOR link : viewElement.link»
			«IF (link.targetView instanceof CreateView)»
			<button value="«link.targetView.name.removeWhitespaces»" class="btn btn-primary btn-sm">Add</button>
			«ENDIF»
		«ENDFOR»
		'''
	}
	
	def getSaveButtons(View view, ViewGroup viewGroup) {
		'''
		«IF !(view.isStartView == true && viewGroup.welcomeViewGroup == true)»
		<button value="«viewGroup.views.findFirst[it.startView].name.removeWhitespaces»" class="btn btn-primary btn-sm"
			data-ng-disabled="«view.name.removeWhitespaces»Form.$invalid"
			data-ng-click="save«view.class_.name.removeWhitespaces»()">
			Save
		</button>
		«ENDIF»
		'''
	}
	
	def getModalButtons(View view) {
		'''
		«IF (view instanceof ReadView)»
		<button class="btn btn-default" data-dismiss="modal">Close</button>
		«ENDIF»
		«IF (view instanceof DeleteView) »
		<button class="btn btn-default" data-dismiss="modal"
		data-ng-click="delete«view.class_.name.toFirstUpper»(«view.class_.name.toFirstLower».id)">Delete</button>
		<button class="btn btn-default" data-dismiss="modal">Cancel</button>
		«ENDIF»
		'''
	}
	
	def getConditions(View view, ConditionalElement viewElement) {
		'''
		«IF viewElement.condition instanceof ComparisonCondition»
		«var condition = (viewElement.condition as ComparisonCondition)»
		data-ng-«correctNgVisibility(condition.type.getName())»="new«view.class_.name.toLowerCase».«condition.property.property.name.toLowerCase.removeWhitespaces» «correctNgComparison(condition.comparisonType.getName())» '«condition.comparisonValue»'"
		«ENDIF»
		«IF viewElement.condition instanceof CompositeCondition»
		«var composition = (viewElement.condition as CompositeCondition)»
		«var condition1 = composition.composedConditions.get(0) as ComparisonCondition»
		«var condition2 = composition.composedConditions.get(1) as ComparisonCondition»
		data-ng-«correctNgVisibility(composition.type.getName())»="new«view.class_.name.toLowerCase».«condition1.property.property.name.toLowerCase.removeWhitespaces» «correctNgComparison(condition1.comparisonType.getName())» '«condition1.comparisonValue»' «correctNgComposition(composition.compositionType.getName())» new«view.class_.name.toLowerCase».«condition2.property.property.name.toLowerCase.removeWhitespaces» «correctNgComparison(condition2.comparisonType.getName())» '«condition2.comparisonValue»'"
		«ENDIF»
		'''
	}
	
	def correctNgComposition(String text) {
		return text.replace("And", "&&").replace("Or", "||");
	}
	
	def correctNgComparison(String text) {
		return text.replace("Equal", "==").replace("Less", "<").replace("Greater", ">");
	}
	
	def correctNgVisibility(String text) {
		return text.toLowerCase.replace("enable", "enabled").replace("disable", "disabled");
	}
	
	def getErrorSpanTags(ClassOperationView view, PropertyElement viewElement) {
		switch viewElement {
			Text:
			'''
			<span class="«view.name.removeWhitespaces»Span" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toFirstLower.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
	    	«IF !((viewElement as Text).format.isNullOrEmpty)»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$error.pattern">Input doesn't match expected pattern.</span>«ENDIF»
	  		</span>
	  		'''
	  		DateTimePicker:
	  		'''<span class="«view.name.removeWhitespaces»Span" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toFirstLower.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
	    	«IF !((viewElement as DateTimePicker).format.isNullOrEmpty)»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$error.pattern">Input doesn't match expected pattern.</span>«ENDIF»
	  	</span>'''
	  		Selection:
	  		'''<span class="«view.name.removeWhitespaces»Span" style="color:red" data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$dirty && «view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$invalid">
	    	«IF viewElement.isMandatory»<span data-ng-show="«view.name.removeWhitespaces»Form.«viewElement.property.name.toLowerCase.removeWhitespaces».$error.required">Input is mandatory.</span>«ENDIF»
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