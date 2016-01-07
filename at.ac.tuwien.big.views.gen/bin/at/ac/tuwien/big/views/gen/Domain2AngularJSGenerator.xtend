package at.ac.tuwien.big.views.gen

import java.io.File
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import at.ac.tuwien.big.views.DomainModel
import at.ac.tuwien.big.views.Class
import at.ac.tuwien.big.views.DomainModelElement

class Domain2AngularJSGenerator implements IGenerator {
	
	override doGenerate(Resource resource, IFileSystemAccess fsa) {
		if (resource.contents.get(0) instanceof DomainModel) {
			var domainModel = resource.contents.get(0) as DomainModel
			val angularJSFileName = new File(getFirstClassName(domainModel).toLowerCase+".js");
			fsa.generateFile(
				angularJSFileName.toString,
				'''
				«generateModule(domainModel)»
				«generateService(domainModel)»
				«generateController(domainModel)»'''
			)
		}
	}
	
	def generateModule(DomainModel model) {
		'''var module = angular.module('«getFirstClassName(model)»App', []);'''
	}
	
	def generateService(DomainModel model) {
		'''module.service('«getFirstClassName(model)»Service', function () {
	«FOR current: model.domainModelElements.filter(Class)»
	var «getDomainModelElementName(current)»s = [];
	var «getDomainModelElementName(current)»id = 0;

	this.save«getStringFirstLetterCaps(getDomainModelElementName(current))»Service = function («getDomainModelElementName(current)») {
		if («getDomainModelElementName(current)».id == null) {
			«getDomainModelElementName(current)».id = «getDomainModelElementName(current)»id++;
			«getDomainModelElementName(current)»s.push(«getDomainModelElementName(current)»);
		} else {
			for (i in «getDomainModelElementName(current)»s) {
				if («getDomainModelElementName(current)»s[i].id == «getDomainModelElementName(current)».id) {
					«getDomainModelElementName(current)»s[i] = «getDomainModelElementName(current)»;
				}
			}
		}
	}

	this.get«getStringFirstLetterCaps(getDomainModelElementName(current))»Service = function (id) {
		for (i in «getDomainModelElementName(current)»s) {
			if («getDomainModelElementName(current)»s[i].id == id) {
				return «getDomainModelElementName(current)»s[i];
			}
		}
	}

	this.delete«getStringFirstLetterCaps(getDomainModelElementName(current))»Service = function (id) {
		for (i in «getDomainModelElementName(current)»s) {
			if («getDomainModelElementName(current)»s[i].id == id) {
				«getDomainModelElementName(current)»s.splice(i, 1);
			}
		}
	}

	this.list«getStringFirstLetterCaps(getDomainModelElementName(current))»Service = function () {
		return «getDomainModelElementName(current)»s;
	}
	«ENDFOR»
});'''
	}
	
	def generateController(DomainModel model) {	'''
module.controller('«getFirstClassName(model)»Controller', function ($scope, «getFirstClassName(model)»Service) {
	«FOR current: model.domainModelElements.filter(Class)»
	$scope.«getDomainModelElementName(current)»s = «getFirstClassName(model)»Service.list«getStringFirstLetterCaps(getDomainModelElementName(current))»Service();

	$scope.save«getStringFirstLetterCaps(getDomainModelElementName(current))» = function () {
		«getFirstClassName(model)»Service.save«getStringFirstLetterCaps(getDomainModelElementName(current))»Service($scope.new«getDomainModelElementName(current)»);
		$scope.new«getDomainModelElementName(current)» = {};
	}

	$scope.delete«getStringFirstLetterCaps(getDomainModelElementName(current))» = function (id) {
		«getFirstClassName(model)»Service.delete«getStringFirstLetterCaps(getDomainModelElementName(current))»Service(id);
	}

	$scope.update«getStringFirstLetterCaps(getDomainModelElementName(current))» = function (id) {
		$scope.new«getDomainModelElementName(current)» = angular.copy(«getFirstClassName(model)»Service.get«getStringFirstLetterCaps(getDomainModelElementName(current))»Service(id));
	}

	$scope.get«getStringFirstLetterCaps(getDomainModelElementName(current))» = function (id) {
		$scope.«getDomainModelElementName(current)» = angular.copy(«getFirstClassName(model)»Service.get«getStringFirstLetterCaps(getDomainModelElementName(current))»Service(id));
	}

	$scope.navigation«getStringFirstLetterCaps(getDomainModelElementName(current))» = function (targetView) {
		$(".container").hide(); 
		var view = angular.element('#'+targetView);
		view.show();
	}
	«ENDFOR»
});'''
	}
	
	def getFirstClassName(DomainModel model) {
		var classname = model.domainModelElements.filter(Class).get(0)
		return classname.name.toLowerCase.replaceAll("\\W", "");
	}
	
	def getDomainModelElementName(Class element) {
		return element.name.toLowerCase.replaceAll("\\W", "");
	}
	
	def getXClassName(DomainModel model, int x) {
		var classname = model.domainModelElements.filter(Class).get(x)
		return classname.name.toLowerCase.replaceAll("\\W", "");
	}
	
	def getClassAmount(DomainModel model) {
		return model.domainModelElements.filter(Class).size();
	}
	
	def getStringFirstLetterCaps(String text) {
		return text.charAt(0).toString.toUpperCase + text.substring(1);
	}	
}