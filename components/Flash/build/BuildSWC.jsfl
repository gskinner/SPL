/*
* SPL; AS3 Spelling library for Flash and the Flex SDK. 
* 
* Copyright (c) 2013 gskinner.com, inc.
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/
var outputURI;
var fileFilter = {SPLAllClasses:true, SPLCoreClasses:true, SPLCustomWordlistLSO:true, SPLTag:true, SPLWordListLoader:true};

var wasOpen; //Array
var currDOM;

fl.outputPanel.clear();

function build() {
	currDOM = fl.getDocumentDOM();
	if (currDOM == null) { trace('Open at least one fla file.'); return; }
	
	var openDocs = fl.documents;
	var l = openDocs.length;
	wasOpen = [];
	for (i=0;i<l;i++) {
		wasOpen.push(openDocs[i].path);
	}
	
	//Windows paths
	if (currDOM.path.indexOf('\\') > -1) {
		var outPathArr = currDOM.path.split('\\');
		outPathArr.pop();
		var outPath = outPathArr.join("/") + '/';
		
		outputURI = 'file:///'+outPathArr.join("/") + '/';
	} else {
		var outPathArr = currDOM.path.split('/');
		outPathArr.pop();
		var outPath = outPathArr.join("/") + '/';
		
		outputURI = 'file://'+outPathArr.join("/") + '/';
	}	
	
	var files = FLfile.listFolder(outputURI, 'files');
	
	while (files.length) {
		var filePath = files.pop();
		var fileName = filePath.split('/').pop();
		var filterFileName = fileName.split('.')[0];
		var type = fileName.split('.')[1];
		
		//Only open allowed files.
		if (!fileFilter[filterFileName] || type != 'fla') { continue; }
		
		fl.openDocument(outputURI+filePath);
		
		buildSWC();
	}	
}
build();

function isWasOpened() { //Boolean
	var currPath = currDOM.path;
	for (i=0;i<wasOpen.length;i++) {
		if (currPath == wasOpen[i]) {
			return true;
		}
	}
	return false;
}

function buildSWC() {
	currDOM = fl.getDocumentDOM();
	if (currDOM == null) { 
		trace('Error, no open document.');
		return;
	}
	
	var component = findComponent();
	if (component == null) {
		trace('No componets found in: ' + currDOM.name);
		return;
	}
	var path = outputURI + component.name.split('/').pop() + '.swc';
	component.exportSWC(path);
	
	if (!isWasOpened()) {
		fl.closeDocument(currDOM, false);
	}
}

/**
 * Searches the current library for any component type files.
 */
function findComponent() {
	var lib = currDOM.library;
	var currName = currDOM.name.split('.')[0];
	
	var items = lib.items;
	var l = items.length;
	
	for (i=0;i<l;i++) {
		var item = items[i];
		var type = item.itemType;
		var name = item.name.split('/').pop();
		
		if (type == 'component' && name == currName) {
			return item;
		}
	}
	return null;
}

function trace(p_item) {
	fl.trace(p_item);
}